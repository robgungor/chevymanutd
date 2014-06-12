/**
* ...
* @author Jonathan Achai
* @version 0.1
 * This class provides with an easy API to adjust playback morphing
 * 1. Pass a PlaybackEngine API to initialize.
 * 2. Use setMorphInfluence with label and percent to change morphing percentages 
*/

package com.oddcast.workshop
{
	import com.oddcast.host.api.EditorAPI;
	import com.oddcast.host.api.morph.MorphInfluencePlayback
	
	public class MorphingPlayback
	{
		
		private var api:*;
		
		public function MorphingPlayback(in_api:*)
		{
			api = in_api;
		}
		
		public function setMorphInfluence(label:String, percent:Number):void
		{
			var mip:MorphInfluencePlayback = api.getMorphTarget(label);
			mip.setGlobalWeight(percent);
		}

	}
}