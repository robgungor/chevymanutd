package com.oddcast.photo
{
	import code.skeleton.App;
	
	import com.oddcast.cv.api.FaceAPI_Constants;
	import com.oddcast.cv.util.Loader_HaxeSwfCallback;
	import com.oddcast.workshop.ServerInfo;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class OFCWrapper
	{
		protected var _face_finder_loader:Loader_HaxeSwfCallback;
		protected var _class_face_finder:Class;
		protected var face_finder_api:*;		
		
		public function OFCWrapper()
		{
			
		}
		
		public function load_face_finder():void
		{
			
			var face_finder_url:String = ServerInfo.contentURL+'autophoto/FaceFinder.swf';//ServerInfo.autoPhotoURL + App.settings.FACE_FINDER_FILE_NAME;
			_face_finder_loader = new Loader_HaxeSwfCallback(face_finder_loaded,"com.oddcast.cv.api.FaceFinderSWF");
			_face_finder_loader.addEventListener(IOErrorEvent.IO_ERROR,face_finder_error);
			_face_finder_loader.load(new URLRequest(face_finder_url));
		}
		
		public function find_face(_bitmap_data:BitmapData):Array
		{
			var rotations:Array = [0.0, 30.0, -30.0];
			var faceIDarray:Array = face_finder_api.getFacesRotated(_bitmap_data,true,rotations);
			if (faceIDarray!=null && faceIDarray.length>0)
			{
				if (faceIDarray.length>1)
				{
					return null;
				}
				else
				{
					for each (var face:uint in faceIDarray) {
						var pos:Array = face_finder_api.getFaceData(face, [FaceAPI_Constants.AR_FACE_DATA_XPOS, 
							FaceAPI_Constants.AR_FACE_DATA_YPOS, 
							FaceAPI_Constants.AR_FACE_DATA_ZPOS, 
							FaceAPI_Constants.AR_FACE_DATA_NOD,
							FaceAPI_Constants.AR_FACE_DATA_TURN,
							FaceAPI_Constants.AR_FACE_DATA_TWIST ] );
						if (pos) {
							//Here are the XYZ:
							//x and y are in pixel coords from top left;
							//z is in arbitrary units  as we dont actually know the focal length of the webcam - more work to do here
							// currently all data is unsmoothed so it will jump around a bit.  I'll work more on smoothing my end.
							//check to ensure that each data is valid;
							var x:Number = (pos[FaceAPI_Constants.AR_FACE_DATA_XPOS] != null) ? pos[FaceAPI_Constants.AR_FACE_DATA_XPOS] : 0.0;
							var y:Number = (pos[FaceAPI_Constants.AR_FACE_DATA_YPOS] != null) ? pos[FaceAPI_Constants.AR_FACE_DATA_YPOS] : 0.0;
							var z:Number = (pos[FaceAPI_Constants.AR_FACE_DATA_ZPOS] != null) ? pos[FaceAPI_Constants.AR_FACE_DATA_ZPOS] : 0.0;
							var nod:Number = (pos[FaceAPI_Constants.AR_FACE_DATA_NOD] != null) ? pos[FaceAPI_Constants.AR_FACE_DATA_NOD] : 0.0;
							var turn:Number = (pos[FaceAPI_Constants.AR_FACE_DATA_TURN] != null) ? pos[FaceAPI_Constants.AR_FACE_DATA_TURN] : 0.0;
							var twist:Number = (pos[FaceAPI_Constants.AR_FACE_DATA_TWIST] != null) ? pos[FaceAPI_Constants.AR_FACE_DATA_TWIST] : 0.0;
							
							trace ("x:" + x+ "  y:"+y+ "   z:"+z + " twist:"+twist + ' turn: ' + turn);
							return [x, y, z, twist];
						}
						else
						{
							return null;
						}
					}
					return null;
				}
				
			}
			else
			{
				return null;
			}
		}
		
		protected function face_finder_loaded(swf:MovieClip, haxeRootClass:Class):void
		{
			_face_finder_loader.removeEventListener(IOErrorEvent.IO_ERROR,face_finder_error);
			_class_face_finder = haxeRootClass;
			var faceFinderSWF:* = new _class_face_finder();
			face_finder_api = faceFinderSWF.getAPI();
		}
		
		protected function face_finder_error(aIOError:IOErrorEvent):void
		{
			
		}
		
	}
}