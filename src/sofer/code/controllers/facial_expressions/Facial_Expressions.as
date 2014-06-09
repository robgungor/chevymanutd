package code.controllers.facial_expressions 
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
	public class Facial_Expressions
	{
		private var ui						:Facial_Expressions_UI;
		private var btn_open				:InteractiveObject;
		
		private var expressionArr			:Array;
		
		public function Facial_Expressions( _btn_open:InteractiveObject, _ui:Facial_Expressions_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
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
			if (ui.closeBtn)
				App.listener_manager.add( ui.closeBtn, MouseEvent.CLICK, close_win, this );
			App.listener_manager.add( btn_open, MouseEvent.CLICK, open_win, this );
			App.listener_manager.add( ui.expSelector, SelectorEvent.SELECTED, expSelected, this );
			App.listener_manager.add( ui.resetBtn, MouseEvent.CLICK, resetVals, this );
			App.listener_manager.add( ui.expSlider, ScrollEvent.SCROLL, sliderMoved, this );
			init_shortcuts();
			ui.expSelector.addScrollBtn(ui.nextBtn, 1);
			ui.expSelector.addScrollBtn(ui.prevBtn, -1);
			ui.expSlider.percent = 1;
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
		 ***************************** INTERFACE API */
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
		private function close_win( _e:MouseEvent = null ):void 
		{
			ui.visible = false;
		}
		private function open_win( _e:MouseEvent ):void 
		{
			if (!ServerInfo.is3D)
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t536', 'This feature is not available'));
				return;
			}
			else if (App.mediator.scene_editing &&
					App.mediator.scene_editing.model &&
					App.mediator.scene_editing.model.has_head_data())
			{
				ui.visible = true;
				populate_expressions_from_current_model();
				set_focus();
			}
			else	App.mediator.alert_user( new AlertEvent(AlertEvent.ERROR, 'f9t536', 'This feature is not available'));
		}
		private function populate_expressions_from_current_model(  ):void 
		{
			expressionArr = (App.mediator.scene_editing as Object).getExpressions();
			ui.expSelector.clear();
			for (var i:int = 0; i < expressionArr.length; i++)
				ui.expSelector.add(i, expressionArr[i], null, false);
				
			ui.expSelector.update();
		}
		private function expSelected(evt:SelectorEvent):void
		{
			var expression	:String = expressionArr[ui.expSelector.getSelectedId()];
			var amount		:Number = ui.expSlider.percent;
			(App.mediator.scene_editing as Object).setExpression(expression, amount);
		}
		private function sliderMoved(evt:ScrollEvent):void
		{
			if (ui.expSelector.isSelected())
			{
				var expression	:String = expressionArr[ui.expSelector.getSelectedId()];
				var amount		:Number = ui.expSlider.percent;
				(App.mediator.scene_editing as Object).setExpression(expression, amount);
			}
		}
		private function resetVals(evt:MouseEvent):void
		{
			if (ui.expSelector.isSelected())
			{
				var expression	:String = expressionArr[ui.expSelector.getSelectedId()];
				(App.mediator.scene_editing as Object).setExpression(expression, 0);
			}
			ui.expSlider.percent = 0;
			ui.expSelector.deselect();
		}
		
		
		
		/**
		 * 
		 * 
		 * 
		 * 
		 * 
		 * ******************************** KEYBOARD SHORTCUTS */
		private function set_focus():void
		{	ui.stage.focus = ui;
		}
		private function init_shortcuts():void
		{	App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}	
		private function shortcut_close_win(  ):void 		
		{	if (ui.visible)
				close_win();	
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