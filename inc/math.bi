#ifndef __FB3D_MATH__
#define __FB3D_MATH__

'' Some convenience macros
#ifndef max
  #define max( a, b )        iif( ( a ) > ( b ), a, b )
#endif

#ifndef min
  #define min( a, b )        iif( ( a ) < ( b ), a, b )
#endif

#ifndef clamp
  #define clamp( mn, mx, v ) iif( ( v ) < ( mn ), mn, iif( ( v ) > ( mx ), mx, v ) )
#endif

#ifndef wrap
  #define wrap( wrapValue, v ) ( ( ( v ) + ( wrapValue ) ) mod ( wrapValue ) )
#endif

#ifndef fwrap
  #define fwrap( wrapValue, v ) ( ( fmod( ( v ) + ( wrapValue ), wrapValue ) )
#endif

'' Portable floating-point mod function
#ifndef fmod
  #define fmod( numer, denom ) ( ( numer ) - int( numer / denom ) * denom )
#endif

'' Useful constants
const as single C_PI = 4 * atn( 1 )
const as single C_TWOPI = 2 * C_PI
const as single C_HALFPI = C_PI / 2

const as single C_DEGTORAD = C_PI / 180
const as single C_RADTODEG = 180 / C_PI
const as single C_EPSILON = 0.00000001

'' Used to express angles in another unit
#define radians( ang ) ( ang * C_DEGTORAD )
#define degrees( ang ) ( ang * C_RADTODEG )

'' Functions to return a delimited random value (uses FB implementation which
public function rng overload( mn as integer, mx as integer ) as integer
  return int( rnd() * ( mx + 1 - mn ) + mn )
end function

public function rng( mn as single, mx as single ) as single
  return rnd() * ( mx - mn ) + mn
end function

public function rng( mn as double, mx as double ) as double
  return rnd() * ( mx - mn ) + mn
end function  

'' Port of the famed 'Carmack's Reverse'
'' Computes the inverse square root of a number ( 1 / sqr( number ) )
function q_rsqrt( number as single ) as single
  dim as long i
  dim as single x2, y
  dim as const single threehalfs = 1.5
  
  x2 = number * 0.5
  y = number
  i = *cast( long ptr, @y )
  i = &h5F375A86 - ( i shr 1 )
  y = *cast( single ptr, @i )
  y = y * ( threehalfs - ( x2 * y * y ) )
  
  return( y )
end function

#endif
