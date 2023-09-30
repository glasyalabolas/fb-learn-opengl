#include once "vec4.bi"
#include once "mat4.bi"

type Camera
  declare constructor()
  declare constructor( as Vec4, as single = 0.1f, as single = 100.0f )
  
  declare sub move( as Vec4 )
  declare sub rotate( as Vec4, as single )
  declare sub lookAt( as Vec4 )
  
  declare function getViewMatrix() as Mat4
  
  as Vec4 pos              '' Position in world space
  as Vec4 X, Y, Z          '' Three axes of the coordinate system for the camera
  as single near, far, fov '' Near and far plane distance, field of view
end type

constructor Camera()
  constructor( Vec4( 0.0f, 0.0f, 0.0f ), 0.1f, 100.0f )
end constructor

constructor Camera( p as Vec4, n as single = 0.1f, f as single = 100.0f )
  pos = p
  near = n
  far = f
  fov = 45.0f
  
  Z = Vec4( 0.0f, 0.0f, -1.0f )
  Y = Vec4( 0.0f, 1.0f, 0.0f )
  X = normalize( cross( Z, Y ) )
end constructor

sub Camera.move( offset as Vec4 )
  pos += offset
end sub

sub Camera.rotate( axis as Vec4, angle as single )
  X = rotateAroundAxis( X, axis, angle )
  Y = rotateAroundAxis( Y, axis, angle )
  Z = rotateAroundAxis( Z, axis, angle )
end sub

sub Camera.lookAt( target as Vec4 )
  '' Compute the forward vector
  var forward = Vec4( normalize( pos - target ) )
  
  /'
    Compute temporal up vector based on the forward vector
    
    Watch out when look up/down at 90 degree
    for example, forward vector is on the Y axis
  '/
  dim as Vec4 up = Y
  
  if( abs( forward.x ) < C_EPSILON ) andAlso ( abs( forward.z ) < C_EPSILON ) then
    if( forward.y > 0 ) then
      '' Forward vector is pointing +Y axis
      up = Vec4( 0.0, 0.0, -1.0 )
    else
      '' Forward vector is pointing -Y axis
      up = Vec4( 0.0, 0.0, 1.0 )
    end if
  else
    '' In general, up vector is straight up
    up = Vec4( 0.0, 1.0, 0.0 )
  end if
  
  '' Compute the left vector
  dim as Vec4 left_ = Vec4( normalize( cross( up, forward ) ) )
  
  '' Re-calculate the orthonormal up vector
  up = normalize( cross( forward, left_ ) )
  
  Z = -forward
  X = left_
  Y = up
end sub

function Camera.getViewMatrix() as Mat4
  return( fbm.lookAt( pos, pos + Z, Y ) )
end function
