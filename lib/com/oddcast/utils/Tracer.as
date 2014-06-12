/**
* ...
* @author Sam
* @version 0.1
* 
* Writes output to a textfield that can be hidden or shown using hot-keys.  Currently, the hot-key is pressing
* A, F12, F1 consecutively
* 
* e.g.
* to init:
* Tracer.setTextField(tf) - where tf is the textfield (usually root level) where you want the output to show up
* 
* Tracer.write(s) - writes string to the textfield
*/

package com.oddcast.utils {
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;

	public class Tracer {
		private static var tf:TextField;
		private static const magicKeys:Array=[65,123,112];  //a F12, F1  one after the other
		private static var lastKeys:Array = new Array(magicKeys.length);
		public static var echo:Boolean = true;
		
		public function Tracer() {
			/*
			if (tf==null) {
				tf=new TextField();
				tf.width=(stage==null)?500:(stage.width-50);
				tf.height=(stage==null)?300:(stage.height-50);
				tf.border=true;
				tf.background=true;
				tf.multiline=true;
				tf.type="dynamic";
				tf.selectable=true;
				addChild(tf);
			}
			*/
		}
		
		public static function setTextField($tf:TextField):void 
		{
			tf=$tf;
			tf.visible=false;
			if (tf.stage==null) 
			{
				tf.addEventListener(Event.ADDED_TO_STAGE,addedToStage);
			}
			else 
			{
				tf.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyPressed);	
			}		
		}
		
		private static function addedToStage(evt:Event):void
		{
			tf.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyPressed);
		}
		
		public static function write(s:String):void 
		{
			if (echo) trace(s);
			if (tf!=null) {
				tf.text=tf.text+s+"\n"
			}
		}
		
		private static function keyPressed(evt:KeyboardEvent):void 
		{
			lastKeys.shift();
			lastKeys.push(evt.keyCode);
			//trace(lastKeys);
			if (compareArrays(lastKeys,magicKeys)) tf.visible=!tf.visible;
		}
		
		private static function compareArrays(a1:Array, a2:Array):Boolean 
		{
			if (a1.length != a2.length) return false;
			for (var i:uint=0; i<a1.length; i++)
			{
				if (a1[i] != a2[i]) return false;
			}
			return true;
		}
	}	
}