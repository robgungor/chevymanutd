/**
* ...
* @author David Segal
* @version 0.1
* @date 01.28.08
* 
*/

package com.oddcast.player
{
	import com.oddcast.assets.structures.*;
	
	import flash.display.Sprite;
	

	/**
	 * Internal interface for the VHSS v5 player. Used by the editors and shell players.
	 */
	public interface IInternalPlayerAPI extends IPublicPlayerAPI
	{
		/**
		 * Get a pointer to the engine api. Can be reference to either the 
		 * 2d or the 3d engine. In the case of the 2d engine the return value can 
		 * be safely cast to a <code>MovieClip</code>.
		 * 
		 * @return Reference to the engine api as an <code>Object</code>. 
		 */
		function getActiveEngineAPI():Object;
		/**
		 * Get the active audio url
		 * 
		 * @return Url of the active audio as a <code>String</code>.
		 */
		function getAudioUrl():String;
		/**
		 * Get a pointer to the <code>Sprite</code> where that stack of backgounds sits 
		 * 
		 * @return <code>Sprite</code> that contains the stack of backgrounds
		 */
		function getBGHolder():Sprite
		/**
		 * Get a pointer to the <code>Sprite</code> where that stack of hosts sits 
		 * 
		 * @return <code>Sprite</code> that contains the stack of hosts
		 */
		function getHostHolder():Sprite;
		/**
		 * Get the show xml. The show xml defines all the assets and properties of
		 * a show or scene. Can be used to retrieve any special parameters that were added to the xml
		 * that the show might ignore such as 'extradata'
		 * 
		 * @return <code>XML</code> of the show. See Oddcast wiki for xml schema
		 */
		function getShowXML():XML;
		/**
		 * 
		 * Initialize the show (display list) of the player. This is only necessary when you need to load assets into a player that
		 * does not start with or use some show xml.
		 * 
		 */
		 function initBlankShow():void;
		/**
		 * Load a background in the current scene. Loaded background will only apply to the immediate state of the
		 * scene. Navigating away from the scene and back again will result in the background returning to it's original state.
		 * 
		 * @param $bg <code>BackgroundStruct</code> of the background to apply. Passing <code>null</code> will remove the active background
		 * 
		 * @event bg_loaded:VHSSEvent - background has loaded. 
		 */
		function loadBackground($bg:BackgroundStruct):void;
		/**
		 * Load a host. Replaces the currently loaded host. If switch 2d to 3d or 3d to 2d you should also get a new reference to the
		 * engine api if one is stored
		 * 
		 * @param $host <code>HostStruct</code> of the new host to load.
		 */
		function loadHost($host:HostStruct):void;
		/**
		 * Load the show xml for this playback session
		 * 
		 * @param $in_doc the url to the show xml for this playback session
		 */
		function loadShowXML($in_doc:String):void;
		/**
		 * Load a skin to the stack of available skins. 
		 * 
		 * @param $skin <code>SkinStruct</code> to load.
		 * 
		 * @event SKIN_LOADED:VHSSEvent - skin has loaded
		 */
		function loadSkin($skin:SkinStruct):void;
		/**
		 * Set the player initialization flags. Used to control the start-up behavior of the player. See
		 * <code>com.oddcast.player.PlayerInitFlags</code> for flags that can be set and their definition. Should be set
		 * after the <code>Event.COMPLETE</code> from the <code>URLLoader</code> of the player
		 */
		function setPlayerInitFlags($i:int):void;
		/**
		 * Set the appearance of the skin. 
		 * 
		 * @param $xml skin configuration as <code>XML</code>
		 */
		function setSkinConfig($xml:XML):void;
		/**
		 * Set that show playback xml.
		 * 
		 * @param $xml show data as <code>XML</code>
		 */
		function setShowXML($xml:XML):void;
		/**
		 * Starts a show that has its xml set via the <code>setShowXML</code> api 
		 */
		function startShow():void;
		/**
		 * Sets the audio structure for a scene. This audio will behave under the rules for audios 
		 * that are saved with a scene
		 * 
		 * @param $audio <code>AudioStruct</code> that defines the scene audio
		 * 
		 */
		function setSceneAudio($audio:AudioStruct):void
		/**
		 * Sets the scene size for full-body 3d scenes
		 * 
		 * @param $w scene width
		 * @param $h scene height
		 * 
		 */
		function set3DSceneSize($w:int, $h:int):void
	}
}