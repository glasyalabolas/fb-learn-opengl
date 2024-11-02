#include once "GL/gl.bi"
#include once "GL/glext.bi"
#include once "fbgfx.bi"

#include once "../inc/vec3.bi"
#include once "../inc/vec4.bi"
#include once "../inc/mat4.bi"
#include once "../inc/fbgl-camera.bi"

sub initGL( w as long, h as long )
  screenRes( w, h, 32, , Fb.GFX_OPENGL )
  
  glViewport( 0, 0, w, h )
  glEnable( GL_DEPTH_TEST )
end sub

windowTitle( "learnopengl.com - Light casters - Spotlight, soft" )
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
#include once "../inc/fbgl-models.bi"

var model = texturedCube()
var light = solidCube()

dim as vec4 cubePositions( ... ) = { _
  vec4(  0.0f,  0.0f,  0.0f ), _
  vec4(  2.0f,  5.0f, -15.0f ), _
  vec4( -1.5f, -2.2f, -2.5f ), _
  vec4( -3.8f, -2.0f, -12.3f ), _
  vec4(  2.4f, -0.4f, -3.5f ), _
  vec4( -1.7f,  3.0f, -7.5f ), _
  vec4(  1.3f, -2.0f, -2.5f ), _
  vec4(  1.5f,  2.0f, -2.5f ), _
  vec4(  1.5f,  0.2f, -1.5f ), _
  vec4( -1.3f,  1.0f, -1.5f ) }

'' Load and compile shaders
var shader = GLShader( "shaders/05-lightcasters-directional.vs", "shaders/05-lightcasters-spotlight-soft.fs" )
var lightShader = GLShader( "shaders/01-light-cube.vs", "shaders/01-light-cube.fs" )

'' Load textures
var diffuseMap = GLTexture( "../res/container2.bmp" )
var specularMap = GLTexture( "../res/container2_specular.bmp" )

dim as double deltaTime = 0.0, lastFrame = 0.0

'' Camera
var cam = Camera( vec4( 0.0f, 0.0f, 3.0f ) )
var lightPos = vec4( 1.2f, 1.0f, 2.0f )

'' Mouse status and last position/wheel
dim as long xpos, ypos, buttons, wheel, lastWheel = 0
dim as single lastX = scrW / 2, lastY = scrH / 2

