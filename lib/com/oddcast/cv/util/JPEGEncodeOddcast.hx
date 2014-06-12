
/*
 *  wraps various jpg encoders with a class that implements mx.graphics.codec.IImageEncoder
 * 
 * 
 */


package  com.oddcast.cv.util;
//import com.oddcast.cv.util.JPEGEncodeOddcast;

import com.oddcast.host.engine3d.texture.TextureWriter;//  import com.oddcast.host.engine3d.texture.IQualityImageEncoder;
import com.oddcast.cv.IDisposable;

#if polygonal
import de.polygonal.gl.codec.JPEGEncode;
#elseif true
import mx.graphics.codec.JPEGEncoder;
#end


import flash.utils.ByteArray;
import flash.display.BitmapData;


class JPEGEncodeOddcast extends QualityImageEncoder  //which is a stump implementation of mx.graphics.codec.IImageEncoder in .as
						  ,implements IDisposable
{
	
		
	public function new(quality:Int = 50) {
		super();
		#if polygonal
		polygonalEncoder = new JPEGEncode(quality);
		#elseif true
		f9jpegEncoder =    new JPEGEncoder(quality);
		#end
		_quality = quality;
	}
	
	override public function getContentType():String {
		#if polygonal
		return polygonalEncoder.getContentType();
		#elseif true
		return f9jpegEncoder.contentType;
		#end
		 
	}
	
	override public function encode(bitmapData:BitmapData):ByteArray { 
		#if polygonal
		return polygonalEncoder.encode(bitmapData);
		#elseif true
		return f9jpegEncoder.encode(bitmapData);
		#end
		
	}
	
	override public function encodeByteArray(byteArray:ByteArray, width:Int, height:Int, transparent:Bool = true):ByteArray { 
		#if polygonal
		return polygonalEncoder.encodeByteArray(byteArray, width, height, transparent); 
		#elseif true
		return f9jpegEncoder.encodeByteArray(byteArray, width, height, transparent); 
		#end
	}
			
	
	
		
	override public function setQuality(quality:Float):Void {
		if ( quality != _quality)
			throw "cannot change quality";
	}
	
	public function dispose():Void {
		#if polygonal
		polygonalEncoder.free();
		polygonalEncoder = null;
		#elseif true
		f9jpegEncoder = null;
		#end
	}
	
	#if polygonal
	var polygonalEncoder 		: JPEGEncode;
	#elseif true
	var	f9jpegEncoder 			: JPEGEncoder;
	#end
	var _quality		: Int;
	
}