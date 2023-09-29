#include once "GL/gl.bi"
#include once "GL/glext.bi"
#include once "../inc/fbgl-img.bi"
#include once "../inc/vec4.bi"
#include once "../inc/mat4.bi"

#define ARRAY_ELEMENTS( a ) ( ubound( a ) + 1 )

sub initGL( w as long, h as long )
  screenRes( w, h, 32, , Fb.GFX_OPENGL )
  
  glViewport( 0, 0, w, h )
end sub

windowTitle( "learnopengl.com - Coordinate systems" )
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
glBindProc( glUniformMatrix4fv )

#include once "../inc/fbgl-texture.bi"

dim as GLuint texture1 = createGLTexture( loadBMP( "../res/container.bmp" ) )
dim as GLuint texture2 = createGLTexture( loadBMP( "../res/awesomeface.bmp" ) )

'' Load and compile shader
var shader = GLShader( "shaders/coordinate-systems.vs", "shaders/transform.fs" )

dim as GLfloat vertices( ... ) = { _
  _ '' positions        '' texture coords
   0.5f,  0.5f, 0.0f,   1.0f, 1.0f, _  '' top right
   0.5f, -0.5f, 0.0f,   1.0f, 0.0f, _  '' bottom right
  -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, _  '' bottom left
  -0.5f,  0.5f, 0.0f,   0.0f, 1.0f }   '' top left

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

'' Position
glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof( GLfloat ), 0 )
glEnableVertexAttribArray( 0 )

'' Texture coordinates
glVertexAttribPointer( 1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof( GLfloat ), cast( any ptr, ( 3 * sizeof( GLfloat ) ) ) )
glEnableVertexAttribArray( 1 )

'' Unbind the vertex array once we finish setting attributes, to avoid accidentally
'' store unwanted attributes in it.
glBindVertexArray( 0 )

'' Don't forget to activate the shader before setting uniforms 
glUseProgram( shader )
  shader.setInt( "texture1", 0 )
  shader.setInt( "texture2", 1 )

var model = fbm.rotation( radians( -55.0f ), vec4( 1.0f, 0.0f, 0.0f ) )
var view_ = fbm.translation( 0.0f, 0.0f, -3.0f )
var projection = fbm.projection( 45.0f, scrW / scrH, 0.1f, 100.0f )

'' Remember, we always pass the matrices transposed to GL
shader.setMat4( "model", model )
shader.setMat4( "view", view_ )
shader.setMat4( "projection", projection )

'dim as GLint modelLoc = glGetUniformLocation( shader, "model" )
'glUniformMatrix4fv( modelLoc, 1, GL_TRUE, @model.a )
'
'dim as GLint viewLoc = glGetUniformLocation( shader, "view" )
'glUniformMatrix4fv( viewLoc, 1, GL_TRUE, @view_.a )
'
'dim as GLint projectionLoc = glGetUniformLocation( shader, "projection" )
'glUniformMatrix4fv( projectionLoc, 1, GL_TRUE, @projection.a )

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
