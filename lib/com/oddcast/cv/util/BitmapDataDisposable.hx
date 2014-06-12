/**
 * ...
 * @author Jake Lewis
 */

package com.oddcast.cv.util;
//import com.oddcast.cv.util.BitmapDataDisposable;

import flash.display.BitmapData;
import com.oddcast.cv.IDisposable;
import com.oddcast.util.PointTools;

class BitmapDataDisposable extends BitmapData, implements IDisposable
{

	public function makeClone():BitmapDataDisposable {
		var clone = new BitmapDataDisposable(width, height, transparent);
		clone.copyPixels(this, rect, PointTools.ZERO);
		return clone;
	}
	
	override public function dispose():Void 
	{
		super.dispose();
	}
	
}