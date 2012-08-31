unit ChipmunkImport;


// Chipmunk Engine fully ported by Paul Robello
// with help from  Fernando Nadal and Ruben Javier
// paulr@par-com.net

//{$DEFINE CHIPMUNK_DOUBLE_PRECISION} // This is needed when you want to use double precision

interface

uses
{$IFDEF __GPC__}
  system,
  gpc,
{$ENDIF}

{$IFDEF UNIX}
{$IFDEF FPC}
{$IFDEF Ver1_0}
  linux,
{$ELSE}
  pthreads,
  baseunix,
  unix,
{$ENDIF}
  x,
  xlib,
{$ELSE}
  Types,
  Libc,
  Xlib,
{$ENDIF}
{$ENDIF}

{$IFDEF __MACH__}
  GPCMacOSAll,
{$ENDIF}
  Classes, SysUtils, math;

//chipmunk.inc should set this correctly now
//{$DEFINE INLINE}

const
CP_CIRCLE_SHAPE = 0;
CP_SEGMENT_SHAPE = 1;
CP_POLY_SHAPE = 3;
CP_NUM_SHAPES = 3;

CP_PIN_JOINT = 0;
CP_PIVOT_JOINT = 1;
CP_SLIDE_JOINT = 2;
CP_GROOVE_JOINT = 3;

CP_HASH_COEF = 3344921057;

M_PI = 3.1415926535897932;
M_2PI = M_PI * 2;
M_1RAD = M_PI /180;

INFINITY = 1e10000;
cp_bias_coef = 0.1;// Determines how fast penetrations resolve themselves.
cp_collision_slop = 0.1;// Amount of allowed penetration. Used to reduce vibrating contacts.
cp_joint_bias_coef = 0.1;
cp_contact_persistence = 3;// Number of frames that contact information should persist.
CP_ARRAY_INCREMENT = 10;

(*Comment this line if you get weird errors*)
{$DEFINE NICE_CODE_PARAMS}

type
  {simple types}
  {$IFDEF CHIPMUNK_DOUBLE_PRECISION}
   Float = Double;
  {$ELSE}
   Float = Single;
  {$ENDIF}

///////////////
//Chipmunk types
///////////////


type
  pcpUnsignedIntArray=^cpUnsignedIntArray;
  cpUnsignedIntArray = Array [0..32767] of LongWord;

  PcpFloat = ^cpFloat;
  cpFloat = Float;

  PcpVect = ^cpVect;
  cpVect = packed record
    x             : cpFloat;
    y             : cpFloat;
  end;
  PcpVectArray = ^cpVectArray;
  cpVectArray = Array [0..32767] of cpVect;


Const cpVZero  : cpVect = (x:  0; y: 0);
      cpVRight : cpVect = (x:  1; y: 0);
      cpVLeft  : cpVect = (x: -1; y: 0);
      cpVUp    : cpVect = (x:  0; y: 1);
      cpVDown  : cpVect = (x:  0; y:-1);

Type
  PcpBB = ^cpBB;
  cpBB = packed record
    l             : cpFloat;
    b             : cpFloat;
    r             : cpFloat;
    t             : cpFloat;
  end;

  PcpBody = ^cpBody;
  cpBody = packed record
    m             : cpFloat;// Mass and it's inverse.
    m_inv         : cpFloat;
    i             : cpFloat;// Moment of inertia and it's inverse.
    i_inv         : cpFloat;
    p             : cpVect;// Linear components of motion (position, velocity, and force)
    v             : cpVect;
    f             : cpVect;
    v_bias        : cpVect;// NOTE: v_bias and w_bias are used internally for penetration/joint correction.
    a             : cpFloat;// Angular components of motion (angle, angular velocity, and torque)
    w             : cpFloat;
    t             : cpFloat;
    w_bias        : cpFloat;// NOTE: v_bias and w_bias are used internally for penetration/joint correction.
    rot           : cpVect;// Unit length
    data          : pointer; // user defined data
    drawRotInc    : cpFloat; //TISFAT SPECIFIC
    tag           : cardinal; // user usable field
    sleeping      : boolean;
  end;
  pcpBodyPair=^cpBodyPair;
  cpBodyPair=array[0..1] of pcpbody;

  // NOTE: cpArray is rarely used and will probably go away.
  PcpPointerArray=^cpPointerArray;
  cpPointerArray=Array [0..32767] of pointer;

  PcpArray = ^cpArray;
  cpArray = packed record
    num           : integer;
    max           : integer;
    arr           : PcpPointerArray;
  end;
  PcpArrayIter = ^TcpArrayIter;
  TcpArrayIter = procedure (ptr : pointer; data : pointer ); //CFUNCTYPE(None, c_void_p, c_void_p) // typedef void (*cpArrayIter)(void *ptr, void *data);

  // cpHashSet uses a chained hashtable implementation.
  // Other than the transformation functions, there is nothing fancy going on.

  // cpHashSetBin's form the linked lists in the chained hash table.
  PcpHashSetBin = ^cpHashSetBin;
  PPcpHashSetBin = ^PcpHashSetBin;
  cpHashSetBin = packed record
    elt           : pointer;// Pointer to the element.
    hash          : LongWord;// Hash value of the element.
    next          : PcpHashSetBin;// Next element in the chain.
  end;
  PcpHashSetBinArray = ^cpHashSetBinArray;
  cpHashSetBinArray = Array [0..32767] of PcpHashSetBin;


  // Equality function. Returns true if ptr is equal to elt.
  TcpHashSetEqlFunc = function (ptr : pointer; elt : pointer): boolean;

  // Used by cpHashSetInsert(). Called to transform the ptr into an element.
  TcpHashSetTransFunc = function (ptr : pointer; data : pointer): pointer;

  // Iterator function for a hashset.
  TcpHashSetIterFunc = procedure (elt : pointer; data : pointer);

  // Reject function. Returns true if elt should be dropped.
  TcpHashSetRejectFunc = function (elt : pointer; data : pointer): integer;

  PcpHashSet = ^cpHashSet;
  cpHashSet = packed record
    entries       : integer;// Number of elements stored in the table.
    size          : integer;// Number of cells in the table.
    eql           : TcpHashSetEqlFunc;
    trans         : TcpHashSetTransFunc;
    default_value : pointer;// Default value returned by cpHashSetFind() when no element is found.// Defaults to NULL.
    table         : PcpHashSetBinArray;
  end;

  // The spatial hash is Chipmunk's default (and currently only) spatial index type.
  // Based on a chained hash table.
  // Used internally to track objects added to the hash
  PcpHandle = ^cpHandle;
  cpHandle = packed record
    obj           : pointer;// Pointer to the object
    retain        : integer;// Retain count
    stamp         : integer;// Query stamp. Used to make sure two objects
  end;                  // aren't identified twice in the same query.

  // Linked list element for in the chains.
  PcpSpaceHashBin = ^cpSpaceHashBin;
  cpSpaceHashBin = packed record
    handle        : PcpHandle;
    next          : PcpSpaceHashBin;//
  end;
  PcpSpaceHashBinArray=^cpSpaceHashBinArray;
  cpSpaceHashBinArray = Array [0..32767] of pcpSpaceHashBin;

  // BBox callback. Called whenever the hash needs a bounding box from an object.
  PTcpSpaceHashBBFunc = ^TcpSpaceHashBBFunc;
  TcpSpaceHashBBFunc = function (obj : pointer): cpBB;

  PcpSpaceHash = ^cpSpaceHash;
  cpSpaceHash = packed record
    numcells      : integer;// Number of cells in the table.
    celldim       : cpFloat;// Dimentions of the cells.
    bbfunc        : TcpSpaceHashBBFunc;// BBox callback.
    handleSet     : PcpHashSet;// Hashset of all the handles.
    table         : PcpSpaceHashBinArray;
    bins          : PcpSpaceHashBin;// List of recycled bins.
    stamp         : integer;// Incremented on each query. See cpHandle.stamp.
  end;

  // Iterator function
  TcpSpaceHashIterator = procedure (obj : pointer; data : pointer); //maybe a procedure

  // Query callback.
  TcpSpaceHashQueryFunc = function (obj1 : pointer; obj2 : pointer; data : pointer): integer;

   PcpEachPair=^cpEachPair;
   cpEachPair=packed record
      func:TcpSpaceHashIterator;
      data:pointer;
   end;

   // Similar to struct eachPair above.
   pcpQueryRehashPair =^cpQueryRehashPair;
   cpQueryRehashPair = packed record
      hash:pcpSpaceHash;
      func:TcpSpaceHashQueryFunc;
      data:pointer;
   end;


// Enumeration of shape types.
  cpShapeType = integer;

  // Basic shape struct that the others inherit from.
  PcpShape = ^cpShape;
  cpShape = packed record
    cptype        : cpShapeType;//original name was "type"
    cacheData     : function (shape : PcpShape; const p : cpVect; const rot : cpVect) : cpBB; //Called by cpShapeCacheBB().
    destroy       : procedure (shape : PcpShape); // Called to by cpShapeDestroy().
    id            : LongWord;// Unique id used as the hash value.
    bb            : cpBB;// Cached BBox for the shape.
    collision_type: LongWord;// User defined collision type for the shape.
    group         : LongWord;// User defined collision group for the shape.
    layers        : LongWord;// User defined layer bitmask for the shape.
    data          : pointer;// User defined data pointer for the shape.
    body          : PcpBody;// cpBody that the shape is attached to.
    is_static     : boolean;// set to true if body is static
    e             : cpFloat;// Coefficient of restitution. (elasticity)
    u             : cpFloat;// Coefficient of friction.
    surface_v     : cpVect;// Surface velocity used when solving for friction.
    tag           : LongWord;// user usable
  end;
  cpShapePair=array[0..1] of pcpShape;
  cpShapeArray=Array [0..32767] of PcpShape;
  PcpShapeArray=^cpShapeArray;


  // Circle shape structure.
  PcpCircleShape = ^cpCircleShape;
  cpCircleShape = packed record
    shape         : cpShape;
    c             : cpVect;// Center. (body space coordinates)
    r             : cpFloat;// Radius.
    tc            : cpVect;// Transformed center. (world space coordinates)
  end;

  // Segment shape structure.
  PcpSegmentShape = ^cpSegmentShape;
  cpSegmentShape = packed record
    shape         : cpShape;
    a             : cpVect;// Endpoints and normal of the segment.a,b,n (body space coordinates)
    b             : cpVect;
    n             : cpVect;
    r             : cpFloat;// Radius of the segment. (Thickness)
    ta            : cpVect;// Transformed endpoints and normal.ta,tb,tn (world space coordinates)
    tb            : cpVect;
    tn            : cpVect;
  end;

  // Axis structure used by cpPolyShape.
  PcpPolyShapeAxis = ^cpPolyShapeAxis;
  cpPolyShapeAxis = packed record
    n             : cpVect;// normal
    d             : cpFloat;// distance from origin
  end;

  cpPolyShapeAxisArray = Array [0..32767] of cpPolyShapeAxis;
  PcpPolyShapeAxisArray = ^cpPolyShapeAxisArray;

  // Convex polygon shape structure.
  PcpPolyShape = ^cpPolyShape;
  cpPolyShape = packed record
    shape         : cpShape;
    numVerts      : integer;// Vertex and axis list count.
    verts         : PcpVectArray;
    axes          : PcpPolyShapeAxisArray;
    tVerts        : PcpVectArray;// Transformed vertex and axis lists.
    tAxes         : PcpPolyShapeAxisArray;
    convex        : boolean; // true if poly is convex
  end;

  // Data structure for contact points.
  PcpContact = ^cpContact;
  cpContact = packed record
    p             : cpVect;// Contact point.
    n             : cpVect;// Contact point normal.
    dist          : cpFloat;// Penetration distance.
    r1            : cpVect;// Calculated by cpArbiterPreStep.
    r2            : cpVect;// Calculated by cpArbiterPreStep.
    nMass         : cpfloat;// Calculated by cpArbiterPreStep.
    tMass         : cpfloat;// Calculated by cpArbiterPreStep.
    bounce        : cpfloat;// Calculated by cpArbiterPreStep.
    jnAcc         : cpfloat;// Persistant contact information.
    jtAcc         : cpfloat;// Persistant contact information.
    jBias         : cpfloat;// Persistant contact information.
    bias          : cpfloat;// Persistant contact information.
    hash          : LongWord;// Hash value used to (mostly) uniquely identify a contact.
  end;
  cpContactArray = Array [0..32767] of cpContact;
  PcpContactArray = ^cpContactArray;

  // Data structure for tracking collisions between shapes.
  PcpArbiter = ^cpArbiter;
  cpArbiter = packed record
    numContacts   : integer;// Information on the contact points between the objects.
    contacts      : PcpContactArray;// Information on the contact points between the objects.
    a             : PcpShape;// The two shapes involved in the collision.
    b             : PcpShape;// The two shapes involved in the collision.
    u             : cpFloat;// Calculated by cpArbiterPreStep().
    e             : cpFloat;// Calculated by cpArbiterPreStep().
    target_v      : cpVect;// Calculated by cpArbiterPreStep().
    stamp         : integer;// Time stamp of the arbiter. (from cpSpace)
  end;

  PcpJoint = ^cpJoint;
  cpJoint = packed record
    cpType        : integer;
    a             : PcpBody;
    b             : PcpBody;
    preStep       : procedure (joint : PcpJoint; const dt_inv : cpFloat);
    applyImpulse  : procedure (joint : PcpJoint);
    tisJoint      : pointer;
    x,y           : cpFloat;
  end;

  PcpPinJoint = ^cpPinJoint;
  cpPinJoint = packed record
    joint         : cpJoint;
    anchr1        : cpVect;
    anchr2        : cpVect;
    dist          : cpFloat;
    r1            : cpVect;
    r2            : cpVect;
    n             : cpVect;
    nMass         : cpFloat;
    jnAcc         : cpFloat;
    jBias         : cpFloat;
    bias          : cpFloat;
  end;

  PcpSlideJoint = ^cpSlideJoint;
  cpSlideJoint = packed record
    joint         : cpJoint;
    anchr1        : cpVect;
    anchr2        : cpVect;
    min           : cpFloat;
    max           : cpFloat;
    r1            : cpVect;
    r2            : cpVect;
    n             : cpVect;
    nMass         : cpFloat;
    jnAcc         : cpFloat;
    jBias         : cpFloat;
    bias          : cpFloat;
  end;

  PcpPivotJoint = ^cpPivotJoint;
  cpPivotJoint = packed record
    joint         : cpJoint;
    anchr1        : cpVect;
    anchr2        : cpVect;
    r1            : cpVect;
    r2            : cpVect;
    k1            : cpVect;
    k2            : cpVect;
    jAcc          : cpVect;
    jBias         : cpVect;
    bias          : cpVect;
  end;

  PcpGrooveJoint = ^cpGrooveJoint;
  cpGrooveJoint = packed record
    joint         : cpJoint;
    grv_n         : cpVect;
    grv_a         : cpVect;
    grv_b         : cpVect;
    anchr2        : cpVect;
    grv_tn        : cpVect;
    clamp         : cpFloat;
    r1            : cpVect;
    r2            : cpVect;
    k1            : cpVect;
    k2            : cpVect;
    jAcc          : cpVect;
    jBias         : cpVect;
    bias          : cpVect;
  end;

  // User collision pair function.
  TcpCollFunc = function (a : PcpShape; b : PcpShape; contacts : PcpContactArray; numContacts : integer; normal_coef : cpFloat; data : pointer): integer;

  // Structure for holding collision pair function information.
  // Used internally.
  PcpCollPairFunc = ^cpCollPairFunc;
  cpCollPairFunc = packed record
    a             : LongWord;
    b             : LongWord;
    func          : TcpCollFunc;
    data          : pointer;
  end;

  pcpCollFuncData=^cpCollFuncData;
  cpCollFuncData = packed record
     func :TcpCollFunc;
     data:pointer;
  end;

  PcpSpace = ^cpSpace;
  cpSpace = packed record
    iterations    : integer;// Number of iterations to use in the impulse solver.
    gravity       : cpVect;// Self explanatory.
    damping       : cpFloat;// Self explanatory.
    stamp         : integer;// Time stamp. Is incremented on every call to cpSpaceStep().
    staticShapes  : PcpSpaceHash;// The static and active shape spatial hashes.
    activeShapes  : PcpSpaceHash;// The static and active shape spatial hashes.
    bodies        : PcpArray;// List of bodies in the system.
    arbiters      : PcpArray;// List of active arbiters for the impulse solver.
    contactSet    : PcpHashSet;// Persistant contact set.
    joints        : PcpArray;// List of joints in the system.
    collFuncSet   : PcpHashSet;// Set of collisionpair functions.
    defaultPairFunc : cpCollPairFunc;// Default collision pair function.
  end;

  // Iterator function for iterating the bodies in a space.
  TcpSpaceBodyIterator = procedure (body : PcpBody; data : pointer); //maybe a procedure

  TcpCollisionFunc=function (a,b:pcpShape; var contact:PcpContactArray):integer;
  PcpCollisionFuncArray = ^TcpCollisionFuncArray;
  TcpCollisionFuncArray = Array [0..32767] of TcpCollisionFunc;


// *****************************************************************************************************************************
//
// main functions
//
// *****************************************************************************************************************************
function calloc(Num,ElemSize : integer) : pointer; overload;{$IFDEF INLINE}inline;{$ENDIF}

function calloc(Size : integer) : pointer; overload;{$IFDEF INLINE}inline;{$ENDIF}
procedure cfree(p : pointer); {$IFDEF INLINE}inline;{$ENDIF}
function malloc(Num,ElemSize : integer) : pointer; overload;{$IFDEF INLINE}inline;{$ENDIF}
function malloc(Size : integer) : pointer; overload;{$IFDEF INLINE}inline;{$ENDIF}


function CP_HASH_PAIR(A, B :LongWord):LongWord; overload;{$IFDEF INLINE}inline;{$ENDIF}
function CP_HASH_PAIR(A, B :pointer):LongWord; overload;{$IFDEF INLINE}inline;{$ENDIF}
function CP_HASH_PAIR(A: Longword; B :pointer):LongWord; overload;{$IFDEF INLINE}inline;{$ENDIF}
function CP_HASH_PAIR(A: Pointer; B :Longword):LongWord; overload;{$IFDEF INLINE}inline;{$ENDIF}

procedure cpInitChipmunk;
procedure cpShutdownChipmunk;
procedure cpAddColFunc(a, b:cpShapeType; func:TCPCollisionFunc);
procedure cpInitCollisionFuncs; 
function cpMomentForCircle(const m,r1,r2 : cpFloat; const offset : cpVect) : cpFloat; {$IFDEF INLINE}inline;{$ENDIF}
function cpMomentForPoly(const m : cpFloat; numVerts : integer; verts : PcpVectArray; const offset : cpVect) : cpFloat;

