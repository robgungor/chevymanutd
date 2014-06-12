package com.oddcast.vhost.groups
{
	import com.oddcast.event.EngineEvent;
	import com.oddcast.event.FragmentEvent;
	import com.oddcast.vhost.GroupedMember;
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.oddcast.vhost.accessories.FragmentLoader;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	public class AccessoryGroup extends com.oddcast.vhost.groups.Group
	{
		
		//private var _mclLoader:MovieClipLoader;
		private var _arAccessories:Array;
		private var _uintFragLoaded:uint;
		private var _uintFragToLoad:uint;
		//private var _nLastAccessoryId:Number = 0;
		private var _iLastTypeId:int;
		private var _arLastAccessories:Array;
		private var _arOrigAccessories:Array
		private var _iLoadingAccessory:int;
		private var _bIsMirror:Boolean;
		private var _oLipsColorTrans:Object;
		private var _arIncompatArr:Array; //this array has pointers to the movieclips active fragment movieclips by typeId
		private var _arHiddenArr:Array; //this array has pointers to _arIncompatArr per typeId				
		
		function AccessoryGroup()
		{
			super("age");
			_arAccessories = new Array();
			_arOrigAccessories = new Array();
			_arLastAccessories = new Array();
			_arIncompatArr = new Array();
			_arHiddenArr = new Array();			
			
		}
		
		public function setAccessory(acc:AccessoryData,transObj:Object=null):void //returns an array with movieclip pointers
		{			
			changeAccessoryInit();
			var waitForLoad:Boolean = false;
			var accName = AccessoryData.getTypeName(acc.typeId);
			_iLoadingAccessory = acc.id;
			_iLastTypeId = acc.typeId;			
			for (var i in members)
			{				
				if (members[i].getMC is Function)
				{					
					var _member:GroupedMember = GroupedMember(members[i]);
					//trace("member ids:"+members[i].getExtData().id)
					if (_member.getExtData().id==accName)
					{												
						if (_arAccessories[acc.id]==undefined)
						{												
							_arAccessories[acc.id] = new Array();
							waitForLoad = true;
						}												
						
						if (_arAccessories[acc.id][_member.getExtData().type]==undefined)
						{
							_arAccessories[acc.id][_member.getExtData().type] = new Array();
							
							var origMC:MovieClip = getExistingMC(_member.getMC(),_member.getExtData().type);							
							//trace("AccessoryGroup::setAccessory origMC "+origMC.name+" parent is "+origMC.parent.name);
							if (acc.typeId==12) //mouth
							{
								//color mouth
								///var ct:Color = new Color(origMC.lips);
								///_oLipsColorTrans = ct.getTransform();
							}							
							var stackonMC:MovieClip = origMC.parent;
							var newMC:MovieClip = new MovieClip();
							newMC.x = origMC.x;
							newMC.y = origMC.y;
							newMC.name = "acc"+acc.id;	
							newMC.container = stackonMC;
							newMC.accId = acc.id;
							newMC.extDataType = _member.getExtData().type;
							newMC.isMirror = acc.isMirror;
							//trace("newMC.extDataType="+newMC.extDataType+", acc.isMirror="+acc.isMirror);																															
							//_arAccessories[acc.id][_member.getExtData().type] = newMC; //do this after loaded
							var fragUrl:String = getFragmentUrl(_member.getExtData().type,acc)														
							if (fragUrl!=null)
							{
								var _fragLoader:FragmentLoader = new FragmentLoader(fragUrl,newMC);
								_uintFragToLoad++;									
								_fragLoader.addEventListener(FragmentEvent.FRAGMENT_LOADED,onLoadInit);
								_fragLoader.addEventListener(FragmentEvent.FRAGMENT_LOAD_ERROR,onLoadError);																
								_fragLoader.load();								
							}
							else if (_arAccessories[acc.id][_member.getExtData().type] is DisplayObject)
							{										
								stackonMC.removeChild(_arAccessories[acc.id][_member.getExtData().type]);								
							}														
						}
						else
						{
							if (acc.typeId==12) //mouth
							{
								//color mouth
								
								///var arr:Array = _arAccessories[_arLastAccessories[_nLastTypeId]];
								///for (var i in arr)
								///{
								///	var ct:Color = new Color(arr[i].lips);
								///	_oLipsColorTrans = ct.getTransform();
								///}								
							}
						}
					}
				}
			}
			if (!waitForLoad)
			{				
				accessoryLoaded();
			}					
		}
				
		
		private function changeAccessoryInit():void
		{
			_uintFragLoaded = 0;
			_uintFragToLoad = 0;
			
		}
		
		public function onLoadInit(evt:FragmentEvent):void
		{			
			_uintFragLoaded++;		
			
			var _fragLoader:FragmentLoader = FragmentLoader(evt.data);
			var _fragMC:MovieClip = _fragLoader.getContent();
			_fragMC.x = _fragLoader.getData("x");
			_fragMC.y = _fragLoader.getData("y");			
			_fragMC.name = _fragLoader.getData("name");
			_fragMC.visible = false;
			//flip the left side if a mirror fragment
			
			//trace("AccessoryGroup::onLoadInit storing new displayObject at ["+_fragLoader.getData("accId")+"]["+_fragLoader.getData("extDataType")+"]");
			//MovieClip(_fragLoader.getData("container")).addChild(_fragMC);
			//trace("container="+_fragLoader.getData("container").name+", _fragMC="+_fragMC.name);
			_arAccessories[_fragLoader.getData("accId")][_fragLoader.getData("extDataType")] = MovieClip(_fragLoader.getData("container")).addChild(_fragMC);	
			
			if (_iLastTypeId==12)//mouth
			{
				_arAccessories[_fragLoader.getData("accId")][_fragLoader.getData("extDataType")].version = Number(_fragLoader.getResourceData("version"));
				if (Number(_fragLoader.getResourceData("colorable"))==1)
				{					
					_arAccessories[_fragLoader.getData("accId")][_fragLoader.getData("extDataType")].lips.c_grp = "mouth";
				}
			}			
			
			if (_uintFragLoaded==_uintFragToLoad)
			{
				//trace("AccessoryGroup::onLoadInit end");
				accessoryLoaded();
			}
		}
		
		public function onLoadError(evt:FragmentEvent):void
		{
			//trace("onLoadError");
			dispatchEvent(evt.data);
			//broadcastMessage("accessoryLoadError");
		}
				
		/*
		public function onLoadError(target_mc:MovieClip,ec:String,st:Number)
		{
			//trace("onLoadError "+ec+" "+st);
		}
		*/
		private function accessoryLoaded():void
		{
			//trace("accGrp::accessoryLoaded "+_arLastAccessories[_iLastTypeId]);
			if (_arLastAccessories[_iLastTypeId]==0 || _arLastAccessories[_iLastTypeId]==undefined)
			{
				//trace("AccessoryGroup::accessoryLoaded call hideFragments")
				hideFragments(_arOrigAccessories);			
			}
			else
			{			
				hideFragments(_arAccessories[_arLastAccessories[_iLastTypeId]]);			
			}		
			//trace("_arIncompatArr["+_nLastTypeId+"]="+_nLoadingAccessory);
			_arIncompatArr[_iLastTypeId] = _arAccessories[_iLoadingAccessory];		
			hideFragments(_arAccessories[_iLoadingAccessory],false);		
			_arLastAccessories[_iLastTypeId] = _iLoadingAccessory
			//_nLastAccessoryId = _nLoadingAccessory;
			var accessoryLoadedObject:Object = new Object();
			//trace("AccessoryGroup::accessoryLoaded retriving new displayObject from "+_iLoadingAccessory);
			accessoryLoadedObject.accArray = _arAccessories[_iLoadingAccessory];
			accessoryLoadedObject.typeId = _iLastTypeId;
			accessoryLoadedObject.colorObj = _oLipsColorTrans;
			dispatchEvent(new EngineEvent(EngineEvent.ACCESSORY_LOADED,accessoryLoadedObject));
			//broadcastMessage("accessoryLoaded",_arAccessories[_nLoadingAccessory],_nLastTypeId,_oLipsColorTrans);
		}
		
		public function hideAccessoryByType(selectedId:int,incompatId:int,hide:Boolean):void
		{
			
			//trace("AccessoryGroup::hideAccessoryByType ("+selectedId+", "+incompatId+", "+hide+")");
			var mcArr:Array = new Array();
			for (var i in members)
			{
				if (members[i].getMC is Function)
				{
					var gm:GroupedMember = members[i];
					var o:Object = gm.getExtData();
					//trace("		--> "+gm.getName()+" - id="+o.id+", type="+o.type);
					if (incompatId==AccessoryData.getTypeId(o.id) && hide)
					{
							//trace("hiding "+gm.getMC());
							//gm.getMC()._visible = false;
							mcArr.push(gm.getMC());
							_arHiddenArr[selectedId] = incompatId
					}
					else if (_arHiddenArr[selectedId]>0 && _arHiddenArr[selectedId]==AccessoryData.getTypeId(o.id) && !hide)
					{
						//gm.getMC()._visible = true;
							mcArr.push(gm.getMC());
										
					}
				}
			}
			
			if (!hide)
			{
				delete _arHiddenArr[selectedId];
			}
			
			hideFragments(mcArr,hide);		
		}
				
		public function getHiddenAccessories():Array
		{
			return _arHiddenArr;
		}
		
		private function hideFragments(mcArr:Array,b:Boolean=true):void
		{									
			for (var i in mcArr)
			{
				if (mcArr[i] is MovieClip)
				{
					//trace("AccessoryGroup::hideFragments "+i+"->"+mcArr[i].name+" parent="+mcArr[i].parent.name+" hide="+b);				
					mcArr[i].visible = !b;
				}
			}			
		}
		
		private function getFragmentUrl(frSym:String,accessory:AccessoryData):String
		{
			return accessory.getFragmentUrl(frSym);		
		}
		
		private function getExistingMC(mc:MovieClip,type:String):MovieClip
		{			
			if (_arOrigAccessories[mc.name+"_"+type]==undefined)
			{		
				if (mc is DisplayObjectContainer)
				{			
					for (var i:uint=0; i<mc.numChildren; ++i)			
					{				
						if (mc.getChildAt(i) is MovieClip)							
						{									
							if (mc.getChildAt(i).name.indexOf("attached")>=0)
							{
								_arOrigAccessories[mc.name+"_"+type] = mc.getChildAt(i);
								return _arOrigAccessories[mc.name+"_"+type];
							}
						}
					}
				}				
			}
			else
			{
				return _arOrigAccessories[mc.name+"_"+type];
			}			
		}
		
		
		private function getMemberIndex(mName:String):Number
		{
			for (var i in members)
			{
				if (members[i].getMC is Function)
				{
					if (mName==members[i].getName())
					{
						return i;				
					}
				}
			}
		}
		
	}
}