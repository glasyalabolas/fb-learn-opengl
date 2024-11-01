#ifndef __FB3D_VEC3__
#define __FB3D_VEC3__  

/'
  3D vector
  
  | x |
  | y |
  | z |
'/
type Vec3
  public:
    declare constructor()
    declare constructor( as single = 0.0, as single = 0.0, as single = 0.0 )
    declare constructor( rhs as Vec3 )
    declare operator let( rhs as Vec3 )
    
    declare operator cast() as string
    
    declare function length() as single
    declare function setLength( as single ) byref as Vec3
    declare function ofLength( as single ) as Vec3
    declare function squaredLength() as single
    declare function normalize() byref as Vec3
    declare function normalized() as Vec3
    declare function homogenize() byref as Vec3
    declare function homogeneous() as Vec3
    declare function cross( v as Vec3 ) as Vec3
    declare function dot( v as Vec3 ) as single
    declare function distance( v as Vec3 ) as single
    declare function squaredDistance( as Vec3 ) as single
    
    as single x, y, z
end type

constructor Vec3()
  x = 0.0 : y = 0.0 : z = 0.0
end constructor

constructor Vec3( nx as single = 0.0, ny as single = 0.0, nz as single = 0.0 )
  x = nx : y = ny : z = nz
end constructor

constructor Vec3( rhs as Vec3 )
  x = rhs.x : y = rhs.y : z = rhs.z
end constructor

operator Vec3.let( rhs as Vec3 )
  x = rhs.x : y = rhs.y : z = rhs.z
end operator

'' Human readable string representation (useful for debugging)
operator Vec3.cast() as string
  return( _
    "| " & trim( str( x ) ) & " |" & chr( 13 ) & chr( 10 ) & _
    "| " & trim( str( y ) ) & " |" & chr( 13 ) & chr( 10 ) & _
    "| " & trim( str( z ) ) & " |" & chr( 13 ) & chr( 10 ) )
end operator

operator = ( lhs as Vec3, rhs as Vec3 ) as integer
  return( lhs.x = rhs.x andAlso lhs.y = rhs.y andAlso lhs.z = rhs.z )
end operator

operator <> ( lhs as Vec3, rhs as Vec3 ) as integer
  return( lhs.x <> rhs.x orElse lhs.y <> rhs.y orElse lhs.z <> rhs.z )
end operator

operator - ( v as Vec3, w as Vec3 ) as Vec3
  return( Vec3( v.x - w.x, v.y - w.y, v.z - w.z ) )
end operator

'' Unary minus
operator - ( v as Vec3 ) as Vec3
  return( Vec3( -v.x, -v.y, -v.z ) )
end operator

operator + ( v as Vec3, w as Vec3 ) as Vec3
  return( Vec3( v.x + w.x, v.y + w.y, v.z + w.z ) )
end operator

operator * ( v as Vec3, w as Vec3 ) as Vec3
  return( Vec3( v.x * w.x, v.y * w.y, v.z * w.z ) )
end operator

/'
  Multiplication with a scalar.
  
  Note that this is not a cross product, but a
  multiplication of their individual members by a scalar.
  Vectors do not define multiplications per se, they define the
  dot product and the cross product. To avoid confusion (and
  also correctness), the multiplication operator is overloaded
  to a scaling of the vector by a scalar quantity.
'/
operator * ( v as Vec3, s as single ) as Vec3
  return( Vec3( v.x * s, v.y * s, v.z * s ) )
end operator

operator * ( s as single, v as Vec3 ) as Vec3
  return( Vec3( v.x * s, v.y * s, v.z * s ) )
end operator

'' Division by a scalar. See note above on multiplying a vector
operator / ( v as Vec3, s as single ) as Vec3
  return( Vec3( v.x / s, v.y / s, v.z / s ) )
end operator

'' Division by another vector
operator / ( v as Vec3, w as Vec3 ) as Vec3
  return( Vec3( v.x / w.x, v.y / w.y, v.z / w.z ) )
end operator

operator abs( v as Vec3 ) as Vec3
  return( Vec3( abs( v.x ), abs( v.y ), abs( v.z ) ) )
end operator

/'
  Returns the squared length of this vector
  
  Useful when you just want to compare which one is bigger,
  as this avoids having to compute a square root.
