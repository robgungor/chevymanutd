package com.oddcast.ai.tts2animation 
//import com.oddcast.ai.tts2animation.ITTS2AnimationAnalyzer;
{
	
	/**
	 * ...
	 * @author Jake 3/2/2011 5:29 PM
	 */
	
	import com.oddcast.workshop.fb3d.playback.FB3dControllerPlayback;
	
	public interface ITTS2AnimationAnalyzer 
	{
		function init(controller:FB3dControllerPlayback, avatarInstanceName:String):void;
		function say(controller:FB3dControllerPlayback, text:String, finishedCallback:Function=null):void;
		function destroy():void;
	}
	
}