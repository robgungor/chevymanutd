package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.data.AvatarData;
	import com.oddcast.oc3d.data.SceneData;
	import com.oddcast.oc3d.shared.Image;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.media.Sound;
	
	public interface IResourceManager
	{
		function tryFindPreloadedAvatarData(uri:String):AvatarData;
		function tryFindPreloadedBitmap(uri:String):Image;
		function tryFindPreloadedSceneData(uri:String):SceneData;
		function tryFindPreloadedSound(uri:String):Sound;
		function tryFindPreloadedXML(uri:String):XML;
		function tryFindPreloadedSwf(uri:String):MovieClip;

		// continuationFn:Function<AvatarData>
		function accessAvatarData(uri:String, cache:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Image>
		function accessBitmap(uri:String, cache:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<SceneData>
		function accessSceneData(uri:String, cache:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Sound>
		function accessSound(uri:String, cache:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<XML>
		function accessXML(uri:String, cache:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:function<MovieClip>
		function accessSwf(uri:String, cache:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function freeAvatarData(uri:String):void;
		function freeBitmap(uri:String):void;
		function freeSceneData(uri:String):void;
		function freeSound(uri:String):void;
		function freeXML(uri:String):void;
		function freeSwf(uri:String):void;
		
		function enterTemporaryAvatarData(data:AvatarData):String;
		function enterTemporaryBitmap(data:Image):String;
		function enterTemporarySceneData(data:SceneData):String;
		function enterTemporarySound(data:Sound):String;
		function enterTemporaryXML(data:XML):String;
		function enterTemporarySwf(data:MovieClip):String;
	}
}