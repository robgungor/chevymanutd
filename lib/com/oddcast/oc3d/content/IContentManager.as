package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	public interface IContentManager
	{
		function loadedAvatarAddedSignal():Signal; // Signal<IAvatar>
		function loadedAvatarRemovedSignal():Signal; // Signal<>

		function thumbnailChangedSignal():Signal; // Signal<IThumbnail>
		
		// returns null if property does not exist
		function tryGetProperty(propertyName:String):String;

		function scene():IScene3D;
		
		// continuationFn:Function<Association>
		function newAssociation(parent:*, child:*, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function removeAssociation(parent:*, child:*, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<IMaterial>
		function newMaterial(parent:IMaterial, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ITextureMaterialLayer>
		function newTextureMaterialLayer(parent:IMaterial, name:String, blendingMode:BlendingMode, data:BitmapData, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IColorMaterialLayer>
		function newColorMaterialLayer(parent:IMaterial, name:String, blendingMode:BlendingMode, color:Color, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IScript>
		function newScript(parent:INode, name:String, code:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<IMaterial>
		function loadMaterial(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ITextureMaterialLayer>
		function loadTextureMaterialLayer(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IColorMaterialLayer>
		function loadColorMaterialLayer(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continationFn:Function<IScript>
		function loadScript(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continationFn:Function<IAvatar>
		function loadAvatar(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function addLoadedAvatar(avatar:IAvatar):void;
		function removeLoadedAvatar(avatar:IAvatar):void;
		function loadedAvatars():Dictionary;
		
		function content():IContentProvider;
	}
}