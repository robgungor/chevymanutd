package code.controllers.terms_conditions 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.ui.StickyButton;
	import com.oddcast.workshop.WSEventTracker;
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.ui.Mouse;

	/**
	 * ...
	 * @author Me^
	 */
	public class Terms_Conditions
	{
		private var btn_open:InteractiveObject;
		private var _ui:TermsConditions_UI;
		public function Terms_Conditions( ui:TermsConditions_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			App.listener_manager.add(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED_PLAYBACK_STATE, app_initialized, this);
			
			// reference to controllers UI
			_ui 		= ui;
			btn_open	= new Sprite();//_ui.btn_continue;
			
			closeWin();
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				//App.listener_manager.remove_caught_event_listener( _e, arguments );
				App.listener_manager.remove(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED_PLAYBACK_STATE, app_initialized);
				App.listener_manager.remove(App.mediator, App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE, app_initialized);
				// init this after the application has been inaugurated
				init();
			}
		}
		private var btnArr:Array = [];
		private function init(  ):void 
		{
			return;
			App.listener_manager.add( btn_open, MouseEvent.CLICK, show_terms, this );
			App.listener_manager.add( _ui.btn_continue, MouseEvent.CLICK, _onContinueClick, this );
			App.listener_manager.add( _ui.btn_close, MouseEvent.CLICK, closeWin, this );
			App.listener_manager.add(_ui.termsOfUse, MouseEvent.CLICK, _onTermsLinkClicked, this);
			App.listener_manager.add(_ui.privacyPolicy, MouseEvent.CLICK, _onPolicyClicked, this);
			
			_ui.accept_Cb.addEventListener(MouseEvent.CLICK, _onCbClicked);
			
			btnArr.push(_ui.male);
			btnArr.push(_ui.female);
			
			_ui.tf_day.restrict 	= "0-9";
			_ui.tf_month.restrict 	= "0-9";
			_ui.tf_year.restrict 	= "0-9";
			_ui.tf_zip.restrict 	= "0-9";
			_ui.tf_email.restrict 	= App.settings.EMAIL_SINGLE_TF_RESTRICT;
			
			var tfs:Array = [_ui.tf_day,
				_ui.tf_month,
				_ui.tf_year,
				_ui.tf_zip,
				_ui.tf_email,
				_ui.tf_name];
			App.listener_manager.add_multiple_by_object( tfs, MouseEvent.CLICK, _onTfFocus, this );
			App.listener_manager.add_multiple_by_object( tfs, FocusEvent.FOCUS_IN, _onTfFocus, this );
			App.listener_manager.add_multiple_by_object( tfs, FocusEvent.FOCUS_OUT, _onTfLeave, this );
			
			for each(var tf:TextField in tfs)
			{
				tf.text = getDefault(tf);
			}
			
			_ui.tf_email.maxChars	= 50;
			_ui.tf_name.maxChars	= 50;
			
			_ui.male.addEventListener(MouseEvent.CLICK, _onRadioClick);
			_ui.female.addEventListener(MouseEvent.CLICK, _onRadioClick);
			
			_ui.female.selected = false;
			_ui.male.selected = true;
		}
		private function _onTfFocus(e:Event):void
		{
			if( (e.target as TextField).text == getDefault(e.target) )
			{
				(e.target as TextField).text = "";
			}
		}
		private function _onTfLeave(e:Event):void
		{
			if( (e.target as TextField).text == "" )
			{
				(e.target as TextField).text = getDefault(e.target);
			}
		}
		private function getDefault(obj:*):String
		{
			
			switch(obj)
			{
				case _ui.tf_day: 	return DOB_D_DEFAULT; break;
				case _ui.tf_month:	return DOB_M_DEFAULT; break;
				case _ui.tf_year: 	return DOB_Y_DEFAULT; break;
				case _ui.tf_zip: 	return ZIP_DEFAULT; break;
				case _ui.tf_email: 	return EMAIL_DEFAULT; break;
				case _ui.tf_name: 	return NAME_DEFAULT; break;
				default:
					return "";
			}
		}
		private function _onCbClicked( e:MouseEvent):void
		{
			if(_ui.accept_Cb.selected)
			{
				_ui.btn_continue.enabled = true;
				_ui.btn_continue.alpha = 1;
			} else
			{
				_ui.btn_continue.enabled = false;
				_ui.btn_continue.alpha = .35;
			}
			
		}
		public function get optedIn():Boolean
		{
			return App.ws_art.auto_photo_mode_selector.accept_Cb.selected;
		}
		private var _onContinueCallback:Function;
		
		public function openWin(callback:Function):void
		{
			return;
			_onContinueCallback = callback;
			_ui.visible = true;
			_ui.accept_Cb.selected = false;
			_ui.btn_continue.enabled = false;
			_ui.btn_continue.alpha = .35;
			
			var tab_order:Array = 	[_ui.tf_name,
				_ui.tf_email,
				_ui.tf_month,
				_ui.tf_day,
				_ui.tf_year,
				_ui.tf_zip];
			App.utils.tab_order.set_order( tab_order, 100 );
			//_ui.stage.focus = tab_order[0];
		}
		/** checks specific fields if they contain bad words */
		private function bad_words_passed( _replace_badwords:Boolean ):Boolean 
		{
			var textFields_to_check:Array = [_ui.tf_name];
			
			for (var i:int = 0; i < textFields_to_check.length; i++) 
			{
				var tf:TextField	= textFields_to_check[i];
				var check:String	= check_for_badwords( tf.text, _replace_badwords );
				if (check == null)	// bad word found
					return false;
				else
					tf.text			= check;
			}
			return true;
		}
		private function _onTermsLinkClicked(e:MouseEvent):void
		{
			App.mediator.open_hyperlink( "http://www.aetn.com/termsofuse/", "_blank");
		}
		private function _onPolicyClicked(e:MouseEvent):void
		{
			App.mediator.open_hyperlink( "http://www.aetn.com/privacy/", "_blank");
			
		}
		/**
		 * checks if a string has a bad word or not
		 * @param	_s	string that might contain a badword
		 * @param	_replace_bad_words	if to replace the bad words or leave
		 * @return	returns null if an error is thrown, otherwise returns converted/orignal string
		 */
		private function check_for_badwords( _s:String, _replace_bad_words:Boolean ):String 
		{
			if (App.asset_bucket.profanity_validator.is_loaded) 
			{
				if (_replace_bad_words) 
					return(App.asset_bucket.profanity_validator.replaceBadWords(_s));
				else 
				{
					var badWord:String = App.asset_bucket.profanity_validator.validate(_s);
					if (badWord == "") 
						return(_s);
					else 
					{
						App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, "f9t331", "You cannot use the word " + badWord + ". Please try with a different word.", { badWord:badWord } ));
						return(null);
					}
				}
			}
			else return(_s);
		}
		private static const NAME_DEFAULT:String = "John Smith";
		private static const DOB_M_DEFAULT:String = "MM";
		private static const DOB_D_DEFAULT:String = "DD";
		private static const DOB_Y_DEFAULT:String = "YYYY";
		private static const EMAIL_DEFAULT:String = "john.smith@email.com";
		private static const ZIP_DEFAULT:String = "00000";
		
		public function closeWin(e:MouseEvent = null):void
		{
			//_ui.visible = false;
		}
		/************************************************
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
		 * 
		 * 
		 ***************************** INTERNALS */
		private function show_terms( _e:MouseEvent ):void 
		{
			App.mediator.open_hyperlink(App.settings.TERMS_CONDITIONS_LINK, "_blank");
			return;
			
			var alert:AlertEvent = new AlertEvent( AlertEvent.CONFIRM, '', App.settings.TERMS_CONDITIONS_TEXT, null, terms_response );
			alert.report_error = false;
			App.mediator.alert_user(alert);
			//Bridge_Engine.mediator.alert_user( new AlertEvent( AlertEvent.CONFIRM, '', Bridge_Engine.settings.TERMS_CONDITIONS_TEXT, null, terms_response ), false );
			
			function terms_response( _ok:Boolean ):void 
			{
				if (_ok)
				{
					// do something for accept
				}
				else
				{
					// do something for deny
				}
			}
		}
		public function get gender():String
		{
			return _ui.male.selected ? "male" : "female";
		}
		private function _onRadioClick(evt:MouseEvent):void 
		{
			var btn:StickyButton = evt.currentTarget as StickyButton;
			if (!btn.selected) btn.selected = true;
			else 
			{	
				for (var i:int = 0; i < btnArr.length; i++) 
				{	
					if (btnArr[i] == btn)
					{
						
					}
					else 	btnArr[i].selected = false;
				}
			}
		}
		private function _onContinueClick(e:MouseEvent):void
		{
			if( !_ui.accept_Cb.selected ) return; 
			if(!bad_words_passed( App.settings.EMAIL_REPLACE_BAD_WORDS )) return;
			closeWin();
			//WSEventTracker.event("ce15");
			if(_onContinueCallback is Function) _onContinueCallback();
		}
		public function get optinData():String
		{
			var data:Object = {	email		: checkDefault(_ui.tf_email), 
								name		: checkDefault(_ui.tf_name), 
								bday_day	: checkDefault(_ui.tf_day),
								bday_month	: checkDefault(_ui.tf_month),
								bday_year	: checkDefault(_ui.tf_year),
								zip			: checkDefault(_ui.tf_zip)}
			function checkDefault(tf:TextField):String
			{
				return tf.text == getDefault(tf) ? "" : tf.text;
			}
			var result		:String  = "";
			
			for( var key:* in data)	
			{
				if(data[key] != "") result += key+": "+data[key]+", ";
			}
			
			// trim last comma and space
			result = result.substr(0, result.length-2);
			trace("OPT IN DATA: "+result);
			return result;
			
		}
		
		
	}

}