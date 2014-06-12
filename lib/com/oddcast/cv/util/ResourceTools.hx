

	/**
	 * ...
	 * @author Jake Lewis
	 *  5/26/2010 10:57 AM
	 */
package  com.oddcast.cv.util;
//import com.oddcast.cv.util.ResourceTools; using com.oddcast.cv.util.ResourceTools;

import haxe.Resource;
import flash.display.Loader;
import flash.display.Bitmap;


class ResourceTools 
{
	
	static public function loadImageAsLoader(resourceName:String):Loader {
		var loader  = new Loader();
		loader.loadBytes(Resource.getBytes(resourceName).getData());
		
		return loader;
	}
	
	static public function smooth(loader:Loader, smoothing:Bool):Loader{
		if(loader.numChildren >0){
			var child = loader.getChildAt(0);
			var bitmap = cast(child, Bitmap);
			bitmap.smoothing = smoothing;
			return null;
		}
		return loader;
	}
	
}

