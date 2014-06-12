package com.oddcast.oc3d.content
{
	public interface IAccessorySetProxy extends INodeSetProxy
	{
		function rootActionFolder():IFolder;
		function rootGroup():IGroup;
		
		// onlyTheseTypes:Array<INode>
		function findCategoriesWhichContain(onlyTheseTypes:Array=null):Array; // Array<ICategoryProxy>
	}
}