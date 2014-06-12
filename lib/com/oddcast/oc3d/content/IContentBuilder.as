package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	
	public interface IContentBuilder
	{
		function setThrottleFactor(factor:Number):void;
		
		function preloadManifestEnabled():Boolean;
		function setPreloadManifestEnabled(b:Boolean):void;

		function tryFindCachedFarNode(nodeSetId:int, id:int, onlyTheseTypes:Array=null):INodeProxy;
		function tryFindCachedNode(id:int, onlyTheseTypes:Array=null):INodeProxy;

		function protocolManager():IProtocolManager;

		function mousePress(view:IViewport3D, e:MouseEvent, failedFn:Function=null):void;
		function mouseRelease(view:IViewport3D, e:MouseEvent, failedFn:Function=null):void;
		function mouseDoubleClick(view:IViewport3D, e:MouseEvent, failedFn:Function=null):void;
		function mouseMove(view:IViewport3D, e:MouseEvent, failedFn:Function=null):void;

		// continuationFn:Function<IAudioProxy>
		function loadExternalAudio(url:String):IAudioProxy;

		function downloadFile(relativeUri:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<IBlispNode>
		function evaluateMainScript(cmd:String, continuationFn:Function):void;
		// continuationFn:Function<IBlispNode>
		function evaluatePrebuildScript(cmd:String, continuationFn:Function):void;
		// continuationFn:Function<IBlispNode>
		function evaluatePostbuildScript(cmd:String, continuationFn:Function):void;

		function materialConfigurationChangedSignal():Signal; // Signal<IMaterialConfiguation>
		
		function thumbnailChangedSignal():Signal; // Signal<IThumbnail>

		function kernel():IContentKernel;
		
		// DEPRECATED continuationFn:Function<INode> 
		function loadNode(type:Class, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void; 
		// continuationFn:Function<INode>
		function tryFindNode(type:Class, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<INode>
		function tryFindFarNode(nodeSetId:int, type:Class, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// typeFn:Function<Class>
		function forEachType(typeFn:Function):void;

		function nodeSet():INodeSet;
		
		// returns null if property does not exist
		function tryGetProperty(propertyName:String):String;
		function setProperty(propertyName:String, value:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;


		function scene():IScene3D;
		
		// continuationFn:Function<Association>
		function newFarAssociation(parent:*, child:*, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function
		function removeFarAssociation(parent:*, child:*, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Association>
		function newAssociation(parent:*, child:*, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function removeAssociation(parent:*, child:*, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<IMaterial>
		function newMaterial(parent:IFolder, name:String, perspectiveCorrectionEnabled:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ITextureMaterialLayer>
		function newTextureMaterialLayer(parent:IMaterial, name:String, blendingMode:BlendingMode, texture:ITextureProxy, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IColorMaterialLayer>
		function newColorMaterialLayer(parent:IMaterial, name:String, blendingMode:BlendingMode, color:Color, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ITexture>
		function newTexture(parent:INode, name:String, uri:String, colorTransform:Array, quality:Number, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ISwf>
		function newSwf(parent:INode, name:String, uri:String, colorTransform:Array, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void; 

		// continuationFn:Function<IMaterial>
		function loadMaterial(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ITextureMaterialLayer>
		function loadTextureMaterialLayer(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IColorMaterialLayer>
		function loadColorMaterialLayer(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ITexture>
		function loadTexture(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ISwf>
		function loadSwf(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<IScript>
		function newScript(parent:INode, name:String, code:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continationFn:Function<IScript>
		function loadScript(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<ICategory>
		function newCategory(parent:INodeProxy, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<ICategory>
		function loadCategory(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<Thumbnail>
		function newThumbnail(parent:INode, name:String, uri:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Thumbnail>
		function loadThumbnail(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<Folder>
		function newFolder(parent:*, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Folder>
		function loadFolder(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<IMaterialConfiguration>
		function newMaterialConfiguration(parent:INode, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IMaterialConfiguration>
		function loadMaterialConfiguration(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<IAnimation>
		function newAnimation(parent:IFolder, name:String, uri:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IAnimation>
		function loadAnimation(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<ICommand>
		function newCommand(parent:INodeSet, name:String, description:String, returnType:CommandArgType, arguments:Array, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void; // arguments:Dictionary<argName:String, type:CommandArgType>
		// continuationFn:Function<ICommand>
		function loadCommand(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<IProtocolBinding>
		function newProtocolBinding(node:INodeProxy, protocol:IProtocol, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IProtocolBinding>
		function loadProtocolBinding(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<IAudio>
		function newAudio(parent:IFolder, name:String, uri:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IAudio>
		function loadAudio(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<IAction>
		function newAction(name:String, adoptedProtocols:Vector.<IProtocol>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IAction>
		function loadAction(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<IBlob>
		function newBlob(parent:INode, name:String, data:ByteArray, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IBlob>
		function loadBlob(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<IFarNode>
		function newFarNode(parent:INode, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<IFarNode>
		function loadFarNode(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		function content():IContentProvider;
		
		function typeToString(obj:*):String;
		function stringToType(type:String):Class;
		
		function dispose():void;
	}
}