package custom
{
	import code.skeleton.App;
	
	import com.adobe.images.PNGEncoder;
	import com.oddcast.event.AlertEvent;
	import com.oddcast.event.SendEvent;
	import com.oddcast.utils.URL_Opener;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.Callback_Struct;
	import com.oddcast.workshop.ServerInfo;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import org.casalib.events.RemovableEventDispatcher;
	import org.casalib.util.RatioUtil;
	
	public class DanceScreenShot extends RemovableEventDispatcher
	{
		private const PROCESS_UPLOADING			:String = 'PROCESS_UPLOADING dance screen shot';
		protected var _swf				:MovieClip;
		protected var _bitmap			:Bitmap;
		protected var _tempURL			:String;
		protected var _heads			:Array;
		protected var _mouths			:Array;
		protected var _defaultHeads		:Array;
		protected var _placementRects	:Array;
		
		public function DanceScreenShot(heads:Array, mouths:Array)
		{
			super();
			_heads = heads;
			_mouths = mouths;
			_init();
		}
		protected function _init():void
		{
			App.ws_art.printProcessing.visible = true;
			///App.ws_art.printProcessing.btn_close.addEventListener(MouseEvent.CLICK, onCloseClicked);
			
			App.mediator.processing_start( PROCESS_UPLOADING);
			if(App.asset_bucket.last_mid_saved == null) _saveMessage();
			else	_loadSwf(); 
		}
		protected function _saveMessage():void
		{
			App.utils.mid_saver.save_message(new SendEvent(SendEvent.SEND, SendEvent.DOWNLOAD_VIDEO), new Callback_Struct( fin, null, null ) );
			
			function fin():void 
			{	
				_loadSwf();	
			}	
		}
		
		protected function _loadSwf():void
		{			
			var dances:Array = ["Classic","Soul","Hip_Hop","80s","Charleston"];
			var headCount:Number = 0;
			for(var i:Number = 0; i<App.mediator.savedHeads.length; i++)
			{	
				if(App.mediator.savedHeads[i] != null) headCount++;
			}
			var url:String = ServerInfo.content_url_door + "misc/"+dances[App.mediator.danceIndex]+"_"+headCount+"_screenshot.swf";
			Gateway.retrieve_Loader( new Gateway_Request(url, new Callback_Struct( _onSwfLoaded ) ) );
		}
		protected function _onSwfLoaded(l:Loader):void
		{
			_swf = (l).content as MovieClip;
			_makePlacementRects();
			_updateHeads();
			_takeScreenShot();
		}
		protected function _updateHeads(e:Event = null):void
		{
			var dup:Number = 0;
			for( var i:Number = 0; i< 5; i++)
			{	
				var head:* = _heads[i];
				if(head == null && App.mediator.danceIndex == 3) 
				{
					if(dup > _heads.length-1) dup = 0;
					head = _heads[dup];
					dup++;
				}
				if(head != null) swapHead(head, i, _mouths[i]);
			}			
		}
		public function swapHead( bmp:Bitmap, index:Number, mouth:* = null):void
		{
			var mouthBmp:Bitmap;
			
			if(mouth is Number)
			{
				mouth = _makeMouth(bmp, mouth);
			}
			if( mouth is Bitmap ) mouthBmp = mouth;
			mouthBmp = new Bitmap(mouthBmp.bitmapData, "auto", true);
			
			var head:MovieClip = _swf.getChildByName("head"+(index+1)) as MovieClip
			var headSize	:Rectangle 	= RatioUtil.scaleToFill( new Rectangle(0,0,bmp.width, bmp.height), _placementRects[index]);
			
			
			if(bmp is Bitmap) bmp = new Bitmap((bmp as Bitmap).bitmapData.clone(), "auto", true);
				
			if(App.mediator.danceIndex == 0) bmp = _makeNoMouthFace(bmp, bmp.height - mouthBmp.height);
			
			//set size
			bmp.width 			= headSize.width;
			bmp.scaleY 			= bmp.scaleX;
	
			//if(_currentDanceClip.getHeadByDepth is Function) head = _currentDanceClip.getHeadByDepth(index);
				
			//_currentDanceClip.getChildAt(faceOrder[index]) as MovieClip;
			if(head && head.numChildren > 0)
			{
				var mouthMC	:MovieClip = head.getChildByName("mouth") as MovieClip;
				var faceMC	:MovieClip = head.getChildByName("face") as MovieClip;
				
				if(App.mediator.danceIndex == 0)
				{
					mouthBmp.scaleX = bmp.scaleX;
					mouthBmp.scaleY = bmp.scaleY;
					mouthBmp.y 		= (bmp.height+bmp.y);				
					
					if(mouthMC)
					{
						mouthMC.removeChildAt( 0 );
						mouthMC.addChild( mouthBmp );
					}
					
					head.addChildAt(faceMC, 1); 
				}
				
				if(faceMC)
				{
					faceMC.removeChildAt( 0 );
					faceMC.addChild( bmp );
				}
			}
		}
		private function _makePlacementRects():void
		{
			_placementRects = [];
			for(var i:Number = 1; i<6; i++)
			{
				var h:MovieClip = _swf.getChildByName("head"+String(i)) as MovieClip;
				var bmp:* = (h.getChildByName("face") as MovieClip).getChildAt(0);
				if(bmp) _makePlacementRect(bmp);
			} 	
		}
		private function _makePlacementRect( obj:DisplayObject ):void
		{
			_placementRects.push(new Rectangle( obj.x, obj.y, obj.width, obj.height ));
		}
		protected function _makeMouth(face:Bitmap, mouthCutPoint:Number):Bitmap
		{
			var data:BitmapData = new BitmapData(face.width, face.height-mouthCutPoint, true, 0x0000000);
			var mat:Matrix = new Matrix();
			
			var rect:Rectangle = new Rectangle(0,mouthCutPoint,face.width,face.height-mouthCutPoint);
			mat.translate( -rect.x, -rect.y);
			
			data.draw(face, mat);
			
			return new Bitmap(data, "auto", true);
		}
		
		protected function _makeNoMouthFace(face:Bitmap, mouthCutPoint:Number):Bitmap
		{
			var data:BitmapData = new BitmapData(face.width, mouthCutPoint, true, 0x0000000);
			var mat:Matrix = new Matrix();
			data.draw(face);//, mat);
			return new Bitmap(data, "auto", true);
		}
		protected function _takeScreenShot():void
		{
			_bitmap = new Bitmap();
			_bitmap.bitmapData = new BitmapData(_swf.width, _swf.height, true);
			_bitmap.bitmapData.draw(_swf);
			_uploadImage();
			
		}
		protected function _uploadImage():void
		{
			var img_data:ByteArray = PNGEncoder.encode( _bitmap.bitmapData );
			App.utils.image_uploader.upload_binary( new Callback_Struct( _onImageUploaded, null, error ), img_data, "png");
			
			function error(e:*):void
			{
				App.mediator.alert_user(new AlertEvent(AlertEvent.ERROR, 'f9t201', 'Error saving image.'));
			}
		}
		
		protected function _onImageUploaded(bg:*):void
		{
			App.mediator.processing_ended( PROCESS_UPLOADING);
			_tempURL = bg.url;
			App.ws_art.printProcessing.visible 	= false;
			App.ws_art.printReady.visible 		= true;
			App.ws_art.printReady.btn_ok.addEventListener(MouseEvent.CLICK, onOkClicked);
			App.ws_art.printReady.btn_close.addEventListener(MouseEvent.CLICK, onCloseClicked);
		}
		protected function onCloseClicked(e:MouseEvent):void
		{
			destroy();
		}
		protected function onOkClicked(e:MouseEvent):void
		{
			var url:String = ServerInfo.localURL + "api_misc/1083/getCode.php?mId="+App.asset_bucket.last_mid_saved+"&url="+_tempURL;
			URL_Opener.open_url( url, "_blank");
			destroy();
		}
		override public function destroy():void
		{
			App.ws_art.printReady.visible = false;
			App.ws_art.printReady.btn_ok.removeEventListener(MouseEvent.CLICK, onOkClicked);
			App.ws_art.printReady.btn_close.removeEventListener(MouseEvent.CLICK, onCloseClicked);
			super.destroy();
		}
		protected function _onImageSaved(e:*):void
		{
			
		}
		
	}
}