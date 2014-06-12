package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.INodeProxy;

	public interface INodeSetProxy extends INodeProxy
	{
		function rootMaterialFolder():IFolder;
		function rootAnimationFolder():IFolder;
		function rootTextureFolder():IFolder;
		function rootAudioFolder():IFolder;
		function rootSwfFolder():IFolder;
	}
}