(*
Ming is a library for generating Macromedia Flash files (.swf), written in C,
licensed under the LGPL (see lgpl-3.0.txt).
You can get the source for Ming at http://www.libming.org/

This wrapper is very lightweight in that it simply gives access to existing
Ming functions, and requires a call to MingLoad before use.

Friday 21 Mar 2008: version 1.0, bound to be buggy

Author: Dirk de la Hunt (noshbar@yahoo.com)
*)

unit ming;

interface

const (***** SWFBitmap *****)
   SWF_DBL_COLORTABLE = 0;
   SWF_DBL_RGB15      = 1;
   SWF_DBL_RGB24      = 2;
   SWF_DBL_RGB32      = 3;

   SWF_RAWIMG_ARGB = 0;

const (***** SWFFillStyle - a fill instance on a shape *****)
   SWFFILL_SOLID           = $00;
   SWFFILL_GRADIENT        = $10;
   SWFFILL_LINEAR_GRADIENT = $10;
   SWFFILL_RADIAL_GRADIENT = $12;
   SWFFILL_FOCAL_GRADIENT  = $13;
   SWFFILL_BITMAP          = $40;
   SWFFILL_TILED_BITMAP    = $40;
   SWFFILL_CLIPPED_BITMAP  = $41;

const (***** SWFLineStyle *****) (* linestyle 2 flags *)
   SWF_LINESTYLE_CAP_ROUND          = (0 shl 14);
   SWF_LINESTYLE_CAP_NONE           = (1 shl 14);
   SWF_LINESTYLE_CAP_SQUARE         = (2 shl 14);

   SWF_LINESTYLE_JOIN_ROUND         = (0 shl 12);
   SWF_LINESTYLE_JOIN_BEVEL         = (1 shl 12);
   SWF_LINESTYLE_JOIN_MITER         = (2 shl 12);

   SWF_LINESTYLE_FLAG_NOHSCALE      = (1 shl 10);
   SWF_LINESTYLE_FLAG_NOVSCALE      = (1 shl 9);
   SWF_LINESTYLE_FLAG_HINTING       = (1 shl 8);
   SWF_LINESTYLE_FLAG_NOCLOSE       = (1 shl 2);

   SWF_LINESTYLE_FLAG_ENDCAP_ROUND  = (0 shl 0);
   SWF_LINESTYLE_FLAG_ENDCAP_NONE   = (1 shl 0);
   SWF_LINESTYLE_FLAG_ENDCAP_SQUARE = (2 shl 0);

const (***** SWFShape *****)
   SWF_SHAPE3 = 3;
   SWF_SHAPE4 = 4;

   SWF_SHAPE_USESCALINGSTROKES     = (1 shl 0);
   SWF_SHAPE_USENONSCALINGSTREOKES = (1 shl 1);

const (***** SWFTextField *****)
   SWFTEXTFIELD_HASFONT   = (1 shl 0);   (* private *)
   SWFTEXTFIELD_HASLENGTH = (1 shl 1);   (* private *)
   SWFTEXTFIELD_HASCOLOR  = (1 shl 2);   (* private *) 
   SWFTEXTFIELD_NOEDIT    = (1 shl 3);   (* disables editing *)
   SWFTEXTFIELD_PASSWORD  = (1 shl 4);   (* hides characters *)
   SWFTEXTFIELD_MULTILINE = (1 shl 5);   (* multiline and scrollable *)
   SWFTEXTFIELD_WORDWRAP  = (1 shl 6);   (* enable automatic line wrap *)
   SWFTEXTFIELD_HASTEXT   = (1 shl 7);   (* private *)
   SWFTEXTFIELD_USEFONT   = (1 shl 8);   (* private *)
   SWFTEXTFIELD_HTML      = (1 shl 9);   (* renders some HTML tags*)
   SWFTEXTFIELD_DRAWBOX   = (1 shl 11);  (* draws a border *)
   SWFTEXTFIELD_NOSELECT  = (1 shl 12);  (* disabled selection *)
   SWFTEXTFIELD_HASLAYOUT = (1 shl 13);  (* private *)
   SWFTEXTFIELD_AUTOSIZE  = (1 shl 14);  (* resizes to textlen *)
   (* enum *)
   SWFTEXTFIELD_ALIGN_LEFT    = 0;
   SWFTEXTFIELD_ALIGN_RIGHT   = 1;
   SWFTEXTFIELD_ALIGN_CENTER  = 2;
   SWFTEXTFIELD_ALIGN_JUSTIFY = 3;

const (***** SWFSound *****)
   SWF_SOUND_COMPRESSION       = $f0;
   SWF_SOUND_NOT_COMPRESSED    = (0 shl 4);
   SWF_SOUND_ADPCM_COMPRESSED  = (1 shl 4);
   SWF_SOUND_MP3_COMPRESSED    = (2 shl 4);
   SWF_SOUND_NOT_COMPRESSED_LE = (3 shl 4);
   SWF_SOUND_NELLY_COMPRESSED  = (6 shl 4);
   
   SWF_SOUND_RATE              = $0c;
   SWF_SOUND_5KHZ              = (0 shl 2);
   SWF_SOUND_11KHZ             = (1 shl 2);
   SWF_SOUND_22KHZ             = (2 shl 2);
   SWF_SOUND_44KHZ             = (3 shl 2);
   
   SWF_SOUND_BITS              = $02;
   SWF_SOUND_8BITS             = (0 shl 1);
   SWF_SOUND_16BITS            = (1 shl 1);
   
   SWF_SOUND_CHANNELS          = $01;
   SWF_SOUND_MONO              = (0 shl 0);
   SWF_SOUND_STEREO            = (1 shl 0);

const (***** SWFButton *****)
   SWFBUTTON_HIT    = (1 shl 3);
   SWFBUTTON_DOWN   = (1 shl 2);
   SWFBUTTON_OVER   = (1 shl 1);
   SWFBUTTON_UP     = (1 shl 0);
   
   (* deprecated: *)
   
   SWFBUTTONRECORD_HITSTATE    = (1 shl 3);
   SWFBUTTONRECORD_DOWNSTATE   = (1 shl 2);
   SWFBUTTONRECORD_OVERSTATE   = (1 shl 1);
   SWFBUTTONRECORD_UPSTATE     = (1 shl 0);

   SWFBUTTON_OVERDOWNTOIDLE    = (1 shl 8);
   SWFBUTTON_IDLETOOVERDOWN    = (1 shl 7);
   SWFBUTTON_OUTDOWNTOIDLE     = (1 shl 6);
   SWFBUTTON_OUTDOWNTOOVERDOWN = (1 shl 5);
   SWFBUTTON_OVERDOWNTOOUTDOWN = (1 shl 4);
   SWFBUTTON_OVERDOWNTOOVERUP  = (1 shl 3);
   SWFBUTTON_OVERUPTOOVERDOWN  = (1 shl 2);
   SWFBUTTON_OVERUPTOIDLE      = (1 shl 1);
   SWFBUTTON_IDLETOOVERUP      = (1 shl 0);
   
   (* easier to remember: *)
   SWFBUTTON_MOUSEUPOUTSIDE  = SWFBUTTON_OUTDOWNTOIDLE;
   SWFBUTTON_DRAGOVER        = (SWFBUTTON_OUTDOWNTOOVERDOWN or SWFBUTTON_IDLETOOVERDOWN);
   SWFBUTTON_DRAGOUT         = (SWFBUTTON_OVERDOWNTOOUTDOWN or SWFBUTTON_OVERDOWNTOIDLE);
   SWFBUTTON_MOUSEUP         = SWFBUTTON_OVERDOWNTOOVERUP;
   SWFBUTTON_MOUSEDOWN       = SWFBUTTON_OVERUPTOOVERDOWN;
   SWFBUTTON_MOUSEOUT        = SWFBUTTON_OVERUPTOIDLE;
   SWFBUTTON_MOUSEOVER       = SWFBUTTON_IDLETOOVERUP;

const (***** SWFGradient *****)
   SWF_GRADIENT_PAD     = 0;
   SWF_GRADIENT_REFLECT = 1;
   SWF_GRADIENT_REPEAT  = 2;
   
   SWF_GRADIENT_NORMAL = 0;
   SWF_GRADIENT_LINEAR = 1;

const (***** SWFDisplayItem *****)
   SWFACTION_ONLOAD          = (1 shl 0);
   SWFACTION_ENTERFRAME      = (1 shl 1);
   SWFACTION_UNLOAD          = (1 shl 2);
   SWFACTION_MOUSEMOVE       = (1 shl 3);
   SWFACTION_MOUSEDOWN       = (1 shl 4);
   SWFACTION_MOUSEUP         = (1 shl 5);
   SWFACTION_KEYDOWN         = (1 shl 6);
   SWFACTION_KEYUP           = (1 shl 7);
   SWFACTION_DATA            = (1 shl 8);
   SWFACTION_INIT            = (1 shl 9);
   SWFACTION_PRESS           = (1 shl 10);
   SWFACTION_RELEASE         = (1 shl 11);
   SWFACTION_RELEASEOUTSIDE  = (1 shl 12);
   SWFACTION_ROLLOVER        = (1 shl 13);
   SWFACTION_ROLLOUT         = (1 shl 14);
   SWFACTION_DRAGOVER        = (1 shl 15);
   SWFACTION_DRAGOUT         = (1 shl 16);
   SWFACTION_KEYPRESS        = (1 shl 17);
   SWFACTION_CONSTRUCT       = (1 shl 18);

   SWFBLEND_MODE_NULL      = 0;
   SWFBLEND_MODE_NORMAL    = 1;
   SWFBLEND_MODE_LAYER     = 2;
   SWFBLEND_MODE_MULT      = 3;
   SWFBLEND_MODE_SCREEN    = 4;
   SWFBLEND_MODE_LIGHTEN   = 5;
   SWFBLEND_MODE_DARKEN    = 6;
   SWFBLEND_MODE_DIFF      = 7;
   SWFBLEND_MODE_ADD       = 8;
   SWFBLEND_MODE_SUB       = 9;
   SWFBLEND_MODE_INV       = 10;
   SWFBLEND_MODE_ALPHA     = 11;
   SWFBLEND_MODE_ERASE     = 12;
   SWFBLEND_MODE_OVERLAY   = 13;
   SWFBLEND_MODE_HARDLIGHT = 14;
   
const (***** SWFFilter ***********)
   FILTER_MODE_INNER      = (1 shl 7);
   FILTER_MODE_KO         = (1 shl 6);
   FILTER_MODE_COMPOSITE  = (1 shl 5);
   FILTER_MODE_ONTOP      = (1 shl 4);
   FILTER_FLAG_CLAMP           = (1 shl 1);
   FILTER_FLAG_PRESERVE_ALPHA  = (1 shl 0);
type (***** SWFFilter ***********)
   SWFColor = record
        red   : byte;
        green : byte;
        blue  : byte;
        alpha : byte;
   end;
   
//#define MING_VERSION        0.4.0.beta5
//#define MING_VERSION_TEXT  "0.4.0.beta5"
type
   SWFBlock = pointer;
   SWFMatrix = pointer;
   SWFInput = pointer;
   SWFCharacter = pointer;
   SWFDBLBitmap = pointer;
   SWFDBLBitmapData = pointer;
   SWFJpegBitmap = pointer;
   SWFJpegWithAlpha = pointer;
   SWFGradient = pointer;
   SWFFillStyle = pointer;
   SWFLineStyle = pointer;
   SWFShape = pointer;
   SWFMorph = pointer;
   SWFFont = pointer;
   SWFText = pointer;
   SWFBrowserFont = pointer;
   SWFFontCharacter = pointer;
   SWFTextField = pointer;
   SWFSoundStream = pointer;
   SWFSound = pointer;
   SWFSoundInstance = pointer;
   SWFCXform = pointer;
   SWFAction = pointer;
   SWFButton = pointer;
   SWFSprite = pointer;
   SWFPosition = pointer;
   SWFDisplayItem = pointer;
   SWFFill = pointer;
   SWFMovieClip = pointer;
   SWFMovie = pointer;
   SWFVideoStream = pointer;
   SWFPrebuiltClip = pointer;
   SWFFilter = pointer;
   SWFButtonRecord = pointer;
   SWFSymbolClass = pointer;
   SWFBinaryData = pointer;
   SWFSceneData = pointer;
   SWFShadow = pointer;
   SWFBlur = pointer;
   SWFFilterMatrix = pointer;
   SWFBitmap = pointer;

   SWFRawImgFmt = integer;
   SWFBitmapFmt = integer;
   GradientSpreadMode = integer;
   GradientInterpolationMode = integer;
   SWFTextFieldAlignment = integer;
   wordptr = ^word;

