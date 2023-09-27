#include once "GL/gl.bi"
#include once "GL/glext.bi"
#include once "fbgfx.bi"

#define ARRAY_ELEMENTS( a ) ( ubound( a ) + 1 )

sub initGL( w as long, h as long )
  screenRes( w, h, 32, , Fb.GFX_OPENGL )
  
  glViewport( 0, 0, w, h )
end sub

windowTitle( "learnopengl.com - Uniforms" )
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
glBindProc( glUniform4f )

var shader = GLShader( "shaders/hello-triangle.vs", "shaders/hello-triangle-uniforms.fs" )

dim as GLfloat vertices( ... ) = { _
   0.0f,  0.5f, 0.0f, _
  -0.5f, -0.5f, 0.0f, _
   0.5f, -0.5f, 0.0f }

'' Vertex array object
dim as GLuint VAO
glGenVertexArrays( 1, @VAO )

'' Vertex buffer object
dim as GLuint VBO
glGenBuffers( 1, @VBO )

'' Bind the vertex array. All subsequent attributes we define here will be bound to
'' the array, so we can just use the vertex array object instead of havint to bind
'' everything again.
glBindVertexArray( VAO )

glBindBuffer( GL_ARRAY_BUFFER, VBO )
glBufferData( GL_ARRAY_BUFFER, ARRAY_ELEMENTS( vertices ) * sizeof( GLfloat ), @vertices( 0 ), GL_STATIC_DRAW )

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
  
  '' Set the green component of the triangle depending on a variable
  dim as GLfloat timeValue_ = timer()
  dim as GLfloat greenValue = sin( timeValue_ ) / 2.0f + 0.5f
  
  dim as GLint vertexColorLocation = glGetUniformLocation( shader, "ourColor" )
  glUniform4f( vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f )
  
  '' Bind vertex array and render it
  glBindVertexArray( VAO )
    glDrawArrays( GL_TRIANGLES, 0, 3 )
  glBindVertexArray( 0 )
  
  flip()
  
  sleep( 1, 1 )
loop until( len( inkey() ) )

'' Cleanup
glDeleteVertexArrays( 1, @VAO )
glDeleteBuffers( 1, @VBO )
