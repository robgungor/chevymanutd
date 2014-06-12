package com.oddcast.oc3d.core
{
	import com.oddcast.oc3d.data.AvatarData;

	public interface IAvatar2AsPlugIn
	{
		function convert(data:AvatarData):String; // converts avatar data in to as3 source code
	}
}