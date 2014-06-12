package com.oddcast.animation
{	

	import fl.transitions.*;
	import fl.transitions.easing.*;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class TransitionMaker
	{	
		
		private var tw:Tweens;
		
		public function TransitionMaker(mc:MovieClip,time:Number,typeId:Number,o:Object)
		{
					
			o.start = o.start==null?0:o.start;
			o.end = o.end==null?1:o.end;
			//trace("TransitionMaker::transition mc="+mc+", time="+time+", typeId="+typeId);
			tw = new Tweens();
			tw.addEventListener(Event.COMPLETE, ev_TranstionComplete);
			switch(typeId)
			{
				case 2: //fade
					tw.addTween(mc,"alpha",1,2,o.start,o.end,time);
					tw.init();												
					break;
				case 3:				
					tw.addTween(mc,"scaleX",1,2,o.start,o.end,time);
					tw.addTween(mc,"scaleY",1,2,o.start,o.end,time);
					tw.init();		
					break;
				case 4:				
					tw.addTween(mc,"x",1,2,o.w/2,mc.x,time);
					tw.addTween(mc,"y",1,2,o.h/2,mc.y,time);
					tw.addTween(mc,"scaleX",1,2,o.start,o.end,time);
					tw.addTween(mc,"scaleY",1,2,o.start,o.end,time);
					tw.init();		
					break;
				case 5:
					tw.addTween(mc,"x",1,2,-o.w,mc.x,time);
					tw.init();
					break;
				case 6:
					//_global['setTimeout'](TransitionMaker,'onTweensDone',time);
					TransitionManager.start(mc,{type:fl.transitions.PixelDissolve, direction:fl.transitions.Transition.IN, duration:time, easing:fl.transitions.easing.Back.easeInOut, xSections:mc.width/10, ySections:mc.width/10});
					//mx.transitions.TransitionManager.start(mc, {type:mx.transitions.PixelDissolve, direction:mx.transitions.Transition.IN, duration:time, easing:mx.transitions.easing.Back.easeInOut, xSections:mc._width/10, ySections:mc._width/10});
					break;
				case 7:
					//_global['setTimeout'](TransitionMaker,'onTweensDone',time);
					TransitionManager.start(mc, {type:fl.transitions.Squeeze, direction:fl.transitions.Transition.IN, duration:time, easing:fl.transitions.easing.Back.easeInOut, dimension:1});
					//mx.transitions.TransitionManager.start(mc, {type:mx.transitions.Squeeze, direction:mx.transitions.Transition.IN, duration:time, easing:mx.transitions.easing.Back.easeInOut, dimension:1});
					break;
				default:
					//busy = false;
			}			
		}
		
		public function destroy():void
		{
			tw.removeEventListener(Event.COMPLETE, ev_TranstionComplete);
			tw = null;
		}
		
		private function ev_TranstionComplete($ev:Event):void
		{
			
		}
			
	}
}