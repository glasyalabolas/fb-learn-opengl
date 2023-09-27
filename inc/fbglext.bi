/'
  This header file helps set up the OpenGL extensions.
  Note that these bindings must be used AFTER an OpenGL video mode has been set.
'/
#include once "GL/gl.bi"
#include once "GL/glext.bi"

'' Define null if it is not defined
#ifndef FBGL_NULL
  #define FBGL_NULL 0
#endif

'' Some useful helper functions.
'' Prints messages to the console for debugging purposes
sub cPrint( text as string = "" )
  dim as integer fn = freeFile()
  
  open cons for output as fn
    ? #fn, text
  close( fn )
end sub

' Exit the program with an error message
sub errorExit( msg as string )
  if( screenPtr() <> 0 ) then
    screen( 0 )
  end if
  
  dim as integer w, h
  screenInfo( w, h )
  
  w *= 0.75
  h *= 0.75
  
  screenRes( w, h )
  width w / 8, h / 16
  
  ? "GL Error: " & msg
  
  sleep()
  
  end( 1 )
end sub

'' Set up the OpenGL extensions
#macro glBindProc( n )
  #if not defined( n )
    dim shared as PFN##n##PROC n
    
    n = screenGLProc( #n )
    
    if( n = 0 ) then
      errorExit( "glBindProc(): failed to bind " & #n )
    end if
  #endif
#endmacro

'glBindProc( glGenVertexArrays )
'glBindProc( glBindVertexArray )
'glBindProc( glGenBuffers )
'glBindProc( glBindBuffer )
'glBindProc( glBufferData )
'glBindProc( glEnableVertexAttribArray )
'glBindProc( glDisableVertexAttribArray )
'glBindProc( glVertexAttribPointer )
'glBindProc( glCreateShader )
'glBindProc( glShaderSource )
'glBindProc( glCompileShader )
'glBindProc( glGetShaderiv )
'glBindProc( glGetShaderInfoLog )
'glBindProc( glDeleteShader )
'glBindProc( glCreateProgram )
'glBindProc( glAttachShader )
'glBindProc( glLinkProgram )
'glBindProc( glDetachShader )
'glBindProc( glGetProgramiv )
'glBindProc( glGetProgramInfoLog )
'glBindProc( glUseProgram )
'glBindProc( glDeleteProgram )
'glBindProc( glDeleteBuffers )
'glBindProc( glDeleteVertexArrays )
'glBindProc( glGetUniformLocation )
'glBindProc( glUniform1f )
'glBindProc( glUniform1i )
'glBindProc( glUniform2f )
'glBindProc( glUniform2fv )
'glBindProc( glUniform3fv )
'glBindProc( glActiveTexture )
'glBindProc( glUniformMatrix3fv )
