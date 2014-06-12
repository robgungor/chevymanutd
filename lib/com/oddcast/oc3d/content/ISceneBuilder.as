package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.IViewport3D;
	import com.oddcast.oc3d.shared.Signal;
	
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public interface ISceneBuilder extends IContentBuilder
	{
		function avatarAddedSignal():Signal;
		function avatarRemovedSignal():Signal;
		function mapAddedSignal():Signal;
		function mapRemovedSignal():Signal;

		function selectionManager():IMultiSelectionManager;
		
		// continuationFn:Function<ISceneSet>
		function loadSceneSet(id:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void

		// continationFn:Function<IAvatar>
		function loadAvatar(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function removeAvatar(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
			
		// continuationFn:Function<IMap>
		function loadMap(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function removeMap(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function tryPickAvatar(view:IViewport3D, screenPos:Point):IAvatar;
		function tryPickAvatarInstance(view:IViewport3D, screenPos:Point):IAvatarInstance;
		
		// avatar stuff
		//function addPreloadedAvatar(avatar:IAvatar):void;
		//function removePreloadedAvatar(avatar:IAvatar):void;
		function loadedAvatars():Dictionary;
		function tryFindPreloadedAvatar(id:int):IAvatar;
		
		// map stuff
		//function addPreloadedMap(map:IMap):void;
		//function removePreloadedMap(map:IMap):void;
		function loadedMaps():Dictionary;
		function tryFindPreloadedMap(id:int):IMap;
		
		// objects
		function newAvatarParameter(parent:ISceneSet, name:String, avatarId:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function loadAvatarParameter(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function updateAvatarParameter(parameter:IAvatarParameter, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function removeAvatarParameter(parameter:IAvatarParameter, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function newMapParameter(parent:ISceneSet, name:String, mapId:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function loadMapParameter(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function updateMapParameter(parameter:IMapParameter, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function removeMapParameter(parameter:IMapParameter, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function start(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function stop(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		function loadInstances(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		function saveInstances(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		function updateInstances():void;
		function avatarInstanceNames():Vector.<String>;
		function tryFindAvatarInstance(instanceName:String):IAvatarInstance;
	}
}