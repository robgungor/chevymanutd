/**
 * ...
 * @author Jake Lewis
 * IntermediateSprite - shows debugging images on stage
 */

package com.oddcast.cv.util;
//import com.oddcast.cv.util.IntermediateSprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import com.oddcast.cv.util.NamedSprite;
import com.oddcast.cv.util.IIntermediateSprite;
import com.oddcast.cv.IDisposable;

class IntermediateSprite extends NullIntermediateSprite
{


	override public function setBitmap(bitmap:Bitmap, bDispose:Bool= false):IIntermediateSprite {
		if (this.bitmap != null){
			removeChild(this.bitmap);
			if (bDispose)
				this.bitmap.bitmapData.dispose;
		}
		this.bitmap = bitmap;
		if(bitmap!=null)
			addChildAt(bitmap,0);
		return super.setBitmap(bitmap);
	}
	override public function setBitmapData(bitmapData:BitmapData, bDispose:Bool= false):IIntermediateSprite {
		
		setBitmap(new Bitmap(bitmapData), bDispose);
		return super.setBitmapData(bitmapData);
	}
	
	override public function setPos(x:Int, y:Int):IIntermediateSprite { 
		this.x = x;
		this.y = y;
		return super.setPos(x, y);
	}
	
	override public function setScale(s:Float):IIntermediateSprite { 
		scaleX = scaleY = s;
		return super.setScale(s); 
	}
	
	override public function addIntermediateSprite(name:String):IIntermediateSprite { 
		var ret = new IntermediateSprite(name);
		addChild(ret);
		return ret;
	}
	
	override public function dispose():Void {
		super.dispose();
		if (parent != null)
			parent.removeChild(this);
		setBitmap(null);
		
		var nChildren = numChildren;
		var aDispose = new Array<IntermediateSprite>();
		for ( n in 0...nChildren) {
			var child = getChildAt(n);
			if (Std.is(child, IntermediateSprite)){
				var iChild = cast (child, IntermediateSprite);
				aDispose.push(iChild);
			}
			
		}
		Disposable.disposeIterableIfValid(aDispose);
		
	}
	
	var bitmap	:Bitmap;
	
}