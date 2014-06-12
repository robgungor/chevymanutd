package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.data.SceneData;

	public interface ICollada2ScenePlugIn
	{
		function convert(dae:XML):SceneData;
	}
}