do
  '' Render scene
  dim as double currentFrame = timer()
  
  '' Clear the color buffer
  glClearColor( 0.2f, 0.3f, 0.3f, 1.0f )
  glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT )
  
  var lightColor = vec3( 1.0f, 1.0f, 1.0f )
  var diffuseColor = lightColor * 0.5f
  var ambientColor = diffuseColor * 0.2f
  
  '' Bind shader
  with shader
    .use()
    
    .setMat4( "projection", fbm.projection( cam.fov, scrW / scrH, cam.near, cam.far ) )
    .setMat4( "view", cam.getViewMatrix() )
    .setVec3( "viewPos", cam.pos )
    
    '' Set material properties for the cube
    .setInt( "material.diffuse", 0 )
    glActiveTexture( GL_TEXTURE0 )
    glBindTexture( GL_TEXTURE_2D, diffuseMap )
    
    .setInt( "material.specular", 1 )
    glActiveTexture( GL_TEXTURE1 )
    glBindTexture( GL_TEXTURE_2D, specularMap )
    
    .setVec3(  "material.specular",  0.5f, 0.5f, 0.5f )
    .setFloat( "material.shininess", 32.0f )
    
    '' Set light properties
    .setVec3(  "light.position", cam.pos )
    .setVec3(  "light.ambient",  ambientColor )
    .setVec3(  "light.diffuse",  diffuseColor )
    .setVec3(  "light.specular", 1.0f, 1.0f, 1.0f ) 
    .setFloat( "light.constant", 1.0f )
    .setFloat( "light.linear", 0.09f )
    .setFloat( "light.quadratic", 0.032f )
    .setVec3(  "light.direction", cam.z )
    .setFloat( "light.cutOff", cos( radians( 12.5f ) ) )
    .setFloat( "light.outerCutOff", cos( radians( 17.5f ) ) )
  end with
  
  '' Render cube
  glBindVertexArray( model )
    for i as integer = 0 to ubound( cubePositions )
      '' Set the transform for the model before rendering it
      shader.setMat4( "model", fbm.translation( cubePositions( i ) ) * _
        fbm.rotation( radians( 20.0f * i ), vec4( 1.0f, 0.3f, 0.5f ) ) )
      
      glDrawArrays( GL_TRIANGLES, 0, 36 )
    next
  glBindVertexArray( 0 )
  
  '' Render light source
  with lightShader
    .use()
  
    .setMat4( "projection", fbm.projection( cam.fov, scrW / scrH, cam.near, cam.far ) )
    .setMat4( "view", cam.getViewMatrix() )
    .setMat4( "model", fbm.translation( lightPos ) * fbm.scaling( 0.2f, 0.2f, 0.2f ) )
  end with
  
  glBindVertexArray( light )
    glDrawArrays( GL_TRIANGLES, 0, 36 )
  glBindVertexArray( 0 )
  
  flip()
  
  deltaTime = currentFrame - lastFrame
  lastFrame = currentFrame
  
  dim as single cameraSpeed = 2.5f * deltaTime
  dim as single lightSpeed = 3.5 * deltaTime
  
  if( multiKey( Fb.SC_W ) ) then
    cam.pos += cam.Z * cameraSpeed
  end if
  
  if( multiKey( Fb.SC_S ) ) then
    cam.pos -= cam.Z * cameraSpeed
  end if
  
  if( multiKey( Fb.SC_A ) ) then
    cam.pos += cam.X * cameraSpeed
  end if
  
  if( multiKey( Fb.SC_D ) ) then
    cam.pos -= cam.X * cameraSpeed
  end if
  
  if( multiKey( Fb.SC_Q ) ) then
    cam.pos += cam.Y * cameraSpeed
  end if
  
  if( multiKey( Fb.SC_E ) ) then
    cam.pos -= cam.Y * cameraSpeed
  end if
  
  if( multiKey( Fb.SC_I ) ) then
    lightPos.z += lightSpeed
  end if
  
  if( multiKey( Fb.SC_K ) ) then
    lightPos.z -= lightSpeed
  end if

  if( multiKey( Fb.SC_J ) ) then
    lightPos.x += lightSpeed
  end if

  if( multiKey( Fb.SC_L ) ) then
    lightPos.x -= lightSpeed
  end if
  
  if( multiKey( Fb.SC_U ) ) then
    lightPos.y += lightSpeed
  end if
  
  if( multiKey( Fb.SC_O ) ) then
    lightPos.y -= lightSpeed
  end if
  
  if( multiKey( Fb.SC_SPACE ) ) then
    cam.lookAt( vec4( 0.0f, 0.0f, 0.0f ) )
  end if
  
  if( getMouse( xpos, ypos, wheel, buttons ) = 0 ) then
    dim as single sensitivity = 0.2f
    dim as single xoffset = ( xpos - lastX ) * sensitivity
    dim as single yoffset = ( lastY - ypos ) * sensitivity
    
    lastX = xpos
    lastY = ypos
    
    if( buttons and Fb.BUTTON_LEFT ) then
      '' Rotation about the Y axis of the WORLD (aka Yaw)
      cam.rotate( vec4( 0.0, 1.0, 0.0 ), 320.0 * xoffset / ( scrW / 2 ) * deltaTime )
      '' Rotation about the X axis of the CAMERA (aka Pitch)
      cam.rotate( cam.X, 320.0 * yoffset / ( scrH / 2 ) * deltaTime )
    end if
    
    '' Zoom in/out using the mouse wheel
    dim as long woffset = wheel - lastWheel
    lastWheel = wheel
    
    cam.fov = clamp( 1.0f, 45.0f, cam.fov - woffset )
  end if
  
  sleep( 1, 1 )
loop until( multiKey( Fb.SC_ESCAPE ) )

'' Cleanup
model.dispose()
light.dispose()
