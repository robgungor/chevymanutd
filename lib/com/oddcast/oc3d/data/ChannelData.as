package com.oddcast.oc3d.data
{
	public class ChannelData
	{
		public var Type:uint;					// look at AnimationChannelType for a list of enums
		public var TargetPath:String; 			// target grammer: "<node-name> ('|' <node-name>)* ('.' <property-name>)?" (example:"body|face.myDeformer") 
		public var Frames:Vector.<FrameData>; 	// sorted by FrameNumber, all animations start at 0
		public var Duration:Number;				// lastFrameNumber - firstFrameNumber
	}
}