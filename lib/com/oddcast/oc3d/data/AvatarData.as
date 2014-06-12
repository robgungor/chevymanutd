package com.oddcast.oc3d.data
{
	import flash.utils.ByteArray;

	public class AvatarData
	{
		public var Name:String;
		public var Scenes:Vector.<SceneData>;
		public var ContentNodes:Vector.<ContentNodeData>;
		public var ContentAssociations:Vector.<ContentAssociationData>;
		public var VisemeMappings:Vector.<VisemeMappingData>;
	}
}