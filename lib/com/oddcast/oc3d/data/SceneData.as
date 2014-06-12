package com.oddcast.oc3d.data
{
	import com.oddcast.oc3d.data.*;
	
	import flash.media.Camera;
	import flash.utils.ByteArray;

	public class SceneData
	{
		public var Uri:String;
		public var Name:String;
		public var Nodes:Vector.<NodeData>;
		public var Skins:Vector.<SkinData>;
		public var Morphs:Vector.<MorphData>;
		public var Meshes:Vector.<MeshData>;
		public var Cameras:Vector.<CameraData>;
		public var Lights:Vector.<LightData>;
		public var Materials:Vector.<MaterialData>;
		public var Animations:Vector.<AnimationData>;
	}
}