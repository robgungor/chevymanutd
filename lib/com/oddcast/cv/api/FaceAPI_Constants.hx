
/**
 * ...
 * @author Jake Lewis
 * copyright Oddcast Inc. 2010  All rights reserved
 * 5/4/2010 4:24 PM
 **/

package  com.oddcast.cv.api;
//import com.oddcast.cv.api.FaceAPI_Constants;

	import com.oddcast.cv.face.FaceParts;
	import com.oddcast.cv.framestore.FrameStore;
	import com.oddcast.cv.util.HandleID;
	import com.oddcast.cv.haar.SmoothingFacePoints;
	
	typedef ID_Type     = ID;
	typedef FaceID		= ID_Type;
	
	typedef ArrayFaceID = Array <FaceID>;	
	typedef ArrayFaceData = Array <Int>;
	typedef ArrayFaceDataResults = Array <Float>;
	
	typedef FrameStoreID = ID_Type;
	typedef TrackerMode = UInt;
	
	typedef FrameStoreFrameReturnCode = Int;
	
	class FaceAPI_Constants
	{
		public static var AR_FACE_DATA_XPOS  			= AR_FaceData.XPOS;
		public static var AR_FACE_DATA_YPOS  			= AR_FaceData.YPOS;
		public static var AR_FACE_DATA_ZPOS  			= AR_FaceData.ZPOS;
		public static var AR_FACE_DATA_NOD   			= AR_FaceData.NOD;
		public static var AR_FACE_DATA_TURN  			= AR_FaceData.TURN;
		public static var AR_FACE_DATA_TWIST  			= AR_FaceData.TWIST;
		public static var AR_FACE_DATA_LEFT_EYE_X  		= AR_FaceData.LEFT_EYE_X;
		public static var AR_FACE_DATA_LEFT_EYE_Y   	= AR_FaceData.LEFT_EYE_Y; 
		public static var AR_FACE_DATA_RIGHT_EYE_X  	= AR_FaceData.RIGHT_EYE_X; 
		public static var AR_FACE_DATA_RIGHT_EYE_Y  	= AR_FaceData.RIGHT_EYE_Y; 
		public static var AR_FACE_DATA_SIMPLE_FACE_XPOS	= AR_FaceData.SIMPLE_FACE_XPOS;
		public static var AR_FACE_DATA_SIMPLE_FACE_YPOS	= AR_FaceData.SIMPLE_FACE_YPOS;
		public static var AR_FACE_DATA_SIMPLE_FACE_ZPOS	= AR_FaceData.SIMPLE_FACE_ZPOS;
		
		
		
		
		public static inline var CAMERA_DIST 	= 1000.0; //HaarFace.CAMERA_DIST;
		public static inline var ERROR_FACEID  = -1;
		public static inline var DEFAULT_MAX_FACES = 64;
		public static inline var DEFAULT_WEBCAM_MAX_FACES = 1;
		public static inline var ERROR_FRAMESTOREID  = HandleID.NULL_ID;
		
		public static var FRAMESTORE_ARCHIVE_FILE_EXTENSION = ".framestore.oa1";
		
		
		public static inline var FRAMESTORE_FRAME_ERROR			= FrameStore.FRAME_ERROR;
		public static inline var FRAMESTORE_FRAME_FULL				= FrameStore.FRAME_FULL;
		public static inline var FRAMESTORE_FRAME_OVERWROTE_PREV  	= FrameStore.FRAME_OVERWROTE_PREV;
		public static inline var FRAMESTORE_FRAME_RECORDED 		= FrameStore.FRAME_RECORDED;
		
		public static inline var FRAME_PLAYBACK_FINISHED			= FrameStore.FRAME_ERROR;
		
	
		public static inline var STATE_WAITING_FOR_SECURITY_CLICK  :Int			= TrackerStates.STATE_0_NONE;
		public static inline var STATE_WAITING_FOR_WHITEBALANCE	   :Int			= TrackerStates.STATE_CAMERA_WHITEBALANCE_WARMUP;
		public static inline var STATE_FACE_FINDING				   :Int			= TrackerStates.STATE_FACE_FINDING;
		
		
		public static inline var TRACKER_MODE_FACE			:Int = 1;
		public static inline var TRACKER_MODE_JUST_FACE		:Int = TRACKER_MODE_FACE;
		public static inline var TRACKER_MODE_FACE_EYES		:Int = 3;
		
		
		public static inline var TRACKER_MODE_DEFAULT	:Int = TRACKER_MODE_FACE_EYES;
		
		public static inline var DEFAULT_BLINK_INTERVAL :Float = 500;
		
		public static inline var DEFAULT_MODE		= 0;
		public static inline var FAST_MODE			= 1;
		public static inline var FINE_MODE 			= 2;
		
		
		inline public static var DEFAULT_JPG_COMPRESSION = 80;
	}
	
	class SmoothingIndices{
		public static var SIMPLE_XYSMOOTH  	= 	SmoothingFacePoints.SIMPLE_XYSMOOTH + SmoothingFacePoints.SMOOTH_ID;
		public static var SIMPLE_ZSMOOTH   	=	SmoothingFacePoints.SIMPLE_ZSMOOTH  + SmoothingFacePoints.SMOOTH_ID;
		public static var XY_SMOOTH			=	SmoothingFacePoints.XY_SMOOTH 		+ SmoothingFacePoints.SMOOTH_ID;				
		public static var Z_SMOOTH 			=	SmoothingFacePoints.Z_SMOOTH 		+ SmoothingFacePoints.SMOOTH_ID;
		public static var EYEL_SMOOTH		=	SmoothingFacePoints.EYEL_SMOOTH	 	+ SmoothingFacePoints.SMOOTH_ID;
		public static var EYER_SMOOTH		=	SmoothingFacePoints.EYER_SMOOTH	 	+ SmoothingFacePoints.SMOOTH_ID;
		public static var NOSE_SMOOTH		=	SmoothingFacePoints.NOSE_SMOOTH	 	+ SmoothingFacePoints.SMOOTH_ID;
	}	
	
	
	