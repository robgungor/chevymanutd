/**
* ...
* @author Jonathan Achai
* 
* Purpose:
* Due to a flash player bug in windowless mode (tested with opaque) the curosr misbehaves in input textfields.
* Namely, moveing the curosr twice instead of once.
* This class uses timing information to determine which cursor move was redundant and bring back the cursor to the location where it should have been
* 
* 
* @usage initiliazie this static class using init and a reference to the stage (or other interactive object from which you want monitor textfields)
*/


package com.oddcast.utils 
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author jachai
	 */
	public class TextFieldScrollKeyFix 
	{

		private static var stageMC:InteractiveObject;
		private static var dict:Dictionary;
		private static var tripleClickDict:Dictionary;
		private static const INVALID_TIME_BET_EVENTS:int = 5; //ms
		public static var TRIPLE_CLICK_TIME:int = 300;
		private static var _tfActive:Object;
		private static var _oTFSelection:Object;
		private static var _oPrevSelection:Object;
		private static var _timer:Timer;
		
		public static var tripleClickEnabled:Boolean;
		
		public function TextFieldScrollKeyFix() 
		{
			
		}
		
		public static function init(mc:InteractiveObject, tripleClick:Boolean = true):void
		{			
			stageMC = mc;
			dict = new Dictionary();
			tripleClickEnabled = tripleClick;
			if (tripleClickEnabled)
			{
				tripleClickDict = new Dictionary();
			}
			stageMC.addEventListener(FocusEvent.FOCUS_IN, onObjectAdded);
			_timer = new Timer(1,1);
			_timer.addEventListener(TimerEvent.TIMER, doSelection);			
		}
		
		public static function destroy():void
		{			
			for each (var key:Object in dict)
			{
				TextField(KeyboardEvent).removeEventListener(KeyboardEvent.KEY_DOWN, registerKeyDown);
				if (tripleClickEnabled)
				{
					TextField(KeyboardEvent).removeEventListener(MouseEvent.CLICK, registerClick);
				}
			}
			stageMC.removeEventListener(FocusEvent.FOCUS_IN, onObjectAdded);
			stageMC = null;
			dict = null;
			if (tripleClickEnabled)
			{
				tripleClickDict = null;
			}
			_timer.removeEventListener(TimerEvent.TIMER, doSelection);
			_timer = null;
		}
		
		private static function onObjectAdded(evt:Event):void
		{
			if (evt.target is TextField)
			{
				if (TextField(evt.target).type == TextFieldType.INPUT)
				{					
					TextField(evt.target).addEventListener(KeyboardEvent.KEY_DOWN, registerKeyDown)
					if (tripleClickEnabled)
					{
						TextField(evt.target).addEventListener(MouseEvent.CLICK, registerClick)
					}
				}
			}
		}
		
		private static function registerClick(evt:MouseEvent):void
		{
			if (tripleClickDict[evt.target] == null)
			{
				tripleClickDict[evt.target] = { lastClick:getTimer(), clickNumber:1 };
			}
			else if (getTimer()-tripleClickDict[evt.target].lastClick<=TRIPLE_CLICK_TIME)
			{
				var clickNum:int = tripleClickDict[evt.target].clickNumber + 1;
				if (clickNum == 3)
				{
					TextField(evt.target).stage.focus = TextField(evt.target);
					TextField(evt.target).setSelection(0, TextField(evt.target).length);
					tripleClickDict[evt.target] = { lastClick:getTimer(), clickNumber:0};
				}
				else
				{
					tripleClickDict[evt.target] = { lastClick:getTimer(), clickNumber:clickNum};
				}
			}
			else
			{				
				tripleClickDict[evt.target] = { lastClick:getTimer(), clickNumber:1};
			}
		}
		
		private static function doSelection(evt:TimerEvent):void
		{						
			TextField(_tfActive).stage.focus = TextField(_tfActive);
			if (_oTFSelection.scroll != null)
			{
				TextField(_tfActive).scrollV = _oTFSelection.scroll
			}
			else
			{
				TextField(_tfActive).setSelection(_oTFSelection.begin , _oTFSelection.end);											
			}
		}
		
		private static function registerKeyDown(evt:KeyboardEvent):void
		{
			
			var beginIndex:int = TextField(evt.target).selectionBeginIndex;;
			var endIndex:int = TextField(evt.target).selectionEndIndex;
			var caretIndex:int = TextField(evt.target).caretIndex;		
			var lineIndex:int = TextField(evt.target).getLineIndexOfChar(caretIndex);
			var scrollVertIndex:int = TextField(evt.target).scrollV;
			var tfValue:String = TextField(evt.target).text;			
			//right/left arrows, delete, pgUp/pgDown, up/down arrows
			//trace(getTimer()+" scrollV=" + scrollVertIndex);
			//trace(getTimer()+" registerKeyDown " + evt.keyCode);
			//trace("getTimer "+getTimer()+" caretIndex ="+caretIndex + "->" +TextField(evt.target).getLineIndexOfChar(caretIndex));
			if (dict[evt.target] == null && (evt.keyCode==37 || evt.keyCode==39 || evt.keyCode == 46 || evt.keyCode == 33 || evt.keyCode == 34 || evt.keyCode == 40 || evt.keyCode == 38))
			{
				//trace("saving "+scrollVertIndex+" to scrollV");
				dict[evt.target] = { time:getTimer(), sel: { begin:beginIndex, end:endIndex, caret:caretIndex, value:tfValue, line:lineIndex, scrollV:scrollVertIndex}};												
			}			
			else if (dict[evt.target] != null && (getTimer()-dict[evt.target].time)<=INVALID_TIME_BET_EVENTS)
			{
				//trace(getTimer()+" not null scrollV=" + scrollVertIndex);
				//trace("getTimer "+getTimer()+" caretIndex ="+caretIndex + "->" +TextField(evt.target).getLineIndexOfChar(caretIndex));
				var currentCaretIndex:int = TextField(evt.target).caretIndex;				
				if (evt.keyCode == 37 || evt.keyCode == 39)
				{
					//trace("caret 1 "+dict[evt.target].sel.caret);
					var moveTo:int = TextField(evt.target).caretIndex;				
					//trace("caret 2 "+currentCaretIndex);
					var moveBy:int = (evt.keyCode == 37) ? 1 : -1;
					
					var selectOffset:int;
					
					if (evt.shiftKey)
					{								
						_tfActive = evt.target;		
						if (caretIndex == beginIndex)
						{
							_oTFSelection = { begin:endIndex, end: beginIndex };// { begin:beginIndex, end:endIndex };
						}
						else
						{
							_oTFSelection = { begin:beginIndex, end: endIndex };
						}
						_timer.reset();
						_timer.repeatCount = 1;
						_timer.start();						
					}					
					else
					{						
						TextField(evt.target).setSelection(moveTo + (moveBy * 1), moveTo + (moveBy * 1));				
					}					
				}
				else if (evt.keyCode == 46 && dict[evt.target].sel.begin==dict[evt.target].sel.end)
				{
					TextField(evt.target).text = dict[evt.target].sel.value;					
				}
				
				else if (evt.keyCode == 38 || evt.keyCode == 40)
				{
					var firstCharOnLine:int = TextField(evt.target).getLineOffset(dict[evt.target].sel.line) + dict[evt.target].sel.caret;
					if (firstCharOnLine < TextField(evt.target).length)
					{
						TextField(evt.target).setSelection(firstCharOnLine, firstCharOnLine);
					}
					else
					{
						TextField(evt.target).setSelection(TextField(evt.target).length-1, TextField(evt.target).length-1);
					}
					//trace("getTimer "+getTimer()+" caretIndex ="+caretIndex + "->" +TextField(evt.target).getLineIndexOfChar(caretIndex));
					//trace(caretIndex + "->" +TextField(evt.target).getLineIndexOfChar(caretIndex));
				}
				else if (evt.keyCode == 33 || evt.keyCode == 34)
				{
					//trace("do scrollV=" + scrollVertIndex);
					//TextField(evt.target).scrollV = scrollVertIndex;
					_tfActive = evt.target;		
					_oTFSelection = { scroll:scrollVertIndex };// { begin:beginIndex, end:endIndex };						
					_timer.reset();
					_timer.repeatCount = 1;
					_timer.start();										
				}				
			}
			else if (dict[evt.target] != null)
			{
				//trace("do scrollV=" + dict[evt.target].sel.scrollV);
				dict[evt.target] = { time:getTimer(), sel: { begin:beginIndex, end:endIndex, caret:caretIndex , value:tfValue}};								
			}
		}
		
	}
	
}