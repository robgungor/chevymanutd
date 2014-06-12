package com.oddcast.host.api.postprocess {
	import flash.display.PixelSnapping;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	
	import com.oddcast.host.api.IHostAPI;
	public class PostProcess {
		public function PostProcess(hostAPI : com.oddcast.host.api.IHostAPI = null,clearBuffer : Boolean = false) : void {  {
			hostAPI.allowRender(false,clearBuffer);
		}}
		
		public function initBitmap(width : int,height : int) : flash.display.Bitmap {
			return this.postProcessBitmap = new flash.display.Bitmap(new flash.display.BitmapData(width,height,true,2147483647),flash.display.PixelSnapping.NEVER,true);
		}
		
		public function postProcess(hostAPI : com.oddcast.host.api.IHostAPI) : void {
			null;
		}
		
		public function unload() : void {
			this.postProcessBitmap = null;
		}
		
		protected var postProcessBitmap : flash.display.Bitmap;
	}
}
