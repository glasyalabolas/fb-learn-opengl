#include once "fbgfx.bi"
#include once "file.bi"

#ifndef loadBMP
  function loadBMP( path as const string ) as Fb.Image ptr
    #define __BM_WINDOWS__ &h4D42
    
    type __BITMAPFILEHEADER__ field = 1
      as ushort id
      as ulong size
      as ubyte reserved( 0 to 3 )
      as ulong offset
    end type
    
    type __BITMAPINFOHEADER__ field = 1
      as ulong size
      as long width
      as long height
      as ushort planes
      as ushort bpp
      as ulong compression_method
      as ulong image_size
      as ulong h_res
      as ulong v_res
      as ulong color_palette_num
      as ulong colors_used
    end type
    
    dim as any ptr img = 0
    
    if( fileExists( path ) ) then
      dim as __BITMAPFILEHEADER__ header 
      dim as __BITMAPINFOHEADER__ info
      
      dim as long f = freeFile()
      
      open path for binary as f
        get #f, , header
        get #f, sizeof( header ) + 1, info
      close( f )
      
      '' Check if the file is indeed a Windows bitmap
      if( header.id = __BM_WINDOWS__ ) then
        img = imageCreate( info.width, abs( info.height ) )
        bload( path, img )
      end if
    end if
    
    return( img )
  end function
#endif
