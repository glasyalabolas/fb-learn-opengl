#include once "inc/fbgl-img.bi"

screenRes( 800, 600, 32 )

var img = loadBMP( "res/wooden-container.bmp" )

put( 0, 0 ), img, pset

sleep()

imageDestroy( img )