// math functions
function cpfmax(const a : cpFloat; const b : cpFloat) : cpFloat; {$IFDEF INLINE}inline;{$ENDIF}
function cpfmin(const a : cpFloat; const b : cpFloat) : cpFloat; {$IFDEF INLINE}inline;{$ENDIF}


// *****************************************************************************************************************************
//
// Vect functions
//
// *****************************************************************************************************************************

function cpv(const x : cpFloat; const y : cpFloat):cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvadd(const v1 : cpVect; const v2 : cpVect):cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvneg(const v : cpVect):cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvsub(const v1 : cpVect; const v2 : cpVect):cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvmult(const v : cpVect; const s : cpFloat):cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvdot(const v1 : cpVect; const v2 : cpVect):cpFloat; {$IFDEF INLINE}inline;{$ENDIF}
function cpvcross(const v1 : cpVect; const v2 : cpVect):cpFloat; {$IFDEF INLINE}inline;{$ENDIF}
function cpvperp(const v : cpVect):cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvrperp(const v : cpVect):cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvproject(const v1 : cpVect; const v2 : cpVect):cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvrotate(const v1 : cpVect; const v2 : cpVect):cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvunrotate(const v1 : cpVect; const v2 : cpVect):cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvforangle(const a : cpFloat) : cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvtoangle(const v : cpVect) : cpFloat; {$IFDEF INLINE}inline;{$ENDIF}
function cpvlength(const v : cpVect) : cpFloat; {$IFDEF INLINE}inline;{$ENDIF}
function cpvdist(const v1,v2 : cpVect) : cpFloat; {$IFDEF INLINE}inline;{$ENDIF}
function cpvdistsq(const v1,v2 : cpVect) : cpFloat; {$IFDEF INLINE}inline;{$ENDIF}
function cpvlengthsq(const v : cpVect) : cpFloat; {$IFDEF INLINE}inline;{$ENDIF}
function cpvnormalize(const v : cpVect) : cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function cpvstr(const v : cpVect) : string; {$IFDEF INLINE}inline;{$ENDIF}
function cpvEqual(const v1,v2 : cpVect) : boolean; {$IFDEF INLINE}inline;{$ENDIF}
function modf(const a,b: cpFloat) : cpFloat; {$IFDEF INLINE}inline;{$ENDIF}

// *****************************************************************************************************************************
//
// BB functions
//
// *****************************************************************************************************************************

function cpBBNew (const l : cpFloat; const b : cpFloat; const r : cpFloat; const t : cpFloat):cpBB; {$IFDEF INLINE}inline;{$ENDIF}
function cpBBintersects(const a : cpBB; const b : cpBB):integer; {$IFDEF INLINE}inline;{$ENDIF}
function cpBBcontainsBB(const bb : cpBB; const other : cpBB):integer; {$IFDEF INLINE}inline;{$ENDIF}
function cpBBcontainsVect(const bb : cpBB; const v : cpVect):integer; {$IFDEF INLINE}inline;{$ENDIF}
function  cpBBClampVect(const bb : cpBB; const v : cpVect) : cpVect; {$IFDEF INLINE}inline;{$ENDIF}
function  cpBBWrapVect(const bb : cpBB; const v : cpVect) : cpVect; {$IFDEF INLINE}inline;{$ENDIF}

// *****************************************************************************************************************************
//
// Body functions
//
// *****************************************************************************************************************************

// Basic allocation/destruction functions
function  cpBodyAlloc() : PcpBody;
function cpBodyInit( body : PcpBody; const m : cpFloat; const i : cpFloat) : PcpBody;
function  cpBodyNew( const m : cpFloat; const i : cpFloat) : PcpBody;
procedure  cpBodyDestroy( body : PcpBody); 
procedure  cpBodyFree( body : PcpBody);
// Setters for some of the special properties (mandatory!)
procedure  cpBodySetMass( body : PcpBody; const m : cpFloat);
procedure  cpBodySetMoment( body : PcpBody; const i : cpFloat);
procedure cpBodySetAngle( body : PcpBody; const a : cpFloat);

// Modify the velocity of an object so that it will
procedure  cpBodySlew( body : PcpBody; const pos : cpVect; const dt : cpFloat);
// Integration functions.
procedure  cpBodyUpdateVelocity( body : PcpBody; const gravity : cpVect; const damping : cpFloat; const dt : cpFloat);
procedure  cpBodyUpdatePosition( body : PcpBody; const dt : cpFloat);

// Convert body local to world coordinates
function cpBodyLocal2World( body : PcpBody; const v : cpVect):cpVect;
// Convert world to body local coordinates
function cpBodyWorld2Local( body : PcpBody; const v : cpVect):cpVect;
// Apply an impulse (in world coordinates) to the body.
procedure cpBodyApplyImpulse( body : PcpBody; const j : cpVect; const r : cpVect);
// Not intended for external use. Used by cpArbiter.c and cpJoint.c.
procedure cpBodyApplyBiasImpulse( body : PcpBody; const j : cpVect; const r : cpVect);

// Zero the forces on a body.
procedure  cpBodyResetForces( body : PcpBody);
// Apply a force (in world coordinates) to a body.
procedure  cpBodyApplyForce( body : PcpBody; const f : cpVect; const r : cpVect);
// Apply a damped spring force between two bodies.
procedure  cpDampedSpring( a : PcpBody; b : PcpBody; const anchr1 : cpVect; const anchr2 : cpVect; const rlen : cpFloat; const k : cpFloat; const dmp : cpFloat; const dt : cpFloat);

// *****************************************************************************************************************************
//
// Array functions
//
// *****************************************************************************************************************************

// NOTE: cpArray is rarely used and will probably go away.
function  cpArrayAlloc() : PcpArray; 
function  cpArrayInit( arr : PcpArray; size :integer) : PcpArray; 
function  cpArrayNew( size :integer) : PcpArray;
procedure  cpArrayDestroy( arr : PcpArray ); 
procedure  cpArrayFree( arr : PcpArray ); 
procedure  cpArrayPush( arr : PcpArray; cpobject : pointer ); 
procedure  cpArrayDeleteIndex( arr : PcpArray; index :integer); 
procedure  cpArrayDeleteObj( arr : PcpArray; obj : pointer );
procedure  cpArrayEach( arr : PcpArray; iterFunc : TcpArrayIter; data : pointer );
function  cpArrayContains( arr : PcpArray; ptr : pointer ) : integer; 

// *****************************************************************************************************************************
//
// HashSet functions
//
// *****************************************************************************************************************************

// cpHashSet uses a chained hashtable implementation.
// Other than the transformation functions, there is nothing fancy going on.

// Basic allocation/destruction functions.
function  cpHashSetAlloc : PcpHashSet; 
function  cpHashSetInit( cpset : PcpHashSet; size : integer; eqlFunc : TcpHashSetEqlFunc; trans : TcpHashSetTransFunc) : PcpHashSet; 
function  cpHashSetNew( size : integer; eqlFunc : TcpHashSetEqlFunc; trans : TcpHashSetTransFunc) : PcpHashSet; 
procedure  cpHashSetDestroy( cpset : PcpHashSet); 
procedure  cpHashSetFree( cpset : PcpHashSet); 
function cpHashSetIsFull( cpset : PcpHashSet) : boolean; 
procedure cpHashSetResize( cpset : PcpHashSet ); 

// Insert an element into the set, returns the element.
// If it doesn't already exist, the transformation function is applied.
function  cpHashSetInsert( cpset : PcpHashSet; hash : LongWord; ptr : pointer; data : pointer) : pointer; 
// Remove and return an element from the set.
function  cpHashSetRemove( cpset : PcpHashSet; hash : LongWord; ptr : pointer) : pointer; 
// Find an element in the set. Returns the default value if the element isn't found.
function  cpHashSetFind( cpset : PcpHashSet; hash : LongWord; ptr : pointer) : pointer; 

// Iterate over a hashset.
procedure  cpHashSetEach( cpset : PcpHashSet; func : TcpHashSetIterFunc; data : pointer); 
// Iterate over a hashset while rejecting certain elements.
procedure  cpHashSetReject( cpset : PcpHashSet; func : TcpHashSetRejectFunc; data : pointer); 

// *****************************************************************************************************************************
//
// SpaceHash functions
//
// *****************************************************************************************************************************

//Basic allocation/destruction functions.
function cpHandleAlloc:pcpHandle; 
function cpHandleInit(hand:pcpHandle; obj:pointer):pcpHandle; 
function cpHandleNew(obj:pointer):pcpHandle; 
procedure cphandleFreeWrap(elt:pointer; unused:pointer); 
procedure cpHandleRetain(hand:pcpHandle);  {$IFDEF INLINE}inline;{$ENDIF}
procedure cpHandleFree(hand:pcpHandle);  {$IFDEF INLINE}inline;{$ENDIF}
procedure cpHandleRelease(hand:pcpHandle);  {$IFDEF INLINE}inline;{$ENDIF}
procedure cpClearHashCell(hash:pcpSpaceHash; index:integer);  {$IFDEF INLINE}inline;{$ENDIF}
procedure cpfreeBins(hash:pcpSpaceHash); 
procedure cpClearHash(hash:pcpSpaceHash);
procedure cpSpaceHashAllocTable(hash:pcpSpaceHash; numcells: integer); 
function  cpSpaceHashAlloc() : PcpSpaceHash;
function  cpSpaceHashInit( hash : PcpSpaceHash; celldim : cpFloat; numcells : integer; bbfunc : TcpSpaceHashBBFunc) : PcpSpaceHash;
function  cpSpaceHashNew( celldim : cpFloat; cells : integer; bbfunc : TcpSpaceHashBBFunc) : PcpSpaceHash; 

procedure cpSpaceHashDestroy( hash : PcpSpaceHash);                           
procedure cpSpaceHashFree( hash : PcpSpaceHash); 
function cpContainsHandle(bin:pcpSpaceHashBin; hand:pcpHandle):integer; {$IFDEF INLINE}inline;{$ENDIF}
function getEmptyBin(hash:pcpSpaceHash) :pcpSpaceHashBin; {$IFDEF INLINE}inline;{$ENDIF}
function cphash_func(x:LongWord; y:LongWord; n:LongWord) :LongWord; {$IFDEF INLINE}inline;{$ENDIF}
procedure cphashHandle(hash:pcpSpaceHash; hand:pcpHandle;bb:cpBB);  {$IFDEF INLINE}inline;{$ENDIF}
// Resize the hashtable. (Does not rehash! You must call cpSpaceHashRehash() if needed.)
procedure cpSpaceHashResize( hash : PcpSpaceHash; celldim : cpFloat; numcells: Integer);

// Add an object to the hash.
procedure cpSpaceHashInsert( hash : PcpSpaceHash; obj : pointer; id : LongWord; bb : cpBB);
// Remove an object from the hash.
procedure cpSpaceHashRemove( hash : PcpSpaceHash; obj : pointer; id : LongWord);

// Iterate over the objects in the hash.
procedure cpSpaceHashEach( hash : PcpSpaceHash; func : TcpSpaceHashIterator; data : pointer);

// Rehash the contents of the hash.
procedure cpSpaceHashRehash( hash : PcpSpaceHash);

// Rehash only a specific object.
procedure cpSpaceHashRehashObject( hash : PcpSpaceHash; obj : pointer; id : LongWord); 

// Query the hash for a given BBox.
procedure cpSpaceHashQuery( hash : PcpSpaceHash; obj : pointer; bb : cpBB; func : TcpSpaceHashQueryFunc; data : pointer);

// Rehashes while querying for each object. (Optimized case)
procedure cpSpaceHashQueryRehash( hash : PcpSpaceHash; func : TcpSpaceHashQueryFunc; data : pointer); 

// *****************************************************************************************************************************
//
// Shape functions
//
// *****************************************************************************************************************************

// For determinism, you can reset the shape id counter.
procedure  cpResetShapeIdCounter;

// Low level shape initialization func.
function  cpShapeInit( const shape : PcpShape; const cptype : cpShapeType; const body : PcpBody) : PcpShape;

// Basic destructor functions. (allocation functions are not shared)
procedure  cpShapeDestroy( const shape : PcpShape); 
procedure  cpShapeFree( const shape : PcpShape);

// Cache the BBox of the shape.
function  cpShapeCacheBB( const shape : PcpShape) : cpBB;
function bbFromCircle(const c:cpVect;const r:cpFloat ) :cpBB; {$IFDEF INLINE}inline;{$ENDIF}

// Basic allocation functions for cpCircleShape.
function cpCircleShapeCacheData(shape : PcpShape; const p : cpVect; const rot : cpVect):cpBB; 
function  cpCircleShapeAlloc() : PcpCircleShape;
function  cpCircleShapeInit( const circle : PcpCircleShape; const body : PcpBody; const radius : cpFloat; const offset : cpVect) : PcpCircleShape;
function  cpCircleShapeNew( const body : PcpBody; const radius : cpFloat; const offset : cpVect) : PcpShape;

// Basic allocation functions for cpSegmentShape.
function cpSegmentShapeCacheData(shape:pcpShape; const p:cpVect; const rot:cpVect):cpBB; 
function  cpSegmentShapeAlloc() : PcpSegmentShape;
function  cpSegmentShapeInit( const seg : PcpSegmentShape; const body : PcpBody; const a : cpVect; const b : cpVect; const r : cpFloat) : PcpSegmentShape;
function  cpSegmentShapeNew( const body : PcpBody; const a : cpVect; const b : cpVect; const r : cpFloat) : PcpShape;

// *****************************************************************************************************************************
//
// PolyShape functions
//
// *****************************************************************************************************************************

// Basic allocation functions.
procedure cpPolyShapeTransformAxes(poly:pcpPolyShape; p:cpVect; rot:cpVect);
procedure cpPolyShapeTransformVerts(poly:pcpPolyShape; const p:cpVect; const rot:cpVect);
function cpPolyShapeCacheData(shape:pcpShape; const p:cpVect; const rot:cpVect) :cpBB;
function cpIsPolyConvex(verts : pcpVectArray; numVerts : integer) : boolean;
procedure cpPolyShapeDestroy(shape:pcpShape);
function  cpPolyShapeAlloc : PcpPolyShape;
function  cpPolyShapeInit( poly : PcpPolyShape; body : PcpBody; numVerts : integer; verts : PcpVectArray; const offset : cpVect; assumeConvex : boolean = true) : PcpPolyShape;
function  cpPolyShapeNew( body : PcpBody; numVerts : integer; verts : PcpVectArray; const offset : cpVect) : PcpShape;

// Returns the minimum distance of the polygon to the axis.
function  cpPolyShapeValueOnAxis( const poly : PcpPolyShape; const n : cpVect; const d : cpFloat) : cpFloat; {$IFDEF INLINE}inline;{$ENDIF}
// Returns true if the polygon contains the vertex.
function  cpPolyShapeContainsVert( const poly : PcpPolyShape; const v : cpVect) : integer; {$IFDEF INLINE}inline;{$ENDIF}

// *****************************************************************************************************************************
//
// Arbiter functions
//
// *****************************************************************************************************************************

// Contacts are always allocated in groups.
function cpContactInit( con : PcpContact; const p : cpVect; const n : cpVect; const dist : cpFloat; const hash : LongWord ) : PcpContact; 
// Sum the contact impulses. (Can be used after cpSpaceStep() returns)
function cpContactsSumImpulses( contacts : PcpContactArray; const numContacts :integer) : cpVect; 
function cpContactsSumImpulsesWithFriction( contacts : PcpContactArray; const numContacts :integer) : cpVect; 

// Basic allocation/destruction functions.
function cpArbiterAlloc() : PcpArbiter; 
function cpArbiterInit( arb : PcpArbiter; a : PcpShape; b : PcpShape; stamp :integer) : PcpArbiter;
function cpArbiterNew( a : PcpShape; b : PcpShape; stamp :integer) : PcpArbiter;
procedure cpArbiterDestroy( arb : PcpArbiter );
procedure cpArbiterFree( arb : PcpArbiter );
procedure cpFreeArbiters( space : pcpspace); 

// These functions are all intended to be used internally.
// Inject new contact points into the arbiter while preserving contact history.
procedure cpArbiterInject( arb : PcpArbiter; var contacts : PcpContactArray; const numContacts :integer); 
// Precalculate values used by the solver.
procedure cpArbiterPreStep( arb : PcpArbiter; const dt_inv : cpFloat );
// Run an iteration of the solver on the arbiter.
procedure cpArbiterApplyImpulse( arb : PcpArbiter ); 

// *****************************************************************************************************************************
//
// Collision functions
//
// *****************************************************************************************************************************

// Collides two cpShape structures. (this function is lonely :( )
function cpAddContactPoint(var arr:PcpContactArray; var max, num:integer) :pcpContact;
function  cpCollideShapes( a : PcpShape; b : PcpShape; var arr : PcpContactArray) : integer;

// *****************************************************************************************************************************
//
// Joint functions
//
// *****************************************************************************************************************************

procedure  cpJointDestroy( joint : PcpJoint);
procedure  cpJointFree( joint : PcpJoint);

function  cpPinJointAlloc : PcpPinJoint;
function cpPinJointReInit( joint : PcpPinJoint; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect) : PcpPinJoint;
function  cpPinJointInit( joint : PcpPinJoint; a : PcpBody; b : PcpBody; const anchr1 : cpVect; const anchr2 : cpVect) : PcpPinJoint;
function  cpPinJointNew( a : PcpBody; b : PcpBody; const anchr1 : cpVect; const anchr2 : cpVect) : PcpJoint;

function  cpSlideJointAlloc : PcpSlideJoint;
function cpSlideJointReInit( joint : PcpSlideJoint; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; min : cpFloat; max : cpFloat) : PcpSlideJoint;
function  cpSlideJointInit( joint : PcpSlideJoint; a : PcpBody; b : PcpBody; const anchr1 : cpVect; const anchr2 : cpVect; const min : cpFloat; const max : cpFloat) : PcpSlideJoint;
function  cpSlideJointNew( a : PcpBody; b : PcpBody; const anchr1 : cpVect; const anchr2 : cpVect; const min : cpFloat; const max : cpFloat) : PcpJoint;

function  cpPivotJointAlloc() : PcpPivotJoint;
function cpPivotJointReInit( joint : PcpPivotJoint; a : PcpBody; b : PcpBody; pivot : cpVect) : PcpPivotJoint;
function  cpPivotJointInit( joint : PcpPivotJoint; a : PcpBody; b : PcpBody; const pivot : cpVect) : PcpPivotJoint;
function  cpPivotJointNew( a : PcpBody; b : PcpBody; const pivot : cpVect) : PcpJoint;

