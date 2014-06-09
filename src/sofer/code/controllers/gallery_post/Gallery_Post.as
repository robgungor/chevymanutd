package code.controllers.gallery_post 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	/**
	 * ...
	 * @author Me^
	 */
	public class Gallery_Post
	{
		private var ui					:Gallery_Post_UI;
		private var btn_open			:InteractiveObject;
		
		private const PROCESS_LOADING_TOPICS	:String = 'PROCESS_LOADING_TOPICS';
		private const MSG_LOADING_TOPICS		:String = 'Loading gallery topics.';
		
		public function Gallery_Post( _btn_open:InteractiveObject, _ui:Gallery_Post_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui				= _ui;
			btn_open		= _btn_open;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				// init this after the application has been inaugurated
				init();
			}
		}
		private function init(  ):void 
		{
			if (ui.closeBtn != null) 
				App.listener_manager.add( ui.closeBtn, MouseEvent.CLICK, close_win, this );

			App.listener_manager.add( btn_open, MouseEvent.CLICK, open_win, this );
			App.listener_manager.add( ui.sendBtn, MouseEvent.CLICK, send, this );
			
			ui.tf_fromEmail.restrict = "a-zA-Z0-9_\\-.@";
			ui.topicSelector.visible = false;
			ui.tf_fromName.text = "";
			ui.tf_fromEmail.text = "";
			ui.tf_subject.text = "";
			
			init_shortcuts();
		}
		private function close_win( _e:MouseEvent = null ):void 
		{
			ui.visible = false;
		}
		private function open_win( _e:MouseEvent ):void 
		{
			if (App.mediator.checkPhotoExpired())
			{
				App.mediator.scene_editing.stopAudio();
				ui.visible = true;
				
				// set tab order
				var tab_oder:Array = 	[	ui.tf_fromName,
					ui.tf_fromEmail,
					ui.tf_subject,
					ui.sendBtn	];
				App.utils.tab_order.set_order( tab_oder );
				
				App.mediator.processing_start( PROCESS_LOADING_TOPICS, MSG_LOADING_TOPICS );
				App.asset_bucket.gallery_topics_list.load_gallery_topics( new Callback_Struct( loaded, null, error ) );
				
				function loaded(  ):void 
				{
					App.mediator.processing_ended( PROCESS_LOADING_TOPICS );
					populate_topics();
					set_focus();
				}
				function error( _e:AlertEvent ):void
				{
					App.mediator.processing_ended( PROCESS_LOADING_TOPICS );
					App.mediator.alert_user( _e );
				}
			}
		}
		
		private function populate_topics():void
		{
			if (App.asset_bucket.gallery_topics_list.topics.length <= 1) 
				return;
			
			var topic:GalleryTopic;
			for (var i:int = 0; i < App.asset_bucket.gallery_topics_list.topics.length; i++) {
				topic = App.asset_bucket.gallery_topics_list.topics[i];
				ui.topicSelector.add(topic.id, topic.name);
			}
			ui.topicSelector.selectById(App.asset_bucket.gallery_topics_list.defaultTopicId);
			ui.topicSelector.visible = true;
		}
		
		private function send( _e:MouseEvent = null):void
		{
			if (!EmailValidator.validate(ui.tf_fromEmail.text)) {
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR,"f9t106","Invalid from e-mail address"));
				return;
			}
			
			if (App.asset_bucket.profanity_validator.is_loaded)
			{
				var badWord:String;
				//validate subject field for bad words
				badWord = App.asset_bucket.profanity_validator.validate(ui.tf_subject.text);
				if (badWord != "") 
				{
					App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t331", "You cannot use the word " + badWord + ". Please try with a different word.", { badWord:badWord } ));
					return;
				}
				//validate name field for bad words
				badWord = App.asset_bucket.profanity_validator.validate(ui.tf_fromName.text);
				if (badWord != "") 
				{
					App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t331", "You cannot use the word " + badWord + ". Please try with a different word.", { badWord:badWord } ));
					return;
				}
			}
			
			var messageXML:XML = new XML("<message />");
			messageXML.from = new XML();
			messageXML.body = ui.tf_subject.text;
			messageXML.from.name = ui.tf_fromName.text;
			messageXML.from.email = ui.tf_fromEmail.text;
			
			if (ui.topicSelector.visible) 
				ServerInfo.topic = ui.topicSelector.getSelectedId();
			var sendEvt:SendEvent = new SendEvent(SendEvent.SEND, SendEvent.POST, messageXML);
			ui.sendBtn.disabled = true;
			App.utils.mid_saver.save_message( sendEvt, new Callback_Struct(message_sent, null, error) );
			
			function message_sent(  ):void 
			{	ui.sendBtn.disabled = false;
				close_win();
				App.asset_bucket.last_audio_saved = App.mediator.scene_editing.audio;
				WSEventTracker.event("edgp")
				App.mediator.alert_user(new AlertEvent(AlertEvent.ALERT,"f9t105","Thank you. Selected messages will be posted within 48 hours of submission."));
			}
			function error( _e:AlertEvent ):void {}
		}
		
		
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{	ui.stage.focus = ui.tf_fromName;
		}
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
			App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ENTER, shortcut_enter_handler );
		}	
		private function shortcut_close_win(  ):void 		
		{	if (ui.visible)
				close_win();	
		}
		private function shortcut_enter_handler(  ):void
		{
			send();
		}
		 /*******************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		
	}

}