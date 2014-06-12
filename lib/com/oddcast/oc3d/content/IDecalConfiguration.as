package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.shared.BlendingMode;
	
	public interface IDecalConfiguration extends IDecalConfigurationProxy, INode
	{
		function setVisible(visible:Boolean):void;
		function setBlendingMode(blendingMode:BlendingMode):void;
	}
}