/**
* @author Sam Myer
* 
* These are the functions that are necessary for the SceneController to interact with the background loader.
* This interface is implemented by workshop.uploadphoto.BGController
* 
* The BGController class is typically linked to a movieclip on the stage.
* 
* I didn't want to put the background loader itself in the shared classes, becuase this will need to be
* customized.  So, you can use any class you want now to load the backgrounds as long as it implements these functions:
*/

package com.oddcast.workshop {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	
	public interface IBGLoader extends IEventDispatcher {
		function loadBG($bg:WSBackgroundStruct):void;
		function setMask($mask:DisplayObject):void;
		function get bg():WSBackgroundStruct;
		function get bgPosition():Matrix;
		function set bgPosition(m:Matrix):void;
	}
	
}