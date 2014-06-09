package player 
{
	import com.oddcast.event.*;
	import com.oddcast.ui.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Me^
	 */
	public class Alert extends MovieClip
	{
		public var tf_alert		:TextField;
		public var tf_title		:TextField;
		public var btn_ok		:SimpleButton;
		public var btn_cancel	:SimpleButton;
		public var scrollbar	:OScrollBar;
		
		public static const COMPILATION_TIME		:String = '0910091655';
		public static const ERROR_LOADING_PLAYBACK	:String = 'Cannot load playback';
		public static const MSG_BLOCKED_LINK		:String = 'If the link was blocked, please click OK to copy the following URL to your clipboard:\n\n';
		public static const MSG_CLIPBOARD_ERROR		:String = 'Could not copy to your clipboard';
		
		public function Alert() 
		{
			App.alert = this;
			App.listener_manager.add( btn_ok, MouseEvent.CLICK, close_win, this );
			//App.listener_manager.add( btn_cancel, MouseEvent.CLICK, close_win, this );
			App.listener_manager.add( scrollbar, ScrollEvent.SCROLL, scroll_callback, this);
			App.listener_manager.add( scrollbar, ScrollEvent.RELEASE, scroll_callback, this);
			close_win();
			init_shortcuts();
		}
		public function alert_user( _e:AlertEvent ):void 
		{
			tf_title.text = _e.alertType == AlertEvent.CONFIRM ? 'Message' : 'Error';
			tf_alert.text = _e.text;
			open_win();
			show_hide_scrollvar();
			
			function show_hide_scrollvar(  ):void 
			{
				scrollbar.visible		= (tf_alert.maxScrollV > 1);
				scrollbar.totalSteps	= tf_alert.maxScrollV;
				scrollbar.percent		= 0;
				tf_alert.scrollV		= 1;
			}
			
			if (_e.callback != null)
			{
				//if(btn_cancel) App.listener_manager.add( btn_cancel, MouseEvent.CLICK, user_responded, this );
				App.listener_manager.add( btn_ok, MouseEvent.CLICK, user_responded, this );
				function user_responded ( _click_e:MouseEvent ):void
				{
					App.listener_manager.remove( btn_cancel, MouseEvent.CLICK, user_responded );
					App.listener_manager.remove( btn_ok, MouseEvent.CLICK, user_responded );
					_e.callback( _click_e.target == btn_ok);
				}
			}
		}
		private function close_win( _e:MouseEvent = null ):void 
		{
			visible = false;
		}
		private function open_win(  ):void 
		{
			visible = true;
			set_focus();
		}
		private function scroll_callback( _e:ScrollEvent ):void
		{
			var min				:Number		= 1;
			var max				:Number		= tf_alert.maxScrollV;
			var scroll_to		:Number		= Math.round( max * _e.percent ) + min
			tf_alert.scrollV = scroll_to;
		}
		private function set_focus(  ):void 
		{
			if (stage)
				stage.focus = this;
		}
		private function init_shortcuts(  ):void 
		{
			App.shortcut_manager.api_add_shortcut_to( this, Keyboard.ESCAPE, shortcut_cancel );
			App.shortcut_manager.api_add_shortcut_to( this, Keyboard.ENTER, shortcut_ok );
		}
		private function shortcut_cancel(  ):void 
		{
			btn_cancel.dispatchEvent(new MouseEvent(MouseEvent.CLICK));	// better do this since it sends the user response callback as well
		}
		private function shortcut_ok(  ):void 
		{
			btn_ok.dispatchEvent(new MouseEvent(MouseEvent.CLICK));	// better do this since it sends the user response callback as well
		}
		
	}

}