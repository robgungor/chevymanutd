package com.oddcast.vhost.groups
{	
	public class AgeGroup extends Group
	{
		function AgeGroup()
		{			
			super("age");	
		}
		
		public function setAge(age:Number,mName:String = ""):void
		{						
			for (var i in members)
			{
				if (members[i].getMC is Function)
				{
					if (mName==members[i].getMC().age_grp || mName.length==0)
					{
						members[i].getMC().gotoAndStop(age);
					}
				}
			}		
		}
		
		public function getAge(mName:String=""):Number
		{
			if (members!=null&&members.length>0&&members[0].getMC is Function) return members[0].getMC().currentFrame;
			else return(Number.NaN);
		}		
	}
}