function  cpGrooveJointAlloc : PcpGrooveJoint;
function cpGrooveJointReInit( joint : PcpGrooveJoint; a : PcpBody; b : PcpBody; groove_a : cpVect; groove_b : cpVect; anchr2 : cpVect) : PcpGrooveJoint;
function  cpGrooveJointInit( joint : PcpGrooveJoint; a : PcpBody; b : PcpBody; const groove_a : cpVect; const groove_b : cpVect; const anchr2 : cpVect) : PcpGrooveJoint;
function  cpGrooveJointNew( a : PcpBody; b : PcpBody; const groove_a : cpVect; const groove_b : cpVect; const anchr2 : cpVect) : PcpJoint;

// *****************************************************************************************************************************
//
// Space functions
//
// *****************************************************************************************************************************

// Basic allocation/destruction functions.
function  cpSpaceAlloc : PcpSpace;
function  cpSpaceInit( space : PcpSpace) : PcpSpace;
function  cpSpaceNew : PcpSpace;

procedure cpSpaceClearArbiters ( space : PcpSpace);
procedure cpSpaceDestroy( space : PcpSpace);
procedure cpSpaceFree( space : PcpSpace);

// Convenience function. Frees all referenced entities. (bodies, shapes and joints)
procedure cpSpaceFreeChildren( space : PcpSpace);

// Collision pair function management functions.
procedure cpSpaceAddCollisionPairFunc( space : PcpSpace; a : LongWord; b : LongWord; func : TcpCollFunc; data : pointer);
procedure cpSpaceRemoveCollisionPairFunc( space : PcpSpace; a : LongWord; b : LongWord);
procedure cpSpaceSetDefaultCollisionPairFunc( space : PcpSpace; func : TcpCollFunc; data : pointer);
function cpContactSetReject(ptr : pointer; data : pointer) : integer;

// Add and remove entities from the system.
procedure cpSpaceAddShape( space : PcpSpace; shape : PcpShape);
procedure cpSpaceAddStaticShape( space : PcpSpace; shape : PcpShape);
procedure cpSpaceAddBody( space : PcpSpace; body : PcpBody);
procedure cpSpaceAddJoint( space : PcpSpace; joint : PcpJoint);

procedure cpSpaceRemoveShape( space : PcpSpace; shape : PcpShape);
procedure cpSpaceRemoveStaticShape( space : PcpSpace; shape : PcpShape);
procedure cpSpaceRemoveBody( space : PcpSpace; body : PcpBody);
procedure cpSpaceRemoveJoint( space : PcpSpace; joint : PcpJoint);
procedure cpSpaceEachBody( space : PcpSpace; func : TcpSpaceBodyIterator; data : pointer);

// Spatial hash management functions.
procedure cpSpaceResizeStaticHash( space : PcpSpace; dim : cpFloat; count : Integer);
procedure cpSpaceResizeActiveHash( space : PcpSpace; dim : cpFloat; count : Integer);
procedure cpUpdateBBCache(ptr:pointer;unused:pointer);
procedure cpSpaceRehashStatic( space : PcpSpace);

// Update the space.
function cpQueryFunc(p1:pointer; p2:pointer; data:pointer) : integer;
function cpQueryReject(a:pcpShape; b:pcpShape) : integer;{$IFDEF INLINE}inline;{$ENDIF}
procedure cpSpaceStep( space : PcpSpace; dt : cpFloat);


function cpTotalBodies : integer;
function cpTotalShapes : integer;
function cpTotalArbiters : integer;
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------


implementation

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

const primes :array[0..29] of integer = (
	5,          //2^2  + 1
	11,         //2^3  + 3
	17,         //2^4  + 1
	37,         //2^5  + 5
	67,         //2^6  + 3
	131,        //2^7  + 3
	257,        //2^8  + 1
	521,        //2^9  + 9
	1031,       //2^10 + 7
	2053,       //2^11 + 5
	4099,       //2^12 + 3
	8209,       //2^13 + 17
	16411,      //2^14 + 27
	32771,      //2^15 + 3
	65537,      //2^16 + 1
	131101,     //2^17 + 29
	262147,     //2^18 + 3
	524309,     //2^19 + 21
	1048583,    //2^20 + 7
	2097169,    //2^21 + 17
	4194319,    //2^22 + 15
	8388617,    //2^23 + 9
	16777259,   //2^24 + 43
	33554467,   //2^25 + 35
	67108879,   //2^26 + 15
	134217757,  //2^27 + 29
	268435459,  //2^28 + 3
	536870923,  //2^29 + 11
	1073741827, //2^30 + 3
	0
);



var SHAPE_ID_COUNTER : integer=0;
    NumBodies : integer=0;
    NumShapes : integer=0;
    NumArbiters : integer=0;
    cpColfuncs : PcpCollisionFuncArray = nil;


// *****************************************************************************************************************************
//
// main functions
//
// *****************************************************************************************************************************

function cpTotalBodies : integer;
begin
   result:=NumBodies;
end;

function cpTotalShapes : integer;
begin
   result:=NumShapes;
end;

function cpTotalArbiters : integer;
begin
   result:=NumArbiters;
end;

function calloc(Size : integer) : pointer;
begin
   getmem(result,size);
   fillchar(result^,size,0);
end;

function calloc(Num,ElemSize : integer) : pointer;
begin
   result:=calloc(num*ElemSize);
end;

procedure cfree(p : pointer);
begin
   if assigned(p) then freemem(p);
end;

function malloc(Size : integer) : pointer;
begin
   getmem(result,size);
end;

function malloc(Num,ElemSize : integer) : pointer;
begin
   result:=malloc(num*ElemSize);
end;

function CP_HASH_PAIR(A, B :LongWord):LongWord;
begin
   result:=(A*CP_HASH_COEF) xor (B*CP_HASH_COEF);
end;

function CP_HASH_PAIR(A, B :pointer):LongWord;
begin
   result:=CP_HASH_PAIR(cardinal(A), cardinal(B));
end;

function CP_HASH_PAIR(A: Longword; B :pointer):LongWord;
begin
   result:=CP_HASH_PAIR(A, cardinal(B));
end;

function CP_HASH_PAIR(A: Pointer; B :Longword):LongWord;
begin
   result:=CP_HASH_PAIR(cardinal(A), B);
end;

function cpfmax (const a : cpFloat; const b : cpFloat) : cpFloat;
begin
 if a>b then
  result:=a
 else
  result:=b;
end;

function cpfmin (const a : cpFloat; const b : cpFloat) : cpFloat;
begin
 if a<b then
  result:=a
 else
  result:=b;
end;

function cpAddContactPoint(var arr:PcpContactArray; var max, num:integer) :pcpContact;
begin
   if not assigned(arr) then begin
      // Allocate the array if it hasn't been done.
      max := 2;
      num := 0;
      arr := calloc(max,sizeof(cpContact));
   end else if (num = max) then begin
      // Extend it if necessary.
      max := max*2;
      arr:=ReallocMemory(arr, max*sizeof(cpContact));
   end;

   result := @arr[num];
   inc(num);
end;

// Add contact points for circle to circle collisions.
// Used by several collision tests.
function circle2circleQuery(p1,p2:cpVect; r1,r2:cpFloat; var con : PcpContactArray) : integer;
var distsq,non_zero_dist,dist, mindist : cpFloat;
    delta : cpVect;
begin
   result:=0;
   mindist := r1 + r2;
   delta := cpvsub(p2, p1);
   distsq := cpvlengthsq(delta);
   if(distsq >= mindist*mindist) then exit;

   dist := sqrt(distsq);
   // To avoid singularities, do nothing in the case of dist := 0.
   if dist<>0 then non_zero_dist := dist else non_zero_dist:=INFINITY;

   // Allocate and initialize the contact.
   con := calloc(sizeof(cpContact));
   cpContactInit(@con[0],
                 cpvadd(p1, cpvmult(delta, 0.5 + (r1 - 0.5*mindist)/non_zero_dist)),
                 cpvmult(delta, 1.0/non_zero_dist),
                 dist - mindist,
                 0
   );

   result:=1;
end;

// Collide circle shapes.
function circle2circle(shape1, shape2:pcpShape; var arr:PcpContactArray) : integer;
var circ1,circ2 : pcpCircleShape;
begin
   circ1 := pcpCircleShape(shape1);
   circ2 := pcpCircleShape(shape2);

   result:=circle2circleQuery(circ1.tc, circ2.tc, circ1.r, circ2.r, arr);
end;

// Collide circles to segment shapes.
function circle2segment(circleShape,segmentShape:pcpShape;var con:PcpContactArray) : integer;
var circ:pcpCircleShape;
    seg:pcpSegmentShape;
    dist,dt,dtMin,dtMax,dn : cpFloat;
    n : cpVect;
begin
   result:=0;
   circ := pcpCircleShape(circleShape);
   seg := pcpSegmentShape(segmentShape);

   // Calculate normal distance from segment.
   dn := cpvdot(seg.tn, circ.tc) - cpvdot(seg.ta, seg.tn);
   dist := abs(dn) - circ.r - seg.r;
   if(dist > 0.0) then exit;

   // Calculate tangential distance along segment.
   dt := -cpvcross(seg.tn, circ.tc);
   dtMin := -cpvcross(seg.tn, seg.ta);
   dtMax := -cpvcross(seg.tn, seg.tb);

   // Decision tree to decide which feature of the segment to collide with.
   if(dt < dtMin) then begin
      if(dt < (dtMin - circ.r)) then begin
         exit;
      end else  begin
         result:=circle2circleQuery(circ.tc, seg.ta, circ.r, seg.r, con);
         exit;
      end;
   end else begin
      if(dt < dtMax) then begin
         if (dn < 0.0) then n := seg.tn else n:=cpvneg(seg.tn);
         con := calloc(sizeof(cpContact));
         cpContactInit(@con[0],
                       cpvadd(circ.tc, cpvmult(n, circ.r + dist*0.5)),
                       n,
                       dist,
                       0
         );
         result:=1;
         exit;
      end else begin
         if(dt < (dtMax + circ.r))  then begin
            result:=circle2circleQuery(circ.tc, seg.tb, circ.r, seg.r, con);
            exit;
         end else begin
            exit;
         end;
      end;
   end;
   result:=1;
end;

// Like cpPolyValueOnAxis(), but for segments.
function segValueOnAxis(seg:pcpSegmentShape; const n:cpVect; d:cpFloat):cpFloat;{$IFDEF INLINE}inline;{$ENDIF}
var a, b:cpFloat;
begin
   a := cpvdot(n, seg.ta) - seg.r;
   b := cpvdot(n, seg.tb) - seg.r;
   result:=cpfmin(a, b) - d;
end;

// Identify vertexes that have penetrated the segment.
procedure findPointsBehindSeg(var arr:PcpContactArray; var max,num : integer; seg:pcpSegmentShape; poly:pcpPolyShape; const pDist, coef:cpFloat);{$IFDEF INLINE}inline;{$ENDIF}
var dta,dtb,dt : cpFloat;
    n,v : cpVect;
    i : integer;
begin
   dta := cpvcross(seg.tn, seg.ta);
   dtb := cpvcross(seg.tn, seg.tb);
   n := cpvmult(seg.tn, coef);

   for i:=0 to poly.numVerts-1 do begin
      v := poly.tVerts[i];
      if(cpvdot(v, n) < cpvdot(seg.tn, seg.ta)*coef + seg.r) then begin
         dt := cpvcross(seg.tn, v);
         if((dta >= dt) and (dt >= dtb)) then begin
            cpContactInit(cpaddContactPoint(arr, max, num), v, n, pDist, CP_HASH_PAIR(poly, i));
         end;
      end;
   end;
end;

// Identify points that have penetrated the segment.
procedure findPointBehindSeg(var arr:PcpContactArray; var max,num : integer; seg:pcpSegmentShape; const v:cpVect; const pDist, coef:cpFloat);// {$IFDEF INLINE}inline;{$ENDIF}
var dta,dtb,dt,vdn,nda : cpFloat;
    n : cpVect;
begin
   dta := cpvcross(seg.tn, seg.ta);
   dtb := cpvcross(seg.tn, seg.tb);
   n := cpvmult(seg.tn, coef);
   vdn:=cpvdot(v, n);
   nda:=cpvdot(seg.tn, seg.tb)*coef + seg.r;
   if(vdn < nda) then begin
      dt := cpvcross(seg.tn, v);
      if((dta >= dt) and (dt >= dtb)) then begin
         cpContactInit(cpaddContactPoint(arr, max, num), v, n, pDist, CP_HASH_PAIR(seg, @v));
      end;
   end;
end;

function seg2seg(shape1,shape2:pcpShape; var arr:PcpContactArray) : integer;
var seg1,seg2,ss,sd,st : pcpSegmentShape;
    max,num,i : integer;
    v : cpVect;
    ua,ub,pDist,denom,nume_a,nume_b : cpFloat;
begin
   result:=0;
   seg1 := pcpSegmentShape(shape1);
   seg2 := pcpSegmentShape(shape2);

   max := 0;
   num := 0;

   denom := ((seg2.tb.y - seg2.ta.y)*(seg1.tb.x - seg1.ta.x)) -
            ((seg2.tb.x - seg2.ta.x)*(seg1.tb.y - seg1.ta.y));

   nume_a := ((seg2.tb.x - seg2.ta.x)*(seg1.ta.y - seg2.ta.y)) -
             ((seg2.tb.y - seg2.ta.y)*(seg1.ta.x - seg2.ta.x));

   nume_b := ((seg1.tb.x - seg1.ta.x)*(seg1.ta.y - seg2.ta.y)) -
            ((seg1.tb.y - seg1.ta.y)*(seg1.ta.x - seg2.ta.x));


   if(abs(denom) < 0.001) then begin
      if((nume_a = 0.0) and (nume_b = 0.0)) then begin
//       COINCIDENT 
         if nume_a>1 then;
         exit;
      end;
      if nume_a>1 then;
      exit;
   end;

   ua := nume_a / denom;
   ub := nume_b / denom;

   if((ua >= 0.0) and (ua <= 1.0) and (ub >= 0.0) and (ub <= 1.0)) then begin
      // Get the intersection point.
      v.x := seg1.ta.x + ua*(seg1.tb.x - seg1.ta.x);
      v.y := seg1.ta.y + ua*(seg1.tb.y - seg1.ta.y);
      if seg1.shape.is_static then begin
         ss:=seg1;
         sd:=seg2;
      end else begin
         if seg2.shape.is_static then begin
            ss:=seg2;
            sd:=seg1;
         end else begin
            ss:=seg2;
            sd:=seg1;
         end;
      end;
      for i:=0 to 1 do begin
         if cpvdot(ss.tn,cpvnormalize(cpvsub(sd.ta,ss.ta))) <=0 then begin
            pDist:=-cpvlength(cpvsub(sd.ta,v))+ss.r;
            cpContactInit(cpAddContactPoint(arr, max, num), sd.ta, cpvneg(ss.tn), pDist, CP_HASH_PAIR(cardinal(sd), 0));
         end;
         if cpvdot(ss.tn,cpvnormalize(cpvsub(sd.tb,ss.ta))) <=0 then begin
            pDist:=-cpvlength(cpvsub(sd.tb,v))+ss.r;
            cpContactInit(cpAddContactPoint(arr, max, num), sd.tb, cpvneg(ss.tn), pDist, CP_HASH_PAIR(cardinal(sd), 1));
         end;
         if num>0 then break;
         st:=ss;
         ss:=sd;
         sd:=st;
      end;

      result:=num;
   end;
end;

// Find the minimum separating axis for the give poly and axis list.
function findMSA(poly:pcpPolyShape; axes:pcpPolyShapeAxisArray; num:integer; var min_out:cpFloat):integer; {$IFDEF INLINE}inline;{$ENDIF}
var i,min_index : integer;
    dist,min : cpFloat;
begin
   result:=-1;
   min_index := 0;
   min := cpPolyShapeValueOnAxis(poly, axes[0].n, axes[0].d);
   if(min > 0.0) then exit;

   for i:=1 to num-1 do begin
      dist := cpPolyShapeValueOnAxis(poly, axes[i].n, axes[i].d);
      if(dist > 0.0)  then begin
         exit;
      end else if(dist > min) then begin
         min := dist;
         min_index := i;
      end;
   end;

   min_out := min;
   result:=min_index;
end;

// Add contacts for penetrating vertexes.
function findVerts(var arr:PcpContactArray; poly1,poly2:pcpPolyShape; const n:cpVect; const dist:cpFloat) : integer;{$IFDEF INLINE}inline;{$ENDIF}
var i,max,num : integer;
    v : cpVect;
begin
   max := 0;
   num := 0;

   for i:=0 to  poly1.numVerts-1 do begin
      v := poly1.tVerts[i];
      if (cpPolyShapeContainsVert(poly2, v)<>0) then
         cpContactInit(cpaddContactPoint(arr, max, num), v, n, dist, CP_HASH_PAIR(poly1, i));
   end;

   for i:=0 to poly2.numVerts-1 do begin
      v := poly2.tVerts[i];
      if (cpPolyShapeContainsVert(poly1, v)<>0) then
         cpContactInit(cpaddContactPoint(arr, max, num), v, n, dist, CP_HASH_PAIR(poly2, i));
   end;

   result:=num;
end;

// Collide poly shapes together.
function poly2poly(shape1,shape2:pcpShape; var arr:PcpContactArray) : integer;
var poly1,poly2:pcpPolyShape;
    min1,min2 : cpFloat;
    mini1,mini2 : integer;
begin
   result:=0;
   poly1 := pcpPolyShape(shape1);
   poly2 := pcpPolyShape(shape2);

   mini1 := findMSA(poly2, poly1.tAxes, poly1.numVerts, min1);
   if(mini1 = -1) then exit;

   mini2 := findMSA(poly1, poly2.tAxes, poly2.numVerts, min2);
   if(mini2 = -1) then exit;

   // There is overlap, find the penetrating verts
   if(min1 > min2) then result:=findVerts(arr, poly1, poly2, poly1.tAxes[mini1].n, min1)
      else result:=findVerts(arr, poly1, poly2, cpvneg(poly2.tAxes[mini2].n), min2);
end;

// This one is complicated and gross. Just don't go there...
// TODO: Comment me!
function seg2poly(shape1,shape2:pcpShape; var arr:PcpContactArray) : integer;
var seg :pcpSegmentShape;
    poly:pcpPolyShape;
    axes :pcpPolyShapeAxisArray;
    dist,poly_min,minNorm,minNeg,segD : cpFloat;
    max,num,i,mini : integer;
    va,vb,poly_n : cpVect;
