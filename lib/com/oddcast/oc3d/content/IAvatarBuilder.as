package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	public interface IAvatarBuilder extends IAvatarBuilderProxy 
	{
		function setActionsEnabled(b:Boolean):void;
		function actionsEnabled():Boolean;
		
		function downloadAvatar(name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		function unload():void;

		function accessoryShownSignal():Signal; // Signal<IAccessory>
		function accessoryHiddenSignal():Signal; // Signal<IAccessory>

		function setBuildingEnabled(b:Boolean):void;
		function buildingEnabled():Boolean;
		
		function restoreInitialState(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		function buildPackages(continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		function extractContentList():Dictionary; // Dictionary<nodeId:int, uri:String>
		function extractContentIds():Array; // Array<nodeId:int>
		
		function createDragNodeController(target:String, view:IViewport3D):Function;
		function createHitSpot(target:String, view:IViewport3D, offset:Vector3D, scaler:Number, visible:Boolean):IHitSpot;
		function talk(audio:IAudioProxy, morphDeformerName:String, triggerAudio:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function phonemePlayers():Dictionary // Dictionary<deformerName:String, IPhonemePlayer> 

		function loadAccessorySet(accessorySetId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		function selectedMaterialConfigurations():Vector.<IMaterialConfiguration>;
		function selectedDecalConfigurations():Vector.<IDecalConfiguration>;

		// continuationFn<>
		function inputConfiguration(xml:XML, continuationFn:Function=null, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<IAvatar>
		function newAvatar(name:String, stage:Stage, generate2d:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<IAccessory>
		function newAccessory(parent:*, name:String, uri:String, previewUrl:String, maskMode:MaskMode, defaultMaterialConfigurationId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ISlot>
		function newSlot(parent:IMaterialConfiguration, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IGroup>
		function newGroup(parent:*, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ISelector>
		function newSelector(parent:IGroup, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IMask>
		function newMask(parent:IAccessory, name:String, texture:ITextureProxy, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IPreset>
		function newPreset(parent:IAccessorySet, name:String, config:XML, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IDecalConfiguration>
		function newDecalConfiguration(parent:IAccessory, texture:ITexture, name:String, visible:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IModel>
		function newModel(parent:IAccessorySet, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<ISlot>
		function loadSlot(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IGroup>
		function loadGroup(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ISelector>
		function loadSelector(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IMask>
		function loadMask(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IPreset>
		function loadPreset(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IDecalConfiguration>
		function loadDecalConfiguration(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Model>
		function loadModel(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}