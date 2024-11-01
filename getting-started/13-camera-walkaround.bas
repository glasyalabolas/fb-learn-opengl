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

windowTitle( "learnopengl.com - Camera - Walk around" )
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

  shader.setMat4( "projection", fbm.projection( 45.0f, scrW / scrH, 0.1f, 100.0f ) )

dim as double deltaTime = 0.0, lastFrame = 0.0

'' Camera vectors
var cameraPos = Vec4( 0.0f, 0.0f, 3.0f )
var cameraFront = Vec4( 0.0f, 0.0f, -1.0f )
var cameraUp = Vec4( 0.0f, 1.0f, 0.0f )

do
  dim as double currentFrame = timer()
  
  '' Clear the color buffer
  glClearColor( 0.2f, 0.3f, 0.3f, 1.0f )
  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT )
  
  '' Bind shader
  glUseProgram( shader )
  
  shader.setMat4( "view", fbm.lookAt( cameraPos, cameraPos + cameraFront, cameraUp ) )
  
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
  
  deltaTime = currentFrame - lastFrame
  lastFrame = currentFrame
  
  dim as single cameraSpeed = 2.5f * deltaTime
  
  if( multiKey( Fb.SC_W ) ) then
    cameraPos += cameraSpeed * cameraFront
  end if
  
  if( multiKey( Fb.SC_S ) ) then
    cameraPos -= cameraSpeed * cameraFront
  end if
  
  if( multiKey( Fb.SC_A ) ) then
    cameraPos += normalize( cross( cameraFront, cameraUp ) ) * cameraSpeed
  end if
  
  if( multiKey( Fb.SC_D ) ) then
    cameraPos -= normalize( cross( cameraFront, cameraUp ) ) * cameraSpeed
  end if
  
  sleep( 1, 1 )
loop until( multiKey( Fb.SC_ESCAPE ) )

'' Cleanup
glDeleteVertexArrays( 1, @VAO )
glDeleteBuffers( 1, @VBO )
glDeleteTextures( 1, @texture1 )
glDeleteTextures( 1, @texture2 )
