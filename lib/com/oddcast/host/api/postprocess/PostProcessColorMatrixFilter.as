package com.oddcast.host.api.postprocess {
	import com.oddcast.host.api.postprocess.PostProcess;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.filters.ColorMatrixFilter;
	
	import com.oddcast.host.api.IHostAPI;
	public class PostProcessColorMatrixFilter extends com.oddcast.host.api.postprocess.PostProcess {
		public function PostProcessColorMatrixFilter(hostAPI : com.oddcast.host.api.IHostAPI = null,clearBuffer : Boolean = false) : void {  {
			super(hostAPI,clearBuffer);
		}}
		
		public function setFilter(cfm : flash.filters.ColorMatrixFilter) : void {
			this.colorMatrixFilter = cfm;
		}
		
		public override function postProcess(hostAPI : com.oddcast.host.api.IHostAPI) : void {
			this.postProcessBitmap.bitmapData.fillRect(new flash.geom.Rectangle(0,0,this.postProcessBitmap.bitmapData.width,this.postProcessBitmap.bitmapData.height),2147483647);
			hostAPI.renderInto(this.postProcessBitmap);
			this.applyColorMatrix(this.postProcessBitmap,this.colorMatrixFilter);
		}
		
		protected function applyColorMatrix(bitmap : flash.display.Bitmap,cfm : flash.filters.ColorMatrixFilter) : void {
			bitmap.bitmapData.applyFilter(bitmap.bitmapData,new flash.geom.Rectangle(0,0,bitmap.bitmapData.width,bitmap.bitmapData.height),new flash.geom.Point(),cfm);
		}
		
		protected var colorMatrixFilter : flash.filters.ColorMatrixFilter;
	}
}
