	/**  Direct replacement for mx.graphics.codecJPEGEncoder - but 8 times quicker!
	 * ...
	 * @author Jake Lewis
	 *  3/26/2010 3:45 PM
	 */
package  com.oddcast.cv.util{
	//import com.oddcast.cv.util.JPEGEncoderAlchemy;
	
	import mx.graphics.codec.IImageEncoder;
				
	
	
	public class JPEGEncoderAlchemy extends JPGEncoderAlchemy implements IImageEncoder
	{
		public function JPEGEncoderAlchemy(quality:Number = 60.0) {
			super(quality);
		}	
	}
}