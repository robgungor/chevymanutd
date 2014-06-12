package com.oddcast.vhost
{
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.display.MovieClip;		
	
	import com.oddcast.vhost.groups.AgeGroup;
	import com.oddcast.vhost.groups.AlphaGroup;
	import com.oddcast.vhost.groups.ColorGroup;
	import com.oddcast.vhost.groups.RangeGroup;
	import com.oddcast.vhost.groups.AccessoryGroup;
	import com.oddcast.vhost.GroupedMember;
	public class VHostConfigEngineController extends EventDispatcher
	{
		protected var ageGrp:AgeGroup;
		protected var colGrp:ColorGroup;
		protected var alGrp:AlphaGroup;
		protected var rngGrp:RangeGroup;
		protected var accGrp:AccessoryGroup;
		protected var rangeMCs:Array = new Array();	
		private var _nRandomControlId:Number;  //this variable is used to make sure the host movieclips are not traversed more than once. and allow traversing it again for each init()
		private var _bAccessoryGroup:Boolean;		
		
		function VHostConfigEngineController()
		{		
			rangeMCs["mouth"]	= {name:"mouth",configVars:"mscale",maxScale:150,minScale:50}//remove
			rangeMCs["nose"] 	= {name:"nose",configVars:"nscale",maxScale:150,minScale:50}//remove
			rangeMCs["body"] 	= {name:"body",configVars:"bscale",maxScale:130,minScale:50}//remove
			rangeMCs["host"] 	= {name:"host",configVars:"hyscale,hxscale",maxScale:125,minScale:75}//remove
			//to support backhair and hairback problem
			//need to make a jsfl script to look if we still have this problem
			//rangeMCs["hairback"] 	= {name:"host",configVars:"hyscale,hxscale",maxScale:125,minScale:75}
			rangeMCs["backhair"] 	= {name:"backhair",configVars:"hyscale,hxscale",maxScale:125,minScale:75}//remove
		}
		
		public function init(model:MovieClip,accessoryGroup:Boolean=false):void
		{
			_nRandomControlId = Math.random()*999999;	
			ageGrp	= new AgeGroup();
			colGrp	= new ColorGroup();
			alGrp 	= new AlphaGroup();
			rngGrp = new RangeGroup();
			accGrp = new AccessoryGroup();
			
			if (!accessoryGroup)
			{
				getHostElements(model);
				colGrp.getBaseColors();
			}
			else
			{
				_bAccessoryGroup = true;
			}
		}
		
		public function getId():Number
		{
			return _nRandomControlId;
		}
		
		public function setScaleVal(hostPart:String,scaleVal:Number):void
		{
			if (hostPart=="width")
			{
				rngGrp.setXScale(scaleVal,"host");
				rngGrp.setXScale(scaleVal,"backhair");
			}
			else if (hostPart=="height")
			{
				rngGrp.setYScale(scaleVal,"host");
				rngGrp.setYScale(scaleVal,"backhair");
			}
			else if (hostPart=="body") rngGrp.setXScale(scaleVal,"body");
			else rngGrp.setXYScale(scaleVal,hostPart);
		}
		
		public function setAge(percent:Number):void
		{
			var frameNum:Number = Math.ceil(percent*45);
			ageGrp.setAge(frameNum==0?1:frameNum);
		}
		
		public function setAlpha(hostPart:String,percent:Number):void
		{			
			alGrp.setAlpha(percent*100,hostPart);
		}
		
		public function setColor(hostPart:String,transObj:Object):void
		{
			colGrp.setColor(transObj,hostPart);
		}
		
		public function setHexColor(hostPart:String,hexCol:uint):void
		{ //added sam
			colGrp.setHexColor(hexCol,hostPart);
		}	
		
		public function getScale(hostPart:String):Number
		{
			var scaleVal:Number;
			
			if (hostPart=="width")
			{
				return rngGrp.getXScale("host");
			}
			else if (hostPart=="height")
			{
				return rngGrp.getYScale("host");
			}
			else
			{
				return rngGrp.getXYScale(hostPart);
			}
		}
		
		public function getAgeFrame():Number
		{		
			return ageGrp.getAge();
		}
		
		public function getColor(hostPart:String):Object
		{				
			return colGrp.getColor(hostPart);
		}
				
		
		//**************************************************************
		// Internal & Utility functions
		//**************************************************************
		//recursive function which build groups by "drilling" the vhost
		protected function getHostElements(m:MovieClip):void
		{													
			if (m.name!="model" && m.name.indexOf("attached")==-1)
			{
				if (m.vccVisit==_nRandomControlId)
				//if movieclip was already visited return (avoid infinite loops due to pointers)
				{
					return;
				}
				
				
				
				//trace("**getHostElements "+m.name);
				//trace("getHostElements:: "+m);		
				if (m.name.indexOf("engine")>=0 || m.name.indexOf("sound")>=0) return;		
				
				if (m.age_grp is String)
				{
					if (m.age_grp.length>0)
						ageGrp.addMember(new GroupedMember(m));
				}
				
				if (m.c_grp is String)
				{
					if (m.c_grp.length>0)
						colGrp.addMember(new GroupedMember(m));
				}
				if (m.al_grp is String)
				{
					if (m.al_grp.length>0)
						alGrp.addMember(new GroupedMember(m));
				}
				if (isRangeMC(m.name))
					rngGrp.addMember(new GroupedMember(m,rangeMCs[m.name]));
				if (m.a_grp is String && _bAccessoryGroup)
				{
					if (m.a_grp.length>0)
					{
						//trace("VHOST CONFIG CTRL  -->add accessory member: "+m+" a_grp="+m.a_grp+", type="+m.type+" name="+m.name+" parentName="+m.parent.name);
						accGrp.addMember(new GroupedMember(m,{id:m.a_grp,type:m.type}));
					}
				}				
				
				
				m.vccVisit = _nRandomControlId;
			}
			if (m is DisplayObjectContainer)
			{
				for (var i:uint=0; i<m.numChildren; ++i)			
				{
					if (m.getChildAt(i) is MovieClip)							
					{				
						getHostElements(MovieClip(m.getChildAt(i)));
					}
				}
			}
		}
				
		
		private function isRangeMC(n:String):Boolean
		{		
			for (var i in rangeMCs)
			{
				if (i==n)
				{
					//trace(n +" is rangeMC");
					return true;			
				}
			}
			return false;
		}
		
	}
}