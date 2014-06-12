package com.oddcast.oc3d.content
{
	public interface ISlot extends ISlotProxy, INode
	{
		// passing in null for mat unassigns material
		// continuationFn<>
		function assignMaterial(mat:IMaterial, continuationFn:Function=null, failedFn:Function=null, progressedFn:Function=null):void;
		//function tryFindAssignedMaterial():IMaterial;
		//function isComposite():Boolean;
	}
}