package com.oddcast.oc3d.core
{
	
	
	public interface IRenderEngine
	{
		function trianglesRendered():uint;
		
		function renderPasses():uint; 
			
		function enabled():Boolean;
		function setEnabled(v:Boolean):void;

		function registerExternalRenderer(name:String, renderFn:Function, layer:IRenderLayer):void;
		function unregisterExternalRenderer(name:String):void;
		
		// Array<Array<RenderListItem>>
		function renderLists():Array
			
		function setProjectOnly(v:Boolean):void;
		function projectOnly():Boolean;
	}
}