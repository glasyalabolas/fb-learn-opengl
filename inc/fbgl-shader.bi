#include once "GL/gl.bi"
#include once "GL/glext.bi"
#include once "fbglext.bi"
#include once "../inc/mat4.bi"

/'
  This header contains helper functions to do shader loading/compiling
  Note that these bindings must be used AFTER an OpenGL video mode has been set.
'/
glBindProc( glCreateShader )
glBindProc( glShaderSource )
glBindProc( glCompileShader )
glBindProc( glGetShaderiv )
glBindProc( glGetShaderInfoLog )
glBindProc( glDeleteShader )
glBindProc( glCreateProgram )
glBindProc( glAttachShader )
glBindProc( glLinkProgram )
glBindProc( glDetachShader )
glBindProc( glGetProgramiv )
glBindProc( glGetProgramInfoLog )
glBindProc( glDeleteProgram )
glBindProc( glUseProgram )

glBindProc( glGetUniformLocation )
glBindProc( glUniform1i )
glBindProc( glUniform1f )
glBindProc( glUniform4f )
glBindProc( glUniformMatrix4fv )

'' Load a vertex shader
function loadVertexShader( fileName as string ) as GLuint
  dim as GLuint vertexShaderID
  dim as string code, d
  
  '' See if the file specified could be opened
  dim as integer fn = freeFile()
  dim as integer result = open( fileName for input as fn )
  
  if( result = 0 ) then
    '' If the file was opened, read it
    do while( not eof( fn ) )
      line input #fn, d
      
      code &= d & !"\n"
    loop
    
    '' Get an ID to load the shader to
    vertexShaderID = glCreateShader( GL_VERTEX_SHADER )
    
    if( vertexShaderID = 0 ) then
      '' Something went wrong, abort
      errorExit( "glCreateShader(): failed to create vertex shader" )
    end if
  else
    '' File could not be opened, probably due to the file being non-existent
    errorExit( "loadVertexShader(): failed to load " & fileName & result ) 
  end if
  
  '' Try to compile the vertex shader
  dim as GLint logSize
  dim as GLint status
  
  dim as GLchar ptr pCode = strPtr( code )
  
  glShaderSource( vertexShaderID, 1, @pCode, FBGL_NULL )
  glCompileShader( vertexShaderID )
  
  '' Check if everything went ok
  glGetShaderiv( vertexShaderID, GL_COMPILE_STATUS, @status )
  
  if( status = GL_FALSE ) then
    '' Something went wrong with compilation, get the error log
    dim as string errorLog
    
    glGetShaderiv( vertexShaderID, GL_INFO_LOG_LENGTH, @logSize )
    errorLog = space( logSize )  '' Allocates space for the log string
    pCode = strPtr( errorLog )  '' Sets the pointer to the string
    
    glGetShaderInfoLog( vertexShaderID, logSize, FBGL_NULL, pCode )
    errorExit( "glCompileShader(): failed to compile " & fileName & " vertex shader. " & !"\n  " & errorLog )
    
    '' Clean up
    glDeleteShader( vertexShaderID )
    vertexShaderID = 0    
  end if
  
  '' If everything went OK, we have our compiled vertex shader, that we
  '' can access through its ID.
  return( vertexShaderID )
end function

'' Loads a fragment shader
function loadFragmentShader( fileName as string ) as GLuint
  dim as GLuint fragmentShaderID
  dim as string code
  dim as string d
  
  '' Try to open the file
  dim as integer fn = freeFile()
  dim as integer result = open( fileName for input as fn )
  
  if( result = 0 ) then
    '' If the file was opened, read it
    do while( not eof( fn ) )
      line input #fn, d
      
      code &= d & !"\n"
    loop
    
    '' Get an ID to load to reference the shader
    fragmentShaderID = glCreateShader( GL_FRAGMENT_SHADER )
    
    if( fragmentShaderID = 0 ) then
      '' Something went wrong, abort
      errorExit( "glCreateShader(): failed to create fragment shader" )
    end if
  else
    '' File could not be opened, probably due to the file being non-existent
    errorExit( "loadFragmentShader(): failed to load " & fileName & result ) 
  end if
  
  '' Try to compile the fragment shader
  dim as GLint logSize
  dim as GLint status
  
  dim as GLchar ptr pCode = strPtr( code )
  
  glShaderSource( fragmentShaderID, 1, @pCode, FBGL_NULL )
  glCompileShader( fragmentShaderID )
  
  '' Check if everything went ok
  glGetShaderiv( fragmentShaderID, GL_COMPILE_STATUS, @status )
  
  if( status = GL_FALSE ) then
    '' Something went wrong with compilation, get the error log
    dim as string errorLog
    
    glGetShaderiv( fragmentShaderID, GL_INFO_LOG_LENGTH, @logSize )
    errorLog = space( logSize )
    pCode = strPtr( errorLog )
    
    glGetShaderInfoLog( fragmentShaderID, logSize, FBGL_NULL, pCode )
    errorExit( "glCompileShader(): failed to compile " & fileName & " fragment shader. " & !"\n  " & errorLog )
    
    '' Clean up
    glDeleteShader( fragmentShaderID )
    fragmentShaderID = 0
  end if
  
  '' If everything went OK, return the shader ID
  return( fragmentShaderID )
