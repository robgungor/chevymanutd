package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	
	public interface IMaterialLayer extends IMaterialLayerProxy, INode
	{
		function setBlendingMode(blendingMode:BlendingMode):void;
	}
}