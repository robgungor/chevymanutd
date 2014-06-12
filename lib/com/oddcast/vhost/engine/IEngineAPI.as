package com.oddcast.vhost.engine
{
	//import com.oddcast.vhost.VHostConfigController;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	public interface IEngineAPI extends IEventDispatcher
	{
		//Player API
		function setFPS(fps:Number,isEvent:Boolean):void;
		function followCursor(b:Boolean):void;
		function say(url:String, sec:Number=0):void;
		function saySilent(sec:Number):void;
		function resume():void;
		function freeze(eyesOpen:Boolean = false):void;
		function stopSpeech():void;
		function recenter():void;
		function isFollowingCursor():Boolean;
		function setGaze(angle:uint,sec:Number,rad:Number,pageOrigin:Boolean=false):void;
		//function isGazing():Boolean;
		function setColor(part:String, hex:uint):void;
		function setLookSpeed(speedIndex:uint):void; //maybe revisit with dave could call direct values?
		function randomMovement(b:Boolean):void;
		function setMouthFrame(frame:uint):void;
		function configFromCS(cs:String):void //configs the host from a cs string
		function loadModel(url:String,doc:DisplayObjectContainer = null):void;
		function setActiveModel(model:MovieClip):Boolean;
		function getCurrentAudioProgress():Number; //return percent of current audio progress bet. 0-1
		function getMaxAgeFrames():uint;
		
		//Editor API
		//function getConfigController():VHostConfigController;
		function getConfigString():String;
		function setMouthPath(mc:MovieClip):void;
		function getOHUrl(incompatTypeArr:Array=null):String //returns the oh2 url ready for post
	}
}
