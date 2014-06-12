package com.oddcast.utils {
	import flash.display.DisplayObjectContainer;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

	import flash.system.System;

	public class MemoryTracer {
		private var _timer:Timer;
		private var _bUseTextField:Boolean;		
		private var _tfText:TextField;
		
		function MemoryTracer(callEvery:uint,drawTextField:Boolean=false,doc:DisplayObjectContainer=null) {
			_bUseTextField = drawTextField;
			if (_bUseTextField)
			{
				_tfText	= new TextField();				
				_tfText.autoSize = TextFieldAutoSize.LEFT;
				_tfText.background = true;
				_tfText.border = true;

				var format:TextFormat = new TextFormat();
				format.font = "Verdana";
				format.color = 0xFF0000;
				format.size = 10;
				format.underline = true;

				_tfText.defaultTextFormat = format;         

				
				doc.addChild(_tfText);
			}
			
			_timer=new Timer(callEvery);
			_timer.addEventListener(TimerEvent.TIMER,showMemory);
			_timer.start();
		}
		
		private function showMemory(evt:TimerEvent):void
		{
			var text:String = "System.totalMemory="+System.totalMemory;
			if (!_bUseTextField)
			{
				trace(text);
			}
			else
			{				
				//trace("MemoryTracer::showMemory "+System.totalMemory);
				_tfText.text = text;			
			}
		}
		
		public function stop():void
		{
			_timer.stop();
		}
		
		public function resume():void
		{
			_timer.start();
		}
		
		
	}
	
}