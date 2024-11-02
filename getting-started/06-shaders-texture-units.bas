#include once "GL/gl.bi"
#include once "GL/glext.bi"
#include once "../inc/fbgl-img.bi"

#define ARRAY_ELEMENTS( a ) ( ubound( a ) + 1 )

sub initGL( w as long, h as long )
  screenRes( w, h, 32, , Fb.GFX_OPENGL )
  
  glViewport( 0, 0, w, h )
end sub

windowTitle( "learnopengl.com - Texture units" )
const as long scrW = 800, scrH = 600

'' Set the OpenGL context
InitGL( scrW, scrH )

'' Bind extensions used for the example
#include once "../inc/fbgl-shader.bi"

glBindProc( glGenBuffers )
glBindProc( glBindBuffer )
glBindProc( glBufferData )
glBindProc( glDeleteBuffers )

glBindProc( glGenVertexArrays )
glBindProc( glBindVertexArray )
glBindProc( glDeleteVertexArrays )
glBindProc( glVertexAttribPointer )
glBindProc( glEnableVertexAttribArray )

glBindProc( glUseProgram )
glBindProc( glActiveTexture )

function createGLTexture( img as Fb.Image ptr ) as GLuint
  '' Create an OpenGL texture
  dim as GLuint texture
  glGenTextures( 1, @texture )
  
  '' Bind the newly created texture
  glBindTexture( GL_TEXTURE_2D, texture )
  
  /'
    These calls set the format of the bitmap that GL uses so we can use the Fb.Image
    buffers directly and upload them to the shader	
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

'' Load textures
dim as GLuint texture1 = createGLTexture( loadBMP( "../res/container.bmp" ) )
dim as GLuint texture2 = createGLTexture( loadBMP( "../res/awesomeface.bmp" ) )

'' Load and compile shader
var shader = GLShader( "shaders/texture-unit.vs", "shaders/texture-unit.fs" )

dim as GLfloat vertices( ... ) = { _
  _ '' Positions        Colors              Texture coords
   0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f, _  '' top right
   0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f, _  '' bottom right
  -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f, _  '' bottom left
  -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f }   '' top left

dim as GLuint indices( ... ) = { _
  0, 1, 3, _   '' First triangle
  1, 2, 3 }    '' Second triangle  

'' Vertex array object
dim as GLuint VAO
glGenVertexArrays( 1, @VAO )

'' Vertex buffer object
dim as GLuint VBO
glGenBuffers( 1, @VBO )

'' Element buffer object
dim as GLuint EBO
glGenBuffers( 1, @EBO )

'' Bind the vertex array. All subsequent attributes we define here will be bound to
'' the array, so we can just use the vertex array object instead of having to bind
'' everything again.
glBindVertexArray( VAO )

glBindBuffer( GL_ARRAY_BUFFER, VBO )
glBufferData( GL_ARRAY_BUFFER, ARRAY_ELEMENTS( vertices ) * sizeof( GLfloat ), @vertices( 0 ), GL_STATIC_DRAW )

glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, EBO )
glBufferData( GL_ELEMENT_ARRAY_BUFFER, ARRAY_ELEMENTS( indices ) * sizeof( GLuint ), @indices( 0 ), GL_STATIC_DRAW )

'' Position
glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof( GLfloat ), 0 )
glEnableVertexAttribArray( 0 )

'' Color
glVertexAttribPointer( 1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof( GLfloat ), cast( any ptr, ( 3 * sizeof( GLfloat ) ) ) )
glEnableVertexAttribArray( 1 )

'' Texture coordinates
glVertexAttribPointer( 2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof( GLfloat ), cast( any ptr, ( 6 * sizeof( GLfloat ) ) ) )
glEnableVertexAttribArray( 2 )

'' Unbind the vertex array once we finish setting attributes, to avoid accidentally
'' store unwanted attributes in it.
glBindVertexArray( 0 )

'' Don't forget to activate the shader before setting uniforms 
glUseProgram( shader )
  shader.setInt( "texture1", 0 )
  shader.setInt( "texture2", 1 )

do
  '' Clear the color buffer
  glClearColor( 0.2f, 0.3f, 0.3f, 1.0f )
  glClear( GL_COLOR_BUFFER_BIT )
  
  '' Bind shader
  glUseProgram( shader )
  
  '' Bind each texture to a texture unit
  glActiveTexture( GL_TEXTURE0 )
  glBindTexture( GL_TEXTURE_2D, texture1 )
  glActiveTexture( GL_TEXTURE1 )
  glBindTexture( GL_TEXTURE_2D, texture2 )
  
  '' Bind element array and render it
  glBindVertexArray( VAO )
    glDrawElements( GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0 )
  glBindVertexArray( 0 )
  
  flip()
  
  sleep( 1, 1 )
loop until( len( inkey() ) )

'' Cleanup
glDeleteVertexArrays( 1, @VAO )
glDeleteBuffers( 1, @VBO )
glDeleteTextures( 1, @texture1 )
glDeleteTextures( 1, @texture2 )
