/**
* ...
* @author David Segal
* @version 0.1
* @date 01.28.08
* 
*/

package com.oddcast.player
{
	import flash.events.IEventDispatcher;
	
	public interface IPublicPlayerAPI extends IEventDispatcher
	{
		
		// public api
		function followCursor($mode:Number):void;
		function freezeToggle():void;
		function recenter():void;
		function setGaze($degrees:Number, $duration:Number, $radius:Number = 100, $page_req:Number = 0):void;
		function setFacialExpression($id:*, $duration:Number, $intensity:Number = 100, $attack:Number = 0, $decay:Number = 0):void;
		
		function loadAudio($name:String):void;
		function loadText($text:String, $voice:String, $lang:String, $engine:String, $fx_type:String="", $fx_level:String="", $origin:String = ""):void;
		function sayAudio($name:String, $startTime:Number = 0):void;
		function sayText($text:String, $voice:String, $lang:String, $engine:String, $fx_type:String="", $fx_level:String="", $origin:String = ""):void;
		function sayAIResponse($text:String, $voice:String, $lang:String, $engine:String, $bot:String = "0", $fx_type:String="", $fx_level:String="", $origin:String = ""):void;
		function saySilent($seconds:Number):void;
		function setPlayerVolume($vol:Number):void;
		function setStatus($interrupt:Number = 0, $progressInterval:Number = 0, $gazeSpeed:Number = -1, $randomMoves:Number = -1):void;
		function stopSpeech():void;
		function sayByUrl($url:String):void;
		function sayTextExported($text:String, $voice:String, $lang:String, $engine:String, $fx_type:String = "", $fx_level:String = "", $origin:String = ""):void;
		function sayAudioExported($name:String, $start:Number = 0):void;

		function setBackground($name:String):void;
		function setColor($part:String, $color:String):void;
		function setLink($url:String, $target:String = "_blank"):void;

		function gotoNextScene():void;
		function gotoPrevScene():void;
		function gotoScene($scene:Object):void;
		function loadShow($scene:int):void;
		/**
		 * Preloads all the assets for the next scene in a show to memory
		 * 
		 * @event SCENE_PRELOADED:VHSSEvent - scene preloaded to memory
		 */
		function preloadNextScene():void;
		/**
		 * Preloads all the assets of a scene in the show to memory
		 * 
		 * @param $num the index of the scene in the show to preload
		 * 
		 * @event SCENE_PRELOADED:VHSSEvent - scene preloaded to memory
		 */
		function preloadScene($num:Number):void;
		function replay($force_replay:Number = 0):void;
		function setNextSceneIndex($scene:Object):void

	}
}