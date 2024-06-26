#ifndef __FB3D_MAT4__
#define __FB3D_MAT4__

#include once "vec4.bi"
/'
                     | a b c d |
  4x4 matrix type    | e f g h |
                     | i j k l |
                     | m n o p |
  
  9/30/2017: improved 4x4 matrix inverse calculation. With -gen gcc -O max
    (the settings I always use) it is more than 60% faster than the previous
    version. A byproduct of correcting the bug mentioned below.
  9/29/2017: fixed determinant calculation (it was erroneously computed)
    The funny thing was that this library is used in various applications,
    including my 3D engine and various tools. When I was implementing a
    feature, it kept doing weird things, and the bug was finally tracked to
    an erroneous calculation of the determinant. The determinant was
    correctly calculated in the 3x3  matrix code, but when I ported the code
    to use OpenGL for rendering, it  didn't worked as intended. Goes to show
    you that one is to be extra  careful with the math code, as it is the
    foundation of the entire game engine.
    
    the calculations were cross checked with the help of this online resource:
      
      https://www.mathsisfun.com/algebra/matrix-calculator.html
    
    which has a very neat matrix calculator for various dimensions.
'/  
type Mat4
  public:
    as single a, b, c, d
    as single e, f, g, h
    as single i, j, k, l
    as single m, n, o, p
    
    declare constructor( _
      sa as single = 1.0, sb as single = 0.0, sc as single = 0.0, sd as single = 0.0, _
      se as single = 0.0, sf as single = 1.0, sg as single = 0.0, sh as single = 0.0, _
      si as single = 0.0, sj as single = 0.0, sk as single = 1.0, sl as single = 0.0, _
      sm as single = 0.0, sn as single = 0.0, so as single = 0.0, sp as single = 1.0 )
    declare constructor( NM as Mat4 )
    declare operator let( RHS as Mat4 )
    declare operator cast() as string
    
    declare function determinant() as single
    declare sub transpose()
    declare function transpose( M as Mat4 ) as Mat4
    declare sub inverse()
    declare sub identity()
end type

constructor Mat4( _
      sa as single = 1.0, sb as single = 0.0, sc as single = 0.0, sd as single = 0.0, _
      se as single = 0.0, sf as single = 1.0, sg as single = 0.0, sh as single = 0.0, _
      si as single = 0.0, sj as single = 0.0, sk as single = 1.0, sl as single = 0.0, _
      sm as single = 0.0, sn as single = 0.0, so as single = 0.0, sp as single = 1.0 )
  
  '' Default constructor initializes the matrix to an identity, if no coefficients are specified.
  '' this is far more useful than initializing it to all zeros
  a = sa : b = sb : c = sc : d = sd
  e = se : f = sf : g = sg : h = sh
  i = si : j = sj : k = sk : l = sl
  m = sm : n = sn : o = so : p = sp
end constructor

constructor Mat4( RHS as Mat4 )
  '' Copy constructor
  a = RHS.a : b = RHS.b : c = RHS.c : d = RHS.d
  e = RHS.e : f = RHS.f : g = RHS.g : h = RHS.h
  i = RHS.i : j = RHS.j : k = RHS.k : l = RHS.l
  m = RHS.m : n = RHS.n : o = RHS.o : p = RHS.p
end constructor

operator Mat4.let( RHS as Mat4 )
  '' Assignment construction
  a = RHS.a : b = RHS.b : c = RHS.c : d = RHS.d
  e = RHS.e : f = RHS.f : g = RHS.g : h = RHS.h
  i = RHS.i : j = RHS.j : k = RHS.k : l = RHS.l
  m = RHS.m : n = RHS.n : o = RHS.o : p = RHS.p
end operator