type (***** General Ming functions *****)

  pfMing_init = function() : integer; cdecl;
  pfMing_cleanup = procedure(); cdecl;
  pfMing_collectGarbage = procedure(); cdecl;
  pfMing_useConstants = procedure(flag : integer); cdecl;

  (* sets the threshold error for drawing cubic beziers.  Lower is more
     accurate; hence larger file size. *)
  pfMing_setCubicThreshold = procedure(num : integer); cdecl;

  (* sets the overall scale; default is 20.0 *)
  pfMing_setScale = procedure(scale : single); cdecl;
  pfMing_getScale = function() : single; cdecl;

  (* set the version number to use *)
  pfMing_useSWFVersion = procedure(version : integer); cdecl;

  (*
   * Set output compression level.
   * Return previous value.
   *) 
  pfMing_setSWFCompression = function(level : integer) : integer; cdecl;

  (*
   * Error and warning callbacks.
   *)
  SWFMsgFunc = procedure (msg : pchar); cdecl;

  (* a generic output method.  specific instances dump output to file;
     send to stdout; etc. *)
  SWFByteOutputMethod = procedure(b : byte; data : pointer); cdecl;

  (***** SWFBlock *****)

  (***** SWFMatrix *****)

  pfSWFMatrix_getScaleX = function(m : SWFMatrix) : single; cdecl;
  pfSWFMatrix_getRotate0 = function(m : SWFMatrix) : single; cdecl;
  pfSWFMatrix_getRotate1 = function(m : SWFMatrix) : single; cdecl;
  pfSWFMatrix_getScaleY = function(m : SWFMatrix) : single; cdecl;
  pfSWFMatrix_getTranslateX = function(m : SWFMatrix) : integer; cdecl;
  pfSWFMatrix_getTranslateY = function(m : SWFMatrix) : integer; cdecl;

  (***** SWFInput *****)

  (* A generic input object.  Wraps files; buffers and streams; replaces standard file funcs *)
  pfnewSWFInput_file = function(f : pointer {FILE*}) : SWFInput; cdecl;
  pfnewSWFInput_stream = function(f : pointer {FILE*}) : SWFInput; cdecl;
  pfnewSWFInput_buffer = function(buffer : byte; length : integer) : SWFInput; cdecl;
  pfnewSWFInput_allocedBuffer = function(buffer : byte; length : integer) : SWFInput; cdecl;
  pfnewSWFInput_input = function(input : SWFInput; length : cardinal) : SWFInput; cdecl;
  pfdestroySWFInput = procedure(input : SWFInput); cdecl;

  pfSWFInput_length = function(input : SWFInput) : integer; cdecl;
  pfSWFInput_rewind = procedure(input : SWFInput); cdecl;
  pfSWFInput_tell = function(input : SWFInput) : integer; cdecl;
  pfSWFInput_seek = procedure(input : SWFInput; offset : longint; whence : integer); cdecl;
  pfSWFInput_eof = function(input : SWFInput) : integer; cdecl;

  (***** SWFCharacter *****)

  (* a character is any sort of asset that's referenced later-
     SWFBitmap; SWFShape; SWFMorph; SWFSound; SWFSprite are all SWFCharacters *)

  pfSWFCharacter_getWidth = function(character : SWFCharacter) : single; cdecl;
  pfSWFCharacter_getHeight = function(character : SWFCharacter) : single; cdecl;

  (***** SWFBitmap *****)

  pfnewSWFBitmap_fromInput = function(input : SWFInput) : SWFBitmap; cdecl;
  pfnewSWFBitmap_fromRawImg = function(raw : byte; srcFmt : SWFRawImgFmt; dstFmt : SWFBitmapFmt; width : word; height : word) : SWFBitmap; cdecl;

  pfdestroySWFBitmap = procedure(bitmap : SWFBitmap); cdecl;

  pfSWFBitmap_getWidth = function(b : SWFBitmap) : integer; cdecl;
  pfSWFBitmap_getHeight = function(b : SWFBitmap) : integer; cdecl;

  (***** SWFDBLBitmap extends SWFBitmap *****)

  (* create a new DBL (define bits lossless) bitmap from the given file *)
  pfnewSWFDBLBitmap = function(f : pointer {FILE*}) : SWFDBLBitmap; cdecl;
  (* create a new DBL bitmap from the given input object *)
  pfnewSWFDBLBitmap_fromInput = function(input : SWFInput) : SWFDBLBitmap; cdecl;

  //SWFDBLBitmapData newSWFDBLBitmapData_fromGifFile(pchar name);
  //SWFDBLBitmapData newSWFDBLBitmapData_fromGifInput(input : SWFInput);

  pfnewSWFDBLBitmapData_fromPngFile = function(name : pchar) : SWFDBLBitmapData; cdecl;
  pfnewSWFDBLBitmapData_fromPngInput = function(input : SWFInput) : SWFDBLBitmapData; cdecl;

  (***** SWFJpegBitmap extends SWFBitmap *****)

  pfnewSWFJpegBitmap = function(f : pointer {FILE*}) : SWFJpegBitmap; cdecl;
  pfnewSWFJpegBitmap_fromInput = function(input : SWFInput) : SWFJpegBitmap; cdecl;

  pfnewSWFJpegWithAlpha = function(f : pointer {FILE*}; alpha : pointer {FILE*}) : SWFJpegWithAlpha; cdecl;
  pfnewSWFJpegWithAlpha_fromInput = function(input : SWFInput; alpha : SWFInput) : SWFJpegWithAlpha; cdecl;

  (***** SWFGradient *****)

  pfnewSWFGradient = function() : SWFGradient; cdecl;
  pfdestroySWFGradient = procedure(gradient : SWFGradient); cdecl;

  pfSWFGradient_addEntry = procedure(gradient : SWFGradient; ratio : single; r : byte; g : byte; b : byte; a : byte); cdecl;

  pfSWFGradient_setSpreadMode = procedure(gradient : SWFGradient; mode : GradientSpreadMode); cdecl;
  pfSWFGradient_setInterpolationMode = procedure(gradient : SWFGradient; mode : GradientInterpolationMode); cdecl;
  pfSWFGradient_setFocalPoint = procedure(gradient : SWFGradient; focalPoint : single); cdecl;

  (***** SWFFillStyle - a fill instance on a shape *****)

  pfnewSWFSolidFillStyle = function(r : byte; g : byte; b : byte; a : byte) : SWFFillStyle; cdecl;
  pfnewSWFGradientFillStyle = function(gradient : SWFGradient; radial : byte) : SWFFillStyle; cdecl;
  pfnewSWFBitmapFillStyle = function(bitmap : SWFCharacter; flags : byte) : SWFFillStyle; cdecl;

  pfSWFFillStyle_getMatrix = function(fill : SWFFillStyle) : SWFMatrix; cdecl;
  pfdestroySWFFillStyle = procedure(fill : SWFFillStyle); cdecl;

  (***** SWFLineStyle *****)

  pfnewSWFLineStyle = function(width : word; r : byte; g : byte; b : byte; a : byte) : SWFLineStyle; cdecl;

  pfnewSWFLineStyle2 = function(width : word; r : byte; g : byte; b : byte; a : byte; flags : integer; miterLimit : single) : SWFLineStyle; cdecl;
  pfnewSWFLineStyle2_filled = function(width : word; fill : SWFFillStyle; flags : integer; miterLimit : single) : SWFLineStyle; cdecl;

  (***** SWFShape *****)

  pfnewSWFShape = function() : SWFShape; cdecl;
  (*
   * returns a shape containing the bitmap in a filled rect
   * flag can be SWFFILL_CLIPPED_BITMAP or SWFFILL_TILED_BITMAP
   *)
  pfnewSWFShapeFromBitmap = function(bitmap : SWFBitmap; flag : integer) : SWFShape; cdecl;
  pfdestroySWFShape = procedure(shape : SWFShape); cdecl;

  pfSWFShape_end = procedure(shape : SWFShape); cdecl;
  pfSWFShape_useVersion = procedure(shape : SWFShape; version : integer); cdecl;
  pfSWFShape_getVersion = function(shape : SWFShape) : integer; cdecl;
  pfSWFShape_setRenderHintingFlags = procedure(shape : SWFShape; flags : integer); cdecl;

  pfSWFShape_movePenTo = procedure(shape : SWFShape; x : single; y : single); cdecl;
  pfSWFShape_movePen = procedure(shape : SWFShape; x : single; y : single); cdecl;

  pfSWFShape_getPenX = function(shape : SWFShape) : single; cdecl;
  pfSWFShape_getPenY = function(shape : SWFShape) : single; cdecl;
  pfSWFShape_getPen = procedure(shape : SWFShape; var penX : single; var penY : single); cdecl;

  (* x;y relative to shape origin *)
  pfSWFShape_drawLineTo = procedure(shape : SWFShape; x : single; y : single); cdecl;
  pfSWFShape_drawLine = procedure(shape : SWFShape; dx : single; dy : single); cdecl;

  pfSWFShape_drawCurveTo = procedure(shape : SWFShape; controlx : single; controly : single; anchorx : single; anchory : single); cdecl;
  pfSWFShape_drawCurve = procedure(shape : SWFShape; controldx : single; controldy : single; anchordx : single; anchordy : single); cdecl;

  pfSWFShape_setLineStyle = procedure(shape : SWFShape; width : word; r : byte; g : byte; b : byte; a : byte) {__deprecated}; cdecl;

  pfSWFShape_setLineStyle2 = procedure(shape : SWFShape; width : word; r : byte; g : byte; b : byte; a : byte; flags : integer; miterLimit : single) {__deprecated}; cdecl;

  pfSWFShape_setLineStyle2filled = procedure(shape : SWFShape; width : word; fill : SWFFillStyle; flags : integer; miterLimit : single) {__deprecated}; cdecl;

  pfSWFShape_hideLine = procedure(shape : SWFShape); cdecl;

  pfSWFShape_addSolidFillStyle = function(shape : SWFShape; r : byte; g : byte; b : byte; a : byte) : SWFFillStyle; cdecl;
  pfSWFShape_addGradientFillStyle = function(shape : SWFShape; gradient : SWFGradient; flags : byte) : SWFFillStyle; cdecl;
  pfSWFShape_addBitmapFillStyle = function(shape : SWFShape; bitmap : SWFBitmap; flags : byte) : SWFFillStyle; cdecl;

  pfSWFShape_setLeftFillStyle = procedure(shape : SWFShape; fill : SWFFillStyle); cdecl;
  pfSWFShape_setRightFillStyle = procedure(shape : SWFShape; fill : SWFFillStyle); cdecl;

  (***** SWFMorph *****)

  pfnewSWFMorphShape = function() : SWFMorph; cdecl;
  pfdestroySWFMorph = procedure(morph : SWFMorph); cdecl;

  pfSWFMorph_getShape1 = function(morph : SWFMorph) : SWFShape; cdecl;
  pfSWFMorph_getShape2 = function(morph : SWFMorph) : SWFShape; cdecl;

  (***** SWFFont *****)

  pfnewSWFFont = function() : SWFFont; cdecl;
  pfnewSWFFont_fromFile = function(filename : pchar) : SWFFont; cdecl;

  (* pull font definition from fdb (font def block) file *)
  pfloadSWFFontFromFile = function(f : pointer {FILE*}) {__deprecated} : SWFFont; cdecl;
  pfdestroySWFFont = procedure(font : SWFFont); cdecl;

  pfSWFFont_getStringWidth = function(font : SWFFont; const str : pchar) : single; cdecl;
  pfSWFFont_getUTF8StringWidth = function(font : SWFFont; const str : pchar) : single; cdecl;

    (* deprecated? *)
  pfSWFFont_getWideStringWidth = function(font : SWFFont; const str : pchar; len : integer) : single; cdecl;
    //#define SWFFont_getWidth SWFFont_getStringWidth

  pfSWFFont_getAscent = function(font : SWFFont) : single; cdecl;
  pfSWFFont_getDescent = function(font : SWFFont) : single; cdecl;
  pfSWFFont_getLeading = function(font : SWFFont) : single; cdecl;

  (***** SWFText *****)

  pfnewSWFText = function() : SWFText; cdecl;
  pfnewSWFText2 = function() : SWFText; cdecl;
  pfdestroySWFText = procedure(text : SWFText); cdecl;

  pfSWFText_setFont = procedure(text : SWFText; font : pointer); cdecl;
  pfSWFText_setHeight = procedure(text : SWFText; height : single); cdecl;
  pfSWFText_setColor = procedure(text : SWFText; r : byte; g : byte; b : byte; a : byte); cdecl;

  pfSWFText_moveTo = procedure(text : SWFText; x : single; y : single); cdecl;

  pfSWFText_addString = procedure(text : SWFText; const str : pchar; var advance : integer); cdecl;
  pfSWFText_addUTF8String = procedure(text : SWFText; const str : pchar; var advance : integer); cdecl;
  pfSWFText_addWideString = procedure(text : SWFText; const str : wordptr; strlen : integer; var advance : integer); cdecl;

  pfSWFText_setSpacing = procedure(text : SWFText; spacing : single); cdecl;

  pfSWFText_getStringWidth = function(text : SWFText; const str : pchar) : single; cdecl;
  pfSWFText_getUTF8StringWidth = function(text : SWFText; const str : pchar) : single; cdecl;
  pfSWFText_getWideStringWidth = function(text : SWFText; const str : wordptr) : single; cdecl;

    (* deprecated? *)
    //#define SWFText_getWidth SWFText_getStringWidth

  pfSWFText_getAscent = function(text : SWFText) : single; cdecl;
  pfSWFText_getDescent = function(text : SWFText) : single; cdecl;
  pfSWFText_getLeading = function(text : SWFText) : single; cdecl;

    (* deprecated: *)
    //#define SWFText_setXY(t;x;y) SWFText_moveTo((t);(x);(y))

  (***** SWFBrowserFont *****)

  pfnewSWFBrowserFont = function(name : pchar) : SWFBrowserFont; cdecl;
  pfdestroySWFBrowserFont = procedure(browserFont : SWFBrowserFont); cdecl;

  (***** SWFFontCharacter *****)

  pfSWFMovie_addFont = function(movie : SWFMovie; font : SWFFont) : SWFFontCharacter; cdecl;
  pfSWFFontCharacter_addChars = procedure(font : SWFFontCharacter; str : pchar); cdecl;
  pfSWFFontCharacter_addUTF8Chars = procedure(font : SWFFontCharacter; str : pchar); cdecl;
  pfSWFMovie_importFont = function(movie : SWFMovie; filename : pchar; name : pchar) : SWFFontCharacter; cdecl;
  pfSWFFontCharacter_addAllChars = procedure(character : SWFFontCharacter); cdecl;

  (***** SWFTextField *****)

  pfnewSWFTextField = function() : SWFTextField; cdecl;
  pfdestroySWFTextField = procedure(textField : SWFTextField); cdecl;

  pfSWFTextField_setFont = procedure(field : SWFTextField; font : SWFBlock); cdecl;
  pfSWFTextField_setBounds = procedure(field : SWFTextField; width : single; height : single); cdecl;
  pfSWFTextField_setFlags = procedure(field : SWFTextField; flags : integer); cdecl;
  pfSWFTextField_setColor = procedure(field : SWFTextField; r : byte; g : byte; b : byte; a : byte); cdecl;
  pfSWFTextField_setVariableName = procedure(field : SWFTextField; name : pchar); cdecl;

  pfSWFTextField_addString = procedure(field : SWFTextField; str : pchar); cdecl;
  pfSWFTextField_addUTF8String = procedure(field : SWFTextField; str : pchar); cdecl;

  pfSWFTextField_setHeight = procedure(field : SWFTextField; height : single); cdecl;
  pfSWFTextField_setFieldHeight = procedure(field : SWFTextField; height : single); cdecl;
  pfSWFTextField_setLeftMargin = procedure(field : SWFTextField; leftMargin : single); cdecl;
  pfSWFTextField_setRightMargin = procedure(field : SWFTextField; rightMargin : single); cdecl;
  pfSWFTextField_setIndentation = procedure(field : SWFTextField; indentation : single); cdecl;
  pfSWFTextField_setLineSpacing = procedure(field : SWFTextField; lineSpacing : single); cdecl;
  pfSWFTextField_setPadding = procedure(field : SWFTextField; padding : single); cdecl;

  pfSWFTextField_addChars = procedure(field : SWFTextField; str : pchar); cdecl;

    (* deprecated? *)
    (*procedure SWFTextField_addUTF8Chars(field : SWFTextField; pchar string);*)

  pfSWFTextField_setAlignment = procedure(field : SWFTextField; alignment : SWFTextFieldAlignment); cdecl;
  pfSWFTextField_setLength = procedure(field : SWFTextField; length : integer); cdecl;

  (***** SWFSoundStream - only mp3 streaming implemented *****)

  pfnewSWFSoundStream = function(f : pointer {FILE*}) : SWFSoundStream; cdecl;
  (* added by David McNab <david@rebirthing.co.nz> *)
  pfnewSWFSoundStreamFromFileno = function(fd : integer) : SWFSoundStream; cdecl;
  pfnewSWFSoundStream_fromInput = function(input : SWFInput) : SWFSoundStream; cdecl;
  pfSWFSoundStream_getFrames = function(sound : SWFSoundStream) : integer; cdecl;
  pfdestroySWFSoundStream = procedure(soundStream : SWFSoundStream); cdecl;

  (***** SWFSound *****)

  pfnewSWFSound = function(f : pointer {FILE*}; flags : byte) : SWFSound; cdecl;
  (* added by David McNab to facilitate Python access *)
  pfnewSWFSoundFromFileno = function(fd : integer; flags : byte) : SWFSound; cdecl;
  pfnewSWFSound_fromInput = function(input : SWFInput; flags : byte) : SWFSound; cdecl;
  pfdestroySWFSound = procedure(sound : SWFSound); cdecl;

  (***** SWFSoundInstance *****)

  (* created from SWFMovie[Clip]_startSound;
     lets you change the parameters of the sound event (loops; etc.) *)

  pfSWFSoundInstance_setNoMultiple = procedure(instance : SWFSoundInstance); cdecl;
  pfSWFSoundInstance_setLoopInPoint = procedure(instance : SWFSoundInstance; point : cardinal); cdecl;
  pfSWFSoundInstance_setLoopOutPoint = procedure(instance : SWFSoundInstance; point : cardinal); cdecl;
  pfSWFSoundInstance_setLoopCount = procedure(instance : SWFSoundInstance; count : integer); cdecl;
  pfSWFSoundInstance_addEnvelope = procedure(inst : SWFSoundInstance; mark44 : cardinal; left : smallint; right : smallint); cdecl;

  (***** SWFCXform - Color transform *****)

  (* create a new color transform with the given parameters *)
  pfnewSWFCXform = function(rAdd : integer; gAdd : integer; bAdd : integer; aAdd : integer; rMult : single; gMult : single; bMult : single; aMult : single) : SWFCXform; cdecl;
  (* create a new color transform with the given additive parameters and
     default multiplicative *)
  pfnewSWFAddCXform = function(rAdd : integer; gAdd : integer; bAdd : integer; aAdd : integer) : SWFCXform; cdecl;
  (* create a new color transform with the given multiplicative parameters
     and default additive *)
  pfnewSWFMultCXform = function(rMult : single; gMult : single; bMult : single; aMult : single) : SWFCXform; cdecl;
  pfdestroySWFCXform = procedure(cXform : SWFCXform); cdecl;

  (* set the additive part of the color transform to the given parameters *)
  pfSWFCXform_setColorAdd = procedure(cXform : SWFCXform; rAdd : integer; gAdd : integer; bAdd : integer; aAdd : integer); cdecl;
  (* set the multiplicative part of the color transform to the given
     parameters *)
  pfSWFCXform_setColorMult = procedure(cXform : SWFCXform; rMult : single; gMult : single; bMult : single; aMult : single); cdecl;

  (***** SWFAction *****)
  pfnewSWFAction = function(script : pchar) : SWFAction; cdecl;
  pfnewSWFAction_fromFile = function(filename : pchar) : SWFAction; cdecl;
  pfcompileSWFActionCode = function(script : pchar) {__deprecated} : SWFAction; cdecl;
  pfdestroySWFAction = procedure(action : SWFAction); cdecl;
  pfSWFAction_getByteCode = function(action : SWFAction; var length : integer) : pointer; cdecl;

  (***** SWFButton *****)

  pfnewSWFButton = function() : SWFButton; cdecl;
  pfdestroySWFButton = procedure(button : SWFButton); cdecl;

  pfSWFButton_addShape = procedure(button : SWFButton; character : SWFCharacter; flags : byte) {__deprecated}; cdecl;
  pfSWFButton_addCharacter = function(button : SWFButton; character : SWFCharacter; flags : byte) : SWFButtonRecord; cdecl;
  pfSWFButton_addAction = procedure(button : SWFButton; action : SWFAction; flags : integer); cdecl;
  pfSWFButton_addSound = function(button : SWFButton; action : SWFSound; flags : byte) : SWFSoundInstance; cdecl;
  pfSWFButton_setMenu = procedure(button : SWFButton; flag : integer); cdecl;
  pfSWFButton_setScalingGrid = procedure(b : SWFButton; x : integer; y : integer; w : integer; h : integer); cdecl;
  pfSWFButton_removeScalingGrid = procedure(b : SWFButton); cdecl;

  pfSWFButtonRecord_addFilter = procedure(b : SWFButtonRecord; f : SWFFilter); cdecl;
  pfSWFButtonRecord_setBlendMode = procedure(b : SWFButtonRecord; mode : integer); cdecl;
  pfSWFButtonRecord_move = procedure(rec : SWFButtonRecord; x : single; y : single); cdecl;
  pfSWFButtonRecord_moveTo = procedure(rec : SWFButtonRecord; x : single; y : single); cdecl;
  pfSWFButtonRecord_rotate = procedure(rec : SWFButtonRecord; deg : single); cdecl;
  pfSWFButtonRecord_rotateTo = procedure(rec : SWFButtonRecord; deg : single); cdecl;
  pfSWFButtonRecord_scale = procedure(rec : SWFButtonRecord; scaleX : single; scaleY : single); cdecl;
  pfSWFButtonRecord_scaleTo = procedure(rec : SWFButtonRecord; scaleX : single; scaleY : single); cdecl;
  pfSWFButtonRecord_skewX = procedure(rec : SWFButtonRecord; skewX : single); cdecl;
  pfSWFButtonRecord_skewXTo = procedure(rec : SWFButtonRecord; skewX : single); cdecl;
  pfSWFButtonRecord_skewY = procedure(rec : SWFButtonRecord; skewY : single); cdecl;
  pfSWFButtonRecord_skewYTo = procedure(rec : SWFButtonRecord; skewY : single); cdecl;

  (****** SWFVideo ******)

  pfdestroySWFVideoStream = procedure(stream : SWFVideoStream); cdecl;
  pfnewSWFVideoStream_fromFile = function(f : pointer {FILE*}) : SWFVideoStream; cdecl;
  pfnewSWFVideoStream_fromInput = function(input : SWFInput) : SWFVideoStream; cdecl;
  pfnewSWFVideoStream = function() : SWFVideoStream; cdecl;
  pfSWFVideoStream_setDimension = procedure(stream : SWFVideoStream; width : integer; height : integer); cdecl;
  pfSWFVideoStream_getNumFrames = function(stream : SWFVideoStream) : integer; cdecl;
  pfSWFVideoStream_hasAudio = function(stream : SWFVideoStream) : integer; cdecl;

  (***** SWFSprite *****)

  pfnewSWFSprite = function() : SWFSprite; cdecl;
  pfdestroySWFSprite = procedure(sprite : SWFSprite); cdecl;

  pfSWFSprite_addBlock = procedure(sprite : SWFSprite; block : SWFBlock); cdecl;

  (***** SWFPosition *****)

  pfnewSWFPosition = function(matrix : SWFMatrix) : SWFPosition; cdecl;
  pfdestroySWFPosition = procedure(position : SWFPosition); cdecl;

  pfSWFPosition_skewX = procedure(position : SWFPosition; x : single); cdecl;
  pfSWFPosition_skewXTo = procedure(position : SWFPosition; x : single); cdecl;
  pfSWFPosition_skewY = procedure(position : SWFPosition; y : single); cdecl;
  pfSWFPosition_skewYTo = procedure(position : SWFPosition; y : single); cdecl;

  pfSWFPosition_scaleX = procedure(position : SWFPosition; x : single); cdecl;
  pfSWFPosition_scaleXTo = procedure(position : SWFPosition; x : single); cdecl;
  pfSWFPosition_scaleY = procedure(position : SWFPosition; y : single); cdecl;
  pfSWFPosition_scaleYTo = procedure(position : SWFPosition; y : single); cdecl;
  pfSWFPosition_scaleXY = procedure(position : SWFPosition; x : single; y : single); cdecl;
  pfSWFPosition_scaleXYTo = procedure(position : SWFPosition; x : single; y : single); cdecl;

  pfSWFPosition_getMatrix = function(p : SWFPosition) : SWFMatrix; cdecl;
  pfSWFPosition_setMatrix = procedure(p : SWFPosition; a : single; b : single; c : single; d : single; x : single; y : single); cdecl;

  pfSWFPosition_rotate = procedure(position : SWFPosition; degrees : single); cdecl;
  pfSWFPosition_rotateTo = procedure(position : SWFPosition; degrees : single); cdecl;

  pfSWFPosition_move = procedure(position : SWFPosition; x : single; y : single); cdecl;
  pfSWFPosition_moveTo = procedure(position : SWFPosition; x : single; y : single); cdecl;

  (***** SWFFilter ***********)

  pfnewSWFShadow = function(angle : single; distance : single; strength : single) : SWFShadow; cdecl;
  pfdestroySWFShadow = procedure(s : SWFShadow); cdecl;

  pfnewSWFBlur = function(blurX : single; blurY : single; passes : integer) : SWFBlur; cdecl;
  pfdestroySWFBlur = procedure(b : SWFBlur); cdecl;

  pfnewSWFFilterMatrix = function(cols : integer; rows : integer; vals : array of single) : SWFFilterMatrix; cdecl;
  pfdestroySWFFilterMatrix = procedure(m : SWFFilterMatrix); cdecl;

  pfdestroySWFFilter = procedure(filter : SWFFilter); cdecl;
  pfnewColorMatrixFilter = function(matrix : SWFFilterMatrix) : SWFFilter; cdecl;
  pfnewConvolutionFilter = function(matrix : SWFFilterMatrix; divisor : single; bias : single; color : SWFColor; flags : integer) : SWFFilter; cdecl;

  pfnewGradientBevelFilter = function(gradient : SWFGradient; blur : SWFBlur; shadow : SWFShadow; flags : integer) : SWFFilter; cdecl;

  pfnewGradientGlowFilter = function(gradient : SWFGradient; blur : SWFBlur; shadow : SWFShadow; flags : integer) : SWFFilter; cdecl;

  pfnewBevelFilter = function(shadowColor : SWFColor; highlightColor : SWFColor; blur : SWFBlur; shadow : SWFShadow; flags : integer) : SWFFilter; cdecl;

  pfnewGlowFilter = function(color : SWFColor; blur : SWFBlur; strength : single; flags : integer) : SWFFilter; cdecl;

  pfnewBlurFilter = function(blur : SWFBlur) : SWFFilter; cdecl;
  pfnewDropShadowFilter = function(color : SWFColor; blur : SWFBlur; shadow : SWFShadow; flags : integer) : SWFFilter; cdecl;

  (***** SWFDisplayItem *****)

  pfSWFDisplayItem_getCharacter = function(item : SWFDisplayItem) : SWFCharacter; cdecl;
  pfSWFDisplayItem_endMask = procedure(item : SWFDisplayItem); cdecl;

  (*
   * Methods for reading position data
   *  - added by David McNab <david@rebirthing.co.nz>
   *)

  pfSWFDisplayItem_get_x = function(item : SWFDisplayItem) : single; cdecl;
  pfSWFDisplayItem_get_y = function(item : SWFDisplayItem) : single; cdecl;
  pfSWFDisplayItem_get_xScale = function(item : SWFDisplayItem) : single; cdecl;
  pfSWFDisplayItem_get_yScale = function(item : SWFDisplayItem) : single; cdecl;
  pfSWFDisplayItem_get_xSkew = function(item : SWFDisplayItem) : single; cdecl;
  pfSWFDisplayItem_get_ySkew = function(item : SWFDisplayItem) : single; cdecl;
  pfSWFDisplayItem_get_rot = function(item : SWFDisplayItem) : single; cdecl;

  pfSWFDisplayItem_move = procedure(item : SWFDisplayItem; x : single; y : single); cdecl;
  pfSWFDisplayItem_moveTo = procedure(item : SWFDisplayItem; x : single; y : single); cdecl;
  pfSWFDisplayItem_rotate = procedure(item : SWFDisplayItem; degrees : single); cdecl;
  pfSWFDisplayItem_rotateTo = procedure(item : SWFDisplayItem; degrees : single); cdecl;
  pfSWFDisplayItem_scale = procedure(item : SWFDisplayItem; x : single; y : single); cdecl;
  pfSWFDisplayItem_scaleTo = procedure(item : SWFDisplayItem; x : single; y : single); cdecl;
  pfSWFDisplayItem_skewX = procedure(item : SWFDisplayItem; x : single); cdecl;
  pfSWFDisplayItem_skewXTo = procedure(item : SWFDisplayItem; x : single); cdecl;
  pfSWFDisplayItem_skewY = procedure(item : SWFDisplayItem; y : single); cdecl;
  pfSWFDisplayItem_skewYTo = procedure(item : SWFDisplayItem; y : single); cdecl;

  pfSWFDisplayItem_getPosition = procedure(item : SWFDisplayItem; var x : single; var y : single); cdecl;
  pfSWFDisplayItem_getRotation = procedure(item : SWFDisplayItem; var degrees : single); cdecl;
  pfSWFDisplayItem_getScale = procedure(item : SWFDisplayItem; var x : single; var y : single); cdecl;
  pfSWFDisplayItem_getSkew = procedure(item : SWFDisplayItem; var x : single; var y : single); cdecl;

  pfSWFDisplayItem_getMatrix = function(item : SWFDisplayItem) : SWFMatrix; cdecl;
  pfSWFDisplayItem_setMatrix = procedure(i : SWFDisplayItem; a : single; b : single; c : single; d : single; x : single; y : single); cdecl;

  pfSWFDisplayItem_getDepth = function(item : SWFDisplayItem) : integer; cdecl;
  pfSWFDisplayItem_setDepth = procedure(item : SWFDisplayItem; depth : integer); cdecl;
  pfSWFDisplayItem_remove = procedure(item : SWFDisplayItem); cdecl;
  pfSWFDisplayItem_setName = procedure(item : SWFDisplayItem; name : pchar); cdecl;
  pfSWFDisplayItem_setMaskLevel = procedure(item : SWFDisplayItem; masklevel : integer); cdecl;
  pfSWFDisplayItem_setRatio = procedure(item : SWFDisplayItem; ratio : single); cdecl;
  pfSWFDisplayItem_setCXform = procedure(item : SWFDisplayItem; cXform : SWFCXform); cdecl;
  pfSWFDisplayItem_setColorAdd = procedure(item : SWFDisplayItem; r : integer; g : integer; b : integer; a : integer); cdecl;
  pfSWFDisplayItem_setColorMult = procedure(item : SWFDisplayItem; r : single; g : single; b : single; a : single); cdecl;

  //#define SWFDisplayItem_addColor SWFDisplayItem_setColorAdd
  //#define SWFDisplayItem_multColor SWFDisplayItem_setColorMult

  pfSWFDisplayItem_addAction = procedure(item : SWFDisplayItem; action : SWFAction; flags : integer); cdecl;

  pfSWFDisplayItem_cacheAsBitmap = procedure(item : SWFDisplayItem; flag : integer); cdecl;

  pfSWFDisplayItem_setBlendMode = procedure(item : SWFDisplayItem; mode : integer); cdecl;
  pfSWFDisplayItem_addFilter = procedure(item : SWFDisplayItem; filter : SWFFilter); cdecl;
  (***** SWFFill *****)

  (* adds a position object to manipulate SWFFillStyle's matrix *)

  pfnewSWFFill = function(fill : SWFFillStyle) : SWFFill; cdecl;
  pfdestroySWFFill = procedure(fill : SWFFill); cdecl;

  pfSWFFill_skewX = procedure(fill : SWFFill; x : single) {__deprecated}; cdecl;
  pfSWFFill_skewXTo = procedure(fill : SWFFill; x : single) {__deprecated}; cdecl;
  pfSWFFill_skewY = procedure(fill : SWFFill; y : single) {__deprecated}; cdecl;
  pfSWFFill_skewYTo = procedure(fill : SWFFill; y : single) {__deprecated}; cdecl;

  pfSWFFill_scaleX = procedure(fill : SWFFill; x : single) {__deprecated}; cdecl;
  pfSWFFill_scaleXTo = procedure(fill : SWFFill; x : single) {__deprecated}; cdecl;
  pfSWFFill_scaleY = procedure(fill : SWFFill; y : single) {__deprecated}; cdecl;
  pfSWFFill_scaleYTo = procedure(fill : SWFFill; y : single) {__deprecated}; cdecl;
  pfSWFFill_scaleXY = procedure(fill : SWFFill; x : single; y : single) {__deprecated}; cdecl;
  pfSWFFill_scaleXYTo = procedure(fill : SWFFill; x : single; y : single) {__deprecated}; cdecl;

  pfSWFFill_rotate = procedure(fill : SWFFill; degrees : single); cdecl;
  pfSWFFill_rotateTo = procedure(fill : SWFFill; degrees : single); cdecl;

  pfSWFFill_move = procedure(fill : SWFFill; x : single; y : single); cdecl;
  pfSWFFill_moveTo = procedure(fill : SWFFill; x : single; y : single); cdecl;

  pfSWFFill_setMatrix = procedure(fill : SWFFill; a : single; b : single; c : single; d : single; x : single; y : single); cdecl;

  (***** shape_util.h *****)

  pfSWFShape_setLine = procedure(shape : SWFShape; width : word; r : byte; g : byte; b : byte; a : byte); cdecl;

  pfSWFShape_setLine2Filled = procedure(shape : SWFShape; width : word; fill : SWFFillStyle; flags : integer; miterLimit : single); cdecl;

  pfSWFShape_setLine2 = procedure(shape : SWFShape; width : word; r : byte; g : byte; b : byte; a : byte; flags : integer; miterLimit : single); cdecl;

  pfSWFShape_addSolidFill = function(shape : SWFShape; r : byte; g : byte; b : byte; a : byte) : SWFFill; cdecl;
  pfSWFShape_addGradientFill = function(shape : SWFShape; gradient : SWFGradient; flags : byte) : SWFFill; cdecl;
  pfSWFShape_addBitmapFill = function(shape : SWFShape; bitmap : SWFBitmap; flags : byte) : SWFFill; cdecl;

  pfSWFShape_setLeftFill = procedure(shape : SWFShape; fill : SWFFill); cdecl;
  pfSWFShape_setRightFill = procedure(shape : SWFShape; fill : SWFFill); cdecl;

  pfSWFShape_drawArc = procedure(shape : SWFShape; r : single; startAngle : single; endAngle : single); cdecl;
  pfSWFShape_drawCircle = procedure(shape : SWFShape; r : single); cdecl;

  (* draw character c from font font into shape shape at size size *)
  pfSWFShape_drawGlyph = procedure(shape : SWFShape; font : SWFFont; c : word); cdecl;
  pfSWFShape_drawSizedGlyph = procedure(shape : SWFShape; font : SWFFont; c : word; size : integer); cdecl;

    (* Deprecated: *)
    //#define SWFShape_drawFontGlyph(s;f;c) SWFShape_drawGlyph(s;f;c)

  (* approximate a cubic bezier with quadratic segments *)
  (* returns the number of segments used *)
  pfSWFShape_drawCubic = function(shape : SWFShape; bx : single; by : single; cx : single; cy : single; dx : single; dy : single) : integer; cdecl;
  pfSWFShape_drawCubicTo = function(shape : SWFShape; bx : single; by : single; cx : single; cy : single; dx : single; dy : single) : integer; cdecl;
  pfSWFShape_drawCharacterBounds = procedure(shape : SWFShape; character : SWFCharacter); cdecl;

  (***** SWFMovieClip *****)

  pfnewSWFMovieClip = function() : SWFMovieClip; cdecl;
  pfdestroySWFMovieClip = procedure(movieClip : SWFMovieClip); cdecl;

  pfSWFMovieClip_setNumberOfFrames = procedure(clip : SWFMovieClip; frames : integer); cdecl;
  pfSWFMovieClip_nextFrame = procedure(clip : SWFMovieClip); cdecl;
  pfSWFMovieClip_labelFrame = procedure(clip : SWFMovieClip; lbl : pchar); cdecl;

  pfSWFMovieClip_add = function(clip : SWFMovieClip; block : SWFBlock) : SWFDisplayItem; cdecl;
  pfSWFMovieClip_remove = procedure(clip : SWFMovieClip; item : SWFDisplayItem); cdecl;

  pfSWFMovieClip_setSoundStream = procedure(clip : SWFMovieClip; sound : SWFSoundStream; rate : single); cdecl;
  pfSWFMovie_setSoundStreamAt = procedure(movie : SWFMovie; stream : SWFSoundStream; skip : single); cdecl;
  pfSWFMovieClip_startSound = function(clip : SWFMovieClip; sound : SWFSound) : SWFSoundInstance; cdecl;
  pfSWFMovieClip_stopSound = procedure(clip : SWFMovieClip; sound : SWFSound); cdecl;
  pfSWFMovieClip_setScalingGrid = procedure(clip : SWFMovieClip; x : integer; y : integer; w : integer; h : integer); cdecl;
  pfSWFMovieClip_removeScalingGrid = procedure(clip : SWFMovieClip); cdecl;
  pfSWFMovieClip_addInitAction = procedure(clip : SWFMovieClip; action : SWFAction); cdecl;

  (***** SWFPrebuiltClip ****)

  pfdestroySWFPrebuiltClip = procedure(clip : SWFPrebuiltClip); cdecl;
  pfnewSWFPrebuiltClip_fromFile = function(filename : pchar) : SWFPrebuiltClip; cdecl;
  pfnewSWFPrebuiltClip_fromInput = function(input : SWFInput) : SWFPrebuiltClip; cdecl;

  (***** SWFBinaryData *****)

  pfnewSWFBinaryData = function(blob : byte; length : integer) : SWFBinaryData; cdecl;

  (***** SWFMovie *****)

  (*
   * Write the EXPORTASSET tag with informations gathered by calls to
   * SWFMovie_addExport.
   *
   * Call this function to control insertion of the EXPORTASSET tag; which
   * is otherwise written at the END of the SWF.
   *)
  pfSWFMovie_writeExports = procedure(movie : SWFMovie); cdecl;

  pfnewSWFMovie = function() : SWFMovie; cdecl;
  pfnewSWFMovieWithVersion = function(version : integer) : SWFMovie; cdecl;
  pfdestroySWFMovie = procedure(movie : SWFMovie); cdecl;

  pfSWFMovie_setRate = procedure(movie : SWFMovie; rate : single); cdecl;
  pfSWFMovie_setDimension = procedure(movie : SWFMovie; x : single; y : single); cdecl;
  pfSWFMovie_setNumberOfFrames = procedure(movie : SWFMovie; frames : integer); cdecl;

  (*
   * Export the given asset giving it the given linkage symbol.
   *
   * Call SWFMovie_writeExports() when you're done with the exports
   * to actually write the tag. If you don't the tag will be added
   * at the END of the SWF.
   *)
  pfSWFMovie_addExport = procedure(movie : SWFMovie; block : SWFBlock; name : pchar); cdecl;

  pfSWFMovie_assignSymbol = procedure(m : SWFMovie; character : SWFCharacter; name : pchar); cdecl;
  pfSWFMovie_defineScene = procedure(m : SWFMovie; offset : cardinal; name : pchar); cdecl;
  pfSWFMovie_setBackground = procedure(movie : SWFMovie; r : byte; g : byte; b : byte); cdecl;

  pfSWFMovie_setSoundStream = procedure(movie : SWFMovie; sound : SWFSoundStream); cdecl;
  pfSWFMovie_startSound = function(movie : SWFMovie; sound : SWFSound) : SWFSoundInstance; cdecl;
  pfSWFMovie_stopSound = procedure(movie : SWFMovie; sound : SWFSound); cdecl;

  pfSWFMovie_add = function(movie : SWFMovie; ublock : pointer) : SWFDisplayItem; cdecl;
  pfSWFMovie_replace = function(movie : SWFMovie; item : SWFDisplayItem; block : pointer) : integer;

  pfSWFMovie_remove = procedure(movie : SWFMovie; item : SWFDisplayItem); cdecl;

  pfSWFMovie_nextFrame = procedure(movie : SWFMovie); cdecl;
  pfSWFMovie_labelFrame = procedure(movie : SWFMovie; lbl : pchar); cdecl;
  pfSWFMovie_namedAnchor = procedure(movie : SWFMovie; lbl : pchar); cdecl;

  pfSWFMovie_output = function(movie : SWFMovie; method : SWFByteOutputMethod; data : pointer) : integer; cdecl;
  pfSWFMovie_save = function(movie : SWFMovie; filename : pchar) : integer; cdecl;
  pfSWFMovie_output_to_stream = function(movie : SWFMovie; f : pointer {FILE *}) : integer; cdecl;

  (*
   * enable edit protections for a movie
   * This function adds a block that tells flash editors to not edit this movie.
   *)
  pfSWFMovie_protect = procedure(movie : SWFMovie; password : pchar); cdecl;

  pfSWFMovie_setNetworkAccess = procedure(movie : SWFMovie; flag : integer); cdecl;
  pfSWFMovie_addMetadata = procedure(movie : SWFMovie; xml : pchar); cdecl;
  pfSWFMovie_setScriptLimits = procedure(movie : SWFMovie; maxRecursion : integer; timeout : integer); cdecl;
  pfSWFMovie_setTabIndex = procedure(movie : SWFMovie; depth : integer; index : integer); cdecl;

  pfSWFMovie_importCharacter = function(movie : SWFMovie; filename : pchar; name : pchar) : SWFCharacter; cdecl;

  (*
   * Set the function that gets called when a warning occurs within the library
   * This function sets function to be called when a warning occurs within the
   * library. The default function prints the warning message to stdout.
   * Returns the previously-set warning function.
   *)
  pfMing_setWarnFunction = function(func : SWFMsgFunc) : SWFMsgFunc; cdecl;

  (*
   * Set the function that gets called when an error occurs within the library
   * This function sets function to be called when an error occurs within the
   * library. The default function prints the error mesage to stdout and exits.
   * Returns the previously-set error function.
   *)
  pfMing_setErrorFunction = function(func : SWFMsgFunc) : SWFMsgFunc; cdecl;

  function SWFBUTTON_KEYPRESS(c : byte) : integer;
  function SWFBUTTON_ONKEYPRESS(c : byte) : integer;

  function LoadMing : boolean;
  procedure UnloadMing;

var
   hDLL : HMODULE = 0;

var
   Ming_setWarnFunction : pfMing_setWarnFunction;
   Ming_setErrorFunction : pfMing_setErrorFunction;
   Ming_init : pfMing_init;
   Ming_cleanup : pfMing_cleanup;
   Ming_collectGarbage : pfMing_collectGarbage;
   Ming_useConstants : pfMing_useConstants;
   Ming_setCubicThreshold : pfMing_setCubicThreshold;
   Ming_setScale : pfMing_setScale;
   Ming_getScale : pfMing_getScale;
   Ming_useSWFVersion : pfMing_useSWFVersion;
   Ming_setSWFCompression : pfMing_setSWFCompression;
   SWFMatrix_getScaleX : pfSWFMatrix_getScaleX;
   SWFMatrix_getRotate0 : pfSWFMatrix_getRotate0;
   SWFMatrix_getRotate1 : pfSWFMatrix_getRotate1;
   SWFMatrix_getScaleY : pfSWFMatrix_getScaleY;
   SWFMatrix_getTranslateX : pfSWFMatrix_getTranslateX;
   SWFMatrix_getTranslateY : pfSWFMatrix_getTranslateY;
   newSWFInput_file : pfnewSWFInput_file;
   newSWFInput_stream : pfnewSWFInput_stream;
   newSWFInput_buffer : pfnewSWFInput_buffer;
   newSWFInput_allocedBuffer : pfnewSWFInput_allocedBuffer;
   newSWFInput_input : pfnewSWFInput_input;
   destroySWFInput : pfdestroySWFInput;
   SWFInput_length : pfSWFInput_length;
   SWFInput_rewind : pfSWFInput_rewind;
   SWFInput_tell : pfSWFInput_tell;
   SWFInput_seek : pfSWFInput_seek;
   SWFInput_eof : pfSWFInput_eof;
   SWFCharacter_getWidth : pfSWFCharacter_getWidth;
   SWFCharacter_getHeight : pfSWFCharacter_getHeight;
   newSWFBitmap_fromInput : pfnewSWFBitmap_fromInput;
   newSWFBitmap_fromRawImg : pfnewSWFBitmap_fromRawImg;
   destroySWFBitmap : pfdestroySWFBitmap;
   SWFBitmap_getWidth : pfSWFBitmap_getWidth;
   SWFBitmap_getHeight : pfSWFBitmap_getHeight;
   newSWFDBLBitmap : pfnewSWFDBLBitmap;
   newSWFDBLBitmap_fromInput : pfnewSWFDBLBitmap_fromInput;
   newSWFDBLBitmapData_fromPngFile : pfnewSWFDBLBitmapData_fromPngFile;
   newSWFDBLBitmapData_fromPngInput : pfnewSWFDBLBitmapData_fromPngInput;
   newSWFJpegBitmap : pfnewSWFJpegBitmap;
   newSWFJpegBitmap_fromInput : pfnewSWFJpegBitmap_fromInput;
   newSWFJpegWithAlpha : pfnewSWFJpegWithAlpha;
   newSWFJpegWithAlpha_fromInput : pfnewSWFJpegWithAlpha_fromInput;
   newSWFGradient : pfnewSWFGradient;
   destroySWFGradient : pfdestroySWFGradient;
   SWFGradient_addEntry : pfSWFGradient_addEntry;
   SWFGradient_setSpreadMode : pfSWFGradient_setSpreadMode;
   SWFGradient_setInterpolationMode : pfSWFGradient_setInterpolationMode;
   SWFGradient_setFocalPoint : pfSWFGradient_setFocalPoint;
   newSWFSolidFillStyle : pfnewSWFSolidFillStyle;
   newSWFGradientFillStyle : pfnewSWFGradientFillStyle;
   newSWFBitmapFillStyle : pfnewSWFBitmapFillStyle;
   SWFFillStyle_getMatrix : pfSWFFillStyle_getMatrix;
   destroySWFFillStyle : pfdestroySWFFillStyle;
   newSWFLineStyle : pfnewSWFLineStyle;
   newSWFLineStyle2 : pfnewSWFLineStyle2;
   newSWFLineStyle2_filled : pfnewSWFLineStyle2_filled;
   newSWFShape : pfnewSWFShape;
   newSWFShapeFromBitmap : pfnewSWFShapeFromBitmap;
   destroySWFShape : pfdestroySWFShape;
   SWFShape_end : pfSWFShape_end;
   SWFShape_useVersion : pfSWFShape_useVersion;
   SWFShape_getVersion : pfSWFShape_getVersion;
   SWFShape_setRenderHintingFlags : pfSWFShape_setRenderHintingFlags;
   SWFShape_movePenTo : pfSWFShape_movePenTo;
   SWFShape_movePen : pfSWFShape_movePen;
   SWFShape_getPenX : pfSWFShape_getPenX;
   SWFShape_getPenY : pfSWFShape_getPenY;
   SWFShape_getPen : pfSWFShape_getPen;
   SWFShape_drawLineTo : pfSWFShape_drawLineTo;
   SWFShape_drawLine : pfSWFShape_drawLine;
   SWFShape_drawCurveTo : pfSWFShape_drawCurveTo;
   SWFShape_drawCurve : pfSWFShape_drawCurve;
   SWFShape_setLineStyle : pfSWFShape_setLineStyle;
   SWFShape_setLineStyle2 : pfSWFShape_setLineStyle2;
   SWFShape_setLineStyle2filled : pfSWFShape_setLineStyle2filled;
   SWFShape_hideLine : pfSWFShape_hideLine;
   SWFShape_addSolidFillStyle : pfSWFShape_addSolidFillStyle;
   SWFShape_addGradientFillStyle : pfSWFShape_addGradientFillStyle;
   SWFShape_addBitmapFillStyle : pfSWFShape_addBitmapFillStyle;
   SWFShape_setLeftFillStyle : pfSWFShape_setLeftFillStyle;
   SWFShape_setRightFillStyle : pfSWFShape_setRightFillStyle;
   newSWFMorphShape : pfnewSWFMorphShape;
   destroySWFMorph : pfdestroySWFMorph;
   SWFMorph_getShape1 : pfSWFMorph_getShape1;
   SWFMorph_getShape2 : pfSWFMorph_getShape2;
   newSWFFont : pfnewSWFFont;
   newSWFFont_fromFile : pfnewSWFFont_fromFile;
   loadSWFFontFromFile : pfloadSWFFontFromFile;
   destroySWFFont : pfdestroySWFFont;
   SWFFont_getStringWidth : pfSWFFont_getStringWidth;
   SWFFont_getUTF8StringWidth : pfSWFFont_getUTF8StringWidth;
   SWFFont_getWideStringWidth : pfSWFFont_getWideStringWidth;
   SWFFont_getAscent : pfSWFFont_getAscent;
   SWFFont_getDescent : pfSWFFont_getDescent;
   SWFFont_getLeading : pfSWFFont_getLeading;
   newSWFText : pfnewSWFText;
   newSWFText2 : pfnewSWFText2;
   destroySWFText : pfdestroySWFText;
   SWFText_setFont : pfSWFText_setFont;
   SWFText_setHeight : pfSWFText_setHeight;
   SWFText_setColor : pfSWFText_setColor;
   SWFText_moveTo : pfSWFText_moveTo;
   SWFText_addString : pfSWFText_addString;
   SWFText_addUTF8String : pfSWFText_addUTF8String;
   SWFText_addWideString : pfSWFText_addWideString;
   SWFText_setSpacing : pfSWFText_setSpacing;
   SWFText_getStringWidth : pfSWFText_getStringWidth;
   SWFText_getUTF8StringWidth : pfSWFText_getUTF8StringWidth;
   SWFText_getWideStringWidth : pfSWFText_getWideStringWidth;
   SWFText_getAscent : pfSWFText_getAscent;
   SWFText_getDescent : pfSWFText_getDescent;
   SWFText_getLeading : pfSWFText_getLeading;
   newSWFBrowserFont : pfnewSWFBrowserFont;
   destroySWFBrowserFont : pfdestroySWFBrowserFont;
   SWFMovie_addFont : pfSWFMovie_addFont;
   SWFFontCharacter_addChars : pfSWFFontCharacter_addChars;
   SWFFontCharacter_addUTF8Chars : pfSWFFontCharacter_addUTF8Chars;
   SWFMovie_importFont : pfSWFMovie_importFont;
   SWFFontCharacter_addAllChars : pfSWFFontCharacter_addAllChars;
   newSWFTextField : pfnewSWFTextField;
   destroySWFTextField : pfdestroySWFTextField;
   SWFTextField_setFont : pfSWFTextField_setFont;
   SWFTextField_setBounds : pfSWFTextField_setBounds;
   SWFTextField_setFlags : pfSWFTextField_setFlags;
   SWFTextField_setColor : pfSWFTextField_setColor;
   SWFTextField_setVariableName : pfSWFTextField_setVariableName;
   SWFTextField_addString : pfSWFTextField_addString;
   SWFTextField_addUTF8String : pfSWFTextField_addUTF8String;
   SWFTextField_setHeight : pfSWFTextField_setHeight;
   SWFTextField_setFieldHeight : pfSWFTextField_setFieldHeight;
   SWFTextField_setLeftMargin : pfSWFTextField_setLeftMargin;
   SWFTextField_setRightMargin : pfSWFTextField_setRightMargin;
   SWFTextField_setIndentation : pfSWFTextField_setIndentation;
   SWFTextField_setLineSpacing : pfSWFTextField_setLineSpacing;
   SWFTextField_setPadding : pfSWFTextField_setPadding;
   SWFTextField_addChars : pfSWFTextField_addChars;
   SWFTextField_setAlignment : pfSWFTextField_setAlignment;
   SWFTextField_setLength : pfSWFTextField_setLength;
   newSWFSoundStream : pfnewSWFSoundStream;
   newSWFSoundStreamFromFileno : pfnewSWFSoundStreamFromFileno;
   newSWFSoundStream_fromInput : pfnewSWFSoundStream_fromInput;
   SWFSoundStream_getFrames : pfSWFSoundStream_getFrames;
   destroySWFSoundStream : pfdestroySWFSoundStream;
   newSWFSound : pfnewSWFSound;
   newSWFSoundFromFileno : pfnewSWFSoundFromFileno;
   newSWFSound_fromInput : pfnewSWFSound_fromInput;
   destroySWFSound : pfdestroySWFSound;
   SWFSoundInstance_setNoMultiple : pfSWFSoundInstance_setNoMultiple;
   SWFSoundInstance_setLoopInPoint : pfSWFSoundInstance_setLoopInPoint;
   SWFSoundInstance_setLoopOutPoint : pfSWFSoundInstance_setLoopOutPoint;
   SWFSoundInstance_setLoopCount : pfSWFSoundInstance_setLoopCount;
   SWFSoundInstance_addEnvelope : pfSWFSoundInstance_addEnvelope;
   newSWFCXform : pfnewSWFCXform;
   newSWFAddCXform : pfnewSWFAddCXform;
   newSWFMultCXform : pfnewSWFMultCXform;
   destroySWFCXform : pfdestroySWFCXform;
   SWFCXform_setColorAdd : pfSWFCXform_setColorAdd;
   SWFCXform_setColorMult : pfSWFCXform_setColorMult;
   newSWFAction : pfnewSWFAction;
   newSWFAction_fromFile : pfnewSWFAction_fromFile;
   compileSWFActionCode : pfcompileSWFActionCode;
   destroySWFAction : pfdestroySWFAction;
   SWFAction_getByteCode : pfSWFAction_getByteCode;
   newSWFButton : pfnewSWFButton;
   destroySWFButton : pfdestroySWFButton;
   SWFButton_addShape : pfSWFButton_addShape;
   SWFButton_addCharacter : pfSWFButton_addCharacter;
   SWFButton_addAction : pfSWFButton_addAction;
   SWFButton_addSound : pfSWFButton_addSound;
   SWFButton_setMenu : pfSWFButton_setMenu;
   SWFButton_setScalingGrid : pfSWFButton_setScalingGrid;
   SWFButton_removeScalingGrid : pfSWFButton_removeScalingGrid;
   SWFButtonRecord_addFilter : pfSWFButtonRecord_addFilter;
   SWFButtonRecord_setBlendMode : pfSWFButtonRecord_setBlendMode;
   SWFButtonRecord_move : pfSWFButtonRecord_move;
   SWFButtonRecord_moveTo : pfSWFButtonRecord_moveTo;
   SWFButtonRecord_rotate : pfSWFButtonRecord_rotate;
   SWFButtonRecord_rotateTo : pfSWFButtonRecord_rotateTo;
   SWFButtonRecord_scale : pfSWFButtonRecord_scale;
   SWFButtonRecord_scaleTo : pfSWFButtonRecord_scaleTo;
   SWFButtonRecord_skewX : pfSWFButtonRecord_skewX;
   SWFButtonRecord_skewXTo : pfSWFButtonRecord_skewXTo;
   SWFButtonRecord_skewY : pfSWFButtonRecord_skewY;
   SWFButtonRecord_skewYTo : pfSWFButtonRecord_skewYTo;
   destroySWFVideoStream : pfdestroySWFVideoStream;
   newSWFVideoStream_fromFile : pfnewSWFVideoStream_fromFile;
   newSWFVideoStream_fromInput : pfnewSWFVideoStream_fromInput;
   newSWFVideoStream : pfnewSWFVideoStream;
   SWFVideoStream_setDimension : pfSWFVideoStream_setDimension;
   SWFVideoStream_getNumFrames : pfSWFVideoStream_getNumFrames;
   SWFVideoStream_hasAudio : pfSWFVideoStream_hasAudio;
   newSWFSprite : pfnewSWFSprite;
   destroySWFSprite : pfdestroySWFSprite;
   SWFSprite_addBlock : pfSWFSprite_addBlock;
   newSWFPosition : pfnewSWFPosition;
   destroySWFPosition : pfdestroySWFPosition;
   SWFPosition_skewX : pfSWFPosition_skewX;
   SWFPosition_skewXTo : pfSWFPosition_skewXTo;
   SWFPosition_skewY : pfSWFPosition_skewY;
   SWFPosition_skewYTo : pfSWFPosition_skewYTo;
   SWFPosition_scaleX : pfSWFPosition_scaleX;
   SWFPosition_scaleXTo : pfSWFPosition_scaleXTo;
   SWFPosition_scaleY : pfSWFPosition_scaleY;
   SWFPosition_scaleYTo : pfSWFPosition_scaleYTo;
   SWFPosition_scaleXY : pfSWFPosition_scaleXY;
   SWFPosition_scaleXYTo : pfSWFPosition_scaleXYTo;
   SWFPosition_getMatrix : pfSWFPosition_getMatrix;
   SWFPosition_setMatrix : pfSWFPosition_setMatrix;
   SWFPosition_rotate : pfSWFPosition_rotate;
   SWFPosition_rotateTo : pfSWFPosition_rotateTo;
   SWFPosition_move : pfSWFPosition_move;
   SWFPosition_moveTo : pfSWFPosition_moveTo;
   newSWFShadow : pfnewSWFShadow;
   destroySWFShadow : pfdestroySWFShadow;
   newSWFBlur : pfnewSWFBlur;
   destroySWFBlur : pfdestroySWFBlur;
   newSWFFilterMatrix : pfnewSWFFilterMatrix;
   destroySWFFilterMatrix : pfdestroySWFFilterMatrix;
   destroySWFFilter : pfdestroySWFFilter;
   newColorMatrixFilter : pfnewColorMatrixFilter;
   newConvolutionFilter : pfnewConvolutionFilter;
   newGradientBevelFilter : pfnewGradientBevelFilter;
   newGradientGlowFilter : pfnewGradientGlowFilter;
   newBevelFilter : pfnewBevelFilter;
   newGlowFilter : pfnewGlowFilter;
   newBlurFilter : pfnewBlurFilter;
   newDropShadowFilter : pfnewDropShadowFilter;
   SWFDisplayItem_getCharacter : pfSWFDisplayItem_getCharacter;
   SWFDisplayItem_endMask : pfSWFDisplayItem_endMask;
   SWFDisplayItem_get_x : pfSWFDisplayItem_get_x;
   SWFDisplayItem_get_y : pfSWFDisplayItem_get_y;
   SWFDisplayItem_get_xScale : pfSWFDisplayItem_get_xScale;
   SWFDisplayItem_get_yScale : pfSWFDisplayItem_get_yScale;
   SWFDisplayItem_get_xSkew : pfSWFDisplayItem_get_xSkew;
   SWFDisplayItem_get_ySkew : pfSWFDisplayItem_get_ySkew;
   SWFDisplayItem_get_rot : pfSWFDisplayItem_get_rot;
   SWFDisplayItem_move : pfSWFDisplayItem_move;
   SWFDisplayItem_moveTo : pfSWFDisplayItem_moveTo;
   SWFDisplayItem_rotate : pfSWFDisplayItem_rotate;
   SWFDisplayItem_rotateTo : pfSWFDisplayItem_rotateTo;
   SWFDisplayItem_scale : pfSWFDisplayItem_scale;
   SWFDisplayItem_scaleTo : pfSWFDisplayItem_scaleTo;
   SWFDisplayItem_skewX : pfSWFDisplayItem_skewX;
   SWFDisplayItem_skewXTo : pfSWFDisplayItem_skewXTo;
   SWFDisplayItem_skewY : pfSWFDisplayItem_skewY;
   SWFDisplayItem_skewYTo : pfSWFDisplayItem_skewYTo;
   SWFDisplayItem_getPosition : pfSWFDisplayItem_getPosition;
   SWFDisplayItem_getRotation : pfSWFDisplayItem_getRotation;
   SWFDisplayItem_getScale : pfSWFDisplayItem_getScale;
   SWFDisplayItem_getSkew : pfSWFDisplayItem_getSkew;
   SWFDisplayItem_getMatrix : pfSWFDisplayItem_getMatrix;
   SWFDisplayItem_setMatrix : pfSWFDisplayItem_setMatrix;
   SWFDisplayItem_getDepth : pfSWFDisplayItem_getDepth;
   SWFDisplayItem_setDepth : pfSWFDisplayItem_setDepth;
   SWFDisplayItem_remove : pfSWFDisplayItem_remove;
   SWFDisplayItem_setName : pfSWFDisplayItem_setName;
   SWFDisplayItem_setMaskLevel : pfSWFDisplayItem_setMaskLevel;
   SWFDisplayItem_setRatio : pfSWFDisplayItem_setRatio;
   SWFDisplayItem_setCXform : pfSWFDisplayItem_setCXform;
   SWFDisplayItem_setColorAdd : pfSWFDisplayItem_setColorAdd;
   SWFDisplayItem_setColorMult : pfSWFDisplayItem_setColorMult;
   SWFDisplayItem_addAction : pfSWFDisplayItem_addAction;
   SWFDisplayItem_cacheAsBitmap : pfSWFDisplayItem_cacheAsBitmap;
   SWFDisplayItem_setBlendMode : pfSWFDisplayItem_setBlendMode;
   SWFDisplayItem_addFilter : pfSWFDisplayItem_addFilter;
   newSWFFill : pfnewSWFFill;
   destroySWFFill : pfdestroySWFFill;
   SWFFill_skewX : pfSWFFill_skewX;
   SWFFill_skewXTo : pfSWFFill_skewXTo;
   SWFFill_skewY : pfSWFFill_skewY;
   SWFFill_skewYTo : pfSWFFill_skewYTo;
   SWFFill_scaleX : pfSWFFill_scaleX;
   SWFFill_scaleXTo : pfSWFFill_scaleXTo;
   SWFFill_scaleY : pfSWFFill_scaleY;
   SWFFill_scaleYTo : pfSWFFill_scaleYTo;
   SWFFill_scaleXY : pfSWFFill_scaleXY;
   SWFFill_scaleXYTo : pfSWFFill_scaleXYTo;
   SWFFill_rotate : pfSWFFill_rotate;
   SWFFill_rotateTo : pfSWFFill_rotateTo;
   SWFFill_move : pfSWFFill_move;
   SWFFill_moveTo : pfSWFFill_moveTo;
   SWFFill_setMatrix : pfSWFFill_setMatrix;
   SWFShape_setLine : pfSWFShape_setLine;
   SWFShape_setLine2Filled : pfSWFShape_setLine2Filled;
   SWFShape_setLine2 : pfSWFShape_setLine2;
   SWFShape_addSolidFill : pfSWFShape_addSolidFill;
   SWFShape_addGradientFill : pfSWFShape_addGradientFill;
   SWFShape_addBitmapFill : pfSWFShape_addBitmapFill;
   SWFShape_setLeftFill : pfSWFShape_setLeftFill;
   SWFShape_setRightFill : pfSWFShape_setRightFill;
   SWFShape_drawArc : pfSWFShape_drawArc;
   SWFShape_drawCircle : pfSWFShape_drawCircle;
   SWFShape_drawGlyph : pfSWFShape_drawGlyph;
   SWFShape_drawSizedGlyph : pfSWFShape_drawSizedGlyph;
   SWFShape_drawCubic : pfSWFShape_drawCubic;
   SWFShape_drawCubicTo : pfSWFShape_drawCubicTo;
   SWFShape_drawCharacterBounds : pfSWFShape_drawCharacterBounds;
   newSWFMovieClip : pfnewSWFMovieClip;
   destroySWFMovieClip : pfdestroySWFMovieClip;
   SWFMovieClip_setNumberOfFrames : pfSWFMovieClip_setNumberOfFrames;
   SWFMovieClip_nextFrame : pfSWFMovieClip_nextFrame;
   SWFMovieClip_labelFrame : pfSWFMovieClip_labelFrame;
   SWFMovieClip_add : pfSWFMovieClip_add;
   SWFMovieClip_remove : pfSWFMovieClip_remove;
   SWFMovieClip_setSoundStream : pfSWFMovieClip_setSoundStream;
   SWFMovie_setSoundStreamAt : pfSWFMovie_setSoundStreamAt;
   SWFMovieClip_startSound : pfSWFMovieClip_startSound;
   SWFMovieClip_stopSound : pfSWFMovieClip_stopSound;
   SWFMovieClip_setScalingGrid : pfSWFMovieClip_setScalingGrid;
   SWFMovieClip_removeScalingGrid : pfSWFMovieClip_removeScalingGrid;
   SWFMovieClip_addInitAction : pfSWFMovieClip_addInitAction;
   destroySWFPrebuiltClip : pfdestroySWFPrebuiltClip;
   newSWFPrebuiltClip_fromFile : pfnewSWFPrebuiltClip_fromFile;
   newSWFPrebuiltClip_fromInput : pfnewSWFPrebuiltClip_fromInput;
   newSWFBinaryData : pfnewSWFBinaryData;
   SWFMovie_writeExports : pfSWFMovie_writeExports;
   newSWFMovie : pfnewSWFMovie;
   newSWFMovieWithVersion : pfnewSWFMovieWithVersion;
   destroySWFMovie : pfdestroySWFMovie;
   SWFMovie_setRate : pfSWFMovie_setRate;
   SWFMovie_setDimension : pfSWFMovie_setDimension;
   SWFMovie_setNumberOfFrames : pfSWFMovie_setNumberOfFrames;
   SWFMovie_addExport : pfSWFMovie_addExport;
   SWFMovie_assignSymbol : pfSWFMovie_assignSymbol;
   SWFMovie_defineScene : pfSWFMovie_defineScene;
   SWFMovie_setBackground : pfSWFMovie_setBackground;
   SWFMovie_setSoundStream : pfSWFMovie_setSoundStream;
   SWFMovie_startSound : pfSWFMovie_startSound;
   SWFMovie_stopSound : pfSWFMovie_stopSound;
   SWFMovie_add : pfSWFMovie_add;
   SWFMovie_replace : pfSWFMovie_replace;
   SWFMovie_remove : pfSWFMovie_remove;
   SWFMovie_nextFrame : pfSWFMovie_nextFrame;
   SWFMovie_labelFrame : pfSWFMovie_labelFrame;
   SWFMovie_namedAnchor : pfSWFMovie_namedAnchor;
   SWFMovie_output : pfSWFMovie_output;
   SWFMovie_save : pfSWFMovie_save;
   SWFMovie_output_to_stream : pfSWFMovie_output_to_stream;
   SWFMovie_protect : pfSWFMovie_protect;
   SWFMovie_setNetworkAccess : pfSWFMovie_setNetworkAccess;
   SWFMovie_addMetadata : pfSWFMovie_addMetadata;
   SWFMovie_setScriptLimits : pfSWFMovie_setScriptLimits;
   SWFMovie_setTabIndex : pfSWFMovie_setTabIndex;
   SWFMovie_importCharacter : pfSWFMovie_importCharacter;

implementation

uses
  windows;

function SWFBUTTON_KEYPRESS(c : byte) : integer;
begin
  SWFBUTTON_KEYPRESS := (((c) and $7f) shl 9);
end;

function SWFBUTTON_ONKEYPRESS(c : byte) : integer;
begin
  SWFBUTTON_ONKEYPRESS := (((c) and $7f) shl 9);
end;

procedure UnloadMing;
begin
  if (hDLL = 0) then
    exit;
  FreeLibrary(hDLL);
  hDLL := 0;
end;

function LoadMing : boolean;
begin

  if (hDLL <> 0) then
  begin
    LoadMing := true;
    exit;
  end;

  LoadMing := false;

  hDLL := LoadLibrary('ming.dll');
  if (hDLL = 0) then
     exit;

  Ming_setWarnFunction := pfMing_setWarnFunction(GetProcAddress(hDLL, 'Ming_setWarnFunction'));
  Ming_setErrorFunction := pfMing_setErrorFunction(GetProcAddress(hDLL, 'Ming_setErrorFunction'));
  Ming_init := pfMing_init(GetProcAddress(hDLL, 'Ming_init'));
  Ming_cleanup := pfMing_cleanup(GetProcAddress(hDLL, 'Ming_cleanup'));
  Ming_collectGarbage := pfMing_collectGarbage(GetProcAddress(hDLL, 'Ming_collectGarbage'));
  Ming_useConstants := pfMing_useConstants(GetProcAddress(hDLL, 'Ming_useConstants'));
  Ming_setCubicThreshold := pfMing_setCubicThreshold(GetProcAddress(hDLL, 'Ming_setCubicThreshold'));
  Ming_setScale := pfMing_setScale(GetProcAddress(hDLL, 'Ming_setScale'));
  Ming_getScale := pfMing_getScale(GetProcAddress(hDLL, 'Ming_getScale'));
  Ming_useSWFVersion := pfMing_useSWFVersion(GetProcAddress(hDLL, 'Ming_useSWFVersion'));
  Ming_setSWFCompression := pfMing_setSWFCompression(GetProcAddress(hDLL, 'Ming_setSWFCompression'));
  SWFMatrix_getScaleX := pfSWFMatrix_getScaleX(GetProcAddress(hDLL, 'SWFMatrix_getScaleX'));
  SWFMatrix_getRotate0 := pfSWFMatrix_getRotate0(GetProcAddress(hDLL, 'SWFMatrix_getRotate0'));
  SWFMatrix_getRotate1 := pfSWFMatrix_getRotate1(GetProcAddress(hDLL, 'SWFMatrix_getRotate1'));
  SWFMatrix_getScaleY := pfSWFMatrix_getScaleY(GetProcAddress(hDLL, 'SWFMatrix_getScaleY'));
  SWFMatrix_getTranslateX := pfSWFMatrix_getTranslateX(GetProcAddress(hDLL, 'SWFMatrix_getTranslateX'));
  SWFMatrix_getTranslateY := pfSWFMatrix_getTranslateY(GetProcAddress(hDLL, 'SWFMatrix_getTranslateY'));
  newSWFInput_file := pfnewSWFInput_file(GetProcAddress(hDLL, 'newSWFInput_file'));
  newSWFInput_stream := pfnewSWFInput_stream(GetProcAddress(hDLL, 'newSWFInput_stream'));
  newSWFInput_buffer := pfnewSWFInput_buffer(GetProcAddress(hDLL, 'newSWFInput_buffer'));
  newSWFInput_allocedBuffer := pfnewSWFInput_allocedBuffer(GetProcAddress(hDLL, 'newSWFInput_allocedBuffer'));
  newSWFInput_input := pfnewSWFInput_input(GetProcAddress(hDLL, 'newSWFInput_input'));
  destroySWFInput := pfdestroySWFInput(GetProcAddress(hDLL, 'destroySWFInput'));
  SWFInput_length := pfSWFInput_length(GetProcAddress(hDLL, 'SWFInput_length'));
  SWFInput_rewind := pfSWFInput_rewind(GetProcAddress(hDLL, 'SWFInput_rewind'));
  SWFInput_tell := pfSWFInput_tell(GetProcAddress(hDLL, 'SWFInput_tell'));
  SWFInput_seek := pfSWFInput_seek(GetProcAddress(hDLL, 'SWFInput_seek'));
  SWFInput_eof := pfSWFInput_eof(GetProcAddress(hDLL, 'SWFInput_eof'));
  SWFCharacter_getWidth := pfSWFCharacter_getWidth(GetProcAddress(hDLL, 'SWFCharacter_getWidth'));
  SWFCharacter_getHeight := pfSWFCharacter_getHeight(GetProcAddress(hDLL, 'SWFCharacter_getHeight'));
  newSWFBitmap_fromInput := pfnewSWFBitmap_fromInput(GetProcAddress(hDLL, 'newSWFBitmap_fromInput'));
  newSWFBitmap_fromRawImg := pfnewSWFBitmap_fromRawImg(GetProcAddress(hDLL, 'newSWFBitmap_fromRawImg'));
  destroySWFBitmap := pfdestroySWFBitmap(GetProcAddress(hDLL, 'destroySWFBitmap'));
  SWFBitmap_getWidth := pfSWFBitmap_getWidth(GetProcAddress(hDLL, 'SWFBitmap_getWidth'));
  SWFBitmap_getHeight := pfSWFBitmap_getHeight(GetProcAddress(hDLL, 'SWFBitmap_getHeight'));
  newSWFDBLBitmap := pfnewSWFDBLBitmap(GetProcAddress(hDLL, 'newSWFDBLBitmap'));
  newSWFDBLBitmap_fromInput := pfnewSWFDBLBitmap_fromInput(GetProcAddress(hDLL, 'newSWFDBLBitmap_fromInput'));
  newSWFDBLBitmapData_fromPngFile := pfnewSWFDBLBitmapData_fromPngFile(GetProcAddress(hDLL, 'newSWFDBLBitmapData_fromPngFile'));
  newSWFDBLBitmapData_fromPngInput := pfnewSWFDBLBitmapData_fromPngInput(GetProcAddress(hDLL, 'newSWFDBLBitmapData_fromPngInput'));
  newSWFJpegBitmap := pfnewSWFJpegBitmap(GetProcAddress(hDLL, 'newSWFJpegBitmap'));
  newSWFJpegBitmap_fromInput := pfnewSWFJpegBitmap_fromInput(GetProcAddress(hDLL, 'newSWFJpegBitmap_fromInput'));
  newSWFJpegWithAlpha := pfnewSWFJpegWithAlpha(GetProcAddress(hDLL, 'newSWFJpegWithAlpha'));
  newSWFJpegWithAlpha_fromInput := pfnewSWFJpegWithAlpha_fromInput(GetProcAddress(hDLL, 'newSWFJpegWithAlpha_fromInput'));
  newSWFGradient := pfnewSWFGradient(GetProcAddress(hDLL, 'newSWFGradient'));
  destroySWFGradient := pfdestroySWFGradient(GetProcAddress(hDLL, 'destroySWFGradient'));
  SWFGradient_addEntry := pfSWFGradient_addEntry(GetProcAddress(hDLL, 'SWFGradient_addEntry'));
  SWFGradient_setSpreadMode := pfSWFGradient_setSpreadMode(GetProcAddress(hDLL, 'SWFGradient_setSpreadMode'));
  SWFGradient_setInterpolationMode := pfSWFGradient_setInterpolationMode(GetProcAddress(hDLL, 'SWFGradient_setInterpolationMode'));
  SWFGradient_setFocalPoint := pfSWFGradient_setFocalPoint(GetProcAddress(hDLL, 'SWFGradient_setFocalPoint'));
  newSWFSolidFillStyle := pfnewSWFSolidFillStyle(GetProcAddress(hDLL, 'newSWFSolidFillStyle'));
  newSWFGradientFillStyle := pfnewSWFGradientFillStyle(GetProcAddress(hDLL, 'newSWFGradientFillStyle'));
  newSWFBitmapFillStyle := pfnewSWFBitmapFillStyle(GetProcAddress(hDLL, 'newSWFBitmapFillStyle'));
  SWFFillStyle_getMatrix := pfSWFFillStyle_getMatrix(GetProcAddress(hDLL, 'SWFFillStyle_getMatrix'));
  destroySWFFillStyle := pfdestroySWFFillStyle(GetProcAddress(hDLL, 'destroySWFFillStyle'));
  newSWFLineStyle := pfnewSWFLineStyle(GetProcAddress(hDLL, 'newSWFLineStyle'));
  newSWFLineStyle2 := pfnewSWFLineStyle2(GetProcAddress(hDLL, 'newSWFLineStyle2'));
  newSWFLineStyle2_filled := pfnewSWFLineStyle2_filled(GetProcAddress(hDLL, 'newSWFLineStyle2_filled'));
  newSWFShape := pfnewSWFShape(GetProcAddress(hDLL, 'newSWFShape'));
  newSWFShapeFromBitmap := pfnewSWFShapeFromBitmap(GetProcAddress(hDLL, 'newSWFShapeFromBitmap'));
  destroySWFShape := pfdestroySWFShape(GetProcAddress(hDLL, 'destroySWFShape'));
  SWFShape_end := pfSWFShape_end(GetProcAddress(hDLL, 'SWFShape_end'));
  SWFShape_useVersion := pfSWFShape_useVersion(GetProcAddress(hDLL, 'SWFShape_useVersion'));
  SWFShape_getVersion := pfSWFShape_getVersion(GetProcAddress(hDLL, 'SWFShape_getVersion'));
  SWFShape_setRenderHintingFlags := pfSWFShape_setRenderHintingFlags(GetProcAddress(hDLL, 'SWFShape_setRenderHintingFlags'));
  SWFShape_movePenTo := pfSWFShape_movePenTo(GetProcAddress(hDLL, 'SWFShape_movePenTo'));
  SWFShape_movePen := pfSWFShape_movePen(GetProcAddress(hDLL, 'SWFShape_movePen'));
  SWFShape_getPenX := pfSWFShape_getPenX(GetProcAddress(hDLL, 'SWFShape_getPenX'));
  SWFShape_getPenY := pfSWFShape_getPenY(GetProcAddress(hDLL, 'SWFShape_getPenY'));
  SWFShape_getPen := pfSWFShape_getPen(GetProcAddress(hDLL, 'SWFShape_getPen'));
  SWFShape_drawLineTo := pfSWFShape_drawLineTo(GetProcAddress(hDLL, 'SWFShape_drawLineTo'));
  SWFShape_drawLine := pfSWFShape_drawLine(GetProcAddress(hDLL, 'SWFShape_drawLine'));
  SWFShape_drawCurveTo := pfSWFShape_drawCurveTo(GetProcAddress(hDLL, 'SWFShape_drawCurveTo'));
  SWFShape_drawCurve := pfSWFShape_drawCurve(GetProcAddress(hDLL, 'SWFShape_drawCurve'));
  SWFShape_setLineStyle := pfSWFShape_setLineStyle(GetProcAddress(hDLL, 'SWFShape_setLineStyle'));
  SWFShape_setLineStyle2 := pfSWFShape_setLineStyle2(GetProcAddress(hDLL, 'SWFShape_setLineStyle2'));
  SWFShape_setLineStyle2filled := pfSWFShape_setLineStyle2filled(GetProcAddress(hDLL, 'SWFShape_setLineStyle2filled'));
  SWFShape_hideLine := pfSWFShape_hideLine(GetProcAddress(hDLL, 'SWFShape_hideLine'));
  SWFShape_addSolidFillStyle := pfSWFShape_addSolidFillStyle(GetProcAddress(hDLL, 'SWFShape_addSolidFillStyle'));
  SWFShape_addGradientFillStyle := pfSWFShape_addGradientFillStyle(GetProcAddress(hDLL, 'SWFShape_addGradientFillStyle'));
  SWFShape_addBitmapFillStyle := pfSWFShape_addBitmapFillStyle(GetProcAddress(hDLL, 'SWFShape_addBitmapFillStyle'));
  SWFShape_setLeftFillStyle := pfSWFShape_setLeftFillStyle(GetProcAddress(hDLL, 'SWFShape_setLeftFillStyle'));
  SWFShape_setRightFillStyle := pfSWFShape_setRightFillStyle(GetProcAddress(hDLL, 'SWFShape_setRightFillStyle'));
  newSWFMorphShape := pfnewSWFMorphShape(GetProcAddress(hDLL, 'newSWFMorphShape'));
  destroySWFMorph := pfdestroySWFMorph(GetProcAddress(hDLL, 'destroySWFMorph'));
  SWFMorph_getShape1 := pfSWFMorph_getShape1(GetProcAddress(hDLL, 'SWFMorph_getShape1'));
  SWFMorph_getShape2 := pfSWFMorph_getShape2(GetProcAddress(hDLL, 'SWFMorph_getShape2'));
  newSWFFont := pfnewSWFFont(GetProcAddress(hDLL, 'newSWFFont'));
  newSWFFont_fromFile := pfnewSWFFont_fromFile(GetProcAddress(hDLL, 'newSWFFont_fromFile'));
  loadSWFFontFromFile := pfloadSWFFontFromFile(GetProcAddress(hDLL, 'loadSWFFontFromFile'));
  destroySWFFont := pfdestroySWFFont(GetProcAddress(hDLL, 'destroySWFFont'));
  SWFFont_getStringWidth := pfSWFFont_getStringWidth(GetProcAddress(hDLL, 'SWFFont_getStringWidth'));
  SWFFont_getUTF8StringWidth := pfSWFFont_getUTF8StringWidth(GetProcAddress(hDLL, 'SWFFont_getUTF8StringWidth'));
  SWFFont_getWideStringWidth := pfSWFFont_getWideStringWidth(GetProcAddress(hDLL, 'SWFFont_getWideStringWidth'));
  SWFFont_getAscent := pfSWFFont_getAscent(GetProcAddress(hDLL, 'SWFFont_getAscent'));
  SWFFont_getDescent := pfSWFFont_getDescent(GetProcAddress(hDLL, 'SWFFont_getDescent'));
  SWFFont_getLeading := pfSWFFont_getLeading(GetProcAddress(hDLL, 'SWFFont_getLeading'));
  newSWFText := pfnewSWFText(GetProcAddress(hDLL, 'newSWFText'));
  newSWFText2 := pfnewSWFText2(GetProcAddress(hDLL, 'newSWFText2'));
  destroySWFText := pfdestroySWFText(GetProcAddress(hDLL, 'destroySWFText'));
  SWFText_setFont := pfSWFText_setFont(GetProcAddress(hDLL, 'SWFText_setFont'));
  SWFText_setHeight := pfSWFText_setHeight(GetProcAddress(hDLL, 'SWFText_setHeight'));
  SWFText_setColor := pfSWFText_setColor(GetProcAddress(hDLL, 'SWFText_setColor'));
  SWFText_moveTo := pfSWFText_moveTo(GetProcAddress(hDLL, 'SWFText_moveTo'));
  SWFText_addString := pfSWFText_addString(GetProcAddress(hDLL, 'SWFText_addString'));
  SWFText_addUTF8String := pfSWFText_addUTF8String(GetProcAddress(hDLL, 'SWFText_addUTF8String'));
  SWFText_addWideString := pfSWFText_addWideString(GetProcAddress(hDLL, 'SWFText_addWideString'));
  SWFText_setSpacing := pfSWFText_setSpacing(GetProcAddress(hDLL, 'SWFText_setSpacing'));
  SWFText_getStringWidth := pfSWFText_getStringWidth(GetProcAddress(hDLL, 'SWFText_getStringWidth'));
  SWFText_getUTF8StringWidth := pfSWFText_getUTF8StringWidth(GetProcAddress(hDLL, 'SWFText_getUTF8StringWidth'));
  SWFText_getWideStringWidth := pfSWFText_getWideStringWidth(GetProcAddress(hDLL, 'SWFText_getWideStringWidth'));
  SWFText_getAscent := pfSWFText_getAscent(GetProcAddress(hDLL, 'SWFText_getAscent'));
  SWFText_getDescent := pfSWFText_getDescent(GetProcAddress(hDLL, 'SWFText_getDescent'));
  SWFText_getLeading := pfSWFText_getLeading(GetProcAddress(hDLL, 'SWFText_getLeading'));
  newSWFBrowserFont := pfnewSWFBrowserFont(GetProcAddress(hDLL, 'newSWFBrowserFont'));
  destroySWFBrowserFont := pfdestroySWFBrowserFont(GetProcAddress(hDLL, 'destroySWFBrowserFont'));
  SWFMovie_addFont := pfSWFMovie_addFont(GetProcAddress(hDLL, 'SWFMovie_addFont'));
  SWFFontCharacter_addChars := pfSWFFontCharacter_addChars(GetProcAddress(hDLL, 'SWFFontCharacter_addChars'));
  SWFFontCharacter_addUTF8Chars := pfSWFFontCharacter_addUTF8Chars(GetProcAddress(hDLL, 'SWFFontCharacter_addUTF8Chars'));
  SWFMovie_importFont := pfSWFMovie_importFont(GetProcAddress(hDLL, 'SWFMovie_importFont'));
  SWFFontCharacter_addAllChars := pfSWFFontCharacter_addAllChars(GetProcAddress(hDLL, 'SWFFontCharacter_addAllChars'));
  newSWFTextField := pfnewSWFTextField(GetProcAddress(hDLL, 'newSWFTextField'));
  destroySWFTextField := pfdestroySWFTextField(GetProcAddress(hDLL, 'destroySWFTextField'));
  SWFTextField_setFont := pfSWFTextField_setFont(GetProcAddress(hDLL, 'SWFTextField_setFont'));
  SWFTextField_setBounds := pfSWFTextField_setBounds(GetProcAddress(hDLL, 'SWFTextField_setBounds'));
  SWFTextField_setFlags := pfSWFTextField_setFlags(GetProcAddress(hDLL, 'SWFTextField_setFlags'));
  SWFTextField_setColor := pfSWFTextField_setColor(GetProcAddress(hDLL, 'SWFTextField_setColor'));
  SWFTextField_setVariableName := pfSWFTextField_setVariableName(GetProcAddress(hDLL, 'SWFTextField_setVariableName'));
  SWFTextField_addString := pfSWFTextField_addString(GetProcAddress(hDLL, 'SWFTextField_addString'));
  SWFTextField_addUTF8String := pfSWFTextField_addUTF8String(GetProcAddress(hDLL, 'SWFTextField_addUTF8String'));
  SWFTextField_setHeight := pfSWFTextField_setHeight(GetProcAddress(hDLL, 'SWFTextField_setHeight'));
  SWFTextField_setFieldHeight := pfSWFTextField_setFieldHeight(GetProcAddress(hDLL, 'SWFTextField_setFieldHeight'));
  SWFTextField_setLeftMargin := pfSWFTextField_setLeftMargin(GetProcAddress(hDLL, 'SWFTextField_setLeftMargin'));
  SWFTextField_setRightMargin := pfSWFTextField_setRightMargin(GetProcAddress(hDLL, 'SWFTextField_setRightMargin'));
  SWFTextField_setIndentation := pfSWFTextField_setIndentation(GetProcAddress(hDLL, 'SWFTextField_setIndentation'));
  SWFTextField_setLineSpacing := pfSWFTextField_setLineSpacing(GetProcAddress(hDLL, 'SWFTextField_setLineSpacing'));
  SWFTextField_setPadding := pfSWFTextField_setPadding(GetProcAddress(hDLL, 'SWFTextField_setPadding'));
  SWFTextField_addChars := pfSWFTextField_addChars(GetProcAddress(hDLL, 'SWFTextField_addChars'));
  SWFTextField_setAlignment := pfSWFTextField_setAlignment(GetProcAddress(hDLL, 'SWFTextField_setAlignment'));
  SWFTextField_setLength := pfSWFTextField_setLength(GetProcAddress(hDLL, 'SWFTextField_setLength'));
  newSWFSoundStream := pfnewSWFSoundStream(GetProcAddress(hDLL, 'newSWFSoundStream'));
  newSWFSoundStreamFromFileno := pfnewSWFSoundStreamFromFileno(GetProcAddress(hDLL, 'newSWFSoundStreamFromFileno'));
  newSWFSoundStream_fromInput := pfnewSWFSoundStream_fromInput(GetProcAddress(hDLL, 'newSWFSoundStream_fromInput'));
  SWFSoundStream_getFrames := pfSWFSoundStream_getFrames(GetProcAddress(hDLL, 'SWFSoundStream_getFrames'));
  destroySWFSoundStream := pfdestroySWFSoundStream(GetProcAddress(hDLL, 'destroySWFSoundStream'));
  newSWFSound := pfnewSWFSound(GetProcAddress(hDLL, 'newSWFSound'));
  newSWFSoundFromFileno := pfnewSWFSoundFromFileno(GetProcAddress(hDLL, 'newSWFSoundFromFileno'));
  newSWFSound_fromInput := pfnewSWFSound_fromInput(GetProcAddress(hDLL, 'newSWFSound_fromInput'));
  destroySWFSound := pfdestroySWFSound(GetProcAddress(hDLL, 'destroySWFSound'));
  SWFSoundInstance_setNoMultiple := pfSWFSoundInstance_setNoMultiple(GetProcAddress(hDLL, 'SWFSoundInstance_setNoMultiple'));
  SWFSoundInstance_setLoopInPoint := pfSWFSoundInstance_setLoopInPoint(GetProcAddress(hDLL, 'SWFSoundInstance_setLoopInPoint'));
  SWFSoundInstance_setLoopOutPoint := pfSWFSoundInstance_setLoopOutPoint(GetProcAddress(hDLL, 'SWFSoundInstance_setLoopOutPoint'));
  SWFSoundInstance_setLoopCount := pfSWFSoundInstance_setLoopCount(GetProcAddress(hDLL, 'SWFSoundInstance_setLoopCount'));
  SWFSoundInstance_addEnvelope := pfSWFSoundInstance_addEnvelope(GetProcAddress(hDLL, 'SWFSoundInstance_addEnvelope'));
  newSWFCXform := pfnewSWFCXform(GetProcAddress(hDLL, 'newSWFCXform'));
  newSWFAddCXform := pfnewSWFAddCXform(GetProcAddress(hDLL, 'newSWFAddCXform'));
  newSWFMultCXform := pfnewSWFMultCXform(GetProcAddress(hDLL, 'newSWFMultCXform'));
  destroySWFCXform := pfdestroySWFCXform(GetProcAddress(hDLL, 'destroySWFCXform'));
  SWFCXform_setColorAdd := pfSWFCXform_setColorAdd(GetProcAddress(hDLL, 'SWFCXform_setColorAdd'));
  SWFCXform_setColorMult := pfSWFCXform_setColorMult(GetProcAddress(hDLL, 'SWFCXform_setColorMult'));
  newSWFAction := pfnewSWFAction(GetProcAddress(hDLL, 'newSWFAction'));
  newSWFAction_fromFile := pfnewSWFAction_fromFile(GetProcAddress(hDLL, 'newSWFAction_fromFile'));
  compileSWFActionCode := pfcompileSWFActionCode(GetProcAddress(hDLL, 'compileSWFActionCode'));
  destroySWFAction := pfdestroySWFAction(GetProcAddress(hDLL, 'destroySWFAction'));
  SWFAction_getByteCode := pfSWFAction_getByteCode(GetProcAddress(hDLL, 'SWFAction_getByteCode'));
  newSWFButton := pfnewSWFButton(GetProcAddress(hDLL, 'newSWFButton'));
  destroySWFButton := pfdestroySWFButton(GetProcAddress(hDLL, 'destroySWFButton'));
  SWFButton_addShape := pfSWFButton_addShape(GetProcAddress(hDLL, 'SWFButton_addShape'));
  SWFButton_addCharacter := pfSWFButton_addCharacter(GetProcAddress(hDLL, 'SWFButton_addCharacter'));
  SWFButton_addAction := pfSWFButton_addAction(GetProcAddress(hDLL, 'SWFButton_addAction'));
  SWFButton_addSound := pfSWFButton_addSound(GetProcAddress(hDLL, 'SWFButton_addSound'));
  SWFButton_setMenu := pfSWFButton_setMenu(GetProcAddress(hDLL, 'SWFButton_setMenu'));
  SWFButton_setScalingGrid := pfSWFButton_setScalingGrid(GetProcAddress(hDLL, 'SWFButton_setScalingGrid'));
  SWFButton_removeScalingGrid := pfSWFButton_removeScalingGrid(GetProcAddress(hDLL, 'SWFButton_removeScalingGrid'));
  SWFButtonRecord_addFilter := pfSWFButtonRecord_addFilter(GetProcAddress(hDLL, 'SWFButtonRecord_addFilter'));
  SWFButtonRecord_setBlendMode := pfSWFButtonRecord_setBlendMode(GetProcAddress(hDLL, 'SWFButtonRecord_setBlendMode'));
  SWFButtonRecord_move := pfSWFButtonRecord_move(GetProcAddress(hDLL, 'SWFButtonRecord_move'));
  SWFButtonRecord_moveTo := pfSWFButtonRecord_moveTo(GetProcAddress(hDLL, 'SWFButtonRecord_moveTo'));
  SWFButtonRecord_rotate := pfSWFButtonRecord_rotate(GetProcAddress(hDLL, 'SWFButtonRecord_rotate'));
  SWFButtonRecord_rotateTo := pfSWFButtonRecord_rotateTo(GetProcAddress(hDLL, 'SWFButtonRecord_rotateTo'));
  SWFButtonRecord_scale := pfSWFButtonRecord_scale(GetProcAddress(hDLL, 'SWFButtonRecord_scale'));
  SWFButtonRecord_scaleTo := pfSWFButtonRecord_scaleTo(GetProcAddress(hDLL, 'SWFButtonRecord_scaleTo'));
  SWFButtonRecord_skewX := pfSWFButtonRecord_skewX(GetProcAddress(hDLL, 'SWFButtonRecord_skewX'));
  SWFButtonRecord_skewXTo := pfSWFButtonRecord_skewXTo(GetProcAddress(hDLL, 'SWFButtonRecord_skewXTo'));
  SWFButtonRecord_skewY := pfSWFButtonRecord_skewY(GetProcAddress(hDLL, 'SWFButtonRecord_skewY'));
  SWFButtonRecord_skewYTo := pfSWFButtonRecord_skewYTo(GetProcAddress(hDLL, 'SWFButtonRecord_skewYTo'));
  destroySWFVideoStream := pfdestroySWFVideoStream(GetProcAddress(hDLL, 'destroySWFVideoStream'));
  newSWFVideoStream_fromFile := pfnewSWFVideoStream_fromFile(GetProcAddress(hDLL, 'newSWFVideoStream_fromFile'));
  newSWFVideoStream_fromInput := pfnewSWFVideoStream_fromInput(GetProcAddress(hDLL, 'newSWFVideoStream_fromInput'));
  newSWFVideoStream := pfnewSWFVideoStream(GetProcAddress(hDLL, 'newSWFVideoStream'));
  SWFVideoStream_setDimension := pfSWFVideoStream_setDimension(GetProcAddress(hDLL, 'SWFVideoStream_setDimension'));
  SWFVideoStream_getNumFrames := pfSWFVideoStream_getNumFrames(GetProcAddress(hDLL, 'SWFVideoStream_getNumFrames'));
  SWFVideoStream_hasAudio := pfSWFVideoStream_hasAudio(GetProcAddress(hDLL, 'SWFVideoStream_hasAudio'));
  newSWFSprite := pfnewSWFSprite(GetProcAddress(hDLL, 'newSWFSprite'));
  destroySWFSprite := pfdestroySWFSprite(GetProcAddress(hDLL, 'destroySWFSprite'));
  SWFSprite_addBlock := pfSWFSprite_addBlock(GetProcAddress(hDLL, 'SWFSprite_addBlock'));
  newSWFPosition := pfnewSWFPosition(GetProcAddress(hDLL, 'newSWFPosition'));
  destroySWFPosition := pfdestroySWFPosition(GetProcAddress(hDLL, 'destroySWFPosition'));
  SWFPosition_skewX := pfSWFPosition_skewX(GetProcAddress(hDLL, 'SWFPosition_skewX'));
  SWFPosition_skewXTo := pfSWFPosition_skewXTo(GetProcAddress(hDLL, 'SWFPosition_skewXTo'));
  SWFPosition_skewY := pfSWFPosition_skewY(GetProcAddress(hDLL, 'SWFPosition_skewY'));
  SWFPosition_skewYTo := pfSWFPosition_skewYTo(GetProcAddress(hDLL, 'SWFPosition_skewYTo'));
  SWFPosition_scaleX := pfSWFPosition_scaleX(GetProcAddress(hDLL, 'SWFPosition_scaleX'));
  SWFPosition_scaleXTo := pfSWFPosition_scaleXTo(GetProcAddress(hDLL, 'SWFPosition_scaleXTo'));
  SWFPosition_scaleY := pfSWFPosition_scaleY(GetProcAddress(hDLL, 'SWFPosition_scaleY'));
  SWFPosition_scaleYTo := pfSWFPosition_scaleYTo(GetProcAddress(hDLL, 'SWFPosition_scaleYTo'));
  SWFPosition_scaleXY := pfSWFPosition_scaleXY(GetProcAddress(hDLL, 'SWFPosition_scaleXY'));
  SWFPosition_scaleXYTo := pfSWFPosition_scaleXYTo(GetProcAddress(hDLL, 'SWFPosition_scaleXYTo'));
  SWFPosition_getMatrix := pfSWFPosition_getMatrix(GetProcAddress(hDLL, 'SWFPosition_getMatrix'));
  SWFPosition_setMatrix := pfSWFPosition_setMatrix(GetProcAddress(hDLL, 'SWFPosition_setMatrix'));
  SWFPosition_rotate := pfSWFPosition_rotate(GetProcAddress(hDLL, 'SWFPosition_rotate'));
  SWFPosition_rotateTo := pfSWFPosition_rotateTo(GetProcAddress(hDLL, 'SWFPosition_rotateTo'));
  SWFPosition_move := pfSWFPosition_move(GetProcAddress(hDLL, 'SWFPosition_move'));
  SWFPosition_moveTo := pfSWFPosition_moveTo(GetProcAddress(hDLL, 'SWFPosition_moveTo'));
  newSWFShadow := pfnewSWFShadow(GetProcAddress(hDLL, 'newSWFShadow'));
  destroySWFShadow := pfdestroySWFShadow(GetProcAddress(hDLL, 'destroySWFShadow'));
  newSWFBlur := pfnewSWFBlur(GetProcAddress(hDLL, 'newSWFBlur'));
  destroySWFBlur := pfdestroySWFBlur(GetProcAddress(hDLL, 'destroySWFBlur'));
  newSWFFilterMatrix := pfnewSWFFilterMatrix(GetProcAddress(hDLL, 'newSWFFilterMatrix'));
  destroySWFFilterMatrix := pfdestroySWFFilterMatrix(GetProcAddress(hDLL, 'destroySWFFilterMatrix'));
  destroySWFFilter := pfdestroySWFFilter(GetProcAddress(hDLL, 'destroySWFFilter'));
  newColorMatrixFilter := pfnewColorMatrixFilter(GetProcAddress(hDLL, 'newColorMatrixFilter'));
  newConvolutionFilter := pfnewConvolutionFilter(GetProcAddress(hDLL, 'newConvolutionFilter'));
  newGradientBevelFilter := pfnewGradientBevelFilter(GetProcAddress(hDLL, 'newGradientBevelFilter'));
  newGradientGlowFilter := pfnewGradientGlowFilter(GetProcAddress(hDLL, 'newGradientGlowFilter'));
  newBevelFilter := pfnewBevelFilter(GetProcAddress(hDLL, 'newBevelFilter'));
  newGlowFilter := pfnewGlowFilter(GetProcAddress(hDLL, 'newGlowFilter'));
  newBlurFilter := pfnewBlurFilter(GetProcAddress(hDLL, 'newBlurFilter'));
  newDropShadowFilter := pfnewDropShadowFilter(GetProcAddress(hDLL, 'newDropShadowFilter'));
  SWFDisplayItem_getCharacter := pfSWFDisplayItem_getCharacter(GetProcAddress(hDLL, 'SWFDisplayItem_getCharacter'));
  SWFDisplayItem_endMask := pfSWFDisplayItem_endMask(GetProcAddress(hDLL, 'SWFDisplayItem_endMask'));
  SWFDisplayItem_get_x := pfSWFDisplayItem_get_x(GetProcAddress(hDLL, 'SWFDisplayItem_get_x'));
  SWFDisplayItem_get_y := pfSWFDisplayItem_get_y(GetProcAddress(hDLL, 'SWFDisplayItem_get_y'));
  SWFDisplayItem_get_xScale := pfSWFDisplayItem_get_xScale(GetProcAddress(hDLL, 'SWFDisplayItem_get_xScale'));
  SWFDisplayItem_get_yScale := pfSWFDisplayItem_get_yScale(GetProcAddress(hDLL, 'SWFDisplayItem_get_yScale'));
  SWFDisplayItem_get_xSkew := pfSWFDisplayItem_get_xSkew(GetProcAddress(hDLL, 'SWFDisplayItem_get_xSkew'));
  SWFDisplayItem_get_ySkew := pfSWFDisplayItem_get_ySkew(GetProcAddress(hDLL, 'SWFDisplayItem_get_ySkew'));
  SWFDisplayItem_get_rot := pfSWFDisplayItem_get_rot(GetProcAddress(hDLL, 'SWFDisplayItem_get_rot'));
  SWFDisplayItem_move := pfSWFDisplayItem_move(GetProcAddress(hDLL, 'SWFDisplayItem_move'));
  SWFDisplayItem_moveTo := pfSWFDisplayItem_moveTo(GetProcAddress(hDLL, 'SWFDisplayItem_moveTo'));
  SWFDisplayItem_rotate := pfSWFDisplayItem_rotate(GetProcAddress(hDLL, 'SWFDisplayItem_rotate'));
  SWFDisplayItem_rotateTo := pfSWFDisplayItem_rotateTo(GetProcAddress(hDLL, 'SWFDisplayItem_rotateTo'));
  SWFDisplayItem_scale := pfSWFDisplayItem_scale(GetProcAddress(hDLL, 'SWFDisplayItem_scale'));
  SWFDisplayItem_scaleTo := pfSWFDisplayItem_scaleTo(GetProcAddress(hDLL, 'SWFDisplayItem_scaleTo'));
  SWFDisplayItem_skewX := pfSWFDisplayItem_skewX(GetProcAddress(hDLL, 'SWFDisplayItem_skewX'));
  SWFDisplayItem_skewXTo := pfSWFDisplayItem_skewXTo(GetProcAddress(hDLL, 'SWFDisplayItem_skewXTo'));
  SWFDisplayItem_skewY := pfSWFDisplayItem_skewY(GetProcAddress(hDLL, 'SWFDisplayItem_skewY'));
  SWFDisplayItem_skewYTo := pfSWFDisplayItem_skewYTo(GetProcAddress(hDLL, 'SWFDisplayItem_skewYTo'));
  SWFDisplayItem_getPosition := pfSWFDisplayItem_getPosition(GetProcAddress(hDLL, 'SWFDisplayItem_getPosition'));
  SWFDisplayItem_getRotation := pfSWFDisplayItem_getRotation(GetProcAddress(hDLL, 'SWFDisplayItem_getRotation'));
  SWFDisplayItem_getScale := pfSWFDisplayItem_getScale(GetProcAddress(hDLL, 'SWFDisplayItem_getScale'));
  SWFDisplayItem_getSkew := pfSWFDisplayItem_getSkew(GetProcAddress(hDLL, 'SWFDisplayItem_getSkew'));
  SWFDisplayItem_getMatrix := pfSWFDisplayItem_getMatrix(GetProcAddress(hDLL, 'SWFDisplayItem_getMatrix'));
  SWFDisplayItem_setMatrix := pfSWFDisplayItem_setMatrix(GetProcAddress(hDLL, 'SWFDisplayItem_setMatrix'));
  SWFDisplayItem_getDepth := pfSWFDisplayItem_getDepth(GetProcAddress(hDLL, 'SWFDisplayItem_getDepth'));
  SWFDisplayItem_setDepth := pfSWFDisplayItem_setDepth(GetProcAddress(hDLL, 'SWFDisplayItem_setDepth'));
  SWFDisplayItem_remove := pfSWFDisplayItem_remove(GetProcAddress(hDLL, 'SWFDisplayItem_remove'));
  SWFDisplayItem_setName := pfSWFDisplayItem_setName(GetProcAddress(hDLL, 'SWFDisplayItem_setName'));
  SWFDisplayItem_setMaskLevel := pfSWFDisplayItem_setMaskLevel(GetProcAddress(hDLL, 'SWFDisplayItem_setMaskLevel'));
  SWFDisplayItem_setRatio := pfSWFDisplayItem_setRatio(GetProcAddress(hDLL, 'SWFDisplayItem_setRatio'));
  SWFDisplayItem_setCXform := pfSWFDisplayItem_setCXform(GetProcAddress(hDLL, 'SWFDisplayItem_setCXform'));
  SWFDisplayItem_setColorAdd := pfSWFDisplayItem_setColorAdd(GetProcAddress(hDLL, 'SWFDisplayItem_setColorAdd'));
  SWFDisplayItem_setColorMult := pfSWFDisplayItem_setColorMult(GetProcAddress(hDLL, 'SWFDisplayItem_setColorMult'));
  SWFDisplayItem_addAction := pfSWFDisplayItem_addAction(GetProcAddress(hDLL, 'SWFDisplayItem_addAction'));
  SWFDisplayItem_cacheAsBitmap := pfSWFDisplayItem_cacheAsBitmap(GetProcAddress(hDLL, 'SWFDisplayItem_cacheAsBitmap'));
  SWFDisplayItem_setBlendMode := pfSWFDisplayItem_setBlendMode(GetProcAddress(hDLL, 'SWFDisplayItem_setBlendMode'));
  SWFDisplayItem_addFilter := pfSWFDisplayItem_addFilter(GetProcAddress(hDLL, 'SWFDisplayItem_addFilter'));
  newSWFFill := pfnewSWFFill(GetProcAddress(hDLL, 'newSWFFill'));
  destroySWFFill := pfdestroySWFFill(GetProcAddress(hDLL, 'destroySWFFill'));
  SWFFill_skewX := pfSWFFill_skewX(GetProcAddress(hDLL, 'SWFFill_skewX'));
  SWFFill_skewXTo := pfSWFFill_skewXTo(GetProcAddress(hDLL, 'SWFFill_skewXTo'));
  SWFFill_skewY := pfSWFFill_skewY(GetProcAddress(hDLL, 'SWFFill_skewY'));
  SWFFill_skewYTo := pfSWFFill_skewYTo(GetProcAddress(hDLL, 'SWFFill_skewYTo'));
  SWFFill_scaleX := pfSWFFill_scaleX(GetProcAddress(hDLL, 'SWFFill_scaleX'));
  SWFFill_scaleXTo := pfSWFFill_scaleXTo(GetProcAddress(hDLL, 'SWFFill_scaleXTo'));
  SWFFill_scaleY := pfSWFFill_scaleY(GetProcAddress(hDLL, 'SWFFill_scaleY'));
  SWFFill_scaleYTo := pfSWFFill_scaleYTo(GetProcAddress(hDLL, 'SWFFill_scaleYTo'));
  SWFFill_scaleXY := pfSWFFill_scaleXY(GetProcAddress(hDLL, 'SWFFill_scaleXY'));
  SWFFill_scaleXYTo := pfSWFFill_scaleXYTo(GetProcAddress(hDLL, 'SWFFill_scaleXYTo'));
  SWFFill_rotate := pfSWFFill_rotate(GetProcAddress(hDLL, 'SWFFill_rotate'));
  SWFFill_rotateTo := pfSWFFill_rotateTo(GetProcAddress(hDLL, 'SWFFill_rotateTo'));
  SWFFill_move := pfSWFFill_move(GetProcAddress(hDLL, 'SWFFill_move'));
  SWFFill_moveTo := pfSWFFill_moveTo(GetProcAddress(hDLL, 'SWFFill_moveTo'));
  SWFFill_setMatrix := pfSWFFill_setMatrix(GetProcAddress(hDLL, 'SWFFill_setMatrix'));
  SWFShape_setLine := pfSWFShape_setLine(GetProcAddress(hDLL, 'SWFShape_setLine'));
  SWFShape_setLine2Filled := pfSWFShape_setLine2Filled(GetProcAddress(hDLL, 'SWFShape_setLine2Filled'));
  SWFShape_setLine2 := pfSWFShape_setLine2(GetProcAddress(hDLL, 'SWFShape_setLine2'));
  SWFShape_addSolidFill := pfSWFShape_addSolidFill(GetProcAddress(hDLL, 'SWFShape_addSolidFill'));
  SWFShape_addGradientFill := pfSWFShape_addGradientFill(GetProcAddress(hDLL, 'SWFShape_addGradientFill'));
  SWFShape_addBitmapFill := pfSWFShape_addBitmapFill(GetProcAddress(hDLL, 'SWFShape_addBitmapFill'));
  SWFShape_setLeftFill := pfSWFShape_setLeftFill(GetProcAddress(hDLL, 'SWFShape_setLeftFill'));
  SWFShape_setRightFill := pfSWFShape_setRightFill(GetProcAddress(hDLL, 'SWFShape_setRightFill'));
  SWFShape_drawArc := pfSWFShape_drawArc(GetProcAddress(hDLL, 'SWFShape_drawArc'));
  SWFShape_drawCircle := pfSWFShape_drawCircle(GetProcAddress(hDLL, 'SWFShape_drawCircle'));
  SWFShape_drawGlyph := pfSWFShape_drawGlyph(GetProcAddress(hDLL, 'SWFShape_drawGlyph'));
  SWFShape_drawSizedGlyph := pfSWFShape_drawSizedGlyph(GetProcAddress(hDLL, 'SWFShape_drawSizedGlyph'));
  SWFShape_drawCubic := pfSWFShape_drawCubic(GetProcAddress(hDLL, 'SWFShape_drawCubic'));
  SWFShape_drawCubicTo := pfSWFShape_drawCubicTo(GetProcAddress(hDLL, 'SWFShape_drawCubicTo'));
  SWFShape_drawCharacterBounds := pfSWFShape_drawCharacterBounds(GetProcAddress(hDLL, 'SWFShape_drawCharacterBounds'));
  newSWFMovieClip := pfnewSWFMovieClip(GetProcAddress(hDLL, 'newSWFMovieClip'));
  destroySWFMovieClip := pfdestroySWFMovieClip(GetProcAddress(hDLL, 'destroySWFMovieClip'));
  SWFMovieClip_setNumberOfFrames := pfSWFMovieClip_setNumberOfFrames(GetProcAddress(hDLL, 'SWFMovieClip_setNumberOfFrames'));
  SWFMovieClip_nextFrame := pfSWFMovieClip_nextFrame(GetProcAddress(hDLL, 'SWFMovieClip_nextFrame'));
  SWFMovieClip_labelFrame := pfSWFMovieClip_labelFrame(GetProcAddress(hDLL, 'SWFMovieClip_labelFrame'));
  SWFMovieClip_add := pfSWFMovieClip_add(GetProcAddress(hDLL, 'SWFMovieClip_add'));
  SWFMovieClip_remove := pfSWFMovieClip_remove(GetProcAddress(hDLL, 'SWFMovieClip_remove'));
  SWFMovieClip_setSoundStream := pfSWFMovieClip_setSoundStream(GetProcAddress(hDLL, 'SWFMovieClip_setSoundStream'));
  SWFMovie_setSoundStreamAt := pfSWFMovie_setSoundStreamAt(GetProcAddress(hDLL, 'SWFMovie_setSoundStreamAt'));
  SWFMovieClip_startSound := pfSWFMovieClip_startSound(GetProcAddress(hDLL, 'SWFMovieClip_startSound'));
  SWFMovieClip_stopSound := pfSWFMovieClip_stopSound(GetProcAddress(hDLL, 'SWFMovieClip_stopSound'));
  SWFMovieClip_setScalingGrid := pfSWFMovieClip_setScalingGrid(GetProcAddress(hDLL, 'SWFMovieClip_setScalingGrid'));
  SWFMovieClip_removeScalingGrid := pfSWFMovieClip_removeScalingGrid(GetProcAddress(hDLL, 'SWFMovieClip_removeScalingGrid'));
  SWFMovieClip_addInitAction := pfSWFMovieClip_addInitAction(GetProcAddress(hDLL, 'SWFMovieClip_addInitAction'));
  destroySWFPrebuiltClip := pfdestroySWFPrebuiltClip(GetProcAddress(hDLL, 'destroySWFPrebuiltClip'));
  newSWFPrebuiltClip_fromFile := pfnewSWFPrebuiltClip_fromFile(GetProcAddress(hDLL, 'newSWFPrebuiltClip_fromFile'));
  newSWFPrebuiltClip_fromInput := pfnewSWFPrebuiltClip_fromInput(GetProcAddress(hDLL, 'newSWFPrebuiltClip_fromInput'));
  newSWFBinaryData := pfnewSWFBinaryData(GetProcAddress(hDLL, 'newSWFBinaryData'));
  SWFMovie_writeExports := pfSWFMovie_writeExports(GetProcAddress(hDLL, 'SWFMovie_writeExports'));
  newSWFMovie := pfnewSWFMovie(GetProcAddress(hDLL, 'newSWFMovie'));
  newSWFMovieWithVersion := pfnewSWFMovieWithVersion(GetProcAddress(hDLL, 'newSWFMovieWithVersion'));
  destroySWFMovie := pfdestroySWFMovie(GetProcAddress(hDLL, 'destroySWFMovie'));
  SWFMovie_setRate := pfSWFMovie_setRate(GetProcAddress(hDLL, 'SWFMovie_setRate'));
  SWFMovie_setDimension := pfSWFMovie_setDimension(GetProcAddress(hDLL, 'SWFMovie_setDimension'));
  SWFMovie_setNumberOfFrames := pfSWFMovie_setNumberOfFrames(GetProcAddress(hDLL, 'SWFMovie_setNumberOfFrames'));
  SWFMovie_addExport := pfSWFMovie_addExport(GetProcAddress(hDLL, 'SWFMovie_addExport'));
  SWFMovie_assignSymbol := pfSWFMovie_assignSymbol(GetProcAddress(hDLL, 'SWFMovie_assignSymbol'));
  SWFMovie_defineScene := pfSWFMovie_defineScene(GetProcAddress(hDLL, 'SWFMovie_defineScene'));
  SWFMovie_setBackground := pfSWFMovie_setBackground(GetProcAddress(hDLL, 'SWFMovie_setBackground'));
  SWFMovie_setSoundStream := pfSWFMovie_setSoundStream(GetProcAddress(hDLL, 'SWFMovie_setSoundStream'));
  SWFMovie_startSound := pfSWFMovie_startSound(GetProcAddress(hDLL, 'SWFMovie_startSound'));
  SWFMovie_stopSound := pfSWFMovie_stopSound(GetProcAddress(hDLL, 'SWFMovie_stopSound'));
  SWFMovie_add := pfSWFMovie_add(GetProcAddress(hDLL, 'SWFMovie_add_internal'));
  SWFMovie_replace := pfSWFMovie_replace(GetProcAddress(hDLL, 'SWFMovie_replace_internal'));
  SWFMovie_remove := pfSWFMovie_remove(GetProcAddress(hDLL, 'SWFMovie_remove'));
  SWFMovie_nextFrame := pfSWFMovie_nextFrame(GetProcAddress(hDLL, 'SWFMovie_nextFrame'));
  SWFMovie_labelFrame := pfSWFMovie_labelFrame(GetProcAddress(hDLL, 'SWFMovie_labelFrame'));
  SWFMovie_namedAnchor := pfSWFMovie_namedAnchor(GetProcAddress(hDLL, 'SWFMovie_namedAnchor'));
  SWFMovie_output := pfSWFMovie_output(GetProcAddress(hDLL, 'SWFMovie_output'));
  SWFMovie_save := pfSWFMovie_save(GetProcAddress(hDLL, 'SWFMovie_save'));
  SWFMovie_output_to_stream := pfSWFMovie_output_to_stream(GetProcAddress(hDLL, 'SWFMovie_output_to_stream'));
  SWFMovie_protect := pfSWFMovie_protect(GetProcAddress(hDLL, 'SWFMovie_protect'));
  SWFMovie_setNetworkAccess := pfSWFMovie_setNetworkAccess(GetProcAddress(hDLL, 'SWFMovie_setNetworkAccess'));
  SWFMovie_addMetadata := pfSWFMovie_addMetadata(GetProcAddress(hDLL, 'SWFMovie_addMetadata'));
  SWFMovie_setScriptLimits := pfSWFMovie_setScriptLimits(GetProcAddress(hDLL, 'SWFMovie_setScriptLimits'));
  SWFMovie_setTabIndex := pfSWFMovie_setTabIndex(GetProcAddress(hDLL, 'SWFMovie_setTabIndex'));
  SWFMovie_importCharacter := pfSWFMovie_importCharacter(GetProcAddress(hDLL, 'SWFMovie_importCharacter'));

  { the functions above need testing for nil }
  LoadMing := true;
end;

initialization

finalization
  UnloadMing;
  
end.

