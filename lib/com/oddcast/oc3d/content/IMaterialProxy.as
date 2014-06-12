package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.IMaterialObject3D;
	import com.oddcast.oc3d.core.INodeProxy;

	public interface IMaterialProxy extends INodeProxy
	{
		// the resulting image will be destroyed as soon as continuationFn returns
		// make a clone of it if you wish to hang on to the image
		// continuationFn:Function<Image>
		function tryComposite(continuationFn:Function):void;
		
		function material():IMaterialObject3D;
		function perspectiveCorrectionEnabled():Boolean;
	}
}