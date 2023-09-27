#include once "GL/gl.bi"
#include once "GL/glext.bi"
#include once "fbgfx.bi"
#include once "inc/fbgl-img.bi"

#define ARRAY_ELEMENTS( a ) ( ubound( a ) + 1 )

sub initGL( w as long, h as long )
  screenRes( w, h, 32, , Fb.GFX_OPENGL )
  
  glViewport( 0, 0, w, h )
end sub

windowTitle( "learnopengl.com - Hello quad" )
const as long scrW = 800, scrH = 600

'' Set the OpenGL context
InitGL( scrW, scrH )

'' Bind extensions used for the example
#include once "inc/fbgl-shader.bi"

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

glBindProc( glGenerateMipmap )

'' Load an image
var img = loadBMP( "res/wooden-container.bmp" )

'' Create the OpenGL texture object
dim as GLuint texture
glGenTextures( 1, @texture )

'' Bind the newly created texture
glBindTexture( GL_TEXTURE_2D, texture )

glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE )
glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE )

glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR )
glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR )

'' Set the format of the bitmap so we can use the Fb.image buffers directly and
'' bind them to a texture object.
glPixelStorei( GL_UNPACK_ALIGNMENT, 4 )
glPixelStorei( GL_UNPACK_ROW_LENGTH, img->pitch \ sizeof( GLuint ) )

'' Generate the texture
glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, img->width, img->height, 0, _
  GL_BGRA, GL_UNSIGNED_BYTE, cast( GLuint ptr, img ) + sizeof( Fb.image ) \ sizeof( GLuint ) )
glGenerateMipmap( GL_TEXTURE_2D )

'' We're finished so unbind the texture
glBindTexture( GL_TEXTURE_2D, 0 )

'' Once the texture is copied to GPU memory, we can free the image data
imageDestroy( img )

var shader = GLShader( "shaders/hello-triangle.vs", "shaders/hello-triangle.fs" )

dim as GLfloat vertices( ... ) = { _
    // positions          // colors           // texture coords
     0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // top right
     0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // bottom right
    -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // bottom left
    -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f }   // top left
dim as GLuint indices( ... ) = { _
  0, 1, 3, _   '' first triangle
  1, 2, 3 }    '' second triangle  

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
'' the array, so we can just use the vertex array object instead of havint to bind
'' everything again.
glBindVertexArray( VAO )

glBindBuffer( GL_ARRAY_BUFFER, VBO )
glBufferData( GL_ARRAY_BUFFER, ARRAY_ELEMENTS( vertices ) * sizeof( GLfloat ), @vertices( 0 ), GL_STATIC_DRAW )

glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, EBO )
glBufferData( GL_ELEMENT_ARRAY_BUFFER, ARRAY_ELEMENTS( indices ) * sizeof( GLuint ), @indices( 0 ), GL_STATIC_DRAW )

glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof( GLfloat ), 0 )
glEnableVertexAttribArray( 0 )

'' Unbind the vertex array once we finish setting attributes, to avoid accidentally
'' store unwanted attributes in it.
glBindVertexArray( 0 )

do
  '' Clear the color buffer
  glClearColor( 0.2f, 0.3f, 0.3f, 1.0f )
  glClear( GL_COLOR_BUFFER_BIT )
  
  '' Bind shader
  glUseProgram( shader )
  
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
glDeleteTextures( 1, @texture )