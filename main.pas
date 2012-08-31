unit main;

interface

uses
  Windows, Messages, SysUtils, {Variants,} Classes, Graphics, Controls, Forms, GDIPAPI, GDIPOBJ, GDIPUTIL,
  Dialogs, StdCtrls, Grids, ExtCtrls, Math, jpeg, Menus, {DXSounds,}mmsystem,{wave,}configfile,drawcanvas, shellapi, gifimage, label2;

{$i inc.inc}

type

///////////

  TEditUndo = record
      m_nChange : integer; // eg: 1 for a point change, 2 for a colour change...
      m_nType : integer;
      m_pObject : pointer;
      m_nParams : array[1..30] of integer;
      m_strParam : string;
      m_pSavedObject : pointer;
  end;

  TEditVideoObjPtr = ^TEditVideoObj;
  TEditVideoObj = class(TObject)
      public
         m_strFileName : string[255];
         PntList : TList;
         procedure Draw(xoffs,yoffs : integer);
         procedure Assign(source : TEditVideoObjPtr);
         procedure Move(xAmount, yAmount : integer);
         procedure SetPoint(x, y, nIndex : integer);
         procedure Update(nIndex : integer);
         function Pnt(nIndex : integer) : TLabel2Ptr;
         destructor Destroy;
         constructor Create(AOwner : TWinControl);
  end;

  TLineObjPtr = ^TLineObj;
  TLineObj = class(TObject)
     public
         m_bMoving : boolean;
         m_nX, m_nY : integer;
         PntList : TList;
         m_nLineWidth : integer;
         m_Colour : TColor;
         m_alpha : byte;
         m_angle : single;
         m_aliased : byte;
         m_body : pointer;
         constructor Create(AOwner : TWinControl);
         destructor Destroy; override;
         procedure Assign(source : TLineObjPtr);
         procedure Draw(xoffs,yoffs : integer; DrawControlPoints : boolean = false);
         procedure SetPoint(x, y, nIndex : integer);
         procedure Move(xAmount, yAmount : integer);
         function Pnt(nIndex : integer) : TLabel2Ptr;
         procedure Update(nIndex : integer);
         procedure Alpha(amount : single);
  end;

  TParticlePtr = ^TParticle;
  TParticle = record
      xinc, yinc : real;
  end;

  TExplodeObjPtr = ^TExplodeObj;
  TExplodeObj = class(TObject)
     public
      m_bInit : boolean;
         m_bMoving : boolean;
         m_nX, m_nY : integer;
         PntList : TList;
         m_Particles : TList;
         m_nMidX, m_nMidY : integer;
         constructor Create(AOwner : TWinControl; bGen : BOOLEAN = FALSE);
         destructor Destroy; override;
         procedure InitParts;
         procedure Assign(source : TExplodeObjPtr);
         procedure Draw(xoffs,yoffs : integer; nIterations, nCurrentFrame : integer; DrawControlPoints : boolean = false);
         procedure SetPoint(x, y, nIndex : integer);
         procedure Move(xAmount, yAmount : integer);
         function Pnt(nIndex : integer) : TLabel2Ptr;
         procedure Update(nIndex : integer);
  end;

  TTextObjPtr = ^TTextObj;
  TTextObj = class(TObject)
     public
         m_bMoving : boolean;
         m_nX, m_nY : integer;
         PntList : TList;
         //m_font : TGPFont;
         m_InColour, m_OutColour : TColor;
         m_styleOuter : TBrushStyle;
         m_strFontName : string[255];
         m_FontStyle : TFontStyles;
         m_strCaption : string[255];
         m_alpha : byte;
         m_angle : single;
         m_aliased : byte;
         m_body : pointer;
         constructor Create(AOwner : TWinControl; strCaption : string = 'Text');
         destructor Destroy; override;
         procedure Assign(source : TTextObjPtr);
         procedure Draw(xoffs,yoffs : integer; DrawControlPoints : boolean = false);
         procedure SetPoint(x, y, nIndex : integer);
         procedure Move(xAmount, yAmount : integer);
         function Pnt(nIndex : integer) : TLabel2Ptr;
         procedure Update(nIndex : integer);
         procedure Rotate(amount : single);
         procedure Alpha(amount : single);
  end;

  TSubtitleObjPtr = ^TSubtitleObj;
  TSubtitleObj = class(TObject)
   public
         m_strCaption : string;
         constructor Create(strCaption : string = '');
         destructor Destroy; override;
         procedure Assign(source : TSubtitleObjPtr);
  end;

  TPolyObjPtr = ^TPolyObj;
  TPolyObj = class(TObject)
     public
         m_bMoving : boolean;
         m_nX, m_nY : integer;
         PntList : TList;
         m_nLineWidth : integer;
         m_InColour, m_OutColour : TColor;
         m_styleInner : TBrushStyle;
         m_styleOuter : TPenStyle;
         m_alpha : byte;
         m_angle : single;
         m_aliased : byte;
         m_body : pointer;
         constructor Create(AOwner : TWinControl; VerticeCount : integer);
         destructor Destroy; override;
         procedure Assign(source : TPolyObjPtr);
         procedure Draw(xoffs,yoffs : integer; DrawControlPoints : boolean = false);
         procedure SetPoint(x, y, nIndex : integer);
         procedure Move(xAmount, yAmount : integer);
         function Pnt(nIndex : integer) : TLabel2Ptr;
         procedure Update(nIndex : integer);
         procedure Alpha(amount : single);
  end;

  TSoundObjPtr = ^TSoundObj;
  TSoundObj = class(TObject)
     public
         m_bMoving : boolean;
         m_nX, m_nY : integer;
         Pnt : TLabel;
//         m_CHANNEL : TAudioFileStream;
         m_strFileName : string;
         constructor Create(AOwner : TWinControl; strFileName : string = '');
         destructor Destroy; override;
         procedure Assign(source : TSoundObjPtr);
         procedure Draw(DrawControlPoints : boolean = FALSE);
         procedure SetVisible(newVal : Boolean);
         procedure SetPoint(x, y, nIndex : integer);
         procedure Move(xAmount, yAmount : integer);
         procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
         procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
         procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

  TOvalObjPtr = ^TOvalObj;
  TOvalObj = class(TObject)
   public
         m_bMoving : boolean;
         m_nX, m_nY : integer;
         PntList : TList;
         m_nLineWidth : integer;
         m_InColour, m_OutColour : TColor;
         m_styleInner : TBrushStyle;
         m_styleOuter : TPenStyle;
         m_alpha : byte;
         m_angle : single;
         m_aliased : byte;
         m_body : pointer;
         constructor Create(AOwner : TWinControl);
         destructor Destroy; override;
         procedure Assign(source : TOvalObjPtr);
         procedure Draw(xoffs,yoffs : integer; DrawControlPoints : boolean = false);
         procedure SetPoint(x, y, nIndex : integer);
         procedure Move(xAmount, yAmount : integer);
         function Pnt(nIndex : integer) : TLabel2Ptr;
         procedure Rotate(amount : single);
         procedure Alpha(amount : single);
         procedure Update(nIndex : integer);
         procedure Tween(pSource, pDest : TOvalObjPtr; nCurrentFrame, nTotalFrames : integer);
  end;

  TSquareObjPtr = ^TSquareObj;
  TSquareObj = class(TObject)
     public
         m_bMoving : boolean;
         m_nX, m_nY : integer;
//         Pnt : array[1..4] of TLabel;
         PntList : TList;
         m_nLineWidth : integer;
         m_InColour, m_OutColour : TColor;
         m_styleInner : TBrushStyle;
         m_styleOuter : TPenStyle;
         m_alpha : byte;
         m_angle : single;
         m_aliased : byte;
         m_body : pointer;
         constructor Create(AOwner : TWinControl);
         destructor Destroy; override;
         procedure Assign(source : TSquareObjPtr);
         procedure Draw(xoffs,yoffs : integer; DrawControlPoints : boolean = false);
         procedure SetPoint(x, y, nIndex : integer);
         procedure Move(xAmount, yAmount : integer);
         procedure Rotate(amount : single);
         procedure Alpha(amount : single);
         function Pnt(nIndex : integer) : TLabel2Ptr;
         procedure Update(nIndex : integer);
         procedure Tween(pSource, pDest : TSquareObjPtr; nCurrentFrame, nTotalFrames : integer);
  end;

   TBitmanPtr = ^TBitman;
   TBitman = class(TObject)
      public
         m_bMoving : boolean;
         m_nX, m_nY : integer;
         m_strFileName : string;
         PntList : TList;
         Imarge : TGPBitmap;
         m_bLoadNew : boolean;
         m_alpha : byte;
         m_angle : single;
         m_aliased : byte;
         ms : TMemoryStream;
         m_body : pointer;
         constructor Create(AOwner : TWinControl; strFileName : string; wide,high : integer);
         destructor Destroy; override;
         procedure Assign(source : TBitManPtr);
         procedure Draw(xoffs,yoffs : integer; alpha : byte; DrawControlPoints : boolean = false);
         procedure SetPoint(x, y, nIndex : integer);
         procedure Move(xAmount, yAmount : integer);
         function Pnt(nIndex : integer) : TLabel2Ptr;
         procedure Update(nIndex : integer);
         procedure Rotate(amount : single);
         procedure Alpha(amount : single);
         procedure Tween(pSource, pDest : TBitmanPtr; nCurrentFrame, nTotalFrames : integer);
   end;

   TpCanvas = ^TGPGraphics;
   TStickManPtr = ^TStickMan;
   TStickMan = class(TObject)
      public
         m_pCanvas : TpCanvas;
         m_bMoving : boolean;
         m_nX, m_nY : integer;
         m_nHeadDiam : integer;
         Wid : array[1..10] of integer;
         PntList : TList;        // 1 is the hip, 2 left knee, 3 left foot, 4 right knee, 5 right foot, 6 neck
                                             // 7 leftarm top, 8 leftarm bot, 9 rightarm top, 10 rightarm bot
         Lng : array[1..9] of integer;    // 1 left thigh, 2 left calf, 3 right thigh, 4 right calf, 5 body
                                          // 6 leftarm top, 7 leftarm bot, 8 rightarm top, 9 rightarm bot
         m_InColour, m_OutColour : TColor;
         m_alpha : byte;
         m_angle : single;
         m_aliased : byte;
         constructor Create(AOwner : TWinControl; n1,n2,n3,n4,n5,n6,n7,n8,n9 : integer);
         destructor Destroy; override;
         procedure Draw(xoffs,yoffs : integer; DrawControlPoints : Boolean = FALSE);
         procedure SetPoint(x, y, nIndex, nSrcIndex : integer);
         procedure Assign(source : TStickManPtr);
         procedure UpdatePoint(nIndex1, nIndex2, nIndex3 : integer);
         procedure Move(xAmount, yAmount : integer);
         function Pnt(nIndex : integer) : TLabel2Ptr;
         procedure Update(nIndex : integer);
         procedure Alpha(amount : single);
   end;

   TSpecialStickManPtr = ^TSpecialStickMan;
   TSpecialStickMan = class(TObject)
      public
         m_nDrawStyle : integer;
         m_pCanvas : TpCanvas;
         m_bMoving : boolean;
         m_nX, m_nY : integer;
         m_nHeadDiam : integer;
         Wid : array[1..14] of integer;
         PntList : TList;        // 1 is the hip, 2 left knee, 3 left foot, 4 right knee, 5 right foot, 6 neck
                                             // 7 leftarm top, 8 leftarm bot, 9 rightarm top, 10 rightarm bot
         Lng : array[1..13] of integer;    // 1 left thigh, 2 left calf, 3 right thigh, 4 right calf, 5 body
                                          // 6 leftarm top, 7 leftarm bot, 8 rightarm top, 9 rightarm bot
         m_InColour, m_OutColour : TColor;
         m_nLineWidth : integer;
         m_styleInner : TBrushStyle;
         m_styleOuter : TPenStyle;
         m_alpha : byte;
         m_angle : single;
         m_aliased : byte;
         constructor Create(AOwner : TWinControl; n1,n2,n3,n4,n5,n6,n7,n8,n9 : integer);
         destructor Destroy; override;
         procedure Draw(xoffs,yoffs : integer; DrawControlPoints : Boolean = FALSE);
         procedure SetPoint(x, y, nIndex, nSrcIndex : integer);
         procedure Assign(source : TSpecialStickManPtr);
         procedure UpdatePoint(nIndex1, nIndex2, nIndex3 : integer);
         procedure Move(xAmount, yAmount : integer);
         function Pnt(nIndex : integer) : TLabel2Ptr;
         procedure Update(nIndex : integer);
         procedure Alpha(amount : single);
   end;

   TStickManBMPPtr = ^TStickManBMP;
   TStickManBMP = class(TObject)
      public
         m_pCanvas : TpCanvas;
         m_bMoving : boolean;
         m_nX, m_nY : integer;
         m_nHeadDiam : integer;
         m_bMouthOpen : boolean;
         m_bFlipped : boolean;
         m_FaceClosed, m_FaceOpen : TGPBitmap;
         Wid : array[1..10] of integer;
         PntList : TList;        // 1 is the hip, 2 left knee, 3 left foot, 4 right knee, 5 right foot, 6 neck
                                             // 7 leftarm top, 8 leftarm bot, 9 rightarm top, 10 rightarm bot
         Lng : array[1..9] of integer;    // 1 left thigh, 2 left calf, 3 right thigh, 4 right calf, 5 body
                                          // 6 leftarm top, 7 leftarm bot, 8 rightarm top, 9 rightarm bot
         m_InColour, m_OutColour : TColor;
         m_alpha : byte;
         m_angle : single;
         m_aliased : byte;
         ms : TMemoryStream;
         constructor Create(AOwner : TWinControl; n1,n2,n3,n4,n5,n6,n7,n8,n9 : integer; strFileName1 : string = ''; strFileName2 : string = '');
         destructor Destroy; override;
         procedure Draw(xoffs,yoffs : integer; DrawControlPoints : Boolean = FALSE);
         procedure SetPoint(x, y, nIndex : integer);
         procedure Assign(source : TStickManBMPPtr);
         procedure UpdatePoint(nIndex1, nIndex2, nIndex3 : integer);
         procedure Move(xAmount, yAmount : integer);
         function Pnt(nIndex : integer) : TLabel2Ptr;
         procedure Update(nIndex : integer);
         procedure Alpha(amount : single);
   end;

////////////////////

  TActionObjPtr = ^TActionObj;
  TActionObj = class(TObject)
  private
  public
      m_nType : integer;
      m_nParams : array[1..3] of integer;
      m_strParam : string[255];
      m_nFrameNo : integer;
  end;

  TIFramePtr = ^TIFrame;
  TIFrame = class(TObject)
  public
      m_nType : integer;      // object type
      m_pObject : pointer;    // object pointer
      m_FrameNo : integer;
      m_nOnion : integer;
      constructor Create;
      destructor Destroy; override;
  end;

  TSingleFramePtr = ^TSingleFrame;
  TSingleFrame = class(TObject)
  private
  public
      m_Frames : TList;
      m_Type : integer;    //tween or normal draw
      constructor Create;
      destructor Destroy; override;
  end;

  TLayerObjPtr = ^TLayerObj;
  TLayerObj = class(TObject)
  private
  public
    m_pObject : pointer;
    m_pTempObject : pointer;
    m_nType : integer;     // see inc.inc for defs
    m_olFrames : TList;
    m_strName : ShortString;
    m_olActions : TList;
    m_bHidden : BOOLEAN;
    constructor Create(nType : integer; strMisc : string; strMisc2 : string = '');
    destructor Destroy; override;
    procedure DestroyObjects;
    function Render(xoffs,yoffs, nFrame : integer; DrawControlPoints : boolean = FALSE) : boolean;
  end;

