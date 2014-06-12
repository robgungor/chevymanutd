/**
* @author Sam Myer
* 
* static class to take care of tweening including handling listeners
* 
* tweenMCTo(mc,property,value,time,callback,easing) - performs a tween and calls callback() when complete
* mc - stage DisplayObject the tween should act on
* property - the property being tweened (as a String) e.g. "x", "alpha", "scaleX"
* value - the final value of the property
* time - the amount of time the tweening should take
* callback - function to call when tweening is complete
* easing - easing function.  e.g. SimpleTween.easeIn
* 
* playTween(tween,time,callback) - plays a SimpleTween object and calls callback() when done
* getTweensOnMC(mc) - return an array of SimpleTween objects of the tweens currently operating on the MovieClip mc
* removeTweensOnMC(mc) - removes all tweens currently operating on the MovieClip mc
*/
package com.oddcast.utils {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	public class SimpleTweenManager {
		private static var tweenArr:Array=[];
		
		public static function playTween(tween:SimpleTween, time:Number,callback:Function) {
			tweenArr.push(tween);
			tween.addEventListener(Event.COMPLETE, tweenComplete);
			tween.callback = callback;
			tween.play(time);
		}
		
		public static function tweenMCTo(mc:DisplayObject, property:String, value:Object, time:Number, callback:Function=null, easing:Function = null) {
			var tween:SimpleTween = new SimpleTween(mc);
			tween.addTween(property, mc[property], value as Number, easing);
			playTween(tween, time, callback);
		}
		
		private static function tweenComplete(evt:Event) {
			var tween:SimpleTween = evt.target as SimpleTween;
			tween.removeEventListener(Event.COMPLETE, tweenComplete);
			tweenArr.splice(tweenArr.indexOf(tween), 1);
			if (tween.callback != null) tween.callback(tween);
			tween.callback = null;
		}
		
		public static function removeTween(tween:SimpleTween) {
			tween.stop();
			tween.removeEventListener(Event.COMPLETE, tweenComplete);
			var pos:int = tweenArr.indexOf(tween);
			if (pos >= 0) tweenArr.splice(pos, 1);
			tween.callback = null;
		}
		
		public static function getTweensOnMC(mc:DisplayObject):Array {
			var arr:Array = new Array();
			for (var i:int = 0; i < tweenArr.length; i++) {
				if (tweenArr[i].target == mc) arr.push(tweenArr[i]);
				else if ((mc is DisplayObjectContainer)&&(mc as DisplayObjectContainer).contains(tweenArr[i].target)) arr.push(tweenArr[i]);
			}
			return(arr);
		}
		
		public static function removeTweensOnMC(mc:DisplayObject) {
			var arr:Array = getTweensOnMC(mc);
			for (var i:int = 0; i < arr.length; i++) removeTween(arr[i]);
		}
	}
	
}