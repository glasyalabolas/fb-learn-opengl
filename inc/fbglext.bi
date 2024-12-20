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
sub debug( text as string = "" )
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
  
  debug( "GL Error: " & msg )
  
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
