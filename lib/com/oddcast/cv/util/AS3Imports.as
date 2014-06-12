package com.oddcast.cv.util 
{
	/**
	 * ...
	 * @author Jake Lewis
	 * 6/23/2010 6:40 PM
	 * ensures that all the required as files are made into a swf that can then be run thru hxclasses
	 */
	import  com.oddcast.utils.Webcamera;
	import  com.oddcast.cv.util.QualityImageEncoder; 
	
	import mx.utils.Base64Decoder;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	import mx.graphics.codec.IImageEncoder;
	
	public class AS3Imports
	{
		
		public function AS3Imports() 
		{
			var wc		:Webcamera 				= new Webcamera();
			var qie		:QualityImageEncoder 	= new QualityImageEncoder();
			//var vc	:WebcamCapture 			= new WebcamCapture();
			var png		:PNGEncoder 			= new PNGEncoder();
			var base64u	:Base64Decoder 			= new Base64Decoder();
			var jpegEncode:JPEGEncoder			= new JPEGEncoder();
		}
		
	}

}