'/
function Vec3.squaredLength() as single
  return( x ^ 2 + y ^ 2 + z ^ 2 )
end function

'' Returns the length of this vector
function Vec3.length() as single
  return( sqr( x ^ 2 + y ^ 2 + z ^ 2 ) )
end function

function Vec3.setLength( l as single ) byref as Vec3
  dim as single nl = l / length()
  
  this *= nl
  
  return( this )
end function

function Vec3.ofLength( l as single ) as Vec3
  dim as single nl = l / length()
  return( this * nl )
end function

/'
  Normalizes the vector.
  Note that the homogeneous coordinate (w) is not touched here.
'/
function Vec3.normalize() byref as Vec3
  dim as single l = 1 / length()
  
  if( l > 0.0 ) then
    x *= l : y *= l : z *= l
  end if
  
  return( this )
end function

function Vec3.normalized() as Vec3
  dim as single l = 1 / sqr( x ^ 2 + y ^ 2 + z ^ 2 )
  
  if( l > 0.0 ) then
    return( Vec3( x, y, z ) * l )
  else
    return( Vec3( x, y, z ) )
  end if 
end function

function Vec3.homogenize() byref as Vec3
  dim as single rz = 1 / z
  x *= rz: y *= rz : z *= rz
  
  return( this )
end function

function Vec3.homogeneous() as Vec3
  dim as single rz = 1 / z
  return( Vec3( x * rz, y * rz, z * rz ) )
end function

/'
  Returns the cross product (aka vectorial product) of this
  vector and another vector v.
'/
function Vec3.cross( v as Vec3 ) as Vec3
  return( Vec3( v.y * z - v.z * y, v.z * x - v.x * z, v.x * y - v.y * x ) )
end function

/'
  Returns the dot product (aka scalar product) of this
  vector and vector v.
'/
function Vec3.dot( v as Vec3 ) as single
  return( v.x * x + v.y * y + v.z * z )
end function

/'
  Gets the distance of this vector with vector v
  To calculate the distance, substract them and
  calculate the length of the resultant vector.
'/
function Vec3.distance( v as Vec3 ) as single
  return( sqr( ( v.x - x ) ^ 2 + ( v.y - y ) ^ 2 + ( v.z - z ) ^ 2 ) )
end function

/'
  Gets the squared distance of this vector with
  vector v. Useful when you need to just compare
  distances.
'/
function Vec3.squaredDistance( v as Vec3 ) as single
  return( ( v.x - x ) ^ 2 + ( v.y - y ) ^ 2 + ( v.z - z ) ^ 2 )
end function

/'
  Rotate vector v around arbitrary axis for angle radians
  
  It can only rotate around an axis through our object, to rotate
  around another axis: first translate the object to the axis, then
  use this function, then translate back in the new direction.
'/
function rotateAroundAxis overload( v as Vec3, anAxis as Vec3, anAngle as single ) as Vec3
  if( _
    ( v.x = 0.0 ) andAlso _
    ( v.y = 0.0 ) andAlso _
    ( v.z = 0.0 ) ) then
    
    return Vec3( 0.0, 0.0, 0.0 )
  end if
  
  var nAxis = anAxis.normalized()
  
  '' Calculate parameters of the rotation matrix
  dim as single c = cos( anAngle ), s = sin( anAngle ), t = 1.0 - c
  
  '' Multiply w with rotation matrix
  dim as Vec3 w
  
  w.x = ( t * nAxis.x * nAxis.x + c ) * v.x _
      + ( t * nAxis.x * nAxis.y + s * nAxis.z ) * v.y _
      + ( t * nAxis.x * nAxis.z - s * nAxis.y ) * v.z
  w.y = ( t * nAxis.x * nAxis.y - s * nAxis.z ) * v.x _
      + ( t * nAxis.y * nAxis.y + c ) * v.y _
      + ( t * nAxis.y * nAxis.z + s * nAxis.x ) * v.z
  w.z = ( t * nAxis.x * nAxis.z + s * nAxis.y ) * v.x _
      + ( t * nAxis.y * nAxis.z - s * nAxis.x ) * v.y _
      + ( t * nAxis.z * nAxis.z + c ) * v.z
  
  /'
    The vector has to retain its length, so it's normalized and
    multiplied with the original length.
  '/
  w.normalize()
  w = w * v.length()
  
  return( w )
end function

#endif