operator Mat4.cast() as string
  '' The matrix in a human readable form (very useful for debugging purposes)
  return( _
    "| " & trim( str( a ) ) & " | " & trim( str( b ) ) & " | " & trim( str( c ) ) & " | " & trim( str( d ) ) & " |" & chr( 13 ) & chr( 10 ) & _
    "| " & trim( str( e ) ) & " | " & trim( str( f ) ) & " | " & trim( str( g ) ) & " | " & trim( str( h ) ) & " |" & chr( 13 ) & chr( 10 ) & _
    "| " & trim( str( i ) ) & " | " & trim( str( j ) ) & " | " & trim( str( k ) ) & " | " & trim( str( l ) ) & " |" & chr( 13 ) & chr( 10 ) & _
    "| " & trim( str( m ) ) & " | " & trim( str( n ) ) & " | " & trim( str( o ) ) & " | " & trim( str( p ) ) & " |" & chr( 13 ) & chr( 10 ) )
end operator

function Mat4.determinant() as single
  /'
    Computes the determinant of the matrix using Laplace cofactor expansion.
    
    The determinant of a 3x3 matrix is:
      a * ( e * i - f * h ) - b * ( d * i - f * g ) + c * ( d * h - e * g )
    
    and a 4x4 matrix determinant is given by:
      a *         b *         c *         d *
      | f g h |   | e g h |   | e f h |   | e f g |
      | j k l | - | i k l | + | i j l | - | i j k |
      | n o p |   | m o p |   | m n p |   | m n o |
      
      where the '|' means the determinant of the inner 3x3 matrices. Note that the
      cofactors are already factored in the calculation.
      
    The determinant is thus:
      + ( a * (  f * ( k * p - l * o ) - g * ( j * p - l * n ) + h * ( j * o - k * n ) ) )
      - ( b * ( e * ( k * p - l * o ) - g * ( i * p - l * m ) + h * ( i * o - k * m ) ) )
      +  ( c * ( e * ( j * p - l * n ) - f * ( i * p - l * m ) + h * ( i * n - j * m ) ) )
      - ( d * ( e * ( j * o - k * n ) - f * ( i * o - k * m ) + g * ( i * n - j * m ) ) )
    
  '/
  dim as single det = _
      ( a * (  f * ( k * p - l * o ) - g * ( j * p - l * n ) + h * ( j * o - k * n ) ) ) _
    - ( b * ( e * ( k * p - l * o ) - g * ( i * p - l * m ) + h * ( i * o - k * m ) ) ) _
    +  ( c * ( e * ( j * p - l * n ) - f * ( i * p - l * m ) + h * ( i * n - j * m ) ) ) _
    - ( d * ( e * ( j * o - k * n ) - f * ( i * o - k * m ) + g * ( i * n - j * m ) ) )
  /'
    This isn't matematically correct, just a programmer's dirty hack.
    If the determinant of a matrix is 0, it means it has no inverse. In the code for
    calculating the inverse, a division by the determinant is performed; and if it is 
    zero, a division by zero is performed on *every* element of the matrix, filling it
    with positive or negative infinity values and rendering it useless. A matrix 
    without inverse is the matrix  itself, so setting the determinant value to 1 
    does the trick.
  '/
  if det = 0 then det = 1.0
  
  return( det )
end function

sub Mat4.transpose()
  /'
    Transposes the matrix
    
      [ a b c d ]T    [ a e i m ]
      [ e f g h ]  =  [ b f j n ]
      [ i j k l ]     [ c g k o ]
      [ m n o p ]     [ d h l p ]
    
    Why have it, if it is not used by the matrix code itself? Well, there is a
    nice property of matrices, which has to do with rotations. If you can
    be sure that the matrix contains only rotations, transposing it is the
    same as taking its inverse, thus saving you *a lot* of computation.
    
    It's also useful to pass them to OpenGL, since the memory layout might be
    different. Passing the matrix transposed to OpenGL would put them in the
    correct layout expected by it.
  '/
  this = Mat4( a, e, i, m, b, f, j, n, c, g, k, o, d, h, l, p )
end sub

function transpose( M as Mat4 ) as Mat4
  return( Mat4( _
    M.a, M.e, M.i, M.m, _
    M.b, M.f, M.j, M.n, _
    M.c, M.g, M.k, M.o, _
    M.d, M.h, M.l, M.p ) )
end function

