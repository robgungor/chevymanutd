/*
* A "Document Class" for Oddcast Applications
* 
* 
* 
*/
package com.oddcast.stage
{

	import flash.display.MovieClip;
	import flash.events.Event;	
	import com.oddcast.ui.PlayerButton;
	import com.oddcast.ui.StickyButton;
	import com.oddcast.event.BaseButtonEvent;
	
	public class OCStage extends MovieClip
	{
		private var playBtn:PlayerButton;
		private var playBtn2:PlayerButton;
		private var stickBtn:StickyButton;
		
		function OCStage()
		{
			this.addEventListener(Event.ADDED,childAdded);
			playBtn = getChildByName("pbtn2") as PlayerButton;
			//playBtn2 = getChildByName("dn_btn") as PlayerButton;
			//stickBtn = getChildByName("stbtn") as StickyButton;
			
			playBtn.addEventListener(BaseButtonEvent.DBLCLICK,dblClicked);
			playBtn.addEventListener(BaseButtonEvent.CLICK,clicked);
			//playBtn2.addEventListener(BaseButtonEvent.CLICK,clicked);
			//stickBtn.addEventListener(BaseButtonEvent.CLICK,clicked);
			playBtn.doubleClickEnabled = true;
			var o:Object = new Object();
			o.id = 1;
			o.name = "jon";
			o.type = "player!!!";
			playBtn.data = o;	
			//stickBtn.setData("type","Sticky!!!");
			//playBtn2.setData("name","button2");
			
		}
	
		private function dblClicked(evt:Event):void
		{
			var btn:PlayerButton = evt.target as PlayerButton;
			btn.setData("name","other");
			trace("dblClicked "+evt.target);
		}
		
		private function clicked(evt:Event):void
		{
			var btn:PlayerButton = evt.target as PlayerButton;
			//trace("clicked "+evt.target);
			//trace(evt.target)
			
			trace(btn.getData("name"));
			trace(btn.getData("type"));
		}
		
		private function childAdded(evt:Event):void
		{						
			
		}
	}
}