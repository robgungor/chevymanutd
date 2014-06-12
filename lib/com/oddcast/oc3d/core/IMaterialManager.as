package com.oddcast.oc3d.core
{
	public interface IMaterialManager
	{
		function engine():IEngine3D;
		
		function defaultMaterial():IMaterialObject3D;
		function defaultWireframeMaterial():IWireframeMaterial;
		//function defaultLineMaterial():ILineMaterial;
		//function defaultParticleMaterial():IParticleMaterial;

		//function tryFindMaterial(name:String):IMaterialObject3D;
		
		function newMaterialObject3D(name:String):IMaterialObject3D;
		//function newParticleMaterial(name:String, color:Number=0xff9900, alpha:Number=100):IParticleMaterial;
		//function newLineMaterial(name:String, color:Number=0xFF0000, alpha:Number=1):ILineMaterial;
		function newWireframeMaterial(name:String, color:Number=0x43ffa3, alpha:Number=100, thickness:Number=0):IWireframeMaterial;
		function newGouraudMaterial(name:String, diffuseColor:uint=0x777777, ambientColor:uint=0xFFFFFF):IGouraudMaterial;
		function newLayeredMaterial(name:String):ILayeredMaterial;
		function newCompositeMaterial(name:String):ICompositeMaterial;
	}
}