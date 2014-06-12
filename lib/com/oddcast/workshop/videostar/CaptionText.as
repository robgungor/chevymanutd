/**
* ...
* @author Default
* @version 0.1
*/

package com.oddcast.workshop.videostar {

	public class CaptionText {
		public var text:String;
		public var name:String;
		public var font:String;
		public var pointSize:uint;
		public var strokeSize:Number;
		public var strokeColor:uint;
		public var fillColor:uint;
		public var align:String;
		
		public static const ALIGN_CENTER:String = "center";
		
		public function CaptionText($text:String,$name:String,$font:String="Arial",$pointSize:uint=12,$strokeSize:Number=2,$strokeColor:uint=0xFFFF00,$fillColor:uint=0xff9900,$align:String=ALIGN_CENTER) {
			text=$text;
			name=$name;
			font=$font;
			pointSize=$pointSize;
			strokeSize=$strokeSize;
			strokeColor=$strokeColor;
			fillColor = $fillColor;
			align = $align;
		}
	}
	
}