begin
   result:=0;
   seg := pcpSegmentShape(shape1);
   poly := pcpPolyShape(shape2);
   axes := poly.tAxes;

   segD := cpvdot(seg.tn, seg.ta);
   minNorm := cpPolyShapeValueOnAxis(poly, seg.tn, segD) - seg.r;
   minNeg := cpPolyShapeValueOnAxis(poly, cpvneg(seg.tn), -segD) - seg.r;
   if((minNeg > 0.0) or (minNorm > 0.0)) then exit;

   mini := 0;
   poly_min := segValueOnAxis(seg, axes[0].n, axes[0].d);
   if(poly_min > 0.0) then exit;
   for i:=0 to poly.numVerts-1 do begin
      dist := segValueOnAxis(seg, axes[i].n, axes[i].d);
      if(dist > 0.0) then begin
         exit;
      end else if(dist > poly_min) then begin
         poly_min := dist;
         mini := i;
      end;
   end;

   max := 0;
   num := 0;

   poly_n := cpvneg(axes[mini].n);

   va := cpvadd(seg.ta, cpvmult(poly_n, seg.r));
   vb := cpvadd(seg.tb, cpvmult(poly_n, seg.r));
   if(cpPolyShapeContainsVert(poly, va)<>0) then
      cpContactInit(cpaddContactPoint(arr, max, num), va, poly_n, poly_min, CP_HASH_PAIR(seg, 0));
   if(cpPolyShapeContainsVert(poly, vb)<>0) then
      cpContactInit(cpaddContactPoint(arr, max, num), vb, poly_n, poly_min, CP_HASH_PAIR(seg, 1));

   // Floating point precision problems here.
   // This will have to do for now.
   poly_min := poly_min - cp_collision_slop;
   if((minNorm >= poly_min) or (minNeg >= poly_min))  then begin
      if(minNorm > minNeg) then
         findPointsBehindSeg(arr, max, num, seg, poly, minNorm, 1.0)
      else
         findPointsBehindSeg(arr, max, num, seg, poly, minNeg, -1.0);
   end;

   result:=num;
end;

// This one is less gross, but still gross.
// TODO: Comment me!

function circle2poly(shape1, shape2:pcpShape; var con:PcpContactArray) : integer;
var circ:pcpCircleShape;
    poly:pcpPolyShape;
    axes:pcpPolyShapeAxisArray;
    i,mini : integer;
    dta,dtb,dt,dist,min : cpFloat;
    a,b,n:cpVect;

begin
   result:=0;
   circ := pcpCircleShape(shape1);
   poly := pcpPolyShape(shape2);
   axes := poly.tAxes;

   mini := 0;
   min := cpvdot(axes[0].n, circ.tc) - axes[0].d - circ.r;
   for i:=0 to  poly.numVerts-1 do begin
      dist := cpvdot(axes[i].n, circ.tc) - axes[i].d - circ.r;
      if(dist > 0.0) then begin
         exit;
      end else if(dist > min) then begin
         min := dist;
         mini := i;
      end;
   end;

   n := axes[mini].n;
   a := poly.tVerts[mini];
   b := poly.tVerts[(mini + 1) mod poly.numVerts];
   dta := cpvcross(n, a);
   dtb := cpvcross(n, b);
   dt := cpvcross(n, circ.tc);

   if(dt < dtb) then begin
      result:=circle2circleQuery(circ.tc, b, circ.r, 0.0, con);
   end else if(dt < dta)  then begin
      con := calloc(sizeof(cpContact));
      cpContactInit(@con[0],
                     cpvsub(circ.tc, cpvmult(n, circ.r + min/2.0)),
                     cpvneg(n),
                     min,
                     0
      );
      result:=1;
   end else begin
      result:=circle2circleQuery(circ.tc, a, circ.r, 0.0, con);
   end;
end;

function  cpCollideShapes( a : PcpShape; b : PcpShape; var arr : PcpContactArray) : integer;
var cfunc : TcpCollisionFunc;
begin
   result:=0;

   // Their shape types must be in order.
   assert(a.cptype <= b.cptype);

   cfunc := cpcolfuncs[a.cptype + b.cptype*CP_NUM_SHAPES];
   if not assigned(cfunc) then exit;

   result:=cfunc(a, b, arr);
end;

procedure cpAddColFunc(a, b:cpShapeType; func:TcpCollisionFunc);
begin
   cpColfuncs[a + b*CP_NUM_SHAPES] := func;
end;

procedure cpInitCollisionFuncs;
begin
    if assigned(cpColfuncs) then exit;
    cpColfuncs := calloc(50, sizeof(TcpCollisionFunc));

    cpaddColFunc(CP_CIRCLE_SHAPE,  CP_CIRCLE_SHAPE,  circle2circle);  //0=0
    cpaddColFunc(CP_CIRCLE_SHAPE,  CP_SEGMENT_SHAPE, circle2segment); //1=3
    cpAddColFunc(CP_SEGMENT_SHAPE, CP_SEGMENT_SHAPE, seg2seg);        //2=6
    cpaddColFunc(CP_CIRCLE_SHAPE,  CP_POLY_SHAPE,    circle2poly);    //3=9
    cpaddColFunc(CP_SEGMENT_SHAPE, CP_POLY_SHAPE,    seg2poly);       //4=12
    cpaddColFunc(CP_POLY_SHAPE,    CP_POLY_SHAPE,    poly2poly);      //6=18
end;

procedure cpInitChipmunk;
begin
   cpInitCollisionFuncs;
end;

procedure cpShutdownChipmunk;
begin
   cfree(cpColfuncs);
end;

function cpMomentForCircle(const m,r1,r2 : cpFloat; const offset : cpVect) : cpFloat;
begin
   result:=0.5*m*(r1*r1-r2*r2)+m*cpvdot(offset,offset);
end;


function cpMomentForPoly(const m : cpFloat; numVerts : integer; verts : PcpVectArray; const offset : cpVect) : cpFloat;
var i : integer;
    sum1,sum2,a,b : cpFloat;
    tverts:PcpVectArray;
    v1,v2 : cpVect;
begin
   tVerts:=malloc(numVerts,sizeof(cpVect));
   for i:=0 to numVerts-1 do tVerts[i] := cpvadd(verts[i], offset);

   sum1 := 0.0;
   sum2 := 0.0;
   for i:=0 to numVerts-1 do begin
      v1 := tVerts[i];
      v2 := tVerts[(i+1) mod numVerts];

      a := cpvcross(v2, v1);
      b := cpvdot(v1, v1) + cpvdot(v1, v2) + cpvdot(v2, v2);

      sum1:=sum1+a*b;
      sum2:=sum2+a;
   end;

   freemem(tVerts);
   result:=(m*sum1)/(6.0*sum2);
end;

// *****************************************************************************************************************************
//
// Vect functions
//
// *****************************************************************************************************************************

function cpv(const x : cpFloat; const y : cpFloat):cpVect;
begin
   result.x:=x; result.y:=y;
end;

function cpvadd(const v1 : cpVect; const v2 : cpVect):cpVect;
begin
   result:=cpv(v1.x+v2.x,v1.y+v2.y);
end;

function cpvneg(const v : cpVect):cpVect;
begin
   result:=cpv(-v.x,-v.y);
end;

function cpvsub(const v1 : cpVect; const v2 : cpVect):cpVect;
begin
   result:=cpv(v1.x-v2.x,v1.y-v2.y);
end;

function cpvmult(const v : cpVect; const s : cpFloat):cpVect;
begin
   result:=cpv(v.x*s,v.y*s);
end;

function cpvdot(const v1 : cpVect; const v2 : cpVect):cpFloat;
begin
   result:=v1.x*v2.x + v1.y*v2.y;
end;

function cpvcross(const v1 : cpVect; const v2 : cpVect):cpFloat;
begin
   result:=v1.x*v2.y - v1.y*v2.x;
end;

function cpvperp(const v : cpVect):cpVect;
begin
   result:=cpv(-v.y,v.x);
end;

function cpvrperp(const v : cpVect):cpVect;
begin
   result:=cpv(v.y,-v.x);
end;

function cpvproject(const v1 : cpVect; const v2 : cpVect):cpVect;
begin
   result:=cpvmult(v2, cpvdot(v1, v2)/cpvdot(v2, v2));
end;

