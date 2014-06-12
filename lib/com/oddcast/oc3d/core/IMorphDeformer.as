package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.shared.*;
	
	public interface IMorphDeformer extends IDeformer
	{
		function tryGetWeight(channelIndex:uint):RangedNumber;
		function tryFindMorphName(channelIndex:uint):String;
		
		function setWeight(channelIndex:uint, value:RangedNumber):void;
		
		function morphCount():uint;
	}
}