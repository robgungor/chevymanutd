package com.oddcast.oc3d.shared
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.IBitmapDrawable;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class Image 
	{
		public static const DEBUG_ENABLED:Boolean = false;
		
		private static const IMAGE_POOL_ENABLED:Boolean = true;
		public static const DEBUG_POOL_ENABLED:Boolean = false;
		
		public static var ColorTransforms:Dictionary = new Dictionary(); // Dictionary<uri:String, ColorMatrixFilter>
		
		private var data_:BitmapData;
		private static var instanceCounter_:uint = 0;
		private static var idCounter_:uint = 0;
		private var id_:uint;
		private var uri_:String;
		
		// caller must free deserialized texture
		public static function assemble(uri:String, disTex:Vector.<BitmapData>):Image
		{
			if (disTex == null || disTex.length == 0 || disTex.length > 2)
				return null;
			
			var result:BitmapData;
			if (disTex.length == 2) // has alpha channel
			{
				var color:BitmapData = disTex[0];
				var alpha:BitmapData = disTex[1];
				result = newBitmap(color.width, color.height);
				result.copyPixels(color, color.rect, new Point());
				result.copyChannel(alpha, alpha.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			}
			else
				result = BitmapData(disTex[0]).clone();
			
			return Image.createFromBitmapData(uri, result);
		}
		
		// takes responsibility of BitmapData
		public static function createFromBitmapData(uri:String, bm:BitmapData):Image
		{
			var img:Image = new Image(0, 0);
			img.uri_ = uri;
			img.data_ = bm;
			if (DEBUG_ENABLED)
			{
				++instanceCounter_;
				img.id_ = ++idCounter_;
				trace("image::image(bm)  : id:" + img.id_ + " (w:" + bm.width + " h:" + bm.height + ") ttl:" + instanceCounter_ + " uri:" + img.uri_); 
			}
			return img;
		}

		public function Image(width:int, height:int, transparent:Boolean=true, fillColor:uint=0xffffffff)
		{
			uri_ = "";
			if (width != 0 && height != 0)
			{
				data_ = newBitmap(width, height, transparent, fillColor);
				if (DEBUG_ENABLED)
				{
					++instanceCounter_;
					id_ = ++idCounter_; 
					trace("image::image(w,h) : id:" + id_ + " (w:" + width + " h:" + height + ") ttl:" + instanceCounter_ + " uri:" + uri_);
				}
			}
			else
				prePopulate();
		}
		
		public function setUri(v:String):void
		{
			uri_ = v;
		}
		
		public function uri():String
		{
			return uri_;
		}

		public function clone():Image
		{
			var img:Image = new Image(0, 0);
			img.data_ = data_.clone();
			if (DEBUG_ENABLED)
			{
				++instanceCounter_;
				img.id_ = ++idCounter_; 
				trace("image::clone()    : id:" + img.id_ + " (w:" + img.data_.width + " h:" + img.data_.height + ") ttl:" + instanceCounter_ + " uri:" + uri_);
			}
			return img;
		}
		
		public function dispose():void
		{
			if (data_ != null)
			{
				var w:int = data_.width;
				var h:int = data_.height;
				disposeBitmap(data_);
				data_ = null;
				
				if (DEBUG_ENABLED)
				{
					trace("image::dispose()  ~ id:" + id_ + " (w:" + w + " h:" + h + ") ttl:" + (instanceCounter_-1) + " uri:" + uri_);
					--instanceCounter_;
				}
			}
		}
		
		public function width():int
		{
			return data_.width;
		}
		
		public function data():BitmapData { return data_; }
		public function getPixel32(x:int, y:int):uint
		{
			return data_.getPixel32(x, y);
		}
		public function getPixel(x:int, y:int):uint
		{
			return data_.getPixel(x, y);
		}
		public function applyFilter(sourceBitmapData:Image, sourceRect:Rectangle, destPoint:Point, filter:BitmapFilter):void
		{
			data_.applyFilter(sourceBitmapData.data_, sourceRect, destPoint, filter);
		}
		public function draw(source:IBitmapDrawable, matrix:Matrix=null, colorTransform:ColorTransform=null, blendMode:String=null, clipRect:Rectangle=null, smoothing:Boolean=false):void
		{
			data_.draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
		}
		public function height():int
		{
			return data_.height;
		}
		
		public function bounds():Rectangle
		{
			return data_.rect;
		}
		
		public function copyChannel(source:Image, sourceRect:Rectangle, destPoint:Point, sourceChannel:uint, destChannel:uint):void
		{
			data_.copyChannel(source.data_, sourceRect, destPoint, sourceChannel, destChannel);
		}		
		public function isTransparent():Boolean
		{
			return data_.transparent;
		}
		
		//private static var jpeginit:CLibInit = new CLibInit();
		//private static var jpegEncoder:Object = jpeginit.init(); 
		public function disassemble(jpgQuality:Number=60.0):Vector.<ByteArray>
		{
			var finalQuality:Number = jpgQuality;
			var result:Vector.<ByteArray>;
			if (data_.transparent)
			{
				result = new Vector.<ByteArray>(2, true);
				
				// compress color with jpg
				var color:BitmapData = data_.clone()
				color.colorTransform(color.rect, new ColorTransform(1, 1, 1, 0, 0, 0, 0, 255));
				result[0] = (new JPGEncoder(finalQuality)).encode(color);
				disposeBitmap(color);
				
				// compress alpha with png
				var alpha:BitmapData = newBitmap(data_.width, data_.height, false, 0);
				alpha.copyChannel(data_, data_.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.RED); // storing alpha in red channel
				alpha.copyChannel(data_, data_.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN); 
				alpha.copyChannel(data_, data_.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
				result[1] = PNGEncoder.encode(alpha);
				disposeBitmap(alpha);
			}
			else
			{
				// compress with jpg
				result = new Vector.<ByteArray>(1, true);
				result[0] = (new JPGEncoder(finalQuality)).encode(data_);
			}
			return result;
		}
		
		// IMAGE POOL///////////////////////////////////////////////////////
		private static var imagePool:Dictionary; // Dictionary<key:String, Array>
		private static const poolSizeForEachSize:uint = 6;
		private static function prePopulate():void
		{
			if (imagePool != null)
				return;
			imagePool = new Dictionary();
			imagePool["128:128:true"] = 
			[
				new BitmapData(128, 128, true),
				new BitmapData(128, 128, true),
				new BitmapData(128, 128, true)
			];
			imagePool["128:128:false"] = 
			[
				new BitmapData(128, 128, false),
				new BitmapData(128, 128, false),
				new BitmapData(128, 128, false)
			];
			imagePool["192:192:true"] =
			[
				new BitmapData(192, 192, true),
				new BitmapData(192, 192, true),
				new BitmapData(192, 192, true),
			];
			imagePool["192:192:false"] =
			[
				new BitmapData(192, 192, false),
				new BitmapData(192, 192, false),
				new BitmapData(192, 192, false),
			];
			imagePool["256:256:true"] =
			[
				new BitmapData(256, 256, true),
				new BitmapData(256, 256, true),
				new BitmapData(256, 256, true),
			];
			imagePool["256:256:false"] = 
			[
				new BitmapData(256, 256, false),
				new BitmapData(256, 256, false),
				new BitmapData(256, 256, false)
			];
			imagePool["384:384:true"] =
			[
				new BitmapData(384, 384, true),
				new BitmapData(384, 384, true),
				new BitmapData(384, 384, true),
			];
			imagePool["384:384:false"] = 
			[
				new BitmapData(384, 384, false),
				new BitmapData(384, 384, false),
				new BitmapData(384, 384, false),
			];
			imagePool["512:512:true"] =
			[
				new BitmapData(512, 512, true),
				new BitmapData(512, 512, true),
				new BitmapData(512, 512, true),
			];
			imagePool["512:512:false"] =
			[
				new BitmapData(512, 512, false),
				new BitmapData(512, 512, false),
				new BitmapData(512, 512, false),
			];
		}
		private static function newBitmap(width:int, height:int, transparent:Boolean=true, fillColor:uint=0xffffffff):BitmapData
		{
			if (!IMAGE_POOL_ENABLED)
				return new BitmapData(width, height, transparent, fillColor);
			else
			{
				prePopulate();
				var key:String = width + ":" + height + ":" + transparent;
				var bitmaps:Array = imagePool[key];
				if (bitmaps == null || bitmaps.length == 0)
				{
					if (DEBUG_POOL_ENABLED)
						trace("newBitmap (" + key + ")");
					return new BitmapData(width, height, transparent, fillColor);
				}
				else
				{
					var bitmap:BitmapData = bitmaps.pop();
					bitmap.fillRect(bitmap.rect, fillColor);
					return bitmap;
				}
			}
		}
		private static function disposeBitmap(bm:BitmapData):void
		{
			if (!IMAGE_POOL_ENABLED)
				bm.dispose();
			else
			{
				var key:String = bm.width + ":" + bm.height + ":" + bm.transparent;
				var bitmaps:Array = imagePool[key];
				if (bitmaps == null)
					imagePool[key] = bitmaps = [bm];
				else if (bitmaps.length < poolSizeForEachSize)
					bitmaps.push(bm);
				else
				{
					if (DEBUG_POOL_ENABLED)
						trace("disposeBitmap (" + key + ")");
					bm.dispose();
				}
			}
		}
	}
}







