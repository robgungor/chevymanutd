package com.oddcast.vhost.groups
{	
	public class RangeGroup extends Group
	{				
		function RangeGroup()
		{			
			super("range");	
		}
		
		public function setXYScale(scale:Number,mName:String):void
		{		
		
				for (var i in members)
				{
					if (members[i].getName is Function)
					{
						if (mName==members[i].getName() || !mName.length)
						{					
							var maxScale:Number = members[i].getExtData().maxScale;
							var minScale:Number = members[i].getExtData().minScale;
							if (scale>=minScale ||scale<=maxScale)
							{
								members[i].getMC().scaleX = scale/100;
								members[i].getMC().scaleY = scale/100;
							}
						}
					}
				}			
		}
		
		public function getXYScale(name:String):Number 
		{
			return getXScale(name);
		}
		
		public function getXScale(name:String):Number
		{
			if (getMemberIndex(name) != -1)
			{
				return members[getMemberIndex(name)].getMC().scaleX * 100;
			}
			else
			{
				return -1;
			}
		}
		
		public function getYScale(name:String):Number
		{
			return members[getMemberIndex(name)].getMC().scaleY*100;
		}
		
		private function getMemberIndex(mName:String):Number
		{
			for (var i in members)
			{
				if (mName==members[i].getName())
				{
					return i;				
				}
			}
			return -1;
		}
		
		public function setXScale(scale:Number,mName:String):void//,anim:Boolean,ptr:RangeGroup):Void
		{
			//trace("RangeGroup::setXScale "+scale+", "+mName);			
			for (var i in members)
			{
				if (members[i].getName is Function)
				{
					if (mName==members[i].getName() || !mName.length)
					{					
						var maxScale:Number = members[i].getExtData().maxScale;
						var minScale:Number = members[i].getExtData().minScale;
						if (scale>=minScale ||scale<=maxScale)
							members[i].getMC().scaleX = scale/100;
					}
				}
			}
		}
		
		public function setYScale(scale:Number,mName:String):void//,anim:Boolean,ptr:RangeGroup):Void
		{			
			for (var i in members)
			{
				if (members[i].getName is Function)
				{
					if (mName==members[i].getName() || !mName.length)
					{
						var maxScale:Number = members[i].getExtData().maxScale;
						var minScale:Number = members[i].getExtData().minScale;
						if (scale>=minScale ||scale<=maxScale)
							members[i].getMC().scaleY = scale/100;
					}
				}
			}
		}		
	}
}