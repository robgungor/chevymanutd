/****************************************************************************
Class name:
<VhostConfigController>

_____________________________________________________________________________

Written by:
Jonathan Achai

Date created:
1/10/2008

Description:
Interface to manage the vhost character groups and configuration

Requires:
Flash 9 

Library Requirements:

Modifications:


Usage:
1. Instantiate the VhostConfigController
2. call init with the vhost movieclip as a parameter
3. Use addEventListener() for VHostController Events
Example for a user:
var vhostCtrl:VHostConfigController = new VHostConfigController();
vhostCtrl.init(mc);
vhostCtrl.addEventListener(VhostConfigControllerEvent.ACCESSORY_LOADED,accessoryLoaded);

Methods:

************************
 Set functions
************************

public setScale(group:String, percent:Number) : Void
------------------------------------------------------------------------------
Sets the scale of a vhost group based on the percentage of its possible values

Parameters
group:String - The name of a group to scale. (e.g. mouth, body, etc.)

percent:Number - Percent of the range of values. Between 0.0 and 1.0

public setScaleVal(group:String, val:Number) : Void*
------------------------------------------------------------------------------
Sets the scale of a vhost group based on the actual scale value

Parameters
group:String - The name of a group to scale. (e.g. mouth, body, etc.)

val:Number - The scale value

*This function can basically override the allowed range so be carefull

public setAge(percent:Number) : Void
------------------------------------------------------------------------------
Sets the age of the host by going to a frame in all the age group movieclips. (Currently uses 45 frames for aging)

Parameters

percent:Number - Percent of the age range. Between 0.0 and 1.0

public setAlpha(group:String, percent:Number) : Void
------------------------------------------------------------------------------
Sets the alpha property of a vhost alpha group based on the percentage of its possible values.

Parameters
group:String - The name of a group to scale. (e.g. blush, make-up)

percent:Number - Percent of the range of values. Between 0.0 and 1.0

public setColor(group:String, transObj:Object) : Void*
------------------------------------------------------------------------------
Sets the color transform of a vhost color group based on the Transfrom Object 

Parameters
group:String - The name of a group to color. (e.g. mouth, skin, eyes, etc.)

transObj:Object - Transform object

*This function uses a slight variant of the Transform Object based on the color picker values

public setAccessory(acc:Accessory) : Void
------------------------------------------------------------------------------
Sets the accessory on a vhost. 
The function loads, and hides incompatible accessoires and triggers the accessoryLoaded and accessoryIncompatible callbacks.

Parameters
acc:Accessory - The accessory object (see com.oddcast.vhost.accessories.Accessory)

************************
 Get functions
************************

public getColor(group:String) : Object*
------------------------------------------------------------------------------
Returns the color transform object of a vhost color group.

Parameters
group:String - The name of a group to color. (e.g. mouth, skin, eyes, etc.)

*The color transform object returned is a slight variant of the Transform Object based on the color picker values
 
public getScalePercent(group:String) : Number
------------------------------------------------------------------------------
Returns the scale percentage of a specific vhost range group.

Parameters
group:String - The name of a range group. (e.g. width, mouth, nose, etc.)

public getScale(group:String) : Number
------------------------------------------------------------------------------
Returns the actual scale of a specific vhost range group.

Parameters
group:String - The name of a range group. (e.g. width, mouth, nose, etc.)

public getColorSections() : Array
------------------------------------------------------------------------------
Returns an associative array of available and compatible color sections (based on the c_grp) in the following structure:
arr["mouth"] = true;
arr["eyes"] = true;
.
.
This function can be used with the ColorPanel component (com.oddcast.vhost.editor.colorTweak.color.ColorPanel)

public getAccessorySections() : Array
------------------------------------------------------------------------------
Returns an associative array of available and (compatible?) accessories (based on the a_grp) in the following structure:
arr["mouth"] = true;
arr["costume"] = true;
.
.

public getTypedAccessorySections() : Array
------------------------------------------------------------------------------
Returns an array of {name,active,typeId} of available and (compatible?) accessories (based on the a_grp) in the following structure:
arr[0] = {"mouth",true,12};
arr[0] = {"hat",true,9};
.
.

public getScaledSections() : Array
------------------------------------------------------------------------------
Returns an associative array of available and compatible scalable sections (based on the range array) in the following structure:
arr["mouth"] = true;
arr["body"] = true;
.
.
This function can be used with the TweakPanel component (com.oddcast.vhost.editor.colorTweak.tweak.TweakPanel)

public getAgeSections() : Array
------------------------------------------------------------------------------
Returns an associative array with one element of the age percentage value in the following structure:
arr["age"] = percent:Number;

This function can be used with the TweakPanel component (com.oddcast.vhost.editor.colorTweak.tweak.TweakPanel)

public getColorTransforms() : Array
------------------------------------------------------------------------------
Returns an associative array of the color transforms in the following structure:
arr["mouth"] = Object; //color transform
arr["eyes"] = Object; //color transform
.
.

public getSelectedAccessoriesById() : Array
------------------------------------------------------------------------------
Returns an associative array of accessory objects (see com.oddcast.vhost.accessories.Accessory) including hidden ones due to incompatibility in the following structure:
arr[12] = Accessory;
arr[9] = Accessory;
.
.

public getSelectedAccessoriesByName() : Object //written by Sam Meyer
------------------------------------------------------------------------------
Returns an Object with accessory objects (see com.oddcast.vhost.accessories.Accessory) including hidden ones due to incompatibility in the following structure:
o.mouth = Accessory;
o.hat = Accessory;
.
.

public getSelectedAccessory(accessoryTypeId:Number) : Accessory
------------------------------------------------------------------------------
Returns an Accessory object (see com.oddcast.vhost.accessories.Accessory) including hidden ones due to incompatibility in the following structure

Parameters
accessoryTypeId:Number - The accessory type id to retrieve (e.g. 12, 9, etc.)

public getAccessoryRef(accessoryTypeName:String) : Array
------------------------------------------------------------------------------
Returns an array of references (pointers) to the accessory's actual movieclips

Parameters
accessoryTypeId:Number - The accessory type id to retrieve (e.g. 12, 9, etc.)

public getGeneratorString(template:String):String
------------------------------------------------------------------------------
Returns the generator string to be used with jGenerator

Parameters
template:String - The template for jGenerator. This is usually supplied in the xml and is usually the model swf itself (e.g. /8c/6c/model_54.swf)

public getConfigString():String
------------------------------------------------------------------------------
Returns the configuration string to be used with jGenerator

Callbacks:
the following callbacks will be invoked on listeners:

accessoryLoaded(accessoryTypeId:Number,mcArray:Array) : Void
------------------------------------------------------------------------------

Invoked after accessory is set using the setAccessory function. 
The callback will be called whether the accessory fragments were actually downloaded or just made visible.

Parameters
accessoryTypeId:Number - The accessory type id of loaded accessory (e.g. 12, 9, etc.)

mcArray:Array - An array of the movieclips*

*This might not be needed anymore!?

accessoryIncompatible(accessoryTypeId:Number,isIncompatible:Boolean[,accessoryTypeName:String]);
-----------------------------------------------------------------------------
Invoked after accessory is set using the setAccessory function.
The callback will always be triggered and alert the listener if an accessory type should be disabled or not

Parameters
accessoryTypeId:Number - The accessory type id of the incompatible accessory (e.g. 12, 9, etc.)

isIncompatible:Boolean - Specified wheter the typeId should be disable or enabled

accessoryTypeName:String - The accessory type name of the incompatible accessory (e.g. mouth, hat)


Modifications:
_____________________________________________________________________________

Description:

Written By:

Date modified:

_____________________________________________________________________________
****************************************************************************/
package com.oddcast.vhost
{
	import com.oddcast.event.EngineEvent;
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.vhost.engine.IEngineAPI;
	
	import flash.display.MovieClip;
	import flash.events.IOErrorEvent;
	
	public class VHostConfigController extends com.oddcast.vhost.VHostConfigEngineController implements com.oddcast.vhost.IVhostConfigController
	{ 
		
		private var engineAPI:IEngineAPI;				
		private var _arSelectedAcc:Array;
		private var _arIncompatState:Array;
		private var _arHiddenAccessories:Array;	
		private var _uintModelId:uint;
		
		private var _nCount:Number = 0;

		function VHostConfigController()
		{			
			_arSelectedAcc=new Array();
			_arIncompatState = new Array();
			_arHiddenAccessories = new Array();
		}
				
		override public function init(model:MovieClip,accessoryGroup:Boolean=false):void
		{			
			super.init(model,true)			
			
			accGrp.addEventListener(EngineEvent.ACCESSORY_LOADED,accessoryLoaded);
			accGrp.addEventListener(IOErrorEvent.IO_ERROR,accessoryLoadError);						
			getHostElements(model);
			colGrp.getBaseColors();			
		}   
		
		public function setEngine(engine:IEngineAPI):void
		{
			engineAPI = engine;
		}
		
		//**************************************************************
		// External Methods
		//**************************************************************
		
		public function setScale(hostPart:String,x:Number):void
		{
			var scaleVal:Number;
			//trace("got scale from scrollbar "+x);
			if (hostPart=="width")
			{
				scaleVal = rangeMCs["host"].minScale+(x*(rangeMCs["host"].maxScale-rangeMCs["host"].minScale))
				setScaleVal(hostPart,scaleVal);				
			}
			else if (hostPart=="height")
			{
				scaleVal = rangeMCs["host"].minScale+(x*(rangeMCs["host"].maxScale-rangeMCs["host"].minScale))
				setScaleVal(hostPart,scaleVal);				
			}
			else if (hostPart=="body")
			{
				scaleVal = rangeMCs["body"].minScale+(x*(rangeMCs["body"].maxScale-rangeMCs["body"].minScale))
				setScaleVal(hostPart,scaleVal);				
			}
			else if (hostPart == "nose")
			{
				scaleVal = rangeMCs[hostPart].minScale + (x * (rangeMCs[hostPart].maxScale - rangeMCs[hostPart].minScale));
				rngGrp.setXScale(scaleVal, hostPart);
			}
			else
			{			
				scaleVal = rangeMCs[hostPart].minScale+(x*(rangeMCs[hostPart].maxScale-rangeMCs[hostPart].minScale))
				setScaleVal(hostPart,scaleVal);				
			}
		}
					
		public function setAccessory(acc:AccessoryData):void
		{				
			//trace("VHostConfigController::setAccessory()  acc id: "+acc.getTypeId());
			var incompatId:int = acc.incompatibleWith
			var accId:int = acc.typeId;
			accGrp.setAccessory(acc,accId==12?getColor("mouth"):null);
			_arSelectedAcc[acc.typeId]=acc;
			//trace("accessory is incompatable with typeId="+incompatId);
			var incompatObject:Object = new Object();
			if (incompatId>0)
			{
				//hide incompatible accessories
				accGrp.hideAccessoryByType(accId,incompatId,true);
				_arIncompatState[accId] = incompatId;
				_arHiddenAccessories[incompatId] = true;				
				incompatObject.id = incompatId;
				incompatObject.incompat = true;
				incompatObject.accName = AccessoryData.getTypeName(incompatId);
				dispatchEvent(new EngineEvent(EngineEvent.ACCESSORY_INCOMPATIBLE,incompatObject));				
			}
			else
			{
				//show previously hidden incompatible accessories
				accGrp.hideAccessoryByType(accId,incompatId,false);
				if (_arIncompatState[accId]!=undefined)
				{
					
					incompatObject.id = _arIncompatState[accId];
					incompatObject.incompat = false;
					incompatObject.accName = AccessoryData.getTypeName(incompatId);
					dispatchEvent(new EngineEvent(EngineEvent.ACCESSORY_INCOMPATIBLE,incompatObject));
					//broadcastMessage("accessoryIncompatible",_arIncompatState[accId],false,accessoryTypes.getAccessoryName(_arIncompatState[accId]));
					delete _arHiddenAccessories[_arIncompatState[accId]];
					delete _arIncompatState[accId];
				}
			}						
		}	
		
		public function getHexColor(grpName:String):Number { //added sam
			return(colGrp.getHexColor(grpName));
		}
		
		public function getMembers(grpName:String):Array
		{
			return this[grpName].getMembers();
		}
		
		public function getColorSections():Array
		{
			return colGrp.getMembersArr("c_grp");
		}
		
		public function getColorTransforms():Array
		{
			var retArr:Array = new Array;
			var colSections:Array = getColorSections();
			for (var i in colSections)
			{
				retArr[i] = getColor(i);
			}
			return retArr;
		}
		
		public function getAccessorySections():Array
		{
			return accGrp.getMembersArr("a_grp");
		}
		
		public function getScaledSections():Array
		{
			var retArr:Array = new Array();
			//get range group
			for (var i in rangeMCs)
			{
				var sName:String = i;
				if (i=="host")
				{														
					retArr["width"] = Math.floor(10*((getScale("width")-rangeMCs[sName].minScale)/(rangeMCs[sName].maxScale-rangeMCs[sName].minScale)))/10;
					retArr["height"] = Math.floor(10*((getScale("height")-rangeMCs[sName].minScale)/(rangeMCs[sName].maxScale-rangeMCs[sName].minScale)))/10;				
				}
				else
				{					
					retArr[i] = Math.floor(10*((getScale(i)-rangeMCs[sName].minScale)/(rangeMCs[sName].maxScale-rangeMCs[sName].minScale)))/10;
					
				}
			}
			return retArr;
		}
		
		public function getAlphaSections():Array
		{
			var retArr:Array = new Array();
			//get alpha group
			var alArr:Array = alGrp.getMembersArr("al_grp");
			for (var i in alArr)
			{
				retArr[i] = Math.floor(10*(alGrp.getAlpha(i)/100))/10;
			}
			return retArr;
		}
		
		public function getSelectedAccessoriesByName():Object
		{
			var retObj:Object = new Object();
			for (var i in _arSelectedAcc)
			{
				retObj[AccessoryData.getTypeName(AccessoryData(_arSelectedAcc[i]).typeId)] = _arSelectedAcc[i];
			}
			return retObj;
		}
		
		public function getSelectedAccessoriesById():Array
		{
			return _arSelectedAcc;
		}
		
		public function setInitialAccessories(ohObj:Object):void
		{ //added sam
			//use: controller.setInitialAccessories(OHUrlParser.getOHObject(hosturl));			
			_uintModelId = ohObj['model'];			
			var typeId:Number;
			for (var accName in ohObj) {
				typeId=AccessoryData.getTypeId(accName);				
				if (typeId>0) 
				{					
					_arSelectedAcc[typeId]=new AccessoryData(ohObj[accName],"",typeId,"",0);
				}
			}
		}
		
		public function setInitialAccessoryArr(accArr:Array):void
		{ //added sam
			//pass it an array of accessories already parsed
			var typeId:Number;		
			for (var i=0;i<accArr.length;i++) {
				typeId=AccessoryData(accArr[i]).typeId;
				_arSelectedAcc[typeId]=accArr[i];
			}
		}				
		
		public function getSelectedAccessory(typeId:Number):AccessoryData
		{
			return _arSelectedAcc[typeId];
		}
			
			
		public function getAgeSections():Array
		{
			var retArr:Array = new Array();
			//get age group
			var age:Number=ageGrp.getAge();
			if (!(isNaN(age)))	{
				retArr["age"] = Math.floor(10*(age/engineAPI.getMaxAgeFrames()))/10;
			}
			return retArr;
		}	
		
		public function getAccessoryRef(s:String):Array
		{
			return accGrp.getMemberRefArr("a_grp",s);
		}
		
		public function getTypedAccessorySections():Array
		{
			var retArr:Array = new Array();
			var secArr:Array = accGrp.getMembersArr("a_grp");			
			for (var i in secArr)
			{			
				retArr.push({name:i,active:secArr[i],typeId:AccessoryData.getTypeId(i)});
			}
			return retArr;
			
		}
		
		public function getScalePercent(s:String):Number
		{
		//	trace("ConfigControoler getScalePercent "+s);
			var sName:String = s;
			if (s=="width" || s=="height")
			{
				sName = "host";
			}
			//Editor.traceOut("getScale(s)="+getScale(s));
			//return Math.floor((10*getScale(s))/(rangeMCs[sName].minScale+rangeMCs[sName].maxScale))/10;
			return Math.floor(10*((getScale(s)-rangeMCs[sName].minScale)/(rangeMCs[sName].maxScale-rangeMCs[sName].minScale)))/10;
				
		}	
		
		public function getHiddenAccessories():Array
		{
			var arr:Array = new Array();
			for (var i in _arHiddenAccessories)
			{
				arr[AccessoryData.getTypeName(i)] = _arHiddenAccessories[i];
			}
			return arr;
		}
		/*
		public function getGeneratorString(template:String):String
		{
			var _arSelectedAccessories:Array = this.getSelectedAccessoriesById();
			var retStr:String = "";
			for (var i in _arSelectedAccessories)
			{				
				//skip hidden incompatible accessories
				if (_arHiddenAccessories[_arSelectedAccessories[i].typeId]) continue;
				
				var accName:String = AccessoryData.getTypeName(i);
				var fragArr:Array = AccessoryData(_arSelectedAccessories[i]).getFragments();
				for(var j in fragArr)
				{
					if (j!='m')
					{
						retStr+=accName+i+"="+fragArr[j]+"&";
					}
					else
					{
						retStr+=accName+"l="+fragArr[j]+"&";
						retStr+=accName+"r="+fragArr[j]+"&";
					}
				}			
			}
			retStr+="template="+template;
			return retStr;
		}
		*/
		public function getConfigString():String
		{		
			var _arSelectedAccessories:Array = this.getSelectedAccessoriesById();
			var retStr:String = "";
			var configStr:String = engineAPI.getConfigString();
			var configArr:Array = configStr.split(":");
			var l:Number = ConfigString.getMap().length//configArr.length;
			var mouthColTrans:Object = this.getColor("mouth"); //becasue CongifString returns bad values due to the way vhostConfigCtrl replaces the mouth
			for (var i:Number=0; i<l;++i)
			{
				if (ConfigString.getMap()[i].type=="color")
				{
					var rb:Number;
					var gb:Number;
					var bb:Number;
					if (ConfigString.getMap()[i].name=="mouth")
					{
						rb = mouthColTrans.rb;
						gb = mouthColTrans.gb;
						bb = mouthColTrans.bb;
					}
					else
					{
						rb = ConfigString.createColorTransform(configArr[i]).rb;
						gb = ConfigString.createColorTransform(configArr[i]).gb;
						bb = ConfigString.createColorTransform(configArr[i]).bb;
					}
					
					retStr+=ConfigString.getMap()[i].name+"R="+rb+"&";
					retStr+=ConfigString.getMap()[i].name+"G="+gb+"&";
					retStr+=ConfigString.getMap()[i].name+"B="+bb+"&";
				}
				else
				{
					retStr+=ConfigString.getMap()[i].name+"="+configArr[i]+"&";
				}
			}
			
			for (var j in _arSelectedAccessories)
			{
				//skip hidden incompatible accessories
				if (_arHiddenAccessories[_arSelectedAccessories[j].typeId]) continue;
				
				var accName:String = AccessoryData.getTypeName(j);
				var accId:Number = _arSelectedAccessories[j].id;//getAccessoryId();
				retStr+="ac_"+accName+"="+accId+"&";			
			}
			
			retStr+="ok=1";
			
			return retStr;
			
		}
		
		public function getOHObj():Object
		{							
			var retObj:Object = new Object();
			for (var i in _arSelectedAcc)
			{
				if (_arSelectedAcc[i] is AccessoryData)
				{
					//trace("VhostConfigController::getOHObj "+i+"->"+_arSelectedAcc[i]);
					retObj[AccessoryData.getTypeName(AccessoryData(_arSelectedAcc[i]).typeId)] = AccessoryData(_arSelectedAcc[i]).id;
				}
			}
			retObj['model'] = _uintModelId;
			return retObj;
			
		}
		
		//**************************************************************
		// Callbacks
		//**************************************************************	
		public function accessoryLoaded(evt:EngineEvent):void		
		//public function accessoryLoaded(mcs:Array,typeId:Number,transObj:Object):Void
		{
			
			var mcs:Array = evt.data.accArray;
			var typeId:int = evt.data.typeId;
			var transObj:Object = evt.data.colorObj;			
			//trace("VhostCOnfigController::accessoryLoaded");
			if (typeId==12) //mouth
			{
				for(var i in mcs)
				{
					if (mcs[i] is MovieClip)
					{												
						colGrp.addMember(new GroupedMember(mcs[i].lips));
						colGrp.getBaseColors();
						engineAPI.setMouthPath(mcs[i]);
						var hexColor:uint = colGrp.getHexColor("mouth");						
						colGrp.setHexColor(hexColor,"mouth");						
					}
				}				
			}
			else
			{
				for(var j in mcs)
				{
					if (mcs[j].c_grp is String)
					{
						if (mcs[j].c_grp is String)
						{
							if (mcs[j].c_grp.length>0)
							{
								colGrp.addMember(new GroupedMember(mcs[j]));
							}
						}
					}
				}
			}			
			dispatchEvent(new EngineEvent(EngineEvent.ACCESSORY_LOADED,evt.data));
			//broadcastMessage("accessoryLoaded",typeId,mcs);
		}
		
		public function accessoryLoadError(evt:IOErrorEvent):void
		{
			//workaround becasue this triggers a runtime error if not listened to.
			this.addEventListener(IOErrorEvent.IO_ERROR, function (evt:IOErrorEvent){});
			dispatchEvent(evt);
			//broadcastMessage("accessoryLoadError");
		}
		
		public function destroy():void
		{
			engineAPI = null;				
			_arSelectedAcc = null;
			_arIncompatState = null;
			_arHiddenAccessories = null;
		}				
	}
}