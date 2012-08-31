const
   C_NOTHING = 0;
   C_FRAME_EMPTY = 1;
   C_FRAME_USED = 2;
   C_FRAME_KEY = 3;

   C_UNKNOWN = 0;

   //media categories
   C_SOUND = 1;
   C_PICTURE = 2;
   C_STICK = 3;
   C_RECTANGLE = 4;
   C_LINE = 5;
   C_POLYGON = 6;
   C_ELLIPSE = 7;
   C_TEXT = 8;
   C_3D_STATIC = 9;
   C_COMPLEX = 10;
   //media subtypes
   C_MP3 = 100;
   C_OGG = 101;
   C_WAV = 102;

   //movie play state
   C_PLAYING = 1;
   C_STOPPED = 2;
   C_PAUSED = 3;

   //info structures for media descriptors
   C_INFO_AUDIO = 1;
   C_INFO_AUDIO_3D = 2;
   C_INFO_PICTURE = 3;
   C_INFO_STICK = 4;
   C_INFO_LINE = 5;
   C_INFO_RECTANGLE = 6;
   C_INFO_ELLIPSE = 7;
   C_INFO_TEXT = 8;
   C_INFO_3D_STATIC = 9;
   C_INFO_COMPLEX = 10;

   //mouse processing constants
   C_MOUSE_BUTTON_LEFT = 1;
   C_MOUSE_BUTTON_RIGHT = 2;
   C_MOUSE_BUTTON_MIDDLE = 3;
   C_MOUSE_BUTTON_WHEEL = 4;
   C_MOUSE_UP = 5;
   C_MOUSE_DOWN = 6;
   C_MOUSE_MOVE = 7;
   C_MOUSE_SHIFT = 1;
   C_MOUSE_ALT   = 2;
   C_MOUSE_CTRL  = 4;
   //mouse functions: ie, what the mouse is being used for
   C_MOUSE_FUNCTION_NONE = 0;
   C_MOUSE_FUNCTION_SELECT = 1;
   C_MOUSE_FUNCTION_MOVE = 2;
   C_MOUSE_FUNCTION_ROTATE = 3;
   C_MOUSE_FUNCTION_SIZE = 4;

   //main window editing mode
   C_MODE_CONSTRUCT = 1;
   C_MODE_PHYSICS = 2;

   //stick figure editing modes
   C_MODE_SELECT_JOINT = 1;
   C_MODE_ADD_JOINT = 2;
   C_MODE_DELETE_JOINT = 3;
   C_MODE_LOCK_JOINT = 4;
   C_MODE_DISABLE_JOINT = 5;
   C_MODE_UNLOCK_JOINT = 6;
   C_MODE_LOCK_JOINT_TO_PARENT = 7;
   C_MODE_MOVE_JOINT = 8;

   //stick rendering modes
   C_STICK_DRAWMODE_STRAIGHT = 1;
   C_STICK_DRAWMODE_CURVY = 2;
   C_STICK_TWEENMODE_TWEEN = 3;
   C_STICK_TWEENMODE_ROTATE = 4;

   //script constants - affects layers and classMovie
   C_SCRIPT_MOVIE_FRAME_START = 0; //must always be first
      C_SCRIPT_MOVIE_LAYER_START = 1;
      C_SCRIPT_MOVIE_LAYER_DONE  = 2;
   C_SCRIPT_MOVIE_FRAME_DONE  = 3; //must always be last

   //file chunk consts
   //C_CHUNK_FRAME = 1;
   //C_CHUNK_
