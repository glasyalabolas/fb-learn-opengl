#include once "vec4.bi"
#include once "mat4.bi"

type Camera
  declare constructor()
  declare constructor( as vec4, as single = 0.1f, as single = 100.0f )
  
  declare sub move( as vec4 )
  declare sub rotate( as vec4, as single )
  declare sub lookAt( as vec4 )
  
  declare function getViewMatrix() as mat4
  
  as vec4 pos              '' Position in world space
  as vec4 X, Y, Z          '' Three axes of the coordinate system for the camera
  as single near, far, fov '' Near and far plane distance, field of view
end type

constructor Camera()
  constructor( vec4( 0.0f, 0.0f, 0.0f ), 0.1f, 100.0f )
end constructor

constructor Camera( p as vec4, n as single = 0.1f, f as single = 100.0f )
  pos = p
  near = n
  far = f
  fov = 45.0f
  
  Z = vec4( 0.0f, 0.0f, -1.0f )
  Y = vec4( 0.0f, 1.0f, 0.0f )
  X = normalize( cross( Z, Y ) )
end constructor

sub Camera.move( offset as vec4 )
  pos += offset
end sub

sub Camera.rotate( axis as vec4, angle as single )
  X = rotateAroundAxis( X, axis, angle )
  Y = rotateAroundAxis( Y, axis, angle )
  Z = rotateAroundAxis( Z, axis, angle )
end sub

sub Camera.lookAt( target as vec4 )
  '' Compute the forward vector
  var forward = vec4( normalize( pos - target ) )
  
  /'
    Compute temporal up vector based on the forward vector
    
    Watch out when look up/down at 90 degree
    for example, forward vector is on the Y axis
  '/
  dim as vec4 up = Y
  
  if( abs( forward.x ) < C_EPSILON ) andAlso ( abs( forward.z ) < C_EPSILON ) then
    if( forward.y > 0 ) then
      '' Forward vector is pointing +Y axis
      up = vec4( 0.0, 0.0, -1.0 )
    else
      '' Forward vector is pointing -Y axis
      up = vec4( 0.0, 0.0, 1.0 )
    end if
  else
    '' In general, up vector is straight up
    up = vec4( 0.0, 1.0, 0.0 )
  end if
  
  '' Compute the left vector
  dim as vec4 left_ = vec4( normalize( cross( up, forward ) ) )
  
  '' Re-calculate the orthonormal up vector
  up = normalize( cross( forward, left_ ) )
  
  Z = -forward
  X = left_
  Y = up
end sub

function Camera.getViewMatrix() as mat4
  return( fbm.lookAt( pos, pos + Z, Y ) )
end function
