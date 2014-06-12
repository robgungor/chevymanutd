/**
* ...
* @author Jonathan Achai
* @version 0.1
* 
* Usage:
* import com.oddcast.utils.ToolTipManager
* 
* 1. ToolTipManager.add(DisplayObject,String) - add a tooltip to a display object
* 2. Use the public static variables for configuring the tool tip functionality:
* 	a. BG_COLOR
* 	b. BORDER_COLOR
* 	c. TRIGGER_TIME (miliseconds after mouse over to wait before showing the tooltip)
* 	d. REMOTE_TIME (miliseconds after tool tip shows up wait before removing the tooltip)
* 	e. CURSOR_SIZE (how far in pixels should the tooltip be offseted from the mouse position)
* 3.
* 
*/

package com.oddcast.utils{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	public class  ToolTipManager{
		
		public static var BG_COLOR:int = 0xffffe1;
		public static var BORDER_COLOR:int = 0x00000;
		public static var TEXT_COLOR:int = 0x00000;
		public static var TRIGGER_TIME:int = 1000;
		public static var REMOVE_TIME:int = 4000;
		public static var CURSOR_SIZE:int = 10;
		
		private static var _arrObjectStrings:Dictionary;
		private static var _timerOver:Timer;
		private static var _timerOut:Timer;
		private static var _doActiveObject:DisplayObject;
		private static var _doActiveToolTip:DisplayObject;
		
		
		function ToolTipManager()
		{
			
		}
		
		public static function add(dObj:DisplayObject,s:String):void
		{
			dObj.addEventListener(MouseEvent.MOUSE_OVER,ToolTipManager.rollOver);
			dObj.addEventListener(MouseEvent.ROLL_OUT,ToolTipManager.rollOut);
			dObj.addEventListener(MouseEvent.MOUSE_DOWN,ToolTipManager.rollOut);
			if (ToolTipManager._arrObjectStrings==null)
			{
				ToolTipManager._arrObjectStrings = new Dictionary(true);
			}
			//trace("TooltipManager::add dObj.name="+dObj.name+", s="+s);
			ToolTipManager._arrObjectStrings[dObj] = s;
		}
		
		public static function remove(dObj:DisplayObject) {
			if (dObj==_doActiveObject) {
				_timerOver.stop();	
				removeToolTip();
			}
			
			dObj.removeEventListener(MouseEvent.MOUSE_OVER,ToolTipManager.rollOver);
			dObj.removeEventListener(MouseEvent.ROLL_OUT,ToolTipManager.rollOut);
			dObj.removeEventListener(MouseEvent.MOUSE_DOWN, ToolTipManager.rollOut);
			
			//trace("TooltipManager::add dObj.name="+dObj.name+", s="+s);
			delete _arrObjectStrings[dObj];
		}
		
		public static function destroy() {
			for (var obj:Object in _arrObjectStrings) {
				if (obj is DisplayObject) remove(obj as DisplayObject);
			}
		}
		
		private static function rollOver(evt:MouseEvent):void
		{
			//trace("ToolTipManager::rollOver ");
			if (ToolTipManager._timerOver==null)
			{
				ToolTipManager._timerOver = new Timer(ToolTipManager.TRIGGER_TIME,1);
				ToolTipManager._timerOver.addEventListener(TimerEvent.TIMER_COMPLETE,ToolTipManager.showToolTip);
			}			
			
			ToolTipManager.removeToolTip();
			//trace("ToolTipManager::rollOver _doActiveObject.name="+evt.target.name);
			ToolTipManager._doActiveObject = evt.target as DisplayObject;
			ToolTipManager._timerOver.reset();
			ToolTipManager._timerOver.start();
		}
		
		private static function rollOut(evt:MouseEvent):void
		{
			//trace("ToolTipManager::rollOut ");
			ToolTipManager._timerOver.stop();	
			ToolTipManager.removeToolTip();
		}
		
		private static function showToolTip(evt:TimerEvent):void
		{						
			//trace("ToolTipManager::showToolTip _doActiveObject.name="+_doActiveObject.name);
			var ttTF:TextField = new TextField();
			ttTF.text = _arrObjectStrings[_doActiveObject];
			ttTF.textColor = ToolTipManager.TEXT_COLOR;
			ttTF.autoSize = "center";
			ttTF.background = true;
			ttTF.backgroundColor = ToolTipManager.BG_COLOR;
			ttTF.border = true;
			ttTF.selectable = false;
			ttTF.borderColor = ToolTipManager.BORDER_COLOR;
			ttTF.x = _doActiveObject.stage.mouseX + ToolTipManager.CURSOR_SIZE;
			ttTF.y = _doActiveObject.stage.mouseY + ToolTipManager.CURSOR_SIZE;

			//updated -- sam
			var stage:Stage = _doActiveObject.stage;
			
			//set a max char length
			var maxChars:uint = 500;
			ttTF.text = ttTF.text.slice(0, maxChars);
			
			//make sure the textfield doesn't exceed the stage width
			var maxWidth:Number = stage.stageWidth - CURSOR_SIZE * 2;
			if (ttTF.textWidth>maxWidth) {
				ttTF.width=maxWidth;
				ttTF.multiline=true;
				ttTF.wordWrap=true;
			}
			
			//if the textfield goes off the screen, move it up & left
			var xm:Number=(stage.stageWidth-CURSOR_SIZE)-(ttTF.x+ttTF.width);
			var ym:Number=stage.stageHeight-(ttTF.y+ttTF.height);
			if (xm<0) ttTF.x+=xm;
			if (ym < 0) ttTF.y += ym;
			
			/* old code - sam
			if ((ttTF.x+ttTF.width)>_doActiveObject.stage.width)
			{
				ttTF.x = _doActiveObject.stage.mouseX - ToolTipManager.CURSOR_SIZE - ttTF.width;
			}
			
			if ((ttTF.y+ttTF.height)>_doActiveObject.stage.height)
			{
				ttTF.y = _doActiveObject.stage.mouseY - ToolTipManager.CURSOR_SIZE - ttTF.height;
				
			}*/
			
			//trace(ttTF.getBounds(_doActiveObject.stage).toString());
			
			_doActiveToolTip = _doActiveObject.stage.addChild(ttTF);
			if (ToolTipManager._timerOut==null)
			{
				ToolTipManager._timerOut = new Timer(ToolTipManager.REMOVE_TIME,1);
				ToolTipManager._timerOut.addEventListener(TimerEvent.TIMER_COMPLETE,ToolTipManager.expireToolTip);
			}
			ToolTipManager._timerOut.reset();
			ToolTipManager._timerOut.start();
		}
		
		private static function expireToolTip(evt:TimerEvent):void
		{
			ToolTipManager.removeToolTip();
		}
		
		private static function removeToolTip():void
		{
			if (ToolTipManager._doActiveToolTip!=null)
			{
				ToolTipManager._doActiveToolTip.parent.removeChild(ToolTipManager._doActiveToolTip);				
				ToolTipManager._doActiveToolTip = null;
			}
		}
		
	}
	
}