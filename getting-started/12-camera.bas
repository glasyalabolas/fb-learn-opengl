#include once "GL/gl.bi"
#include once "GL/glext.bi"
#include once "../inc/fbgl-img.bi"
#include once "../inc/vec4.bi"
#include once "../inc/mat4.bi"

#define ARRAY_ELEMENTS( a ) ( ubound( a ) + 1 )

sub initGL( w as long, h as long )
  screenRes( w, h, 32, , Fb.GFX_OPENGL )
  
  glViewport( 0, 0, w, h )
  glEnable( GL_DEPTH_TEST )
end sub

windowTitle( "learnopengl.com - Camera" )
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

glBindProc( glActiveTexture )

#include once "../inc/fbgl-texture.bi"

dim as GLuint texture1 = createGLTexture( loadBMP( "../res/container.bmp" ) )
dim as GLuint texture2 = createGLTexture( loadBMP( "../res/awesomeface.bmp" ) )

dim as GLfloat vertices( ... ) = { _
_ '' Positions          Texture coords
  -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, _
   0.5f, -0.5f, -0.5f,  1.0f, 0.0f, _
   0.5f,  0.5f, -0.5f,  1.0f, 1.0f, _
   0.5f,  0.5f, -0.5f,  1.0f, 1.0f, _
  -0.5f,  0.5f, -0.5f,  0.0f, 1.0f, _
  -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, _
  _
  -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, _
   0.5f, -0.5f,  0.5f,  1.0f, 0.0f, _
   0.5f,  0.5f,  0.5f,  1.0f, 1.0f, _
   0.5f,  0.5f,  0.5f,  1.0f, 1.0f, _
  -0.5f,  0.5f,  0.5f,  0.0f, 1.0f, _
  -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, _
  _
  -0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
  -0.5f,  0.5f, -0.5f,  1.0f, 1.0f, _
  -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
  -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
  -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, _
  -0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
  _
   0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
   0.5f,  0.5f, -0.5f,  1.0f, 1.0f, _
   0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
   0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
   0.5f, -0.5f,  0.5f,  0.0f, 0.0f, _
   0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
  _
  -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
   0.5f, -0.5f, -0.5f,  1.0f, 1.0f, _
   0.5f, -0.5f,  0.5f,  1.0f, 0.0f, _
   0.5f, -0.5f,  0.5f,  1.0f, 0.0f, _
  -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, _
  -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
  _
  -0.5f,  0.5f, -0.5f,  0.0f, 1.0f, _
   0.5f,  0.5f, -0.5f,  1.0f, 1.0f, _
   0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
   0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
  -0.5f,  0.5f,  0.5f,  0.0f, 0.0f, _
  -0.5f,  0.5f, -0.5f,  0.0f, 1.0f _
}

dim as Vec4 cubePositions( ... ) = { _
  Vec4(  0.0f,  0.0f,  0.0f ), _
  Vec4(  2.0f,  5.0f, -15.0f ), _
  Vec4( -1.5f, -2.2f, -2.5f ), _
  Vec4( -3.8f, -2.0f, -12.3f ), _
  Vec4(  2.4f, -0.4f, -3.5f ), _
  Vec4( -1.7f,  3.0f, -7.5f ), _
  Vec4(  1.3f, -2.0f, -2.5f ), _
  Vec4(  1.5f,  2.0f, -2.5f ), _
  Vec4(  1.5f,  0.2f, -1.5f ), _
  Vec4( -1.3f,  1.0f, -1.5f ) }

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

'' Position
glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof( GLfloat ), 0 )
glEnableVertexAttribArray( 0 )

'' Texture coordinates
glVertexAttribPointer( 1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof( GLfloat ), cast( any ptr, ( 3 * sizeof( GLfloat ) ) ) )
glEnableVertexAttribArray( 1 )

'' Unbind the vertex array once we finish setting attributes, to avoid accidentally
'' store unwanted attributes in it.
glBindVertexArray( 0 )

'' Load and compile shader
var shader = GLShader( "shaders/coordinate-systems.vs", "shaders/transform.fs" )

'' Don't forget to activate the shader before setting uniforms 
glUseProgram( shader )
  shader.setInt( "texture1", 0 )
  shader.setInt( "texture2", 1 )

var projection = fbm.projection( 45.0f, scrW / scrH, 0.1f, 100.0f )

shader.setMat4( "projection", projection )

do
  '' Clear the color buffer
  glClearColor( 0.2f, 0.3f, 0.3f, 1.0f )
  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT )
  
  '' Bind shader
  glUseProgram( shader )
  
  dim as single radius = 10.0f
  dim as single camX = sin( timer() ) * radius
  dim as single camZ = cos( timer() ) * radius
  
  shader.setMat4( "view", fbm.lookAt( _
    Vec4( camX, 0.0f, camZ ), Vec4( 0.0f, 0.0f, 0.0f ), Vec4( 0.0f, 1.0f, 0.0f ) ) )
  
  '' Bind each texture to a texture unit
  glActiveTexture( GL_TEXTURE0 )
  glBindTexture( GL_TEXTURE_2D, texture1 )
  glActiveTexture( GL_TEXTURE1 )
  glBindTexture( GL_TEXTURE_2D, texture2 )  
  
  '' Bind vertex array and render it
  glBindVertexArray( VAO )
    for i as integer = 0 to ubound( cubePositions )
      '' Set the transform for the model before rendering it
      shader.setMat4( "model", fbm.translation( cubePositions( i ) ) * _
        fbm.rotation( radians( 20.0f * i ), Vec4( 1.0f, 0.3f, 0.5f ) ) )
      
      glDrawArrays( GL_TRIANGLES, 0, 36 )
    next
  glBindVertexArray( 0 )
  
  flip()
  
  sleep( 1, 1 )
loop until( len( inkey() ) )

'' Cleanup
glDeleteVertexArrays( 1, @VAO )
glDeleteBuffers( 1, @VBO )
glDeleteTextures( 1, @texture1 )
glDeleteTextures( 1, @texture2 )
