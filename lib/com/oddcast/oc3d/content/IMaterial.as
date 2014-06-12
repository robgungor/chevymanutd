package com.oddcast.oc3d.content
{
	public interface IMaterial extends IMaterialProxy, INode
	{
		function setPerspectiveCorrectionEnabled(b:Boolean):void;
	}
}