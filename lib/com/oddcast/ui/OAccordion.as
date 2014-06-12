/**
* @author Sam Myer
* 
* This is a basic accordion-style menu.  Each item in the menu consists of a button and an item which can be opened
* or closed:
* 
* Button 1   ->
* Button 2   ->
* Button 3   ->
* 
* if you click on a button, the menu opens
* 
* Button 1   ->
* Button 2   v
*   ITEMITEMITEM
*   ITEMITEMITEM
* 	ITEMITEMITEM
* Button 3   ->
* 
* 
****** FUNCTIONS *****
* 
* addTabAt(btn,mc,order)
* 
* btn - button used for opening/closing submenu item.  Normally this is a StickyButton.  If it implements the
* ISelector interface (e.g. StickyButton, ToggleButton, OCheckBox), then it will go in the selected state when the submenu item
* is open.  E.g. for a sticky button, for the "enable" state you could have a right arrow "Button    ->" and for
* the press state you could have a down arrow  "Button      v"
* 
* mc - this is the submenu item which is opened/closed when you click the button.  You can also
* have it be another Accordion if you want to add another level of submenus.
* 
* order - the position in the list to add the tab.  e.g. 0 adds the tab to the top of the list.
* 
* addTab(btn,mc) - same as addTabAt.  adds tab at the bottom of the list
* 
***** PROPERTIES *****
* xOffset - pixel difference between item and button.  When this is >0, item is indented to the right.
* 
* openOneAtATime - when this is set to true, only one item can be open at a time.  If you open another item,
* the last item will close.  When false, you can have unlimited items open at a time.  defaults to true
* 
* animateSec - the number of seconds to animate the items opening and closing.  When this is 0, the items
* open & close instantly.  defaults to 0
* 
*******  EVENTS *******
* 
* Event.RESIZE - dispatched whenever the height property of the accordion changes.
* 
* 
*/
package com.oddcast.ui {
	import com.oddcast.utils.SimpleTween;
	import com.oddcast.utils.SimpleTweenManager;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class OAccordion extends MovieClip {
		public var tabArray:Array;
		[Inspectable (defaultValue=0)]public var xOffset:Number = 0;
		[Inspectable (defaultValue=true)]public var openOneAtATime:Boolean = true;
		[Inspectable (defaultValue = 0)]public var animateSec:Number = 0;
		
		public function OAccordion() {
			tabArray = new Array();
		}
		
		public function addTab(btn:Sprite, mc:Sprite) {
			addTabAt(btn, mc, tabArray.length);
		}
		
		public function addTabAt(btn:Sprite, mc:Sprite, order:uint) {
			addChild(btn);
			btn.addEventListener(MouseEvent.CLICK, onPressed, false, 0, true);
			mc.addEventListener(Event.RESIZE, onItemResized,false,0,true);
			var tabObj:OCAccordionItem = new OCAccordionItem(btn, mc, false);
			if (order >= tabArray.length) tabArray.push(tabObj);
			else tabArray.splice(order, 0, tabObj);
			update(false);
		}
		
		private function update(animate:Boolean=true) {
			var doAnimate:Boolean = (animateSec > 0) && animate;
			if (doAnimate) SimpleTweenManager.removeTweensOnMC(this);
			
			var oldHeight:Number = height;
			var ypos:Number = 0;
			var item:OCAccordionItem;
			for (var i:int = 0; i < tabArray.length; i++) {
				item = tabArray[i];
				item.btn.x = 0;
				if (doAnimate) addTween(item.btn, "y",ypos);
				else item.btn.y = ypos;
				ypos += item.btn.height;
				if (item.isOpen) {
					item.mc.x = xOffset;
					if (item.mc.parent != this) {
						addChild(item.mc);
						if (doAnimate) {
							item.mc.y = item.btn.y +item.btn.height - item.mc.height;
							if (item.mc.mask==null) {
								item.mc.mask = createBox(item.mc.width, 0);
								addChild(item.mc.mask);
								item.mc.mask.y = item.btn.y + item.btn.height;
							}
							addTween(item.mc, "y", ypos, mcAnimateInComplete);
							addTween(item.mc.mask, "y", ypos);
							addTween(item.mc.mask, "height", item.mc.height);
						}
						else item.mc.y = ypos;
					}
					else if (doAnimate) addTween(item.mc, "y",ypos);
					else item.mc.y = ypos;
					ypos += item.mc.height;
					if (item.btn is ISelectable) (item.btn as ISelectable).selected = true;
				}
				else {
					if (item.mc.parent == this) {
						if (doAnimate) {
							if (item.mc.mask==null) {
								item.mc.mask = createBox(item.mc.width, item.mc.height);
								addChild(item.mc.mask);
								item.mc.mask.y = item.mc.y;
							}
							addTween(item.mc, "y", ypos - item.mc.height, mcAnimateOutComplete);
							addTween(item.mc.mask, "y", ypos);
							addTween(item.mc.mask, "height", 0);
						}
						else removeChild(item.mc);
					}
					if (item.btn is ISelectable) (item.btn as ISelectable).selected = false;
				}
			}
			if (height != oldHeight) dispatchEvent(new Event(Event.RESIZE));
		}
		
		private function onPressed(evt:MouseEvent) {
			var item:OCAccordionItem;
			for (var i:int=0; i < tabArray.length; i++) {
				item = tabArray[i];
				if (item.btn == evt.currentTarget) item.isOpen = !item.isOpen;
				else if (openOneAtATime) item.isOpen = false;
			}
			update(true);
		}
		
		private function onItemResized(evt:Event) {
			update(false);
		}
		
		private function addTween(mc:DisplayObject, property:String, targetVal:Number, callback:Function = null) {
			SimpleTweenManager.tweenMCTo(mc, property, targetVal, animateSec, callback,SimpleTween.easeIn);
		}
		
		private function createBox(w:Number,h:Number):Sprite {
			var box:Sprite = new Sprite();
			box.graphics.lineStyle(0, 0);
			box.graphics.beginFill(0);
			box.graphics.drawRect(xOffset, 0, w, 100);
			box.graphics.endFill();
			box.height = h;
			return(box);
		}
		
		private function mcAnimateInComplete(tween:SimpleTween) {
			var mc:Sprite = (tween.target) as Sprite;
			removeChild(mc.mask);
			mc.mask = null;
			
		}
		private function mcAnimateOutComplete(tween:SimpleTween) {
			var mc:Sprite = (tween.target) as Sprite;
			removeChild(mc.mask);
			mc.mask = null;
			removeChild(mc);
		}
	}
	
}
import flash.display.Sprite;

class OCAccordionItem {
	public var btn:Sprite;
	public var mc:Sprite;
	public var isOpen:Boolean;
	
	public function OCAccordionItem($btn:Sprite, $mc:Sprite, $isOpen:Boolean) {
		btn = $btn;
		mc = $mc;
		isOpen = $isOpen;
	}
}