///////////

  TfrmMain = class(TForm)
    grdFrames: TDrawGrid;
    imgTitle: TImage;
    imgBlank: TImage;
    mnuMain: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    Insert1: TMenuItem;
    Layer1: TMenuItem;
    Keyframes1: TMenuItem;
    New1: TMenuItem;
    Close1: TMenuItem;
    lblSizeGrid: TLabel;
    mnuGridPopup: TPopupMenu;
    InsertKeyFrame1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    FrameSet1: TMenuItem;
    RemoveKeyFrame1: TMenuItem;
    Remove1: TMenuItem;
    KeyFrame1: TMenuItem;
    FrameSet2: TMenuItem;
    Layer2: TMenuItem;
    {DXSound: TDXSound;}
    od: TOpenDialog;
    Movelayerup1: TMenuItem;
    MoveLayerDown1: TMenuItem;
    N2: TMenuItem;
    InserLayer10: TMenuItem;
    RemoveLayer10: TMenuItem;
    N3: TMenuItem;
    InsertFrameSet1: TMenuItem;
    RemoveFrameSet2: TMenuItem;
    N4: TMenuItem;
    Help2: TMenuItem;
    sd: TSaveDialog;
    SetPosetoPreviousKeyFrame1: TMenuItem;
    SetPosetoNextKeyFrame1: TMenuItem;
    N5: TMenuItem;
    KeyFrameAction1: TMenuItem;
    N6: TMenuItem;
    HideLayer1: TMenuItem;
    ShowLayer1: TMenuItem;
    N7: TMenuItem;
    Export1: TMenuItem;
    AVI1: TMenuItem;
    OnionSkinning1: TMenuItem;
    Edit1: TMenuItem;
    Undo1: TMenuItem;
    QSM1: TMenuItem;
    SaveAs1: TMenuItem;
    mnuInsertPose: TMenuItem;
    Timer1: TTimer;
    N8: TMenuItem;
    Movie1: TMenuItem;
    Properties1: TMenuItem;
    imgStickLayer: TImage;
    imgRectLayer: TImage;
    imgOvalLayer: TImage;
    imgLineLayer: TImage;
    imgTextLayer: TImage;
    imgPolyLayer: TImage;
    CopyFrameSet1: TMenuItem;
    PasteFrameset1: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    Bitmap1: TMenuItem;
    Gif1: TMenuItem;
    AniGif1: TMenuItem;
    BitmapSeries1: TMenuItem;
    N11: TMenuItem;
    GotoFrame1: TMenuItem;
    N12: TMenuItem;
    Flash1: TMenuItem;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure grdFramesSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure grdFramesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure grdFramesMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure grdFramesMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure grdFramesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure grdFramesKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Layer1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure lblSizeGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure lblSizeGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure lblSizeGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure InsertKeyFrame1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Keyframes1Click(Sender: TObject);
    procedure FrameSet1Click(Sender: TObject);
    procedure RemoveKeyFrame1Click(Sender: TObject);
    procedure KeyFrame1Click(Sender: TObject);
    procedure FrameSet2Click(Sender: TObject);
    procedure Layer2Click(Sender: TObject);
    procedure Movelayerup1Click(Sender: TObject);
    procedure MoveLayerDown1Click(Sender: TObject);
    procedure InserLayer10Click(Sender: TObject);
    procedure RemoveLayer10Click(Sender: TObject);
    procedure RemoveFrameSet2Click(Sender: TObject);
    procedure InsertFrameSet1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    function FormHelp(Command: Word; Data: Integer;
      var CallHelp: Boolean): Boolean;
    procedure SetPosetoPreviousKeyFrame1Click(Sender: TObject);
    procedure SetPosetoNextKeyFrame1Click(Sender: TObject);
    procedure KeyFrameAction1Click(Sender: TObject);
    procedure HideLayer1Click(Sender: TObject);
    procedure ShowLayer1Click(Sender: TObject);
    procedure OnionSkinning1Click(Sender: TObject);
    procedure AVI1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure Standalone1Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure Insert1Click(Sender: TObject);
    procedure mnuInsertPoseClick(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure File1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure CopyFrameSet1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure PasteFrameset1Click(Sender: TObject);
    procedure Bitmap1Click(Sender: TObject);
    procedure Gif1Click(Sender: TObject);
    procedure AniGif1Click(Sender: TObject);
    procedure BitmapSeries1Click(Sender: TObject);
    procedure GotoFrame1Click(Sender: TObject);
    procedure Flash1Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    m_bScrolling : boolean;
    m_bAdjusting : boolean;
    m_bMoving : boolean;
    m_nLast : integer;
    m_nX, m_nY : integer;
    m_bSaved : BOOLEAN;
    m_strMovieFileName : string;
    //GDI+
    m_nXX, m_nYY : integer;

    procedure realRender(nFrameNo : integer; DrawControlPoints : boolean; layers : TList);
    procedure SaveBitmap(b : TGPBitmap; fs : TFileStream);
    procedure LoadBitmap(var b : TGPBitmap; fs : TFileStream; var ms : TMemoryStream);
    procedure SaveBitmapOld(b : TGPBitmap; fs : TFileStream);
    procedure LoadBitmapOld(var b : TGPBitmap; fs : TFileStream);
  public
     m_nLastFrame : integer;
     m_pFrame : TSingleFramePtr;
     m_pTweenFrame : TIFramePtr;
     m_olLayers : TList;
     m_col, m_row : integer;
     m_nFPS : integer;
     m_bgColor : TColor;
    m_Bitmap : TGPBitmap;
    m_Canvas : TGPGraphics;
     m_bPlaying : boolean;
     m_Settings : TSettingsRec;
     frmCanvas : TfrmCanvas;
     m_bChanged : boolean;
     //  ACTION stuff
     m_incmax : integer;
     m_xinc, m_yinc, m_xincmax, m_yincmax : integer;
     m_bOld : boolean;
     //
     m_bQuit, m_bReady : boolean;
     //
     m_Undo : TEditUndo;
     m_bCancelClose : boolean;
     //
     m_lastCol : integer;
     m_strTHEPATH : string;
     //
     m_bActionMoving : boolean;
     m_pAction : TActionObjPtr;
     //
     m_pCopyFrameSet : TSingleFramePtr;
     m_pCopyLayer : TLayerObjPtr;
     m_strMessage : string;
     //
     //multiple layer selection
     m_olSelectedLayers : TList;
     m_bNoNameChange : boolean;
     //
     m_bMovieReady : boolean;
     m_nMovieWidth : integer;
     m_nMovieHeight : integer;
     m_nLastRendered : integer;
     m_bLastRenderedControl : boolean;
     m_nXoffset, m_nYoffset : integer;
     // this is for edit-time onion skinning
     m_alphaMultiplier : single;
     //
     m_pTempObject : pointer;
     m_pObject : pointer;
     //
     procedure Render(nFrameNo : integer; DrawControlPoints : boolean = FALSE);
    procedure RenderLayers(olLayers : TList; nFrameNo : integer; DrawControlPoints : boolean);
     procedure ReRender;
     procedure Save(strFileName : string; autosave : boolean = false);
     procedure Load(strFileName : string);
     procedure NewMovie(nWidth, nHeight : integer);
     procedure ExportFlashVideo(strFileName, strSoundTrack : string);

     procedure ResizeStage(wide,high : integer);

         procedure DrawLine(x,y,width,height : integer; r,g,b, alpha : byte; linewidth : integer; angle : single);
         procedure DrawLine2(x,y,x2,y2 : integer; colour : longint; alpha : byte; linewidth : integer);
         procedure DrawRect(x,y,width,height : integer; r,g,b,fr,fg,fb, alpha : byte; linewidth : integer; angle : single);
         procedure DrawRectOutline(x,y,width,height : integer; colour : longint; alpha : byte; linewidth : integer; angle : single);
         procedure DrawEllipse(x,y,width,height : integer; outColour,inColour:longint; alpha : byte; linewidth : integer; angle : single);
         procedure DrawEllipseOutline(x,y,width,height : integer; outColour:longint; alpha : byte; linewidth : integer; angle : single);
         procedure DrawImage(image: TGPBitmap; x,y,x2,y2 : integer; alpha : byte; angle : single);
         procedure DrawImage2(image: TGPBitmap; x,y : integer; alpha : byte; angle : single);
         procedure DrawPoly(points : TList; outColour,inColour:longint; alpha : byte; linewidth : integer; fill : boolean);
         procedure DrawPoly2(points : array of TPoint; outColour,inColour:longint; alpha : byte; linewidth : integer);
         procedure DrawText(x,y : integer; strText : string; strFontName : string; high : integer; inColour:longint; alpha : byte; angle : single);
         {procedure MoveTo(x,y : integer);
         procedure LineTo(x,y : integer);}
  end;

  pfStart = procedure(szFileName : pChar; nWidth : integer; nHeight : integer; nFPS : integer); stdcall;
  pfStop = procedure; stdcall;
  pfAddFrame = procedure (hInBMP : HBITMAP); stdcall;
  pfIsOK = function : integer; stdcall;
  pfCompress = procedure; stdcall;

var
  frmMain: TfrmMain;

procedure DWORDtoRGB(t : tcolor; var r,g,b : byte);
  
implementation

uses tools, mooset, stickprops, aoubt, subtitles, textprops, actions, onion, export,
  layername, betanotes, movieprops, gotoform, flashexport, stickstuff, stickjoint, stickrenderer, fixedstreamadapter;

{$R *.dfm}

procedure TfrmMain.DrawText(x,y : integer; strText : string; strFontName : string; high : integer; inColour:longint; alpha : byte; angle : single);
var
   brush : TGPSolidBrush;
   fr,fg,fb : byte;
   font : TGPFont;
   origin : TGPPointF;
   bbox : TGPRectF;
begin
   alpha := round(alpha * m_alphaMultiplier);
   fb := InColour shr 16;
   fg := InColour shr 8;
   fr := InColour;

   font := TGPFont.Create(strFontName, high * 0.72);

   brush := TGPSolidBrush.Create(MakeColor(alpha, fr,fg,fb));
   m_Canvas.ResetTransform();

   origin.X := 0;
   origin.Y := 0;
   m_Canvas.MeasureString(strText, length(StrText), font, origin, bbox);

   m_Canvas.TranslateTransform(x + (bbox.Width /2), y + (bbox.Height /2));
   m_Canvas.RotateTransform(angle);

   origin.X := -bbox.Width / 2;
   origin.Y := -bbox.Height / 2;
   m_Canvas.DrawString(strText, length(strText), font, origin, brush);

   brush.Free;

   font.free;
end;

{procedure TfrmMain.MoveTo(x,y : integer);
begin
   m_nXX := x;
   m_nYY := y;
end;

procedure TfrmMain.LineTo(x,y : integer);
begin
   m_nXX := x;
   m_nYY := y;
end;   }

procedure TfrmMAin.DrawPoly(points : TList; outColour,inColour:longint; alpha : byte; linewidth : integer; fill : boolean);
var
   pen : TGPPen;
   brush : TGPSolidBrush;
   r,g,b,fr,fg,fb : byte;
   gdipoints : array[0..100] of TGPPoint;
   f : integer;
begin
   alpha := round(alpha * m_alphaMultiplier);
   b := outColour shr 16;
   g := outColour shr 8;
   r := outColour;
   fb := InColour shr 16;
   fg := InColour shr 8;
   fr := InColour;

   for f := 0 to points.Count-1 do
   begin
      gdipoints[f].x := TLabel2Ptr(points.items[f])^.Left;
      gdipoints[f].y := TLabel2Ptr(points.items[f])^.Top;
   end;

   pen := TGPPen.Create(MakeColor(alpha, r,g,b), lineWidth);
   brush := TGPSolidBrush.Create(MakeColor(alpha, fr,fg,fb));
   m_Canvas.ResetTransform();
      m_Canvas.TranslateTransform(m_nXoffset,m_nYOffset);
   if (fill) then
      m_Canvas.FillPolygon(brush, PGPPoint(@gdipoints[0]), points.count);
   if (lineWidth <> 0) then
      m_Canvas.DrawPolygon(pen, PGPPoint(@gdipoints[0]), points.count);

   pen.Free;
   brush.Free;
end;

procedure TfrmMAin.DrawPoly2(points : array of TPoint; outColour,inColour:longint; alpha : byte; linewidth : integer);
var
   pen : TGPPen;
   brush : TGPSolidBrush;
   r,g,b,fr,fg,fb : byte;
   f : integer;
   gdipoints : array[0..100] of TGPPoint;
   count : integer;
begin
   alpha := round(alpha * m_alphaMultiplier);
   b := outColour shr 16;
   g := outColour shr 8;
   r := outColour;
   fb := InColour shr 16;
   fg := InColour shr 8;
   fr := InColour;

   count := length(points);

   for f := 0 to Count-1 do
   begin
      gdipoints[f].x := points[f].x;
      gdipoints[f].y := points[f].y;
   end;

   pen := TGPPen.Create(MakeColor(alpha, r,g,b), lineWidth);
   brush := TGPSolidBrush.Create(MakeColor(alpha, fr,fg,fb));
   m_Canvas.ResetTransform();
      //m_Canvas.TranslateTransform(m_nXoffset,m_nYOffset);
   m_Canvas.FillPolygon(brush, PGPPoint(@gdipoints[0]), count);
   m_Canvas.DrawPolygon(pen, PGPPoint(@gdipoints[0]), count);

   pen.Free;
   brush.Free;
end;

procedure TfrmMain.DrawImage(image: TGPBitmap; x,y,x2,y2 : integer; alpha : byte; angle : single);
var
   wide,high,xx,yy : integer;
var
   pAttribs : TGPImageAttributes;
   destRect : TGPRect;
   colorMatrix : TColorMatrix;
begin
   alpha := round(alpha * m_alphaMultiplier);

   wide := x2-x;
   high := y2-y;
   xx := round(x + (wide / 2));
   yy := round(y + (high / 2));

   //
   m_Canvas.ResetTransform();
   m_Canvas.TranslateTransform(xx,yy);
   m_Canvas.RotateTransform(angle);

   if (alpha >= 253) then
   begin
      m_Canvas.DrawImage(image, -wide div 2,-high div 2,wide,high);
   end else
   begin
      colorMatrix[0,0] := 1; colorMatrix[1,0] := 0; colorMatrix[2,0] := 0; colorMatrix[3,0] := 0; colorMatrix[4,0] := 0;
      colorMatrix[0,1] := 0; colorMatrix[1,1] := 1; colorMatrix[2,1] := 0; colorMatrix[3,1] := 0; colorMatrix[4,1] := 0;
      colorMatrix[0,2] := 0; colorMatrix[1,2] := 0; colorMatrix[2,2] := 1; colorMatrix[3,2] := 0; colorMatrix[4,2] := 0;
      colorMatrix[0,3] := 0; colorMatrix[1,3] := 0; colorMatrix[2,3] := 0; colorMatrix[3,3] := alpha/255; colorMatrix[4,3] := 0;
      colorMatrix[0,4] := 0; colorMatrix[1,4] := 0; colorMatrix[2,4] := 0; colorMatrix[3,4] := 0; colorMatrix[4,4] := 1;
      pAttribs := TGPImageAttributes.Create();
      pAttribs.SetColorMatrix(colorMatrix, ColorMatrixFlagsDefault, ColorAdjustTypeBitmap);

      destRect.X := -wide div 2;
      destRect.Y := -high div 2;
      destRect.width := wide;
      destRect.height := high;
      m_Canvas.DrawImage(Image, destRect, 0,0, Image.GetWidth,Image.GetHeight, UnitPixel, pAttribs);

      pAttribs.Destroy;
   end;
   //
end;

procedure TfrmMain.DrawImage2(image: TGPBitmap; x,y : integer; alpha : byte; angle : single);
begin
   //alpha := round(alpha * m_alphaMultiplier);
   
   m_Canvas.ResetTransform();
   m_Canvas.TranslateTransform(x,y);
   m_Canvas.RotateTransform(angle);
   m_Canvas.DrawImage(image,
                      -image.GetWidth div 2,-image.GetHeight div 2,
                      image.GetWidth,image.GetHeight);
end;

procedure TfrmMain.DrawLine(x,y,width,height : integer; r,g,b, alpha : byte; linewidth : integer; angle : single);
var
   pen : TGPPen;
begin
   alpha := round(alpha * m_alphaMultiplier);
   pen := TGPPen.Create(MakeColor(alpha, r,g,b), lineWidth);
   pen.SetStartCap(LineCapRound);
   pen.SetEndCap(LineCapRound);
   m_Canvas.ResetTransform();
   m_Canvas.TranslateTransform(x,y);
   m_Canvas.RotateTransform(angle);
   m_Canvas.DrawLine(pen, 0,0, width,height);
   pen.Free;
end;

procedure TfrmMain.DrawLine2(x,y,x2,y2 : integer; colour : longint; alpha : byte; linewidth : integer);
var
   pen : TGPPen;
   r,g,b : byte;
begin
   b := colour shr 16;
   g := colour shr 8;
   r := colour;
   alpha := round(alpha * m_alphaMultiplier);
   pen := TGPPen.Create(MakeColor(alpha, r,g,b), lineWidth);
   Pen.SetStartCap(LineCapRound);
   Pen.SetEndCap(LineCapRound);
   m_Canvas.ResetTransform();
   m_Canvas.DrawLine(pen, x,y, x2,y2);
   pen.Free;
end;

procedure TfrmMain.DrawRect(x,y,width,height : integer; r,g,b,fr,fg,fb, alpha : byte; linewidth : integer; angle : single);
var
   pen : TGPPen;
   brush : TGPSolidBrush;
begin
   alpha := round(alpha * m_alphaMultiplier);
   pen := TGPPen.Create(MakeColor(alpha, r,g,b), lineWidth);
   brush := TGPSolidBrush.Create(MakeColor(alpha, fr,fg,fb));
   m_Canvas.ResetTransform();
   m_Canvas.TranslateTransform(x,y);
   m_Canvas.RotateTransform(angle);
   m_Canvas.FillRectangle(brush, -width div 2,-height div 2, width,height);
   if (linewidth <> 0) then
      m_Canvas.DrawRectangle(pen, -width div 2,-height div 2, width,height);
   pen.Free;
   brush.Free;
end;

procedure TfrmMain.DrawRectOutline(x,y,width,height : integer; colour : longint; alpha : byte; linewidth : integer; angle : single);
var
   pen : TGPPen;
   r,g,b : byte;
begin
   alpha := round(alpha * m_alphaMultiplier);
   b := Colour shr 16;
   g := Colour shr 8;
   r := Colour;
   pen := TGPPen.Create(MakeColor(alpha, r,g,b), lineWidth);
   m_Canvas.ResetTransform();
   m_Canvas.TranslateTransform(x,y);
   m_Canvas.RotateTransform(angle);
   m_Canvas.DrawRectangle(pen, -width div 2,-height div 2, width,height);
   pen.Free;
end;

procedure TfrmMain.DrawEllipse(x,y,width,height : integer; outColour,inColour:longint; alpha : byte; linewidth : integer; angle : single);
var
   pen : TGPPen;
   brush : TGPSolidBrush;
   r,g,b,fr,fg,fb : byte;
begin
   alpha := round(alpha * m_alphaMultiplier);
   b := outColour shr 16;
   g := outColour shr 8;
   r := outColour;
   fb := InColour shr 16;
   fg := InColour shr 8;
   fr := InColour;

   pen := TGPPen.Create(MakeColor(alpha, r,g,b), lineWidth);
   brush := TGPSolidBrush.Create(MakeColor(alpha, fr,fg,fb));
   m_Canvas.ResetTransform();
   m_Canvas.TranslateTransform(x,y);
   m_Canvas.RotateTransform(angle);
   m_Canvas.FillEllipse(brush, -width div 2,-height div 2, width,height);
   if (linewidth <> 0) then
      m_Canvas.DrawEllipse(pen, -width div 2,-height div 2, width,height);
   pen.Free;
   brush.Free;
end;

procedure TfrmMain.DrawEllipseOutline(x,y,width,height : integer; outColour:longint; alpha : byte; linewidth : integer; angle : single);
var
   pen : TGPPen;
   r,g,b : byte;
begin
   alpha := round(alpha * m_alphaMultiplier);
   b := outColour shr 16;
   g := outColour shr 8;
   r := outColour;

   pen := TGPPen.Create(MakeColor(alpha, r,g,b), lineWidth);
   m_Canvas.ResetTransform();
   m_Canvas.TranslateTransform(x,y);
   m_Canvas.RotateTransform(angle);
   m_Canvas.DrawEllipse(pen, -width div 2,-height div 2, width,height);
   pen.Free;
end;

{$i stickinc.inc}    {done}
{$i bitmap.inc}      {done}
{$i rect.inc}        {done}
{$i oval.inc}        {done}
{$i sound.inc}       {dont need yet}
{$i poly.inc}        {done}
{$i subtitle.inc}    {dont need}
{$i text.inc}        {done}
{$i explode.inc}
{$i line.inc}        {done}

{$i stickBMP.inc}
{$i editvideo.inc}

{$i specialstickinc.inc}    {done}

////////////////
{$i TSingleFrame.inc}
////////////////

function itoa(i : integer) : string;
var
   strTemp : string;
begin
   try
      str(i, strTemp);
      itoa := strTemp;
   except
      itoa := '';
   end;
end;

function atoi(s : string) : integer;
var
   i,c : integer;
begin
   val(s, i, c);
   if (c <> 0) then
   begin
      atoi := 0;
   end else
   begin
      atoi := i;
   end;
end;

constructor TIFrame.Create;
begin
   inherited;
   m_pObject := nil;
   m_nType := -1;
   m_nOnion := 0;
end;

destructor TIFrame.Destroy;
begin
   if (m_pObject <> nil) then
   begin
      if (m_nType = O_EDITVIDEO) then
      begin
         TEditVideoObjPtr(m_pObject)^.Free;
         Dispose(TEditVideoObjPtr(m_pObject));
         TEditVideoObjPtr(m_pObject) := nil;
      end;
      if (m_nType = O_STICKMAN) then
      begin
         TStickManPtr(m_pObject)^.Free;
         Dispose(TStickManPtr(m_pObject));
         TStickManPtr(m_pObject) := nil;
      end;
      if (m_nType = O_SPECIALSTICK) then
      begin
         TSpecialStickManPtr(m_pObject)^.Free;
         Dispose(TSpecialStickManPtr(m_pObject));
         TSpecialStickManPtr(m_pObject) := nil;
      end;
      if (m_nType = O_T2STICK) then
      begin
         TLimbListPtr(m_pObject)^.Free;
         Dispose(TLimbListPtr(m_pObject));
         TLimbListPtr(m_pObject) := nil;
      end;
      if (m_nType = O_STICKMANBMP) then
      begin
         TStickManBMPPtr(m_pObject)^.Free;
         Dispose(TStickManBMPPtr(m_pObject));
         TStickManBMPPtr(m_pObject) := nil;
      end;
      if (m_nType = O_BITMAP) then
      begin
         TBitManPtr(m_pObject)^.Free;
         Dispose(TBitManPtr(m_pObject));
         TBitManPtr(m_pObject) := nil;
      end;
      if (m_nType = O_RECTANGLE) then
      begin
         TSquareObjPtr(m_pObject)^.Free;
         Dispose(TSquareObjPtr(m_pObject));
         TSquareObjPtr(m_pObject) := nil;
      end;
      if (m_nType = O_LINE) then
      begin
         TLineObjPtr(m_pObject)^.Free;
         Dispose(TLineObjPtr(m_pObject));
         TLineObjPtr(m_pObject) := nil;
      end;
      if (m_nType = O_EXPLODE) then
      begin
         TExplodeObjPtr(m_pObject)^.Free;
         Dispose(TExplodeObjPtr(m_pObject));
         TExplodeObjPtr(m_pObject) := nil;
      end;
      if (m_nType = O_TEXT) then
      begin
         TTextObjPtr(m_pObject)^.Free;
         Dispose(TTextObjPtr(m_pObject));
         TTextObjPtr(m_pObject) := nil;
      end;
      if (m_nType = O_SUBTITLE) then
      begin
         TSubtitleObjPtr(m_pObject)^.Free;
         Dispose(TSubtitleObjPtr(m_pObject));
         TSubtitleObjPtr(m_pObject) := nil;
      end;
      if (m_nType = O_POLY) then
      begin
         TPolyObjPtr(m_pObject)^.Free;
         Dispose(TPolyObjPtr(m_pObject));
         TPolyObjPtr(m_pObject) := nil;
      end;
      if (m_nType = O_OVAL) then
      begin
         TOvalObjPtr(m_pObject)^.Free;
         Dispose(TOvalObjPtr(m_pObject));
         TOvalObjPtr(m_pObject) := nil;
      end;
      if (m_nType = O_SOUND) then
      begin
         TSoundObjPtr(m_pObject)^.Free;
         Dispose(TSoundObjPtr(m_pObject));
         TSoundObjPtr(m_pObject) := nil;
      end;
   end;
   m_pObject := nil;
   inherited destroy;
end;

////////////////

procedure TfrmMain.FormCreate(Sender: TObject);
var
   WaveFormat:TWaveFormatEx;
   hInst : LONGWORD;
   t : textfile;
   bShow : boolean;
   strTemp : string;
   frmReadMe : TfrmReadMe;
begin

   m_strTHEPATH := extractfilepath(application.exename);

   hInst := LoadLibrary('tisutils.dll');
   if (hInst = 0) then
   begin
      Avi1.Enabled := FALSE;
   end else
   begin
      FreeLibrary(hInst);
   end;

   randomize;

   left := 0;
   top := 0;
   width := 640;
   height := 480;
   {try
      DXSound.Initialize;
   finally
      if not DXSound.Initialized then
      begin
         ShowMessage('An error occured while trying to initialize the sound device, you will not be able to hear audio.');
      end else
      begin
         MakePCMWaveFormatEx(WaveFormat,44100,16,2);
         DXSound.Primary.SetFormat(WaveFormat);
      end;
   end; }

   if LoadSettings(m_strTHEPATH+'tis.fat', m_Settings) then
   begin
      Left := m_Settings.Left;
      Top := m_Settings.Top;
      Width := m_Settings.Width;
      Height := m_Settings.Height;
      WindowState := wsNormal;
      if m_Settings.WindowState = 1 then WindowState := wsMaximized;
      if m_Settings.WindowState = 2 then WindowState := wsMinimized;
   end;

   bShow := TRUE;
   if (fileexists('misc.fat')) then
   begin
      assignfile(t, 'misc.fat');
      reset(t);
      while not eof(t) do
      begin
         readln(t, strTemp);
         if (strTemp='beta=750') then
         begin
            bShow := FALSE;
         end;
      end;
      closefile(t);
   end;

   if bShow then
   begin
      frmReadMe := TfrmReadme.Create(self);
      frmReadMe.ShowModal;
      if (frmReadme.chkNoShow.Checked) then
      begin
         assignfile(t, 'misc.fat');
         rewrite(t);
         writeln(t, 'beta=750');
         closefile(t);
      end;
      frmReadMe.Destroy;
   end;

   if paramstr(1) <> '' then
   begin
      m_strMovieFileName := paramstr(1);
      timer1.enabled := true;
   end;

   m_olSelectedLayers := nil;
   m_bNoNameChange := false;
   NewMovie(320,240);

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
//
end;

/////////////////// FRAMELIST /////////////////

constructor TLayerObj.Create(nType : integer; strMisc : string; strMisc2 : string);
var
   wide,high : integer;
begin
   m_strName := 'Untitled';
   m_olFrames := TList.Create;
   m_olActions := TList.Create;
   m_pObject := nil;
   m_pTempObject := nil;
   m_pObject := nil;
   m_nType := nType;
   if (nType = O_EDITVIDEO) then
   begin
      new(TEditVideoObjPtr(m_pObject));
      new(TEditVideoObjPtr(m_pTempObject));
      TEditVideoObjPtr(m_pObject)^ := TEditVideoObj.Create(frmCanvas);
      TEditVideoObjPtr(m_pTempObject)^ := TEditVideoObj.Create(frmCanvas);
   end;
   if (nType = O_T2STICK) then
   begin
      new(TLimbListPtr(m_pObject));
      new(TLimbListPtr(m_pTempObject));
      TLimbListPtr(m_pObject)^ := TLimbList.Create();
      TLimbListPtr(m_pTempObject)^ := TLimbList.Create();
      if (strMisc <> '') then
      begin
         TLimbListPtr(m_pObject)^.Load(strMisc);
         TLimbListPtr(m_pTempObject)^.Load(strMisc);
      end;
      //TLimbListPtr(m_pObject)^.Canvas := frmMain.m_Canvas;
      //TLimbListPtr(m_pTempObject)^.Canvas := frmMain.m_Canvas;
   end;
   if (nType = O_STICKMAN) then
   begin
      new(TStickManPtr(m_pObject));
      new(TStickManPtr(m_pTempObject));
      TStickManPtr(m_pObject)^ := TStickMan.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
      TStickManPtr(m_pTempObject)^ := TStickMan.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
      TStickManPtr(m_pObject)^.SetPoint(100,100, 6,6);
      TStickManPtr(m_pObject)^.SetPoint(90,120,7,7);
      TStickManPtr(m_pObject)^.SetPoint(80,140,8,8);
      TStickManPtr(m_pObject)^.SetPoint(110,120,9,9);
      TStickManPtr(m_pObject)^.SetPoint(120,140,10,10);
      TStickManPtr(m_pObject)^.SetPoint(100,150,1,1);
      TStickManPtr(m_pObject)^.SetPoint(90,175,2,2);
      TStickManPtr(m_pObject)^.SetPoint(80,200,3,3);
      TStickManPtr(m_pObject)^.SetPoint(110,175,4,4);
      TStickManPtr(m_pObject)^.SetPoint(120,200,5,5);
   end;
   if (nType = O_SPECIALSTICK) then
   begin
      new(TSpecialStickManPtr(m_pObject));
      new(TSpecialStickManPtr(m_pTempObject));
      TSpecialStickManPtr(m_pObject)^ := TSpecialStickMan.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
      TSpecialStickManPtr(m_pTempObject)^ := TSpecialStickMan.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
      TSpecialStickManPtr(m_pObject)^.SetPoint(100,100, 6,6);
      TSpecialStickManPtr(m_pObject)^.SetPoint(90,120,7,7);
      TSpecialStickManPtr(m_pObject)^.SetPoint(80,140,8,8);
      TSpecialStickManPtr(m_pObject)^.SetPoint(70,140,11,11);//
      TSpecialStickManPtr(m_pObject)^.SetPoint(110,120,9,9);
      TSpecialStickManPtr(m_pObject)^.SetPoint(120,140,10,10);
      TSpecialStickManPtr(m_pObject)^.SetPoint(130,140,12,12);//
      TSpecialStickManPtr(m_pObject)^.SetPoint(100,150,1,1);
      TSpecialStickManPtr(m_pObject)^.SetPoint(90,175,2,2);
      TSpecialStickManPtr(m_pObject)^.SetPoint(80,200,3,3);
      TSpecialStickManPtr(m_pObject)^.SetPoint(70,200,13,13);//
      TSpecialStickManPtr(m_pObject)^.SetPoint(110,175,4,4);
      TSpecialStickManPtr(m_pObject)^.SetPoint(120,200,5,5);
      TSpecialStickManPtr(m_pObject)^.SetPoint(130,200,14,14);//
   end;
   if (nType = O_STICKMANBMP) then
   begin
      new(TStickManBMPPtr(m_pObject));
      new(TStickManBMPPtr(m_pTempObject));
      TStickManBMPPtr(m_pObject)^ := TStickManBMP.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
      TStickManBMPPtr(m_pTempObject)^ := TStickManBMP.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20, strMisc, strMisc2);
      TStickManBMPPtr(m_pObject)^.SetPoint(100,100, 6);
      TStickManBMPPtr(m_pObject)^.SetPoint(90,120,7);
      TStickManBMPPtr(m_pObject)^.SetPoint(80,140,8);
      TStickManBMPPtr(m_pObject)^.SetPoint(110,120,9);
      TStickManBMPPtr(m_pObject)^.SetPoint(120,140,10);
      TStickManBMPPtr(m_pObject)^.SetPoint(100,150,1);
      TStickManBMPPtr(m_pObject)^.SetPoint(90,175,2);
      TStickManBMPPtr(m_pObject)^.SetPoint(80,200,3);
      TStickManBMPPtr(m_pObject)^.SetPoint(110,175,4);
      TStickManBMPPtr(m_pObject)^.SetPoint(120,200,5);
   end;
   if (nType = O_BITMAP) then
   begin
      wide := 0;
      high := 0;
      new(TBitManPtr(m_pObject));
      new(TBitManPtr(m_pTempObject));
      TBitManPtr(m_pTempObject)^ := TBitMan.Create(frmCanvas, strMisc, 0,0);
      if (TBitManPtr(m_pTempObject)^.Imarge <> nil) then
      begin
         wide := TBitManPtr(m_pTempObject)^.Imarge.GetWidth;
         high := TBitManPtr(m_pTempObject)^.Imarge.GetHeight;
      end;
      TBitManPtr(m_pObject)^ := TBitMan.Create(frmCanvas, '', wide,high);
   end;
   if (nType = O_RECTANGLE) then
   begin
      new(TSquareObjPtr(m_pObject));
      new(TSquareObjPtr(m_pTempObject));
      TSquareObjPtr(m_pObject)^ := TSquareObj.Create(frmCanvas);
      TSquareObjPtr(m_pTempObject)^ := TSquareObj.Create(frmCanvas);
   end;
   if (nType = O_LINE) then
   begin
      new(TLineObjPtr(m_pObject));
      new(TLineObjPtr(m_pTempObject));
      TLineObjPtr(m_pObject)^ := TLineObj.Create(frmCanvas);
      TLineObjPtr(m_pTempObject)^ := TLineObj.Create(frmCanvas);
   end;
   if (nType = O_EXPLODE) then
   begin
      new(TExplodeObjPtr(m_pObject));
      new(TExplodeObjPtr(m_pTempObject));
      TExplodeObjPtr(m_pObject)^ := TExplodeObj.Create(frmCanvas);
      TExplodeObjPtr(m_pTempObject)^ := TExplodeObj.Create(frmCanvas);
   end;
   if (nType = O_TEXT) then
   begin
      new(TTextObjPtr(m_pObject));
      new(TTextObjPtr(m_pTempObject));
      TTextObjPtr(m_pObject)^ := TTextObj.Create(frmCanvas, strMisc);
      TTextObjPtr(m_pTempObject)^ := TTextObj.Create(frmCanvas, strMisc);
   end;
   if (nType = O_SUBTITLE) then
   begin
      new(TSubtitleObjPtr(m_pObject));
      new(TSubtitleObjPtr(m_pTempObject));
      TSubtitleObjPtr(m_pObject)^ := TSubtitleObj.Create(strMisc);
      TSubtitleObjPtr(m_pTempObject)^ := TSubtitleObj.Create(strMisc);
   end;
   if (nType = O_POLY) then
   begin
      new(TPolyObjPtr(m_pObject));
      new(TPolyObjPtr(m_pTempObject));
      TPolyObjPtr(m_pObject)^ := TPolyObj.Create(frmCanvas, atoi(strMisc));
      TPolyObjPtr(m_pTempObject)^ := TPolyObj.Create(frmCanvas, atoi(strMisc));
   end;
   if (nType = O_OVAL) then
   begin
      new(TOvalObjPtr(m_pObject));
      new(TOvalObjPtr(m_pTempObject));
      TOvalObjPtr(m_pObject)^ := TOvalObj.Create(frmCanvas);
      TOvalObjPtr(m_pTempObject)^ := TOvalObj.Create(frmCanvas);
   end;
   if (nType = O_SOUND) then
   begin
      new(TSoundObjPtr(m_pObject));
      new(TSoundObjPtr(m_pTempObject));
      TSoundObjPtr(m_pObject)^ := TSoundObj.Create(frmCanvas, strMisc);
      TSoundObjPtr(m_pTempObject)^ := TSoundObj.Create(frmCanvas, strMisc);
      TSoundObjPtr(m_pObject)^.SetVisible(FALSE);
      TSoundObjPtr(m_pTempObject)^.SetVisible(FALSE);
   end;
end;

destructor TLayerObj.Destroy;
var
   f : integer;
begin
   for f := 0 to m_olFrames.Count-1 do
   begin
      TSingleFramePtr(m_olFrames.Items[f])^.Free;
      Dispose(TSingleFramePtr(m_olFrames.Items[f]));
   end;
   m_olFrames.Destroy;
   for f := 0 to m_olActions.Count-1 do
   begin
      TActionObjPtr(m_olActions.Items[f])^.Free;
      Dispose(TActionObjPtr(m_olActions.Items[f]));
   end;
   m_olActions.Destroy;
   DestroyObjects;
   inherited Destroy;
end;

procedure TLayerObj.DestroyObjects;
begin
   if (m_pObject <> nil) then
   begin
      if (m_nType = O_EDITVIDEO) then
      begin
         TEditVideoObjPtr(m_pObject)^.Free;
         TEditVideoObjPtr(m_pTempObject)^.Free;
         Dispose(TEditVideoObjPtr(m_pObject));
         Dispose(TEditVideoObjPtr(m_pTempObject));
      end;
      if (m_nType = O_STICKMAN) then
      begin
         TStickManPtr(m_pObject)^.Free;
         TStickManPtr(m_pTempObject)^.Free;
         Dispose(TStickManPtr(m_pObject));
         Dispose(TStickManPtr(m_pTempObject));
      end;
      if (m_nType = O_SPECIALSTICK) then
      begin
         TSpecialStickManPtr(m_pObject)^.Free;
         TSpecialStickManPtr(m_pTempObject)^.Free;
         Dispose(TSpecialStickManPtr(m_pObject));
         Dispose(TSpecialStickManPtr(m_pTempObject));
      end;
      if (m_nType = O_T2STICK) then
      begin
         TLimbListPtr(m_pObject)^.Free;
         TLimbListPtr(m_pTempObject)^.Free;
         Dispose(TLimbListPtr(m_pObject));
         Dispose(TLimbListPtr(m_pTempObject));
      end;
      if (m_nType = O_STICKMANBMP) then
      begin
         TStickManBMPPtr(m_pObject)^.Free;
         TStickManBMPPtr(m_pTempObject)^.Free;
         Dispose(TStickManBMPPtr(m_pObject));
         Dispose(TStickManBMPPtr(m_pTempObject));
      end;
      if (m_nType = O_BITMAP) then
      begin
         TBitManPtr(m_pObject)^.Free;
         TBitManPtr(m_pTempObject)^.Free;
         Dispose(TBitManPtr(m_pObject));
         Dispose(TBitManPtr(m_pTempObject));
      end;
      if (m_nType = O_RECTANGLE) then
      begin
         TSquareObjPtr(m_pObject)^.Free;
         TSquareObjPtr(m_pTempObject)^.Free;
         Dispose(TSquareObjPtr(m_pObject));
         Dispose(TSquareObjPtr(m_pTempObject));
      end;
      if (m_nType = O_LINE) then
      begin
         TLineObjPtr(m_pObject)^.Free;
         TLineObjPtr(m_pTempObject)^.Free;
         Dispose(TLineObjPtr(m_pObject));
         Dispose(TLineObjPtr(m_pTempObject));
      end;
      if (m_nType = O_EXPLODE) then
      begin
         TExplodeObjPtr(m_pObject)^.Free;
         TExplodeObjPtr(m_pTempObject)^.Free;
         Dispose(TExplodeObjPtr(m_pObject));
         Dispose(TExplodeObjPtr(m_pTempObject));
      end;
      if (m_nType = O_TEXT) then
      begin
         TTextObjPtr(m_pObject)^.Free;
         TTextObjPtr(m_pTempObject)^.Free;
         Dispose(TTextObjPtr(m_pObject));
         Dispose(TTextObjPtr(m_pTempObject));
      end;
      if (m_nType = O_SUBTITLE) then
      begin
         TSubtitleObjPtr(m_pObject)^.Free;
         TSubtitleObjPtr(m_pTempObject)^.Free;
         Dispose(TSubtitleObjPtr(m_pObject));
         Dispose(TSubtitleObjPtr(m_pTempObject));
      end;
      if (m_nType = O_POLY) then
      begin
         TPolyObjPtr(m_pObject)^.Free;
         TPolyObjPtr(m_pTempObject)^.Free;
         Dispose(TPolyObjPtr(m_pObject));
         Dispose(TPolyObjPtr(m_pTempObject));
      end;
      if (m_nType = O_OVAL) then
      begin
         TOvalObjPtr(m_pObject)^.Free;
         TOvalObjPtr(m_pTempObject)^.Free;
         Dispose(TOvalObjPtr(m_pObject));
         Dispose(TOvalObjPtr(m_pTempObject));
      end;
      if (m_nType = O_SOUND) then
      begin
         TSoundObjPtr(m_pObject)^.Free;
         TSoundObjPtr(m_pTempObject)^.Free;
         Dispose(TSoundObjPtr(m_pObject));
         Dispose(TSoundObjPtr(m_pTempObject));
      end;
   end;
   m_pTempObject := nil;
   m_pObject := nil;
end;

procedure DWORDtoRGB(t : tcolor; var r,g,b : byte);
begin
   b := t shr 16;
   g := t shr 8;
   r := t;
end;

function TLayerObj.Render(xoffs, yoffs, nFrame : integer; DrawControlPoints : boolean) : boolean;
var
   f,h, onion : integer;
   pFrame : TSingleFramePtr;
   bRender : boolean;
   nIterations : integer;
   xinc, yinc : real;
   pStart, pEnd : TIFramePtr;
   r,g,b:array[1..3] of byte;
   bVolChange, bPanChange : boolean;

   alpha : byte;
   frameDiff : integer;

   renderer : TStickRenderer;
