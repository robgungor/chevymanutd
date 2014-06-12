/**
* ...
* @author Sam Myer, Me^
* @version 1.2
* 
* Use this class to capture a movieclip or part of a movieclip as a BitmapData object
*/
package com.oddcast.utils 
{
	import flash.display.*;
	import flash.geom.*;
	
	public class BMPCapture 
	{
		/**
		 * 
		 * @param	mc				bject you want to create a bitmap of
		 * @param	captureWindow	display object that defines the capture area frame of the image.  if you don't specify captureWindow, it will default to the mc itself
		 * @param	marginX
		 * @param	marginY
		 * @param	transparent
		 * @param	_scale			scale 0-1 of the original captured image
		 * @param	_dimensions		dimensions of the capture, x=width y=height
		 * @param	_offset			offset from the registration point of the target
		 * @return
		 */
		public static function capture
		(
			mc:DisplayObject, 
			captureWindow:DisplayObject = null, 
			marginX:int = 0, 
			marginY:int = 0, 
			transparent:Boolean = false, 
			_scale:Number = Number.NaN,
			_dimensions:Point = null, 
			_offset:Point = null
		):BitmapData 
		{
			if (captureWindow == null) captureWindow = mc;
			var bmp:BitmapData;
			var matrix:Matrix;
			var scale:Number = isNaN(_scale) ? 1 : _scale;
			var bitmap_width:Number;
			var bitmap_height:Number;
			var matrix_tx:Number = _offset ? _offset.x : 0;
			var matrix_ty:Number = _offset ? _offset.y : 0;
			//mc.stage.bgCol
			if (captureWindow is Stage) 
			{
				var stg:Stage	= captureWindow as Stage;
				bitmap_width	= _dimensions ? _dimensions.y : stg.stageWidth + marginX * 2;
				bitmap_height	= _dimensions ? _dimensions.x : stg.stageHeight + marginY * 2;
				bmp = new BitmapData(bitmap_width * scale, bitmap_height * scale, transparent, transparent?0x00FFFFFF:0xFFFFFFFF);
				if (mc is Stage) matrix = new Matrix(1, 0, 0, 1, matrix_tx, matrix_ty);
				else matrix = mc.transform.concatenatedMatrix;
				matrix.translate(marginX, marginY);
				matrix.scale(scale, scale);
				bmp.draw(mc,matrix);
			}
			else 
			{
				var bounds:Rectangle = captureWindow.getBounds(mc);
				bitmap_width	= _dimensions ? _dimensions.y : bounds.width + marginX * 2;
				bitmap_height	= _dimensions ? _dimensions.x : bounds.height + marginY * 2;
				bmp = new BitmapData(bitmap_width * scale, bitmap_height * scale, transparent, transparent?0x00FFFFFF:0xFFFFFFFF);
				matrix = new Matrix(1, 0, 0, 1, matrix_tx, matrix_ty);
				matrix.translate( -bounds.x, -bounds.y);
				matrix.translate(marginX, marginY);
				matrix.scale(scale, scale);
				bmp.draw(mc, matrix);
			}
			return(bmp);
		}
	}
	
}