sub Mat4.inverse()
  /'
    Computes the inverse of a 4x4 matrix.
    
    This version is 60%+ faster and 400%+ uglier than the previous version.
    it was made so by computing the determinant inside the method and
    recycling as much calculation as possible
  '/
  '' List of 2x2 determinants
  dim as single _
    kplo = k * p - l * o, _
    jpln = j * p - l * n, _
    jokn = j * o - k * n, _
    iplm = i * p - l * m, _
    iokm = i * o - k * m, _
    injm = i * n - j * m, _
    gpho = g * p - h * o, _
    fphn = f * p - h * n, _
    fogn = f * o - g * n, _
    ephm = e * p - h * m, _
    eogm = e * o - g * m, _
    enfm = e * n - f * m, _
    glhk = g * l - h * k, _
    flhj = f * l - h * j, _
    fkgj = f * k - g * j, _
    elhi = e * l - h * i, _
    ekgi = e * k - g * i, _
    ejfi = e * j - f * i

  '' List of 3x3 determinants
  dim as single _
    d1kplo = f * kplo, _
    d1jpln = g * jpln, _
    d1jokn = h * jokn, _
    d2kplo = e * kplo, _
    d2iplm = g * iplm, _
    d2iokm = h * iokm, _
    d3jpln = e * jpln, _
    d3iplm = f * iplm, _
    d3injm = h * injm, _
    d4jokn = e * jokn, _
    d4iokm = f * iokm, _
    d4injm = g * injm, _
    d5kplo = b * kplo, _
    d5jpln = c * jpln, _
    d5jokn = d * jokn, _
    d6kplo = a * kplo, _
    d6iplm = c * iplm, _
    d6iokm = d * iokm, _
    d7jpln = a * jpln, _
    d7iplm = b * iplm, _
    d7injm = d * injm, _
    d8jokn = a * jokn, _
    d8iokm = b * iokm, _
    d8injm = c * injm, _
    d9gpho = b * gpho, _
    d9fphn = c * fphn, _
    d9fogn = d * fogn, _
    d10gpho = a * gpho, _
    d10ephm = c * ephm, _
    d10eogm = d * eogm, _
    d11fphn = a * fphn, _
    d11ephm = b * ephm, _
    d11enfm = d * enfm, _
    d12fogn = a * fogn, _
    d12eogm = b * eogm, _
    d12enfm = c * enfm, _
    d13glhk = b * glhk, _
    d13flhj = c * flhj, _
    d13fkgj = d * fkgj, _
    d14glhk = a * glhk, _
    d14elhi = c * elhi, _
    d14ekgi = d * ekgi, _
    d15flhj = a * flhj, _
    d15elhi = b * elhi, _
    d15ejfi = d * ejfi, _
    d16fkgj = a * fkgj, _
    d16ekgi = b * ekgi, _
    d16ejfi = c * ejfi
  
  '' 4x4 determinant (inversed)
  dim as single det = _
      ( a * ( d1kplo - d1jpln + d1jokn ) _
    - ( b * ( d2kplo - d2iplm + d2iokm ) ) _
    + ( c * ( d3jpln - d3iplm + d3injm ) ) _
    - ( d * ( d4jokn - d4iokm + d4injm ) ) )
  
  '' If the determinant is 0, the matrix has no inverse
  if det = 0 then exit sub
  
  '' Multiplying with the reciprocal is slightly faster than dividing
  dim as single invDet = 1.0 / det
  
  '' Minors
  dim as single _
    Ma = d1kplo - d1jpln + d1jokn, _
    Mb = d2kplo - d2iplm + d2iokm, _
    Mc = d3jpln - d3iplm + d3injm, _
    Md = d4jokn - d4iokm + d4injm, _
    Me = d5kplo - d5jpln + d5jokn, _
    Mf = d6kplo - d6iplm + d6iokm, _
    Mg = d7jpln - d7iplm + d7injm, _
    Mh = d8jokn - d8iokm + d8injm, _
    Mi = d9gpho - d9fphn + d9fogn, _
    Mj = d10gpho - d10ephm + d10eogm, _
    Mk = d11fphn - d11ephm + d11enfm, _
    Ml = d12fogn - d12eogm + d12enfm, _
    Mm = d13glhk - d13flhj + d13fkgj, _
    Mn = d14glhk - d14elhi + d14ekgi, _
    Mo = d15flhj - d15elhi + d15ejfi, _
    Mp = d16fkgj - d16ekgi + d16ejfi
  
  /'
    Adjugate (the adjugate is the transpose of the cofactored matrix of minors)      
     
     Ma  -Me   Mi  -Mm
    -Mb   Mf  -Mj   Mn
     Mc  -Mg   Mk  -Mo
    -Md   Mh  -Ml   Mp
  '/
  this = Mat4( _
     Ma * invDet, -Me * invDet,  Mi * invDet, -Mm * invDet, _
    -Mb * invDet,  Mf * invDet, -Mj * invDet,  Mn * invDet, _
     Mc * invDet, -Mg * invDet,  Mk * invDet, -Mo * invDet, _
    -Md * invDet,  Mh * invDet, -Ml * invDet,  Mp * invDet )
