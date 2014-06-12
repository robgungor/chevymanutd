/****************************************************************************
Class name:

_____________________________________________________________________________

Written by:
Jonathan Achai

Date created:
9/3/2008

Description:
This class groups and simplifies tweens (from mx.transitions)

Requires:
Flash 9 and later

Library Requirements:

Usage:
1. Instantiate a Tweens Class object

2. Use the addTween public function:
	_mc:MovieClip - the movieclip to tween
	_prop:String - the property of the movieclip to tween
	_tweenType:Number (enum) - can have any of the following values:
		0 - None (default)
		1 - Regular
		2 - Strong
		3 - Elastic
		4 - Bounce
	_easeType:Number (enum) - can have any of the following values:
		0 - None (default)
		1 - EaseIn
		2 - Out
		3 - InOut
	_start:Number - the start value of the property assigned by _prop
	_end:Number - the end value of the property assigned by _prop
	_duration:Number - the duration of the tween

3. invoke the init() method to exectue all the added Tweens simultaneously

Returns:
the callback onTweensDone() will be invoked when the last Tween is finished


*/


package com.oddcast.animation
{	
	import fl.transitions.*;	
	import fl.transitions.easing.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.display.MovieClip;

	public class Tweens extends EventDispatcher
	{
		private var _arTweens:Array;	
		private var _nTweensLeft:Number;
		private var _nTweensId:Number;
		private var _nTotalDuration:Number;
		private var _arFilters:Array;
		private var _filterBlur:BlurFilter;
		
		function Tweens()
		{
			_arTweens = new Array();
			_nTotalDuration = 0;
		}
		
		public function addTween(_mc:MovieClip,_prop:String,_tweenType:Number,_easeType:Number,_start:Number,_end:Number,_duration:Number):void
		{
			_arTweens.push({mc:_mc,prop:_prop,type:getTweenEaseType(_tweenType,_easeType),start:_start,end:_end,dur:_duration});
			_nTotalDuration+=_duration;
		}
		
		public function init():void
		{	
			tween();	
		}
		
		private function tween():void
		{
			var l:Number = _arTweens.length;
			_nTweensLeft = l;
			for(var i:Number=0;i<l;++i)
			{
				var o:Object = _arTweens[i];
				var myTween:Tween = new Tween(o.mc, o.prop, o.type, o.start, o.end, o.dur, true);
				if (o.prop=="blur")
				{				
					_filterBlur = new BlurFilter(0,0,2);
				}
				myTween.addEventListener(TweenEvent.MOTION_CHANGE, onMotionChanged);// addListener(this);
				myTween.addEventListener(TweenEvent.MOTION_FINISH,onMotionFinished);// addListener(this);
				
				/*
					case "Alpha":
						mx.transitions.TransitionManager.start(o.mc, {type:mx.transitions.Fade, direction:o.direction, duration:o.dur, easing:o.type});
						break;
				}
				*/
			}
		}
		
		public function getDuration():Number
		{
			return _nTotalDuration*1000;
		}
		
		public function onMotionChanged(evt:TweenEvent = null):void
		{
			var tw:Tween = Tween(evt.target);
			if (tw.prop=="blur")
			{		
				
				_filterBlur.blurX = tw.obj[tw.prop];
				_filterBlur.blurY = _filterBlur.blurX;			
				_arFilters = new Array();
				_arFilters.push(_filterBlur);	
				tw.obj.filters = _arFilters;
				//hopefully solve a ui problem with leaving any blur filter (even 0) on
				if (tw.obj[tw.prop]==0)
				{				
					tw.obj.filters = new Array();
				}
			}
		}
		
		public function onMotionFinished(evt:TweenEvent = null):void
		{
			_nTweensLeft--;
			if (_nTweensLeft==0)
			{
				//broadcastMessage("onTweensDone", _nTweensId);
				dispatchEvent(new Event(Event.COMPLETE));
			}
			//trace("motionFinished")
		}
						
		public function setId(x:Number):void
		{
			_nTweensId = x;
		}
		
		public function getId():Number
		{
			return _nTweensId;
		}
		
		private function getTweenEaseType(t:Number,in_e:Number):Object
		{
			var o:Object;
			var e:String = getEaseType(in_e);
			switch(t)
			{
				case 0:			
					o = fl.transitions.easing.None[e];
					break;
				case 1:
					o = fl.transitions.easing.Regular[e];
					break;
				case 2:
					o = fl.transitions.easing.Strong[e];
					break;
				case 3:
					o = fl.transitions.easing.Elastic[e];
					break;
				case 4:
					o = fl.transitions.easing.Bounce[e];
					break;
				default:
					o = fl.transitions.easing.None[e];
			}
			return o;
		}
		
		private function getEaseType(e:Number):String
		{
			var s:String = "ease";
			switch(e)
			{
				case 0:
					s += "None";
					break;
				case 1:
					s += "In";
					break;
				case 2:
					s += "Out"
					break;
				case 3:
					s += "InOut";
					break;
				default:
					s += "None";				
			}
			return s;
		}
	}
}