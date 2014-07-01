package code.controllers.bigshow
{
	
		

	import code.skeleton.App;
	
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.SceneStruct;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSBackgroundStruct;
	import com.oddcast.workshop.WSEventTracker;
	import com.oddcast.workshop.WorkshopMessage;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import org.casalib.util.ArrayUtil;
	import org.casalib.util.RatioUtil;
	
	public class BigShow
	{
		//[Embed(source="../../src/art/idle_vid01.swf")]
		//private var Idle:Class;
		private var ui						:BigShow_UI;
		private var _idleLoader				:*;
		private var _idle					:MovieClip;
		
		private var _currentDanceClip		:MovieClip;
		
		private var _heads					:Array;
		private var _mouths					:Array;
		private var _mask					:Sprite;
		
		private var _danceIndex				:Number = 0;
		
		protected var _looping				:Boolean = false;
		
		protected var _currentLoop			:Number;
		protected var _lastFrame			:Number;
		
		protected var _loops				:Array = [ "idle1", "idle2", "idle3" ];
		
		protected var _useOddIdleLoop		:Boolean;
		
		/*** USED FOR BIG SHOW ***/
		private var _inBigShow				:Boolean;
		
		private var mid_message				:WorkshopMessage;
		private var _gotoEditStateCallback	:Function;
		private var _photosToBeLoaded		:Array;
		
		private static const LOADING_HEADS	:String = "LOADING HEADS";
		private static const LOADING_DANCE	:String = "LOADING DANCE";
		
		private static const START_X:Number = 0;
		private static const START_Y:Number = 0;
		
		
		public function BigShow()
		{
			super();
		
			ui = App.ws_art.bigShow;
			
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			App.listener_manager.add(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE, in_editing_state, this);
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				// init this after the application has been inaugurated
				if(!_hasBeenInit) _init();
			}
			function in_editing_state(e:Event):void
			{				
				ui.visible = false;			
			}
			
		}
		
		protected var _hasBeenInit:Boolean;
	
		private function _init():void
		{
			_hasBeenInit = true;			
		}
			
		public function load_and_play_message( _mid:String, _edit_state_starter_callback:Function ):void
		{
			_inBigShow = true;
			if(!_hasBeenInit) _init();
			
			_gotoEditStateCallback = _edit_state_starter_callback;
			
			ui.btn_create_your_own.addEventListener(MouseEvent.CLICK, _onCreateYourOwnClicked)
				
			var doc_query	:String = ServerInfo.acceleratedURL + 'php/api/playScene/doorId=' + ServerInfo.door + '/clientId=' + ServerInfo.client + '/mId=' + _mid;
			Gateway.retrieve_XML( doc_query, new Callback_Struct( fin, null, error ) );
			App.localizer.localize(ui, "bigshow");
			function fin( _xml:XML ):void 
			{	
				mid_message = new WorkshopMessage( parseInt(_mid) );
				mid_message.parseXML( _xml);
				_danceIndex = parseFloat(mid_message.extraData.danceIndex) || 0;
				App.asset_bucket.mid_message = mid_message;
				
				_photosToBeLoaded = [];
					
				for(var i:Number = 0; i<mid_message.sceneArr.length; i++)
				{
					var scene:SceneStruct = mid_message.sceneArr[i];
					var image:WSBackgroundStruct = mid_message.sceneArr[i].bg as WSBackgroundStruct;
					if(image && image.url) 
					{
						var photo:Photo = new Photo(image.url,parseFloat(image.name));
						photo.addEventListener(Event.COMPLETE, _onPhotoLoaded);
						_photosToBeLoaded.push( photo );
					}
				}				
			}	
			function error( _msg:String ):void 
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "", _msg));
			}
		}
			
		protected function _onPhotoLoaded(e:Event):void
		{
			var photo:Photo = e.target as Photo;
			ArrayUtil.removeItem(_photosToBeLoaded, photo);
			
			var size:Rectangle = new Rectangle(0,0,photo.bitmap.width, photo.bitmap.height);
			var bounds:Rectangle = new Rectangle(0,0,ui.photo_hold.width,ui.photo_hold.height);
			size = RatioUtil.scaleToFill(size, bounds, true);
//			photo.bitmap.width =  size.height;
//			photo.bitmap.height =  size.height;
			
			if(ui.photo_hold.numChildren) ui.photo_hold.removeChildAt(0);
			ui.photo_hold.addChild(photo.bitmap);
			
			photo.destroy();
			
			App.ws_art.main_loader.visible = false;
		}
		
		protected function _onCreateYourOwnClicked(e:MouseEvent):void
		{
			WSEventTracker.event("gce3");
			
			_inBigShow = false;			
			ui.visible = false;
	
			App.asset_bucket.mid_message =  null;
			App.asset_bucket.last_mid_saved = null;
			
			_gotoEditStateCallback();			
		}
		
	}
}
import com.oddcast.utils.gateway.Gateway;
import com.oddcast.workshop.Callback_Struct;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.ProgressEvent;

import org.casalib.events.RemovableEventDispatcher;

class Photo extends RemovableEventDispatcher
{
	public function Photo( _url:String, _index:Number):void
	{
		index = _index;
		init(_url);
	}
	protected function init(url:String):void
	{
		Gateway.retrieve_Bitmap( url, new Callback_Struct(_imageLoaded));
	}
	private var _callback:Function;
	private function onLoadProgress(evt:ProgressEvent):void
	{
		trace("onLoadProgress - " + evt.bytesLoaded);
		var percent:Number = (evt.bytesTotal == 0)?0:(evt.bytesLoaded / evt.bytesTotal);
		//	dispatchEvent(new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.BG, percent));
	}
	protected function onError(evt:ErrorEvent):void {
		///	dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE, ProcessingEvent.BG));
		//	dispatchEvent(new AlertEvent(AlertEvent.ERROR, "f9tp311", "Could not load BG : "+evt.text));
	}
	protected function _imageLoaded(bmp:Bitmap):void
	{
		bitmap = new Bitmap(bmp.bitmapData, "auto", true);
		//_callback(bitmap, index);
		//bitmap = new Bitmap(((evt.target as LoaderInfo).content as Bitmap).bitmapData, "auto", true);
		dispatchEvent(new Event(Event.COMPLETE));
		
	}	
	private var _imgLoader:Loader;
	public var bitmap:Bitmap;
	public var index:Number;
}