end sub

sub Mat4.identity()
  '' Makes the matrix an identity matrix
  a = 1.0 : b = 0.0 : c = 0.0 : d = 0.0
  e = 0.0 : f = 1.0 : g = 0.0 : h = 0.0
  i = 0.0 : j = 0.0 : k = 1.0 : l = 0.0
  m = 0.0 : n = 0.0 : o = 0.0 : p = 1.0
end sub

operator *( A as Mat4, B as Mat4 ) as Mat4
  /'
    Multiply two 4x4 matrices.
    
    Remember that matrix multiplication is not commutative!
      A * B != B * A
  '/
  return( Mat4( _
    A.a * B.a + A.b * B.e + A.c * B.i + A.d * B.m, _
    A.a * B.b + A.b * B.f + A.c * B.j + A.d * B.n, _
    A.a * B.c + A.b * B.g + A.c * B.k + A.d * B.o, _
    A.a * B.d + A.b * B.h + A.c * B.l + A.d * B.p, _
    A.e * B.a + A.f * B.e + A.g * B.i + A.h * B.m, _
    A.e * B.b + A.f * B.f + A.g * B.j + A.h * B.n, _
    A.e * B.c + A.f * B.g + A.g * B.k + A.h * B.o, _
    A.e * B.d + A.f * B.h + A.g * B.l + A.h * B.p, _
    A.i * B.a + A.j * B.e + A.k * B.i + A.l * B.m, _
    A.i * B.b + A.j * B.f + A.k * B.j + A.l * B.n, _
    A.i * B.c + A.j * B.g + A.k * B.k + A.l * B.o, _
    A.i * B.d + A.j * B.h + A.k * B.l + A.l * B.p, _
    A.m * B.a + A.n * B.e + A.o * B.i + A.p * B.m, _
    A.m * B.b + A.n * B.f + A.o * B.j + A.p * B.n, _
    A.m * B.c + A.n * B.g + A.o * B.k + A.p * B.o, _
    A.m * B.d + A.n * B.h + A.o * B.l + A.p * B.p ) )
end operator

operator +( A as Mat4, B as Mat4 ) as Mat4
  '' Adds two 4x4 matrices
  return( Mat4( _
    A.a + B.a, A.b + B.b, A.c + B.c, A.d + B.d, _
    A.e + B.e, A.f + B.f, A.g + B.g, A.h + B.h, _
    A.i + B.i, A.j + B.j, A.k + B.k, A.l + B.l, _
    A.m + B.m, A.n + B.n, A.o + B.o, A.p + B.p ) )
end operator

operator -( A as Mat4, B as Mat4 ) as Mat4
  '' Substracts two 4x4 matrices
  return( Mat4( _
    A.a - B.a, A.b - B.b, A.c - B.c, A.d - B.d, _
    A.e - B.e, A.f - B.f, A.g - B.g, A.h - B.h, _
    A.i - B.i, A.j - B.j, A.k - B.k, A.l - B.l, _
    A.m - B.m, A.n - B.n, A.o - B.o, A.p - B.p ) )
