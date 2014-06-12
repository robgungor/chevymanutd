//needs to be rewritten with flash.geom.ColorTransfrom or maybe Color (setTint?)

package com.oddcast.vhost.groups
{
	import com.oddcast.utils.ColorConverter;
	import com.oddcast.vhost.color.ColorAnalyzer;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	
	public class ColorGroup extends Group
	{		
		private var analyzer:ColorAnalyzer;
		
		function ColorGroup()
		{
			super("color");			
		}
			
		//added sam +++
		public function getBaseColors():void 
		{						
			analyzer=new ColorAnalyzer(members);
		}
		
		public function setHexColor(colorHex:uint,mName:String):void
		{			
			var colorTrans:Object=analyzer.getTransform(mName,colorHex);					
			setColor(colorTrans,mName);//,anim,ptr);
		}
		
		public function getHexColor(mName:String):uint {
			var colorTrans:Object=getColor(mName);
			return(analyzer.getHexColor(mName,colorTrans));
		}
		
		//++++/
			
		public function setColor(colorTrans:Object,mName:String):void
		{		
			for (var i in members)
			{							
				if (members[i].getMC is Function)
				{
					//trace("ColorGroup::setColor "+mName+"=?="+members[i].getMC().c_grp+" ("+members[i].getMC()+")");
					if (mName==members[i].getMC().c_grp || mName.length==0)
					{					
						//trace("ColorGroup::setColor mc="+members[i].getMC().name+", colorTrans={"+colorTrans.rb+","+colorTrans.gb+","+colorTrans.bb+"}");
						//var col:Color = new Color(members[i].getMC());
						//col.setTransform(colorTrans);					
						var ct:ColorTransform = new ColorTransform(1,1,1,1,colorTrans.rb,colorTrans.gb,colorTrans.bb);
						MovieClip(members[i].getMC()).transform.colorTransform = ct;
					}
				}
			}
		}
		
		public function getColor(mName:String):Object
		{
			for (var i in members)
			{		
				if (members[i].getMC is Function)
				{
					if (mName==members[i].getMC().c_grp)
					{								
						//var col:Color = new Color(members[i].getMC());
						//return col.getTransform();				
						var newCT:ColorTransform = MovieClip(members[i].getMC()).transform.colorTransform;
						var ct:Object = new Object();
						ct.rb = newCT.redOffset;
						ct.gb = newCT.greenOffset;
						ct.bb = newCT.blueOffset;
						return ct;
					}
				}
			}
		}		
	}
}