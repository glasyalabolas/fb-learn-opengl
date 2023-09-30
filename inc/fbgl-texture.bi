#include once "fbgl-img.bi"

function createGLTexture( img as Fb.Image ptr ) as GLuint
  '' Create an OpenGL texture
  dim as GLuint texture
  glGenTextures( 1, @texture )
  
  '' Bind the newly created texture
  glBindTexture( GL_TEXTURE_2D, texture )
  
  /'
    These calls set the format of the bitmap that GL uses so we can use the Fb.Image
    buffers directly and upload them to the shader.
  '/
  glPixelStorei( GL_UNPACK_ALIGNMENT, 4 )
  glPixelStorei( GL_UNPACK_ROW_LENGTH, img->pitch \ sizeof( GLuint ) )
  
  glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE )
  glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE )
  
  glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR )
  glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR )
  
  glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, img->width, img->height, 0, _
    GL_BGRA, GL_UNSIGNED_BYTE, cast( GLuint ptr, img ) + sizeof( Fb.Image ) \ sizeof( GLuint ) )
  
  '' We're finished so unbind the texture
  glBindTexture( GL_TEXTURE_2D, 0 )
  
  '' Once the texture is uploaded to GPU memory, we can free it
  imageDestroy( img )
  
  return( texture )
end function

type GLTexture
  declare constructor( as string )
  declare destructor()
  
  declare operator cast() as GLuint
  
  as GLuint ID
end type

constructor GLTexture( fileName as string )
  ID = createGLTexture( loadBMP( fileName ) )
end constructor

destructor GLTexture()
  glDeleteTextures( 1, @ID )
end destructor

operator GLTexture.cast() as GLuint
  return( ID )
end operator
