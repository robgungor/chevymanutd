/**
* ...
* @author Sam, Me^
* @version 2.2
*  
* This is the heart of the workshop.  It stores all the data about the current model, bg, and audio.
* It provides methods to change those things all well as color, size, accessories.  It provides
* callbacks when things are loaded or changed as well as speech callbacks.
* 
* There are two classes currently that implement this interface:  SceneController2D and SceneController3D
* they both inherit from SceneControllerBase, which has methods common to both 2d and 3d
* 
* Note: most of the BG functions have been moved to IBGLoader class to allow for custom bg loaders.
* You can access this with getBGMC()
* 
***************************** INITIALIZATION ******************************
* 
* constructor:
* SceneController(in_player:Sprite) - the scene is constructed by passing the movieclip ("player") where the scene (host/bg) will be loaded.
* By default, this will automatically set the location of the HostHolder movieclip, the BGHolder movieclip, and the host mask
* to the following locations:
* player.hostMask -> this is used for the mask for the host.
* it will be duplicated to create a mask for the bg. it also specifies the active area of the scene.
* player.hostMC -> this is an empty MC of class HostLoader where the host will be loaded
* player.bgMC -> this is an empty MC of class BGLoader where the bg will be loaded
* 
* you can also set these movieclips manually with these functions:
* function setHostMC($mc:HostLoader);
* function setBGMC($mc:IBGLoader);
* function setHostMask($mc:Sprite);		
* 
* once the locations of the player, host, bg, and mask are specified, initialize the scene controller by calling:
* function init();
* once initialized, you can't call setHostMC, setBGMC, or setHostMask again.
*
* you can retreive the HostLoader and IBGLoader objects and call functions directly on them using:
* function getHostMC():HostLoader;
* function getBGMC():IBGLoader
* 
* 
*************** EVENTS *****************
* 
* ProcessingEvent.STARTED
* ProcessingEvent.PROGRESS
* ProcessingEvent.DONE
* 
* returns these events whenever the scene starts/progresses/finishes processing something.  This is so
* you can block the workshop and show a loading bar.  Usually they accompany another callback.  These events are
* provided just for the convenience of showing processing bars.  Processing done doesn't necessarily mean
* it finished successfully.  It could have finished successfully or finished with an error
* 
* ProcesingEvent contains a property processName - which tells you what is being processed.
* Processes are:
* ProcessingEvent.MODEL - when model starts/finishes loading - note that the scene also returns a MODEL_LOADED event
* ProcessingEvent.AUDIO - when the host is loading audio to be played.
* STARTED coincides with when you call playSceneAudio() or previewaudio(), and DONE coincides with talkStarted or talkError
* ProcessingEvent.ACCESSORY - started is called when the accessory starts loading as long as there isn't another accessory already loading
* done is called when all accessories are done loading.
* 
* the ProcessingEvent.BG process is called by IBGLoader when the bg starts/finishes loading
* 
* MODEL_LOADED aka "configDone" - model is loaded
* AUDIO_UPDATED - a new audio has been selected
* COLOR_UPDATED - a color has been changed
* SIZING_UPDATED - when you change the sizing
* ACCESSORY_LOADED - accessory has been loaded
* ACCESSORY_LOAD_ERROR - there was an error loading the accessory
* TALK_STARTED - talk started
* TALK_ENDED - talk ended
* TALK_ERROR - there was an error with the audio
* 
* the BG_LOADED event is called by the IBGLoader class
*/