begin
   if (m_bHidden) then exit;
   Render := TRUE;

   bRender := FALSE;
   for f := 0 to m_olFrames.Count-1 do
   begin
      pFrame := m_olFrames.Items[f];
      if (nFrame >= TIFramePtr(pFrame^.m_Frames.First)^.m_FrameNo) and (nFrame <= TIFramePtr(pFrame.m_Frames.Last)^.m_FrameNo) then
      begin
         bRender := TRUE;
         break;
      end;
   end;

   if bRender then
   begin
        //
        for f := pFrame^.m_Frames.Count-1 downto 1 do
        begin
            pStart := pFrame^.m_Frames.Items[f-1];
            pEnd := pFrame^.m_Frames.Items[f];
            if (nFrame >= pStart^.m_FrameNo) and (nFrame <= pEnd^.m_FrameNo) then
            begin
               break;
            end;
        end;
        //
{}      if (m_nType = O_SUBTITLE) then
        begin
            //frmSubtitles.AddString(TSubtitleObjPtr(pStart^.m_pObject)^.m_strCaption);
            exit;
        end;
{}      if (m_nType = O_EDITVIDEO) then
        begin
               if (pStart^.m_FrameNo = nFrame) then
               begin
                  frmMain.frmCanvas.aviPlaya.FileName := TEditVideoObjPtr(pStart^.m_pObject)^.m_strFileName;
                  frmMain.frmCanvas.aviPlaya.Active := TRUE;
               end;
               nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
               for f := 1 to 4 do
               begin
                  xinc := (nFrame - pStart^.m_FrameNo) * ((TEditVideoObjPtr(pEnd^.m_pObject)^.Pnt(f)^.left - TEditVideoObjPtr(pStart^.m_pObject)^.Pnt(f)^.left) / nIterations);
                  TEditVideoObjPtr(m_pTempObject)^.Pnt(f)^.left := round(TEditVideoObjPtr(pStart^.m_pObject)^.Pnt(f)^.left + xinc);
                  yinc := (nFrame - pStart^.m_FrameNo) * ((TEditVideoObjPtr(pEnd^.m_pObject)^.Pnt(f)^.top - TEditVideoObjPtr(pStart^.m_pObject)^.Pnt(f)^.top) / nIterations);
                  TEditVideoObjPtr(m_pTempObject)^.Pnt(f)^.top := round(TEditVideoObjPtr(pStart^.m_pObject)^.Pnt(f)^.top + yinc);
               end;
               frmMain.frmCanvas.aviPlaya.Width := TEditVideoObjPtr(m_pTempObject)^.Pnt(3)^.left - TEditVideoObjPtr(m_pTempObject)^.Pnt(1)^.left;
               frmMain.frmCanvas.aviPlaya.Height := TEditVideoObjPtr(m_pTempObject)^.Pnt(3)^.top - TEditVideoObjPtr(m_pTempObject)^.Pnt(1)^.top;
               xinc := ((pEnd^.m_FrameNo - nFrame) / nIterations) * frmMain.frmCanvas.aviPlaya.FrameCount;
               frmMain.frmCanvas.aviPlaya.Seek(round(xinc));
               TEditVideoObjPtr(m_pTempObject)^.Draw(xoffs,yoffs);
               exit;
        end;
{}      if (m_nType = O_STICKMAN) then
        begin
               TStickManPtr(m_pTempObject)^.Assign(TStickManPtr(pStart^.m_pObject));
               nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
               onion := nFrame - pStart^.m_nOnion;
               if (onion < pStart^.m_FrameNo) then onion := pStart^.m_FrameNo;

               frameDiff := nFrame - onion;

               while onion <= nFrame do
               begin
                   begin
                       for f := 1 to 10 do
                       begin
                          if (TStickManPtr(pStart^.m_Pobject)^.Pnt(f)^.Left) <> (TStickManPtr(pEnd^.m_Pobject)^.Pnt(f)^.Left) then
                          begin
                             xinc := (onion - pStart^.m_FrameNo) * ((TStickManPtr(pEnd^.m_pObject)^.Pnt(f)^.Left - TStickManPtr(pStart^.m_pObject)^.Pnt(f)^.Left) / nIterations);
                             TStickManPtr(m_pTempObject)^.Pnt(f)^.Left := round(TStickManPtr(pStart^.m_pObject)^.Pnt(f)^.Left + xinc);
                          end;
                          if (TStickManPtr(pStart^.m_Pobject)^.Pnt(f)^.Top) <> (TStickManPtr(pEnd^.m_Pobject)^.Pnt(f)^.Top) then
                          begin
                             yinc := (onion - pStart^.m_FrameNo) * ((TStickManPtr(pEnd^.m_pObject)^.Pnt(f)^.Top - TStickManPtr(pStart^.m_pObject)^.Pnt(f)^.Top) / nIterations);
                             TStickManPtr(m_pTempObject)^.Pnt(f)^.Top := round(TStickManPtr(pStart^.m_pObject)^.Pnt(f)^.Top + yinc);
                          end;
                          if (TStickManPtr(pStart^.m_Pobject)^.Wid[f]) <> (TStickManPtr(pEnd^.m_Pobject)^.Wid[f]) then
                          begin
                             xinc := (onion - pStart^.m_FrameNo) * ((TStickManPtr(pEnd^.m_pObject)^.Wid[f] - TStickManPtr(pStart^.m_pObject)^.Wid[f]) / nIterations);
                             TStickManPtr(m_pTempObject)^.Wid[f] := round(TStickManPtr(pStart^.m_pObject)^.Wid[f] + xinc);
                          end;
                       end;
                       if (TStickManPtr(pStart^.m_Pobject)^.m_nHeadDiam) <> (TStickManPtr(pEnd^.m_Pobject)^.m_nHeadDiam) then
                       begin
                          xinc := (onion - pStart^.m_FrameNo) * ((TStickManPtr(pEnd^.m_pObject)^.m_nHeadDiam - TStickManPtr(pStart^.m_pObject)^.m_nHeadDiam) / nIterations);
                          TStickManPtr(m_pTempObject)^.m_nHeadDiam := round(TStickManPtr(pStart^.m_pObject)^.m_nHeadDiam + xinc);
                       end;
                   //alpha
                      xinc := (onion - pStart^.m_FrameNo) * ((TStickManPtr(pEnd^.m_pObject)^.m_alpha - TStickManPtr(pStart^.m_pObject)^.m_alpha) / nIterations);
                      alpha := round(TStickManPtr(pStart^.m_pObject)^.m_alpha + xinc);
                           if (onion < nFRame) then
                           begin
                              alpha := round(alpha * (1 - ((nFrame - onion) / frameDiff)));
                           end;
                      TStickManPtr(m_pTempObject)^.m_alpha := alpha;
                   //alpha/
                       if (onion = nFrame) then
                       begin
                           DWORDtoRGB(TStickManPtr(pStart^.m_pObject)^.m_InColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TStickManPtr(pEnd^.m_pObject)^.m_InColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           TStickManPtr(m_pTempObject)^.m_InColour := rgb(r[3],g[3],b[3]);
                           DWORDtoRGB(TStickManPtr(pStart^.m_pObject)^.m_OutColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TStickManPtr(pEnd^.m_pObject)^.m_OutColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           TStickManPtr(m_pTempObject)^.m_OutColour := rgb(r[3],g[3],b[3]);
                           TStickManPtr(m_pTempObject)^.Draw(xoffs,yoffs,DrawControlPoints);
                       end else
                       begin
                           DWORDtoRGB(TStickManPtr(pStart^.m_pObject)^.m_InColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TStickManPtr(pEnd^.m_pObject)^.m_InColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           r[3] := r[3] div (onion div 3+1);
                           g[3] := g[3] div (onion div 3+1);
                           b[3] := b[3] div (onion div 3+1);
                           TStickManPtr(m_pTempObject)^.m_InColour := rgb(r[3],g[3],b[3]);
                           DWORDtoRGB(TStickManPtr(pStart^.m_pObject)^.m_OutColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TStickManPtr(pEnd^.m_pObject)^.m_OutColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           r[3] := r[3] div (onion div 3+1);
                           g[3] := g[3] div (onion div 3+1);
                           b[3] := b[3] div (onion div 3+1);
                           TStickManPtr(m_pTempObject)^.m_OutColour := rgb(r[3],g[3],b[3]);
                           TStickManPtr(m_pTempObject)^.Draw(xoffs,yoffs,FALSE);
                       end;
                   end;
                   onion := onion + 1;
               end;
           exit;
        end;
{}      if (m_nType = O_SPECIALSTICK) then
        begin
               TSpecialStickManPtr(m_pTempObject)^.Assign(TSpecialStickManPtr(pStart^.m_pObject));
               nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
               onion := nFrame - pStart^.m_nOnion;
               if (onion < pStart^.m_FrameNo) then onion := pStart^.m_FrameNo;
               while onion <= nFrame do
               begin
                   begin
                       xinc := (onion - pStart^.m_FrameNo) * ((TSpecialStickManPtr(pEnd^.m_pObject)^.m_nLineWidth - TSpecialStickManPtr(pStart^.m_pObject)^.m_nLineWidth) / nIterations);
                       TSpecialStickManPtr(m_pTempObject)^.m_nLineWidth := round(TSpecialStickManPtr(pStart^.m_pObject)^.m_nLineWidth + xinc);
                       for f := 1 to 14 do
                       begin
                          if (TSpecialStickManPtr(pStart^.m_Pobject)^.Pnt(f)^.Left) <> (TSpecialStickManPtr(pEnd^.m_Pobject)^.Pnt(f)^.Left) then
                          begin
                             xinc := (onion - pStart^.m_FrameNo) * ((TSpecialStickManPtr(pEnd^.m_pObject)^.Pnt(f)^.Left - TSpecialStickManPtr(pStart^.m_pObject)^.Pnt(f)^.Left) / nIterations);
                             TSpecialStickManPtr(m_pTempObject)^.Pnt(f)^.Left := round(TSpecialStickManPtr(pStart^.m_pObject)^.Pnt(f)^.Left + xinc);
                          end;
                          if (TSpecialStickManPtr(pStart^.m_Pobject)^.Pnt(f)^.Top) <> (TSpecialStickManPtr(pEnd^.m_Pobject)^.Pnt(f)^.Top) then
                          begin
                             yinc := (onion - pStart^.m_FrameNo) * ((TSpecialStickManPtr(pEnd^.m_pObject)^.Pnt(f)^.Top - TSpecialStickManPtr(pStart^.m_pObject)^.Pnt(f)^.Top) / nIterations);
                             TSpecialStickManPtr(m_pTempObject)^.Pnt(f)^.Top := round(TSpecialStickManPtr(pStart^.m_pObject)^.Pnt(f)^.Top + yinc);
                          end;
                          if (TSpecialStickManPtr(pStart^.m_Pobject)^.Wid[f]) <> (TSpecialStickManPtr(pEnd^.m_Pobject)^.Wid[f]) then
                          begin
                             xinc := (onion - pStart^.m_FrameNo) * ((TSpecialStickManPtr(pEnd^.m_pObject)^.Wid[f] - TSpecialStickManPtr(pStart^.m_pObject)^.Wid[f]) / nIterations);
                             TSpecialStickManPtr(m_pTempObject)^.Wid[f] := round(TSpecialStickManPtr(pStart^.m_pObject)^.Wid[f] + xinc);
                          end;
                       end;
                       if (TSpecialStickManPtr(pStart^.m_Pobject)^.m_nHeadDiam) <> (TSpecialStickManPtr(pEnd^.m_Pobject)^.m_nHeadDiam) then
                       begin
                          xinc := (onion - pStart^.m_FrameNo) * ((TSpecialStickManPtr(pEnd^.m_pObject)^.m_nHeadDiam - TSpecialStickManPtr(pStart^.m_pObject)^.m_nHeadDiam) / nIterations);
                          TSpecialStickManPtr(m_pTempObject)^.m_nHeadDiam := round(TSpecialStickManPtr(pStart^.m_pObject)^.m_nHeadDiam + xinc);
                       end;
                   //alpha
                      xinc := (onion - pStart^.m_FrameNo) * ((TSpecialStickManPtr(pEnd^.m_pObject)^.m_alpha - TSpecialStickManPtr(pStart^.m_pObject)^.m_alpha) / nIterations);
                      TSpecialStickManPtr(m_pTempObject)^.m_alpha := round(TSpecialStickManPtr(pStart^.m_pObject)^.m_alpha + xinc);
                   //alpha/
                       if (onion = nFrame) then
                       begin
                           DWORDtoRGB(TSpecialStickManPtr(pStart^.m_pObject)^.m_InColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TSpecialStickManPtr(pEnd^.m_pObject)^.m_InColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           TSpecialStickManPtr(m_pTempObject)^.m_InColour := rgb(r[3],g[3],b[3]);
                           DWORDtoRGB(TSpecialStickManPtr(pStart^.m_pObject)^.m_OutColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TSpecialStickManPtr(pEnd^.m_pObject)^.m_OutColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           TSpecialStickManPtr(m_pTempObject)^.m_OutColour := rgb(r[3],g[3],b[3]);
                           TSpecialStickManPtr(m_pTempObject)^.Draw(xoffs,yoffs,DrawControlPoints);
                       end else
                       begin
                           DWORDtoRGB(TSpecialStickManPtr(pStart^.m_pObject)^.m_InColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TSpecialStickManPtr(pEnd^.m_pObject)^.m_InColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           r[3] := r[3] div (onion div 3+1);
                           g[3] := g[3] div (onion div 3+1);
                           b[3] := b[3] div (onion div 3+1);
                           TSpecialStickManPtr(m_pTempObject)^.m_InColour := rgb(r[3],g[3],b[3]);
                           DWORDtoRGB(TSpecialStickManPtr(pStart^.m_pObject)^.m_OutColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TSpecialStickManPtr(pEnd^.m_pObject)^.m_OutColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           r[3] := r[3] div (onion div 3+1);
                           g[3] := g[3] div (onion div 3+1);
                           b[3] := b[3] div (onion div 3+1);
                           TSpecialStickManPtr(m_pTempObject)^.m_OutColour := rgb(r[3],g[3],b[3]);
                           TSpecialStickManPtr(m_pTempObject)^.Draw(xoffs,yoffs,FALSE);
                       end;
                   end;
                   onion := onion + 1;
               end;
           exit;
        end;
{}      if (m_nType = O_STICKMANBMP) then
        begin
               TStickManBMPPtr(m_pTempObject)^.Assign(TStickManBMPPtr(pStart^.m_pObject));
               nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
               onion := nFrame - pStart^.m_nOnion;
               if (onion < pStart^.m_FrameNo) then onion := pStart^.m_FrameNo;
               while onion <= nFrame do
               begin
                   begin
                       for f := 1 to 10 do
                       begin
                          if (TStickManBMPPtr(pStart^.m_Pobject)^.Pnt(f)^.Left) <> (TStickManBMPPtr(pEnd^.m_Pobject)^.Pnt(f)^.Left) then
                          begin
                             xinc := (onion - pStart^.m_FrameNo) * ((TStickManBMPPtr(pEnd^.m_pObject)^.Pnt(f)^.Left - TStickManBMPPtr(pStart^.m_pObject)^.Pnt(f)^.Left) / nIterations);
                             TStickManBMPPtr(m_pTempObject)^.Pnt(f)^.Left := round(TStickManBMPPtr(pStart^.m_pObject)^.Pnt(f)^.Left + xinc);
                          end;
                          if (TStickManBMPPtr(pStart^.m_Pobject)^.Pnt(f)^.Top) <> (TStickManBMPPtr(pEnd^.m_Pobject)^.Pnt(f)^.Top) then
                          begin
                             yinc := (onion - pStart^.m_FrameNo) * ((TStickManBMPPtr(pEnd^.m_pObject)^.Pnt(f)^.Top - TStickManBMPPtr(pStart^.m_pObject)^.Pnt(f)^.Top) / nIterations);
                             TStickManBMPPtr(m_pTempObject)^.Pnt(f)^.Top := round(TStickManBMPPtr(pStart^.m_pObject)^.Pnt(f)^.Top + yinc);
                          end;
                          if (TStickManBMPPtr(pStart^.m_Pobject)^.Wid[f]) <> (TStickManBMPPtr(pEnd^.m_Pobject)^.Wid[f]) then
                          begin
                             xinc := (onion - pStart^.m_FrameNo) * ((TStickManBMPPtr(pEnd^.m_pObject)^.Wid[f] - TStickManBMPPtr(pStart^.m_pObject)^.Wid[f]) / nIterations);
                             TStickManBMPPtr(m_pTempObject)^.Wid[f] := round(TStickManBMPPtr(pStart^.m_pObject)^.Wid[f] + xinc);
                          end;
                       end;
                       if (TStickManBMPPtr(pStart^.m_Pobject)^.m_nHeadDiam) <> (TStickManBMPPtr(pEnd^.m_Pobject)^.m_nHeadDiam) then
                       begin
                          xinc := (onion - pStart^.m_FrameNo) * ((TStickManBMPPtr(pEnd^.m_pObject)^.m_nHeadDiam - TStickManBMPPtr(pStart^.m_pObject)^.m_nHeadDiam) / nIterations);
                          TStickManBMPPtr(m_pTempObject)^.m_nHeadDiam := round(TStickManBMPPtr(pStart^.m_pObject)^.m_nHeadDiam + xinc);
                       end;
                   //alpha
                      xinc := (onion - pStart^.m_FrameNo) * ((TStickManBMPPtr(pEnd^.m_pObject)^.m_alpha - TStickManBMPPtr(pStart^.m_pObject)^.m_alpha) / nIterations);
                      TStickManBMPPtr(m_pTempObject)^.m_alpha := round(TStickManBMPPtr(pStart^.m_pObject)^.m_alpha + xinc);
                   //alpha/
                       if (onion = nFrame) then
                       begin
                           DWORDtoRGB(TStickManBMPPtr(pStart^.m_pObject)^.m_InColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TStickManBMPPtr(pEnd^.m_pObject)^.m_InColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           TStickManBMPPtr(m_pTempObject)^.m_InColour := rgb(r[3],g[3],b[3]);
                           DWORDtoRGB(TStickManBMPPtr(pStart^.m_pObject)^.m_OutColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TStickManBMPPtr(pEnd^.m_pObject)^.m_OutColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           TStickManBMPPtr(m_pTempObject)^.m_OutColour := rgb(r[3],g[3],b[3]);
                           TStickManBMPPtr(m_pTempObject)^.Draw(xoffs,yoffs,DrawControlPoints);
                       end else
                       begin
                           DWORDtoRGB(TStickManBMPPtr(pStart^.m_pObject)^.m_InColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TStickManBMPPtr(pEnd^.m_pObject)^.m_InColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           r[3] := r[3] div (onion div 3+1);
                           g[3] := g[3] div (onion div 3+1);
                           b[3] := b[3] div (onion div 3+1);
                           TStickManBMPPtr(m_pTempObject)^.m_InColour := rgb(r[3],g[3],b[3]);
                           DWORDtoRGB(TStickManBMPPtr(pStart^.m_pObject)^.m_OutColour, r[1],g[1],b[1]);
                           DWORDtoRGB(TStickManBMPPtr(pEnd^.m_pObject)^.m_OutColour, r[2],g[2],b[2]);
                           r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                           g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                           b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                           r[3] := r[3] div (onion div 3+1);
                           g[3] := g[3] div (onion div 3+1);
                           b[3] := b[3] div (onion div 3+1);
                           TStickManBMPPtr(m_pTempObject)^.m_OutColour := rgb(r[3],g[3],b[3]);
                           TStickManBMPPtr(m_pTempObject)^.Draw(xoffs,yoffs,FALSE);
                       end;
                   end;
                   onion := onion + 1;
               end;
           exit;
        end;
{}      if (m_nType = O_BITMAP) then
        begin
               nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
               onion := nFrame - pStart^.m_nOnion;
               if (onion < pStart^.m_FrameNo) then onion := pStart^.m_FrameNo;

               frameDiff := nFrame - onion;
               
               while onion <= nFrame do
               begin
                   for f := 1 to 4 do
                   begin
                      xinc := (onion - pStart^.m_FrameNo) * ((TBitManPtr(pEnd^.m_pObject)^.Pnt(f)^.Left - TBitManPtr(pStart^.m_pObject)^.Pnt(f)^.Left) / nIterations);
                      TBitManPtr(m_pTempObject)^.Pnt(f)^.Left := round(TBitManPtr(pStart^.m_pObject)^.Pnt(f)^.Left + xinc);
                      yinc := (onion - pStart^.m_FrameNo) * ((TBitManPtr(pEnd^.m_pObject)^.Pnt(f)^.Top - TBitManPtr(pStart^.m_pObject)^.Pnt(f)^.Top) / nIterations);
                      TBitManPtr(m_pTempObject)^.Pnt(f)^.Top := round(TBitManPtr(pStart^.m_pObject)^.Pnt(f)^.Top + yinc);
                   end;
                   //angle
                      xinc := (onion - pStart^.m_FrameNo) * ((TBitManPtr(pEnd^.m_pObject)^.m_angle - TBitManPtr(pStart^.m_pObject)^.m_angle) / nIterations);
                      TBitManPtr(m_pTempObject)^.m_angle := (TBitManPtr(pStart^.m_pObject)^.m_angle + xinc);
                   //angle/
                   //alpha
                      xinc := (onion - pStart^.m_FrameNo) * ((TBitManPtr(pEnd^.m_pObject)^.m_alpha - TBitManPtr(pStart^.m_pObject)^.m_alpha) / nIterations);
                      TBitManPtr(m_pTempObject)^.m_alpha := round(TBitManPtr(pStart^.m_pObject)^.m_alpha + xinc);
                           alpha := TBitManPtr(m_pTempObject)^.m_alpha;
                           if (onion < nFRame) then
                           begin
                              alpha := round(alpha * (1 - ((nFrame - onion) / frameDiff)));
                           end;
                   //alpha/
                   TBitManPtr(m_pTempObject)^.Draw(xoffs,yoffs,alpha,DrawControlPoints);
                   onion := onion + 1;
               end;
           exit;
        end;
{}      if (m_nType = O_RECTANGLE) then
        begin
               nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
               onion := nFrame - pStart^.m_nOnion;
               if (onion < pStart^.m_FrameNo) then onion := pStart^.m_FrameNo;
               while onion <= nFrame do
               begin
                   for f := 1 to 4 do
                   begin
                         xinc := (onion - pStart^.m_FrameNo) * ((TSquareObjPtr(pEnd^.m_pObject)^.Pnt(f)^.left - TSquareObjPtr(pStart^.m_pObject)^.Pnt(f)^.left) / nIterations);
                         TSquareObjPtr(m_pTempObject)^.Pnt(f)^.left := round(TSquareObjPtr(pStart^.m_pObject)^.Pnt(f)^.left + xinc);
                         yinc := (onion - pStart^.m_FrameNo) * ((TSquareObjPtr(pEnd^.m_pObject)^.Pnt(f)^.top - TSquareObjPtr(pStart^.m_pObject)^.Pnt(f)^.top) / nIterations);
                         TSquareObjPtr(m_pTempObject)^.Pnt(f)^.top := round(TSquareObjPtr(pStart^.m_pObject)^.Pnt(f)^.top + yinc);
                   end;
                   //angle
                      xinc := (onion - pStart^.m_FrameNo) * ((TSquareObjPtr(pEnd^.m_pObject)^.m_angle - TSquareObjPtr(pStart^.m_pObject)^.m_angle) / nIterations);
                      TSquareObjPtr(m_pTempObject)^.m_angle := (TSquareObjPtr(pStart^.m_pObject)^.m_angle + xinc);
                   //angle/
                   //alpha
                      xinc := (onion - pStart^.m_FrameNo) * ((TSquareObjPtr(pEnd^.m_pObject)^.m_alpha - TSquareObjPtr(pStart^.m_pObject)^.m_alpha) / nIterations);
                      TSquareObjPtr(m_pTempObject)^.m_alpha := round(TSquareObjPtr(pStart^.m_pObject)^.m_alpha + xinc);
                   //alpha/
                      xinc := (onion - pStart^.m_FrameNo) * ((TSquareObjPtr(pEnd^.m_pObject)^.m_nLineWidth - TSquareObjPtr(pStart^.m_pObject)^.m_nLineWidth) / nIterations);
                      TSquareObjPtr(m_pTempObject)^.m_nLineWidth := round(TSquareObjPtr(pStart^.m_pObject)^.m_nLineWidth + xinc);
                      DWORDtoRGB(TSquareObjPtr(pStart^.m_pObject)^.m_InColour, r[1],g[1],b[1]);
                      DWORDtoRGB(TSquareObjPtr(pEnd^.m_pObject)^.m_InColour, r[2],g[2],b[2]);
                      r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                      g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                      b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                      TSquareObjPtr(m_pTempObject)^.m_InColour := rgb(r[3],g[3],b[3]);
                      DWORDtoRGB(TSquareObjPtr(pStart^.m_pObject)^.m_OutColour, r[1],g[1],b[1]);
                      DWORDtoRGB(TSquareObjPtr(pEnd^.m_pObject)^.m_OutColour, r[2],g[2],b[2]);
                      r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                      g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                      b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                      TSquareObjPtr(m_pTempObject)^.m_OutColour := rgb(r[3],g[3],b[3]);
                   TSquareObjPtr(m_pTempObject)^.m_styleInner := TSquareObjPtr(pStart^.m_pObject)^.m_styleInner;
                   TSquareObjPtr(m_pTempObject)^.m_styleOuter := TSquareObjPtr(pStart^.m_pObject)^.m_styleOuter;
                   TSquareObjPtr(m_pTempObject)^.Draw(xoffs,yoffs,DrawControlPoints);
                 onion := onion + 1;
               end;
           exit;
        end;
{}      if (m_nType = O_LINE) then
        begin
           nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
           onion := nFrame - pStart^.m_nOnion;
               if (onion < pStart^.m_FrameNo) then onion := pStart^.m_FrameNo;
           while onion <= nFrame do
           begin
               for f := 1 to 2 do
               begin
                  xinc := (onion - pStart^.m_FrameNo) * ((TLineObjPtr(pEnd^.m_pObject)^.Pnt(f)^.left - TLineObjPtr(pStart^.m_pObject)^.Pnt(f)^.left) / nIterations);
                  TLineObjPtr(m_pTempObject)^.Pnt(f)^.left := round(TLineObjPtr(pStart^.m_pObject)^.Pnt(f)^.left + xinc);
                  yinc := (onion - pStart^.m_FrameNo) * ((TLineObjPtr(pEnd^.m_pObject)^.Pnt(f)^.top - TLineObjPtr(pStart^.m_pObject)^.Pnt(f)^.top) / nIterations);
                  TLineObjPtr(m_pTempObject)^.Pnt(f)^.top := round(TLineObjPtr(pStart^.m_pObject)^.Pnt(f)^.top + yinc);
               end;
                   //alpha
                      xinc := (onion - pStart^.m_FrameNo) * ((TLineObjPtr(pEnd^.m_pObject)^.m_alpha - TLineObjPtr(pStart^.m_pObject)^.m_alpha) / nIterations);
                      TLineObjPtr(m_pTempObject)^.m_alpha := round(TLineObjPtr(pStart^.m_pObject)^.m_alpha + xinc);
                   //alpha/
               xinc := (onion - pStart^.m_FrameNo) * ((TLineObjPtr(pEnd^.m_pObject)^.m_nLineWidth - TLineObjPtr(pStart^.m_pObject)^.m_nLineWidth) / nIterations);
               TLineObjPtr(m_pTempObject)^.m_nLineWidth := round(TLineObjPtr(pStart^.m_pObject)^.m_nLineWidth + xinc);
               DWORDtoRGB(TLineObjPtr(pStart^.m_pObject)^.m_Colour, r[1],g[1],b[1]);
               DWORDtoRGB(TLineObjPtr(pEnd^.m_pObject)^.m_Colour, r[2],g[2],b[2]);
               r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
               g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
               b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
               TLineObjPtr(m_pTempObject)^.m_Colour := rgb(r[3],g[3],b[3]);
               TLineObjPtr(m_pTempObject)^.Draw(xoffs,yoffs,DrawControlPoints);
              onion := onion + 1;
           end;
           exit;
        end;
{}      if (m_nType = O_EXPLODE) then
        begin
               nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
               DrawControlPoints := FALSE;
               if nFrame = pStart^.m_FrameNo then DrawControlPoints := not frmMain.m_bPlaying;
               TExplodeObjPtr(pStart^.m_pObject)^.Draw(xoffs,yoffs,nIterations, (nFrame - pStart^.m_FrameNo), DrawControlPoints);
           exit;
        end;
{}      if (m_nType = O_T2STICK) then
        begin
           nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;

            onion := nFrame - pStart^.m_nOnion;
            if (onion < pStart^.m_FrameNo) then onion := pStart^.m_FrameNo;
            frameDiff := nFrame - onion;
            renderer := TStickRenderer.Create(frmMain.m_Canvas);
            renderer.XOffset := xoffs;
            renderer.yoffset := yoffs;
            while onion <= nFrame do
            begin
               TLimbListPtr(m_pTempObject)^.Tween(TLimbListPtr(pStart^.m_pObject)^, TLimbListPtr(pEnd^.m_pObject)^, (onion-pStart^.m_FrameNo) / nIterations);
               renderer.DrawControlPoints := DrawControlPoints and (onion = nFrame);
               TLimbListPtr(m_pTempObject)^.ShowJoints := renderer.DrawControlPoints;
               onion := onion + 1;
               TLimbListPtr(m_pTempObject)^.Alpha := TLimbListPtr(m_pTempObject)^.Alpha * frmMain.m_alphaMultiplier;
                           alpha := round(TLimbListPtr(m_pTempObject)^.Alpha * 255);
                           if (onion < nFRame) then
                           begin
                              alpha := round(alpha * (1 - ((nFrame - onion) / frameDiff)));
                           end;
               renderer.DrawStick(TLimbListPtr(m_pTempObject)^, 0, alpha);
            end;
            renderer.Destroy;

           {TLimbListPtr(m_pTempObject)^.Tween(TLimbListPtr(pStart^.m_pObject)^, TLimbListPtr(pEnd^.m_pObject)^, (nFrame-pStart^.m_FrameNo) / nIterations);
           TLimbListPtr(m_pTempObject)^.ShowJoints := DrawControlPoints;

           renderer := TStickRenderer.Create(frmMain.m_Canvas);
           renderer.DrawControlPoints := DrawControlPoints;
           renderer.XOffset := xoffs;
           renderer.yoffset := yoffs;
           TLimbListPtr(m_pTempObject)^.Alpha := TLimbListPtr(m_pTempObject)^.Alpha * frmMain.m_alphaMultiplier;
           renderer.DrawStick(0,0, TLimbListPtr(m_pTempObject)^, 0);
           renderer.Destroy; }

           exit;
        end;
{}      if (m_nType = O_TEXT) then
        begin
               nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
           onion := nFrame - pStart^.m_nOnion;
               if (onion < pStart^.m_FrameNo) then onion := pStart^.m_FrameNo;
           while onion <= nFrame do
           begin
               for f := 1 to 4 do
               begin
                     xinc := (onion - pStart^.m_FrameNo) * ((TTextObjPtr(pEnd^.m_pObject)^.Pnt(f)^.Left - TTextObjPtr(pStart^.m_pObject)^.Pnt(f)^.Left) / nIterations);
                     TTextObjPtr(m_pTempObject)^.Pnt(f)^.Left := round(TTextObjPtr(pStart^.m_pObject)^.Pnt(f)^.Left + xinc);
                     yinc := (onion - pStart^.m_FrameNo) * ((TTextObjPtr(pEnd^.m_pObject)^.Pnt(f)^.Top - TTextObjPtr(pStart^.m_pObject)^.Pnt(f)^.Top) / nIterations);
                     TTextObjPtr(m_pTempObject)^.Pnt(f)^.Top := round(TTextObjPtr(pStart^.m_pObject)^.Pnt(f)^.Top + yinc);
               end;
                   //angle
                      xinc := (onion - pStart^.m_FrameNo) * ((TTextObjPtr(pEnd^.m_pObject)^.m_angle - TTextObjPtr(pStart^.m_pObject)^.m_angle) / nIterations);
                      TTextObjPtr(m_pTempObject)^.m_angle := (TTextObjPtr(pStart^.m_pObject)^.m_angle + xinc);
                   //angle/
                   //alpha
                      xinc := (onion - pStart^.m_FrameNo) * ((TTextObjPtr(pEnd^.m_pObject)^.m_alpha - TTextObjPtr(pStart^.m_pObject)^.m_alpha) / nIterations);
                      TTextObjPtr(m_pTempObject)^.m_alpha := round(TTextObjPtr(pStart^.m_pObject)^.m_alpha + xinc);
                   //alpha/
               DWORDtoRGB(TTextObjPtr(pStart^.m_pObject)^.m_InColour, r[1],g[1],b[1]);
               DWORDtoRGB(TTextObjPtr(pEnd^.m_pObject)^.m_InColour, r[2],g[2],b[2]);
               r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
               g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
               b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
               TTextObjPtr(m_pTempObject)^.m_InColour := rgb(r[3],g[3],b[3]);
               DWORDtoRGB(TTextObjPtr(pStart^.m_pObject)^.m_OutColour, r[1],g[1],b[1]);
               DWORDtoRGB(TTextObjPtr(pEnd^.m_pObject)^.m_OutColour, r[2],g[2],b[2]);
               r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
               g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
               b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
               TTextObjPtr(m_pTempObject)^.m_OutColour := rgb(r[3],g[3],b[3]);
               TTextObjPtr(m_pTempObject)^.m_strCaption := TTextObjPtr(pStart^.m_pObject)^.m_strCaption;
               TTextObjPtr(m_pTempObject)^.m_styleOuter := TTextObjPtr(pStart^.m_pObject)^.m_styleOuter;
               TTextObjPtr(m_pTempObject)^.m_strFontName := TTextObjPtr(pStart^.m_pObject)^.m_strFontName;
               TTextObjPtr(m_pTempObject)^.m_FontStyle := TTextObjPtr(pStart^.m_pObject)^.m_FontStyle;
               TTextObjPtr(m_pTempObject)^.Draw(xoffs,yoffs,DrawControlPoints);
              onion := onion + 1;
           end;
           exit;
        end;
{}      if (m_nType = O_POLY) then
        begin
               nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
           onion := nFrame - pStart^.m_nOnion;
               if (onion < pStart^.m_FrameNo) then onion := pStart^.m_FrameNo;
           while onion <= nFrame do
           begin
               for f := 0 to TPolyObjPtr(m_pObject)^.PntList.Count-1 do
               begin
                     xinc := (onion - pStart^.m_FrameNo) * ((TLabel2Ptr(TPolyObjPtr(pEnd^.m_pObject)^.PntList.Items[f])^.Left - TLabel2Ptr(TPolyObjPtr(pStart^.m_pObject)^.PntList.Items[f])^.Left) / nIterations);
                     TLabel2Ptr(TPolyObjPtr(m_pTempObject)^.PntList.Items[f])^.Left := round(TLabel2Ptr(TPolyObjPtr(pStart^.m_pObject)^.PntList.Items[f])^.Left + xinc);
                     yinc := (onion - pStart^.m_FrameNo) * ((TLabel2Ptr(TPolyObjPtr(pEnd^.m_pObject)^.PntList.Items[f])^.Top - TLabel2Ptr(TPolyObjPtr(pStart^.m_pObject)^.PntList.Items[f])^.Top) / nIterations);
                     TLabel2Ptr(TPolyObjPtr(m_pTempObject)^.PntList.Items[f])^.Top := round(TLabel2Ptr(TPolyObjPtr(pStart^.m_pObject)^.PntList.Items[f])^.Top + yinc);
               end;
                   //alpha
                      xinc := (onion - pStart^.m_FrameNo) * ((TPolyObjPtr(pEnd^.m_pObject)^.m_alpha - TPolyObjPtr(pStart^.m_pObject)^.m_alpha) / nIterations);
                      TPolyObjPtr(m_pTempObject)^.m_alpha := round(TPolyObjPtr(pStart^.m_pObject)^.m_alpha + xinc);
                   //alpha/
                  xinc := (onion - pStart^.m_FrameNo) * ((TPolyObjPtr(pEnd^.m_pObject)^.m_nLineWidth - TPolyObjPtr(pStart^.m_pObject)^.m_nLineWidth) / nIterations);
                  TPolyObjPtr(m_pTempObject)^.m_nLineWidth := round(TPolyObjPtr(pStart^.m_pObject)^.m_nLineWidth + xinc);
                  DWORDtoRGB(TPolyObjPtr(pStart^.m_pObject)^.m_InColour, r[1],g[1],b[1]);
                  DWORDtoRGB(TPolyObjPtr(pEnd^.m_pObject)^.m_InColour, r[2],g[2],b[2]);
                  r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                  g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                  b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                  TPolyObjPtr(m_pTempObject)^.m_InColour := rgb(r[3],g[3],b[3]);
                  DWORDtoRGB(TPolyObjPtr(pStart^.m_pObject)^.m_OutColour, r[1],g[1],b[1]);
                  DWORDtoRGB(TPolyObjPtr(pEnd^.m_pObject)^.m_OutColour, r[2],g[2],b[2]);
                  r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                  g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                  b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                  TPolyObjPtr(m_pTempObject)^.m_OutColour := rgb(r[3],g[3],b[3]);
               TPolyObjPtr(m_pTempObject)^.m_styleInner := TPolyObjPtr(pStart^.m_pObject)^.m_styleInner;
               TPolyObjPtr(m_pTempObject)^.m_styleOuter := TPolyObjPtr(pStart^.m_pObject)^.m_styleOuter;
               TPolyObjPtr(m_pTempObject)^.Draw(xoffs,yoffs,DrawControlPoints);
              onion := onion + 1;
           end;
           exit;
        end;
{}      if (m_nType = O_OVAL) then
        begin
               nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
           onion := nFrame - pStart^.m_nOnion;
               if (onion < pStart^.m_FrameNo) then onion := pStart^.m_FrameNo;
           while onion <= nFrame do
           begin
               for f := 1 to 4 do
               begin
                  xinc := (onion - pStart^.m_FrameNo) * ((TOvalObjPtr(pEnd^.m_pObject)^.Pnt(f)^.Left - TOvalObjPtr(pStart^.m_pObject)^.Pnt(f)^.Left) / nIterations);
                  TOvalObjPtr(m_pTempObject)^.Pnt(f)^.Left := round(TOvalObjPtr(pStart^.m_pObject)^.Pnt(f)^.Left + xinc);
                  yinc := (onion - pStart^.m_FrameNo) * ((TOvalObjPtr(pEnd^.m_pObject)^.Pnt(f)^.Top - TOvalObjPtr(pStart^.m_pObject)^.Pnt(f)^.Top) / nIterations);
                  TOvalObjPtr(m_pTempObject)^.Pnt(f)^.Top := round(TOvalObjPtr(pStart^.m_pObject)^.Pnt(f)^.Top + yinc);
               end;
                   //angle
                      xinc := (onion - pStart^.m_FrameNo) * ((TOvalObjPtr(pEnd^.m_pObject)^.m_angle - TOvalObjPtr(pStart^.m_pObject)^.m_angle) / nIterations);
                      TOvalObjPtr(m_pTempObject)^.m_angle := (TOvalObjPtr(pStart^.m_pObject)^.m_angle + xinc);
                   //angle/
                   //alpha
                      xinc := (onion - pStart^.m_FrameNo) * ((TOvalObjPtr(pEnd^.m_pObject)^.m_alpha - TOvalObjPtr(pStart^.m_pObject)^.m_alpha) / nIterations);
                      TOvalObjPtr(m_pTempObject)^.m_alpha := round(TOvalObjPtr(pStart^.m_pObject)^.m_alpha + xinc);
                   //alpha/
                  xinc := (onion - pStart^.m_FrameNo) * ((TOvalObjPtr(pEnd^.m_pObject)^.m_nLineWidth - TOvalObjPtr(pStart^.m_pObject)^.m_nLineWidth) / nIterations);
                  TOvalObjPtr(m_pTempObject)^.m_nLineWidth := round(TOvalObjPtr(pStart^.m_pObject)^.m_nLineWidth + xinc);
                  DWORDtoRGB(TOvalObjPtr(pStart^.m_pObject)^.m_InColour, r[1],g[1],b[1]);
                  DWORDtoRGB(TOvalObjPtr(pEnd^.m_pObject)^.m_InColour, r[2],g[2],b[2]);
                  r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                  g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                  b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                  TOvalObjPtr(m_pTempObject)^.m_InColour := rgb(r[3],g[3],b[3]);
                  DWORDtoRGB(TOvalObjPtr(pStart^.m_pObject)^.m_OutColour, r[1],g[1],b[1]);
                  DWORDtoRGB(TOvalObjPtr(pEnd^.m_pObject)^.m_OutColour, r[2],g[2],b[2]);
                  r[3] := r[1]+round((onion - pStart^.m_FrameNo) * (r[2] - r[1]) / nIterations);
                  g[3] := g[1]+round((onion - pStart^.m_FrameNo) * (g[2] - g[1]) / nIterations);
                  b[3] := b[1]+round((onion - pStart^.m_FrameNo) * (b[2] - b[1]) / nIterations);
                  TOvalObjPtr(m_pTempObject)^.m_OutColour := rgb(r[3],g[3],b[3]);
               TOvalObjPtr(m_pTempObject)^.m_styleInner := TOvalObjPtr(pStart^.m_pObject)^.m_styleInner;
               TOvalObjPtr(m_pTempObject)^.m_styleOuter := TOvalObjPtr(pStart^.m_pObject)^.m_styleOuter;
               TOvalObjPtr(m_pTempObject)^.Draw(xoffs,yoffs,DrawControlPoints);
              onion := onion + 1;
           end;
           exit;
        end;
{}      if (m_nType = O_SOUND) then
        begin
           bVolChange := FALSE;
           bPanChange := FALSE;
           TSoundObjPtr(m_pObject)^.SetVisible(FALSE);
           nIterations := pEnd^.m_FrameNo - pStart^.m_FrameNo;
           if (TSoundObjPtr(pStart^.m_Pobject)^.Pnt.Left) <> (TSoundObjPtr(pEnd^.m_Pobject)^.Pnt.Left) then
           begin
               xinc := (nFrame - pStart^.m_FrameNo) * ((TSoundObjPtr(pEnd^.m_pObject)^.Pnt.Left - TSoundObjPtr(pStart^.m_pObject)^.Pnt.Left) / nIterations);
               TSoundObjPtr(m_pTempObject)^.Pnt.Left := 10+ round(TSoundObjPtr(pStart^.m_pObject)^.Pnt.Left + xinc);
               bPanChange := TRUE;
           end;
           if (TSoundObjPtr(pStart^.m_Pobject)^.Pnt.Top) <> (TSoundObjPtr(pEnd^.m_Pobject)^.Pnt.Top) then
           begin
              yinc := (nFrame - pStart^.m_FrameNo) * ((TSoundObjPtr(pEnd^.m_pObject)^.Pnt.Top - TSoundObjPtr(pStart^.m_pObject)^.Pnt.Top) / nIterations);
              TSoundObjPtr(m_pTempObject)^.Pnt.Top := 10+ round(TSoundObjPtr(pStart^.m_pObject)^.Pnt.Top + yinc);
              bVolChange := TRUE;
           end;
           TSoundObjPtr(m_pTempObject)^.Draw(DrawControlPoints);
              if (frmMain.m_bPlaying) then      //if movie is being rendered in playback
              begin
                 if (nFrame = pStart^.m_FrameNo) then
                 begin
{                    if (TSoundObjPtr(m_pTempObject)^.m_CHANNEL <> nil) then
                    if (TSoundObjPtr(m_pTempObject)^.m_CHANNEL.Playing) then
                    begin
                       TSoundObjPtr(m_pTempObject)^.m_CHANNEL.Stop;
                       TSoundObjPtr(m_pTempObject)^.m_CHANNEL.Free;
                       TSoundObjPtr(m_pTempObject)^.m_CHANNEL := nil;
                    end;
                    TSoundObjPtr(m_pTempObject)^.m_CHANNEL := TAudioFileStream.Create(frmMAin.DXSound.DSound);
                    TSoundObjPtr(m_pTempObject)^.m_CHANNEL.FileName := TSoundObjPtr(pStart^.m_pObject)^.m_strFileName;
                    TSoundObjPtr(m_pTempObject)^.m_CHANNEL.Play;  }
                 end;
                 if (nFrame = pEnd^.m_FrameNo) then
                 begin
                    {if (TSoundObjPtr(m_pTempObject)^.m_CHANNEL <> nil) then
                    if (TSoundObjPtr(m_pTempObject)^.m_CHANNEL.Playing) then
                    begin
                       TSoundObjPtr(m_pTempObject)^.m_CHANNEL.Stop;
                       TSoundObjPtr(m_pTempObject)^.m_CHANNEL.Free;
                       TSoundObjPtr(m_pTempObject)^.m_CHANNEL := nil;
                    end; }
                 end;
                 {if (TSoundObjPtr(m_pTempObject)^.m_CHANNEL <> nil) then
                 begin
                    if bVolChange then TSoundObjPtr(m_pTempObject)^.m_CHANNEL.Volume := round(-10000 * (TSoundObjPtr(m_pTempObject)^.Pnt.Top / frmCanvas.ClientHeight));
                    if bPanChange then TSoundObjPtr(m_pTempObject)^.m_CHANNEL.Pan := -10000 + round(10000*((TSoundObjPtr(m_pTempObject)^.Pnt.Left / (frmCanvas.ClientWidth/2))));
                 end; }
              end;
           exit;
        end;
   end;
end;

///////////////////////////// frmMAIN    ///////////////////////////////

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if m_bPlaying and (not m_bReady) then
   begin
      Action := caNone;
      m_bQuit := TRUE;
   end else
   begin
      if (frmToolBar <> nil) then frmToolBar.m_nCurrentFrame := frmToolBar.m_nEnd;
      m_bCancelClose := FALSE;
      Close1Click(Sender);
      if (m_bCancelClose) then
      begin
         Action := caNone;
         exit;
      end;
      if (frmToolBar <> nil) then frmToolBar.Close;
      LoadSettings(m_strTHEPATH+'tis.fat', m_Settings);
      if WindowState = wsNormal then
      begin
         m_Settings.WindowState := 0;
         m_Settings.Left := Left;
         m_Settings.Top := Top;
         m_Settings.Width := Width;
         m_Settings.Height := Height;
      end;
      if WindowState = wsMaximized then m_Settings.WindowState := 1;
      if WindowState = wsMinimized then m_Settings.WindowState := 2;
      SaveSettings(m_strTHEPATH+'tis.fat', m_Settings);
   end;
end;

procedure TfrmMain.grdFramesSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
   f,g,h : integer;
   pLayer : TLayerObjPtr;
   pFrame : TSingleFramePtr;
   pTweenFrame : TIFramePtr;
begin

   m_pTempObject := nil;
   m_pObject := nil;

   frmToolBar.ResetHeight;

   if (frmCanvas <> nil) then if (frmCanvas.m_PntList <> nil) then frmCanvas.m_PntList.Clear;
   m_col := -1;//ACol;
   m_col := ACol;
   m_row := ARow;
   frmToolBar.lblFrameNo.Caption := 'Frame: ' + itoa(m_col);
   frmToolBar.lblTime.Caption := 'Time: ' + floattostrf(m_col / atoi(frmToolBar.m_strFPS.Text), ffFixed, 4,2) + 's';

   if (m_col < 1) then
   begin
        if (m_bAdjusting) then
        begin
            m_bAdjusting := FALSE;
            exit;
        end;
        if (m_row = 1) then exit;
        frmLayerName.m_strTitle.Text := TLayerObjPtr(m_olLayers.Items[m_row-1])^.m_strName;
        frmLayerName.ShowModal;
        if frmLayerName.m_bOK then
        begin
           TLayerObjPtr(m_olLayers.Items[m_row-1])^.m_strName := frmLayerName.m_strTitle.Text;
        end;
        grdFrames.Repaint;
        m_col := m_lastCol;
        Render(m_col);
        exit;
   end;

   m_lastCol := m_col;

   if (ARow > 0) then
   begin
       pLayer := m_olLayers.Items[ARow-1];
       m_pTempObject := pLayer^.m_pTempObject;
       m_pObject := pLayer^.m_pObject;
       m_pFrame := nil;
       m_pTweenFrame := nil;
       m_pAction := nil;
       if (pLayer <> nil) then
       begin
           for f := 0 to pLayer^.m_olActions.Count-1 do
           begin
               if TActionObjPtr(pLayer^.m_olActions.Items[f])^.m_nFrameNo = ACol then
               begin
                  m_pAction := pLayer^.m_olActions.Items[f];
                  break;
               end;
           end;
           for f := 0 to pLayer^.m_olFrames.Count - 1 do
           begin
              pFrame := pLayer^.m_olFrames.Items[f];
              begin
                 if (ACol >= TIFramePtr(pFrame^.m_Frames.First)^.m_FrameNo) and (ACol <= TIFramePtr(pFrame^.m_Frames.Last)^.m_FrameNo) then
                 begin
                    m_col := ACol;
                    m_pFrame := pFrame;
                    m_nLastFrame := ACol;
                    for g := 0 to pFrame^.m_Frames.Count-1 do
                    begin
                       pTweenFrame := pFrame^.m_Frames.Items[g];
                       if (ACol = pTweenFrame^.m_FrameNo) then
                       begin
                          m_pTweenFrame := pTweenFrame;
                          if (pLayer^.m_bHidden = FALSE) then
                          begin
                             if (pLayer^.m_nType = O_STICKMAN) then
                             begin
                                 for h := 1 to 10 do frmCanvas.m_PntList.Add(TStickManPtr(m_pTweenFrame^.m_pObject)^.Pnt(h));
                                 frmToolBar.ShowDetails(TStickManPtr(m_pTweenFrame^.m_pObject)^.m_InColour,
                                                        TStickManPtr(m_pTweenFrame^.m_pObject)^.m_OutColour,
                                                        TStickManPtr(m_pTweenFrame^.m_pObject)^.m_Alpha);
                             end;
                             if (pLayer^.m_nType = O_T2STICK) then
                             begin
                                 frmToolBar.ShowDetails(0,0,
                                                        round(TLimbListPtr(m_pTweenFrame^.m_pObject)^.Alpha * 255));
                             end;
                             if (pLayer^.m_nType = O_SPECIALSTICK) then
                             begin
                                 for h := 1 to 14 do frmCanvas.m_PntList.Add(TSpecialStickManPtr(m_pTweenFrame^.m_pObject)^.Pnt(h));
                                 frmToolBar.ShowDetails(TSpecialStickManPtr(m_pTweenFrame^.m_pObject)^.m_InColour,
                                                        TSpecialStickManPtr(m_pTweenFrame^.m_pObject)^.m_OutColour,
                                                        TSpecialStickManPtr(m_pTweenFrame^.m_pObject)^.m_Alpha);
                             end;
                             if (pLayer^.m_nType = O_STICKMANBMP) then
                             begin
                                 for h := 1 to 10 do frmCanvas.m_PntList.Add(TStickManBMPPtr(m_pTweenFrame^.m_pObject)^.Pnt(h));
                             end;
                             if (pLayer^.m_nType = O_BITMAP) then
                             begin
                                 for h := 1 to 4 do frmCanvas.m_PntList.Add(TBitManPtr(m_pTweenFrame^.m_pObject)^.Pnt(h));
                                 frmToolBar.ShowDetails(TBitManPtr(m_pTweenFrame^.m_pObject)^.m_Alpha,
                                                        single(TBitManPtr(m_pTweenFrame^.m_pObject)^.m_Angle));
                             end;
                             if (pLayer^.m_nType = O_RECTANGLE) then
                             begin
                                 for h := 1 to 4 do frmCanvas.m_PntList.Add(TSquareObjPtr(m_pTweenFrame^.m_pObject)^.Pnt(h));
                                 frmToolBar.ShowDetails(TSquareObjPtr(m_pTweenFrame^.m_pObject)^.m_InColour,
                                                        TSquareObjPtr(m_pTweenFrame^.m_pObject)^.m_OutColour,
                                                        TSquareObjPtr(m_pTweenFrame^.m_pObject)^.m_Alpha,
                                                        TSquareObjPtr(m_pTweenFrame^.m_pObject)^.m_Angle);
                             end;
                             if (pLayer^.m_nType = O_EDITVIDEO) then
                             begin
                                 for h := 1 to 4 do frmCanvas.m_PntList.Add(TEditVideoObjPtr(m_pTweenFrame^.m_pObject)^.Pnt(h));
                             end;
                             if (pLayer^.m_nType = O_LINE) then
                             begin
                                 for h := 1 to 2 do frmCanvas.m_PntList.Add(TLineObjPtr(m_pTweenFrame^.m_pObject)^.Pnt(h));
                                 frmToolBar.ShowDetailsMin(TLineObjPtr(m_pTweenFrame^.m_pObject)^.m_Colour,
                                                        TLineObjPtr(m_pTweenFrame^.m_pObject)^.m_Alpha);
                             end;
                             if (pLayer^.m_nType = O_EXPLODE) and (g = 0) then
                             begin
                                 for h := 1 to 2 do frmCanvas.m_PntList.Add(TExplodeObjPtr(m_pTweenFrame^.m_pObject)^.Pnt(h));
                             end;
                             if (pLayer^.m_nType = O_TEXT) then
                             begin
                                 for h := 1 to 4 do frmCanvas.m_PntList.Add(TTextObjPtr(m_pTweenFrame^.m_pObject)^.Pnt(h));
                                 frmToolBar.ShowDetails(TTextObjPtr(m_pTweenFrame^.m_pObject)^.m_InColour,
                                                        TTextObjPtr(m_pTweenFrame^.m_pObject)^.m_OutColour,
                                                        TTextObjPtr(m_pTweenFrame^.m_pObject)^.m_Alpha,
                                                        TTextObjPtr(m_pTweenFrame^.m_pObject)^.m_Angle);
                             end;
                             if (pLayer^.m_nType = O_POLY) then
                             begin
                                 for h := 1 to TPolyObjPtr(m_pTweenFrame^.m_pObject)^.PntList.Count do frmCanvas.m_PntList.Add(TPolyObjPtr(m_pTweenFrame^.m_pObject)^.Pnt(h));
                                 frmToolBar.ShowDetails(TPolyObjPtr(m_pTweenFrame^.m_pObject)^.m_InColour,
                                                        TPolyObjPtr(m_pTweenFrame^.m_pObject)^.m_OutColour,
                                                        TPolyObjPtr(m_pTweenFrame^.m_pObject)^.m_Alpha);
                             end;
                             if (pLayer^.m_nType = O_OVAL) then
                             begin
                                 for h := 1 to 4 do frmCanvas.m_PntList.Add(TOvalObjPtr(m_pTweenFrame^.m_pObject)^.Pnt(h));
                                 frmToolBar.ShowDetails(TOvalObjPtr(m_pTweenFrame^.m_pObject)^.m_InColour,
                                                        TOvalObjPtr(m_pTweenFrame^.m_pObject)^.m_OutColour,
                                                        TOvalObjPtr(m_pTweenFrame^.m_pObject)^.m_Alpha,
                                                        TOvalObjPtr(m_pTweenFrame^.m_pObject)^.m_Angle);
                             end;
                          end;
                          if (pLayer^.m_nType = O_SOUND) then TSoundObjPtr(m_pTweenFrame^.m_pObject)^.SetVisible(TRUE);
                          Render(m_col);
                          break;
                       end;
                    end;
                    break;
                 end;
              end;
           end;
       end;
   end;

   grdFrames.Repaint;
end;

procedure TfrmMain.grdFramesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
   nType : integer;
   pLayer : TLayerObjPtr;
   pFrame : TSingleFramePtr;
   f, g : integer;
   bHidden : boolean;
   strTemp : string;
   bOnion, bAction : boolean;
begin
   bOnion := FALSE;
   bAction := FALSE;
   bHidden := FALSE;
   if (Arow > 0) then bHidden := TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_bHidden;
   pFrame := nil;
   if (ACol = 0) then
   begin
      grdFrames.Canvas.Brush.Style := bsClear;
      grdFrames.Canvas.Font.Color := clWhite;
      if (ARow = 0) then
      begin
         grdFrames.Canvas.CopyRect(Rect, imgTitle.Canvas, Classes.Rect(0,0,imgTitle.Width,imgTitle.Height));
         grdFrames.Canvas.TextOut(Rect.Left+5, Rect.Top+1, 'TIMELINE');
      end else
      if (ARow = 1) then
      begin
         grdFrames.Canvas.CopyRect(Rect, imgTitle.Canvas, Classes.Rect(0,0,imgTitle.Width,imgTitle.Height));
         grdFrames.Canvas.TextOut(Rect.Left+5, Rect.Top+1, 'VIDEO');
      end else
      begin
         if (m_olSelectedLayers.IndexOf(TLayerObjPtr(m_olLayers.Items[ARow-1])) <> -1) then
         begin
            grdFrames.Canvas.Brush.Color := rgb(255,0,0);
            grdFrames.Canvas.Rectangle(Rect);
         end else
         begin
            if (TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_nType = O_STICKMAN) or (TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_nType = O_STICKMANBMP) or (TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_nType = O_SPECIALSTICK) then
            begin
               grdFrames.Canvas.CopyRect(Rect, imgStickLayer.Canvas, Classes.Rect(0,0,imgTitle.Width,imgTitle.Height));
            end else
            if (TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_nType = O_RECTANGLE) then
            begin
               grdFrames.Canvas.CopyRect(Rect, imgRectLayer.Canvas, Classes.Rect(0,0,imgTitle.Width,imgTitle.Height));
            end else
            if (TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_nType = O_OVAL) then
            begin
               grdFrames.Canvas.CopyRect(Rect, imgOvalLayer.Canvas, Classes.Rect(0,0,imgTitle.Width,imgTitle.Height));
            end else
            if (TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_nType = O_LINE) then
            begin
               grdFrames.Canvas.CopyRect(Rect, imgLineLayer.Canvas, Classes.Rect(0,0,imgTitle.Width,imgTitle.Height));
            end else
            if (TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_nType = O_TEXT) then
            begin
               grdFrames.Canvas.CopyRect(Rect, imgTextLayer.Canvas, Classes.Rect(0,0,imgTitle.Width,imgTitle.Height));
            end else
            if (TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_nType = O_POLY) then
            begin
               grdFrames.Canvas.CopyRect(Rect, imgPolyLayer.Canvas, Classes.Rect(0,0,imgTitle.Width,imgTitle.Height));
            end else
            begin
               grdFrames.Canvas.CopyRect(Rect, imgBlank.Canvas, Classes.Rect(0,0,imgTitle.Width,imgTitle.Height));
            end;
         end;
         strTemp := '';
         for f := 1 to length(TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_strName) do
         begin
            strTemp := strTemp + TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_strName[f];
            if grdFrames.Canvas.TextWidth(strTemp + '...A') > imgTitle.Width then
            begin
               strTemp := strTemp + '...';
               break;
            end;
         end;
         grdFrames.Canvas.TextOut(Rect.Left+5, Rect.Top+1, strTemp);
      end;
      grdFrames.Canvas.Brush.Style := bsSolid;
      grdFrames.Canvas.Font.Color := clBlack;
   end else
   begin
      nType := -1;
      grdFrames.Canvas.Pen.Color := clBlack;
      if not bHidden then
      begin
        grdFrames.Canvas.Brush.Color := rgb(220,220,220);
      end else
      begin
        grdFrames.Canvas.Brush.Color := rgb(110,110,110);
      end;
      if (ACol mod 10 = 0) then
      begin
         if (Acol mod 100 = 0) then
         begin
            if (not bHidden) then grdFrames.Canvas.Brush.Color := rgb(255,200,255)
            else grdFrames.Canvas.Brush.Color := rgb(125,100,125)
         end else
         begin
            if (not bHidden) then grdFrames.Canvas.Brush.Color := rgb(200,200,255)
            else grdFrames.Canvas.Brush.Color := rgb(100,100,125);
         end;
      end;

      if (ARow > 0) then
      begin
          pLayer := m_olLayers.Items[ARow-1];
          if (pLayer <> nil) then
          begin
              for f := 0 to pLayer^.m_olFrames.Count - 1 do
              begin
                 pFrame := pLayer^.m_olFrames.Items[f];
                 if (pFrame <> nil) then
                 begin
                    if (ACol = TIFRamePtr(pFrame^.m_Frames.First)^.m_FrameNo) or (ACol = TIFRamePtr(pFrame^.m_Frames.Last)^.m_FrameNo) then
                    begin
                       nType := 5;
                       break;
                    end;
                    if (ACol >= TIFramePtr(pFrame^.m_Frames.First)^.m_FrameNo) and (ACol <= TIFRamePtr(pFrame^.m_Frames.Last)^.m_FrameNo) then
                    begin
                       nType := pFrame^.m_Type;
                       break;
                    end;
                 end;
              end;
          end;
      end;

      if (pFrame <> nil) then
      for g := 0 to pFrame^.m_Frames.Count-1 do
      begin
          if (TIFramePtr(pFrame^.m_Frames.Items[g])^.m_FrameNo = ACol) then
          begin
             bOnion := TIFramePtr(pFrame^.m_Frames.Items[g])^.m_nOnion <> 0;
             nType := 7;
             if (TIFramePtr(pFrame^.m_Frames.Items[g]) = pFrame^.m_Frames.First) or (TIFramePtr(pFrame^.m_Frames.Items[g]) = pFrame^.m_Frames.Last) then nType := 5;
             break;
          end;
      end;

      begin
         case (nType) of
            1: begin    {default: drawing}
                  grdFrames.Canvas.Pen.Color := clBlack;
                  grdFrames.Canvas.Brush.Color := rgb(250,250,250);
               end;
            2,4: begin    {2 = Motion Tween Start}
                  grdFrames.Canvas.Pen.Color := clBlack;
                  grdFrames.Canvas.Brush.Color := rgb(50,100,255);
               end;
            5: begin    {5 = Start or End Frame - draggable}
                  grdFrames.Canvas.Pen.Color := clWhite;
                  if not bHidden then grdFrames.Canvas.Brush.Color := rgb(255,200,100)
                  else grdFrames.Canvas.Brush.Color := rgb(200,150,50);
               end;
            6: begin    {6 = tween}
                  grdFrames.Canvas.Pen.Color := clBlack;
                  if not bHidden then grdFrames.Canvas.Brush.Color := rgb(250,250,250)
                  else grdFrames.Canvas.Brush.Color := rgb(200,200,200);
               end;
            7: begin    {7 = real in between tweens}
                  grdFrames.Canvas.Pen.Color := clBlack;
                  if not bHidden then grdFrames.Canvas.Brush.Color := rgb(235,180,80)
                  else grdFrames.Canvas.Brush.Color := rgb(200,130,70);
               end;
         end;
      end;
      if (ACol = m_col) and (ARow = m_row) then
      begin
         grdFrames.Canvas.Pen.Color := clYellow;
         grdFrames.Canvas.Brush.Color := clRed;
      end;
      grdFrames.Canvas.FillRect(Rect);
      if ARow < 1 then
      begin
         grdFrames.Canvas.Font.Color := rgb(150,150,150);
         grdFrames.Canvas.TextOut(Rect.Left,Rect.Top, copy(itoa(ACol),length(itoa(ACol)),1) );
      end;
      if ARow > 0 then
      begin
            for f := 0 to TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_olActions.Count-1 do
            begin
                if (TActionObjPtr(TLayerObjPtr(m_olLayers.Items[ARow-1])^.m_olActions.Items[f])^.m_nFrameNo = ACol) then
                begin
                   bAction := TRUE;
                   break;
                end;
            end;
            if (bOnion and (not bAction)) then
            begin
                   grdFrames.Canvas.Font.Color := rgb(150,150,150);
                   grdFrames.Canvas.TextOut(Rect.Left,Rect.Top, 'o' );
            end;
            if (bAction and (not bOnion)) then
            begin
                   grdFrames.Canvas.Font.Color := rgb(150,150,150);
                   grdFrames.Canvas.TextOut(Rect.Left,Rect.Top, 'a' );
            end;
            if (bOnion and bAction) then
            begin
                   grdFrames.Canvas.Font.Color := rgb(150,150,150);
                   grdFrames.Canvas.TextOut(Rect.Left,Rect.Top, 'b' );
            end;
      end;
   end;

   if (m_row = 0) then
   begin
      if ACol = m_col then
      begin
         if not bHidden then
         begin
           grdFrames.Canvas.Pen.Color := rgb(0,255,255);
           grdFrames.Canvas.Brush.Color := rgb(0,255,255);
         end else
         begin
           grdFrames.Canvas.Pen.Color := rgb(0,125,125);
           grdFrames.Canvas.Brush.Color := rgb(0,125,125);
         end;
         grdFrames.Canvas.FillRect(rect);
         grdFrames.Canvas.Pen.Color := rgb(255,0,0);
         grdFrames.Canvas.MoveTo(Rect.Left + ((Rect.Left + Rect.Right) div 2), Rect.Top);
         grdFrames.Canvas.LineTo(Rect.Left + ((Rect.Left + Rect.Right) div 2), Rect.Bottom);
      end;
   end;

end;

procedure TfrmMain.grdFramesMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   f, g : integer;
   tr : TRect;
   bTrue : boolean;
   pKeyFrame : array[1..3] of TIFramePtr;
begin
   ReleaseCapture();
   if (m_bNoNameChange) then
   begin
      //added 65
      m_bNoNameChange := false;
      Render(m_col, true);
      exit;
   end;
   m_bActionMoving := FALSE;
   //Application.ProcessMessages;
   if (Button = mbLeft) then
   begin
      if (x < grdFrames.Colwidths[0]) and (m_row > 0) then
      begin
         grdFramesSelectCell(Sender, 0, m_row, bTrue);
         exit;
      end;
         if (m_pTweenFrame <> nil) then
         begin
            for f := 0 to m_pFrame^.m_Frames.Count-2 do
            begin
               //if (m_pTweenFrame^.m_FrameNo = TIFramePtr(m_pFrame^.m_Frames.Items[f])^.m_FrameNo) then
               {if (m_pTweenFrame <> TIFramePtr(m_pFrame^.m_Frames.Items[f])) then
               begin
                  m_pTweenFrame^.m_FrameNo := m_lastCol;
                  MessageBox(Application.Handle, 'You cannot drop a KeyFrame on top of another', 'Tis an Error', MB_OK or MB_ICONERROR);
                  m_bAdjusting := FALSE;
                  grdFramesSelectCell(Sender, m_lastCol, m_row, bTrue);
                  grdFrames.Repaint;
                  Render(m_col);
                  exit;
               end; }
            end;
            for f := 0 to m_pFrame^.m_Frames.Count-2 do
            begin
               for g := f to m_pFrame^.m_Frames.Count-1 do
               begin
                  pKeyFrame[1] := m_pFrame^.m_Frames.Items[f];
                  pKeyFrame[2] := m_pFrame^.m_Frames.Items[g];
                  if (pKeyFrame[1]^.m_FrameNo > pKeyFrame[2]^.m_FrameNo) then
                  begin
                     pKeyFrame[3] := m_pFrame^.m_Frames.Items[f];
                     m_pFrame^.m_Frames.Items[f] := m_pFrame^.m_Frames.Items[g];
                     m_pFrame^.m_Frames.Items[g] := pKeyFrame[3];
                  end;
               end;
            end;
         end;

         if (m_bScrolling) then y := m_nY;

         if (y < grdFrames.RowHeights[0]) then
         begin
           m_pFrame := nil;
           m_pTweenFrame := nil;
           for f := 1 to grdFrames.ColCount-1 do
           begin
              tr := grdFrames.CellRect(f,0);
              if (x >= tr.Left) and (x<= tr.Right) then
              begin
                  m_col := f;
                  m_row := 0;
                  frmToolBar.lblFrameNo.Caption := 'Frame: ' + itoa(m_col);
                  frmToolBar.lblTime.Caption := 'Time: ' + floattostrf(m_col / atoi(frmToolBar.m_strFPS.Text), ffFixed, 4,2) + 's';
                  grdFrames.Repaint;
                  if f > 0 then Render(f);
                  m_bAdjusting := FALSE;
                  m_bScrolling := FALSE;
                  exit;
              end;
           end;
         end else
         begin
            grdFrames.MouseToCell(x,y, m_col, m_row);
            frmToolBar.lblFrameNo.Caption := 'Frame: ' + itoa(m_col);
            frmToolBar.lblTime.Caption := 'Time: ' + floattostrf(m_col / atoi(frmToolBar.m_strFPS.Text), ffFixed, 4,2) + 's';
            grdFrames.RePaint;
            if (m_col > 0) then Render(m_col, (m_pTweenFrame <> nil));
         end;

         m_bScrolling := FALSE;
         m_bAdjusting := FALSE;
   end else
   if (Button = mbRight) then
   begin
      bTrue := TRUE;
      grdFrames.OnSelectCell(self, m_col, m_row, bTrue);
      if (m_col > 0) then Render(m_col);
      for f := 0 to mnuGridPopup.Items.Count-1 do mnuGridPopup.Items[f].Enabled := FALSE;
      mnuGridPopup.Items[11].Enabled := TRUE;
      if (m_row > 0) and (m_row < grdFrames.RowCount) then
      begin
         if (m_row > 1) then
         begin
            if m_row > 0 then mnuGridPopup.Items[12].Enabled := TRUE;
            if m_row > 2 then mnuGridPopup.Items[9].Enabled := TRUE;
            if m_row < grdFrames.RowCount-1 then mnuGridPopup.Items[10].Enabled := TRUE;
         end;

          if (TLayerObjPtr(m_olLayers.Items[m_row-1])^.m_bHidden) then
          begin
             mnuGridPopup.Items[17].Enabled := TRUE;
          end else
          begin
             mnuGridPopup.Items[16].Enabled := TRUE;
          end;
      end;
      if (m_pTweenFrame <> nil) then
      begin
          mnuGridPopup.Items[4].Enabled := TRUE;
      end;
      if (m_pFrame <> nil) then
      begin
         mnuGridPopup.Items[7].Enabled := TRUE;
         mnuGridPopup.Items[13].Enabled := TRUE;
         mnuGridPopup.Items[14].Enabled := TRUE;
      end else
      begin
         if (m_row > 0) then mnuGridPopup.Items[6].Enabled := TRUE;
      end;
      if (m_pFrame <> nil) and (m_pTweenFrame = nil) then
      begin
         mnuGridPopup.Items[0].Enabled := TRUE;
      end;
      if (m_pFrame <> nil) then
      begin
          if (m_pFrame^.m_Frames.First = TIFramePtr(m_pTweenFrame)) then
          begin
             mnuGridPopup.Items[3].Enabled := TRUE;
          end;
          if (m_pFrame^.m_Frames.Last = TIFramePtr(m_pTweenFrame)) then
          begin
             mnuGridPopup.Items[2].Enabled := TRUE;
          end;
      end;

      if (m_pTweenFrame <> nil) and (m_pFrame^.m_Frames.First <> TIFramePtr(m_pTweenFrame)) and (m_pFrame^.m_Frames.Last <> TIFramePtr(m_pTweenFrame)) then
      begin
         mnuGridPopup.Items[1].Enabled := TRUE;
         mnuGridPopup.Items[2].Enabled := TRUE;
         mnuGridPopup.Items[3].Enabled := TRUE;
      end;
      if (m_row = 1) then mnuGridPopup.Items[0].Enabled := FALSE;
      mnuGridPopup.Items[19].Enabled := TRUE;
      mnuGridPopup.Popup(frmMain.Left + grdFrames.Left + x,frmMain.Top + grdFrames.Top + y + 24);
   end;

end;

procedure TfrmMain.grdFramesMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   b : boolean;
   pLayer : TLayerObjPtr;
begin
   SetCapture(grdFrames.Handle);
   m_bActionMoving := FALSE;
   if (Button = mbLeft) then
   begin
      grdFrames.MouseToCell(x,y, m_col, m_row);
      if (Shift = [ssLeft, ssAlt]) then
      begin
          m_bActionMoving := TRUE;
      end;
      if (Shift = [ssLeft, ssCtrl]) then
      begin
          //if TLayerObjPtr(m_olLayers.Items[m_row-1])^
          m_bActionMoving := TRUE;
          Shift := [ssLeft];  //to process the mousedown too
      end;
      //added 65
      if (Shift = [ssLeft, ssShift]) then
      begin
         if (m_col < 1) and (m_row > 1) then
         begin
            pLayer := m_olLayers.Items[m_row-1];
            if (m_olSelectedLayers.IndexOf(pLayer) = -1) then
            begin
               m_olSelectedLayers.Add(pLayer);
            end else
            begin
               m_olSelectedLayers.Remove(pLayer);
            end;
            grdFrames.Repaint;
            m_bNoNameChange := true;
            exit;
         end;
      end;
      if (Shift = [ssLeft]) then
      begin
         //added 65
         if (m_col < 1) and (m_olSelectedLayers.Count <> 0) then
         begin
            m_olSelectedLayers.Clear;
            m_bNoNameChange := true;
         end;
         // ADDED 61
         if (m_col < 1) then
         begin
            m_col := m_lastCol;
            grdFramesSelectCell(Sender, m_col, m_row, b);
            grdFrames.Repaint;
            if (frmCanvas <> nil) then frmCanvas.m_PntList.Clear;
            Render(m_col);
            exit;
         end;
         //
         m_lastCol := m_col;
         if y < grdFrames.RowHeights[0] then
         begin
            m_pFrame := nil;
            m_pTweenFrame := nil;
            m_bScrolling := TRUE;
            m_bActionMoving := FALSE;
            m_nY := y;
            m_row := 0;
         end else
         begin
            m_bAdjusting := TRUE;
            if (m_col > 0) then Render(m_col, FALSE);
         end;
      end;
   end;
   if (Button = mbRight) then
   begin
      grdFrames.MouseToCell(x,y, m_col, m_row);
      // added 61
      if (m_col < 1) then m_col := 1;
      //
      grdFrames.Repaint;
   end;
   frmToolBar.lblFrameNo.Caption := 'Frame ' + itoa(m_col);
   frmToolBar.lblTime.Caption := 'Time ' + floattostrf(m_col / atoi(frmToolBar.m_strFPS.Text), ffFixed, 4,2) + 's';
end;

procedure TfrmMain.grdFramesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   nSel : integer;
   r,f,g : integer;
   tr: trect;
   nDiff : integer;
   nSmallest : integer;
begin
   if (m_bScrolling) then
   begin
      y := m_nY;
      grdFrames.MouseToCell(x,y, nSel,r);
      frmToolBar.lblFrameNo.Caption := 'Frame ' + itoa(nSel);
      frmToolBar.lblTime.Caption := 'Time ' + floattostrf(m_col / atoi(frmToolBar.m_strFPS.Text), ffFixed, 4,2) + 's';
      if nSel < 1 then nSel := 1;
      m_col := nSel;
      m_row := 0;
      if (m_nLast <> nSel) then
      begin
         m_nLast := nSel;
         if (nSel > 0) then Render(nSel);
         for f := 1 to grdFrames.ColCount-1 do
         begin
            tr := grdFrames.CellRect(f,0);
            if (x >= tr.Left) and (x<= tr.Right) then
            begin
                m_col := f;
                if m_col < 1 then m_col := 1;
                m_row := 0;
                grdFrames.Repaint;
                if (f > 0) then Render(f);
                exit;
            end;
         end;
         grdFrames.Repaint;
      end;
   end;
   if (m_bAdjusting) then
   begin
      m_bChanged := TRUE;
      y := m_nY;
      if (m_pFrame <> nil) then
      begin
         grdFrames.MouseToCell(x,y, nSel,r);
         if (nSel < 1) then nSel := 1;
         frmToolBar.lblFrameNo.Caption := 'Frame ' + itoa(nSel);
         frmToolBar.lblTime.Caption := 'Time ' + floattostrf(m_col / atoi(frmToolBar.m_strFPS.Text), ffFixed, 4,2) + 's';
         m_col := nSel;
         if (m_pTweenFrame <> nil) then
         begin
            if (m_bActionMoving) then
            begin
               if (m_pAction <> nil) then
               begin
                  if (m_pAction^ <> nil) then
                     m_pAction^.m_nFrameNo := nSel;
               end;
            end;
            m_pTweenFrame^.m_FrameNo := nSel;
            if (m_pTweenFrame^.m_FrameNo < 1) then m_pTweenFrame^.m_FrameNo := 1;
         end else
         begin
            begin
            //
               nSmallest := 65000;
               for f := 0 to m_pFrame^.m_Frames.Count-1 do
               begin
                  if (TIFramePtr(m_pFrame^.m_Frames.Items[f])^.m_FrameNo < nSmallest) then
                     nSmallest := TIFramePtr(m_pFrame^.m_Frames.Items[f])^.m_FrameNo;
               end;
               nDiff := nSel - m_nLastFrame;
               if (nSmallest < 1) then nDiff := (nDiff - nSmallest) + 1;
                  //////////
                  if (m_bActionMoving) then
                  begin
                     for g := 0 to TLayerObjPtr(m_olLayers.Items[m_row-1])^.m_olActions.Count-1 do
                     begin
                        TActionObjPtr(TLayerObjPtr(m_olLayers.Items[m_row-1])^.m_olActions.Items[g])^.m_nFrameNo := TActionObjPtr(TLayerObjPtr(m_olLayers.Items[m_row-1])^.m_olActions.Items[g])^.m_nFrameNo + nDiff;
                     end;
                  end;
                  //////////
               for f := 0 to m_pFrame^.m_Frames.Count-1 do
               begin
                  TIFramePtr(m_pFrame^.m_Frames.Items[f])^.m_FrameNo := TIFramePtr(m_pFrame^.m_Frames.Items[f])^.m_FrameNo + nDiff;
               end;
               m_nLastFrame := nSel;
            end;
         end;
         grdFrames.Repaint;
      end;
   end else if (m_bActionMoving and (m_pAction <> nil)) then
   begin
      grdFrames.MouseToCell(x,y, nSel,r);
      if (nSel < 1) then nSel := 1;
      frmToolBar.lblFrameNo.Caption := 'Frame ' + itoa(nSel);
      frmToolBar.lblTime.Caption := 'Time ' + floattostrf(m_col / atoi(frmToolBar.m_strFPS.Text), ffFixed, 4,2) + 's';
      m_col := nSel;
      m_pAction^.m_nFrameNo := nSel;
      grdFrames.Repaint;
   end;
end;

procedure TfrmMain.realRender(nFrameNo : integer; DrawControlPoints : boolean; layers : TList);
var
   f,g,h : integer;
   pAction : TActionObjPtr;
   pPnt : TLabel2Ptr;
   rr,gg,bb : byte;
begin
   m_bLastRenderedControl := DrawControlPoints;

   for f := 0 to layers.Count-1 do
   begin
      TLayerObjPtr(layers.Items[f])^.Render(m_nXoffset,m_nYoffset, nFrameNo, DrawControlPoints and (f+1 = m_row));
      for g := 0 to TLayerObjPtr(Layers.Items[f])^.m_olActions.Count - 1 do
      begin
         pAction := TActionObjPtr(TLayerObjPtr(layers.Items[f])^.m_olActions.Items[g]);
         if (pAction^.m_nFrameNo = nFrameNo) then
         begin
            case pAction^.m_nType of
               A_JUMPTO: if (pAction^.m_nParams[3] < pAction^.m_nParams[2]) then
                  begin
                     frmToolBar.m_nCurrentFrame := pAction^.m_nParams[1];
                     pAction^.m_nParams[3] := pAction^.m_nParams[3]+1;
                  end;
//               A_LOADNEW:
               A_SHAKE: begin
                     m_xinc := 0;
                     m_yinc := 0;
                     m_xincmax := 0;
                     m_yincmax := 0;
                     if (pAction^.m_nParams[2] = 1) then
                     begin
                        m_xincmax := pAction^.m_nParams[1];
                     end;
                     if (pAction^.m_nParams[3] = 1) then
                     begin
                        m_yincmax := pAction^.m_nParams[1];
                     end;
                  end;
               A_OLD: m_bOld := pAction^.m_nParams[1] = 1;
            end;
         end;
      end;
   end;

   if (m_bPlaying) then
   begin
      if (m_xincmax <> 0) then m_xinc := (-m_xincmax) + random(m_xincmax*2);
      if (m_yincmax <> 0) then m_yinc := (-m_yincmax) + random(m_yincmax*2);
      if (m_bOld) then
      begin
         g := random(8);
         if (g=1) then
         begin
            f := random(frmCanvas.ClientWidth);
            DrawLine2(f,0, f-5+random(10),frmCanvas.ClientHeight, clBlack, random(255), random(3));
         end;
         g := random(6);
         if (g=2) then
         begin
            //d/m_Canvas.Pen.Width := random(3);
            f := random(frmCanvas.ClientWidth);
            g := random(frmCanvas.ClientHeight);
            h := random(30);
            //d/m_Canvas.Arc(f,g,f+h,g+h,f,g,random(frmCanvas.ClientWidth),random(frmCanvas.ClientHeight));
         end;
         if (g=3) then
         for f := 0 to 10 do
         begin
            g := random(frmCanvas.ClientWidth);
            h := random(frmCanvas.ClientHeight);
            DrawEllipseOutline(g,h, random(10),random(10), clBlack, random(255), 1+random(3), 0);
         end;
      end;
   end else
   begin
      for f := 0 to frmCanvas.m_PntList.Count-1 do
      begin
         pPnt := frmCanvas.m_PntList.Items[f];
         bb := pPnt^.Color shr 16;
         gg := pPnt^.Color shr 8;
         rr := pPnt^.Color;

         DrawRect(m_nXoffset + pPnt^.Left+3, m_nYoffset + pPnt^.Top+3,
                         6,6, 0,0,0,rr,gg,bb, 255, 1, 0);
         if (pPnt^.m_bLocked) then
         begin
            DrawEllipseOutline(m_nXoffset + pPnt^.Left+3, m_nYoffset + pPnt^.Top+3,
                        10,10,
                         clBlack, 255,1,0);
         end;
      end;
   end;
end;

procedure TfrmMain.Render(nFrameNo : integer; DrawControlPoints : boolean);
var
   f,g,h : integer;
   pAction : TActionObjPtr;
   pPnt : TLabel2Ptr;
   r,gg,b : byte;
   pScreen : TGPGraphics;
begin
   if m_Bitmap = nil then exit;

   m_nLastRendered := nFrameNo;
   m_bLastRenderedControl := DrawControlPoints;

   r := m_bgColor shr 16;
   gg := m_bgColor shr 8;
   b := m_bgColor;

   m_Canvas.Clear(MakeColor(b,gg,r));

   if (m_olSelectedLayers <> nil) then
      if (m_olSelectedLayers.Count <> 0) then
      begin
         m_alphaMultiplier := 0.5;
         if (not m_bPlaying) and (nFrameNo > 0) then
            realRender(nFrameNo-1, false, m_olSelectedLayers);
      end;

   m_alphaMultiplier := 1;
   realRender(nFrameNo, DrawControlPoints, m_olLayers);

   DrawRectOutline(m_nXoffset + (m_nMovieWidth div 2) -1, m_nYoffset + (m_nMovieHeight div 2) -1,
                   m_nMovieWidth +1, m_nMovieHeight +1,
                   clBlack, 255, 1, 0);

   pScreen := TGPGraphics.Create(frmCanvas.canvas.handle);
   pScreen.DrawImage(m_Bitmap, m_xinc,m_yinc, frmCanvas.clientwidth, frmCanvas.clientheight);
   pScreen.Free;

end;

procedure TfrmMain.RenderLayers(olLayers : TList; nFrameNo : integer; DrawControlPoints : boolean);
var
   f,g,h : integer;
   pAction : TActionObjPtr;
   pPnt : TLabel2Ptr;
   r,gg,b : byte;
   pScreen : TGPGraphics;
begin

exit;

   if m_Bitmap = nil then exit;

   m_nLastRendered := nFrameNo;
   m_bLastRenderedControl := false;

   r := m_bgColor shr 16;
   gg := m_bgColor shr 8;
   b := m_bgColor;

   m_Canvas.Clear(MakeColor(b,gg,r));

   m_alphaMultiplier := 1;

   for f := 0 to olLayers.Count-1 do
   begin
      TLayerObj(olLayers.Items[f]).Render(m_nXoffset,m_nYoffset, nFrameNo, DrawControlPoints);
   end;

   DrawRectOutline(m_nXoffset + (m_nMovieWidth div 2) -1, m_nYoffset + (m_nMovieHeight div 2) -1,
                   m_nMovieWidth +1, m_nMovieHeight +1,
                   clBlack, 255, 1, 0);

   pScreen := TGPGraphics.Create(frmCanvas.canvas.handle);
   pScreen.DrawImage(m_Bitmap, m_xinc,m_yinc, frmCanvas.clientwidth, frmCanvas.clientheight);
   pScreen.Free;

end;

procedure TfrmMain.grdFramesKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
   pLayer : TLayerObjPtr;
   pFrame : TSingleFramePtr;
   pTweenFrame : TIFramePtr;
   pTweenFrame2 : TIFramePtr;
   f,h : integer;
   strTemp : string;
   frmTextProps : TfrmTextProps;
   //
   strFontName : string;
   strCaption : string;
   fontStyle : TFontStyles;
   brushStyle : TBrushStyle;
   inCol, outCol : TColor;
   //
   b : boolean;

   v1,v2,v3,v4 : integer;

begin
    if (m_row > 0) and (m_col > 0) then
    begin
    
      if (Key = VK_F5) then
      begin
          pLayer := m_olLayers.Items[m_row-1];

          if (pLayer^.m_nType = O_SUBTITLE) or (pLayer^.m_nType = O_TEXT) then
          begin
                  frmTextProps := TfrmTextProps.Create(self);
                  frmTextProps.m_InnerColour := clBlack;
                  frmTextProps.lblFontColour.Color := clBlack;
                  frmTextProps.m_OuterColour := clWhite;
                  frmTextProps.lblColour.Color := clWhite;
                  frmTextProps.m_styleOuter := bsClear;
                  frmTextProps.ShowModal;
                  if (frmTextProps.m_bOk) then
                  begin
                     strFontName := frmTextProps.m_strFontName;
                     strCaption := frmTextProps.m_strCaption.Text;
                     fontStyle := frmTextProps.m_FontStyle;
                     inCol := frmTextProps.lblFontColour.Color;
                     outCol := frmTextProps.lblColour.Color;
                     brushStyle := frmTextProps.m_styleOuter;
                  end else
                  begin
                     frmTextProps.Destroy;
                     if (Sender = nil) then
                     begin
                        m_olLayers.Remove(pLayer);
                        pLayer^.Destroy;
                        dispose(pLayer);
                        grdFrames.RowCount := grdFrames.RowCount - 1;
                     end;
                     exit;
                  end;
                  frmTextProps.Destroy;
          end;
          if (pLayer^.m_nType = O_EDITVIDEO) then
          begin
            od.Filter := 'AVI Files (*.AVI)|*.avi';
            if (od.Execute) then
            begin
               strTemp := od.FileName; 
            end else
            begin
               exit;
            end;
          end;

          /// insert new undo code here
          Undo1.Enabled := FALSE;
          //

          New(pFrame);
          pFrame^ := TSingleFrame.Create;
          pFrame^.m_Type := 6;
          New(pTweenFrame);
          pTweenFrame^ := TIFrame.Create;
          pFrame^.m_Frames.Add(pTweenFrame);
          New(pTweenFrame2);
          pTweenFrame2^ := TIFrame.Create;
          pFrame^.m_Frames.Add(pTweenFrame2);
          TIFramePtr(pFrame^.m_Frames.First)^.m_FrameNo := m_col;
          TIFramePtr(pFrame^.m_Frames.Last)^.m_FrameNo := m_col+4;
          if (sender is TfrmToolBar) then
          begin
             TIFramePtr(pFrame^.m_Frames.Last)^.m_FrameNo := m_col+47;
          end;
          TIFramePtr(pFrame^.m_Frames.First)^.m_nType := pLayer^.m_nType;
          TIFramePtr(pFrame^.m_Frames.Last)^.m_nType := pLayer^.m_nType;
          pLayer^.m_olFrames.Add(pFrame);
          if (pLayer^.m_nType = O_EDITVIDEO) then
          begin
             new(TEditVideoObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TEditVideoObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TEditVideoObj.Create(frmCanvas);
             TEditVideoObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.m_strFileName := strTemp;
             new(TEditVideoObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TEditVideoObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TEditVideoObj.Create(frmCanvas);
          end;
          if (pLayer^.m_nType = O_STICKMAN) then
          begin
             new(TStickManPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TStickManPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TStickMan.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
             TStickManPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.Assign(TStickManPtr(pLayer^.m_pObject));
             new(TStickManPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TStickManPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TStickMan.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
             TStickManPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.Assign(TStickManPtr(pLayer^.m_pObject));
          end;
          if (pLayer^.m_nType = O_T2STICK) then
          begin
             new(TLimbListPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TLimbListPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TLimbList.Create();
             TLimbListPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.CopyFrom(TLimbListPtr(pLayer^.m_pObject)^);
             //TLimbListPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.Canvas := frmMain.m_Canvas;
             new(TLimbListPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TLimbListPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TLimbList.Create();
             TLimbListPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.CopyFrom(TLimbListPtr(pLayer^.m_pObject)^);
             //TLimbListPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.Canvas := frmMain.m_Canvas;

             TLimbListPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.GetExtent(v1,v2,v3,v4);
             TLimbListPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.Move(-v1,-v2);
             TLimbListPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.GetExtent(v1,v2,v3,v4);
             TLimbListPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.Move(-v1,-v2);
          end;
          if (pLayer^.m_nType = O_STICKMANBMP) then
          begin
             new(TStickManBMPPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TStickManBMPPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TStickManBMP.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
             TStickManBMPPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.Assign(TStickManBMPPtr(pLayer^.m_pObject));
             new(TStickManBMPPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TStickManBMPPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TStickManBMP.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
             TStickManBMPPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.Assign(TStickManBMPPtr(pLayer^.m_pObject));
          end;
          if (pLayer^.m_nType = O_BITMAP) then
          begin
             new(TBitManPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TBitManPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TBitMan.Create(frmCanvas, '', TBitManPtr(pLayer^.m_pTempObject)^.Imarge.GetWidth, TBitManPtr(pLayer^.m_pTempObject)^.Imarge.GetHeight);
             new(TStickManPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TBitManPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TBitMan.Create(frmCanvas, '', TBitManPtr(pLayer^.m_pTempObject)^.Imarge.GetWidth, TBitManPtr(pLayer^.m_pTempObject)^.Imarge.GetHeight);
          end;
          if (pLayer^.m_nType = O_RECTANGLE) then
          begin
             new(TSquareObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TSquareObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TSquareObj.Create(frmCanvas);
             new(TSquareObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TSquareObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TSquareObj.Create(frmCanvas);
          end;
          if (pLayer^.m_nType = O_LINE) then
          begin
             new(TLineObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TLineObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TLineObj.Create(frmCanvas);
             new(TLineObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TLineObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TLineObj.Create(frmCanvas);
          end;
          if (pLayer^.m_nType = O_EXPLODE) then
          begin
             new(TExplodeObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TExplodeObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TExplodeObj.Create(frmCanvas, TRUE);
             new(TExplodeObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TExplodeObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TExplodeObj.Create(frmCanvas);
          end;
          if (pLayer^.m_nType = O_TEXT) then
          begin
             new(TTextObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TTextObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TTextObj.Create(frmCanvas, strTemp);
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.m_strFontName := strFontName;
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.m_strCaption := strCaption;
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.m_FontStyle := fontStyle;
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.m_InColour := inCol;
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.m_OutColour := outCol;
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.m_styleOuter := brushStyle;
             new(TTextObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TTextObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TTextObj.Create(frmCanvas, strTemp);
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.m_strFontName := strFontName;
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.m_strCaption := strCaption;
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.m_FontStyle := fontStyle;
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.m_InColour := inCol;
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.m_OutColour := outCol;
              TTextObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.m_styleOuter := brushStyle;
          end;
          if (pLayer^.m_nType = O_SUBTITLE) then
          begin
             new(TSubtitleObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TSubtitleObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TSubtitleObj.Create(strTemp);
             new(TSubtitleObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TSubtitleObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TSubtitleObj.Create(strTemp);
          end;
          if (pLayer^.m_nType = O_POLY) then
          begin
             new(TPolyObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TPolyObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TPolyObj.Create(frmCanvas, TPolyObjPtr(pLayer^.m_pObject)^.PntList.Count);
             new(TPolyObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TPolyObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TPolyObj.Create(frmCanvas, TPolyObjPtr(pLayer^.m_pObject)^.PntList.Count);
          end;
          if (pLayer^.m_nType = O_OVAL) then
          begin
             new(TOvalObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
             TOvalObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TOvalObj.Create(frmCanvas);
             new(TOvalObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
             TOvalObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TOvalObj.Create(frmCanvas);
          end;
          if (pLayer^.m_nType = O_SOUND) then
          begin
             od.DefaultExt := 'wav';
             od.Filter := 'Wave files (*.wav)|*.WAV';
             if (od.Execute) then
             begin
                new(TSoundObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject));
                TSoundObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^ := TSoundObj.Create(frmCanvas, od.FileName);
                TSoundObjPtr(TIFramePtr(pFrame^.m_Frames.First)^.m_pObject)^.SetVisible(TRUE);
                new(TSoundObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject));
                TSoundObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^ := TSoundObj.Create(frmCanvas, od.FileName);
                TSoundObjPtr(TIFramePtr(pFrame^.m_Frames.Last)^.m_pObject)^.SetVisible(FALSE);
             end else exit;
          end;
          b := TRUE;
          m_bChanged := TRUE;
          grdFramesSelectCell(Sender, m_col, m_row, b);
      end;

      if (Key = VK_F6) or (Key = VK_F7) then
      begin
         if (m_row = 1) then exit;
         if (m_pFrame = nil) then
         begin
            MessageBox(Application.Handle, 'You first have to select a FrameSet before you can add a KeyFrame to it', 'Tis an error', MB_OK or MB_ICONERROR);
         end;
         if (m_pTweenFrame <> nil) then
         begin
            ShowMessage('You cannot add a keyframe on top of another');
         end else if (m_pFrame <> nil) then
         begin
            if (frmCanvas <> nil) then
            begin
               frmCanvas.m_PntList.Clear;
            end;
            for f := 0 to m_pFrame^.m_Frames.Count-1 do
            begin
               pTweenFrame := m_pFrame^.m_Frames.Items[f];
               if (pTweenFrame^.m_FrameNo > m_col) then
               begin
                  pLayer := m_olLayers.Items[m_row-1];
                  New(pTweenFrame2);
                  pTweenFrame2^ := TIFrame.Create;
                  pTweenFrame2^.m_FrameNo := m_col;
                  pTweenFrame2^.m_nType := pLayer^.m_nType;
                  if (pLayer^.m_nType = O_STICKMAN) then
                  begin
                     new(TStickManPtr(pTweenFrame2^.m_pObject));
                     TStickManPtr(pTweenFrame2^.m_pObject)^ := TStickMan.Create(frmCanvas,0,0,0,0,0,0,0,0,0);
                     TStickManPtr(pTweenFrame2^.m_pObject)^.Assign(TStickManPtr(pTweenFrame^.m_pObject));
                     for h := 1 to 10 do frmCanvas.m_PntList.Add(TStickManPtr(pTweenFrame2^.m_pObject)^.Pnt(h));
                  end;
                  if (pLayer^.m_nType = O_T2STICK) then
                  begin
                     new(TLimbListPtr(pTweenFrame2^.m_pObject));
                     TLimbListPtr(pTweenFrame2^.m_pObject)^ := TLimbList.Create();
                     TLimbListPtr(pTweenFrame2^.m_pObject)^.CopyFrom(TLimbListPtr(pTweenFrame^.m_pObject)^);
                     TLimbListPtr(pTweenFrame2^.m_pObject)^.ShowJoints := true;
                     //for h := 1 to 10 do frmCanvas.m_PntList.Add(TStickManPtr(pTweenFrame2^.m_pObject)^.Pnt(h));
                  end;
                  if (pLayer^.m_nType = O_SPECIALSTICK) then
                  begin
                     new(TSpecialStickManPtr(pTweenFrame2^.m_pObject));
                     TSpecialStickManPtr(pTweenFrame2^.m_pObject)^ := TSpecialStickMan.Create(frmCanvas,0,0,0,0,0,0,0,0,0);
                     TSpecialStickManPtr(pTweenFrame2^.m_pObject)^.Assign(TSpecialStickManPtr(pTweenFrame^.m_pObject));
                     for h := 1 to 14 do frmCanvas.m_PntList.Add(TSpecialStickManPtr(pTweenFrame2^.m_pObject)^.Pnt(h));
                  end;
                  if (pLayer^.m_nType = O_STICKMANBMP) then
                  begin
                     new(TStickManBMPPtr(pTweenFrame2^.m_pObject));
                     TStickManBMPPtr(pTweenFrame2^.m_pObject)^ := TStickManBMP.Create(frmCanvas,0,0,0,0,0,0,0,0,0);
                     TStickManBMPPtr(pTweenFrame2^.m_pObject)^.Assign(TStickManBMPPtr(pTweenFrame^.m_pObject));
                     for h := 1 to 10 do frmCanvas.m_PntList.Add(TStickManBMPPtr(pTweenFrame2^.m_pObject)^.Pnt(h));
                  end;
                  if (pLayer^.m_nType = O_BITMAP) then
                  begin
                     new(TBitManPtr(pTweenFrame2^.m_pObject));
                     TBitManPtr(pTweenFrame2^.m_pObject)^ := TBitMan.Create(frmCanvas, '', TBitManPtr(pLayer^.m_pTempObject)^.Imarge.GetWidth, TBitManPtr(pLayer^.m_pTempObject)^.Imarge.GetHeight);
                     for h := 1 to 4 do frmCanvas.m_PntList.Add(TBitManPtr(pTweenFrame2^.m_pObject)^.Pnt(h));
                  end;
                  if (pLayer^.m_nType = O_RECTANGLE) then
                  begin
                     new(TSquareObjPtr(pTweenFrame2^.m_pObject));
                     TSquareObjPtr(pTweenFrame2^.m_pObject)^ := TSquareObj.Create(frmCanvas);
                     for h := 1 to 4 do frmCanvas.m_PntList.Add(TSquareObjPtr(pTweenFrame2^.m_pObject)^.Pnt(h));
                  end;
                  if (pLayer^.m_nType = O_LINE) then
                  begin
                     new(TLineObjPtr(pTweenFrame2^.m_pObject));
                     TLineObjPtr(pTweenFrame2^.m_pObject)^ := TLineObj.Create(frmCanvas);
                     for h := 1 to 2 do frmCanvas.m_PntList.Add(TLineObjPtr(pTweenFrame2^.m_pObject)^.Pnt(h));
                  end;
                  if (pLayer^.m_nType = O_EXPLODE) then
                  begin
                     exit;
                  end;
                  if (pLayer^.m_nType = O_TEXT) then
                  begin
                      frmTextProps := TfrmTextProps.Create(self);
                      with TTextObjPtr(pTweenFrame^.m_pObject)^ do
                      begin
                         frmTextProps.m_InnerColour := m_InColour;
                         frmTextProps.m_OuterColour := m_OutColour;
                         frmTextProps.m_strFontName := m_strFontName;
                         frmTextProps.m_strCaption.Text := m_strCaption;
                         frmTextProps.lblColour.Color := m_OutColour;
                         frmTextProps.lblFontColour.Color := m_InColour;
                         frmTextProps.m_styleOuter := bsClear;
                      end;
                      frmTextProps.ShowModal;
                      if (frmTextProps.m_bOk) then
                      begin
                         strFontName := frmTextProps.m_strFontName;
                         strCaption := frmTextProps.m_strCaption.Text;
                         fontStyle := frmTextProps.m_FontStyle;
                         inCol := frmTextProps.lblFontColour.Color;
                         outCol := frmTextProps.lblColour.Color;
                         brushStyle := frmTextProps.m_styleOuter;
                         new(TTextObjPtr(pTweenFrame2^.m_pObject));
                         TTextObjPtr(pTweenFrame2^.m_pObject)^ := TTextObj.Create(frmCanvas, strCaption);
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.m_strFontName := strFontName;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.m_strCaption := strCaption;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.m_FontStyle := fontStyle;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.m_InColour := inCol;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.m_OutColour := outCol;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.m_styleOuter := brushStyle;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.pnt(1)^.Left := TTextObjPtr(pTweenFrame^.m_pObject)^.pnt(1)^.Left;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.pnt(1)^.Top := TTextObjPtr(pTweenFrame^.m_pObject)^.pnt(1)^.Top;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.pnt(2)^.Left := TTextObjPtr(pTweenFrame^.m_pObject)^.pnt(2)^.Left;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.pnt(2)^.Top := TTextObjPtr(pTweenFrame^.m_pObject)^.pnt(2)^.Top;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.pnt(3)^.Left := TTextObjPtr(pTweenFrame^.m_pObject)^.pnt(3)^.Left;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.pnt(3)^.Top := TTextObjPtr(pTweenFrame^.m_pObject)^.pnt(3)^.Top;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.pnt(4)^.Left := TTextObjPtr(pTweenFrame^.m_pObject)^.pnt(4)^.Left;
                         TTextObjPtr(pTweenFrame2^.m_pObject)^.pnt(4)^.Top := TTextObjPtr(pTweenFrame^.m_pObject)^.pnt(4)^.Top;
                      end else
                      begin
                         pTweenFrame2^.Destroy;
                         Dispose(pTweenFrame2);
                         pTweenFrame2 := nil;
                         exit;
                      end;
                      frmTextProps.Destroy;
                      frmTextProps := nil;
                      for h := 1 to 4 do frmCanvas.m_PntList.Add(TTextObjPtr(pTweenFrame2^.m_pObject)^.Pnt(h));
                  end;
                  {if (pLayer^.m_nType = O_SUBTITLE) then
                  begin
                     frmSubEdit := TfrmSubEdit.Create(self);
                     frmSubEdit.ShowModal;
                     if (frmSubEdit.m_bOk) then
                     begin
                        strTemp := frmSubEdit.memContent.Text;
                        new(TSubtitleObjPtr(pTweenFrame2^.m_pObject));
                        TSubtitleObjPtr(pTweenFrame2^.m_pObject)^ := TSubtitleObj.Create(strTemp);
                     end;
                     frmSubEdit.Destroy;
                     frmSubEdit := nil;
                  end; }
                  if (pLayer^.m_nType = O_POLY) then
                  begin
                     new(TPolyObjPtr(pTweenFrame2^.m_pObject));
                     TPolyObjPtr(pTweenFrame2^.m_pObject)^ := TPolyObj.Create(frmCanvas, TPolyObjPtr(pLayer^.m_pObject)^.PntList.Count);
                     for h := 1 to TPolyObjPtr(pTweenFrame2^.m_pObject)^.PntList.Count do frmCanvas.m_PntList.Add(TPolyObjPtr(pTweenFrame2^.m_pObject)^.Pnt(h));
                  end;
                  if (pLayer^.m_nType = O_OVAL) then
                  begin
                     new(TOvalObjPtr(pTweenFrame2^.m_pObject));
                     TOvalObjPtr(pTweenFrame2^.m_pObject)^ := TOvalObj.Create(frmCanvas);
                     for h := 1 to 4 do frmCanvas.m_PntList.Add(TOvalObjPtr(pTweenFrame2^.m_pObject)^.Pnt(h));
                  end;
                  if (pLayer^.m_nType = O_SOUND) then
                  begin
                     if (od.Execute) then
                     begin
                        new(TSoundObjPtr(pTweenFrame2^.m_pObject));
                        TSoundObjPtr(pTweenFrame2^.m_pObject)^ := TSoundObj.Create(frmCanvas, od.FileName);
                     end else exit;
                  end;
                  m_pFrame^.m_Frames.Insert(f, pTweenFrame2);
                  m_pTweenFrame := pTweenFrame2;
                  if (Key = VK_F6) then
                  begin
                     frmCanvas.Setposetopreviousframe1Click(self);
                  end;
          /// insert new undo code here
          Undo1.Enabled := FALSE;
          //
                  m_bChanged := TRUE;
                  b := true;
                  grdFramesSelectCell(self, m_Col, m_Row, b);

                  break;
               end;
            end;
         end;
      end;

   end else
   begin
      if (Key = VK_F5) then MessageBox(Application.Handle, 'You first have to add/select a layer before you can add a FrameSet to it', 'Tis an error', MB_OK or MB_ICONERROR);
      if (Key = VK_F6) or (Key = VK_F7) then MessageBox(Application.Handle, 'You first have to add/select a layer before you can add a KeyFrame to it', 'Tis an error', MB_OK or MB_ICONERROR);
   end;

   if (Key = ord('H')) then
   begin
      HideLayer1Click(sender);
   end;
   if (Key = ord('S')) then
   begin
      ShowLayer1Click(sender);
   end;
   if (Key = 38) then
   begin
      m_row := m_row+1;
      Movelayerup1Click(nil);
   end;
   if (Key = 40) then
   begin
      m_row := m_row-1;
      Movelayerdown1Click(nil);
   end;
   if (Key = ord('A')) then
   begin
      KeyFrameAction1Click(nil);
   end;

   grdFrames.Repaint;
   Render(m_col);
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
   grdFrames.Width := ClientWidth;
   lblSizeGrid.Left := 0;
   lblSizeGrid.Width := ClientWidth;
   lblSizeGrid.Height := 5;
end;

procedure TfrmMain.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TfrmMain.Layer1Click(Sender: TObject);
begin
   frmToolBar.imgNewLayerClick(Sender);
//   frmToolBar.imgNewLayerMouseUp(Sender,mbLeft,[ssLeft],0,0);
end;

procedure TfrmMain.New1Click(Sender: TObject);
var
   frmMovieSettings : TfrmMovieSettings;
begin
   ShowMessage('As this is an experimental build, it is recommended that you restart TISFAT if you have run a physics simulation, proceed with caution');

   frmMovieSettings := TfrmMovieSettings.Create(self);
   frmMovieSettings.ShowModal;
   if (frmMovieSettings.m_bOK) then
   begin
      NewMovie(atoi(frmMovieSettings.m_strWidth.Text), atoi(frmMovieSettings.m_strHeight.Text));
      m_bSaved := FALSE;
   end;
   frmMovieSettings.Destroy;
end;

procedure TfrmMain.lblSizeGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := TRUE;
   m_nX := x;
   m_nY := y;
end;

procedure TfrmMain.lblSizeGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   m_bMoving := FALSE;
end;

procedure TfrmMain.lblSizeGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   if (m_bMoving) then
   begin
      lblSizeGrid.Top := lblSizeGrid.Top + (Y - m_nY);
      grdFrames.Height := grdFrames.Height + (Y - m_nY);
   end;
end;

procedure TfrmMain.InsertKeyFrame1Click(Sender: TObject);
var
   keyy : word;
begin
   keyy := VK_F6;
   grdFrames.OnKeyUp(Sender, keyy, [ssLeft]);
end;

procedure TfrmMain.About1Click(Sender: TObject);
var
   frmAbout : TfrmAbout;
begin
   frmAbout := TfrmAbout.Create(self);
   //PlaySound();
   frmAbout.ShowModal;
   frmAbout.free;
end;

procedure TfrmMain.Keyframes1Click(Sender: TObject);
begin
   frmToolBar.imgAddTweenClick(Sender);
end;

procedure TfrmMain.FrameSet1Click(Sender: TObject);
begin
   frmToolBar.imgAddKeyFrameClick(Sender);
end;

procedure TfrmMain.RemoveKeyFrame1Click(Sender: TObject);
var
   b : boolean;
begin
   if (m_pFrame = nil) then
      exit;
   if (m_pFrame^ = nil) then
      exit;
      
   if (m_row > 0) and (m_pTweenFrame <> nil) then
   begin
      if (m_pFrame^.m_Frames.First = m_pTweenFrame) or (m_pFrame^.m_Frames.Last = m_pTweenFrame) then
      begin
         MessageBox(Application.Handle, 'You cannot remove the first, or last, KeyFrame in a FrameSet', 'Tis an Error', MB_OK or MB_ICONERROR);
         exit;
      end;
      if (MessageBox(Application.Handle, 'Are you sure?', 'Remove KeyFrame', MB_YESNO or MB_ICONQUESTION) = IDYES) then
      begin
          /// insert new undo code here
          Undo1.Enabled := FALSE;
          //
         m_pFrame^.m_Frames.Remove(m_pTweenFrame);
         m_pTweenFrame^.Free;
         Dispose(TIFramePtr(m_pTweenFrame));
         m_pTweenFrame := nil;
         m_bChanged := TRUE;
         //Render(m_col, FALSE);
         b := false;
         grdFramesSelectCell(self, m_col, 0, b);
         Render(m_col, false);
      end;
   end;
end;

procedure TfrmMain.KeyFrame1Click(Sender: TObject);
begin
   RemoveKeyFrame1Click(Sender);
end;

procedure TfrmMain.FrameSet2Click(Sender: TObject);
var
   pLayer : TLayerObjPtr;
begin
   if (m_row > 0) and (m_pFrame <> nil) then
   if (MessageBox(Application.Handle, 'Are you sure?', 'Remove FrameSet', MB_YESNO or MB_ICONQUESTION) = IDYES) then
   begin
          /// insert new undo code here
          Undo1.Enabled := FALSE;
          //
      pLayer := m_olLayers.Items[m_row-1];
      pLayer^.m_olFrames.Remove(m_pFrame);
      m_pFrame^.Free;
      Dispose(TSingleFramePtr(m_pFrame));
      grdFrames.Repaint;
      Render(m_col, FALSE);
   end;
end;

procedure TfrmMain.Layer2Click(Sender: TObject);
var
   pLayer : TLayerObjPtr;
begin
   if (m_row > 0) then
   if (MessageBox(Application.Handle, 'Are you sure?', 'Remove Layer', MB_YESNO or MB_ICONQUESTION) = IDYES) then
   begin
          /// insert new undo code here
          Undo1.Enabled := FALSE;
          //
      frmCanvas.m_PntList.Clear;
      pLayer := m_olLayers.Items[m_row-1];
      m_olLayers.Remove(pLayer);
      pLayer^.Free;
      Dispose(TLayerObjPtr(pLayer));
      grdFrames.RowCount := grdFrames.RowCount - 1;
      grdFrames.Repaint;
      Render(m_col, FALSE);
   end;
end;

procedure TfrmMain.Movelayerup1Click(Sender: TObject);
var
   pLayer : TLayerObjPtr;
begin
   if (m_row > 1) then
   begin
      frmCanvas.m_PntList.Clear;
      pLayer := m_olLayers.Items[m_row-1];
      m_olLayers.Items[m_row-1] := m_olLayers.Items[m_row-2];
      m_olLayers.Items[m_row-2] := pLayer;
      grdFrames.Repaint;
      Render(m_col);
      m_row := -1;
      m_bChanged := TRUE;
   end;
end;

procedure TfrmMain.MoveLayerDown1Click(Sender: TObject);
var
   pLayer : TLayerObjPtr;
begin
   if (m_row > 0) and (m_row < grdFrames.RowCount) then
   begin
      frmCanvas.m_PntList.Clear;
      pLayer := m_olLayers.Items[m_row-1];
      m_olLayers.Items[m_row-1] := m_olLayers.Items[m_row];
      m_olLayers.Items[m_row] := pLayer;
      grdFrames.Repaint;
      Render(m_col);
      m_row := -1;
      m_bChanged := TRUE;
   end;
end;

procedure TfrmMain.InserLayer10Click(Sender: TObject);
begin
   frmCanvas.m_PntList.Clear;
   frmToolBar.imgNewLayerClick(Sender);
{   pLayer := m_olLayers.Items[m_row-2];
   m_olLayers.Items[m_row-2] := m_olLayers.Items[m_row-1];
   m_olLayers.Items[m_row-1] := pLayer;
   grdFrames.Repaint;
   Render(m_col);    }
end;

procedure TfrmMain.RemoveLayer10Click(Sender: TObject);
begin
   Layer2Click(Sender);
end;

procedure TfrmMain.RemoveFrameSet2Click(Sender: TObject);
begin
   FrameSet2Click(Sender);
end;

procedure TfrmMain.InsertFrameSet1Click(Sender: TObject);
var
   k : word;
begin
   k := VK_F5;
   frmMain.grdFramesKeyUp(self, k, [ssLeft]);
end;

procedure TfrmMain.Close1Click(Sender: TObject);
var
   f : integer;
   pLayer : TLayerObjPtr;
   nResponse : integer;
begin
   m_bOld := FALSE;
   if (m_bChanged) then
   begin
      nResponse := MessageBox(Application.Handle, 'You have not saved your current movie, would you like to do so now?', 'Save Yourself.', MB_YESNOCANCEL or MB_ICONQUESTION);
      if (nResponse = IDYES) then
      begin
         Save1Click(nil);
      end;
      if (nResponse = IDCANCEL) then
      begin
         m_bCancelClose := TRUE;
         exit;
      end;
   end;
   Movie1.Enabled := FALSE;
   if (m_olLayers <> nil) then
   begin
     if (m_olLayers.Count > 0) then
     for f := 0 to m_olLayers.Count-1 do
     begin
        pLayer := m_olLayers.Items[f];
        pLayer^.Free;
        Dispose(pLayer);
     end;
     m_olLayers.Clear;
     m_olLayers.Free;
     m_olLayers := nil;
   end;
   m_Canvas.Free;
   m_Bitmap.Free;
   m_Canvas := nil;
   m_Bitmap := nil;
   grdFrames.RowCount := 1;
   grdFrames.Repaint;
   if (frmToolBar <> nil) then frmToolBar.Hide;
   grdFrames.Enabled := FALSE;
   lblSizeGrid.Enabled := FALSE;
   Insert1.Enabled := FALSE;
   Remove1.Enabled := FALSE;
   Close1.Enabled := FALSE;
   Save1.Enabled := FALSE;
   if (m_olSelectedLayers <> nil) then
   begin
      m_olSelectedLayers.Destroy;
      m_olSelectedLayers := nil;
   end;
   m_col := 1;
   m_row := 1;
   m_xinc := 0;
   m_yinc := 0;
   m_xincmax := 0;
   m_yincmax := 0;
   m_pCopyFrameSet := nil;
   m_pCopyLayer := nil;
end;

procedure TfrmMain.Help2Click(Sender: TObject);
var
   strPath : string;
begin
   strPath := extractfilepath(application.exename) + 'tisfat.chm';
   if (ShellExecute(Application.Handle, 'open', pChar(strPath), nil,nil, SW_SHOWNORMAL) < 32) then
   begin
      MessageBox(Application.Handle, pChar('Could not load help file (error code:' + itoa(GetLastError()) + ')'), 'Tis an error', MB_OK or MB_ICONERROR);
   end;
end;


procedure TfrmMain.SaveBitmapOld(b : TGPBitmap; fs : TFileStream);
var
   bitty : TBitmap;
   bittyHand : TGPGraphics;
   wide,high : integer;
begin
   wide := b.GetWidth;
   high := b.GetHeight;
   bitty := TBitmap.Create;
   bitty.Height := high;
   bitty.Width := wide;
//   bitty.SetSize(wide,high);

   bittyHand := TGPGraphics.Create(bitty.canvas.handle);
   bittyHand.DrawImage(b, 0,0, wide,high);
   bittyHand.Free;

   bitty.SaveToStream(fs);
   bitty.Free;
end;

procedure TfrmMain.LoadBitmapOld(var b : TGPBitmap; fs : TFileStream);
var
   bitty : TBitmap;
begin
   bitty := TBitmap.Create;
   bitty.LoadFromStream(fs);
   b.Free;
   b := TGPBitmap.Create(bitty.handle,bitty.palette);
   bitty.Free;
end;


procedure TfrmMain.SaveBitmap(b : TGPBitmap; fs : TFileStream);
var
  id: TGUID;
  ms : TMemoryStream;
  l : integer;
begin
  GetEncoderClsid('image/png', id);

  ms := TMemoryStream.Create;
  b.Save(TStreamAdapter.Create(ms), id);

  l := ms.Size;
  fs.Write(l, sizeof(l));

  ms.SaveToStream(fs);
  ms.Free;
end;

procedure TfrmMain.LoadBitmap(var b : TGPBitmap; fs : TFileStream; var ms : TMemoryStream);
var
   l : integer;
begin
   fs.Read(l, sizeof(l));
   ms.Free;
   ms := TMemoryStream.Create;
   ms.CopyFrom(fs, l);
   ms.Position := 0;
   b := TGPBitmap.Create(TFixedStreamAdapter.Create(ms{, soOwned = crash!}));
end;

procedure TfrmMain.Save(strFileName : string; autosave : boolean);
var
   f,g,h,i : integer;
   pLayer : TLayerObjPtr;
   pFrameSet : TSingleFramePtr;
   pFrame : TIFramePtr;
   pAction : TActionObjPtr;
   fs : TFileStream;
   bWritten : BOOLEAN;
   misc : integer;
   nFPS : byte;
   //
   bTrans : boolean;
   bMore : boolean;
   //
   bitty : TBitmap;
   bittyHand : TGPGraphics;
   wide,high : integer;
   x,y : integer;
begin
   if (not autosave) and FileExists(strFileName) and (not m_bSaved) then
   begin
      if MEssageBox(Application.Handle, pChar(strFileName + ' already exists, overwrite?'), pChar('Overwrite?'), MB_YESNOCANCEL or MB_ICONQUESTION) <> IDYES then
      begin
         exit;
      end;
   end;
   DeleteFile(strFileName);
   fs := TFileStream.Create(strFileName, fmCreate);

   nFPS := atoi(frmToolBar.m_strFPS.Text);
   f := ord('I');
   g := ord('H');
   h := ord('8');
   //
   i := ord('V'); //U,I, V
   // no more FPS here
   fs.Write(f, sizeof(integer));
   fs.Write(g, sizeof(integer));
   fs.Write(h, sizeof(integer));
   fs.Write(i, sizeof(integer));

   f := m_nMovieWidth;
   g := m_nMovieHeight;
   h := nFPS;
   fs.Write(f, sizeof(integer));
   fs.Write(g, sizeof(integer));
   //
   fs.Write(h, sizeof(integer));
   //
   fs.Write(m_bgColor, sizeof(m_bgColor));
   for f := 0 to m_olLayers.Count-1 do
   begin
      pLayer := m_olLayers.Items[f];

      i := length(pLayer^.m_strName)+1;
      fs.Write(i, sizeof(i));
      fs.Write(pLayer^.m_strName, i);

      fs.Write(pLayer^.m_nType, sizeof(pLayer^.m_nType));
      fs.Write(pLayer^.m_olFrames.Count, sizeof(pLayer^.m_olFrames.Count));

      fs.Write(pLayer^.m_olActions.Count, sizeof(pLayer^.m_olActions.Count));
      for g := 0 to pLayer^.m_olActions.Count-1 do
      begin
         pAction := pLayer^.m_olActions.Items[g];
         fs.Write(pAction^.m_nType, sizeof(pAction^.m_nType));
         fs.Write(pAction^.m_nFrameNo, sizeof(pAction^.m_nFrameNo));
         case pAction^.m_nType of
            A_JUMPTO,A_SHAKE: begin
                  fs.Write(pAction^.m_nParams[1], sizeof(pAction^.m_nParams[1]));
                  fs.Write(pAction^.m_nParams[2], sizeof(pAction^.m_nParams[2]));
                  fs.Write(pAction^.m_nParams[3], sizeof(pAction^.m_nParams[3]));
               end;
            A_LOADNEW: begin
                  misc := length(pAction^.m_strParam)+1;
                  fs.Write(misc, sizeof(misc));
                  fs.Write(pAction^.m_strParam, misc);
               end;
            A_OLD : fs.Write(pAction^.m_nParams[1], sizeof(pAction^.m_nParams[1]));
         end;
      end;

      bWritten := FALSE;
      for g := 0 to pLayer^.m_olFrames.Count-1 do
      begin
         pFrameSet := pLayer^.m_olFrames.Items[g];
         fs.Write(pFrameSet^.m_Frames.Count, sizeof(pFrameSet^.m_Frames.Count));
         for h := 0 to pFrameSet^.m_Frames.Count-1 do
         begin
            pFrame := pFrameSet^.m_Frames.Items[h];
            fs.Write(pFrame^.m_nOnion, sizeof(pFrame^.m_nOnion));
            fs.Write(pFrame^.m_FrameNo, sizeof(pFrame^.m_FrameNo));
            if (pLayer^.m_nType = O_EDITVIDEO) then
            with TEditVideoObjPtr(pFrame^.m_pObject)^ do
            begin
               i := length(TEditVideoObjPtr(pFrame^.m_pObject)^.m_strFileName)+1;
               fs.write(i, sizeof(i));
               fs.Write(TEditVideoObjPtr(pFrame^.m_pObject)^.m_strFileName, i);
               for i := 1 to 4 do
               begin
                  fs.Write(Pnt(i)^.Left, sizeof(Pnt(i)^.Left));
                  fs.Write(Pnt(i)^.Top, sizeof(Pnt(i)^.Top));
               end;
            end;
            if (pLayer^.m_nType = O_RECTANGLE) then
            with TSquareObjPtr(pFrame^.m_pObject)^ do
            begin
               for i := 1 to 4 do
               begin
                  fs.Write(Pnt(i)^.Left, sizeof(Pnt(i)^.Left));
                  fs.Write(Pnt(i)^.Top, sizeof(Pnt(i)^.Top));
               end;
               fs.Write(m_nLineWidth, sizeof(m_nLineWidth));
               fs.Write(m_InColour, sizeof(m_InColour));
               fs.Write(m_OutColour, sizeof(m_OutColour));
               //
               fs.Write(m_styleInner, sizeof(m_styleInner));
               fs.Write(m_styleOuter, sizeof(m_styleOuter));
               //
               fs.Write(m_angle, sizeof(m_angle));
               fs.Write(m_alpha, sizeof(m_alpha));
               fs.Write(m_aliased, sizeof(m_aliased));
            end;
            if (pLayer^.m_nType = O_LINE) then
            with TLineObjPtr(pFrame^.m_pObject)^ do
            begin
               for i := 1 to 2 do
               begin
                  fs.Write(Pnt(i)^.Left, sizeof(Pnt(i)^.Left));
                  fs.Write(Pnt(i)^.Top, sizeof(Pnt(i)^.Top));
               end;
               fs.Write(m_nLineWidth, sizeof(m_nLineWidth));
               fs.Write(m_Colour, sizeof(m_Colour));
               fs.Write(m_angle, sizeof(m_angle));
               fs.Write(m_alpha, sizeof(m_alpha));
               fs.Write(m_aliased, sizeof(m_aliased));
            end;
            if (pLayer^.m_nType = O_BITMAP) then
            with TBitmanPtr(pFrame^.m_pObject)^ do
            begin
               fs.Write(m_bLoadNew, sizeof(m_bLoadNew));    //used for: is TBitmap or TGPBitmap
               if not bWritten then
               begin
                  if (m_bLoadNew) then
                     SaveBitmap(TBitmanPtr(pLayer^.m_pTempObject)^.Imarge, fs)
                  else
                     SaveBitmapOld(TBitmanPtr(pLayer^.m_pTempObject)^.Imarge, fs);

                  bTrans := TRUE;
                  fs.Write(bTrans, sizeof(bTrans));
                  //
                  bWritten := TRUE;
               end;
               for i := 1 to 4 do
               begin
                  x := Pnt(i)^.Left;
                  y := Pnt(i)^.Top;
                  fs.Write(x, sizeof(x));
                  fs.Write(y, sizeof(y));
               end;
               fs.Write(m_angle, sizeof(m_angle));
               fs.Write(m_alpha, sizeof(m_alpha));
               fs.Write(m_aliased, sizeof(m_aliased));
            end;
            if (pLayer^.m_nType = O_OVAL) then
            with TOvalObjPtr(pFrame^.m_pObject)^ do
            begin
               for i := 1 to 4 do
               begin
                  fs.Write(Pnt(i)^.Left, sizeof(Pnt(i)^.Left));
                  fs.Write(Pnt(i)^.Top, sizeof(Pnt(i)^.Top));
               end;
               fs.Write(m_nLineWidth, sizeof(m_nLineWidth));
               fs.Write(m_InColour, sizeof(m_InColour));
               fs.Write(m_OutColour, sizeof(m_OutColour));
               //
               fs.Write(m_styleInner, sizeof(m_styleInner));
               fs.Write(m_styleOuter, sizeof(m_styleOuter));
               //
               fs.Write(m_angle, sizeof(m_angle));
               fs.Write(m_alpha, sizeof(m_alpha));
               fs.Write(m_aliased, sizeof(m_aliased));
            end;
            if (pLayer^.m_nType = O_EXPLODE) then
            with TExplodeObjPtr(pFrame^.m_pObject)^ do
            begin
               for i := 1 to 2 do
               begin
                  fs.Write(Pnt(i)^.Left, sizeof(Pnt(i)^.Left));
                  fs.Write(Pnt(i)^.Top, sizeof(Pnt(i)^.Top));
               end;
               fs.Write(m_nMidX, sizeof(m_nMidX));
               fs.Write(m_nMidY, sizeof(m_nMidY));
            end;
            if (pLayer^.m_nType = O_STICKMAN) then
            with TStickManPtr(pFrame^.m_pObject)^ do
            begin
               fs.Write(m_nHeadDiam, sizeof(m_nHeadDiam));
               for i := 1 to 10 do
               begin
                  fs.Write(Pnt(i)^.Left, sizeof(Pnt(i)^.Left));
                  fs.Write(Pnt(i)^.Top, sizeof(Pnt(i)^.Top));
               end;
               for i := 1 to 10 do
               begin
                  fs.Write(Wid[i], sizeof(Wid[i]));
               end;
               for i := 1 to 9 do
               begin
                  fs.Write(Lng[i], sizeof(Lng[i]));
               end;
               fs.Write(m_InColour, sizeof(m_InColour));
               fs.Write(m_OutColour, sizeof(m_OutColour));
               fs.Write(m_angle, sizeof(m_angle));
               fs.Write(m_alpha, sizeof(m_alpha));
               fs.Write(m_aliased, sizeof(m_aliased));
            end;
            if (pLayer^.m_nType = O_T2STICK) then
            begin
               if (not bWritten) then
               begin
                  TLimbListPtr(pFrame^.m_pObject)^.CopyBitmapsShallow(TLimbListPtr(pLayer^.m_pTempObject)^);
               end;

               with TLimbListPtr(pFrame^.m_pObject)^ do
               begin
                  Write(fs);
               end;

               if (not bWritten) then
               begin
                  TLimbListPtr(pFrame^.m_pObject)^.ClearBitmaps;
                  bWritten := TRUE;
               end;
            end;
            if (pLayer^.m_nType = O_SPECIALSTICK) then
            with TSpecialStickManPtr(pFrame^.m_pObject)^ do
            begin
               fs.Write(m_nDrawStyle, sizeof(m_nDrawStyle));
               fs.Write(m_nLineWidth, sizeof(m_nLineWidth));
               fs.Write(m_nHeadDiam, sizeof(m_nHeadDiam));
               fs.Write(m_styleInner, sizeof(m_styleInner));
               fs.Write(m_styleOuter, sizeof(m_styleOuter));
               for i := 1 to 14 do
               begin
                  fs.Write(Pnt(i)^.Left, sizeof(Pnt(i)^.Left));
                  fs.Write(Pnt(i)^.Top, sizeof(Pnt(i)^.Top));
               end;
               for i := 1 to 14 do
               begin
                  fs.Write(Wid[i], sizeof(Wid[i]));
               end;
               for i := 1 to 13 do
               begin
                  fs.Write(Lng[i], sizeof(Lng[i]));
               end;
               fs.Write(m_InColour, sizeof(m_InColour));
               fs.Write(m_OutColour, sizeof(m_OutColour));
               //
               bMore := FALSE;
               fs.Write(bMore, sizeof(bMore));
               //
               fs.Write(m_angle, sizeof(m_angle));
               fs.Write(m_alpha, sizeof(m_alpha));
               fs.Write(m_aliased, sizeof(m_aliased));
            end;

            if (pLayer^.m_nType = O_STICKMANBMP) then
            with TStickManBMPPtr(pFrame^.m_pObject)^ do
            begin
               if not bWritten then
               begin
                  //faceclosed
                  SaveBitmap(TStickManBMPPtr(pLayer^.m_pTempObject)^.m_FaceClosed, fs);
                  SaveBitmap(TStickManBMPPtr(pLayer^.m_pTempObject)^.m_FaceOpen, fs);
                  bWritten := TRUE;
               end;
               fs.Write(m_nHeadDiam, sizeof(m_nHeadDiam));
               for i := 1 to 10 do
               begin
                  fs.Write(Pnt(i)^.Left, sizeof(Pnt(i)^.Left));
                  fs.Write(Pnt(i)^.Top, sizeof(Pnt(i)^.Top));
               end;
               for i := 1 to 10 do
               begin
                  fs.Write(Wid[i], sizeof(Wid[i]));
               end;
               for i := 1 to 9 do
               begin
                  fs.Write(Lng[i], sizeof(Lng[i]));
               end;
               fs.Write(m_OutColour, sizeof(m_OutColour));
               fs.Write(m_bMouthOpen, sizeof(m_bMouthOpen));
               fs.Write(m_bFlipped, sizeof(m_bFlipped));
               fs.Write(m_angle, sizeof(m_angle));
               fs.Write(m_alpha, sizeof(m_alpha));
               fs.Write(m_aliased, sizeof(m_aliased));
            end;

            if (pLayer^.m_nType = O_POLY) then
            with TPolyObjPtr(pFrame^.m_pObject)^ do
            begin
               i := PntList.Count;
               fs.Write(i, sizeof(i));
               for i := 0 to PntList.Count-1 do
               begin
                  fs.Write(TLabel2Ptr(PntList.Items[i])^.Left, sizeof(TLabel2Ptr(PntList.Items[i])^.Left));
                  fs.Write(TLabel2Ptr(PntList.Items[i])^.Top, sizeof(TLabel2Ptr(PntList.Items[i])^.Top));
               end;
               fs.Write(m_nLineWidth, sizeof(m_nLineWidth));
               fs.Write(m_InColour, sizeof(m_InColour));
               fs.Write(m_OutColour, sizeof(m_OutColour));
               //
               fs.Write(m_styleInner, sizeof(m_styleInner));
               fs.Write(m_styleOuter, sizeof(m_styleOuter));
               //
               fs.Write(m_angle, sizeof(m_angle));
               fs.Write(m_alpha, sizeof(m_alpha));
               fs.Write(m_aliased, sizeof(m_aliased));
            end;
            if (pLayer^.m_nType = O_TEXT) then
            with TTextObjPtr(pFrame^.m_pObject)^ do
            begin
               for i := 1 to 4 do
               begin
                  fs.Write(Pnt(i)^.Left, sizeof(Pnt(i)^.Left));
                  fs.Write(Pnt(i)^.Top, sizeof(Pnt(i)^.Top));
               end;
               fs.Write(m_InColour, sizeof(m_InColour));
               fs.Write(m_OutColour, sizeof(m_OutColour));
               fs.Write(m_styleOuter, sizeof(m_styleOuter));
               fs.Write(m_FontStyle, sizeof(m_FontStyle));
               i := length(m_strFontName)+1;
               fs.Write(i, sizeof(i));
               fs.Write(m_strFontName, i);
               i := length(m_strCaption)+1;
               fs.Write(i, sizeof(i));
               fs.Write(m_strCaption, i);
               fs.Write(m_angle, sizeof(m_angle));
               fs.Write(m_alpha, sizeof(m_alpha));
               fs.Write(m_aliased, sizeof(m_aliased));
            end;
         end;
      end;
   end;
   fs.Free;
end;

procedure TfrmMain.Load(strFileName : string);
var
   f,g,h,i : integer;
   pLayer : TLayerObjPtr;
   pFrameSet : TSingleFramePtr;
   pFrame : TIFramePtr;
   nFrameSetCount, nFramesCount : integer;
   x, y : integer;
   nWide, nHigh : integer;
   nType : integer;
   strInfo, strLayerName : string[255];
   fs : TFileStream;
   bRead : boolean;
   nActionCount : integer;
   pAction : TActionObjPtr;
   misc : integer;
   bLoadNew : boolean;     //used for later version where can load many BMPs into 1 layer
   bTrans : boolean;
   bFirstLayer : BOOLEAN;
   bMore : boolean;
   nSkip : integer;
   bNewFormat : boolean;

   bitty : TBitmap;
   ms : TMemoryStream;
begin
   m_bChanged := FALSE;
   m_bOld := FALSE;

   fs := TFileStream.Create(strFileName, fmOpenRead);

   fs.Read(f, sizeof(integer));
   fs.Read(g, sizeof(integer));
   fs.Read(h, sizeof(integer));
   //
   fs.Read(i, sizeof(integer));
   //
   bFirstLayer := TRUE;
   bNewFormat := FALSE;
   if (f <> ord('I')) or (g <> ord('H')) or (h <> ord('8')) then
   begin
      m_strMovieFileName := '';
      m_bSaved := FALSE;
      fs.Free;
      MessageBox(Application.Handle, pChar(strFileName + ' does not appear to be a valid TISFAT file.'), 'Tis an error', MB_OK or MB_ICONERROR);
      exit;
   end;
      if (i = ord('U')) then
      begin
         bFirstLayer := FALSE;
      end else
      if (i = ord('I')) then
      begin
         bFirstLayer := TRUE;
      end else
      if (i = ord('V')) then
      begin
         bFirstLayer := TRUE;
         bNewFormat := true;
      end else
      begin
         m_strMovieFileName := '';
         m_bSaved := FALSE;
         fs.Free;
         MessageBox(Application.Handle, pChar(strFileName + ' does not appear to be a valid TISFAT file.'), 'Tis an error', MB_OK or MB_ICONERROR);
         exit;
      end;
   fs.Read(nWide, sizeof(integer));
   fs.Read(nHigh, sizeof(integer));
   NewMovie(nWide, nHigh);
   //
   fs.Read(m_nFPS, sizeof(integer));
   frmToolBar.m_strFPS.Text := itoa(m_nFPS);
   //
   fs.Read(m_bgColor, sizeof(m_bgColor));
   while fs.Position < fs.Size do
   begin
      if bFirstLayer then
      begin
         pLayer := m_olLayers.Items[0];
      end else
      begin
         grdFrames.RowCount := grdFrames.RowCount+1;
         New(pLayer);
         m_olLayers.Add(pLayer);
      end;
      strInfo := '';

      fs.Read(i, sizeof(i));
      fs.Read(strLayerName, i);

      fs.Read(nType, sizeof(integer));
      if (nType = O_POLY) then
      begin
         nType := O_NOTHING;
      end;
      if (nType = O_T2STICK) then
      begin
         strInfo := '';
      end;
      fs.Read(nFrameSetCount, sizeof(integer));
      if not bFirstLayer then
      begin
         pLayer^ := TLayerObj.Create(nType, strInfo);
      end;
      pLayer^.m_strName := strLayerName;
      bRead := fALSE;

      bFirstLayer := FALSE;
      fs.Read(nActionCount, sizeof(nActionCount));
      for g := 0 to nActionCount-1 do
      begin
         new(pAction);
         pAction^ := TActionObj.Create();
         fs.Read(pAction^.m_nType, sizeof(pAction^.m_nType));
         fs.Read(pAction^.m_nFrameNo, sizeof(pAction^.m_nFrameNo));
         case pAction^.m_nType of
            A_JUMPTO,A_SHAKE: begin
                  fs.Read(pAction^.m_nParams[1], sizeof(pAction^.m_nParams[1]));
                  fs.Read(pAction^.m_nParams[2], sizeof(pAction^.m_nParams[2]));
                  fs.Read(pAction^.m_nParams[3], sizeof(pAction^.m_nParams[3]));
               end;
            A_LOADNEW: begin
                  fs.Read(misc, sizeof(misc));
                  fs.Read(pAction^.m_strParam, misc);
               end;
            A_OLD : fs.Read(pAction^.m_nParams[1], sizeof(pAction^.m_nParams[1]));
         end;
         pLayer^.m_olActions.Add(pAction);
      end;

      for f := 0 to nFrameSetCount-1 do
      begin
         New(pFrameSet);
         pLayer^.m_olFrames.Add(pFrameSet);
         pFrameSet^ := TSingleFrame.Create();
         pFrameSet^.m_Type := 6;
         fs.Read(nFramesCount, sizeof(integer));
         for g := 0 to nFramesCount-1 do
         begin
            New(pFrame);
            pFrameSet^.m_Frames.Add(pFrame);
            pFrame^ := TIFrame.Create();
            pFrame^.m_nType := nType;
            if (nType = O_NOTHING) then pFrame^.m_nType := O_POLY;
            fs.Read(pFrame^.m_nOnion, sizeof(pFrame^.m_nOnion));
            fs.Read(pFrame^.m_FrameNo, sizeof(pFrame^.m_FrameNo));
            if (pLayer^.m_nType = O_EDITVIDEO) then
            begin
               New(TEditVideoObjPtr(pFrame^.m_pObject));
               TEditVideoObjPtr(pFrame^.m_pObject)^ := TEditVideoObj.Create(frmCanvas);
               with TEditVideoObjPtr(pFrame^.m_pObject)^ do
               begin
                  fs.Read(i, sizeof(i));
                  fs.Read(TEditVideoObjPtr(pFrame^.m_pObject)^.m_strFileName, i);
                  for i := 1 to 4 do
                  begin
                     fs.Read(x, sizeof(x));
                     fs.Read(y, sizeof(y));
                     Pnt(i)^.Left := x;
                     Pnt(i)^.Top := y;
                  end;
                  //
               end;
            end;
            if (pLayer^.m_nType = O_RECTANGLE) then
            begin
               New(TSquareObjPtr(pFrame^.m_pObject));
               TSquareObjPtr(pFrame^.m_pObject)^ := TSquareObj.Create(frmCanvas);
               with TSquareObjPtr(pFrame^.m_pObject)^ do
               begin
                  for i := 1 to 4 do
                  begin
                     fs.Read(x, sizeof(x));
                     fs.Read(y, sizeof(y));
                     Pnt(i)^.Left := x;
                     Pnt(i)^.Top := y;
                  end;
                  fs.Read(m_nLineWidth, sizeof(m_nLineWidth));
                  fs.Read(m_InColour, sizeof(m_InColour));
                  fs.Read(m_OutColour, sizeof(m_OutColour));
                  //
                  fs.Read(m_styleInner, sizeof(m_styleInner));
                  fs.Read(m_styleOuter, sizeof(m_styleOuter));
                  //
                  if (bNewFormat) then
                  begin
                     fs.Read(m_angle, sizeof(m_angle));
                     fs.Read(m_alpha, sizeof(m_alpha));
                     fs.Read(m_aliased, sizeof(m_aliased));
                  end;
               end;
            end;
            if (pLayer^.m_nType = O_LINE) then
            begin
               New(TLineObjPtr(pFrame^.m_pObject));
               TLineObjPtr(pFrame^.m_pObject)^ := TLineObj.Create(frmCanvas);
               with TLineObjPtr(pFrame^.m_pObject)^ do
               begin
                  for i := 1 to 2 do
                  begin
                     fs.Read(x, sizeof(x));
                     fs.Read(y, sizeof(y));
                     Pnt(i)^.Left := x;
                     Pnt(i)^.Top := y;
                  end;
                  fs.Read(m_nLineWidth, sizeof(m_nLineWidth));
                  fs.Read(m_Colour, sizeof(m_Colour));
                  if (bNewFormat) then
                  begin
                     fs.Read(m_angle, sizeof(m_angle));
                     fs.Read(m_alpha, sizeof(m_alpha));
                     fs.Read(m_aliased, sizeof(m_aliased));
                  end;
               end;
            end;
            if (pLayer^.m_nType = O_EXPLODE) then
            begin
               New(TExplodeObjPtr(pFrame^.m_pObject));
               TExplodeObjPtr(pFrame^.m_pObject)^ := TExplodeObj.Create(frmCanvas, g = 0);
               with TExplodeObjPtr(pFrame^.m_pObject)^ do
               begin
                  for i := 1 to 2 do
                  begin
                     fs.Read(x, sizeof(x));
                     fs.Read(y, sizeof(y));
                     Pnt(i)^.Left := x;
                     Pnt(i)^.Top := y;
                  end;
                  fs.Read(m_nMidX, sizeof(m_nMidX));
                  fs.Read(m_nMidY, sizeof(m_nMidY));
                  if (g = 0) then
                  begin
                     InitParts;
                  end;
               end;
            end;
            if (pLayer^.m_nType = O_BITMAP) then
            begin
               fs.Read(bLoadNew, sizeof(bLoadNew));   //unused for now
               if not bRead then
               begin
                  if (bLoadNew) then
                     LoadBitmap(TBitmanPtr(pLayer^.m_pTempObject)^.Imarge, fs, TBitmanPtr(pLayer^.m_pTempObject)^.ms)
                  else
                     LoadBitmapOld(TBitmanPtr(pLayer^.m_pTempObject)^.Imarge, fs);
                  //
                  fs.Read(bTrans, sizeof(bTrans));
                  //
                  bRead := TRUE;
               end;
               New(TBitmanPtr(pFrame^.m_pObject));
               TBitmanPtr(pFrame^.m_pObject)^ := TBitman.Create(frmCanvas, '', TBitManPtr(pLayer^.m_pTempObject)^.Imarge.GetWidth, TBitManPtr(pLayer^.m_pTempObject)^.Imarge.GetHeight);
               with TBitmanPtr(pFrame^.m_pObject)^ do
               begin
                  for i := 1 to 4 do
                  begin
                     fs.Read(x, sizeof(x));
                     fs.Read(y, sizeof(y));
                     TBitmanPtr(pFrame^.m_pObject)^.Pnt(i)^.Left := x;
                     TBitmanPtr(pFrame^.m_pObject)^.Pnt(i)^.Top := y;
                  end;
                  if (bNewFormat) then
                  begin
                     fs.Read(m_angle, sizeof(m_angle));
                     fs.Read(m_alpha, sizeof(m_alpha));
                     fs.Read(m_aliased, sizeof(m_aliased));
                  end;
               end;
            end;

            if (pLayer^.m_nType = O_STICKMANBMP) then
            begin
               New(TStickManBMPPtr(pFrame^.m_pObject));
               TStickManBMPPtr(pFrame^.m_pObject)^ := TStickManBMP.Create(frmCanvas, 0,0,0,0,0,0,0,0,0);
               if not bRead then
               begin
                  LoadBitmap(TStickManBMPPtr(pLayer^.m_pTempObject)^.m_FaceClosed, fs, TStickManBMPPtr(pLayer^.m_pTempObject)^.ms);
                  LoadBitmap(TStickManBMPPtr(pLayer^.m_pTempObject)^.m_FaceOpen, fs, TStickManBMPPtr(pLayer^.m_pTempObject)^.ms);
                  bRead := TRUE;
               end;
               with TStickManBMPPtr(pFrame^.m_pObject)^ do
               begin
                  fs.Read(m_nHeadDiam, sizeof(m_nHeadDiam));
                  for i := 1 to 10 do
                  begin
                     fs.Read(x, sizeof(x));
                     fs.Read(y, sizeof(y));
                     Pnt(i)^.Left := x;
                     Pnt(i)^.Top := y;
                  end;
                  for i := 1 to 10 do
                  begin
                     fs.Read(Wid[i], sizeof(Wid[i]));
                  end;
                  for i := 1 to 9 do
                  begin
                     fs.Read(Lng[i], sizeof(Lng[i]));
                  end;
                  fs.Read(m_OutColour, sizeof(m_OutColour));
                  fs.Read(m_bMouthOpen, sizeof(m_bMouthOpen));
                  fs.Read(m_bFlipped, sizeof(m_bFlipped));
                  if (bNewFormat) then
                  begin
                     fs.Read(m_angle, sizeof(m_angle));
                     fs.Read(m_alpha, sizeof(m_alpha));
                     fs.Read(m_aliased, sizeof(m_aliased));
                  end;
               end;
            end;

            if (pLayer^.m_nType = O_TEXT) then
            begin
               New(TTextObjPtr(pFrame^.m_pObject));
               TTextObjPtr(pFrame^.m_pObject)^ := TTextObj.Create(frmCanvas);
               with TTextObjPtr(pFrame^.m_pObject)^ do
               begin
                  for i := 1 to 4 do
                  begin
                     fs.Read(x, sizeof(x));
                     fs.Read(y, sizeof(y));
                     Pnt(i)^.Left := x;
                     Pnt(i)^.Top := y;
                  end;
                  fs.Read(m_InColour, sizeof(m_InColour));
                  fs.Read(m_OutColour, sizeof(m_OutColour));
                  fs.Read(m_styleOuter, sizeof(m_styleOuter));
                  fs.Read(m_FontStyle, sizeof(m_FontStyle));
                  fs.Read(i, sizeof(i));
                  fs.Read(m_strFontName, i);
                  fs.Read(i, sizeof(i));
                  fs.Read(m_strCaption, i);
                  if (bNewFormat) then
                  begin
                     fs.Read(m_angle, sizeof(m_angle));
                     fs.Read(m_alpha, sizeof(m_alpha));
                     fs.Read(m_aliased, sizeof(m_aliased));
                  end;
               end;
            end;
            if (pLayer^.m_nType = O_OVAL) then
            begin
               New(TOvalObjPtr(pFrame^.m_pObject));
               TOvalObjPtr(pFrame^.m_pObject)^ := TOvalObj.Create(frmCanvas);
               with TOvalObjPtr(pFrame^.m_pObject)^ do
               begin
                  for i := 1 to 4 do
                  begin
                     fs.Read(x, sizeof(x));
                     fs.Read(y, sizeof(y));
                     Pnt(i)^.Left := x;
                     Pnt(i)^.Top := y;
                  end;
                  fs.Read(m_nLineWidth, sizeof(m_nLineWidth));
                  fs.Read(m_InColour, sizeof(m_InColour));
                  fs.Read(m_OutColour, sizeof(m_OutColour));
                  //
                  fs.Read(m_styleInner, sizeof(m_styleInner));
                  fs.Read(m_styleOuter, sizeof(m_styleOuter));
                  //
                  if (bNewFormat) then
                  begin
                     fs.Read(m_angle, sizeof(m_angle));
                     fs.Read(m_alpha, sizeof(m_alpha));
                     fs.Read(m_aliased, sizeof(m_aliased));
                  end;
               end;
            end;
            if (pLayer^.m_nType = O_STICKMAN) then
            begin
               New(TStickManPtr(pFrame^.m_pObject));
               TStickManPtr(pFrame^.m_pObject)^ := TStickMan.Create(frmCanvas, 0,0,0,0,0,0,0,0,0);
               with TStickManPtr(pFrame^.m_pObject)^ do
               begin
                  fs.Read(m_nHeadDiam, sizeof(m_nHeadDiam));
                  for i := 1 to 10 do
                  begin
                     fs.Read(x, sizeof(x));
                     fs.Read(y, sizeof(y));
                     Pnt(i)^.Left := x;
                     Pnt(i)^.Top := y;
                  end;
                  for i := 1 to 10 do
                  begin
                     fs.Read(Wid[i], sizeof(Wid[i]));
                  end;
                  for i := 1 to 9 do
                  begin
                     fs.Read(Lng[i], sizeof(Lng[i]));
                  end;
                  fs.Read(m_InColour, sizeof(m_InColour));
                  fs.Read(m_OutColour, sizeof(m_OutColour));
                  if (bNewFormat) then
                  begin
                     fs.Read(m_angle, sizeof(m_angle));
                     fs.Read(m_alpha, sizeof(m_alpha));
                     fs.Read(m_aliased, sizeof(m_aliased));
                  end;
               end;
            end;
            if (pLayer^.m_nType = O_T2STICK) then
            begin
               New(TLimbListPtr(pFrame^.m_pObject));
               TLimbListPtr(pFrame^.m_pObject)^ := TLimbList.Create();
               if (not bRead) then
               begin
                  TLimbListPtr(pLAyer^.m_pTempObject)^.Read(fs);
                  TLimbListPtr(pFrame^.m_pObject)^.CopyFrom(TLimbListPtr(pLayer^.m_pTempObject)^);
                  bRead := TRUE;
               end else
               begin
                  TLimbListPtr(pFrame^.m_pObject)^.Read(fs);
               end;
            end;
            if (pLayer^.m_nType = O_SPECIALSTICK) then
            begin
               New(TSpecialStickManPtr(pFrame^.m_pObject));
               TSpecialStickManPtr(pFrame^.m_pObject)^ := TSpecialStickMan.Create(frmCanvas, 0,0,0,0,0,0,0,0,0);
               with TSpecialStickManPtr(pFrame^.m_pObject)^ do
               begin
                  fs.REad(m_nDrawStyle, sizeof(m_nDrawStyle));
                           TSpecialStickManPtr(pLayer^.m_pObject)^.m_nDrawStyle := m_nDrawStyle;
                           TSpecialStickManPtr(pLayer^.m_pTempObject)^.m_nDrawStyle := m_nDrawStyle;
                  fs.REad(m_nLineWidth, sizeof(m_nLineWidth));
                  fs.Read(m_nHeadDiam, sizeof(m_nHeadDiam));
                  fs.Read(m_styleInner, sizeof(m_styleInner));
                  fs.Read(m_styleOuter, sizeof(m_styleOuter));
                  for i := 1 to 14 do
                  begin
                     fs.Read(x, sizeof(x));
                     fs.Read(y, sizeof(y));
                     Pnt(i)^.Left := x;
                     Pnt(i)^.Top := y;
                  end;
                  for i := 1 to 14 do
                  begin
                     fs.Read(Wid[i], sizeof(Wid[i]));
                  end;
                  for i := 1 to 13 do
                  begin
                     fs.Read(Lng[i], sizeof(Lng[i]));
                  end;
                  fs.Read(m_InColour, sizeof(m_InColour));
                  fs.Read(m_OutColour, sizeof(m_OutColour));
                  //
                  fs.Read(bMore, sizeof(bMore));
                  if (bMore) then
                  begin
                     fs.REad(nSkip, sizeof(nSkip));
                     fs.Seek(nSkip, soFromCurrent)
                  end;
                  //
                  if (bNewFormat) then
                  begin
                     fs.Read(m_angle, sizeof(m_angle));
                     fs.Read(m_alpha, sizeof(m_alpha));
                     fs.Read(m_aliased, sizeof(m_aliased));
                  end;
               end;
            end;
            if (pLayer^.m_nType = O_NOTHING) or (pLayer^.m_nType = O_POLY) then        ///POLY HACK!
            begin
               pLayer^.m_nType := O_POLY;
               New(TPolyObjPtr(pFrame^.m_pObject));
               fs.Read(i, sizeof(i));
               TPolyObjPtr(pFrame^.m_pObject)^ := TPolyObj.Create(frmCanvas, i);
               if (pLayer^.m_pObject = nil) then
               begin
                  new(TPolyObjPtr(pLayer^.m_pObject));
                  new(TPolyObjPtr(pLayer^.m_pTempObject));
                  TPolyObjPtr(pLayer^.m_pObject)^ := TPolyObj.Create(frmCanvas, i);
                  TPolyObjPtr(pLayer^.m_pTempObject)^ := TPolyObj.Create(frmCanvas, i);
               end;
               with TPolyObjPtr(pFrame^.m_pObject)^ do
               begin
                  for h := 0 to i-1 do
                  begin
                     fs.Read(x, sizeof(TLabel2Ptr(PntList.Items[h])^.Left));
                     fs.Read(y, sizeof(TLabel2Ptr(PntList.Items[h])^.Top));
                     TLabel2Ptr(PntList.Items[h])^.Left := x;
                     TLabel2Ptr(PntList.Items[h])^.Top := y;
                  end;
                  fs.Read(m_nLineWidth, sizeof(m_nLineWidth));
                  fs.Read(m_InColour, sizeof(m_InColour));
                  fs.Read(m_OutColour, sizeof(m_OutColour));
                  //
                  fs.Read(m_styleInner, sizeof(m_styleInner));
                  fs.Read(m_styleOuter, sizeof(m_styleOuter));
                  //
                  if (bNewFormat) then
                  begin
                     fs.Read(m_angle, sizeof(m_angle));
                     fs.Read(m_alpha, sizeof(m_alpha));
                     fs.Read(m_aliased, sizeof(m_aliased));
                  end;
                end;
            end;
         end;
      end;
   end;
   fs.Free;
   Render(1, TRUE);
end;

procedure TfrmMain.Save1Click(Sender: TObject);
begin
   if (not m_bSaved) then
   begin
     sd.DefaultExt := '.sif';
     sd.Filter := 'TISFAT Files (*.sif)|*.sif';
     LoadSettings(m_strTHEPATH+'tis.fat', m_Settings);
     sd.InitialDir := m_Settings.SaveFilePath;
     if (sd.Execute) then
     begin
        m_strMovieFileName := sd.FileName;
     end else
     begin
       exit;
     end;
     m_Settings.SaveFilePath := extractfilepath(sd.FileName);
     SaveSettings(m_strTHEPATH+'tis.fat', m_Settings);
   end;
   Caption := 'This Is Stick Figure Animation Theatre (' + m_strMovieFileName + ')';
   Save(m_strMovieFileName);
   m_bSaved := TRUE;
   m_bChanged := FALSE;
end;

procedure TfrmMain.Open1Click(Sender: TObject);
var
   whatever : boolean;
begin
   od.DefaultExt := '.sif';
   od.Filter := 'TISFAT Files (*.sif)|*.sif';
   LoadSettings(m_strTHEPATH+'tis.fat', m_Settings);
   od.InitialDir := m_Settings.OpenFilePath;
   if (od.Execute) then
   begin
      if (not FileExists(od.FileName)) then
      begin
        ShowMessage(od.FileName + ' does not exist');
        exit;
      end;
      Close1Click(nil);
      Load(od.FileName);
      m_bSaved := TRUE;
      m_strMovieFileName := od.FileName;
      Caption := 'This Is Stick Figure Animation Theatre (' + m_strMovieFileName + ')';
      grdFramesSelectCell(nil, 1,1, whatever);
   end;
   m_Settings.OpenFilePath := extractfilepath(od.FileName);
   SaveSettings(m_strTHEPATH+'tis.fat', m_Settings);
end;

procedure TfrmMain.NewMovie(nWidth, nHeight : integer);
var
   pLayer : TLayerObjPtr;
begin
   m_nLastRendered := 0;
   m_bLastRenderedControl := false;
   m_nXoffset := 0;
   m_nYoffset := 0;
      m_bMovieReady := false;
      Close1Click(nil);
   m_Bitmap := TGPBitmap.Create(nWidth, nHeight);
   m_Canvas := TGPGraphics.Create(m_Bitmap);
   m_Canvas.SetSmoothingMode(SmoothingModeAntiAlias);
      
      Movie1.Enabled := TRUE;
      m_bActionMoving := FALSE;
      m_col := 1;
      m_row := 1;
      m_nMovieWidth := nWidth;
      m_nMovieHeight := nHeight;
      grdFrames.Width := Width - grdFrames.Left - 10;
      grdFrames.ColWidths[0] := imgTitle.Width;
      grdFrames.DefaultRowHeight := imgTitle.Height;
      grdFrames.DoubleBuffered := TRUE;
      grdFrames.RowCount := 2;
      grdFrames.Height := grdFrames.DefaultRowHeight * 8;
      lblSizeGrid.Top := grdFrames.Top + grdFrames.Height + 2;
      m_bPlaying := FALSE;
      m_olLayers := TList.Create;
      new(pLayer);
      pLayer^ := TLayerObj.Create(O_EDITVIDEO, '');
      pLayer^.m_strName := 'Untitled';
      m_olLayers.Add(pLayer);
      frmCanvas.Free;
      frmCanvas := TfrmCanvas.Create(Self);
      frmCanvas.ClientWidth := nWidth;
      frmCanvas.ClientHeight := nHeight;
      if (frmCanvas.Aviplaya <> nil) then
         frmCanvas.aviPlaya.Left := frmCanvas.ClientWidth + 100;
      m_bOld := FALSE;
      m_bReady := FALSE;
      m_bQuit := FALSE;
      m_bAdjusting := FALSE;
      m_bScrolling := FALSE;
      m_pFrame := nil;
      m_pTweenFrame := nil;
      m_bgColor := clWhite;
      //d/m_Canvas.FillRect(Rect(0,0,nWidth,nHeight));
      frmCanvas.Show;
      if (frmToolBar <> nil) then frmToolBar.Show;
      grdFrames.Enabled := TRUE;
      lblSizeGrid.Enabled := TRUE;
      Insert1.Enabled := TRUE;
      Remove1.Enabled := TRUE;
      Save1.Enabled := TRUE;
      Close1.Enabled := TRUE;
      grdFrames.Row := 0;
      grdFrames.Col := 1;
      m_nFPS := 12;
      m_lastCol := 1;
      m_xinc := 0;
      m_yinc := 0;
      m_xincmax := 0;
      m_yincmax := 0;
      m_bChanged := FALSE;
      m_nLast := -1;
      m_bSaved := FALSE;
      if (m_olSelectedLayers = nil) then
      begin
         m_olSelectedLayers := TList.Create;
      end else
      begin
         m_olSelectedLayers.Clear;
      end;
      m_bMovieReady := true;
end;

function TfrmMain.FormHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;
begin
   Help2Click(self);
   FormHelp := true;
end;

procedure TfrmMain.SetPosetoPreviousKeyFrame1Click(Sender: TObject);
var
   b : boolean;
begin
   b := FALSE;
   grdFramesSelectCell(Sender, m_col, m_row, b);
   frmCanvas.Setposetopreviousframe1Click(Sender);
   m_bChanged := TRUE;
end;

procedure TfrmMain.SetPosetoNextKeyFrame1Click(Sender: TObject);
var
   b : boolean;
begin
   b := FALSE;
   grdFramesSelectCell(Sender, m_col, m_row, b);
   frmCanvas.Setposetonextkeyframe1Click(Sender);
   m_bChanged := TRUE;
end;

procedure TfrmMain.KeyFrameAction1Click(Sender: TObject);
var
   frmAction : TfrmAction;
   f, g : integer;
   pLayer : TLayerObjPtr;
   pAction : TActionObjPtr;
   pTemp : TActionObjPtr;
begin
   if (m_row < 1) then exit;
   frmAction := TfrmAction.Create(self);

   frmAction.m_nEnd := 1;
   for f := 0 to m_olLayers.Count-1 do
   begin
      pLayer := m_olLayers.Items[f];
      for g := 0 to pLayer^.m_olFrames.Count-1 do
      begin
         if TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo > frmAction.m_nEnd then
         begin
            frmAction.m_nEnd := TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo;
         end;
      end;
   end;

   pAction := nil;
   pLayer := m_olLayers.Items[m_row-1];
   for f := 0 to pLayer^.m_olActions.Count-1 do
   begin
      pTemp := pLayer^.m_olActions.Items[f];
      if (pTemp^.m_nFrameNo = m_col) then
      begin
         pAction := pTemp;
         break;
      end;
   end;

   if (pAction <> nil) then
   begin
      frmAction.rg.ItemIndex := pAction^.m_nType;
      frmAction.rgClick(self);
      case pAction^.m_nType of
         A_JUMPTO: begin
               frmAction.strInfo.Text := itoa(pAction^.m_nParams[1]);
               frmAction.strInfo2.Text := itoa(pAction^.m_nParams[2]);
            end;
         A_LOADNEW: begin
               frmAction.strInfo.Text := pAction^.m_strParam;
            end;
         A_SHAKE: begin
               frmAction.chk1.Checked := pAction^.m_nParams[2] = 1;
               frmAction.chk2.Checked := pAction^.m_nParams[3] = 1;
               frmAction.strInfo.Text := itoa(pAction^.m_nParams[1]);
            end;
         A_OLD: begin
               frmAction.chk1.Checked := pAction^.m_nParams[1] = 1;
            end;
      end;
      frmAction.ShowModal;
      if (frmAction.m_bOK) then
      begin
         m_bChanged := TRUE;
         if (frmAction.m_bNothing) then
         begin
            pLayer^.m_olActions.Remove(pAction);
            pAction^.Destroy;
            Dispose(pAction);
         end else
         begin
            pAction^.m_nType := frmAction.rg.ItemIndex;
            case (pAction^.m_nType) of
               A_JUMPTO: begin pAction^.m_nParams[1] := atoi(frmAction.strInfo.Text); pAction^.m_nParams[2] := atoi(frmAction.strInfo2.Text); end;
               A_LOADNEW: pAction^.m_strParam := frmAction.strInfo.Text;
               A_OLD: if frmAction.chk1.Checked then pAction^.m_nParams[1] := 1 else pAction^.m_nParams[1] := 0;
               A_SHAKE: begin
                     pAction^.m_nParams[1] := atoi(frmAction.strInfo.Text);
                     pAction^.m_nParams[2] := 0;
                     pAction^.m_nParams[3] := 0;
                     if frmAction.chk1.Checked then pAction^.m_nParams[2] := 1;
                     if frmAction.chk2.Checked then pAction^.m_nParams[3] := 1;
                  end;
            end;
         end;
      end;
   end else
   begin
      frmAction.rgClick(self);
      frmAction.ShowModal;
      if (frmAction.m_bOK) then
      begin
         if not frmAction.m_bNothing then
         begin
            m_bChanged := TRUE;
            new(pAction);
            pLayer := m_olLayers.Items[m_row-1];
            pAction^ := TActionObj.Create;
            pLayer.m_olActions.Add(pAction);
            pAction^.m_nFrameNo := m_col;
            pAction^.m_nType := frmAction.rg.ItemIndex;
            case (pAction^.m_nType) of
               A_JUMPTO: begin pAction^.m_nParams[1] := atoi(frmAction.strInfo.Text); pAction^.m_nParams[2] := atoi(frmAction.strInfo2.Text); end;
               A_LOADNEW: pAction^.m_strParam := frmAction.strInfo.Text;
               A_OLD: if frmAction.chk1.Checked then pAction^.m_nParams[1] := 1 else pAction^.m_nParams[1] := 0;
               A_SHAKE: begin
                     pAction^.m_nParams[1] := atoi(frmAction.strInfo.Text);
                     pAction^.m_nParams[2] := 0;
                     pAction^.m_nParams[3] := 0;
                     if frmAction.chk1.Checked then pAction^.m_nParams[2] := 1;
                     if frmAction.chk2.Checked then pAction^.m_nParams[3] := 1;
                  end;
            end;
         end;
      end;
   end;
   frmAction.Destroy;
   grdFrames.Repaint;
end;

procedure TfrmMain.HideLayer1Click(Sender: TObject);
var
   pLayer : TLayerObjPtr;
begin
   if (m_row > 0) then
   begin
      pLayer := m_olLayers.Items[m_row-1];
      pLayer^.m_bHidden := TRUE;
      grdFrames.Repaint;
      Render(m_col, TRUE);
   end;
end;

procedure TfrmMain.ShowLayer1Click(Sender: TObject);
var
   pLayer : TLayerObjPtr;
begin
   if (m_row > 0) then
   begin
      pLayer := m_olLayers.Items[m_row-1];
      pLayer^.m_bHidden := FALSE;
      grdFrames.Repaint;
      Render(m_col, TRUE);
   end;
end;

procedure TfrmMain.OnionSkinning1Click(Sender: TObject);
var
   frmOnion : TfrmOnion;
begin
   if (m_pTweenFrame <> nil) then
   begin
       frmOnion := TfrmOnion.Create(self);
       frmOnion.m_strFrames.Text := itoa(m_pTweenFrame^.m_nOnion);
       frmOnion.ShowModal;
       if (frmOnion.m_bOk) then
       begin
          m_pTweenFrame^.m_nOnion := atoi(frmOnion.m_strFrames.Text);
          m_bChanged := TRUE;
       end;
       frmOnion.Destroy;
   end;
end;

procedure TfrmMain.AVI1Click(Sender: TObject);
var
   f, g, h : integer;
   nEnd : integer;
   pLayer : TLayerObjPtr;
   strFileName : string;
   hDLL : LongWORD;
   AviStart : pfStart;
   AviStop : pfStop;
   AviAddFrame : pfAddFrame;
   AviIsOK : pfIsOK;
   AviCompress : pfCompress;
   dwError : DWORD;
   nCurrentWidth, nCurrentHeight : integer;
   bitty : HBITMAP;
   rr,gg,bb : byte;
begin

   nCurrentWidth := frmCanvas.ClientWidth;
   nCurrentHeight := frmCanvas.ClientHeight;

   hDLL := LoadLibrary('tisutils.dll');
   if (hDLL = 0) then
   begin
      dwError := GetLastError;
      MessageBox(Handle, pChar('Could not load TISUTILS.DLL (' + itoa(dwError) + ')'), 'Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   AviStart := GetProcAddress(hDLL, 'Start');
   AviStop := GetProcAddress(hDLL, 'Stop');
   AviAddFrame := GetProcAddress(hDLL, 'AddFrame');
   AviIsOK := GetProcAddress(hDLL, 'IsOK');
   AviCompress := GetProcAddress(hDLL, 'Compress');
   //if (AviStart = nil) or (AviStop = nil) or (AviAddFrame = nil) or (AviIsOK = nil) or (AviCompress = nil) then
   if (FALSE) then
   begin
      MessageBox(Handle, 'Could not find a neccessary AVI function', 'Error', MB_OK or MB_ICONERROR);
      FreeLibrary(hDLL);
      exit;
   end;

   sd.DefaultExt := 'avi';
   sd.Filter := 'AVI files (*.avi)|*.avi';

   LoadSettings(m_strTHEPATH+'tis.fat', m_Settings);
   sd.InitialDir := m_Settings.AviFilePath;

   if sd.Execute then
   begin
      strFileName := sd.FileName;
   end else
   begin
      FreeLibrary(hDLL);
      exit;
   end;

   m_Settings.AviFilePath := extractfilepath(sd.FileName);
   SaveSettings(m_strTHEPATH+'tis.fat', m_Settings);

   frmCanvas.ClientWidth := m_nMovieWidth;
   frmCanvas.ClientHeight := m_nMovieHeight;
   
   nEnd := 1;
   for f := 0 to frmMain.m_olLayers.Count-1 do
   begin
      pLayer := frmMain.m_olLayers.Items[f];
      for g := 0 to pLayer^.m_olFrames.Count-1 do
      begin
         if TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo > nEnd then
         begin
            nEnd := TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo;
         end;
      end;
      for h := 0 to pLayer^.m_olActions.Count-1 do
      begin
         if (TActionObjPtr(pLayer^.m_olActions.Items[h])^.m_nType = 0) then
         begin
            TActionObjPtr(pLayer^.m_olActions.Items[h])^.m_nParams[3] := 0;
         end;
      end;
   end;

   m_bPlaying := TRUE;
   AviStart(pChar(strFileName), frmCanvas.ClientWidth,frmCanvas.ClientHeight, atoi(frmToolBar.m_strFPS.Text));
   if (AviIsOK = 1) then
   begin
     frmToolBar.m_nCurrentFrame := 1;
     while frmToolBar.m_nCurrentFrame < nEnd do
     begin
        frmMain.Render(frmToolBar.m_nCurrentFrame);
        frmToolBar.m_nCurrentFrame := frmToolBar.m_nCurrentFrame + 1;
        rr := m_bgColor;
        gg := m_bgColor shr 8;
        bb := m_bgColor shr 16;
        m_Bitmap.GetHBITMAP(MakeColor(rr,gg,bb), bitty);
        AviAddFrame(bitty);
        DeleteObject(bitty);
        if (AviIsOK = 0) then
        begin
            ShowMessage('Error creating AVI file');
            break;
        end;
     end;
   end else
   begin
      ShowMessage('Could not export to AVI');
   end;
   m_bPlaying := FALSE;
   AviCompress;
   AviStop;
   frmMain.m_col := nEnd;
   frmMAin.grdFrames.Repaint;
   frmMain.Render(nEnd);
   frmMain.m_bPlaying := FALSE;

   FreeLibrary(hDLL);

   frmCanvas.ClientWidth := nCurrentWidth;
   frmCanvas.ClientHeight := nCurrentHeight;
end;

procedure TfrmMain.SaveAs1Click(Sender: TObject);
begin
   begin
     sd.DefaultExt := '.sif';
     sd.Filter := 'TISFAT Files (*.sif)|*.sif';
     LoadSettings(m_strTHEPATH+'tis.fat', m_Settings);
     sd.InitialDir := m_Settings.SaveFilePath;
     if (sd.Execute) then
     begin
        m_strMovieFileName := sd.FileName;
     end else
     begin
       exit;
     end;
     m_Settings.SaveFilePath := extractfilepath(sd.FileName);
     SaveSettings(m_strTHEPATH+'tis.fat', m_Settings);
   end;
   Caption := 'This Is Stick Figure Animation Theatre (' + m_strMovieFileName + ')';
   Save(m_strMovieFileName);
   m_bSaved := TRUE;
   m_bChanged := FALSE;
end;

procedure TfrmMain.Standalone1Click(Sender: TObject);
var
   filMovie : file of byte;
   filResult : file of byte;
   buffer : array[0..32000] of byte;
   nRead : integer;
   filestream : TFileStream;
begin
   frmExport.ShowModal;
   if (frmExport.m_bOK) then
   begin
      Save1Click(sender);
      assignfile(filResult, frmExport.m_strFileName.Text);
      rewrite(filResult);

      filestream := TFileStream.Create(extractfilepath(application.exename)+'tisplay.exe', fmOpenRead);
      if (filestream = nil) then
      begin
         ShowMessage('Couldn''t open TISPLAY.EXE, please make sure it''s in the same folder as TISFAT, and that it is not running');
         exit;
      end;
      while filestream.Position <> filestream.Size do
      begin
         nRead := filestream.Read(buffer, sizeof(buffer));
         blockwrite(filResult, buffer, nRead);
      end;
      filestream.Destroy;

      assignfile(filMovie, m_strMovieFileName);
      reset(filMovie);
      while not eof(filMovie) do
      begin
         blockread(filMovie, buffer, sizeof(buffer), nRead);
         blockwrite(filResult, buffer, nRead);
      end;
      closefile(filMovie);

      closefile(filResult);
   end;
end;

procedure TfrmMain.Remove1Click(Sender: TObject);
begin
   Layer2.Enabled := FALSE;
   FrameSet2.Enabled := FALSE;
   Keyframe1.Enabled := FALSE;
   if (m_row > 1) then
   begin
      Layer2.Enabled := TRUE;
   end;
   if (m_pFrame <> nil) then
   begin
      FrameSet2.Enabled := TRUE;
   end;
   if (m_pTweenFrame <> nil) then
   begin
      KeyFrame1.Enabled := TRUE;
   end;
end;

procedure TfrmMain.Insert1Click(Sender: TObject);
begin
   FrameSet1.Enabled := FALSE;
   Keyframes1.Enabled := FALSE;
   mnuInsertPose.Enabled := FALSE;
   if (m_pFrame = nil) and (m_row > 0) then
   begin
      FrameSet1.Enabled := TRUE;
   end;
   if (m_pTweenFrame = nil) and (m_pFrame <> nil) then
   begin
      KeyFrames1.Enabled := TRUE;
   end;
   if (m_pFrame <> nil) then
   begin
      mnuInsertPose.Enabled := TRUE;
   end;
end;

procedure TfrmMain.mnuInsertPoseClick(Sender: TObject);
var
   pLayer : TLayerObjPtr;
   pTweenFrame, pNew : TIFramePtr;
   f,g : integer;
   b : boolean;
   pOldFrame : TIFramePtr;
   cnt : integer;
begin
   pLayer := m_olLayers.Items[m_row-1];
   frmCanvas.StoreSelectedJointPos;
   if (pLayer^.m_nType <> O_T2STICK) and (pLayer^.m_nType <> O_STICKMAN) and (pLayer^.m_nType <> O_STICKMANBMP) and (pLayer^.m_nType <> O_SPECIALSTICK) then
   begin
      MessageBox(Application.Handle, 'Insert Posed Position is only available for the Stickmen objects', 'Tis Information', MB_OK or MB_ICONERROR);
      exit;
   end;
   if (m_pFrame = nil) then
   begin
      MessageBox(Application.Handle, 'You have to be in a FrameSet to insert a KeyFrame', 'Tis an Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   if (m_pTweenFrame <> nil) then
   begin
      b := true;
      pOldFrame := m_pTweenFrame;
      grdFramesSelectCell(nil, m_col+5, m_row, b);
      if (m_pFrame = nil) then
      begin
         MessageBox(Application.Handle, 'Creating a KeyFrame 5 frames from the current position would exceed the bounds of the FrameSet. Either create a KeyFrame earlier, or make the FrameSet larger first.', 'Tis an Error', MB_OK or MB_ICONERROR);
         grdFramesSelectCell(nil, m_col-5, m_row, b);
         exit;
      end;
      m_col := m_col-5;
      if (m_pTweenFrame <> nil) then
      begin
         MessageBox(Application.Handle, 'Could not create a KeyFrame 5 frames from current position', 'Tis an Error', MB_OK or MB_ICONERROR);
         exit;
      end;
   end else
   begin
      pOldFrame := nil;
   end;

   if (m_pFrame <> nil) and (m_pTweenFrame = nil) then
   begin
      for f := 0 to m_pFrame^.m_Frames.Count-1 do
      begin
         pTweenFrame := m_pFrame^.m_Frames.Items[f];
         if (pTweenFrame^.m_FrameNo > m_col) then
         begin
            if (pOldFrame <> nil) then m_col := m_col + 5;
            cnt := f;
            if cnt < 0 then cnt := 0;
            New(pNew);
            pNew^ := TIFrame.Create;
            pNew^.m_FrameNo := m_col;
            pNew^.m_nType := pLayer^.m_nType;
            m_pTweenFrame := pNew;
            if (pLayer^.m_nType = O_STICKMAN) then
            begin
               new(TStickManPtr(pNew^.m_pObject));
               TStickManPtr(pNew^.m_pObject)^ := TStickMan.Create(frmCanvas,20,20,20,20,20,20,20,20,20);
               if (pOldFrame <> nil) then
               begin
                  pOldFrame := m_pFrame^.m_Frames.Items[f-1];
                  TStickManPtr(pNew^.m_pObject)^.Assign(TStickManPtr(TIFramePtr(pOldFrame^.m_pObject)));
                  for g := 1 to 10 do
                  begin
                     TStickManPtr(pNew^.m_pObject)^.Pnt(g)^.m_bLocked := TStickManPtr(TIFramePtr(pOldFrame^.m_pObject))^.Pnt(g)^.m_bLocked;
                  end;
               end else
               begin
                  TStickManPtr(pNew^.m_pObject)^.Assign(TStickManPtr(TIFramePtr(m_pFrame^.m_Frames.Items[cnt])^.m_pObject));
               end;
            end;
            if (pLayer^.m_nType = O_SPECIALSTICK) then
            begin
               new(TSpecialStickManPtr(pNew^.m_pObject));
               TSpecialStickManPtr(pNew^.m_pObject)^ := TSpecialStickMan.Create(frmCanvas,20,20,20,20,20,20,20,20,20);
               if (pOldFrame <> nil) then
               begin
                  pOldFrame := m_pFrame^.m_Frames.Items[f-1];
                  TSpecialStickManPtr(pNew^.m_pObject)^.Assign(TSpecialStickManPtr(TIFramePtr(pOldFrame^.m_pObject)));
                  for g := 1 to 14 do
                  begin
                     TSpecialStickManPtr(pNew^.m_pObject)^.Pnt(g)^.m_bLocked := TSpecialStickManPtr(TIFramePtr(pOldFrame^.m_pObject))^.Pnt(g)^.m_bLocked;
                  end;
               end else
               begin
                  TSpecialStickManPtr(pNew^.m_pObject)^.Assign(TSpecialStickManPtr(TIFramePtr(m_pFrame^.m_Frames.Items[cnt])^.m_pObject));
               end;
            end;
            if (pLayer^.m_nType = O_STICKMANBMP) then
            begin
               new(TStickManBMPPtr(pNew^.m_pObject));
               TStickManBMPPtr(pNew^.m_pObject)^ := TStickManBMP.Create(frmCanvas,20,20,20,20,20,20,20,20,20);
               if (pOldFrame <> nil) then
               begin
                  pOldFrame := m_pFrame^.m_Frames.Items[f-1];
                  TStickManBMPPtr(pNew^.m_pObject)^.Assign(TStickManBMPPtr(TIFramePtr(pOldFrame^.m_pObject)));
                  for g := 1 to 10 do
                  begin
                     TStickManBMPPtr(pNew^.m_pObject)^.Pnt(g)^.m_bLocked := TStickManBMPPtr(TIFramePtr(pOldFrame^.m_pObject))^.Pnt(g)^.m_bLocked;
                  end;
               end else
               begin
                  TStickManBMPPtr(pNew^.m_pObject)^.Assign(TStickManBMPPtr(TIFramePtr(m_pFrame^.m_Frames.Items[cnt])^.m_pObject));
               end;
            end;
            if (pLayer^.m_nType = O_T2STICK) then
            begin
               new(TLimbListPtr(pNew^.m_pObject));
               TLimbListPtr(pNew^.m_pObject)^ := TLimbList.Create;
               if (pOldFrame <> nil) then
               begin
                  pOldFrame := m_pFrame^.m_Frames.Items[f-1];
                  TLimbListPtr(pNew^.m_pObject)^.CopyFrom(TLimbListPtr(TIFramePtr(pOldFrame^.m_pObject))^);
               end else
               begin
                  TLimbListPtr(pNew^.m_pObject)^.CopyFrom(TLimbListPtr(TIFramePtr(m_pFrame^.m_Frames.Items[cnt])^.m_pObject)^);
               end;
            end;
            m_pFrame^.m_Frames.Insert(f, pNew);
            grdFramesSelectCell(nil, m_col, m_row, b);
            grdFrames.Repaint;
            Render(m_col, TRUE);
            break;
         end;
      end;
   end;
   frmCanvas.SetSelectedJointByPos;
end;

procedure TfrmMain.Undo1Click(Sender: TObject);
var
   f : integer;
begin
   if (m_Undo.m_nType = O_T2STICK) then
   begin
      TLimbListPtr(m_Undo.m_pObject)^.CopyFrom(m_Undo.m_pSavedObject);
   end;   
   if (m_Undo.m_nType = O_STICKMAN) then
   begin
         f := 1;
         while f < 20 do
         begin
            TStickManPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left := m_Undo.m_nParams[f];
            TStickManPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top := m_Undo.m_nParams[f+1];
            f := f + 2;
         end;
   end;
   if (m_Undo.m_nType = O_SPECIALSTICK) then
   begin
         f := 1;
         while f < 28 do
         begin
            TSpecialStickManPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left := m_Undo.m_nParams[f];
            TSpecialStickManPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top := m_Undo.m_nParams[f+1];
            f := f + 2;
         end;
   end;
   if (m_Undo.m_nType = O_STICKMANBMP) then
   begin
         f := 1;
         while f < 20 do
         begin
            TStickManBMPPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left := m_Undo.m_nParams[f];
            TStickManBMPPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top := m_Undo.m_nParams[f+1];
            f := f + 2;
         end;
   end;
   if (m_Undo.m_nType = O_BITMAP) then
   begin
         f := 1;
         while f < 8 do
         begin
            TBitmanPtr(m_Undo.m_pObject).Pnt(((f-1)+2) div 2)^.Left := m_Undo.m_nParams[f];
            TBitmanPtr(m_Undo.m_pObject).Pnt(((f-1)+2) div 2)^.Top := m_Undo.m_nParams[f+1];
            f := f + 2;
         end;
   end;
   if (m_Undo.m_nType = O_RECTANGLE) then
   begin
         f := 1;
         while f < 8 do
         begin
            TSquareObjPtr(m_Undo.m_pObject).Pnt(((f-1)+2) div 2)^.Left := m_Undo.m_nParams[f];
            TSquareObjPtr(m_Undo.m_pObject).Pnt(((f-1)+2) div 2)^.Top := m_Undo.m_nParams[f+1];
            f := f + 2;
         end;
   end;
   if (m_Undo.m_nType = O_OVAL) then
   begin
         f := 1;
         while f < 8 do
         begin
            TOvalObjPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left := m_Undo.m_nParams[f];
            TOvalObjPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top := m_Undo.m_nParams[f+1];
            f := f + 2;
         end;
   end;
   if (m_Undo.m_nType = O_EXPLODE) then
   begin
         f := 1;
         while f < 4 do
         begin
            TExplodeObjPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left := m_Undo.m_nParams[f];
            TExplodeObjPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top := m_Undo.m_nParams[f+1];
            f := f + 2;
         end;
         TExplodeObjPtr(m_Undo.m_pObject).SetPoint(m_Undo.m_nParams[1],m_Undo.m_nParams[2],1);
         TExplodeObjPtr(m_Undo.m_pObject).InitParts;
   end;
   if (m_Undo.m_nType = O_LINE) then
   begin
         f := 1;
         while f < 4 do
         begin
            TLineObjPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left := m_Undo.m_nParams[f];
            TLineObjPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top := m_Undo.m_nParams[f+1];
            f := f + 2;
         end;
   end;
   if (m_Undo.m_nType = O_TEXT) then
   begin
         f := 1;
         while f < 8 do
         begin
            TTextObjPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Left := m_Undo.m_nParams[f];
            TTextObjPtr(m_Undo.m_pObject)^.Pnt(((f-1)+2) div 2)^.Top := m_Undo.m_nParams[f+1];
            f := f + 2;
         end;
   end;
   Undo1.Enabled := FALSE;
   Render(m_col, true);
end;

procedure TfrmMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   screen.cursor := crDefault;
end;

procedure TfrmMain.File1Click(Sender: TObject);
begin
   if (m_olLayers = nil) then
   begin
         Export1.Enabled := FALSE;
         Save1.Enabled := FALSE;
         SaveAs1.Enabled := FALSE;
   end else
   begin
      if (m_olLayers.Count = 1) then
      begin
         Export1.Enabled := FALSE;
         Save1.Enabled := FALSE;
         SaveAs1.Enabled := FALSE;
         AniGif1.Enabled := FALSE;
         BitmapSeries1.Enabled := FALSE;
      end else
      begin
         Export1.Enabled := TRUE;
         Save1.Enabled := TRUE;
         SaveAs1.Enabled := TRUE;
         AniGif1.Enabled := TRUE;
         BitmapSeries1.Enabled := TRUE;
      end;
   end;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
      timer1.enabled := false;
      Close1Click(nil);
      Load(m_strMovieFileName);
      m_bSaved := TRUE;
      Caption := 'This Is Stick Figure Animation Theatre (' + m_strMovieFileName + ')';
end;

procedure TfrmMain.Timer2Timer(Sender: TObject);
var
   name : string;
begin
   if (m_bChanged) then
   begin
      name := extractfilepath(application.exename);
      name := name + 'autosave.sif';
      Save(name, true);
   end;
end;

procedure TfrmMain.Properties1Click(Sender: TObject);
var
   frmMovieProps : TfrmMovieProps;
begin
   frmMovieProps := TfrmMovieProps.Create(self);
   frmMovieProps.m_strWidth.Text := itoa(frmCanvas.ClientWidth);
   frmMovieProps.m_strHeight.Text := itoa(frmCanvas.ClientHeight);
   frmMovieProps.memDescription.Text := TLayerObjPtr(m_olLayers.Items[0])^.m_strName;
   frmMovieProps.ShowModal;
   if (frmMovieProps.m_bOK) then
   begin
      TLayerObjPtr(m_olLayers.Items[0])^.m_strName := frmMovieProps.memDescription.Text;  
      m_nMovieWidth := atoi(frmMovieProps.m_strWidth.Text);
      m_nMovieHeight := atoi(frmMovieProps.m_strHeight.Text);
      if (frmCanvas.ClientWidth < m_nMovieWidth) then
      begin
         frmCanvas.ClientWidth := m_nMovieWidth;
      end;
      if (frmCanvas.ClientHeight < m_nMovieHeight) then
      begin
         frmCanvas.ClientHeight := m_nMovieHeight;
      end;
      if (frmCanvas.Aviplaya <> nil) then
         frmCanvas.aviPlaya.Left := frmCanvas.ClientWidth + 100;
      m_bChanged := TRUE;
   end;
   frmMovieProps.Destroy;
   Render(m_col);
end;

procedure TfrmMain.CopyFrameSet1Click(Sender: TObject);
begin
   if (m_pFrame <> nil) then
   begin
      m_pCopyFrameSet := m_pFrame;
      m_pCopyLayer := m_olLayers.Items[m_row-1];
   end;
end;

procedure TfrmMain.Edit1Click(Sender: TObject);
var
   f, g : integer;
   pFrameSet : TSingleFramePtr;
   pTween : TIFramePtr;
   nMax : integer;
begin
   CopyFrameset1.Enabled := FALSE;
   PasteFrameSet1.Enabled := FALSE;
   if (m_pFrame <> nil) then
   begin
      CopyFrameset1.Enabled := TRUE;
   end;
   if (m_pCopyFrameSet <> nil) then
   begin
      m_strMessage := '';
      if (m_row > 0) then
      begin
         if (m_pCopyLayer.m_nType = TLayerObjPtr(m_olLayers.Items[m_row-1])^.m_nType) then
         begin
            PasteFrameSet1.Enabled := TRUE;
         end;{ else
         if (m_pCopyLayer.m_nType = O_STICKMAN) and (TLayerObjPtr(m_olLayers.Items[m_row-1])^.m_nType = O_STICKMANBMP) then
         begin
            PasteFrameSet1.Enabled := TRUE;
         end else
         if (m_pCopyLayer.m_nType = O_STICKMANBMP) and (TLayerObjPtr(m_olLayers.Items[m_row-1])^.m_nType = O_STICKMAN) then
         begin
            PasteFrameSet1.Enabled := TRUE;
         end;  }
         if PasteFrameSet1.Enabled then
         begin
            for f := 0 to TLayerObjPtr(m_olLayers.Items[m_row-1])^.m_olFrames.Count-1 do
            begin
               pFrameSet := TSingleFramePtr(TLayerObjPtr(m_olLayers.Items[m_row-1])^.m_olFrames.Items[f]);
               nMax := m_col+(TIFramePtr(m_pCopyFrameSet.m_Frames.Last)^.m_FrameNo-TIFramePtr(m_pCopyFrameSet.m_Frames.First)^.m_FrameNo);
               for g := 0 to pFrameSet^.m_Frames.Count-1 do
               begin
                  pTween := pFrameSet^.m_Frames.Items[g];
                  if (pTween^.m_FrameNo >= m_col) and (pTween.m_FrameNo <= nMax) then
                  begin
                     m_strMessage := 'There are not enough free frames to paste the FrameSet here';
                     break;
                  end;
               end;
               if m_strMessage <> '' then break;
            end;
         end;
      end;
   end;
end;

procedure TfrmMain.PasteFrameset1Click(Sender: TObject);
var
   pLayer : TLayerObjPtr;
   pFrameSet : TSingleFramePtr;
   pTween, pNewTween : TIFRamePtr;
   f : integer;
begin
   if (m_strMessage <> '') then
   begin
      MessageBox(Application.Handle, pChar(m_strMessage), 'Tis an Error', MB_OK or MB_ICONERROR);
      exit;
   end;
   if (m_pCopyFrameSet <> nil) then
   begin
      pLayer := m_olLayers.Items[m_row-1];
      if (pLayer <> nil) then
      begin
         new(pFrameSet);
         pFrameSet^ := TSingleFrame.Create;
         pLayer^.m_olFrames.Add(pFrameSet);
         pFrameSet^.m_Type := m_pCopyFrameSet^.m_Type;
         for f := 0 to m_pCopyFrameSet^.m_Frames.Count-1 do
         begin
            pTween := m_pCopyFrameSet^.m_Frames.Items[f];
            new(pNewTween);
            pNewTween^ := TIFrame.Create;
            pFrameSet^.m_Frames.Add(pNewTween);
            pNewTween^.m_nType := pTween^.m_nType;
            pNewTween^.m_FrameNo := m_col + (pTween^.m_FrameNo - TIFramePtr(m_pCopyFrameSet^.m_Frames.Items[0])^.m_FrameNo);
            pNewTween^.m_nOnion := pTween^.m_nOnion;
//////////////
             if (m_pCopyLayer^.m_nType = O_EDITVIDEO) then
             begin
                new(TEditVideoObjPtr(pNewTween^.m_pObject));
                TEditVideoObjPtr(pNewTween^.m_pObject)^ := TEditVideoObj.Create(frmCanvas);
                TEditVideoObjPtr(pNewTween^.m_pObject)^.m_strFileName := TEditVideoObjPtr(pTween^.m_pObject)^.m_strFileName;
                 TEditVideoObjPtr(pNewTween^.m_pObject)^.Pnt(1)^.Left := TEditVideoObjPtr(pTween^.m_pObject)^.Pnt(1)^.Left;
                 TEditVideoObjPtr(pNewTween^.m_pObject)^.Pnt(1)^.Top := TEditVideoObjPtr(pTween^.m_pObject)^.Pnt(1)^.Top;
                 TEditVideoObjPtr(pNewTween^.m_pObject)^.Pnt(2)^.Left := TEditVideoObjPtr(pTween^.m_pObject)^.Pnt(2)^.Left;
                 TEditVideoObjPtr(pNewTween^.m_pObject)^.Pnt(2)^.Top := TEditVideoObjPtr(pTween^.m_pObject)^.Pnt(2)^.Top;
                 TEditVideoObjPtr(pNewTween^.m_pObject)^.Pnt(3)^.Left := TEditVideoObjPtr(pTween^.m_pObject)^.Pnt(3)^.Left;
                 TEditVideoObjPtr(pNewTween^.m_pObject)^.Pnt(3)^.Top := TEditVideoObjPtr(pTween^.m_pObject)^.Pnt(3)^.Top;
                 TEditVideoObjPtr(pNewTween^.m_pObject)^.Pnt(4)^.Left := TEditVideoObjPtr(pTween^.m_pObject)^.Pnt(4)^.Left;
                 TEditVideoObjPtr(pNewTween^.m_pObject)^.Pnt(4)^.Top := TEditVideoObjPtr(pTween^.m_pObject)^.Pnt(4)^.Top;
             end;
             if (m_pCopyLayer^.m_nType = O_STICKMAN) then
             begin
                new(TStickManPtr(pNewTween^.m_pObject));
                TStickManPtr(pNewTween^.m_pObject)^ := TStickMan.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
                TStickManPtr(pNewTween^.m_pObject)^.Assign(TStickManPtr(pTween^.m_pObject));
             end;
             if (m_pCopyLayer^.m_nType = O_SPECIALSTICK) then
             begin
                new(TSpecialStickManPtr(pNewTween^.m_pObject));
                TSpecialStickManPtr(pNewTween^.m_pObject)^ := TSpecialStickMan.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
                TSpecialStickManPtr(pNewTween^.m_pObject)^.Assign(TSpecialStickManPtr(pTween^.m_pObject));
             end;
             if (m_pCopyLayer^.m_nType = O_STICKMANBMP) then
             begin
                new(TStickManBMPPtr(pNewTween^.m_pObject));
                TStickManBMPPtr(pNewTween^.m_pObject)^ := TStickManBMP.Create(frmCanvas, 25,25, 25,25, 40, 20,20,20,20);
                TStickManBMPPtr(pNewTween^.m_pObject)^.Assign(TStickManBMPPtr(pTween^.m_pObject));
             end;
             if (m_pCopyLayer^.m_nType = O_BITMAP) then
             begin
                new(TBitManPtr(pNewTween^.m_pObject));
                TBitManPtr(pNewTween^.m_pObject)^ := TBitMan.Create(frmCanvas, '', TBitManPtr(pLayer^.m_pTempObject)^.Imarge.GetWidth, TBitManPtr(pLayer^.m_pTempObject)^.Imarge.GetHeight);
                TBitManPtr(pNewTween^.m_pObject)^.Assign(TBitManPtr(pTween^.m_pObject));
             end;
             if (m_pCopyLayer^.m_nType = O_RECTANGLE) then
             begin
                new(TSquareObjPtr(pNewTween^.m_pObject));
                TSquareObjPtr(pNewTween^.m_pObject)^ := TSquareObj.Create(frmCanvas);
                TSquareObjPtr(pNewTween^.m_pObject)^.Assign(TSquareObjPtr(pTween^.m_pObject));
             end;
             if (m_pCopyLayer^.m_nType = O_LINE) then
             begin
                new(TLineObjPtr(pNewTween^.m_pObject));
                TLineObjPtr(pNewTween^.m_pObject)^ := TLineObj.Create(frmCanvas);
                TLineObjPtr(pNewTween^.m_pObject)^.Assign(TLineObjPtr(pTween^.m_pObject));
             end;
             if (m_pCopyLayer^.m_nType = O_EXPLODE) then
             begin
                new(TExplodeObjPtr(pNewTween^.m_pObject));
                TExplodeObjPtr(pNewTween^.m_pObject)^ := TExplodeObj.Create(frmCanvas, TRUE);
                TExplodeObjPtr(pNewTween^.m_pObject)^.Assign(TExplodeObjPtr(pTween^.m_pObject));
             end;
             if (m_pCopyLayer^.m_nType = O_TEXT) then
             begin
                new(TTextObjPtr(pNewTween^.m_pObject));
                TTextObjPtr(pNewTween^.m_pObject)^ := TTextObj.Create(frmCanvas, TTextObjPtr(pTween^.m_pObject)^.m_strCaption);
                 TTextObjPtr(pNewTween^.m_pObject)^.m_strFontName := TTextObjPtr(pTween^.m_pObject)^.m_strFontName;
                 TTextObjPtr(pNewTween^.m_pObject)^.m_strCaption := TTextObjPtr(pTween^.m_pObject)^.m_strCaption;
                 TTextObjPtr(pNewTween^.m_pObject)^.m_FontStyle := TTextObjPtr(pTween^.m_pObject)^.m_fontStyle;
                 TTextObjPtr(pNewTween^.m_pObject)^.m_InColour := TTextObjPtr(pTween^.m_pObject)^.m_inColour;
                 TTextObjPtr(pNewTween^.m_pObject)^.m_OutColour := TTextObjPtr(pTween^.m_pObject)^.m_outColour;
                 TTextObjPtr(pNewTween^.m_pObject)^.m_styleOuter := TTextObjPtr(pTween^.m_pObject)^.m_StyleOuter;
                 TTextObjPtr(pNewTween^.m_pObject)^.Pnt(1)^.Left := TTextObjPtr(pTween^.m_pObject)^.Pnt(1)^.Left;
                 TTextObjPtr(pNewTween^.m_pObject)^.Pnt(1)^.Top := TTextObjPtr(pTween^.m_pObject)^.Pnt(1)^.Top;
                 TTextObjPtr(pNewTween^.m_pObject)^.Pnt(2)^.Left := TTextObjPtr(pTween^.m_pObject)^.Pnt(2)^.Left;
                 TTextObjPtr(pNewTween^.m_pObject)^.Pnt(2)^.Top := TTextObjPtr(pTween^.m_pObject)^.Pnt(2)^.Top;
                 TTextObjPtr(pNewTween^.m_pObject)^.Pnt(3)^.Left := TTextObjPtr(pTween^.m_pObject)^.Pnt(3)^.Left;
                 TTextObjPtr(pNewTween^.m_pObject)^.Pnt(3)^.Top := TTextObjPtr(pTween^.m_pObject)^.Pnt(3)^.Top;
                 TTextObjPtr(pNewTween^.m_pObject)^.Pnt(4)^.Left := TTextObjPtr(pTween^.m_pObject)^.Pnt(4)^.Left;
                 TTextObjPtr(pNewTween^.m_pObject)^.Pnt(4)^.Top := TTextObjPtr(pTween^.m_pObject)^.Pnt(4)^.Top;
             end;
             if (m_pCopyLayer^.m_nType = O_POLY) then
             begin
                new(TPolyObjPtr(pNewTween^.m_pObject));
                TPolyObjPtr(pNewTween^.m_pObject)^ := TPolyObj.Create(frmCanvas, TPolyObjPtr(pTween^.m_pObject)^.PntList.Count);
                TPolyObjPtr(pNewTween^.m_pObject)^.Assign(TPolyObjPtr(pTween^.m_pObject));
             end;
             if (m_pCopyLayer^.m_nType = O_OVAL) then
             begin
                new(TOvalObjPtr(pNewTween^.m_pObject));
                TOvalObjPtr(pNewTween^.m_pObject)^ := TOvalObj.Create(frmCanvas);
                TOvalObjPtr(pNewTween^.m_pObject)^.Assign(TOvalObjPtr(pTween^.m_pObject));
             end;
/////////////
         end;
      end;
   end;
   grdFrames.Repaint;
   Render(m_col);
end;

procedure TfrmMain.Bitmap1Click(Sender: TObject);
var
   id : TGUID;
begin
   GetEncoderClsid('image/bmp', id);
   if (frmCanvas <> nil) and (m_Bitmap <> nil) then
   begin
      sd.Filter := 'Bitmap files (*.bmp)|*.bmp';
      sd.DefaultExt := '.bmp';
      if (sd.Execute) then
      begin
         m_Bitmap.Save(sd.FileName, id);
      end;
   end;
end;

procedure TfrmMain.Gif1Click(Sender: TObject);
var
   gif : TGifImage;
   id : TGUID;
begin
   GetEncoderClsid('image/gif', id);
   if (frmCanvas <> nil) and (m_Bitmap <> nil) then
   begin
      sd.Filter := 'Gif files (*.gif)|*.gif';
      sd.DefaultExt := '.gif';
      if (sd.Execute) then
      begin
         m_Bitmap.Save(sd.FileName, id);
      end;
   end;
end;

procedure TfrmMain.AniGif1Click(Sender: TObject);
var
   f, g, h : integer;
   nEnd : integer;
   pLayer : TLayerObjPtr;
   nCurrentFrame : integer;
   gif : TGifImage;
     Ext			: TGIFGraphicControlExtension;
     LoopExt		: TGIFAppExtNSLoop;
     Index			: integer;
     Delay			: integer;
   nCurrentWidth, nCurrentHeight : integer;

   gr : TBitmap;
   dest : TGPGraphics;
begin

   nCurrentWidth := frmCanvas.ClientWidth;
   nCurrentHeight := frmCanvas.ClientHeight;

   sd.Filter := 'Gif files (*.gif)|*.gif';
   sd.DefaultExt := '.gif';
   if (not sd.Execute) then
   begin
      exit;
   end;

   frmCanvas.ClientWidth := m_nMovieWidth;
   frmCanvas.ClientHeight := m_nMovieHeight;
   //ResizeStage(m_nMovieWidth, m_nMovieHeight);
   //frmMain.ResizeStage(clientwidth, clientheight);


   Delay := round(60 / m_nFPS);

   m_xinc := 0;
   m_yinc := 0;
   m_xincmax := 0;
   m_yincmax := 0;
   m_bPlaying := TRUE;
   nEnd := 1;
   for f := 0 to m_olLayers.Count-1 do
   begin
      pLayer := m_olLayers.Items[f];
      for g := 0 to pLayer^.m_olFrames.Count-1 do
      begin
         if TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo > nEnd then
         begin
            nEnd := TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo;
         end;
      end;
      for h := 0 to pLayer^.m_olActions.Count-1 do
      begin
         if (TActionObjPtr(pLayer^.m_olActions.Items[h])^.m_nType = 0) then
         begin
            TActionObjPtr(pLayer^.m_olActions.Items[h])^.m_nParams[3] := 0;
         end;
      end;
   end;

   nCurrentFrame := 1;

   gif := TGifImage.Create;
   gif.ColorReduction := rmNetscape;
   gif.DitherMode := dmNearest;//dmFloydSteinberg;

   while nCurrentFrame <= nEnd do
   begin
      frmMain.Render(nCurrentFrame);
        gr := TBitmap.Create;
        gr.Width := m_nMovieWidth;
        gr.Height := m_nMovieHeight;
        //gr.SetSize(m_nMovieWidth, m_nMovieHeight);
         dest := TGPGraphics.Create(gr.Canvas.handle);
         dest.DrawImage(m_Bitmap, 0,0, m_nMovieWidth, m_nMovieHeight);
         dest.Free;
        Index := GIF.Add(gr);
        gr.Destroy;
        // Add Netscape Loop extension first!
        if (Index = 0) then
        begin
          LoopExt := TGIFAppExtNSLoop.Create(GIF.Images[Index]);
          LoopExt.Loops := 0; // Forever
          GIF.Images[Index].Extensions.Add(LoopExt);
        end;
        // Add Graphic Control Extension (for delay)
        Ext := TGIFGraphicControlExtension.Create(GIF.Images[Index]);
        Ext.Delay := 2;
        GIF.Images[Index].Extensions.Add(Ext);

      nCurrentFrame := nCurrentFrame + 1;
   end;

   gif.SaveToFile(sd.FileName);
   gif.Destroy;

   //ResizeStage(nCurrentWidth, nCurrentHeight);
   frmCanvas.ClientWidth := nCurrentWidth;
   frmCanvas.ClientHeight := nCurrentHeight;

   m_bOld := FALSE;
   m_col := nEnd;
   grdFrames.Repaint;
   m_xinc := 0;
   m_yinc := 0;
   m_xincmax := 0;
   m_yincmax := 0;
   Render(nEnd);
   m_bPlaying := FALSE;

end;

procedure TfrmMain.BitmapSeries1Click(Sender: TObject);
var
   f, g, h : integer;
   nEnd : integer;
   pLayer : TLayerObjPtr;
   nCurrentFrame : integer;
     strName : string;
     strTemp : string;
   fs : TFileStream;
begin

   sd.Filter := 'Bitmap files (*.png)|*.png';
   sd.DefaultExt := '.png';
   if (not sd.Execute) then
   begin
      exit;
   end;

   strName := extractfilename(sd.FileName);
   strName := copy(strName, 1, length(strName)-4);

   m_xinc := 0;
   m_yinc := 0;
   m_xincmax := 0;
   m_yincmax := 0;
   m_bPlaying := TRUE;
   nEnd := 1;
   for f := 0 to m_olLayers.Count-1 do
   begin
      pLayer := m_olLayers.Items[f];
      for g := 0 to pLayer^.m_olFrames.Count-1 do
      begin
         if TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo > nEnd then
         begin
            nEnd := TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo;
         end;
      end;
      for h := 0 to pLayer^.m_olActions.Count-1 do
      begin
         if (TActionObjPtr(pLayer^.m_olActions.Items[h])^.m_nType = 0) then
         begin
            TActionObjPtr(pLayer^.m_olActions.Items[h])^.m_nParams[3] := 0;
         end;
      end;
   end;

   nCurrentFrame := 1;

   while nCurrentFrame <= nEnd do
   begin
      frmMain.Render(nCurrentFrame);
      strTemp := Format('%s%s%0.4d.png', [extractfilepath(sd.FileName), strName, nCurrentFrame]);
      fs := TFileStream.Create(strTemp, fmOpenWrite);
      SaveBitmap(m_Bitmap, fs);
      fs.Free;
      nCurrentFrame := nCurrentFrame + 1;
   end;

   m_bOld := FALSE;
   m_col := nEnd;
   grdFrames.Repaint;
   m_xinc := 0;
   m_yinc := 0;
   m_xincmax := 0;
   m_yincmax := 0;
   Render(nEnd);
   m_bPlaying := FALSE;

end;

procedure TfrmMain.GotoFrame1Click(Sender: TObject);
var
   b : boolean;
begin
   b := false;
   frmGoto.ShowModal;
   if (frmGoto.m_bOk) then
   begin
      grdFrames.Col := frmGoto.m_nFrame;
      grdFramesSelectCell(self, frmGoto.m_nFrame, 0, b);
      Render(frmGoto.m_nFrame, true);
   end;
end;

procedure TfrmMain.Flash1Click(Sender: TObject);
var
   fe : TfrmFlashExport;
   strTemp : string;
begin
   strTemp := m_strMovieFileName;
   if (length(strTemp) = 0) then
   begin
      strTemp := 'untitled.sif';
   end;
   strTemp[length(strTemp)-1] := 'w';
   fe := TfrmFlashExport.Create(self);
   fe.m_strFileNAme.Text := strTemp;
   fe.ShowModal;
   fe.Destroy;
end;

procedure TfrmMain.ExportFlashVideo(strFileName, strSoundTrack : string);
type
   pfVideoCreate = function(nWidth, nHeight, nFPS : integer) : pointer; cdecl;
   pfVideoAddFrame = procedure(pVideo : pointer; dc : HDC; bmp : HBITMAP); cdecl;
   pfVideoSave = function(pVideo : pointer; szName : pchar) : integer; cdecl;
var
   f, g, h : integer;
   nEnd : integer;
   pLayer : TLayerObjPtr;
   nCurrentFrame : integer;
   VideoCreate : pfVideoCreate;
   VideoAddFrame : pfVideoAddFrame;
   VideoSave : pfVideoSave;
   m_hDLL : HMODULE;
   pVideo : pointer;
begin

   //////////
   m_hDLL := LoadLibrary('tis_flash.dll');
   if (m_hDLL = 0) then
   begin
      exit;
   end;
   VideoCreate := pfVideoCreate(GetProcAddress(m_hDLL, 'Video_create'));
   VideoAddFrame := pfVideoAddFrame(GetProcAddress(m_hDLL, 'Video_addFrame'));
   VideoSave := pfVideoSave(GetProcAddress(m_hDLL, 'Video_save'));
   if (@VideoCreate = nil) or (@VideoAddFrame = nil) or (@VideoSave = nil) then
   begin
      FreeLibrary(m_hDLL);
      exit;
   end;
   //d/
   pVideo := VideoCreate(frmCanvas.ClientWidth, frmCanvas.ClientHeight, m_nFPS);
   if (pVideo = nil) then
   begin
      exit;
   end;
   /////////

   m_xinc := 0;
   m_yinc := 0;
   m_xincmax := 0;
   m_yincmax := 0;
   m_bPlaying := TRUE;
   nEnd := 1;
   for f := 0 to m_olLayers.Count-1 do
   begin
      pLayer := m_olLayers.Items[f];
      for g := 0 to pLayer^.m_olFrames.Count-1 do
      begin
         if TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo > nEnd then
         begin
            nEnd := TIFramePtr(TSingleFramePtr(pLayer^.m_olFrames.Items[g])^.m_Frames.Last)^.m_FrameNo;
         end;
      end;
      for h := 0 to pLayer^.m_olActions.Count-1 do
      begin
         if (TActionObjPtr(pLayer^.m_olActions.Items[h])^.m_nType = 0) then
         begin
            TActionObjPtr(pLayer^.m_olActions.Items[h])^.m_nParams[3] := 0;
         end;
      end;
   end;

   nCurrentFrame := 1;

   while nCurrentFrame <= nEnd do
   begin
      frmMain.Render(nCurrentFrame);
      //d/VideoAddFrame(pVideo, m_Bitmap.Canvas.Handle, m_Bitmap.Handle);
      nCurrentFrame := nCurrentFrame + 1;
   end;
   //////////
   VideoSave(pVideo, pChar(strFileName));
   FreeLibrary(m_hDLL);
   //////////

   m_bOld := FALSE;
   m_col := nEnd;
   grdFrames.Repaint;
   m_xinc := 0;
   m_yinc := 0;
   m_xincmax := 0;
   m_yincmax := 0;
   Render(nEnd);
   m_bPlaying := FALSE;
end;

procedure TfrmMain.ResizeStage(wide,high : integer);
begin
   if (m_Bitmap = nil) then
      exit;

   m_Bitmap.Free;
   m_Bitmap := TGPBitmap.Create(wide, high);
   m_Canvas := TGPGraphics.Create(m_Bitmap);
   m_Canvas.SetSmoothingMode(SmoothingModeAntiAlias);

   m_nXoffset := (frmCanvas.ClientWidth - m_nMovieWidth) div 2;
   m_nYOffset := (frmCanvas.ClientHeight - m_nMovieHeight) div 2;

end;

procedure TfrmMain.ReRender;
begin
   Render(m_nLastRendered, m_bLastRenderedControl);
end;

end.
