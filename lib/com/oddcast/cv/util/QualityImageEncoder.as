	/**  stub for IImageEncoder implementation - needed to circumvent haXe inability to properly implement 'get contentType()'
	 * ...
	 * @author Jake Lewis
	 *  3/26/2010 3:45 PM
	 */
	
package  com.oddcast.cv.util{
	//import com.oddcast.cv.util.QualityImageEncoder;
	
	
	
	import mx.graphics.codec.IImageEncoder;
	import flash.utils.ByteArray;	
	import flash.display.BitmapData;
	
	
	
	public class QualityImageEncoder implements IImageEncoder
	{
		public function QualityImageEncoder(){} 
		
		public function get contentType():String {	return getContentType(); }
		
		public function getContentType():String {
			return null;
		}
		
		public function encode(bitmapData:BitmapData):ByteArray { return null; }
		
		public function setQuality(quality:Number):void{}

		public function encodeByteArray(byteArray:ByteArray, width:int, height:int, transparent:Boolean = true):ByteArray{ return null;}
	}
}