end operator

operator -( A as Mat4 ) as Mat4
  '' Negates the matrix
  return( Mat4( _
    -A.a, -A.b, -A.c, -A.d, _
    -A.e, -A.f, -A.g, -A.h, _
    -A.i, -A.j, -A.k, -A.l, _
    -A.m, -A.n, -A.o, -A.p ) )
end operator

operator *( A as Mat4, s as single ) as Mat4
  '' Scalar multiplication
  return( Mat4( _
    A.a * s, A.b * s, A.c * s, A.d * s, _
    A.e * s, A.f * s, A.g * s, A.h * s, _
    A.i * s, A.j * s, A.k * s, A.l * s, _
    A.m * s, A.n * s, A.o * s, A.p * s ) )
end operator

operator *( s as single, A as Mat4 ) as Mat4
  '' Scalar multiplication
  return( Mat4( _
    A.a * s, A.b * s, A.c * s, A.d * s, _
    A.e * s, A.f * s, A.g * s, A.h * s, _
    A.i * s, A.j * s, A.k * s, A.l * s, _
    A.m * s, A.n * s, A.o * s, A.p * s ) )
end operator

'' Scalar division
operator /( A as Mat4, s as single ) as Mat4
  return( Mat4( _
    A.a / s, A.b / s, A.c / s, A.d / s, _
    A.e / s, A.f / s, A.g / s, A.h / s, _
    A.i / s, A.j / s, A.k / s, A.l / s, _
    A.m / s, A.n / s, A.o / s, A.p / s ) )
end operator

operator *( v as Vec4, A as Mat4 ) as Vec4
  /'
    Multiply a vector with a row matrix, resulting in a row vector (like Direct3D)
      A row vector looks like this:
      
      | x y z w |
      
      and is the format that Direct3D uses. What this means, code-wise, is that you
      have to pre-multiply the vectors with the matrices, and some other stuff, like
      transposing the matrices if you are using column vectors (as this library does)
  '/
  return( Vec4( _ 
    A.a * v.x + A.e * v.y + A.i * v.z + A.m * v.w, _
    A.b * v.x + A.f * v.y + A.j * v.z + A.n * v.w, _
    A.c * v.x + A.g * v.y + A.k * v.z + A.o * v.w, _
    A.d * v.x + A.h * v.y + A.l * v.z + A.p * v.w ) )
end operator

operator *( A as Mat4, v as Vec4 ) as Vec4
  /'
    Multiply a vector with a column matrix, resulting in a column vector (like OpenGL)
      A column vector looks like this:
      
      | x |
      | y |
      | z |
      | w |
      
      and is the format favored by OpenGL. In this library, column vectors are used, for
      compatibility.
  '/
  return( Vec4( _
    A.a * v.X + A.b * v.Y + A.c * v.Z + A.d * v.W, _
    A.e * v.X + A.f * v.Y + A.g * v.Z + A.h * v.W, _
    A.i * v.X + A.j * v.Y + A.k * v.Z + A.l * v.W, _
    A.m * v.X + A.n * v.Y + A.o * v.Z + A.p * v.W ) )
end operator

'' Utility functions
function inverse( M as Mat4 ) as Mat4
  '' Returns the inverse of the provided matrix
  dim as Mat4 I = Mat4( M )
  
  I.inverse()
  
  return( I )
end function

