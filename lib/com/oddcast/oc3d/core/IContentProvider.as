package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.INodeSet;
	import com.oddcast.oc3d.data.*;
	
	import flash.display.BitmapData;
	import flash.media.Sound;
	import flash.utils.*;
	
	// using CPS (continuation passing style) 
	
	public interface IContentProvider
	{
		function downloadAvatarObjectsData(nodeSetId:int, continuationFn:Function, failedFn:Function = null, progressedFn:Function = null):void
		
		// property querying function, returns null if property does not exist
		function selectProperty(nodeSetId:int, type:String, parentId:int, propertyName:String):String;
		function updateProperty(nodeSetId:int, parentId:int, propertyName:String, value:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		
		function preloadPackage(nodeSetId:int, assetIds:Array, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void; // assetIds:Array<int>
		
		function downloadAvatar(configData:XML, fullResData:ByteArray, disassembledTextures:Vector.<Vector.<ByteArray>>, lowResData:ByteArray, lowResTexture:Vector.<ByteArray>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// INSERTS
		// continuationFn<id:int>
		function insertFarAssociation(parentNodeSetId:int, parentType:String, parentId:int, childNodeSetId:int, childType:String, childId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertAssociation(nodeSetId:int, parentType:String, parentId:int, childType:String, childId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int, daeUrl:String>
		function insertAccessory(nodeSetId:int, name:String, slotString:String, data:ByteArray, maskMode:uint, defaultMaterialConfigurationId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertSlot(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertGroup(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertSelector(nodeSetId:int, name:String, defaultType:String, defaultId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertMaterial(nodeSetId:int, name:String, perspectiveCorrectionEnabled:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertTextureMaterialLayer(nodeSetId:int, name:String, blendingMode:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertColorMaterialLayer(nodeSetId:int, name:String, blendingMode:int, value:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertMaterialConfiguration(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continationFn<id:int>
		function insertFolder(nodeSetId:int, name:String, continuationFn:Function, failedfn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertMask(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int, daeUri:String>
		function insertAnimation(nodeSetId:int, name:String, data:ByteArray, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int, imgUri:String>
		function insertThumbnail(nodeSetId:int, name:String, data:BitmapData, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertScript(nodeSetId:int, name:String, code:String, isCompressed:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int, soundUrl:String>
		function insertAudio(nodeSetId:int, name:String, sound:Sound, hasViseme:Boolean, boundMorphName:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int, configDataUrl:String, avatarDataUri:String, avatarTexturesUri:String, lowResDataUrl:String, lowResTextureUrl:String>
		function insertAvatar(nodeSetId:int, name:String, configData:XML, data:ByteArray, disassembledTextures:Vector.<Vector.<ByteArray>>, lowResData:ByteArray, lowResTexture:Vector.<ByteArray>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertPreset(nodeSetId:int, name:String, config:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int, url:String>
		function insertTexture(nodeSetId:int, name:String, img:Vector.<ByteArray>, transformStr:String, width:String, height:String, hasAlpha:String, byteCount:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertDecalConfiguration(nodeSetId:int, name:String, visible:Boolean, blendingMode:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertCategory(nodeSetId:int, name:String, preloads:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertAction(nodeSetId:int, name:String, protocolIdString:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertItem(nodeSetId:int, name:String, data:ByteArray, slotString:String, defaultMaterialConfigurationId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertArea(nodeSetId:int, name:String, config:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertCommand(nodeSetId:int, name:String, description:String, signatureString:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertProtocolBinding(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int, url:String>
		function insertSwf(nodeSetId:int, name:String, data:ByteArray, transformStr:String, width:String, height:String, byteCount:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertAvatarParameter(nodeSetId:int, name:String, accessorySetId:String, avatarId:String, extra:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertMapParameter(nodeSetId:int, name:String, itemSetId:String, mapId:String, extra:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertBlob(nodeSetId:int, name:String, data:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertModel(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<id:int>
		function insertFarNode(nodeSetId:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		
		// UPDATES
		// continuationFn<daeUri:String>
		function updateAccessory(nodeSetId:int, id:int, name:String, slotString:String, data:ByteArray, maskMode:uint, defaultMaterialConfigurationId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateSlot(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateGroup(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateSelector(nodeSetId:int, id:int, name:String, defaultType:String, defaultId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateMaterial(nodeSetId:int, id:int, name:String, perspectiveCorrectionEnabled:Boolean, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateTextureMaterialLayer(nodeSetId:int, id:int, name:String, blendingMode:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateColorMaterialLayer(nodeSetId:int, id:int, name:String, blendingMode:int, value:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateMaterialConfiguration(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateFolder(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateMask(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<daeUri:String>
		function updateAnimation(nodeSetId:int, id:int, name:String, data:ByteArray, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateThumbnail(nodeSetId:int, id:int, name:String, data:BitmapData, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateScript(nodeSetId:int, id:int, name:String, code:String, isCompressed:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateAudio(nodeSetId:int, id:int, name:String, data:Sound, hasViseme:Boolean, boundMorphName:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		//function updateAvatar(id:int, name:String, configData:XML, fullResData:ByteArray, disassembledTextures:Vector.<Vector.<ByteArray>>, lowResData:ByteArray, texture:Vector.<ByteArray>, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updatePreset(nodeSetId:int, id:int, name:String, config:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<imgUrl:String>
		function updateTexture(nodeSetId:int, id:int, name:String, img:Vector.<ByteArray>, transformStr:String, width:String, height:String, hasAlpha:String, byteCount:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateDecalConfiguration(nodeSetId:int, id:int, name:String, visible:Boolean, blendingMode:uint, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateCategory(nodeSetId:int, id:int, name:String, preloads:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateAction(nodeSetId:int, id:int, name:String, protocolIdString:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<uri:String>
		function updateItem(nodeSetId:int, id:int, name:String, data:ByteArray, slotString:String, defaultMaterialConfigurationId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateArea(nodeSetId:int, id:int, name:String, config:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateCommand(nodeSetId:int, id:int, name:String, description:String, signatureString:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateProtocolBinding(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<uri:String>
		function updateSwf(nodeSetId:int, id:int, name:String, data:ByteArray, transformStr:String, width:String, height:String, byteCount:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateAvatarParameter(nodeSetId:int, id:int, name:String, accessorySetId:String, avatarId:String, extra:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateMapParameter(nodeSetId:int, id:int, name:String, itemSetId:String, mapId:String, extra:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateBlob(nodeSetId:int, id:int, name:String, data:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateModel(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn<>
		function updateFarNode(nodeSetId:int, id:int, name:String, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// DELETES
		// continuationFn:Function<>
		function deleteFarAssociation(parentNodeSetId:int, parentType:String, parentId:int, childNodeSetId:int, childType:String, childId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteAllFarAssociations(nodeSetId:int, nodeType:String, nodeId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteAssociation(nodeSetId:int, parentType:String, parentId:int, childType:String, childId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteAllAssociations(nodeSetId:int, nodeType:String, nodeId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteAccessory(nodeSetId:int, accId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteSlot(nodeSetId:int, sloId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteSelector(nodeSetId:int, selId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteGroup(nodeSetId:int, grpId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteMaterial(nodeSetId:int, matId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteTextureMaterialLayer(nodeSetId:int, layerId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteColorMaterialLayer(nodeSetId:int, layerId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteMaterialConfiguration(nodeSetId:int, configId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteFolder(nodeSetId:int, folderId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteMask(nodeSetId:int, maskId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteAnimation(nodeSetId:int, animId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteThumbnail(nodeSetId:int, thumbId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteScript(nodeSetId:int, scriptId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteAudio(nodeSetId:int, soundId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteAvatar(nodeSetId:int, avatarId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deletePreset(nodeSetId:int, presetId:int, continuationFn:Function, failedFn:Function=null, progresedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteTexture(nodeSetId:int, texturelId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteDecalConfiguration(nodeSetId:int, decalConfigurationId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteCategory(nodeSetId:int, categoryId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteAction(nodeSetId:int, actionId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteItem(nodeSetId:int, itemId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteArea(nodeSetId:int, areaId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteCommand(nodeSetId:int, cmdId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteProtocolBinding(nodeSetId:int, bndId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteSwf(nodeSetId:int, swfId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteAvatarParameter(nodeSetId:int, parameterId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteMapParameter(nodeSetId:int, parameterId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteBlob(nodeSetId:int, blobId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteModel(nodeSetId:int, modelId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<>
		function deleteFarNode(nodesetId:int, farNodeId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void; 
		
		
		// SELECTS
		// continuationFn:Function<Array<[type:String, id:int]>>
		// types:Array<node:String>
		function selectAssociatedChildren(nodeSetId:int, parentType:String, parentId:int, types:Array, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Array<[parent:String, parentId:int, child:Class, childId:int, parentSet:int, childSetId:int]>>
		function selectAllAssociations(nodeSetId:int, nodeType:String, nodeId:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void
		// continuationFn:Function<Object>
		function selectAccessory(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectSlot(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectGroup(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectSelector(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectMaterial(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectTextureMaterialLayer(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectColorMaterialLayer(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectMaterialConfiguration(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectFolder(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectMask(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectAnimation(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectThumbnail(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectScript(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectAudio(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectPreset(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectTexture(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectDecalConfiguration(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectCategory(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectAction(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectItem(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectArea(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectCommand(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectProtocolBinding(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectSwf(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectAvatarParameter(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectMapParameter(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectBlob(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectModel(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectFarNode(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;

		// continuationFn:Function<Object>
		function selectAvatar(nodeSetId:int, id:int, continationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		// continuationFn:Function<Object>
		function selectMap(nodeSetId:int, id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}