package com.oddcast.host.api {
	import flash.filters.ColorMatrixFilter;
	import com.oddcast.host.api.AccessoryDescription;
	import com.oddcast.host.api.morph.MorphInfluence;
	import com.oddcast.host.api.IHostAPI;
	public interface IEditorAPI extends com.oddcast.host.api.IHostAPI{
		function setUpIsConfigured() : void ;
		function CTLComplete() : void ;
		function isReadyToEdit() : int ;
		function getEditorList(type : String) : Array ;
		function setButton(controlName : String,set : Boolean,undoFlags : int) : void ;
		function getButton(controlName : String) : Boolean ;
		function setColor2(controlName : String,color : int,undoFlags : int) : void ;
		function getColor2(controlName : String) : int ;
		function loadXML(xmlStr : String) : Array ;
		function getURL(type : String) : String ;
		function generateRandom(randomness : Number,quantity : int,width : int,height : int) : Array ;
		function getPhotoBoundaries() : Array ;
		function getPhotoBoundaries2() : Array ;
		function getMeshScreenExtents(modelType : int) : Array ;
		function setOffPhotoColor(offPhotoColor : int) : int ;
		function selectRandom(index : int) : int ;
		function freeFormDeform(mouseX : Number,mouseY : Number,state : int,symmetric : int,power : Number) : int ;
		function unloadAllAccessories() : void ;
		function loadAccessory(accessoryDescription : com.oddcast.host.api.AccessoryDescription,accessoryTypeID : String,undoFlags : int) : String ;
		function setMorphTarget(xml : String,plabel : String) : com.oddcast.host.api.morph.MorphInfluence ;
		function removeMorphTarget(morphInf : com.oddcast.host.api.morph.MorphInfluence) : com.oddcast.host.api.morph.MorphInfluence ;
		function getMorphEditValue(morphInf : com.oddcast.host.api.morph.MorphInfluence,controlName : String) : Number ;
		function setMorphEditValue(morphInf : com.oddcast.host.api.morph.MorphInfluence,controlName : String,value : Number) : Number ;
		function setSkinToneBounding(r : Number,g : Number,b : Number) : void ;
		function getSkinToneBounding() : Array ;
		function getSkinToneColorMatrix(index : int) : flash.filters.ColorMatrixFilter ;
		function getFile(fileType : String) : Array ;
		function getFaceSkinColor() : int ;
		function setFgFilter(morphInf : com.oddcast.host.api.morph.MorphInfluence,plabels : String,index : int,weight : Number) : int ;
		function getFgFilter(morphInf : com.oddcast.host.api.morph.MorphInfluence,plabel : String) : Number ;
		function hasHostChangedSinceLastSave() : Boolean ;
		function setRaceCoordinates(x : Number,y : Number) : void ;
		function stopRaceCoordinates() : void ;
		function burnCurrentToMorphAnimation(plabel : String,channelflags : int) : Boolean ;
		function removeToMorphAnimation(plabel : String) : Boolean ;
		function usePhotoColorForSkinTone(bUsePhotoColor : Boolean) : void ;
		function getSkinToneHSB(influenstStr : String) : Array ;
	}
}