namespace fbm
  '' Constructs an identity matrix
  function identity() as Mat4
    return( Mat4( _
      1.0, 0.0, 0.0, 0.0, _
      0.0, 1.0, 0.0, 0.0, _
      0.0, 0.0, 1.0, 0.0, _
      0.0, 0.0, 0.0, 1.0 ) )
  end function
  
  '' Constructs a translation matrix
  function translation overload( t as Vec4 ) as Mat4
    return Mat4( _
      1.0, 0.0, 0.0, t.x, _
      0.0, 1.0, 0.0, t.y, _
      0.0, 0.0, 1.0, t.z, _
      0.0, 0.0, 0.0, 1.0 ) 
  end function
  
  '' Constructs a translation matrix
  function translation( tx as single, ty as single, tz as single ) as Mat4
    return Mat4( _
      1.0, 0.0, 0.0, tx, _
      0.0, 1.0, 0.0, ty, _
      0.0, 0.0, 1.0, tz, _
      0.0, 0.0, 0.0, 1.0 ) 
  end function
  
  '' Constructs a rotation matrix
  function rotation( a as double, rotAxis as Vec4 ) as Mat4
    dim as single c = cos( a ), s = sin( a ), ic = 1.0f - cos( a )
    dim as Vec4 R = normalize( rotAxis )
    
    return( Mat4( _
      c + R.x * R.x * ic,       R.x * R.y * ic - R.z * s, R.x * R.z * ic + R.y * s, 0.0f, _
      R.y * R.x * ic + R.z * s,       c + R.y * R.y * ic, R.y * R.z * ic - R.x * s, 0.0f, _
      R.z * R.x * ic - R.y * s, R.z * R.y * ic + R.x * s,       c + R.z * R.z * ic, 0.0f, _
                          0.0f,                     0.0f,                     0.0f, 1.0f ) ) 
  end function
  
  '' Constructs a scaling matrix
  function scaling( sx as single, sy as single, sz as single ) as Mat4
    return( Mat4( _
       sx, 0.0, 0.0, 0.0, _
      0.0,  sy, 0.0, 0.0, _
      0.0, 0.0,  sz, 0.0, _
      0.0, 0.0, 0.0, 1.0 ) )
  end function
  
  '' Constructs a projection matrix
  function projection overload( fov as single, nearClip as single, farClip as single ) as Mat4
    dim as single _
      fovX = radians( fov ), fovY = radians( fov ), _
      fovTanX = 1 / tan( fovX / 2 ), fovTanY = 1 / tan( fovY / 2 )
    
    dim as Mat4 PM
    
    with PM
      .a = fovTanX : .b = 0.0 : .c = 0.0 : .d = 0.0
      .e = 0.0 : .f = fovTanY : .g = 0.0 : .h = 0.0
      .i = 0.0 : .j = 0.0 : .k = -( ( farClip + nearClip ) / ( farClip - nearClip ) ) : .l = -( ( 2 * ( farClip * nearClip ) ) / ( farClip - nearClip ) )
      .m = 0.0 : .n = 0.0 : .o = -1.0 : .p = 0.0
    end with
    
    return( PM )
  end function
  
  '' Constructs a projection matrix
  function projection( fov as single, aspect as single, near as single, far as single ) as Mat4
    dim as single _
      tangent = tan( radians( fov ) / 2 ), _
      halfHeight = near * tangent, _
      halfWidth = halfHeight * aspect, _
      l =  halfWidth, _
      r = -halfWidth, _
      t =  halfHeight, _
      b = -halfHeight
    
    return( Mat4( _
      ( 2 * near ) / ( r - l ), 0, ( r + l ) / ( r - l ), 0, _
      0, ( 2 * near ) / ( t - b ), ( t + b ) / ( t - b ), 0, _
      0, 0, -( far + near ) / ( far - near ), ( -2 * far * near ) / ( far - near ), _
      0, 0, -1, 0 ) )
  end function
  
  '' Constructs a lookAt transform matrix using position, target and up vectors
  function lookAt( p as Vec4, target as Vec4, up as Vec4 ) as Mat4
    var zaxis = normalize( p - target )
    var xaxis = normalize( cross( normalize( up ), zaxis ) )
    var yaxis = cross( zaxis, xaxis )
    
    return( Mat4( _
      xaxis.x, xaxis.y, xaxis.z, 0.0f, _
      yaxis.x, yaxis.y, yaxis.z, 0.0f, _
      zaxis.x, zaxis.y, zaxis.z, 0.0f, _
         0.0f,    0.0f,    0.0f, 1.0f ) * translation( -p.x, -p.y, -p.z ) )
  end function
end namespace

#endif
