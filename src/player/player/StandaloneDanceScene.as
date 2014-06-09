package player
{
	
	
	import com.greensock.TweenLite;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.VHSSEvent;
	import com.oddcast.utils.URL_Opener;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.SceneStruct;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSBackgroundStruct;
	import com.oddcast.workshop.WSEventTracker;
	import com.oddcast.workshop.WorkshopMessage;
	
	import custom.DancePlayback;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.System;
	import flash.utils.setTimeout;
	
	import org.casalib.layout.Distribution;
	import org.casalib.util.ArrayUtil;
	import org.casalib.util.RatioUtil;
	
	public class StandaloneDanceScene extends Sprite
	{
		//[Embed(source="../../src/art/idle_vid01.swf")]
		//private var Idle:Class;
		
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
		private var _headsToBeLoaded		:Array;
		
		private static const LOADING_HEADS	:String = "LOADING HEADS";
		private static const LOADING_DANCE	:String = "LOADING DANCE";
		
		private static const START_X:Number = 0;
		private static const START_Y:Number = 0;
	
		protected var _defaultHeads:Array;
		protected var _danceDefaultHeads:Array;
		protected var _placementRects:Array = [];
		
		public function StandaloneDanceScene()
		{
			super();
			App.scene = this;
		}
		
		
		protected var _playback:DancePlayback;
		protected var _hasBeenInit:Boolean;
		protected var _hold:Sprite;
		private function _init():void
		{
			
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			
			//make them all null so we can loop through later
			_heads = [null,null,null,null,null];
			_mouths = [null,null,null,null,null];
						
			_hold = new Sprite();
			this.addChild(_hold);
			
			/*_mask = new Sprite();
			_mask.graphics.beginFill(0,1);
			_mask.graphics.drawRect(0,0,674,440);
			_mask.graphics.endFill();
			this.addChild(_mask);
			_hold.mask = _mask;*/
			
			
			App.my_root.btn_play.visible= false;
			
			_hasBeenInit = true;
		
			App.my_root.btn_play.addEventListener(MouseEvent.CLICK, _onReplayClicked);
		}
		
		protected function _onMiscBtnClicked(e:MouseEvent):void
		{
			if(_playback) _playback.pause();
		}
		protected function _onPlayFromBeginningClicked(e:MouseEvent):void
		{
			if(_currentDanceClip)
			{
				_currentDanceClip.gotoAndPlay(2);
			}
		}
		
		protected function _onReplayClicked(e:MouseEvent):void
		{
			WSEventTracker.event("gce2");
			if(_currentDanceClip) 
			{
				if(_playback)
				{
					_playback.replay();
			//		_currentDanceClip.gotoAndPlay(1);
				}
				//if(_currentDanceClip.currentFrame >= _currentDanceClip.totalFrames-2) _currentDanceClip.gotoAndPlay(0);
				//else _currentDanceClip.play();
			}
			
			//App.ws_art.mainPlayer.btn_play.visible= false;
			App.my_root.btn_play.visible= false;
		}
		protected function _onDanceClicked(e:MouseEvent):void
		{
			//WSEventTracker.event("ce14");
			dance();
		}
		
		private function _makeDefaultHeads():void
		{
			_defaultHeads = [];
			if(_currentDanceClip == null){
				return;
			}
			for(var i:Number = 1; i<6; i++)
			{
				var h:MovieClip = _currentDanceClip.getChildByName("head"+String(i)) as MovieClip;
				var bmp:* = (h.getChildByName("face") as MovieClip).getChildAt(0);
				if(bmp) _makeDefaultHead(bmp);
			} 
			//App.ws_art.addChild(dist);
			
		}
		
		protected function _onEnterFrame(e:Event):void
		{
			if(_currentDanceClip == null) return;
			if(_currentDanceClip.currentFrame >= _currentDanceClip.totalFrames) _onDanceComplete();
		}
		
		public function dance():void
		{
			// check to see if the dance is loaded
			//if(!_checkIfLoaded()) return;
			if(_defaultHeads == null) _makeDefaultHeads();
		
			_looping = false;
			
			this.x = this.y = 0;
			
			/*if(_currentDanceClip != App.asset_bucket.danceScenes[_danceIndex]) 
			{
				if(_currentDanceClip)
				{
					_currentDanceClip.stop();
					SoundMixer.stopAll();
					_currentDanceClip.removeEventListener("swapHeads", _updateHeads);
					if(_hold.contains(_currentDanceClip)) _hold.removeChild(_currentDanceClip);
				}
				_currentDanceClip = App.asset_bucket.danceScenes[_danceIndex] ;
				_currentDanceClip.addEventListener("swapHeads", _updateHeads);
			}*/
			_hold.addChild(_currentDanceClip);
			if(!_inBigShow) _updateHeads();
			
			_currentDanceClip.visible = true;
			_currentDanceClip.gotoAndPlay(2);
//			_currentDanceClip.mask = _mask;
			if(_playback) _playback.destroy();
			
			_playback = new DancePlayback(_videoControls, _currentDanceClip);
			_playback.play();			
		}
		private static const DANCES_LOADED:String = "dancesLoaded";
		private var _prerollSwf:MovieClip;
		
		protected function _checkIfLoaded():Boolean
		{
			/*var boo:Boolean = true;
			boo = App.asset_bucket.danceScenes[_danceIndex];
			//if(boo) boo = App.asset_bucket.idleScenes[_danceIndex];
			
			if(!boo)
			{
				//App.mediator.addEventListener(App.mediator.EVENT_WORKSHOP_LOADED_DANCES, _onDancesLoaded);
				loadDance();
			}
			return boo;*/
			return true
		}

		protected function _onDanceComplete(e:Event = null):void
		{
			SoundMixer.stopAll();
					
			_playback.pause();
			_playback.forceShowControls();
			App.my_root.btn_play.visible= true;
			WSEventTracker.event('ae');
			//dispatchEvent(new VHSSEvent(VHSSEvent.SCENE_PLAYBACK_COMPLETE));
			//dispatchEvent(new VHSSEvent(VHSSEvent.AUDIO_ENDED));
			//dispatchEvent(new VHSSEvent(VHSSEvent.TALK_ENDED));
			
			// hack for recording
			//_currentDanceClip.gotoAndStop(_currentDanceClip.currentFrame-1);
			App.aps_transmitter.message_ended();
		}
		public function swapHead( bmp:Bitmap, index:Number, mouth:* = null):void
		{
			_heads[index] 		= bmp;
			var mouthBmp:Bitmap = mouth is Bitmap ? mouth : _makeMouth(bmp, mouth);
			_mouths[index] 		=  mouthBmp;
			mouthBmp = new Bitmap(mouthBmp.bitmapData, "auto", true);
			if(_currentDanceClip == null) return;
			if(_defaultHeads == null) _makeDefaultHeads();
			if(bmp.bitmapData) bmp = new Bitmap(bmp.bitmapData, "auto", true);
			var headSize	:Rectangle 	= RatioUtil.scaleToFill( new Rectangle(0,0,bmp.width, bmp.height), _placementRects[index]);
			
			if(_danceIndex == 0) bmp = _makeNoMouthFace(bmp, bmp.height - mouthBmp.height);
			
			//set size
			bmp.width 				= headSize.width;
			bmp.scaleY 				= bmp.scaleX;
			
			var headMC:MovieClip 	= _currentDanceClip.getChildByName("head"+(index+1)) as MovieClip;
			if(_currentDanceClip.getHeadByDepth is Function) 
				headMC 				= _currentDanceClip.getHeadByDepth(index);
			
			if(headMC && headMC.numChildren > 0)
			{
				var mouthMC	:MovieClip = headMC.getChildByName("mouth") as MovieClip;
				var faceMC	:MovieClip = headMC.getChildByName("face") as MovieClip;
				
				if(_danceIndex == 0)
				{
					mouthBmp.scaleX = bmp.scaleX;
					mouthBmp.scaleY = bmp.scaleY;
					mouthBmp.y 		= (bmp.height+bmp.y);
					
					if(mouthMC)
					{
						if(mouthMC.numChildren > 0)	mouthMC.removeChildAt( 0 );
						mouthMC.addChild( mouthBmp );
					}
					headMC.addChildAt(faceMC, 1);
				}
				
				if(faceMC)
				{
					if(faceMC.numChildren > 0) faceMC.removeChildAt( 0 );
					faceMC.addChild( bmp );
				}
			}
			return;
			
			
			
			//save it
			if(mouth)
			{
				if(mouth is Number)
				{
					mouth = _makeMouth(bmp, mouth);
				}
			}
			_heads[index] = bmp;
			_mouths[index] =  mouth;
			if(_currentDanceClip == null) return;
			if(_defaultHeads == null) _makeDefaultHeads();
			
			var defaultHead:Bitmap = _defaultHeads[index];
			var headSize:Rectangle 	= RatioUtil.scaleToFill( new Rectangle(0,0,bmp.width, bmp.height), _placementRects[index]);
			
			if(bmp is Bitmap) bmp = new Bitmap((bmp as Bitmap).bitmapData.clone(), "auto", true);
			/*
			// the original head from the idle swf
			if(_defaultHeads ) defaultHead = _defaultHeads[index]; 
			else if(_danceDefaultHeads) defaultHead = _danceDefaultHeads[index];
			
			*/
			// don't resize if it was an original
		
			//set size
			bmp.width 			= headSize.width;
			bmp.scaleY 			= bmp.scaleX;
			
			// center 
			/*bmp.x 				= -bmp.width/2;
			bmp.y 				= (-bmp.height/2)+12;*/
			
			// replace head in dance clip
			//if(_currentDanceClip) 	var head:MovieClip = _currentDanceClip.getChildByName("head"+String(index+1)) as MovieClip;
			//this is because they like to put stuff in weird order
			var faceOrder:Array = [5,4,3,2,1];
			if(_currentDanceClip) 	
			{
				var head:MovieClip = _currentDanceClip.getChildByName("head"+(index+1)) as MovieClip
				if(_currentDanceClip.getHeadByDepth is Function) head = _currentDanceClip.getHeadByDepth(index);
				
			}
			if(head && head.numChildren > 0)
			{
				if((head.getChildByName("face") as MovieClip))
				{
					(head.getChildByName("face") as MovieClip).removeChildAt( 0 );
					(head.getChildByName("face") as MovieClip).addChild( bmp );
				}else{
					
				}
			}
			if(mouth)
			{
				
			}
			
		}
		protected var _videoControls:VideoControls;
		
		public function track():void
		{
			var arr_transport_events:Array = [
				VHSSEvent.ACCESSORY_LOAD_ERROR,
				VHSSEvent.AI_RESPONSE,
				VHSSEvent.AUDIO_ENDED,
				VHSSEvent.AUDIO_ERROR,
				VHSSEvent.AUDIO_LOADED,
				VHSSEvent.AUDIO_PROGRESS,
				VHSSEvent.AUDIO_STARTED,
				VHSSEvent.BG_LOADED,
				VHSSEvent.CONFIG_DONE,
				VHSSEvent.ENGINE_LOADED,
				VHSSEvent.MODEL_LOAD_ERROR,
				VHSSEvent.PLAYER_DATA_ERROR,
				VHSSEvent.PLAYER_READY,
				VHSSEvent.PLAYER_XML_ERROR,
				VHSSEvent.SCENE_LOADED,
				VHSSEvent.SCENE_PLAYBACK_COMPLETE,
				VHSSEvent.SCENE_PRELOADED,
				VHSSEvent.SKIN_LOADED,
				VHSSEvent.TALK_ENDED,
				VHSSEvent.TALK_STARTED,
				VHSSEvent.TTS_LOADED
			];
		}
		public function play_message( ):void
		{
			_inBigShow = true;
			if(!_hasBeenInit) _init();
			
			_videoControls = App.controls;
			_videoControls.visible = false;
			_videoControls.alpha = 0;
			App.my_root.create_your_own.addEventListener(MouseEvent.CLICK, _onCreateYourOwnClicked)
			
			
			_currentDanceClip = App.dance_swf;
			_currentDanceClip.stop();
			_currentDanceClip.addEventListener("swapHeads", _updateHeads);
			
			_prerollSwf = App.preroll_swf;
			_prerollSwf.stop();
			
			/*
			_defaultHeads = [];
			for(var i:Number = 1; i<6; i++)
			{
			var h:MovieClip = _currentDanceClip.getChildByName("head_"+String(i)) as MovieClip;
			var bmp:* = h.getChildAt(0);
			_makeDefaultHead(bmp);
			
			}*/
			_makeDefaultHeads();
			_headsToBeLoaded = [];
			//App.mediator.processing_start(LOADING_HEADS);
			mid_message = App.message_data;
			for(var i:Number = 0; i<mid_message.sceneArr.length; i++)
			{
				var scene:SceneStruct = mid_message.sceneArr[i];
				var image:WSBackgroundStruct = mid_message.sceneArr[i].bg as WSBackgroundStruct;
				if(image && image.url) 
				{
					var cutPoint:Number = parseFloat(mid_message.extraData['mouthCutPoint_'+parseFloat(image.name)]);
					var head:Head = new Head(image.url,parseFloat(image.name), cutPoint);
					head.addEventListener(Event.COMPLETE, _onHeadLoaded);
					_headsToBeLoaded.push( head );
				}
			}
			_danceIndex = parseFloat(mid_message.extraData.danceIndex);
			_startPreroll();
		}
		
		private function _onHoldClicked(e:MouseEvent):void
		{
			if(_inBigShow && !_looping)
			{
				//App.ws_art.mainPlayer.btn_replay.visible 	= true;
				if(_currentDanceClip) _currentDanceClip.gotoAndStop(1);
				SoundMixer.stopAll();
			}
		}
		private function _onBigDanceLoaded( l:Loader ):void
		{
			WSEventTracker.event("ev");
			WSEventTracker.event("pb", String(mid_message.mid));
		
			_currentDanceClip = (l).content as MovieClip;
			_currentDanceClip.stop();
			_currentDanceClip.addEventListener("swapHeads", _updateHeads);
			/*
			_defaultHeads = [];
			for(var i:Number = 1; i<6; i++)
			{
				var h:MovieClip = _currentDanceClip.getChildByName("head_"+String(i)) as MovieClip;
				var bmp:* = h.getChildAt(0);
				_makeDefaultHead(bmp);
				
			}*/
			_makeDefaultHeads();
			_headsToBeLoaded = [];
			//App.mediator.processing_start(LOADING_HEADS);
			
			for(var i:Number = 0; i<mid_message.sceneArr.length; i++)
			{
				var scene:SceneStruct = mid_message.sceneArr[i];
				var image:WSBackgroundStruct = mid_message.sceneArr[i].bg as WSBackgroundStruct;
				if(image && image.url) 
				{
					var cutPoint:Number = parseFloat(mid_message.extraData['mouthCutPoint_'+parseFloat(image.name)]);
					var head:Head = new Head(image.url,parseFloat(image.name), cutPoint);
					head.addEventListener(Event.COMPLETE, _onHeadLoaded);
					_headsToBeLoaded.push( head );
				}
			}

			//_startBigShow();
			
		}
		public function stop():void
		{			
			SoundMixer.stopAll();
			if(_currentDanceClip) _currentDanceClip.gotoAndStop(2);
		}
		protected function _startPreroll():void
		{
			if(_headsToBeLoaded.length < 1 && _currentDanceClip)
			{
				App.my_root.visible = true;
				//App.ws_art.bigShow.visible = true;
				//App.mediator.workshop_finished_loading_playback_state();
				_looping = false;
				//App.ws_art.bigShow.video_controls.visible = false;
				_hold.addChild(_prerollSwf);
				
				var _loaderInfo:LoaderInfo = App.my_root.loaderInfo;
				if(_loaderInfo)
				{
					if(_loaderInfo.parameters.video_export == 'true')
					{
						_prepareVideoExport();
					}
				}
				App.aps_transmitter.message_loaded();
				
				
				_prerollSwf.visible = true;
				_prerollSwf.gotoAndPlay(2);
				_prerollSwf.addEventListener(Event.ENTER_FRAME, _onPrerollEventFrame);
			}
		}
		protected function _onPrerollEventFrame(e:Event):void
		{
			if(_prerollSwf.currentFrame >= _prerollSwf.totalFrames)
			{
				_prerollSwf.removeEventListener(Event.ENTER_FRAME, _onPrerollEventFrame);
				
				_prerollSwf.stop();
				_startBigShow()
			}
		}
		
		protected function _startBigShow():void
		{
			if(_headsToBeLoaded.length < 1 && _currentDanceClip)
			{
				//_prepareVideoExport();
				
				_looping = false;
				
				_playback = new DancePlayback(_videoControls, _currentDanceClip);
				
				_hold.addChild(_currentDanceClip);
				
				_currentDanceClip.visible = true;
				_currentDanceClip.gotoAndPlay(2);
				//dumb but he sometimes puts stop in there;
				_playback.play();
			}
		}
		
		protected function _prepareVideoExport():void
		{
			for(var i:Number = 0; i<App.my_root.numChildren; i++)
			{
				App.my_root.getChildAt(i).visible = false;
			}
			App.my_root.addChild(_hold);
			_hold.x=0;
			_hold.y=0;
		
			_mask = new Sprite();
			_mask.graphics.beginFill(0,1);
			_mask.graphics.drawRect(0,0,674,440);
			_mask.graphics.endFill();
			App.my_root.addChild(_mask);
			_hold.mask = _mask;
			
			
			var s:Stage = App.my_root.stage;
			if(s)
			{
				s.scaleMode = StageScaleMode.NO_SCALE;
				
				//s.addChild(_currentDanceClip);
				_currentDanceClip.scaleX = s.stageWidth/546;
				_currentDanceClip.scaleY = s.stageHeight/307;
			}
			
			
		}
		protected function _onCreateYourOwnClicked(e:MouseEvent):void
		{
			if(_playback) _playback.pause();
			var negative_mid:String = App.message_data.mid + '.4';// negative to indicate that the workshop was opened from this mid
			var pickup_url:String = ServerInfo.pickup_url.split("https:").join("http:"); //+ '?mId=' + negative_mid;
			URL_Opener.open_url( pickup_url );
			App.alert.alert_user( new AlertEvent( AlertEvent.CONFIRM, '', Alert.MSG_BLOCKED_LINK + pickup_url, null, user_responded ))
			WSEventTracker.event("ce1");
			function user_responded( _ok:Boolean ):void 
			{
				if (_ok)
				{
					try 
					{	System.setClipboard( pickup_url );	}
					catch (e:Error)
					{	App.alert.alert_user( new AlertEvent( AlertEvent.CONFIRM, '', Alert.MSG_CLIPBOARD_ERROR ));	}
				}
			}
			
		}
		protected function _onHeadLoaded(e:Event):void
		{
			var head:Head = e.target as Head;
			ArrayUtil.removeItem(_headsToBeLoaded, head);
			swapHead( head.bitmap, head.index, head.mouthCutPoint );
			
			if(_headsToBeLoaded.length == 0) 
			{	
				_startPreroll();
				//App.mediator.processing_ended(LOADING_HEADS);
			}
			
			head.destroy();
		}
		protected function _makeMouth(face:Bitmap, mouthCutPoint:Number):Bitmap
		{
			var data:BitmapData = new BitmapData(face.width, face.height-mouthCutPoint, true, 0x0000000);
			var mat:Matrix = new Matrix();
			
			var rect:Rectangle = new Rectangle(0,mouthCutPoint,face.width,face.height-mouthCutPoint);
			mat.translate( -rect.x, -rect.y);
			
			data.draw(face, mat);
			
			return new Bitmap(data, "auto", true);
		}
		
		protected function _makeNoMouthFace(face:Bitmap, mouthCutPoint:Number):Bitmap
		{
			var data:BitmapData = new BitmapData(face.width, mouthCutPoint, true, 0x0000000);
			var mat:Matrix = new Matrix();
			data.draw(face);//, mat);
			return new Bitmap(data, "auto", true);
		}
		/**
		 * 
		 * @param e
		 * 
		 */
		protected function _updateHeads(e:Event = null):void
		{
			/*for( var i:Number = 0; i< heads.length; i++)
			{	
				if(heads[i] != null) swapHead(heads[i], i, _mouths[i]);
			}*/
			var dup:Number = 0;
			for( var i:Number = 0; i< 5; i++)
			{	
				var head:* = heads[i];
				var mouth:* = _mouths[i];
				if(head == null) 
				{
					if(_danceIndex != 0)
					{
						if(dup > heads.length-1) dup = 0;
						head = heads[dup];
						mouth = _mouths[dup];
						dup++;
					}
				}
				if(head != null) swapHead(head, i, mouth);
			}
			return;
			var dup:Number = 0;
			for( var i:Number = 0; i< 5; i++)
			{	
				var head:* = heads[i];
				if(head == null) 
				{
					if(dup > heads.length-1) dup = 0;
					head = heads[dup];
					dup++;
				}
				swapHead(head, i, _mouths[i]);
			}
		}
		public function set danceIndex(value:Number):void
		{
			_danceIndex = value;
			
			//might need error checking or something here
			/*if(App.asset_bucket.danceScenes[value]) _currentDanceClip = App.asset_bucket.danceScenes[value];
			if(App.asset_bucket.idleScenes[value]) 	_idle = App.asset_bucket.idleScenes[value];*/
			
			_updateHeads();
		}
		public function get heads():Array
		{
			return _heads;
		}

		public function set heads(value:Array):void
		{
			_heads = value;
		}

		public function get danceIndex():Number
		{
			return _danceIndex;
		}

		
		private function _makeDefaultHead( obj:DisplayObject ):Bitmap
		{
			_placementRects.push(new Rectangle( obj.x, obj.y, obj.width, obj.height ));
			var data	:BitmapData = new BitmapData(obj.width, obj.height, true, 0x0000000);
			var mat		:Matrix = new Matrix();
			var rect	:Rectangle = (obj).getBounds( obj.parent );
			mat.translate( -rect.x, -rect.y);
			data.draw(obj, mat);
			var bmp:Bitmap =  new Bitmap( data, "auto", true );
			_defaultHeads.push(bmp);
			return bmp;
		}
		
		
		
		
		
		
		
	}
}
import com.oddcast.utils.gateway.Gateway;
import com.oddcast.workshop.Callback_Struct;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import org.casalib.events.RemovableEventDispatcher;

class Head extends RemovableEventDispatcher
{
	public function Head( _url:String, _index:Number, _mouthCutPoint:Number):void
	{
		index = _index;
		mouthCutPoint = _mouthCutPoint;
		//_callback = callback;
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
	public var mouthCutPoint:Number;
	private var _imgLoader:Loader;
	public var bitmap:Bitmap;
	public var index:Number;
}