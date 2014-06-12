
/** A direct replacement for com.adobe.images.JPGEncoder  - but 8 times quicker!
	 * ...
	 * @author Jake Lewis
	 *  3/26/2010 3:45 PM
	 */
package  com.oddcast.cv.util{
	//import com.oddcast.cv.util.JPGEncoderAlchemy;
	
	
	import com.adobe.images.JPGEncoder;
	import cmodule.as3_jpeg_wrapper.CLibInit;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
			
	public class JPGEncoderAlchemy extends JPGEncoder
	{
		
		public function JPGEncoderAlchemy(quality:Number = 60.0) {
			super(quality);
			var loader:CLibInit = new CLibInit;
			as3_jpeg_wrapper = loader.init();
			setQuality(quality);
		}
		
		public function setQuality(quality:Number):void{ this.quality = quality; }
		
		public function get contentType():String{return "image/jpeg"}

		override public function encode(bitmapData:BitmapData):ByteArray {
			return encodeByteArray(bitmapData.getPixels(bitmapData.rect), bitmapData.width, bitmapData.height, bitmapData.transparent);
		}

		public function encodeByteArray(	byteArray:ByteArray, 
																width:int, height:int,
																transparent:Boolean = true  //Alchemy version ignores this
															):ByteArray {
			return  as3_jpeg_wrapper.write_jpeg_file(byteArray, width, height, 3, 2, quality);	
		}	
		

		private var as3_jpeg_wrapper: Object;
		private var quality					:Number;
		
	}
}