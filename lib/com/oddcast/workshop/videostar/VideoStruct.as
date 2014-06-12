/**
* ...
* @author Sam, Me^
* @version 0.2
* 
* @about an extension of the WSVideoStar class used for videostar workshops.
*/

package com.oddcast.workshop.videostar 
{
	import com.oddcast.assets.structures.*;
	import com.oddcast.audio.*;
	import com.oddcast.data.*;
	import com.oddcast.workshop.*;

	public class VideoStruct extends WSVideoStruct 
	{
		public var desc			:String;
		public var actors		:Array;
		public var keyFileArr	:Array;
		public var audio		:AudioData;
		public var cutoffTime	:Number;
		public var stopPoints	:Array;
		public var settings		:VideoSettings;
		
		public function VideoStruct($url:String, $id:int, $thumb:String, $name:String, $desc:String, $duration:Number, $actors:Array, $catId:int = -1, $catName:String = "")
		{
			super($url, $id, $thumb, $name, $catId);
			desc 		= $desc;
			duration 	= $duration;
			cutoffTime	= $duration;
			actors 		= $actors;
			catName 	= $catName;
		}
		
		/**
		 * a complete new reference/copy of this object
		 * @return
		 */
		public function clone():VideoStruct 
		{
			// clone actors
				var cloned_actors:Array			= new Array();
				for (var i:int = 0; i < actors.length; i++)
					cloned_actors.push( (actors[i] as ActorStruct).clone() );
			// clone keyfiles
				var cloned_keyfiles:Array		= new Array();
				for (i = 0; i < keyFileArr.length; i++ )
				{
					var cur_keyfile:LoadedAssetStruct = keyFileArr[i];
					var new_keyfile:LoadedAssetStruct = new LoadedAssetStruct( cur_keyfile.url, cur_keyfile.id, cur_keyfile.type );
					cloned_keyfiles.push( new_keyfile );
				}
			var cloned_video:VideoStruct	= new VideoStruct(url, id, thumbUrl, name, desc, duration, cloned_actors, catId, catName);
			cloned_video.keyFileArr			= cloned_keyfiles;
			if (audio)
				cloned_video.audio			= audio.clone();
			return(cloned_video);
		}
		
		public function set previewDuration(n:Number):void
		{
			//this is set when the preview is loaded (in mSec)
			//we don't really need thi value.  it is just a failsafe to set the cutofftime for the video
			//in case the php returned "0" for the video duration (which would break stuff)
			if (cutoffTime == 0) cutoffTime = n;
		}
		
		/**
		 * build a struct used for videostar 2.0 playback
		 * NOTE this is not a clone
		 * @return
		 */
		public function getV2PlaybackStruct():VS2PlaybackStruct 
		{
			var v:VS2PlaybackStruct = new VS2PlaybackStruct(url, id, audio);
			for (var i:int = 0; i < actors.length; i++) 
			{
				var actor	:ActorStruct		= actors[i];
				var key_file:LoadedAssetStruct	= keyFileArr[i];
				v.addActor(actor.model, key_file);
			}
			return(v);
		}
	}
	
}