function cpvrotate(const v1 : cpVect; const v2 : cpVect):cpVect;
begin
   result:=cpv(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
end;

function cpvunrotate(const v1 : cpVect; const v2 : cpVect):cpVect;
begin
   result:=cpv(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
end;

function  cpvforangle(const a : cpFloat) : cpVect;
begin
   result.x:=cos(a);
   result.y:=sin(a);
end;

function  cpvtoangle(const v : cpVect) : cpFloat;
begin
   result:=arctan2(v.y,v.x);
end;

function cpvstr(const v : cpVect) : string;
begin
   result:=format('%.3f, $.3f',[v.x,v.y]);
end;

function cpvlength(const v : cpVect) : cpFloat;
begin
   result:=sqrt(cpvdot(v,v));
end;

function cpvlengthsq(const v : cpVect) : cpFloat;
begin
   result:=cpvdot(v,v);
end;

function cpvnormalize(const v : cpVect) : cpVect;
begin
   result:=cpvmult(v,1/cpvlength(v));
end;

function cpvdist(const v1,v2 : cpVect) : cpFloat;
begin
   result:=cpvLength(cpvsub(v1,v2));
end;

function cpvdistsq(const v1,v2 : cpVect) : cpFloat;
begin
   result:=cpvLengthsq(cpvsub(v1,v2));
end;

function cpvEqual(const v1,v2 : cpVect) : boolean;
begin
   result:=(v1.x=v2.x) and (v1.y=v2.y);
end;

function modf(const a,b: cpFloat) : cpFloat;
begin
   result:=a-(b*int(a/b));
end;

// *****************************************************************************************************************************
//
// BB functions
//
// *****************************************************************************************************************************

function cpBBNew (const l : cpFloat; const b : cpFloat; const r : cpFloat; const t : cpFloat):cpBB;
begin
   result.l:=l;
   result.b:=b;
   result.r:=r;
   result.t:=t;
end;

function cpBBintersects(const a : cpBB; const b : cpBB):integer;
begin
 if ((a.l<=b.r) AND (b.l<=a.r) AND (a.b<=b.t) AND (b.b<=a.t)) then
  result:=1
 else
  result:=0;
end;

function cpBBcontainsBB(const bb : cpBB; const other : cpBB):integer;
begin
 if ((bb.l < other.l) AND (bb.r > other.r) AND (bb.b < other.b) AND (bb.t > other.t)) then
  result:=1
 else
  result:=0;
end;

function cpBBcontainsVect(const bb : cpBB; const v : cpVect):integer;
begin
   if ((bb.l < v.x) AND (bb.r > v.x) AND (bb.b < v.y) AND (bb.t > v.y)) then
     result:=1
   else
     result:=0;
end;

function  cpBBClampVect(const bb : cpBB; const v : cpVect) : cpVect;
begin
   result:=cpv(cpfmin(cpfmax(bb.l,v.x),bb.r),cpfmin(cpfmax(bb.b,v.y),bb.t));
end;

function  cpBBWrapVect(const bb : cpBB; const v : cpVect) : cpVect;
var ix,modx,x,iy,mody,y : cpFloat;
begin
   ix := abs(bb.r - bb.l);
   modx := modf(v.x - bb.l, ix);
   if (modx > 0.0) then x := modx else x:=modx + ix;

   iy := abs(bb.t - bb.b);
   mody := modf(v.y - bb.b, iy);
   if (mody > 0.0) then y := mody else y:= mody + iy;

   result:=cpv(x + bb.l, y + bb.b);
end;

// ****************************************************************************************************************************
//
// Body functions
//
// *****************************************************************************************************************************

function cpBodyAlloc() : PcpBody;
begin
   result:=calloc(sizeof(result^));
end;

function cpBodyInit( body : PcpBody; const m : cpFloat; const i : cpFloat) : PcpBody;
begin
   inc(NumBodies);

   cpBodySetMass(body, m);
   cpBodySetMoment(body, i);

   body.p := cpvzero;
   body.v := cpvzero;
   body.f := cpvzero;

   cpBodySetAngle(body, 0.0);

   body.w := 0.0;
   body.t := 0.0;

   body.v_bias := cpvzero;
   body.w_bias := 0.0;

   body.sleeping := false;
   body.drawRotInc := 0;

   result:=body;
end;

function cpBodyNew( const m : cpFloat; const i : cpFloat) : PcpBody;
begin
   result:=cpBodyInit(cpBodyAlloc,m,i);
end;

procedure cpBodyDestroy( body : PcpBody);
begin
end;

procedure cpBodyFree( body : PcpBody);
begin
   if assigned(body) then cpBodyDestroy(body);
   cfree(body);
   dec(NumBodies);
end;

procedure  cpBodySetMass( body : PcpBody; const m : cpFloat);
begin
   body.m:=m;
   body.m_inv:=1/m;
end;

procedure  cpBodySetMoment( body : PcpBody; const i : cpFloat);
begin
   body.i:=i;
   body.i_inv:=1/i;
end;

procedure cpBodySlew( body : PcpBody; const pos : cpVect; const dt : cpFloat);
var delta :cpVect;
begin
   delta := cpvsub(body.p, pos);
   body.v := cpvmult(delta, 1.0/dt);
end;

procedure cpBodyUpdateVelocity( body : PcpBody; const gravity : cpVect; const damping : cpFloat; const dt : cpFloat);
var
   force : cpVect;
begin
   force := gravity;
   if (body.sleeping) then
      force := cpvzero;

   body.v := cpvadd(cpvmult(body.v, damping), cpvmult(cpvadd(force, cpvmult(body.f, body.m_inv)), dt));
   body.w := body.w*damping + body.t*body.i_inv*dt;
end;

procedure cpBodyUpdatePosition( body : PcpBody; const dt : cpFloat);
begin
   body.p := cpvadd(body.p, cpvmult(cpvadd(body.v, body.v_bias), dt));
   cpBodySetAngle(body, body.a + (body.w + body.w_bias)*dt);

   body.v_bias := cpvzero;
   body.w_bias := 0.0;
end;

procedure cpBodySetAngle( body : PcpBody; const a : cpFloat);
begin
   body.a:=modf(a,M_2PI);
   body.rot:=cpvforangle(body.a);
end;

// Convert body local to world coordinates
function cpBodyLocal2World( body : PcpBody; const v : cpVect):cpVect;
begin
   result:=cpvadd(body.p, cpvrotate(v, body.rot));
end;

// Convert world to body local coordinates
function cpBodyWorld2Local( body : PcpBody; const v : cpVect):cpVect;
begin
   result:=cpvunrotate(cpvsub(v, body.p), body.rot);
end;

// Apply an impulse (in world coordinates) to the body.
procedure cpBodyApplyImpulse( body : PcpBody; const j : cpVect; const r : cpVect);
begin
   body.sleeping := false;
   body.v:= cpvadd(body.v, cpvmult(j, body.m_inv));
   body.w:= body.w+(body.i_inv*cpvcross(r, j));
end;

// Not intended for external use. Used by cpArbiter.c and cpJoint.c.
procedure cpBodyApplyBiasImpulse( body : PcpBody; const j : cpVect; const r : cpVect);
begin
   body.sleeping := false;
   body.v_bias:= cpvadd(body.v_bias, cpvmult(j, body.m_inv));
   body.w_bias:= body.w_bias+(body.i_inv*cpvcross(r, j));
end;

procedure cpBodyResetForces( body : PcpBody);
begin
   body.f:=cpvzero;
   body.t:=0;
end;

procedure  cpBodyApplyForce( body : PcpBody; const f : cpVect; const r : cpVect);
begin
   body.sleeping := false;
   body.f := cpvadd(body.f, f);
   body.t := body.t+cpvcross(r, f);
end;

procedure cpDampedSpring( a : PcpBody; b : PcpBody; const anchr1 : cpVect; const anchr2 : cpVect; const rlen : cpFloat; const k : cpFloat; const dmp : cpFloat; const dt : cpFloat);
var r1,r2,delta,v1,v2,n,f : cpVect;
    dist,f_spring,vrn,f_damp : cpFloat;
begin
   // Calculate the world space anchor coordinates.
   r1 := cpvrotate(anchr1, a.rot);
   r2 := cpvrotate(anchr2, b.rot);

   delta := cpvsub(cpvadd(b.p, r2), cpvadd(a.p, r1));
   dist := cpvlength(delta);
   if dist>0 then n :=cpvmult(delta, 1.0/dist) else n:=cpvzero;

   f_spring := (dist - rlen)*k;

   // Calculate the world relative velocities of the anchor points.
   v1 := cpvadd(a.v, cpvmult(cpvperp(r1), a.w));
   v2 := cpvadd(b.v, cpvmult(cpvperp(r2), b.w));

   // Calculate the damping force.
   // This really should be in the impulse solver and can produce problems when using large damping values.
   vrn := cpvdot(cpvsub(v2, v1), n);
   f_damp := vrn*cpfmin(dmp, 1.0/(dt*(a.m_inv + b.m_inv)));

   // Apply!
   f := cpvmult(n, f_spring + f_damp);
   cpBodyApplyForce(a, f, r1);
   cpBodyApplyForce(b, cpvneg(f), r2);
end;

// *****************************************************************************************************************************
//
// Array functions
//
// *****************************************************************************************************************************
// NOTE: cpArray is rarely used and will probably go away.

function  cpArrayAlloc : PcpArray;
begin
   result:=calloc(sizeof(result^));
end;

function cpArrayInit( arr : PcpArray; size : integer ) : PcpArray;
begin
   arr.num := 0;

   if size=0 then size := CP_ARRAY_INCREMENT;
   arr.max := size;
   arr.arr:=calloc(size,sizeof(pointer));

   result:=arr;
end;

function  cpArrayNew( size :integer) : PcpArray;
begin
   result:=cpArrayInit(cpArrayAlloc,size);
end;

procedure cpArrayDestroy( arr : PcpArray );
begin
   cfree(arr.arr);
end;

procedure cpArrayFree( arr : PcpArray );
begin
   cpArrayDestroy(arr);
   cfree(arr);
end;

procedure cpArrayPush( arr : PcpArray; cpobject : pointer );
begin
   if(arr.num = arr.max) then begin
      inc(arr.max,CP_ARRAY_INCREMENT);
      arr.arr := ReallocMemory(arr.arr, arr.max*sizeof(pointer));
//      fillchar(arr.arr[arr.num],(arr.max-arr.num)*sizeof(pointer),0);
   end;

   arr.arr[arr.num] := cpobject;
   inc(arr.num);
end;

procedure cpArrayDeleteIndex( arr : PcpArray; index :integer);
var last : integer;
begin
   dec(arr.num);
   last := arr.num;
   arr.arr[index] := arr.arr[last];
end;

procedure cpArrayDeleteObj( arr : PcpArray; obj : pointer );
var i : integer;
begin
   for i:=0 to arr.num-1 do begin
       if(arr.arr[i] = obj) then begin
	      cpArrayDeleteIndex(arr, i);
         exit;
      end;
   end;
end;

procedure cpArrayEach( arr : PcpArray; iterFunc : TcpArrayIter; data : pointer );
var i : integer;
begin
   i:=0;
   while i<arr.num do begin
      iterFunc(arr.arr[i], data);
      inc(i);
   end;
end;

function cpArrayContains( arr : PcpArray; ptr : pointer ) : integer;
var i : integer;
begin
   result:=0;
   for i:=0 to arr.num-1 do begin
      if(arr.arr[i] = ptr) then begin
         result:=1;
         exit;
      end;
   end;
end;

// *****************************************************************************************************************************
//
//  HashSet functions
//
// *****************************************************************************************************************************

function next_prime(n:integer) : integer;
var i : integer;
begin
   i:=0;
   while(n > primes[i]) do begin
      inc(i);
      assert(primes[i]<>0); // realistically this should never happen
   end;

   result:=primes[i];
end;

function  cpHashSetAlloc : PcpHashSet;
begin
   result:=calloc(sizeof(result^));
end;

function cpHashSetInit( cpset : PcpHashSet; size : integer; eqlFunc : TcpHashSetEqlFunc; trans : TcpHashSetTransFunc) : PcpHashSet;
begin
   cpset.size := next_prime(size);
   cpset.entries := 0;

   cpset.eql := eqlFunc;
   cpset.trans := trans;

   cpset.default_value := nil;

   cpset.table:=calloc(cpset.size,sizeof(cpHashSetBin));

   result:=cpset;
end;

function cpHashSetNew( size : integer; eqlFunc : TcpHashSetEqlFunc; trans : TcpHashSetTransFunc) : PcpHashSet;
begin
   result:=cpHashSetInit(cpHashSetAlloc, size, eqlFunc, trans);
end;

procedure cpHashSetDestroy( cpset : PcpHashSet);
var i : integer;
    bin,next:pcpHashSetBin;
begin
   // Free the chains.
   for i:=0 to cpset.size-1 do begin
      // Free the bins in the chain.
      bin := cpset.table[i];
      while assigned(bin) do begin
         next := bin.next;
	       cfree(bin);
	       bin := next;
      end;
   end;

   // Free the table.
   cfree(cpset.table);
end;

procedure  cpHashSetFree( cpset : PcpHashSet);
begin
   if assigned(cpset) then cpHashSetDestroy( cpset );
   cfree(cpset);
end;

function cpHashSetIsFull( cpset : PcpHashSet) : boolean;
begin
   result:=cpset.entries >= cpset.size
end;

procedure cpHashSetResize( cpset : PcpHashSet );
var i,index,newSize : longword;
    next,bin : pcpHashSetBin;
    newTable : PcpHashSetBinArray;
begin
   // Get the next approximate doubled prime.
   newSize := next_prime(cpset.size + 1);
   // Allocate a new table.
   newTable:=calloc(newSize,sizeof(cpHashSetBin));

   // Iterate over the chains.
   for i:=0 to cpset.size-1 do begin
     // Rehash the bins into the new table.
     bin := cpset.table[i];
     while assigned(bin) do begin
         next := bin.next;
         index := bin.hash mod newSize;
         bin.next := newTable[index];
         newTable[index] := bin;
         bin := next;
      end;
   end;

   cfree(cpset.table);

   cpset.table := newTable;
   cpset.size := newSize;
end;

function  cpHashSetInsert( cpset : PcpHashSet; hash : LongWord; ptr : pointer; data : pointer) : pointer;
var index : longword;
    bin:pcpHashSetBin;
begin
   {$WARNINGS OFF}
   index := hash mod cpset.size;
   {$WARNINGS ON}

   // Find the bin with the matching element.
   bin := cpset.table[index];
   while assigned(bin) and not cpset.eql(ptr, bin.elt) do  bin := bin.next;

   // Create it necessary.
   if not assigned(bin) then begin
      bin:=calloc(sizeof(cpHashSetBin));
      bin.hash := hash;
      bin.elt := cpset.trans(ptr, data); // Transform the pointer.

      bin.next := cpset.table[index];
      cpset.table[index] := bin;

      inc(cpset.entries);

      // Resize the set if it's full.
      if cpHashsetIsFull(cpset) then cpHashSetResize(cpset);
   end;

   result:=bin.elt;
end;

function  cpHashSetRemove( cpset : PcpHashSet; hash : LongWord; ptr : pointer) : pointer;
var index : integer;
    bin : pcpHashSetBin;
    prev_ptr: ppcpHashSetBin;
begin
   {$WARNINGS OFF}
   index := hash mod cpset.size;
   {$WARNINGS ON}

   // Pointer to the previous bin pointer.
   prev_ptr := @cpset.table[index];
   // Pointer the the current bin.
   bin := cpset.table[index];

   // Find the bin
   while assigned(bin) and (not cpset.eql(ptr, bin.elt)) do begin
      prev_ptr := @bin.next;
      bin := bin.next;
   end;

   // Remove it if it exists.
   if assigned(bin) then begin
      // Update the previos bin pointer to point to the next bin.
      prev_ptr^ := bin.next;
      dec(cpset.entries);

      result:=bin.elt;
      cfree(bin);
      exit;
   end;

   result:=nil;
end;

function cpHashSetFind( cpset : PcpHashSet; hash : LongWord; ptr : pointer) : pointer;
var index : integer;
    Bin:pcpHashSetBin;
begin
   {$WARNINGS OFF}
   index := hash mod cpset.size;
   {$WARNINGS ON}
   bin := cpset.table[index];
   while assigned(bin) and (not cpset.eql(ptr, bin.elt)) do bin := bin.next;
   if assigned(bin) then result:=bin.elt else result:=cpset.default_value;
end;

procedure cpHashSetEach( cpset : PcpHashSet; func : TcpHashSetIterFunc; data : pointer);
var i : integer;
    bin:pcpHashSetBin;
begin
   for i:=0 to cpset.size-1 do begin
      bin := cpset.table[i];
      while assigned(bin) do begin
         func(bin.elt, data);
         bin:=bin.next;
      end;
   end;
end;

procedure cpHashSetReject( cpset : PcpHashSet; func : TcpHashSetRejectFunc; data : pointer);
var i : integer;
    next,bin:pcpHashSetBin;
    prev_ptr:ppcpHashSetBin;
begin
   // Iterate over all the chains.
   for i:=0 to cpset.size-1 do begin
      // The rest works similarly to cpHashcpsetRemove() above.
      prev_ptr := @cpset.table[i];
      bin := cpset.table[i];
      while assigned(bin) do begin
         next := bin.next;
         if(func(bin.elt, data)<>0) then begin
            prev_ptr := @bin.next;
         end else begin
            prev_ptr^ := next;
            dec(cpset.entries);
            cfree(bin);
         end;
         bin := next;
      end;
   end;
end;

// *****************************************************************************************************************************
//
//  SpaceHash functions
//
// *****************************************************************************************************************************

procedure cpSpaceHashAllocTable(hash:pcpSpaceHash; numcells: integer);
begin
   cfree(hash.table);
   hash.numcells := numcells;
   hash.table:=calloc(numcells,sizeof(pcpSpaceHashBin));
end;

function cpSpaceHashAlloc : PcpSpaceHash;
begin
   result:=calloc(sizeof(result^));
end;

function cpHandleAlloc:pcpHandle;
begin
   result:=calloc(sizeof(result^));
end;

function cpHandleInit(hand:pcpHandle; obj:pointer):pcpHandle;
begin
   hand.obj := obj;
   hand.retain := 0;
   hand.stamp := 0;

   result:=hand;
end;

function cpHandleNew(obj:pointer):pcpHandle;
begin
   result:=cpHandleInit(cpHandleAlloc, obj);
end;

procedure cpHandleRetain(hand:pcpHandle);
begin
   inc(hand.retain);
end;

procedure cpHandleFree(hand:pcpHandle);
begin
   cfree(hand);
end;

procedure cpHandleRelease(hand:pcpHandle);
begin
   dec(hand.retain);
   if(hand.retain = 0) then cpHandleFree(hand);
end;

function cpHandleSetEql(obj : pointer; elt:pointer) : boolean;
var hand : pcpHandle;
begin
   hand := pcpHandle(elt);
   result:= (obj = hand.obj);
end;

function cphandleSetTrans(obj:pointer; unused:pointer) : pointer;
var hand :pcpHandle;
begin
   hand := cpHandleNew(obj);
   cpHandleRetain(hand);
   result:=hand;
end;

function cpSpaceHashInit( hash : PcpSpaceHash; celldim : cpFloat; numcells : integer; bbfunc : TcpSpaceHashBBFunc) : PcpSpaceHash;
begin
   cpSpaceHashAllocTable(hash, next_prime(numcells));
   hash.celldim := celldim;
   hash.bbfunc := bbfunc;

   hash.bins := nil;
   hash.handleSet := cpHashSetNew(0, cphandleSetEql, cphandleSetTrans);

   hash.stamp := 1;

   result:=hash;
end;

function cpSpaceHashNew( celldim : cpFloat; cells : integer; bbfunc : TcpSpaceHashBBFunc) : PcpSpaceHash;
begin
   result:=cpSpaceHashInit(cpSpaceHashAlloc,celldim,cells,bbfunc);
end;

procedure cphandleFreeWrap(elt:pointer; unused:pointer);
begin
   cpHandleFree(pcpHandle(elt));
end;

procedure cpClearHashCell(hash:pcpSpaceHash; index:integer);
var bin,next :pcpSpaceHashBin;
begin
   bin := hash.table[index];
   while assigned(bin) do begin
      next := bin.next;

      // Release the lock on the handle.
      cpHandleRelease(bin.handle);
      // Recycle the bin.
      bin.next := hash.bins;
      hash.bins := bin;

      bin := next;
   end;

   hash.table[index] := nil;
end;

procedure cpClearHash(hash:pcpSpaceHash);
var i : integer;
begin
   for i:=0 to hash.numcells-1 do cpclearHashCell(hash, i);
end;

procedure cpfreeBins(hash:pcpSpaceHash);
var bin,next:pcpSpaceHashBin;
begin
   bin := hash.bins;
   while assigned(bin) do begin
      next := bin.next;
      cfree(bin);
      bin := next;
   end;
end;

procedure cpSpaceHashDestroy( hash : PcpSpaceHash);
begin
   cpclearHash(hash);
   cpfreeBins(hash);

   // Free the handles.
   cpHashSetEach(hash.handleSet, cphandleFreeWrap, nil);
   cpHashSetFree(hash.handleSet);

   cfree(hash.table);
end;

procedure cpSpaceHashFree( hash : PcpSpaceHash);
begin
   if not assigned(hash) then exit;
   cpSpaceHashDestroy(hash);
   cfree(hash);
end;

procedure cpSpaceHashResize( hash : PcpSpaceHash; celldim : cpFloat; numcells: Integer);
begin
   // Clear the hash to release the old handle locks.
   cpclearHash(hash);

   hash.celldim := celldim;

   cpSpaceHashAllocTable(hash, next_prime(numcells));
end;

// Return true if the chain contains the handle.
function cpContainsHandle(bin:pcpSpaceHashBin; hand:pcpHandle):integer;
begin
   result:=1;

   while assigned(bin) do begin
      if(bin.handle = hand) then exit;
      bin := bin.next;
   end;

   result:=0;
end;

// Get a recycled or new bin.
function getEmptyBin(hash:pcpSpaceHash) :pcpSpaceHashBin;
var bin:pcpSpaceHashBin;
begin
   bin := hash.bins;
   // Make a new one if necessary.
   if(bin = nil) then begin
      result:=calloc(sizeof(result^));
      exit;
   end;

   hash.bins := bin.next;
   result:=bin;
end;

// The hash function itself.
function cphash_func(x:LongWord; y:LongWord; n:LongWord) : LongWord;
begin
   result:=(x*2185031351 xor y*4232417593) mod n;
end;

procedure cphashHandle(hash:pcpSpaceHash; hand:pcpHandle;bb:cpBB);
var dim : cpFloat;
    index,n,i,j : integer;
    newbin,bin:pcpSpaceHashBin;
    l,r,b,t : integer;
begin
   // Find the dimensions in cell coordinates.
   dim := hash.celldim;
   l := trunc(bb.l/dim);
   r := trunc(bb.r/dim);
   b := trunc(bb.b/dim);
   t := trunc(bb.t/dim);

   n := hash.numcells;
   for i:=l to r do begin
      for j:=b to t do begin
         index := cphash_func(i,j,n);
         bin := hash.table[index];

         // Don't add an object twice to the same cell.
         if(cpContainsHandle(bin, hand)<>0) then continue;

         cpHandleRetain(hand);
         // Insert a new bin for the handle in this cell.
         newBin := getEmptyBin(hash);
         newBin.handle := hand;
         newBin.next := bin;
         hash.table[index] := newBin;
      end;
   end;
end;

// Add an object to the hash.
procedure cpSpaceHashInsert( hash : PcpSpaceHash; obj : pointer; id : LongWord; bb : cpBB);
var hand : pcpHandle;
begin
   hand := pcpHandle(cpHashSetInsert(hash.handleSet, id, obj, nil));
   cphashHandle(hash, hand, bb);
end;

// Remove an object from the hash.
procedure cpSpaceHashRemove( hash : PcpSpaceHash; obj : pointer; id : LongWord);
var hand :pcpHandle;
begin
   hand := pcpHandle(cpHashSetRemove(hash.handleSet, id, obj));
   hand.obj := nil;
   cpHandleRelease(hand);
end;

procedure cpEachHelper(elt:pointer; data:pointer);{$IFDEF INLINE}inline;{$ENDIF}
begin
   pcpeachPair(data).func(pcpHandle(elt).obj, pcpeachPair(data).data);
end;

procedure cpSpaceHashEach( hash : PcpSpaceHash; func : TcpSpaceHashIterator; data : pointer);
var pair : cpeachPair;
begin
   // Bundle the callback up to send to the hashset iterator.
   pair.func:=func;
   pair.data:=data;
   cpHashSetEach(hash.handleSet, cpeachHelper, @pair);
end;

procedure cpHandleRehashHelper(elt:pointer;data:pointer);
var hand :pcpHandle;
    hash:pcpSpaceHash;
begin
   hand := pcpHandle(elt);
   hash := pcpSpaceHash(data);
   cphashHandle(hash, hand, hash.bbfunc(hand.obj));
end;

// Rehash the contents of the hash.
procedure cpSpaceHashRehash( hash : PcpSpaceHash);
begin
   cpClearHash(hash);
   // Rehash all of the handles.
   cpHashSetEach(hash.handleSet, cphandleRehashHelper, hash);
end;

// Rehash only a specific object.
procedure cpSpaceHashRehashObject( hash : PcpSpaceHash; obj : pointer; id : LongWord);
var hand :pcpHandle;
begin
   hand := pcpHandle(cpHashSetFind(hash.handleSet, id, obj));
   cphashHandle(hash, hand, hash.bbfunc(obj));
end;

procedure cpSpaceHashQueryHelper(hash:pcpSpaceHash; bin:pcpSpaceHashBin; obj:pointer; func:TcpSpaceHashQueryFunc; data:pointer); {$IFDEF INLINE}inline;{$ENDIF}
var hand :pcpHandle;
    other :pointer;
begin
   while assigned(bin) do begin
      hand := bin.handle;
      other := hand.obj;

      // Skip over certain conditions
      if(
      // Have we already tried this pair in this query?
      (hand.stamp = hash.stamp)
      // Is obj the same as other?
      or (obj = other)
      // Has other been removed since the last rehash?
      or (not assigned(other))
      ) then begin
         bin := bin.next;
         continue;
      end;

      func(obj, other, data);

      // Stamp that the handle was checked already against this object.
      hand.stamp := hash.stamp;
      bin := bin.next;
   end;
end;

// Query the hash for a given BBox.
procedure cpSpaceHashQuery( hash : PcpSpaceHash; obj : pointer; bb : cpBB; func : TcpSpaceHashQueryFunc; data : pointer);
var dim:cpFloat;
    index,l,r,b,t,n,i,j : integer;
begin
   // Get the dimensions in cell coordinates.
   dim := hash.celldim;
   l := trunc(bb.l/dim);
   r := trunc(bb.r/dim);
   b := trunc(bb.b/dim);
   t := trunc(bb.t/dim);

   n := hash.numcells;

   // Iterate over the cells and query them.
   for i:=l to r do begin
      for j:=b to t do begin
         index := cphash_func(i,j,n);
         cpSpaceHashQueryHelper(hash, hash.table[index], obj, func, data);
      end;
   end;
   // Increment the stamp.
   inc(hash.stamp);
end;

// Hashset iterator func used with cpSpaceHashQueryRehash().

procedure cpHandleQueryRehashHelper(elt:pointer;data:pointer);
var hand :pcpHandle;
    index,n,l,r,b,t,i,j : integer;
    obj : pointer;
    bb : cpBB;
    pair : pcpqueryRehashPair;
    hash : pcpSpaceHash;
    func : TcpSpaceHashQueryFunc;
    bin,newBin:pcpSpaceHashBin;
    dim : cpFloat;
begin
   hand := pcpHandle(elt);

   // Unpack the user callback data.
   pair := pcpqueryRehashPair(data);
   hash := pair.hash;
   func := pair.func;

   dim := hash.celldim;
   n := hash.numcells;

   obj := hand.obj;
   bb := hash.bbfunc(obj);

   l := trunc(bb.l/dim);
   r := trunc(bb.r/dim);
   b := trunc(bb.b/dim);
   t := trunc(bb.t/dim);

   for i:=l to r do begin
      for j:=b to t do begin
         index := cphash_func(i,j,n);
         bin := hash.table[index];

         if(cpcontainsHandle(bin, hand)<>0) then continue;
         cpSpaceHashQueryHelper(hash, bin, obj, func, pair.data);

         cpHandleRetain(hand);
         newBin := getEmptyBin(hash);
         newBin.handle := hand;
         newBin.next := bin;
         hash.table[index] := newBin;
      end;
   end;

   // Increment the stamp for each object we hash.
   inc(hash.stamp);
end;


procedure cpSpaceHashQueryRehash( hash : PcpSpaceHash; func : TcpSpaceHashQueryFunc; data : pointer);
var pair : cpqueryRehashPair;
begin
   cpclearHash(hash);

   pair.hash := hash;
   pair.func := func;
   pair.data := data;

   cpHashSetEach(hash.handleSet, cpHandleQueryRehashHelper, @pair);
end;

// *****************************************************************************************************************************
//
//  Shape functions
//
// *****************************************************************************************************************************

procedure cpResetShapeIdCounter;
begin
   SHAPE_ID_COUNTER:=0;
end;

function  cpShapeInit( const shape : PcpShape; const cptype : cpShapeType; const body : PcpBody) : PcpShape;
begin
   inc(NumShapes);

   shape.cptype := cptype;

   shape.id := SHAPE_ID_COUNTER;
   inc(SHAPE_ID_COUNTER);

   assert(assigned(body));
   shape.body := body;
   shape.is_static:=(body.m=INFINITY) and (body.i=INFINITY);

   shape.e := 0.0;
   shape.u := 0.0;
   shape.surface_v := cpvzero;

   shape.collision_type := 0;
   shape.group := 0;
   shape.layers := $FFFF;

   shape.data := nil;

   cpShapeCacheBB(shape);

   result:=shape;
end;

procedure cpShapeDestroy( const shape : PcpShape);
begin
   if assigned(shape.destroy) then shape.destroy(shape);
end;

procedure cpShapeFree( const shape : PcpShape);
begin
   if assigned(shape) then cpShapeDestroy(shape);
   cfree(shape);
   dec(NumShapes);
end;

function bbFromCircle(const c:cpVect;const r:cpFloat ) :cpBB; {$IFDEF INLINE}inline;{$ENDIF}
begin
   result:=cpBBNew(c.x-r, c.y-r, c.x+r, c.y+r);
end;

function cpShapeCacheBB( const shape : PcpShape) : cpBB;
begin
   shape.bb:=shape.cacheData(shape, shape.body.p, shape.body.rot);
   result:=shape.bb;
end;

function cpCircleShapeAlloc : PcpCircleShape;
begin
   result:=calloc(sizeof(result^));
end;

function cpCircleShapeCacheData(shape : PcpShape; const p : cpVect; const rot : cpVect):cpBB;
var circle : pcpCircleShape;
begin
   circle := pcpCircleShape(shape);
   circle.tc := cpvadd(p, cpvrotate(circle.c, rot));
   result:=bbFromCircle(circle.tc, circle.r);
end;

function cpCircleShapeInit( const circle : PcpCircleShape; const body : PcpBody; const radius : cpFloat; const offset : cpVect) : PcpCircleShape;
begin
   circle.c := offset;
   circle.r := radius;

   circle.shape.cacheData := cpCircleShapeCacheData;
   circle.shape.destroy:=nil;

   result:=PcpCircleShape(cpShapeInit(pcpShape(circle), CP_CIRCLE_SHAPE, body));
end;

function cpCircleShapeNew( const body : PcpBody; const radius : cpFloat; const offset : cpVect) : PcpShape;
begin
   result:=PcpShape(cpCircleShapeInit(cpCircleShapeAlloc,body,radius,offset));
end;

function cpSegmentShapeCacheData(shape:pcpShape; const p:cpVect; const rot:cpVect):cpBB;
var seg : pcpSegmentShape;
    rad,l,r,s,t :cpFloat;
begin
   seg := pcpSegmentShape(shape);

   seg.ta := cpvadd(p, cpvrotate(seg.a, rot));
   seg.tb := cpvadd(p, cpvrotate(seg.b, rot));
   seg.tn := cpvrotate(seg.n, rot);

   if(seg.ta.x < seg.tb.x) then begin
      l := seg.ta.x;
      r := seg.tb.x;
   end else begin
      l := seg.tb.x;
      r := seg.ta.x;
   end;

   if(seg.ta.y < seg.tb.y) then begin
      s := seg.ta.y;
      t := seg.tb.y;
   end else begin
      s := seg.tb.y;
      t := seg.ta.y;
   end;

   rad := seg.r;
   result:=cpBBNew(l - rad, s - rad, r + rad, t + rad);
end;

function cpSegmentShapeAlloc : PcpSegmentShape;
begin
   result:=calloc(sizeof(result^));
end;

function cpSegmentShapeInit( const seg : PcpSegmentShape; const body : PcpBody; const a : cpVect; const b : cpVect; const r : cpFloat) : PcpSegmentShape;
begin
   seg.a := a;
   seg.b := b;
   seg.n := cpvperp(cpvnormalize(cpvsub(b, a)));

   seg.r := r;

   seg.shape.cacheData := cpSegmentShapeCacheData;
   cpShapeInit(pcpShape(seg), CP_SEGMENT_SHAPE, body);
   seg.shape.destroy:=nil;

   result:=seg;
end;

function cpSegmentShapeNew( const body : PcpBody; const a : cpVect; const b : cpVect; const r : cpFloat) : PcpShape;
begin
   result:=PcpShape(cpSegmentShapeInit(cpSegmentShapeAlloc,body,a,b,r));
end;

procedure cpPolyShapeTransformAxes(poly:pcpPolyShape; p:cpVect; rot:cpVect);
var src,dst:pcpPolyShapeAxisArray;
    n:cpVect;
    i : integer;
begin
   src := poly.axes;
   dst := poly.tAxes;
   for i:=0 to poly.numVerts-1 do begin
      n := cpvrotate(src[i].n, rot);
      dst[i].n := n;
      dst[i].d := cpvdot(p, n) + src[i].d;
   end;
end;

procedure cpPolyShapeTransformVerts(poly:pcpPolyShape; const p:cpVect; const rot:cpVect);
var src,dst:PcpVectArray;
    i : integer;
begin
   src := poly.verts;
   dst := poly.tverts;
   for i:=0 to poly.numVerts-1 do
      dst[i] := cpvadd(p, cpvrotate(src[i], rot));
end;

function cpPolyShapeCacheData(shape:pcpShape; const p:cpVect; const rot:cpVect) :cpBB;
var v:cpVect;
    poly :pcpPolyShape;
    l, b, r, t :cpFloat;
    verts:PcpVectArray;
    i : integer;
begin
   poly := pcpPolyShape(shape);

   cpPolyShapeTransformAxes(poly, p, rot);
   cpPolyShapeTransformVerts(poly, p, rot);

   verts := poly.tVerts;
   r := verts[0].x;
   l :=r;
   t := verts[0].y;
   b := t;

   for i:=1 to poly.numVerts-1 do begin
      v := verts[i];

      l := cpfmin(l, v.x);
      r := cpfmax(r, v.x);

      b := cpfmin(b, v.y);
      t := cpfmax(t, v.y);
   end;

   result:=cpBBNew(l, b, r, t);
end;

procedure cpPolyShapeDestroy(shape:pcpShape);
var poly:pcpPolyShape;
begin
   poly := pcpPolyShape(shape);

   cfree(poly.verts);
   cfree(poly.tVerts);

   cfree(poly.axes);
   cfree(poly.tAxes);
end;

function  cpPolyShapeAlloc : PcpPolyShape;
begin
   result:=calloc(sizeof(result^));
end;

function cpIsPolyConvex(verts : pcpVectArray; numVerts : integer) : boolean;
var vi,vj : cpvect;
    n : cpFloat;
    i,j : integer;
begin
   result:=False;
   if NumVerts<3 then exit;

   vi := cpvsub(verts[1],verts[0]);
   for i:= 1 to NumVerts-1 do begin
      j  := (i+1) mod NumVerts;
      vj := cpvsub(verts[j],verts[i]);
      n:=cpvcross(vi,vj);

      if (n > 0.0) then exit;
      vi:=vj;
   end;
   result:=True;
end;

function cpPolyShapeInit( poly : PcpPolyShape; body : PcpBody; numVerts : integer; verts : PcpVectArray; const offset : cpVect; assumeConvex : boolean = true) : PcpPolyShape;
var i : integer;
    a,b,n : cpVect;
begin
   poly.numVerts := numVerts;

   poly.verts := calloc(numVerts,sizeof(cpVect));
   poly.tVerts:= calloc(numVerts,sizeof(cpVect));
   poly.axes  := calloc(numVerts,sizeof(cpPolyShapeAxis));
   poly.tAxes := calloc(numVerts,sizeof(cpPolyShapeAxis));

   for i:=0 to numVerts-1 do begin
      a := cpvadd(offset, verts[i]);
      b := cpvadd(offset, verts[(i+1) mod numVerts]);
      n := cpvnormalize(cpvperp(cpvsub(b, a)));

      poly.verts[i] := a;
      poly.axes[i].n := n;
      poly.axes[i].d := cpvdot(n, a);
   end;

   if assumeConvex then poly.convex:=true else poly.convex :=cpIsPolyConvex(poly.verts,poly.numVerts);

   poly.shape.cacheData := cpPolyShapeCacheData;
   poly.shape.destroy := cpPolyShapeDestroy;
   cpShapeInit(pcpShape(poly), CP_POLY_SHAPE, body);
   result:=poly;
end;

function  cpPolyShapeNew( body : PcpBody; numVerts : integer; verts : PcpVectArray; const offset : cpVect) : PcpShape;
begin
   result:=PcpShape(cpPolyShapeInit(cpPolyShapeAlloc,body,numVerts,verts,offset));
end;

function cpPolyShapeValueOnAxis( const poly : PcpPolyShape; const n : cpVect; const d : cpFloat) : cpFloat;
var verts : PcpVectArray;
    min:cpFloat;
    i : integer;
begin
   verts := poly.tVerts;
   min := cpvdot(n, verts[0]);
   for i:=1 to poly.numVerts-1 do
      min := cpfmin(min, cpvdot(n, verts[i]));
   result:=min - d;
end;

function cpPolyShapeContainsVert( const poly : PcpPolyShape; const v : cpVect) : integer;
var axes:pcpPolyShapeAxisArray;
    i : integer;
    dist:cpFloat;
begin
   result:=0;
   axes := poly.tAxes;

   for i:=0 to poly.numVerts-1 do begin
      dist := cpvdot(axes[i].n, v) - axes[i].d;
      if(dist > 0.0) then exit;
   end;

   result:=1;
end;

// *****************************************************************************************************************************
//
//  Arbiter functions
//
// *****************************************************************************************************************************

function cpContactInit( con : PcpContact; const p : cpVect; const n : cpVect; const dist : cpFloat; const hash : LongWord ) : PcpContact;
begin
   con.p := p;
   con.n := n;
   con.dist := dist;

   con.jnAcc := 0.0;
   con.jtAcc := 0.0;
   con.jBias := 0.0;

   con.hash := hash;

   result:=con;
end;

function cpContactsSumImpulses( contacts : PcpContactArray; const numContacts :integer) : cpVect;
var i : integer;
    j:cpVect;
begin
   result := cpvzero;
   for i:=0 to numContacts-1 do begin
      j := cpvmult(contacts[i].n, contacts[i].jnAcc);
      result := cpvadd(result, j);
   end;
end;

function cpContactsSumImpulsesWithFriction( contacts : PcpContactArray; const numContacts :integer) : cpVect;
var i : integer;
    j,t:cpVect;
begin
   result := cpvzero;
   for i:=0 to numContacts-1 do begin
      t := cpvperp(contacts[i].n);
      j := cpvadd(cpvmult(contacts[i].n, contacts[i].jnAcc), cpvmult(t, contacts[i].jtAcc));
      result := cpvadd(result, j);
   end;
end;

function cpArbiterAlloc : PcpArbiter;
begin
   result:=calloc(sizeof(result^));
end;

function cpArbiterInit( arb : PcpArbiter; a : PcpShape; b : PcpShape; stamp :integer) : PcpArbiter;
begin
   inc(NumArbiters);
   arb.numContacts := 0;
   arb.contacts := nil;

   arb.a := a;
   arb.b := b;

   arb.stamp := stamp;

   result:=arb;
end;

function cpArbiterNew( a : PcpShape; b : PcpShape; stamp :integer) : PcpArbiter;
begin
   result:=cpArbiterInit(cpArbiterAlloc,a,b,stamp);
end;
procedure cpArbiterDestroy( arb : PcpArbiter );
begin
   cfree(arb.contacts);
end;
procedure cpArbiterFree( arb : PcpArbiter );
begin
   dec(NumArbiters);
   if assigned(arb) then cpArbiterDestroy(Arb);
   cfree(arb);
end;

procedure cpFreeArbiters( space : pcpspace);
begin
   cpHashSetReject(space.contactSet, cpContactSetReject, space);
end;

procedure cpArbiterInject( arb : PcpArbiter; var contacts : PcpContactArray; const numContacts :integer);
var i,j : integer;
    new_contact,old : pcpContact;
begin
// Iterate over the possible pairs to look for hash value matches.
   for i:=0 to arb.numContacts-1 do begin
      old := @arb.contacts[i];
      for j:=0 to numContacts - 1 do begin
         new_contact := @contacts[j];
// This could trigger false possitives.
         if(new_contact.hash = old.hash) then begin
// Copy the persistant contact information.
	          new_contact.jnAcc := old.jnAcc;
	          new_contact.jtAcc := old.jtAcc;
         end;
      end;
   end;

   cfree(arb.contacts);

   arb.contacts := contacts;
   arb.numContacts := numContacts;
end;

procedure cpArbiterPreStep( arb : PcpArbiter; const dt_inv : cpFloat );
var shapea,shapeb : pcpShape;
    a,b : pcpBody;
    i : integer;
    j,t,v1,v2:cpVect;
    con : pcpContact;
    kt,r1ct,r2ct,kn,r2cn,r1cn,mass_sum:cpFloat;
begin
   shapea := arb.a;
   shapeb := arb.b;

   arb.e := shapea.e * shapeb.e;
   arb.u := shapea.u * shapeb.u;
   arb.target_v := cpvsub(shapeb.surface_v, shapea.surface_v);

   a := shapea.body;
   b := shapeb.body;

   for i:=0 to arb.numContacts-1 do begin
      con := @arb.contacts[i];

     // Calculate the offsets.
     con.r1 := cpvsub(con.p, a.p);
     con.r2 := cpvsub(con.p, b.p);

     // Calculate the mass normal.
     mass_sum := a.m_inv + b.m_inv;

     r1cn := cpvcross(con.r1, con.n);
     r2cn := cpvcross(con.r2, con.n);
     kn := mass_sum + a.i_inv*r1cn*r1cn + b.i_inv*r2cn*r2cn;
     con.nMass := 1.0/kn;

     // Calculate the mass tangent.
     t := cpvperp(con.n);
     r1ct := cpvcross(con.r1, t);
     r2ct := cpvcross(con.r2, t);
     kt := mass_sum + a.i_inv*r1ct*r1ct + b.i_inv*r2ct*r2ct;
     con.tMass := 1.0/kt;

     // Calculate the target bias velocity.
     con.bias := -cp_bias_coef*dt_inv*cpfmin(0.0, con.dist + cp_collision_slop);
     con.jBias := 0.0;

     // Calculate the target bounce velocity.
     v1 := cpvadd(a.v, cpvmult(cpvperp(con.r1), a.w));
     v2 := cpvadd(b.v, cpvmult(cpvperp(con.r2), b.w));
     con.bounce := cpvdot(con.n, cpvsub(v2, v1))*arb.e;

      // Apply the previous accumulated impulse.
      j := cpvadd(cpvmult(con.n, con.jnAcc), cpvmult(t, con.jtAcc));
      cpBodyApplyImpulse(a, cpvneg(j), con.r1);
      cpBodyApplyImpulse(b, j, con.r2);
   end;
end;

procedure cpArbiterApplyImpulse( arb : PcpArbiter );
var a,b : pcpbody;
    i : integer;
    con : pcpContact;
    j,t,v1,v2,vr,vb1,vb2,n,r1,r2,jb:cpVect;
    jt,jtMax,jtOld,vrt,jn,jnOld,vrn,jbn,jbnOld,vbn:cpFloat;
begin
   a := arb.a.body;
   b := arb.b.body;
   for i:=0 to arb.numContacts-1 do begin
      con := @arb.contacts[i];
      n := con.n;
      r1 := con.r1;
      r2 := con.r2;

      // Calculate the relative bias velocities.
      vb1 := cpvadd(a.v_bias, cpvmult(cpvperp(r1), a.w_bias));
      vb2 := cpvadd(b.v_bias, cpvmult(cpvperp(r2), b.w_bias));
      vbn := cpvdot(cpvsub(vb2, vb1), n);

      // Calculate and clamp the bias impulse.
      jbn := (con.bias - vbn)*con.nMass;
      jbnOld := con.jBias;
      con.jBias := cpfmax(jbnOld + jbn, 0.0);
      jbn := con.jBias - jbnOld;

      // Apply the bias impulse.
      jb := cpvmult(n, jbn);
      cpBodyApplyBiasImpulse(a, cpvneg(jb), r1);
      cpBodyApplyBiasImpulse(b, jb, r2);

      // Calculate the relative velocity.
      v1 := cpvadd(a.v, cpvmult(cpvperp(r1), a.w));
      v2 := cpvadd(b.v, cpvmult(cpvperp(r2), b.w));
      vr := cpvsub(v2, v1);
      vrn := cpvdot(vr, n);

      // Calculate and clamp the normal impulse.
      jn := -(con.bounce + vrn)*con.nMass;
      jnOld := con.jnAcc;
      con.jnAcc := cpfmax(jnOld + jn, 0.0);
      jn := con.jnAcc - jnOld;

      // Calculate the relative tangent velocity.
      t := cpvperp(n);
      vrt := cpvdot(cpvadd(vr, arb.target_v), t);

      // Calculate and clamp the friction impulse.
      jtMax := arb.u*con.jnAcc;
      jt := -vrt*con.tMass;
      jtOld := con.jtAcc;
      con.jtAcc := cpfmin(cpfmax(jtOld + jt, -jtMax), jtMax);
      jt := con.jtAcc - jtOld;

      // Apply the final impulse.
      j := cpvadd(cpvmult(n, jn), cpvmult(t, jt));
      cpBodyApplyImpulse(a, cpvneg(j), r1);
      cpBodyApplyImpulse(b, j, r2);
   end;
end;

// *****************************************************************************************************************************
//
// Collision functions
//
// *****************************************************************************************************************************

// *****************************************************************************************************************************
//
// Joint functions
//
// *****************************************************************************************************************************

procedure cpJointDestroy( joint : PcpJoint);
begin
end;

procedure  cpJointFree( joint : PcpJoint);
begin
   if assigned(joint) then cpJointDestroy( joint );
   cfree(joint);
end;

function  cpPinJointAlloc : PcpPinJoint;
begin
   result:=calloc(sizeof(result^));
end;

procedure pinJointPreStep(joint:pcpJoint; const dt_inv:cpFloat);
var a,b : pcpbody;
   jnt:pcpPinJoint;
   kn,r1cn,r2cn,dist,mass_sum:cpFloat;
   j,delta:cpVect;
begin
   a := joint.a;
   b := joint.b;
   jnt := pcpPinJoint(joint);

   mass_sum := a.m_inv + b.m_inv;

   jnt.r1 := cpvrotate(jnt.anchr1, a.rot);
   jnt.r2 := cpvrotate(jnt.anchr2, b.rot);

   delta := cpvsub(cpvadd(b.p, jnt.r2), cpvadd(a.p, jnt.r1));
   dist := cpvlength(delta);
   if dist<>0 then jnt.n := cpvmult(delta, 1.0/dist)
      else jnt.n := cpvmult(delta, 1.0/INFINITY);


   // calculate mass normal
   r1cn := cpvcross(jnt.r1, jnt.n);
   r2cn := cpvcross(jnt.r2, jnt.n);
   kn := mass_sum + a.i_inv*r1cn*r1cn + b.i_inv*r2cn*r2cn;
   jnt.nMass := 1.0/kn;

   // calculate bias velocity
   jnt.bias := -cp_joint_bias_coef*dt_inv*(dist - jnt.dist);
   jnt.jBias := 0.0;

   // apply accumulated impulse
   j := cpvmult(jnt.n, jnt.jnAcc);
   cpBodyApplyImpulse(a, cpvneg(j), jnt.r1);
   cpBodyApplyImpulse(b, j, jnt.r2);
end;

procedure pinJointApplyImpulse(joint:pcpJoint);
var a,b:pcpBody;
    jnt:pcpPinJoint;
    j,v1,v2,jb,vb1,vb2,n,r1,r2:cpVect;
    jn,vrn,jbn,vbn : cpFloat;
begin
   a := joint.a;
   b := joint.b;
   if (a.sleeping and b.sleeping) then
    exit;

   jnt := pcpPinJoint(joint);
   n := jnt.n;
   r1 := jnt.r1;
   r2 := jnt.r2;

   //calculate bias impulse
   vb1 := cpvadd(a.v_bias, cpvmult(cpvperp(r1), a.w_bias));
   vb2 := cpvadd(b.v_bias, cpvmult(cpvperp(r2), b.w_bias));
   vbn := cpvdot(cpvsub(vb2, vb1), n);

   jbn := (jnt.bias - vbn)*jnt.nMass;
   jnt.jBias := jnt.jBias + jbn;

   jb := cpvmult(n, jbn);
   cpBodyApplyBiasImpulse(a, cpvneg(jb), r1);
   cpBodyApplyBiasImpulse(b, jb, r2);

   // compute relative velocity
   v1 := cpvadd(a.v, cpvmult(cpvperp(r1), a.w));
   v2 := cpvadd(b.v, cpvmult(cpvperp(r2), b.w));
   vrn := cpvdot(cpvsub(v2, v1), n);

   // compute normal impulse
   jn := -vrn*jnt.nMass;
   jnt.jnAcc :=+ jn;

   // apply impulse
   j := cpvmult(n, jn);
   cpBodyApplyImpulse(a, cpvneg(j), r1);
   cpBodyApplyImpulse(b, j, r2);
end;

function cpPinJointReInit( joint : PcpPinJoint; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect) : PcpPinJoint;
begin
   fillchar(joint^,sizeof(joint^),0);
   result:=cpPinJointInit(joint,a,b,anchr1,anchr2);
end;

function cpPinJointInit( joint : PcpPinJoint; a : PcpBody; b : PcpBody; const anchr1 : cpVect; const anchr2 : cpVect) : PcpPinJoint;
var p1,p2:cpVect;
begin
   joint.joint.cptype := CP_PIN_JOINT;
   joint.joint.preStep := pinJointPreStep;
   joint.joint.applyImpulse := pinJointApplyImpulse;

   joint.joint.a := a;
   joint.joint.b := b;

   joint.anchr1 := anchr1;
   joint.anchr2 := anchr2;

   p1 := cpvadd(a.p, cpvrotate(anchr1, a.rot));
   p2 := cpvadd(b.p, cpvrotate(anchr2, b.rot));
   joint.dist := cpvlength(cpvsub(p2, p1));

   joint.jnAcc := 0.0;

   result:=joint;
end;

function cpPinJointNew( a : PcpBody; b : PcpBody; const anchr1 : cpVect; const anchr2 : cpVect) : PcpJoint;
begin
   result:=PcpJoint(cpPinJointInit(cpPinJointAlloc,a,b,anchr1,anchr2));
end;

function cpSlideJointAlloc : PcpSlideJoint;
begin
   result:=calloc(sizeof(result^));
end;

procedure SlideJointPreStep(joint:pcpJoint; const dt_inv:cpFloat);
var a,b : pcpbody;
   jnt:pcpSlideJoint;
   pdist,kn,r1cn,r2cn,dist,mass_sum:cpFloat;
   j,delta:cpVect;
begin
   a := joint.a;
   b := joint.b;
   jnt := pcpSlideJoint(joint);

   mass_sum := a.m_inv + b.m_inv;

   jnt.r1 := cpvrotate(jnt.anchr1, a.rot);
   jnt.r2 := cpvrotate(jnt.anchr2, b.rot);

   delta := cpvsub(cpvadd(b.p, jnt.r2), cpvadd(a.p, jnt.r1));
   dist := cpvlength(delta);
   pdist := 0.0;
   if(dist > jnt.max) then  begin
      pdist := dist - jnt.max;
   end else if(dist < jnt.min) then begin
      pdist := jnt.min - dist;
      dist := -dist;
   end;
   if dist<>0 then jnt.n := cpvmult(delta, 1.0/dist)
      else jnt.n := cpvmult(delta, 1.0/INFINITY);

   // calculate mass normal
   r1cn := cpvcross(jnt.r1, jnt.n);
   r2cn := cpvcross(jnt.r2, jnt.n);
   kn := mass_sum + a.i_inv*r1cn*r1cn + b.i_inv*r2cn*r2cn;
   jnt.nMass := 1.0/kn;

   // calculate bias velocity
   jnt.bias := -cp_joint_bias_coef*dt_inv*pdist;
   jnt.jBias := 0.0;

   // apply accumulated impulse
   if(jnt.bias=0) then jnt.jnAcc := 0.0;
   j := cpvmult(jnt.n, jnt.jnAcc);
   cpBodyApplyImpulse(a, cpvneg(j), jnt.r1);
   cpBodyApplyImpulse(b, j, jnt.r2);
end;

procedure SlideJointApplyImpulse(joint:pcpJoint);
var a,b:pcpBody;
    jnt:pcpSlideJoint;
    j,v1,v2,jb,vb1,vb2,n,r1,r2:cpVect;
    jnOld,jbnOld,jn,vrn,jbn,vbn : cpFloat;
begin
   jnt := pcpSlideJoint(joint);
   if (jnt.bias=0) then exit;

   a := joint.a;
   b := joint.b;

   n := jnt.n;
   r1 := jnt.r1;
   r2 := jnt.r2;

   //calculate bias impulse
   vb1 := cpvadd(a.v_bias, cpvmult(cpvperp(r1), a.w_bias));
   vb2 := cpvadd(b.v_bias, cpvmult(cpvperp(r2), b.w_bias));
   vbn := cpvdot(cpvsub(vb2, vb1), n);

   jbn := (jnt.bias - vbn)*jnt.nMass;
   jbnOld := jnt.jBias;
   jnt.jBias := cpfmin(jbnOld + jbn, 0.0);
   jbn := jnt.jBias - jbnOld;

   jb := cpvmult(n, jbn);
   cpBodyApplyBiasImpulse(a, cpvneg(jb), r1);
   cpBodyApplyBiasImpulse(b, jb, r2);

   // compute relative velocity
   v1 := cpvadd(a.v, cpvmult(cpvperp(r1), a.w));
   v2 := cpvadd(b.v, cpvmult(cpvperp(r2), b.w));
   vrn := cpvdot(cpvsub(v2, v1), n);

   // compute normal impulse
   jn := -vrn*jnt.nMass;
   jnOld := jnt.jnAcc;
   jnt.jnAcc := cpfmin(jnOld + jn, 0.0);
   jn := jnt.jnAcc - jnOld;

   // apply impulse
   j := cpvmult(n, jn);
   cpBodyApplyImpulse(a, cpvneg(j), r1);
   cpBodyApplyImpulse(b, j, r2);
end;

function cpSlideJointReInit( joint : PcpSlideJoint; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; min : cpFloat; max : cpFloat) : PcpSlideJoint;
begin
   fillchar(joint^,sizeof(joint^),0);
   result:=cpSlideJointInit(joint,a,b,anchr1,anchr2,min,max);
end;

function cpSlideJointInit( joint : PcpSlideJoint; a : PcpBody; b : PcpBody; const anchr1 : cpVect; const anchr2 : cpVect; const min : cpFloat; const max : cpFloat) : PcpSlideJoint;
begin
   joint.joint.cptype := CP_SLIDE_JOINT;
   joint.joint.preStep := SlideJointPreStep;
   joint.joint.applyImpulse := SlideJointApplyImpulse;

   joint.joint.a := a;
   joint.joint.b := b;

   joint.anchr1 := anchr1;
   joint.anchr2 := anchr2;
   joint.min := min;
   joint.max := max;

   joint.jnAcc := 0.0;

   result := joint;
end;

function cpSlideJointNew( a : PcpBody; b : PcpBody; const anchr1 : cpVect; const anchr2 : cpVect; const min : cpFloat; const max : cpFloat) : PcpJoint;
begin
   result:=PcpJoint(cpSlideJointInit(cpSlideJointAlloc,a,b,anchr1,anchr2,min,max));
end;

function  cpPivotJointAlloc : PcpPivotJoint;
begin
   result:=calloc(sizeof(result^));
end;

procedure pivotJointPreStep(joint:pcpJoint; const dt_inv:cpFloat);
var a,b : pcpbody;
   jnt:pcpPivotJoint;
   r2xsq,r2ysq,r2nxy,r1xsq,r1ysq,r1nxy,det_inv,k11,k12,k21,k22,m_sum:cpFloat;
   delta:cpVect;
begin
   a := joint.a;
   b := joint.b;
   if (a.sleeping and b.sleeping) then
    exit;
   jnt := pcpPivotJoint(joint);

   jnt.r1 := cpvrotate(jnt.anchr1, a.rot);
   jnt.r2 := cpvrotate(jnt.anchr2, b.rot);

   // calculate mass matrix
   // If I wasn't lazy, this wouldn't be so gross...

   m_sum := a.m_inv + b.m_inv;
   k11 := m_sum; k12 := 0.0;
   k21 := 0.0;  k22 := m_sum;

   r1xsq :=  jnt.r1.x * jnt.r1.x * a.i_inv;
   r1ysq :=  jnt.r1.y * jnt.r1.y * a.i_inv;
   r1nxy := -jnt.r1.x * jnt.r1.y * a.i_inv;
   k11 := k11 + r1ysq; k12 := k12 + r1nxy;
   k21 := k21 + r1nxy; k22 := k22 + r1xsq;

   r2xsq :=  jnt.r2.x * jnt.r2.x * b.i_inv;
   r2ysq :=  jnt.r2.y * jnt.r2.y * b.i_inv;
   r2nxy := -jnt.r2.x * jnt.r2.y * b.i_inv;
   k11 := k11 + r2ysq; k12 := k12 + r2nxy;
   k21 := k21 + r2nxy; k22 := k22 + r2xsq;

   det_inv := 1.0/(k11*k22 - k12*k21);
   jnt.k1 := cpv( k22*det_inv, -k12*det_inv);
   jnt.k2 := cpv(-k21*det_inv,  k11*det_inv);

   // calculate bias velocity
   delta := cpvsub(cpvadd(b.p, jnt.r2), cpvadd(a.p, jnt.r1));
   jnt.bias := cpvmult(delta, -cp_joint_bias_coef*dt_inv);
   jnt.jBias := cpvzero;

   // apply accumulated impulse
   cpBodyApplyImpulse(a, cpvneg(jnt.jAcc), jnt.r1);
   cpBodyApplyImpulse(b, jnt.jAcc, jnt.r2);
end;

procedure pivotJointApplyImpulse(joint:pcpJoint);
var a,b:pcpBody;
    jnt:pcpPivotJoint;
    vr,k1,k2,j,v1,v2,jb,vb1,vb2,vbr,r1,r2:cpVect;
begin
   a := joint.a;
   b := joint.b;
   if (a.sleeping and b.sleeping) then
    exit;

   jnt := pcpPivotJoint(joint);
   r1 := jnt.r1;
   r2 := jnt.r2;
   k1 := jnt.k1;
   k2 := jnt.k2;

   //calculate bias impulse
   vb1 := cpvadd(a.v_bias, cpvmult(cpvperp(r1), a.w_bias));
   vb2 := cpvadd(b.v_bias, cpvmult(cpvperp(r2), b.w_bias));
   vbr := cpvsub(jnt.bias, cpvsub(vb2, vb1));

   jb := cpv(cpvdot(vbr, k1), cpvdot(vbr, k2));
   jnt.jBias := cpvadd(jnt.jBias, jb);

   cpBodyApplyBiasImpulse(a, cpvneg(jb), r1);
   cpBodyApplyBiasImpulse(b, jb, r2);

   // compute relative velocity
   v1 := cpvadd(a.v, cpvmult(cpvperp(r1), a.w));
   v2 := cpvadd(b.v, cpvmult(cpvperp(r2), b.w));
   vr := cpvsub(v2, v1);

   // compute normal impulse
   j := cpv(-cpvdot(vr, k1), -cpvdot(vr, k2));
   jnt.jAcc := cpvadd(jnt.jAcc, j);

   // apply impulse
   cpBodyApplyImpulse(a, cpvneg(j), r1);
   cpBodyApplyImpulse(b, j, r2);
end;

function cpPivotJointReInit( joint : PcpPivotJoint; a : PcpBody; b : PcpBody; pivot : cpVect) : PcpPivotJoint;
begin
   fillchar(joint^,sizeof(Joint^),0);
   result:=cpPivotJointInit(joint,a,b,pivot);
end;

function cpPivotJointInit( joint : PcpPivotJoint; a : PcpBody; b : PcpBody; const pivot : cpVect) : PcpPivotJoint;
begin
   joint.joint.cptype := CP_PIVOT_JOINT;
   joint.joint.preStep := pivotJointPreStep;
   joint.joint.applyImpulse := pivotJointApplyImpulse;

   joint.joint.a := a;
   joint.joint.b := b;
   joint.joint.tisJoint := nil;

   joint.anchr1 := cpvunrotate(cpvsub(pivot, a.p), a.rot);
   joint.anchr2 := cpvunrotate(cpvsub(pivot, b.p), b.rot);

   joint.jAcc := cpvzero;

   result := joint;
end;

function cpPivotJointNew( a : PcpBody; b : PcpBody; const pivot : cpVect) : PcpJoint;
begin
   result:=PcpJoint(cpPivotJointInit(cpPivotJointAlloc,a,b,pivot))
end;

function  cpGrooveJointAlloc : PcpGrooveJoint;
begin
   result:=calloc(sizeof(result^));
end;

procedure grooveJointPreStep(joint:pcpJoint; const dt_inv:cpFloat);
var a,b : pcpbody;
   jnt:pcpGrooveJoint;
   td,d,r2xsq,r2ysq,r2nxy,r1xsq,r1ysq,r1nxy,det_inv,k11,k12,k21,k22,m_sum:cpFloat;
   tb,ta,n,delta:cpVect;
begin
   a := joint.a;
   b := joint.b;
   jnt := pcpGrooveJoint(joint);

   // calculate endpoints in worldspace
   ta := cpBodyLocal2World(a, jnt.grv_a);
   tb := cpBodyLocal2World(a, jnt.grv_b);

   // calculate axis
   n := cpvrotate(jnt.grv_n, a.rot);
   d := cpvdot(ta, n);

   jnt.grv_tn := n;
   jnt.r2 := cpvrotate(jnt.anchr2, b.rot);

   // calculate tangential distance along the axis of r2
   td := cpvcross(cpvadd(b.p, jnt.r2), n);
   // calculate clamping factor and r2
   if(td < cpvcross(ta, n)) then begin
      jnt.clamp := 1.0;
      jnt.r1 := cpvsub(ta, a.p);
   end else if(td > cpvcross(tb, n)) then begin
      jnt.clamp := -1.0;
      jnt.r1 := cpvsub(tb, a.p);
   end else begin
      jnt.clamp := 0.0;
      jnt.r1 := cpvadd(cpvmult(cpvperp(n), -td), cpvmult(n, d));
   end;

   // calculate mass matrix
   // If I wasn't lazy and wrote a proper matrix class, this wouldn't be so gross...
   m_sum := a.m_inv + b.m_inv;

   // start with I*m_sum
   k11 := m_sum; k12 := 0.0;
   k21 := 0.0;  k22 := m_sum;

   // add the influence from r1
   r1xsq :=  jnt.r1.x * jnt.r1.x * a.i_inv;
   r1ysq :=  jnt.r1.y * jnt.r1.y * a.i_inv;
   r1nxy := -jnt.r1.x * jnt.r1.y * a.i_inv;
   k11 := k11 + r1ysq; k12 := k12 + r1nxy;
   k21 := k21 + r1nxy; k22 := k22 + r1xsq;

   // add the influnce from r2
   r2xsq :=  jnt.r2.x * jnt.r2.x * b.i_inv;
   r2ysq :=  jnt.r2.y * jnt.r2.y * b.i_inv;
   r2nxy := -jnt.r2.x * jnt.r2.y * b.i_inv;
   k11 := k11 + r2ysq; k12 := k12 + r2nxy;
   k21 := k21 + r2nxy; k22 := k22 + r2xsq;

   // invert
   det_inv := 1.0/(k11*k22 - k12*k21);
   jnt.k1 := cpv( k22*det_inv, -k12*det_inv);
   jnt.k2 := cpv(-k21*det_inv,  k11*det_inv);


   // calculate bias velocity
   delta := cpvsub(cpvadd(b.p, jnt.r2), cpvadd(a.p, jnt.r1));
   jnt.bias := cpvmult(delta, -cp_joint_bias_coef*dt_inv);
   jnt.jBias := cpvzero;

   // apply accumulated impulse
   cpBodyApplyImpulse(a, cpvneg(jnt.jAcc), jnt.r1);
   cpBodyApplyImpulse(b, jnt.jAcc, jnt.r2);
end;

function grooveConstrain(jnt:pcpGrooveJoint; const j:cpVect):cpVect; {$IFDEF INLINE}inline;{$ENDIF}
var jt,t,jn,n : cpVect;
    coef : cpFloat;
begin
   n := jnt.grv_tn;
   jn := cpvmult(n, cpvdot(j, n));

   t := cpvperp(n);
   if (jnt.clamp*cpvcross(j, n) > 0.0) then coef := 1.0 else coef := 0.0;
   jt := cpvmult(t, cpvdot(j, t)*coef);

   result:=cpvadd(jn, jt);
end;

procedure grooveJointApplyImpulse(joint:pcpJoint);
var a,b:pcpBody;
    jnt:pcpGrooveJoint;
    jOld,jbOld,vr,k1,k2,j,v1,v2,jb,vb1,vb2,vbr,r1,r2:cpVect;
begin
   a := joint.a;
   b := joint.b;

   jnt := pcpGrooveJoint(joint);
   r1 := jnt.r1;
   r2 := jnt.r2;
   k1 := jnt.k1;
   k2 := jnt.k2;

   //calculate bias impulse
   vb1 := cpvadd(a.v_bias, cpvmult(cpvperp(r1), a.w_bias));
   vb2 := cpvadd(b.v_bias, cpvmult(cpvperp(r2), b.w_bias));
   vbr := cpvsub(jnt.bias, cpvsub(vb2, vb1));

   jb := cpv(cpvdot(vbr, k1), cpvdot(vbr, k2));
   jbOld := jnt.jBias;
   jnt.jBias := grooveConstrain(jnt, cpvadd(jbOld, jb));
   jb := cpvsub(jnt.jBias, jbOld);

   cpBodyApplyBiasImpulse(a, cpvneg(jb), r1);
   cpBodyApplyBiasImpulse(b, jb, r2);

   // compute relative velocity
   v1 := cpvadd(a.v, cpvmult(cpvperp(r1), a.w));
   v2 := cpvadd(b.v, cpvmult(cpvperp(r2), b.w));
   vr := cpvsub(v2, v1);

   // compute impulse
   j := cpv(-cpvdot(vr, k1), -cpvdot(vr, k2));
   jOld := jnt.jAcc;
   jnt.jAcc := grooveConstrain(jnt, cpvadd(jOld, j));
   j := cpvsub(jnt.jAcc, jOld);

   // apply impulse
   cpBodyApplyImpulse(a, cpvneg(j), r1);
   cpBodyApplyImpulse(b, j, r2);
end;

function cpGrooveJointReInit( joint : PcpGrooveJoint; a : PcpBody; b : PcpBody; groove_a : cpVect; groove_b : cpVect; anchr2 : cpVect) : PcpGrooveJoint;
begin
   fillchar(joint^,sizeof(Joint^),0);
   result:=cpGrooveJointInit(joint,a,b,groove_a,groove_b,anchr2);
end;

function cpGrooveJointInit( joint : PcpGrooveJoint; a : PcpBody; b : PcpBody; const groove_a : cpVect; const groove_b : cpVect; const anchr2 : cpVect) : PcpGrooveJoint;
begin
   joint.joint.cptype := CP_GROOVE_JOINT;
   joint.joint.preStep := grooveJointPreStep;
   joint.joint.applyImpulse := grooveJointApplyImpulse;

   joint.joint.a := a;
   joint.joint.b := b;

   joint.grv_a := groove_a;
   joint.grv_b := groove_b;
   joint.grv_n := cpvperp(cpvnormalize(cpvsub(groove_b, groove_a)));
   joint.anchr2 := anchr2;

   joint.jAcc := cpvzero;

   result := joint;
end;

function cpGrooveJointNew( a : PcpBody; b : PcpBody; const groove_a : cpVect; const groove_b : cpVect; const anchr2 : cpVect) : PcpJoint;
begin
   result:=PcpJoint(cpGrooveJointInit(cpGrooveJointAlloc,a,b,groove_a,groove_b,anchr2));
end;

// *****************************************************************************************************************************
//
// Space functions
//
// *****************************************************************************************************************************

procedure freeWrap(ptr : pointer; unused : pointer);
begin
   cfree(ptr);
end;
procedure shapeFreeWrap(ptr : pointer; unused : pointer);
begin
   cpShapeFree(pcpShape(ptr));
end;
procedure arbiterFreeWrap(ptr : pointer; unused : pointer);
begin
   cpArbiterFree(pcpArbiter(ptr));
end;
procedure bodyFreeWrap(ptr : pointer; unused : pointer);
begin
    cpBodyFree(pcpBody(ptr));
end;
procedure jointFreeWrap(ptr : pointer; unused : pointer);
begin
   cpJointFree(pcpJoint(ptr));
end;

function  cpSpaceAlloc : PcpSpace;
begin
   result:=calloc(sizeof(result^));
end;

const DEFAULT_DIM_SIZE = 100.0;
const DEFAULT_COUNT = 1000;
const DEFAULT_ITERATIONS = 10;

// Equal function for contactSet.
function contactSetEql(ptr : pointer; elt:pointer) : boolean;
var arb:pcpArbiter;
    a,b :pcpShape;
    shapes : PcpShapeArray;
begin
   shapes := PcpShapeArray(ptr);
   a := shapes^[0];
   b := shapes^[1];

   arb := pcpArbiter(elt);

   result:= ((a = arb.a) and (b = arb.b)) or ((b = arb.a) and (a = arb.b));
end;

// Transformation function for contactSet.
function contactSetTrans(ptr:pointer; data:pointer) : pointer;
var space:pcpSpace;
    shapes : PcpShapeArray;
begin
   shapes := PcpShapeArray(ptr);
   space := pcpSpace(data);
   result:=cpArbiterNew(shapes[0], shapes[1], space.stamp);
end;

// Equals function for collFuncSet.
function cpCollFuncSetEql(ptr : pointer; elt:pointer) : boolean;
var ids :pcpUnsignedIntArray;
    pair : PcpCollPairFunc;
    a,b : LongWord;
begin
   ids := pcpUnsignedIntArray(ptr);
   a := ids[0];
   b := ids[1];

   pair := pcpCollPairFunc(elt);

   result:= ((a = pair.a) and (b = pair.b)) or ((b = pair.a) and (a = pair.b));
end;

// Transformation function for collFuncSet.
function collFuncSetTrans(ptr:pointer; data:pointer) : pointer; 
var ids :pcpUnsignedIntArray;
    funcData:pcpCollFuncData;
    pair : PcpCollPairFunc;
begin
   ids := pcpUnsignedIntArray(ptr);
   funcData := pcpCollFuncData(data);
   new(pair);
   pair.a := ids[0];
   pair.b := ids[1];
   pair.func := funcData.func;
   pair.data := funcData.data;

   result:=pair;
end;

// Default collision pair function.
function alwaysCollide(a:pcpShape; b:pcpShape; arr:pcpContactArray; numCon:integer; normal_coef:cpFloat; data:pointer) : integer; 
begin
   result:=1;
end;

// BBfunc callback for the spatial hash.
function bbfunc(ptr:pointer) :cpBB;
begin
   result:=pcpShape(ptr).bb;
end;

function  cpSpaceInit( space : PcpSpace) : PcpSpace;
var pairFunc:cpCollPairFunc;
begin
   space.iterations := DEFAULT_ITERATIONS;
   //	space.sleepTicks = 300;

   space.gravity := cpvzero;
   space.damping := 1.0;

   space.stamp := 0;

   space.staticShapes := cpSpaceHashNew(DEFAULT_DIM_SIZE, DEFAULT_COUNT, bbfunc);
   space.activeShapes := cpSpaceHashNew(DEFAULT_DIM_SIZE, DEFAULT_COUNT, bbfunc);

   space.bodies := cpArrayNew(0);
   space.arbiters := cpArrayNew(0);
   space.contactSet := cpHashSetNew(0, contactSetEql, contactSetTrans);

   space.joints := cpArrayNew(0);

   pairFunc.a:=0;
   pairFunc.b:=0;
   pairFunc.func:=alwaysCollide;
   pairFunc.data:=nil;

   space.defaultPairFunc := pairFunc;
   space.collFuncSet := cpHashSetNew(0, cpCollFuncSetEql, collFuncSetTrans);
   space.collFuncSet.default_value := @space.defaultPairFunc;

   result:=space;
end;

function cpSpaceNew : PcpSpace;
begin
   result:=cpSpaceInit(cpSpaceAlloc);
end;

procedure cpSpaceClearArbiters ( space : PcpSpace);
begin
   if assigned(space.contactSet) then
      cpHashSetEach(space.contactSet, arbiterFreeWrap, nil);

//   cpArrayFree(space.arbiters);
//   space.arbiters := cpArrayNew(0);
end;

procedure cpSpaceDestroy( space : PcpSpace);
begin
   cpSpaceHashFree(space.staticShapes);
   cpSpaceHashFree(space.activeShapes);

   cpArrayFree(space.bodies);
   cpArrayFree(space.joints);

   if assigned(space.contactSet) then
      cpHashSetEach(space.contactSet, arbiterFreeWrap, nil);
   cpHashSetFree(space.contactSet);

   cpArrayFree(space.arbiters);

   if assigned(space.collFuncSet) then
      cpHashSetEach(space.collFuncSet, freeWrap, nil);

   cpHashSetFree(space.collFuncSet);
end;

procedure cpSpaceFree( space : PcpSpace);
begin
   if assigned(space) then cpSpaceDestroy(space);
   cfree(space);
end;

procedure cpSpaceFreeChildren( space : PcpSpace);
begin
   cpSpaceHashEach(space.staticShapes, shapeFreeWrap, nil);
   cpSpaceHashEach(space.activeShapes, shapeFreeWrap, nil);
   cpArrayEach(space.bodies, bodyFreeWrap, nil);
   cpArrayEach(space.joints, jointFreeWrap, nil);
end;

procedure cpSpaceAddCollisionPairFunc( space : PcpSpace; a : LongWord; b : LongWord; func : TcpCollFunc; data : pointer);
var hash :LongWord;
    ids : array[0..1] of LongWord;
    funcdata:cpCollFuncData;
begin
   ids[0] := a;
   ids[1] := b;
   hash := CP_HASH_PAIR(a, b);
   // Remove any old function so the new one will get added.
   cpSpaceRemoveCollisionPairFunc(space, a, b);

   funcData.func := func;
   funcData.data := data;
   cpHashSetInsert(space.collFuncSet, hash, @ids, @funcData);
end;

procedure cpSpaceRemoveCollisionPairFunc(space : PcpSpace; a : LongWord; b : LongWord);
var hash :LongWord;
    ids : array[0..1] of LongWord;
    old_pair:pcpCollPairFunc;
begin
   ids[0] := a;
   ids[1] := b;
   hash := CP_HASH_PAIR(a, b);
   old_pair := pcpCollPairFunc(cpHashSetRemove(space.collFuncSet, hash, @ids));
   cfree(old_pair);
end;

procedure cpSpaceSetDefaultCollisionPairFunc( space : PcpSpace; func : TcpCollFunc; data : pointer);
var pairFunc :cpCollPairFunc;
begin
   pairFunc.a:=0;
   pairFunc.b:=0;
   if assigned(func) then begin
      pairFunc.func:=func;
      pairFunc.data:=data;
   end else begin
      pairFunc.func:=alwaysCollide;
      pairFunc.data:=nil;
   end;
   space.defaultPairFunc := pairFunc;
end;

function cpContactSetReject(ptr : pointer; data : pointer) : integer;
var arb : pcpArbiter;
    space : pcpSpace;
begin
   result:=0;
   arb := pcpArbiter(ptr);
   space := pcpSpace(data);

   if((space.stamp - arb.stamp) > cp_contact_persistence) then begin
      cpArbiterFree(arb);
      exit;
   end;

   result:=1;
end;

procedure cpSpaceAddShape( space : PcpSpace; shape : PcpShape);
begin
   cpSpaceHashInsert(space.activeShapes, shape, shape.id, shape.bb);
end;

procedure cpSpaceAddStaticShape( space : PcpSpace; shape : PcpShape);
begin
  shape.is_static := true;
   cpSpaceHashInsert(space.staticShapes, shape, shape.id, shape.bb);
end;

procedure cpSpaceAddBody( space : PcpSpace; body : PcpBody);
begin
   cpArrayPush(space.bodies, body);
end;

procedure cpSpaceAddJoint( space : PcpSpace; joint : PcpJoint);
begin
   cpArrayPush(space.joints, joint);
end;

procedure cpSpaceRemoveShape( space : PcpSpace; shape : PcpShape);
begin
   cpSpaceHashRemove(space.activeShapes, shape, shape.id);
end;

procedure cpSpaceRemoveStaticShape( space : PcpSpace; shape : PcpShape);
begin
   cpSpaceHashRemove(space.staticShapes, shape, shape.id);
end;

procedure cpSpaceRemoveBody( space : PcpSpace; body : PcpBody);
begin
   cpArrayDeleteObj(space.bodies, body);
end;

procedure cpSpaceRemoveJoint( space : PcpSpace; joint : PcpJoint);
begin
   cpArrayDeleteObj(space.joints, joint);
end;

procedure cpSpaceEachBody( space : PcpSpace; func : TcpSpaceBodyIterator; data : pointer);
var bodies:pcpArray;
    i : integer;
begin
   bodies := space.bodies;
   for i:=0 to bodies.num-1 do
      func(pcpBody(bodies.arr[i]), data);
end;

procedure cpSpaceResizeStaticHash( space : PcpSpace; dim : cpFloat; count : Integer);
begin
   cpSpaceHashResize(space.staticShapes, dim, count);
   cpSpaceHashRehash(space.staticShapes);
end;

procedure cpSpaceResizeActiveHash( space : PcpSpace; dim : cpFloat; count : Integer);
begin
   cpSpaceHashResize(space.activeShapes, dim, count);
end;

procedure cpUpdateBBCache(ptr:pointer;unused:pointer);
begin
   cpShapeCacheBB(pcpShape(ptr));
end;

procedure cpSpaceRehashStatic( space : PcpSpace);
begin
   cpSpaceHashEach(space.staticShapes, cpUpdateBBCache, nil);
   cpSpaceHashRehash(space.staticShapes);
end;


function cpQueryReject(a:pcpShape; b:pcpShape) : integer;
begin
   if
   // BBoxes must overlap
   (cpBBintersects(a.bb, b.bb)=0)
   // Don't collide shapes attached to the same body.
   or (a.body = b.body)
   // Don't collide objects in the same non-zero group
   or (((a.group and b.group)<>0) and (a.group = b.group))
   // Don't collide objects that don't share at least on layer.
   or ((a.layers and b.layers)=0)
      then result:=1 else result:=0;
end;

// Callback from the spatial hash.
// TODO: Refactor this into separate functions?
function cpQueryFunc(p1:pointer; p2:pointer; data:pointer) : integer;
var a,b,temp,pair_a,pair_b : pcpShape;
    space : pcpSpace;
    ids : array[0..1] of LongWord;
    hash : LongWord;
    pairfunc : pcpCollPairFunc;
    contacts:pcpContactArray;
    numContacts : integer;
    normal_coef:cpFloat;
    shape_Pair:cpShapePair;
    arb:pcpArbiter;
begin
   result:=0;
   // Cast the generic pointers from the spatial hash back to usefull types
   a := p1;
   b := p2;
   space := data;

   // Reject any of the simple cases
   if(cpQueryReject(a,b)<>0) then exit;

   // Shape 'a' should have the lower shape type. (required by cpCollideShapes() )
   if(a.cptype > b.cptype) then begin
      temp := a;
      a := b;
      b := temp;
   end;

   // Find the collision pair function for the shapes.
   ids[0] := a.collision_type;
   ids[1] := b.collision_type;
   hash := CP_HASH_PAIR(a.collision_type, b.collision_type);
   pairFunc := pcpCollPairFunc(cpHashSetFind(space.collFuncSet, hash, @ids));
   if not assigned(pairFunc.func) then exit; // A NULL pair function means don't collide at all.

   // Narrow-phase collision detection.
   contacts := nil;
   numContacts := cpCollideShapes(a, b, contacts);
   if(numContacts=0) then exit; // Shapes are not colliding.

   // The collision pair function requires objects to be ordered by their collision types.
   pair_a := a;
   pair_b := b;
   normal_coef := 1.0;

   // Swap them if necessary.
   if(pair_a.collision_type <> pairFunc.a) then begin
      temp := pair_a;
      pair_a := pair_b;
      pair_b := temp;
      normal_coef := -1.0;
   end;

   if(pairFunc.func(pair_a, pair_b, contacts, numContacts, normal_coef, pairFunc.data)<>0) then begin
      // The collision pair function OKed the collision. Record the contact information.

      // Get an arbiter from space.contactSet for the two shapes.
      // This is where the persistant contact magic comes from.
      shape_pair[0] := a;
      shape_pair[1] := b;

      arb := pcpArbiter(cpHashSetInsert(space.contactSet, CP_HASH_PAIR(a, b), @shape_pair, space));

      // Timestamp the arbiter.
      arb.stamp := space.stamp;
      arb.a := a; arb.b := b; // TODO: Investigate why this is still necessary?

      // Inject the new contact points into the arbiter.
      cpArbiterInject(arb, contacts, numContacts);

      // Add the arbiter to the list of active arbiters.
      cpArrayPush(space.arbiters, arb);

      result:=numContacts;
   end else begin
   // The collision pair function rejected the collision.
      cfree(contacts);
   end;
end;

procedure cpActive2staticIter(ptr:pointer; data:pointer);
begin
   cpSpaceHashQuery(pcpSpace(data).staticShapes, pcpShape(ptr), pcpShape(ptr).bb, cpQueryFunc, pcpSpace(data));
end;

procedure cpSpaceStep( space : PcpSpace; dt : cpFloat);
var damping,dt_inv:cpFloat;
    bodies,arbiters,joints:pcpArray;
    joint : pcpJoint;
    i,j : integer;
begin
   if(dt=0) then exit; // prevents div by zero.
   dt_inv := 1.0/dt;

   bodies := space.bodies;
   arbiters := space.arbiters;
   joints := space.joints;

   // Empty the arbiter list.
   cpHashSetReject(space.contactSet, cpContactSetReject, space);
   space.arbiters.num := 0;

   // Integrate velocities.
   damping := power(1.0/space.damping, -dt);
   for i:=0 to bodies.num-1 do
      cpBodyUpdateVelocity(pcpBody(bodies.arr[i]), space.gravity, damping, dt);

   // Pre-cache BBoxes and shape data.
   cpSpaceHashEach(space.activeShapes, cpUpdateBBCache, nil);

   // Collide!
   cpSpaceHashEach(space.activeShapes, cpActive2staticIter, space);
   cpSpaceHashQueryRehash(space.activeShapes, cpQueryFunc, space);

   // Prestep the arbiters.
   for i:=0 to arbiters.num-1 do
      cpArbiterPreStep(pcpArbiter(arbiters.arr[i]), dt_inv);

   // Prestep the joints.
   for i:=0 to joints.num-1 do begin
      joint := pcpJoint(joints.arr[i]);
      joint.preStep(joint, dt_inv);
   end;

   // Run the impulse solver.
   for i:=0 to space.iterations-1 do begin
      for j:=0 to arbiters.num-1 do
         cpArbiterApplyImpulse(pcpArbiter(arbiters.arr[j]));
      for j:=0 to joints.num-1 do begin
         joint := pcpJoint(joints.arr[j]);
         joint.applyImpulse(joint);
      end;
   end;

   // Integrate positions.
   for i:=0 to bodies.num-1 do
      cpBodyUpdatePosition(pcpBody(bodies.arr[i]), dt);

   // Increment the stamp.
   inc(space.stamp);
end;

initialization

finalization
cpShutdownChipmunk;

end.





