package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.*;
	
	public interface IContentKernel extends IBlispKernel
	{
		function defineRootBoxedObject(name:String, object:Object):void;
	}
}