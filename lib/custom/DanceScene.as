package custom
{
	import code.skeleton.App;
	
	import com.greensock.TweenLite;
	import com.oddcast.ai.tts2animation.Key;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.SceneStruct;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSBackgroundStruct;
	import com.oddcast.workshop.WSEventTracker;
	import com.oddcast.workshop.WorkshopMessage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.setTimeout;
	
	import mx.core.MovieClipLoaderAsset;
	
	import org.casalib.layout.Distribution;
	import org.casalib.util.ArrayUtil;
	import org.casalib.util.RatioUtil;
	
	public class DanceScene extends Sprite
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
		
		
		public function DanceScene()
		{
			super();
			
			x  = START_X;
			y = START_Y;
			App.ws_art.bigShow.visible = false;
			
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			App.listener_manager.add(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE, in_editing_state, this);
			App.ws_art.mainPlayer.visible 		= false;
			App.ws_art.printProcessing.visible 	= false;
			App.ws_art.printReady.visible 		= false;
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
				return;
				//_idle = App.asset_bucket.idleScenes[_danceIndex];
				danceIndex = START_DANCE_INDEX;
				if(App.asset_bucket.danceScenes[0]) _currentDanceClip = App.asset_bucket.danceScenes[0];
				var danceScenes:Array = App.asset_bucket.danceScenes;
				// don't know when this would be called...
				
				
				_videoControls = App.ws_art.mainPlayer.video_controls;
				App.ws_art.mainPlayer.player_hold.addChild(_hold.parent);
			
				App.ws_art.bigShow.visible = false;
				
				//loop();
				//setTimeout(chooseOddLoopNext, 7000+(Math.random()*8000));
			}

		}
		protected var _playback:DancePlayback;
		protected var _hasBeenInit:Boolean;
		protected var _hold:Sprite;
		private function _init():void
		{
			return;
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			
			//make them all null so we can loop through later
			_heads = []//null,null,null,null,null];
			_mouths = []//null,null,null,null,null];
			
			//_idleLoader = new Idle();
			//_idleLoader.addEventListener(Event.COMPLETE, _onIdleSwfLoaded);
			
			App.ws_art.dance_Btn.addEventListener(MouseEvent.CLICK, _onDanceClicked);
			
			_hold = new Sprite();
			this.addChild(_hold);
			
			_mask = new Sprite();
			_mask.graphics.beginFill(0,1);
			_mask.graphics.drawRect(0,0,674,440);
			_mask.graphics.endFill();
			this.addChild(_mask);
			_hold.mask = _mask;
			
			App.ws_art.stop_btn.visible = false;
			App.ws_art.mainPlayer.visible = false;
			//App.ws_art.mainPlayer.btn_play.visible= false;
			//App.ws_art.bigShow.btn_play.visible= false;
			
			_hasBeenInit = true;
			
			App.listener_manager.add_multiple_by_object(  [App.ws_art.mainPlayer.btn_play,
															App.ws_art.bigShow.btn_play,
															App.ws_art.mainPlayer.end_screen.btn_replay], MouseEvent.CLICK, _onReplayClicked, this );
			
			App.ws_art.mainPlayer.btn_create_another.addEventListener(MouseEvent.CLICK, _onCreateAnotherClicked);
			
			_danceButtons = [App.ws_art.mainPlayer.btn_dance1,
								App.ws_art.mainPlayer.btn_dance2,
								App.ws_art.mainPlayer.btn_dance3,
								App.ws_art.mainPlayer.btn_dance4,
								App.ws_art.mainPlayer.btn_dance5];
			App.listener_manager.add_multiple_by_object(  _danceButtons, MouseEvent.CLICK, _onDanceBtnClicked, this );
			App.ws_art.makeAnother.btn_select_a_dance.addEventListener(MouseEvent.CLICK, _onSelectADanceClicked);
			
			var art:MainPlayerHolder = App.ws_art.mainPlayer;
			//App.listener_manager.add_multiple_by_object(  [/*art.facebook_btn, */art.btn_dance2, art.btn_calendar, art.btn_dance1, art.btn_merch], MouseEvent.CLICK, _comingSoon, this );
			App.listener_manager.add_multiple_by_object(  [art.btn_create_another, 
															art.btn_merch, 
															art.btn_storedownload,
															art.email_btn,
															art.get_url_btn,
															art.facebook_btn,
															art.twitter_btn,
															art.embed_btn, art.btn_calendar], MouseEvent.CLICK, _onMiscBtnClicked, this );
			art.btn_calendar.addEventListener(MouseEvent.CLICK, _onCalendarClick);
			art.btn_merch.addEventListener(MouseEvent.CLICK, _onShopClick);
			//App.ws_art.mainPlayer.btn_reset.addEventListener(MouseEvent.CLICK, _onPlayFromBeginningClicked);
			App.ws_art.stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyPress);
			App.ws_art.stage.addEventListener(KeyboardEvent.KEY_UP	, _onKeyUp);
		}
		protected var _sPressed:Boolean;
		
		protected function _onKeyPress(e:KeyboardEvent):void
		{
			if(e.charCode == 115)
			{
				_sPressed = true;
			}
			
		}
		protected function _onKeyUp(e:KeyboardEvent):void
		{
			_sPressed = false;
		}
		protected function _comingSoon(e:MouseEvent):void
		{
			if(_playback) _playback.pause();
			App.ws_art.comingSoon.visible = true;
		}
		protected function _onDownloadClick(e:MouseEvent = null):void
		{
			//http://host.oddcast.com/api_misc/1083/checkout.php&mId={mid}&email={email}&optin={optin 0/1}
			//"http://host.oddcast.com/api_misc/1083/checkout.php&mId="+mID+"&email="+email+"&optin="{optin 0/1}";
			
		}
		protected function _onCalendarClick(e:MouseEvent):void
		{
			WSEventTracker.event("ce16");	
			_getCalendar();
			return;
			if(_sPressed)
			{
				_getCalendar();				
			}else{
				App.ws_art.comingSoon.visible = true;
			}
		}
		protected function _onShopClick(e:MouseEvent):void
		{
			WSEventTracker.event("ce15");
			_getCalendar();
			return;
			if(_sPressed)
			{
				_getCalendar();				
			}else{
				App.ws_art.comingSoon.visible = true;
			}
		}
		protected function _getCalendar():void
		{
			// will manage and destroy itself
			new DanceScreenShot(this._heads, this._mouths);
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
		
		protected static const START_DANCE_INDEX:Number = 0;
		protected function _onCreateAnotherClicked(e:MouseEvent):void
		{
			_currentDanceClip.stop();
			SoundMixer.stopAll();
			
			function startOver(_ok:Boolean):void
			{
				if(!_ok) return;
				_danceIndex = START_DANCE_INDEX;
				App.ws_art.stop_btn.visible 	= false;
				App.ws_art.mainPlayer.visible 	= false;
				App.mediator.clearHeads();
				heads = [];
				App.asset_bucket.danceScenes = [];
				App.mediator.autophoto_open_mode_selector();
			}
			App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "startOver", "Are you sure you want to discard your video and start over?", null, startOver));			
			
		}
		protected function _onSelectADanceClicked(e:MouseEvent):void
		{
			//App.ws_art.mainPlayer.visible = false;
			App.ws_art.makeAnother.visible = false;
			//App.ws_art.dancers.visible = false;
			
			dance();
		}
		
		protected function _updateDanceButtons():void
		{
			var art:MainPlayerHolder = App.ws_art.mainPlayer;
			var overs:Array = [art.btn_dance1_over, art.btn_dance2_over, art.btn_dance3_over, art.btn_dance4_over, art.btn_dance5_over];
			var btns:Array = [art.btn_dance1, art.btn_dance2, art.btn_dance3, art.btn_dance4, art.btn_dance5];
			
			for(var i:Number = 0; i<overs.length; i++)
			{
				if(i == danceIndex)
				{
					overs[i].visible = true;
					_danceButtons[i].visible = false;
				}else
				{
					overs[i].visible = false;
					_danceButtons[i].visible = true;
				}
			}
		}
		protected var _danceButtons:Array;
		protected function _onDanceBtnClicked(e:MouseEvent):void
		{
			/*if(_danceButtons.indexOf(e.target) == 0 ){
				if(!_sPressed)
				{				
					if(_playback) _playback.pause();
					App.ws_art.comingSoon.visible = true;
					return
				}
			}*/
			if(_danceButtons.indexOf(e.target) != danceIndex) App.asset_bucket.last_mid_saved = null;
			_danceIndex = _danceButtons.indexOf(e.target); 
			
			WSEventTracker.event("ce"+(4+danceIndex));
			
			loadDance();
			
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
			App.ws_art.mainPlayer.end_screen.visible = false;
			App.ws_art.mainPlayer.btn_play.visible= false;
			App.ws_art.bigShow.btn_play.visible= false;
		}
		protected function _onDanceClicked(e:MouseEvent):void
		{
			//WSEventTracker.event("ce14");		
			loadDance();
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
				if(h) var bmp:* = (h.getChildByName("face") as MovieClip).getChildAt(0);
				if(bmp) _makeDefaultHead(bmp);
			}
			//App.ws_art.addChild(dist);
			App.mediator.autophoto_set_persistant_images( _defaultHeads );
		}
		protected function _onEnterFrame(e:Event):void
		{
			if(_currentDanceClip == null) return;
			if(_currentDanceClip) 	
			{
				for(var i:Number = 0; i<5; i++)
				{
					var head:MovieClip = _currentDanceClip.getHeadByDepth(i);
					if(head) head.gotoAndStop(_currentDanceClip.currentFrame);
				}
				_updateHeads();
				
			}
			if(_currentDanceClip.currentFrame >= _currentDanceClip.totalFrames) _onDanceComplete();
		}
		
		public function dance():void
		{
			// check to see if the dance is loaded
			App.ws_art.mainPlayer.end_screen.visible = false;
			if(!_checkIfLoaded()) return;
			if(_defaultHeads == null) _makeDefaultHeads();
			if(App.ws_art.mainPlayer.end_screen.visible)
			{
				App.ws_art.mainPlayer.end_screen.visible = false;
				App.ws_art.mainPlayer.end_screen.alpha = 0;
			}
			
			_looping = false;
			App.ws_art.mainPlayer.btn_play.visible= false;
			App.ws_art.mainPlayer.visible 	= !_inBigShow;
			
			this.x = this.y = 0;
		
			_hold.addChild(_currentDanceClip);
			if(!_inBigShow) _updateHeads();
			
			_currentDanceClip.visible = true;
			_currentDanceClip.gotoAndPlay(2);

			if(_playback) _playback.destroy();
			_playback = new DancePlayback(_videoControls, _currentDanceClip);
			_playback.play();			
		}
		public static const DANCES_LOADED:String = "dancesLoaded";
		protected function _checkIfLoaded():Boolean
		{
			var boo:Boolean = true;
			boo = App.asset_bucket.danceScenes[_danceIndex];
			//if(boo) boo = App.asset_bucket.idleScenes[_danceIndex];
			
			if(!boo)
			{
				//App.mediator.addEventListener(App.mediator.EVENT_WORKSHOP_LOADED_DANCES, _onDancesLoaded);
				loadDance();
			}
			return boo;
		}
		private function loadDance():void
		{
			if(_currentDanceClip)
			{
				_currentDanceClip.stop();
				SoundMixer.stopAll();
				_currentDanceClip.removeEventListener("swapHeads", _updateHeads);
				if(_hold.contains(_currentDanceClip)) _hold.removeChild(_currentDanceClip);
				_currentDanceClip = null;
			}
			var transform:SoundTransform = new SoundTransform(0);
			SoundMixer.soundTransform = transform;	
			var headCount:Number = 0;
			for(var i:Number = 0; i<App.mediator.savedHeads.length; i++)
			{
				if(App.mediator.savedHeads[i] != null) headCount++;
			}
			var dances:Array = ["Classic","Soul","Hip_Hop","80s","Charleston"];
			var swfURL:String = ServerInfo.content_url_door + "misc/"+dances[_danceIndex]+"_"+headCount+".swf";
			Gateway.retrieve_Loader( new Gateway_Request(swfURL, new Callback_Struct( fin ) ) );
			App.mediator.processing_start(DANCES_LOADED, null, -1, -1, true);
			_updateDanceButtons();
			function fin(l:Loader):void
			{
				(l.content as MovieClip).stop();
				SoundMixer.stopAll();
				App.asset_bucket.danceScenes[_danceIndex] = (l.content as MovieClip);
				_currentDanceClip = (l.content as MovieClip);
				
				_currentDanceClip.addEventListener("swapHeads", _updateHeads);
				
				App.mediator.processing_ended(DANCES_LOADED);
				if(_defaultHeads == null) _makeDefaultHeads();
				
				var transform:SoundTransform = new SoundTransform(1);
				SoundMixer.soundTransform = transform;	
				dance();	
				
			}
		}
		
		
		protected function _onDanceComplete(e:Event = null):void
		{
			SoundMixer.stopAll();
			
			if(_inBigShow) 
			{
				_playback.pause();
				_playback.forceShowControls();
				App.ws_art.bigShow.btn_play.visible= true;
				WSEventTracker.event('ae');
			}else
			{
				
				TweenLite.to(App.ws_art.mainPlayer.end_screen, .4, {alpha:1, visible:true});
				//App.ws_art.mainPlayer.btn_play.visible= true;
				_currentDanceClip.gotoAndStop(2);
				_playback.pause();
				//App.ws_art.upload_btns.visible = true;
				///App.ws_art.dance_Btn.visible = true;
				//App.ws_art.stop_btn.visible = false;
				//loop();
			}
		}
		protected function _updateHeads(e:Event = null):void
		{
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
					//faceMC.scaleX = faceMC.scaleY = mouthMC.scaleX;
				}
				
				if(faceMC)
				{
					if(faceMC.numChildren > 0) faceMC.removeChildAt( 0 );
					faceMC.addChild( bmp );
				}
			}
					
		}
		protected var _videoControls:VideoControls_UI;
		public function load_and_play_message( _mid:String, _edit_state_starter_callback:Function ):void
		{
			_inBigShow = true;
			if(!_hasBeenInit) _init();
			
			_gotoEditStateCallback = _edit_state_starter_callback;
			//x = 23;
			//y = 137;
			_videoControls = App.ws_art.bigShow.video_controls;
			App.ws_art.bigShow.player_hold.addChild(this);
			
			App.ws_art.upload_btns.visible 	= false;
			App.ws_art.dance_Btn.visible 	= false;
			App.ws_art.bigShow.btn_create_your_own.addEventListener(MouseEvent.CLICK, _onCreateYourOwnClicked)
			
			App.ws_art.mainPlayer.visible 	= false;
			
			
			/*this._hold.addEventListener(MouseEvent.CLICK, _onHoldClicked);
			this._hold.buttonMode = true;*/

			var doc_query	:String = ServerInfo.acceleratedURL + 'php/api/playScene/doorId=' + ServerInfo.door + '/clientId=' + ServerInfo.client + '/mId=' + _mid;
			Gateway.retrieve_XML( doc_query, new Callback_Struct( fin, null, error ) );
			
			function fin( _xml:XML ):void 
			{	
				mid_message = new WorkshopMessage( parseInt(_mid) );
				mid_message.parseXML( _xml);
				_danceIndex = parseFloat(mid_message.extraData.danceIndex) || 0;
				App.asset_bucket.mid_message = mid_message;
				
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
				
				
				
				var swfURL:String = ServerInfo.content_url_door + "misc/preroll.swf";
				
				//var swfURL:String = ServerInfo.content_url_door + "misc/dancing_vid0"+String(_danceIndex+1)+".swf";
				Gateway.retrieve_Loader( new Gateway_Request(swfURL, new Callback_Struct( _onPrerollLoaded ) ) );
				
				
			}	
			function error( _msg:String ):void 
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT, "", _msg));
			}
		}
		private var _prerollSwf:MovieClip;
		
		private function _onPrerollLoaded(l:Loader):void
		{
			
			_prerollSwf = (l).content as MovieClip;
			_prerollSwf.stop();
			
			var dances:Array = ["Classic","Soul","Hip_Hop","80s","Charleston"];
			var swfURL:String = ServerInfo.content_url_door + "misc/"+dances[_danceIndex]+"_"+_headsToBeLoaded.length+".swf";
			
			//var swfURL:String = ServerInfo.content_url_door + "misc/dancing_vid0"+String(_danceIndex+1)+".swf";
			Gateway.retrieve_Loader( new Gateway_Request(swfURL, new Callback_Struct( _onBigDanceLoaded ) ) );
		}
		private function _onHoldClicked(e:MouseEvent):void
		{
			if(_inBigShow && !_looping)
			{
				App.ws_art.mainPlayer.btn_replay.visible 	= true;
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
			

			if(_headsToBeLoaded.length == 0) _startPreroll();
			
		}
		protected function _startPreroll():void
		{
			if(_headsToBeLoaded.length < 1 && _currentDanceClip)
			{
				App.ws_art.bigShow.visible = true;
				App.mediator.workshop_finished_loading_playback_state();
				_looping = false;
				App.ws_art.bigShow.video_controls.visible = false;
				_hold.addChild(_prerollSwf);
				_prerollSwf.visible = true;
				_prerollSwf.gotoAndPlay(2);
				_prerollSwf.addEventListener(Event.ENTER_FRAME, _onPrerollEventFrame);
			}
		}
		public function stop():void
		{
			App.ws_art.stop_btn.visible 	= false;
			
			SoundMixer.stopAll();
			if(_currentDanceClip) _currentDanceClip.gotoAndStop(2);
		}
		
		protected function _startBigShow():void
		{
			if(_headsToBeLoaded.length < 1 && _currentDanceClip)
			{
				_playback = new DancePlayback(_videoControls, _currentDanceClip);
				
				_hold.addChild(_currentDanceClip);
				
				_currentDanceClip.visible = true;
				_currentDanceClip.gotoAndPlay(2);
				//dumb but he sometimes puts stop in there;
				_playback.play();
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
		protected function _onCreateYourOwnClicked(e:MouseEvent):void
		{
			WSEventTracker.event("gce3");
			
			_inBigShow = false;
			App.ws_art.mainPlayer.visible = false;
			App.ws_art.bigShow.visible = false;
			App.asset_bucket.danceScenes = [];
			_heads = [];
			
			App.asset_bucket.mid_message =  null;
			App.asset_bucket.last_mid_saved = null;
			
			if(_currentDanceClip) _currentDanceClip.gotoAndStop(2);
			if(_playback) _playback.destroy();
			
			_gotoEditStateCallback();
			
			this._hold.buttonMode = false;
			this._hold.removeEventListener(MouseEvent.CLICK, _onHoldClicked);
		}
		protected function _onHeadLoaded(e:Event):void
		{
			var head:Head = e.target as Head;
			ArrayUtil.removeItem(_headsToBeLoaded, head);
			swapHead( head.bitmap, head.index, head.mouthCutPoint );
			
			if(_headsToBeLoaded.length == 0 && _currentDanceClip != null) 
			{	
				//_startBigShow();
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
		public function set danceIndex(value:Number):void
		{
			_danceIndex = value;
			
			//might need error checking or something here
			if(App.asset_bucket.danceScenes[value]) _currentDanceClip = App.asset_bucket.danceScenes[value];
			if(App.asset_bucket.idleScenes[value]) 	_idle = App.asset_bucket.idleScenes[value];
			
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

		protected var _defaultHeads:Array;
		protected var _danceDefaultHeads:Array;
		protected var _placementRects:Array = [];
		
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