package com.oddcast.workshop 
{
	import com.oddcast.host.api.morph.*;
	import com.oddcast.vhost.accessories.*;
	import com.oddcast.workshop.*;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.*;
	import flash.display.*;
	import flash.events.*;
	import com.oddcast.audio.*;

	public interface ISceneController extends IEventDispatcher 
	{
		
//***************************** PROPERTIES ********************************

		/**current model loaded - null if none*/
		function get model():WSModelStruct;
		
		/**current bg loaded - null if none*/
		function get bg():WSBackgroundStruct;
		
		/**current audio selected - null if none*/
		function get audio():AudioData;
		
		/**zoomer object for manipulating host*/
		function get zoomer():MoveZoomUtil;
		
//***************************** INITIALIZATION ******************************

		/**by default, this is set to playerHolder.player.hostHolder
		this should be called before init()*/
		function setHostMC($mc:HostLoader):void;
		
		function getHostMC():HostLoader;
		
		/**by default, this is set to playerHolder.player.bgHolder
		this should be called before init()*/
		function setBGMC($mc:IBGLoader):void;
		
		function getBGMC():IBGLoader;
		
		/**by default, this is set to playerHolder.player.hostMask
		this should be called before init()*/
		function setHostMask($mc:Sprite):void;
		
		/**
		 * access to the full body controller class
		 */
		function get full_body(  ):IBody_Controller;
		function set full_body( _fb_controller:IBody_Controller ):void;
		/**
		 * check if the full body controller is initialized properly
		 * @return
		 */
		function full_body_ready():Boolean
		
		function init():void;
		
//******************************* BG FUNCTIONS *******************************

		/**this simply forwards the loadBG call to the IBGLoader object. it is equivalent to getBGMC().loadBG(bg)*/
		function loadBG(in_bg:WSBackgroundStruct):void;
		
		/**equivalent to getBGMC().loadBG(null)*/
		function unloadBG():void;
		
//******************************* AUDIO FUNCTIONS *******************************

		/**plays an audio without storing it in the scene*/
		function previewAudio(in_audio:AudioData):void;
		
		function stopAudio():void;
		
		/**plays the audio previously stored with the scene*/
		function playSceneAudio():void;
		
		/**stores audio in the scene without playing it.*/
		function selectAudio(in_audio:AudioData):void;
		
		/**clears stored audio so no audio is stored with the scene*/
		function clearAudio():void;
		
		/**		
		* ---3D only---
		* function sayMultiple(audioArr:Array)
		* pass an array of AudioData objects
		* the host will lipsync only to the first item in the array
		* the host will nod its head to the remaining items in the array.
		*/
		
//******************************* MODEL FUNCTIONS *******************************

		/**load WSModelStruct object
		will dispatch SceneEvent.MODEL_LOADED when done*/
		function loadModel(in_model:WSModelStruct, _force_clean_reload:Boolean = false ):void;
		
		/**reset host position*/
		function resetHost():void;
		
		function freeze():void;
		function resume():void;
		
//******************************* MORPH MODEL FUNCTIONS *******************************
		
		/**
		 * loads the back model, morphs the face with the head
		 * @param	_target_model model whos face will be visible
		 * @param	_back_model the back of the head of the model
		 * @param	_color_dominance color setting
		 * @param	_morph_class morphing class to use... 
		 * for example "MorphPhotoFaceUsersSkintone" for workshops and "MorphPhotoFaceVideoStar" for videostar
		 */
		function morph_models( _target_model:WSModelStruct, _back_model:WSModelStruct, _color_dominance:Boolean, _morph_class:Class ):void;
		
		/**	apply the morph color dominancy either to the face or to the head	*/
		function change_color_analyzer( _value:Boolean ):void;
		
//******************************* ACCESSORY FUNCTIONS *******************************
		
		/**SceneEvent.ACCESSORY_LOADED or SceneEvent.ACCESSORY_LOAD_ERROR will be called when done*/
		function loadAccessory($acc:AccessoryData):void;
		
		/**
		 *unload accessoies by type id 
		 * @param $typeId	type of accessory
		 * 
		 */		
		function removeAccessory($typeId:int):void;
		
		/**unloads all accessories*/
		function removeAllAccessories():int;
		
		/**returns an array of numbers representing type ids of available accessory types - not yet implemented*/
		//function getAccTypes():Array;
		
		/**returns an associative array of AccessoryData objects, indexed by typeId, of currently selected accessories*/
		function getAccessories():Object;
		
//******************************* COLOR FUNCTIONS *******************************

		/**returns an array of HostColorData objects which contains:
		-the group name (to be displayed  e.g. eyes/mouth, etc.),
		-the group type (for internal use only e.g. model, accessory, etc.)
		-and the initial hex color value as a uint.*/
 		function getColors():Array;
		
		/**set color of given item.  grp is the HostColorData object
		containg the group name and group type, and the default color value.  hexVal is the new color value.*/
		function setHexColor(grp:HostColorData, hexVal:uint):void;
		
//******************************* SIZING FUNCTIONS *******************************

		/**getRanges() - returns an array of com.oddcast.vhost.ranges.RangeData objects containing
		the group name (to be displayed  e.g. Nose - Long/Short, Eyes - Open/Closed),
		the group type (for internal use only e.g. basic, advanced)
		initial default value (a Number from 0-1)*/
		function getRanges():Array;
		
		/**returns scale of item with given group name (eg "mouth") and type.  Type is required for
		3D controller - but optional for 2D controller - types of each item are returned with getRanges() function
		returns a number between 0-1*/
		function getScale(grpName:String, grpType:String = ""):Number;
		
		/**sets scale of item where -value is a number between 0-1,
		-name is the group name that you get from the RangeData object
		-type is the group type that you get from the RangeData object*/
		function setScale(grpName:String, val:Number, grpType:String = ""):void;
		
/***************************** 3D ONLY SPECIALIZED FNS *****************************
* 
* function getExpressions():Array - returns an array of available expression strings (eg. ["happy","sad","angry"])
* function setExpression(expression:String, amount:Number = 1) - sets the expression
* -expression is a string you get from getExpressions (e.g. "happy")
* -amount is a value from 0-1
* 	
*/

//******************************* SAVING/OTHER FUNCTIONS *******************************
		
		/***
		 * builds a SceneStruct object used for saving the entire scene including full body and head if available
		 * @param	_callbacks	.fin( SceneStruct )  |  .progress( int )  |  .error( String )
		 */
		function compile_scene( _callbacks:Callback_Struct ):void;
		
		/**returns whether the scene has changed since last call to compileScene()*/
		function sceneChangedSinceLastSave():Boolean;
	
		/**unload everything and remove the scene controller object from memory*/
		function destroy():void;
	}
	
}