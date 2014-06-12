package com.oddcast.oc3d.content
{
	public interface ITextureMaterialLayer extends ITextureMaterialLayerProxy, IMaterialLayer
	{
		function setTexture(tex:ITextureProxy):void;
	}
}