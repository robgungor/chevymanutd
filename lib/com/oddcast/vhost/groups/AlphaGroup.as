package com.oddcast.vhost.groups
{	
	public class AlphaGroup extends Group
	{
		function AlphaGroup()
		{			
			super("alpha");	
		}
		
		public function setAlpha(val:Number,mName:String):void
		{
			for (var i in members)
			{
				if (members[i].getMC is Function)
				{
					if (mName==members[i].getMC().al_grp || mName.length==0)
					{
						members[i].getMC().alpha = val/100;
					}
				}
			}
		}
		
		public function getAlpha(mName:String):Number
		{
			for (var i in members)
			{
				if (members[i].getMC is Function)
				{
					if (mName==members[i].getMC().al_grp)
					{
						return members[i].getMC().alpha*100;
					}
				}
			}
		}
		
	}
}