package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.data.SceneData;

	public interface IScene2AsPlugIn
	{
		function convert(sceneData:SceneData):String; // input SceneData, outputs as3 source code
	}
}