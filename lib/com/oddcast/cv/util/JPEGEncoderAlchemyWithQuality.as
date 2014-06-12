

	/**
	 * ...
	 * @author Jake Lewis
	 *  3/26/2010 3:45 PM
	 */
package  com.oddcast.cv.util{
	//import com.oddcast.cv.util.JPEGEncoderAlchemyWithQuality;
	
	import com.oddcast.host.engine3d.texture.IQualityImageEncoder;
	
	
	public class JPEGEncoderAlchemyWithQuality extends JPEGEncoderAlchemy implements IQualityImageEncoder
	{
		
		public function JPEGEncoderAlchemyWithQuality(quality:Number = 60.0) {
			super(quality);
		}

	}
}