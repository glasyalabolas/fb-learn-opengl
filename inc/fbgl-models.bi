#define _R( c ) ( culng( c ) shr 16 and 255 )
#define _G( c ) ( culng( c ) shr  8 and 255 )
#define _B( c ) ( culng( c )        and 255 )
#define _A( c ) ( culng( c ) shr 24         )

type Mesh
  declare constructor()
  declare constructor( as GLuint, as GLuint )
  declare destructor()
  
  declare operator cast() as GLuint
  declare sub dispose()
  
  as GLuint _VAO, _VBO
end type

constructor Mesh() : end constructor

constructor Mesh( VAO as GLuint, VBO as GLuint )
  _VAO = VAO : _VBO = VBO
end constructor

destructor Mesh()

end destructor

operator Mesh.cast() as GLuint
  return( _VAO )
end operator

sub Mesh.dispose()
  glDeleteVertexArrays( 1, @_VAO )
  glDeleteBuffers( 1, @_VBO )
end sub

function cube() as Mesh
  dim as GLfloat vertices( ... ) = { _
  _ '' Positions          Texture coords
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, _
     0.5f, -0.5f, -0.5f,  1.0f, 0.0f, _
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f, _
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f, _
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f, _
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, _
    _
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, _
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f, _
     0.5f,  0.5f,  0.5f,  1.0f, 1.0f, _
     0.5f,  0.5f,  0.5f,  1.0f, 1.0f, _
    -0.5f,  0.5f,  0.5f,  0.0f, 1.0f, _
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, _
    _
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
    -0.5f,  0.5f, -0.5f,  1.0f, 1.0f, _
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, _
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
    _
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f, _
     0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
     0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
     0.5f, -0.5f,  0.5f,  0.0f, 0.0f, _
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
    _
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
     0.5f, -0.5f, -0.5f,  1.0f, 1.0f, _
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f, _
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f, _
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, _
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, _
    _
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f, _
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f, _
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f, _
    -0.5f,  0.5f,  0.5f,  0.0f, 0.0f, _
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f _
  }
  
  dim as GLuint VAO, VBO
  
  glGenVertexArrays( 1, @VAO )
  glGenBuffers( 1, @VBO )
  
  glBindVertexArray( VAO )
  glBindBuffer( GL_ARRAY_BUFFER, VBO )
  
  glBufferData( GL_ARRAY_BUFFER, ARRAY_ELEMENTS( vertices ) * sizeof( GLfloat ), @vertices( 0 ), GL_STATIC_DRAW )
  
  '' Position
  glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof( GLfloat ), 0 )
  glEnableVertexAttribArray( 0 )
  
  '' Texture coordinates
  glVertexAttribPointer( 1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof( GLfloat ), cast( any ptr, ( 3 * sizeof( GLfloat ) ) ) )
  glEnableVertexAttribArray( 1 )
  
  glBindVertexArray( 0 )
  
  return( Mesh( VAO, VBO ) )
end function

function lightCube() as Mesh
  dim as GLfloat vertices( ... ) = { _
  _ '' Positions
    -0.5f, -0.5f, -0.5f, _
     0.5f, -0.5f, -0.5f, _
     0.5f,  0.5f, -0.5f, _
     0.5f,  0.5f, -0.5f, _
    -0.5f,  0.5f, -0.5f, _
    -0.5f, -0.5f, -0.5f, _
    _
    -0.5f, -0.5f,  0.5f, _
     0.5f, -0.5f,  0.5f, _
     0.5f,  0.5f,  0.5f, _
     0.5f,  0.5f,  0.5f, _
    -0.5f,  0.5f,  0.5f, _
    -0.5f, -0.5f,  0.5f, _
    _
    -0.5f,  0.5f,  0.5f, _
    -0.5f,  0.5f, -0.5f, _
    -0.5f, -0.5f, -0.5f, _
    -0.5f, -0.5f, -0.5f, _
    -0.5f, -0.5f,  0.5f, _
    -0.5f,  0.5f,  0.5f, _
    _
     0.5f,  0.5f,  0.5f, _
     0.5f,  0.5f, -0.5f, _
     0.5f, -0.5f, -0.5f, _
     0.5f, -0.5f, -0.5f, _
     0.5f, -0.5f,  0.5f, _
     0.5f,  0.5f,  0.5f, _
    _
    -0.5f, -0.5f, -0.5f, _
     0.5f, -0.5f, -0.5f, _
     0.5f, -0.5f,  0.5f, _
     0.5f, -0.5f,  0.5f, _
    -0.5f, -0.5f,  0.5f, _
    -0.5f, -0.5f, -0.5f, _
    _
    -0.5f,  0.5f, -0.5f, _
     0.5f,  0.5f, -0.5f, _
     0.5f,  0.5f,  0.5f, _
     0.5f,  0.5f,  0.5f, _
    -0.5f,  0.5f,  0.5f, _
    -0.5f,  0.5f, -0.5f _
  }
  
  dim as GLuint VAO, VBO
  
  glGenVertexArrays( 1, @VAO )
  glGenBuffers( 1, @VBO )
  
  glBindVertexArray( VAO )
  glBindBuffer( GL_ARRAY_BUFFER, VBO )
  
  glBufferData( GL_ARRAY_BUFFER, ARRAY_ELEMENTS( vertices ) * sizeof( GLfloat ), @vertices( 0 ), GL_STATIC_DRAW )
  
  '' Position
  glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof( GLfloat ), 0 )
  glEnableVertexAttribArray( 0 )
  
  return( Mesh( VAO, VBO ) )
end function
