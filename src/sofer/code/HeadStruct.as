package code
{
	import com.oddcast.data.IThumbSelectorData;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.casalib.events.RemovableEventDispatcher;
	
	public class HeadStruct extends RemovableEventDispatcher implements IThumbSelectorData
	{
		public function HeadStruct(image:DisplayObject, url:String, thumb:DisplayObject = null, mouthCutPoint:Number = 1)
		{
			super();
			this._image = image;
			this._url = url;
			this._mouthCutPoint = mouthCutPoint;
			if(thumb) this._thumb = thumb;
			
			if( _image is Bitmap)
			{
				thumb = new Bitmap((_image as Bitmap).bitmapData.clone(), "auto", true);
			}else
			{
				var data:BitmapData = new BitmapData(_image.width, _image.height, true, 0x0000000);
				var mat:Matrix = new Matrix();
				var rect:Rectangle = (_image as Shape).getBounds( _image.parent );
				mat.translate( -rect.x, -rect.y);
				data.draw(_image, mat);
				_image  = new Bitmap(data, "auto", true);
			}
		}
		private var _image	:DisplayObject;
		private var _thumb	:DisplayObject;
		private var _url		:String;
		private var _mouthCutPoint:Number;
		
		public function get image():Bitmap
		{
			var data:BitmapData = new BitmapData(_image.width, _image.height, true, 0x0000000);
			var mat:Matrix = new Matrix();
			if(_image.parent) 
			{
				var rect:Rectangle = _image.getBounds( _image.parent );
				mat.translate( -rect.x, -rect.y);
			}
			data.draw(_image, mat);
			return new Bitmap(data, "auto", true);
			 
		}
		public function get mouth():DisplayObject
		{
			var data:BitmapData = new BitmapData(_image.width, _image.height, true, 0x0000000);
			var mat:Matrix = new Matrix();
			
			var rect:Rectangle = new Rectangle(0,_mouthCutPoint,_image.width,_image.height-_mouthCutPoint);
			mat.translate( -rect.x, -rect.y);
			
			data.draw(_image, mat);
			return new Bitmap(data, "auto", true);
		}
		public function get thumbUrl():String
		{
			return _url;
		}
		public function set image(value:Bitmap):void
		{
			_image = value;
		}

		public function get thumb():DisplayObject
		{
			return _thumb;
		}

		public function set thumb(value:DisplayObject):void
		{
			_thumb = value;
		}

		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			_url = value;
		}
		public function get mouthCutPoint():Number
		{
			return _mouthCutPoint;
		}


	}
}