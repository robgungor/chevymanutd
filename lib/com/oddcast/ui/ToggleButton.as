/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* -movieclip must contain 2 basebuttons
* -whichever button is on the top (highest depth) is the default state
* 
* FUNCTIONS:
* getButton(btnName):BaseButton - returns button by name
* 
* PROPERTIES:
* btn:String - set/get current button state by button name.
* eg say your BaseButtons are called "playBtn" and "stopBtn",
* you could call toggleBtn.btn="playBtn" to select the play button
* 
* state - can have values 1 or 2   -  button on highest depth is automatically button #1 (the default)
* I made this property private for now, because I think using toggleBtn.btn="playBtn" is less ambiguous
* than toggleBtn.state=1
* However, it could be made public for backwards compatibility
* 
* disabled - disables button
* 
* EVENTS:
* mouse events originate from the BaseButtons
* 
* eg
* 
* Usage 1:  use getChildByName to add the event listener directly on the BaseButton
* 
* toggleBtn.getButton("playBtn").addEventListener(MouseEvent.CLICK,playAudio)
* toggleBtn.getButton("stopBtn").addEventListener(MouseEvent.CLICK,stopAudio)
* function playAudio(evt:MouseEvent) {
*   ...
* }
* 
* 
* Usage 2:  use event.target.name to get which BaseButton is causing the click event
* 
* toggleBtn.addEventListener(MouseEvent.CLICK,toggleAudio)
* function toggleAudio(evt:MouseEvent) {
*   if (evt.target.name=="playBtn") playAudio()  
*   else if (evt.target.name=="stopBtn") stopAudio();
* }
* 
* 
* @throws
* Error if it doesn't contain 2 basebuttons
*/

package com.oddcast.ui {
	import com.oddcast.ui.BaseButton;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class ToggleButton extends MovieClip implements ISelectable {
		private var btn1:BaseButton;
		private var btn2:BaseButton;
		
		public function ToggleButton() {
			var btns:Array=new Array();
			for (var i:int=0;i<numChildren;i++) {
				if (getChildAt(i) is BaseButton) btns.push(getChildAt(i));
			}
			if (btns.length!=2) throw new Error("ToggleButton must contain 2 BaseButtons")
			btn1=btns[btns.length-1]; //top button (= btns[1])
			btn2=btns[btns.length-2]; //2nd to top button (= btns[0])
			btn1.addEventListener(MouseEvent.CLICK,btn1Click,false,0,true);
			btn2.addEventListener(MouseEvent.CLICK,btn2Click,false,0,true);
			state=1;
			mouseEnabled=false;
			mouseChildren=true;
		}
		
		public function set btn(btnName:String):void {
			if (btn1.name==btnName) state=1;
			else if (btn2.name==btnName) state=2;
		}
		
		public function get btn():String {
			return(btn2.visible?btn2.name:btn1.name);
		}
		
		private function set state(n:uint):void {
			if (n==1) {
				btn1.visible=true;
				btn2.visible=false;				
			}
			else if (n==2) {
				btn1.visible=false;
				btn2.visible=true;								
			}
		}
		
		private function get state():uint {
			return(btn1.visible?1:2);
		}
		
		private function btn1Click(evt:MouseEvent):void {
			state=2;
		}
		
		private function btn2Click(evt:MouseEvent):void {
			state=1;
		}
		
		public function set disabled(b:Boolean):void {
			btn1.disabled=b;
			btn2.disabled=b;
		}
		
		public function get disabled():Boolean {
			return(btn1.disabled);
		}
		
		public function getButton(btnName:String):BaseButton {
			if (btn1.name==btnName) return (btn1);
			else if (btn2.name==btnName) return(btn2);
			else return null;
		}
		
		/* INTERFACE com.oddcast.ui.ISelectable */
		
		public function get selected():Boolean{
			return(state == 2);
		}
		
		public function set selected(b:Boolean):void{
			state = b?2:1;
		}
	}
	
}