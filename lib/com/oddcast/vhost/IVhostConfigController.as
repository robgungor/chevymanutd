package com.oddcast.vhost
{
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.vhost.engine.IEngineAPI;
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	public interface IVhostConfigController extends IEventDispatcher
	{
		function init(model:MovieClip,accessoryGroup:Boolean=false):void;
		function setEngine(engine:IEngineAPI):void;
		//configController
		function setScale(hostPart:String,percent:Number):void;
		function setAccessory(acc:AccessoryData):void;
		function setInitialAccessories(ohObj:Object):void;
		function setInitialAccessoryArr(accArr:Array):void;
		//base engineController
		function setScaleVal(hostPart:String,scaleVal:Number):void ;
		function setAge(percent:Number):void;
		function setAlpha(hostPart:String,percent:Number):void;
		function setColor(hostPart:String,transObj:Object):void;
		function setHexColor(hostPart:String,hexCol:uint):void;
		//configController
		function getHexColor(grpName:String):Number;
		function getMembers(grpName:String):Array;
		function getColorSections():Array;
		function getColorTransforms():Array;
		function getAccessorySections():Array;
		function getScaledSections():Array;
		function getAlphaSections():Array
		function getSelectedAccessoriesByName():Object;
		function getSelectedAccessoriesById():Array;
		function getSelectedAccessory(typeId:Number):AccessoryData;
		function getAgeSections():Array;
		function getAccessoryRef(s:String):Array;
		function getTypedAccessorySections():Array;
		function getScalePercent(s:String):Number;		
		function getHiddenAccessories():Array;		
		//function getGeneratorString(template:String):String;		
		function getConfigString():String;//oldstyle
		function getOHObj():Object;
		//base engine controller
		function getScale(hostPart:String):Number;
		function getColor(hostPart:String):Object;
		
		
				
	}
	
}