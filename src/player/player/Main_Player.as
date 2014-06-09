package player 
{
	import com.oddcast.event.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.ui.*;
	import flash.utils.setTimeout;

	/**
	 * ...
	 * @author Me^
	 */
	public class Main_Player extends MovieClip
	{
		
		public function Main_Player() 
		{
			//trace("MAIN PLAYER _____ "+loaderInfo.url);
			Security.allowDomain("*");
			
			
			/* if (this.loaderInfo.url == null)
			{
				this.addEventListener(Event.COMPLETE, onInit);
			}
			else 
			{ */
				onInit();
			/* } */
				
		}
		public var btn_play:SimpleButton;
		public var create_your_own:SimpleButton;
		private function onInit(e:Event = null):void
		{
			trace("MAIN PLAYER _____ INIT");
			this.removeEventListener(Event.COMPLETE, onInit);
			App.my_root = this;
			App.aps_transmitter.init( loaderInfo );
			
			if (stage)
			{
				stage.stageFocusRect = false;
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode =  StageScaleMode.SHOW_ALL;
				//stage.scaleMode = StageScaleMode.NO_SCALE;
				if(loaderInfo) {
					if(loaderInfo.parameters.video_export == 'true')
					{
						stage.scaleMode = StageScaleMode.NO_SCALE;
					}

				}
				stageInit();
			}else
			{
				addEventListener(Event.ADDED_TO_STAGE, stageInit);
			}
			function stageInit(e:Event = null):void
			{
				stage.stageFocusRect = false;
				stage.align = StageAlign.TOP_LEFT;
				var s:Stage = App.my_root.stage;
				//s.scaleMode = StageScaleMode.NO_SCALE;
				s.align = StageAlign.TOP_LEFT;
				s.addEventListener(Event.RESIZE, _onStageResize);
				_onStageResize();
				
				
				removeEventListener(Event.ADDED_TO_STAGE, stageInit);
			}
			App.loader.open_win();
			new Inauguration( 	loaderInfo,
								this,
								everything_ready );
			
			
			
			function everything_ready(  ):void 
			{
				
				App.loader.close_win();
				//App.controls.init();
				App.tracking_manager.track_event( Tracking_Manager.EVENT_EVERYTHING_LOADED, App.message_data.mid.toString() );
				App.tracking_manager.track_event( Tracking_Manager.EVENT_SPECIFIC_SCENE, App.message_data.mid.toString() );
				//App.holder_avatar.addChild( App.vhss_player.getHostHolder() );	// place VHOST
				//App.holder_bg.addChild( App.vhss_player.getBGHolder() );		// place Background
				//App.controls.play_message();
				
				App.scene.play_message();
				//App.aps_transmitter.message_loaded();
			}
		}
		
		protected function _onStageResize(e:Event = null):void
		{
			var s:Stage = stage;
			
			var offset:Number = 116;
			// hack for facebook
			if(s.stageHeight < 230)
			{
				stage.scaleMode = StageScaleMode.NO_BORDER;
				for(var i:Number = 0; i < App.my_root.numChildren; i++)
				{
					App.my_root.getChildAt(i).y -= offset;
					// fix logo
					if(App.my_root.getChildAt(i) is Processing)
					{
						(App.my_root.getChildAt(i) as Processing).y += offset/2;
						(App.my_root.getChildAt(i) as Processing).getChildAt(0).y += 10;
					}
				}
				s.removeEventListener(Event.RESIZE, _onStageResize);
			}
		}
		private var _danceScene:StandaloneDanceScene;
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ************************ AIR INTERFACE FOR VIDEO CAPTURE ******/
		
		/* public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			trace("Main Player --- overriden addEventListener ");
			Bridge.listener_manager.add(Bridge.vhss_player, type, listener, this);
		} */
		/* 
		private function onDispatchEvent(event:*):void
		{
			this.dispatchEvent(event as Event);
		} */
		public function setPlayerInitFlags(flags:int):void
		{
			App.vhss_player.setPlayerInitFlags(flags);
		}
		
		public function getActiveEngineAPI():Object
		{
			return App.vhss_player.getActiveEngineAPI();
		}
		
		public function getAudioUrl():String
		{
			
			var _str:String = this.loaderInfo.url.substr(0, this.loaderInfo.url.lastIndexOf("/")+1);
			//trace("url ::::::::::::::::  " + _str + Bridge.vhss_player.getAudioUrl());
			return _str + App.vhss_player.getAudioUrl();
		}
		
		public function getSceneWidth():int
		{
			return this.width;
		}
		
		public function getSceneHeight():int
		{
			return this.height;
		}
		/**********************************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		
	}

}