end function

/'
  This type holds the bare minimum required for OpenGL to actually draw something on screen: a
  vertex shader, and a fragment (pixel) shader. There are other types of shaders such as geometry and
  tesellation control, but they're useful for 3D stuff mostly.
  
  The constructor takes two string parameters: the file names of the shaders to be loaded, compiled
  and linked via the auxiliary functions that we defined before.
'/
type GLShader    
  public:
    declare constructor( vertexShader as string, fragmentShader as string )
    declare destructor()
    
    declare operator cast() as GLuint
    
    declare property ID() as GLuint
    
    declare sub use()
    
    '' Uniform utility functions
    declare sub setInt( name_ as string, value as GLint )
    declare sub setFloat( name_ as string, value as GLfloat )
    declare sub setVec4( name_ as string, x as GLfloat, y as GLfloat, z as GLfloat, w as GLfloat = 1.0f )
    declare sub setMat4( name_ as string, M as Mat4, transposed as boolean = true )
  
  private:
    as GLuint _shaderID
end type

constructor GLShader( vertexShader as string, fragmentShader as string )
  '' Loads the vertex and fragment shader code, and compile them
  dim as GLuint vertID = loadVertexShader( vertexShader )
  dim as GLuint fragID = loadFragmentShader( fragmentShader )
  
  if( vertID > 0 and fragID > 0 ) then
    '' So far so good, try to link the program
    _shaderID = glCreateProgram()
    
    glAttachShader( _shaderID, vertID )
    glAttachShader( _shaderID, fragID )
    
    glLinkProgram( _shaderID )
    
    '' Check for errors
    dim as GLint logSize
    dim as GLint status
    dim as string errorLog
    
    glGetProgramiv( _shaderID, GL_LINK_STATUS, @status )
    
    if( status = GL_FALSE ) then
      '' Some error ocurred during linking
      glGetProgramiv( _shaderID, GL_INFO_LOG_LENGTH, @logSize )
      
      dim as GLchar ptr pCode
      
      errorLog = space( logSize )
      pCode = strptr( errorLog )
      
      '' retrieve error information
      glGetProgramInfoLog( _shaderID, logSize, FBGL_NULL, pCode )
      
      glDetachShader( _shaderID, vertID )
      glDetachShader( _shaderID, fragID )
      
      glDeleteShader( vertID )
      glDeleteShader( fragID )
      
      errorExit( "glLinkShader(): failed to link shader program." & !"\n  " & errorLog )
    end if
  else
    errorExit( "glShaderProg::constructor(): failed to create shader program" )
  end if
  
  '' Detach and delete the shader ID's as they are no longer needed, we
  '' will reference the shader through its ID.
  glDetachShader( _shaderID, vertID )
  glDetachShader( _shaderID, fragID )
  
  glDeleteShader( vertID )
  glDeleteShader( fragID )
end constructor

destructor GLShader()
  glDeleteProgram( _shaderID )
end destructor

operator GLShader.cast() as GLuint
  return( _shaderID )
end operator

property GLShader.ID() as GLuint
  return( _shaderID )
end property

sub GLShader.setInt( name_ as string, value as GLint )
  glUniform1i( glGetUniformLocation( _shaderID, name_ ), value )
end sub

sub GLShader.setFloat( name_ as string, value as GLfloat )
  glUniform1f( glGetUniformLocation( _shaderID, name_ ), value )
end sub

sub GLShader.setVec4( name_ as string, x as GLfloat, y as GLfloat, z as GLfloat, w as GLfloat = 1.0f )
  glUniform4f( glGetUniformLocation( _shaderID, name_ ), x, y, z, w )
end sub

sub GLShader.setMat4( name_ as string, M as Mat4, transposed as boolean = true )
  glUniformMatrix4fv( glGetUniformLocation( _shaderID, name_ ), 1, iif( transposed, GL_TRUE, GL_FALSE ), @M.a )
end sub

sub GLShader.use()
  glUseProgram( _shaderID )
end sub
