package com.oddcast.oc3d.external
{
	import flash.geom.Point;
	
	public interface IPicker
	{
		// return a number that represents the lowest z in viewspace, if nothing is picked, return Number.MAX_VALUE
		function calculateLowestZ(viewPos:Point):Number;
		
		// if your lowest-z was indeed the lowest, this pick method will be invoked
		function pick():void;
	}
}