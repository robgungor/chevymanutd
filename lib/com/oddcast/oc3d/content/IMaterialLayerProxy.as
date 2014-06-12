package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;
	import com.oddcast.oc3d.shared.BlendingMode;

	public interface IMaterialLayerProxy extends INodeProxy
	{
		function blendingMode():BlendingMode;
	}
}