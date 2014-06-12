/**
 * ...
 * @author Jake Lewis
 * IntermediateSprite - shows debugging images on stage
 */

package com.oddcast.cv.util;
//import com.oddcast.cv.util.IIntermediateSprite;
import com.oddcast.cv.IDisposable;
import flash.display.Bitmap; 
import flash.display.BitmapData;
import com.oddcast.cv.util.NamedSprite;
 


interface IIntermediateSprite implements IDisposable {
	function setBitmap(bitmap:Bitmap, bDispose:Bool= false)			 	:IIntermediateSprite;
	function setBitmapData(bitmapData:BitmapData, bDispose:Bool= false) :IIntermediateSprite;
	function setPos(x:Int, y:Int)										:IIntermediateSprite;
	function setScale(s:Float)					 						:IIntermediateSprite;
	function getSprite()					 							:NamedSprite;
	function addIntermediateSprite(name:String)			 				:IIntermediateSprite;
}

class NullIntermediateSprite extends NamedSprite, implements IIntermediateSprite {
	public function setBitmap(bitmap:Bitmap, bDispose:Bool= false)		    	:IIntermediateSprite { return this; }
	public function setBitmapData(bitmapData:BitmapData, bDispose:Bool= false)	:IIntermediateSprite { return this; }
	public function setPos(x:Int, y:Int)										:IIntermediateSprite { return this; }
	public function setScale(s:Float)					 						:IIntermediateSprite { return this; }
	public function getSprite()					 								:NamedSprite 		 { return this; }
	public function addIntermediateSprite(name:String)			 				:IIntermediateSprite { 
		var ret = new NullIntermediateSprite(name);
		addChild(ret);
		return ret;
	}
	
	public function dispose():Void {
		
	}
}
interface IIntermediateSpriteProvider {
	public function addIntermediateSprite(name:String):IIntermediateSprite;
}
