package com.oddcast.oc3d.content
{
	public interface ISwf extends ISwfProxy, INode
	{
		function setColorTransform(transform:Array):void; // Array<Number>
		function setUri(uri:String):void;
	}
}