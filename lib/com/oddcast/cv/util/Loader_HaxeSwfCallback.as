package com.oddcast.cv.util 
//import com.oddcast.cv.util.Loader_HaxeSwfCallback
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	/**
	 * ...
	 * @author Jake Lewis
	 * 6/24/2010 12:10 PM
	 * usage:
	 * var loader = new Loader_HaxeSwfCallback(haxeSwfLoadedCallbackFunction, "com.oddcast.cv.api.FaceFinderSWF");
	   //add your error listeners here 
	   loader.load(	new URLRequest("FaceFinder_F9.swf")	);
	   
	   
	   public function haxeSwfLoadedCallbackFunction(swf:MovieClip, haxeRootClass:Class):void{
			
			var faceFinderSWF = new haxeRootClass(); // of type com.oddcast.cv.api.FaceFinderSWF, but this is not actually typed in your application
			api = faceFinderSWF.getAPI();		 
	   }	
	 * 
	 */
	public class Loader_HaxeSwfCallback extends Loader
	{
		//callback(swf:MovieClip, haxeRootClass:Class):void
		public function Loader_HaxeSwfCallback(callBack:Function, qualifiedClassName:String) 
		{
			super();
			this.callBack = callBack;
			this.qualifiedClassName = qualifiedClassName;
		}
		
		override public function load(request:URLRequest, context:LoaderContext = null):void {
			contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			super.load(request, context);
		}
		
		private function completeHandler(event:Event):void {
			contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			var desiredClass:Class = contentLoaderInfo.applicationDomain.getDefinition(qualifiedClassName) as Class;
		//	var desiredClassInstance:MovieClip = contentLoaderInfo.applicationDomain.getDefinition(qualifiedClassName)._this as MovieClip;
            callBack(content as MovieClip , desiredClass );
			callBack = null;
        }
		
		private var callBack			:Function;
		private var qualifiedClassName	:String;
	}

}