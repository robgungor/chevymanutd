/**
* ...
* @author Sam
* @version 0.1
* 
* This class doesn't do much right now - it basically functions as a loader.
* This has been sort of replaced by the BGController class instead
* 
* loadBG
*/

package com.oddcast.workshop {
	import com.oddcast.utils.MoveZoomUtil;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import workshop.uploadphoto.BGMask;

	public class BGLoader extends Sprite implements IBGLoader {
		public var holder:Loader;
		private var curBG:WSBackgroundStruct;
		
		public function BGLoader() {
			holder=new Loader();
			holder.contentLoaderInfo.addEventListener(Event.INIT, bgLoaded, false, 0, true);
			holder.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError,false,0,true);
			holder.addEventListener(IOErrorEvent.IO_ERROR, onError,false,0,true);
			addChild(holder);
		}
		
		public function loadBG($bg:WSBackgroundStruct) {
			if ($bg == null) {
				try {
					curBG = null;
					holder.unload();
				}
				catch (e:Error) {
					onError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
				}				
			}
			else {
				try {
					holder.load(new URLRequest(bg.url));
					curBG = $bg;
				}
				catch (e:Error) {
					onError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
				}
			}
		}
		
		protected function onError(evt:ErrorEvent) {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,evt.text));
		}
		
		protected function bgLoaded(evt:Event) {
			dispatchEvent(evt);
		}
		
		public function setMask($mask:DisplayObject) {
			mask = $mask;
		}
		/*public function getMC():DisplayObject {
			return(holder.content);
		}*/
		public function get bg():WSBackgroundStruct {
			return(curBG);
		}
		public function get bgPosition():Matrix {
			return(holder.transform.matrix);
		}
		public function set bgPosition(m:Matrix) {
			holder.transform.matrix = m;
		}
	}
	
}