﻿/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* This is the equivalent of the ImageStickyButton in the AS2 Classes.
* The data object passed to this must implement IThumbSelectorData
* @see
* com.oddcast.ui.Selector
* com.oddcast.ui.SelectorItem
* com.oddcast.data.ThumbSelectorData
*/

package com.oddcast.ui {
	import com.oddcast.data.*;
	import com.oddcast.event.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.text.*;
	
	import org.casalib.util.RatioUtil;

	public class ThumbSelectorItem extends ButtonSelectorItem {
		private var placeholder:MovieClip;
		public var _mcImage:MovieClip;
		public var _mcLoading:MovieClip;
		private var img:*;
		private var isLoaded:Boolean;
		private var isShown:Boolean=false;
		[Inspectable] public var maintainAspect:Boolean=false;
		
		public function ThumbSelectorItem() {
			super();
			isLoaded = false;
			placeholder = _mcImage;
			showLoader(false);
			
			img=new Loader();
			img.contentLoaderInfo.addEventListener(Event.INIT,imgLoaded,false,0,true);
			img.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,imgLoadError,false,0,true);
			if (placeholder==null) addChild(img);
			else {
				addChildAt(img,this.getChildIndex(placeholder)+1);
				//removeChild(placeholder);
				placeholder.visible=false;
			}
		}

		override public function shown(b:Boolean):void {
			isShown = b;
			if (isLoaded||!isShown) return;
			if (data==null||data.thumbUrl==null||data.thumbUrl.length==0) return; //invalid url
			loadThumb();
		}
		
		private function loadThumb():void {
			img.load(new URLRequest(data.thumbUrl));
			showLoader(true);
			isLoaded=true;			
		}
		
		private function imgLoaded(evt:Event):void {
			if (placeholder!=null) {	
				maintainAspect = true;
				if (maintainAspect) {
					var size:Rectangle = new Rectangle(0, 0, img.width, img.height);
					var bounds:Rectangle = new Rectangle(0, 0, placeholder.width, placeholder.height);
					var scaled:Rectangle = RatioUtil.scaleToFill(size, bounds, true);
					
					//var scale:Number=Math.max(placeholder.width/img.width,placeholder.height/img.height);
					var dx:Number=(scaled.width-placeholder.width)/2;
					var dy:Number=(scaled.height-placeholder.height)/2;
					
					img.x=placeholder.x-dx;
					img.y=placeholder.y-dy;
					//img.width=img.width*scale;
					//img.height=img.height*scale;
					img.width = scaled.width;
					img.height = scaled.height;
					img.mask=placeholder;
				}
				else {
					img.x=placeholder.x;
					img.y=placeholder.y;
					img.width=placeholder.width;
					img.height=placeholder.height;
				}
			}
			
			// smooth out images which are pixelated
				try	{	
						var bitmap:Bitmap = evt.target.content;
						bitmap.smoothing = true;
						
						removeChild(img);
						
						bitmap = new Bitmap(bitmap.bitmapData, "auto", true);
						bitmap.x=img.x;
						bitmap.y=img.y;
						bitmap.width=img.width;
						bitmap.height=img.height;
						bitmap.mask=placeholder;
						addChildAt(bitmap,this.getChildIndex(placeholder)+1);
					}
				catch (err:Error)	
				{
					trace(err);
				}
				
			showLoader(false);
		}
		
		private function imgLoadError(evt:IOErrorEvent):void {			
			showLoader(false);
		}
		override public function set data(o:Object):void {
			if (!(o is IThumbSelectorData||o==null)) throw new TypeError("ThumbSelector must take an object that implements com.oddcast.data.IThumbSelectorData");
			super.data = o;
			if (isShown) loadThumb();
		}
//		override public function set data(o:Object):void {
//			if (!(o is IThumbSelectorData||o==null)) throw new TypeError("ThumbSelector must take an object that implements com.oddcast.data.IThumbSelectorData");
//			super.data = o;
//			if( o.thumb )
//			{
//				img = null;
//				img = (o).thumb;
//				if (placeholder==null) addChild(img);
//				else {
//					addChildAt(img,this.getChildIndex(placeholder)+1);
//					//removeChild(placeholder);
//					placeholder.visible=false;
//				}
//				imgLoaded(new Event(""));
//				isLoaded = true;
//			} else
//			{
//				if (isShown) loadThumb();
//			}
//		}

		private function showLoader(b:Boolean):void {
			if (_mcLoading != null) _mcLoading.visible = b;
		}
	}
	
}