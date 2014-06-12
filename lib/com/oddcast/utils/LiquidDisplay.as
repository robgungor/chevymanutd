/**
* ...
* @author Default
* @version 0.1
*/

package com.oddcast.utils {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
		
	public class LiquidDisplay {
		private var stageWidth:Number;
		private var stageHeight:Number;
		private var mcArr:Array;
		
		private static var mcChecked:Dictionary;
		
		public function LiquidDisplay(in_stageW:Number,in_stageH:Number) {
			stageWidth=in_stageW;
			stageHeight=in_stageH;
			mcArr=new Array();
		}

		public function registerMC(mc:MovieClip,doCenter:Boolean=false,doScale:Boolean=true,scaleY:Boolean=false) {
			trace("registermc")
			var obj:Object=new Object();
			obj.mc=mc;
			obj.center=doCenter;
			obj.scale=doScale;
			obj.scaleY=scaleY;
			var bounds:Rectangle;
			bounds=getVisibleBounds(mc);
			//bounds=new Rectangle(mc.x,mc.y,mc.width,mc.height);
			obj.top=bounds.top;
			obj.left=bounds.left;
			obj.right=stageWidth-bounds.right;
			obj.bottom=stageHeight-bounds.bottom;
			//trace([obj.mc.name,obj.left,obj.top,obj.right,obj.bottom])
			mcArr.push(obj);
		}

		public function update(newWidth:Number,newHeight:Number) {
			for (var i:int=0;i<mcArr.length;i++) adjustMC(mcArr[i],newWidth,newHeight);
		}
		
		private function adjustMC(obj:Object,nw:Number,nh:Number) {
			var mc:MovieClip=obj.mc;
			if (mc==null||mc.stage==null) return;
			var bounds:Rectangle;
			bounds=getVisibleBounds(mc);
			//bounds=new Rectangle(mc.x,mc.y,mc.width,mc.height);
			
			var minMargin:Number;
			var dw:Number=nw-bounds.width;
			var dh:Number=nh-bounds.height;
			var leftAlign:Boolean=(obj.right>=obj.left);
			//if (obj.scale) trace(mc.name+" : ("+dw+"<0||("+dh+"<0&&"+obj.scaleY+")||"+mc.scaleX+"<1)   ---  "+(obj.scale&&(dw<0||(dh<0&&obj.scaleY)||mc.scaleX<1)));
			
			
			if (obj.scale||obj.scaleY) {
				var newScale:Number=1;
				if (obj.scale&&(dw<0||mc.scaleX<1)) {
					mc.width=nw*(mc.width/bounds.width);
					newScale=Math.min(newScale,mc.scaleX);
				}
				if (obj.scaleY&&(dh<0||mc.scaleY<1)) {
					mc.height=nh*(mc.height/bounds.height);
					newScale=Math.min(newScale,mc.scaleY);
				}
				
				mc.scaleY=mc.scaleX=newScale;
				//trace("new scale = "+mc.scaleX);
				bounds=getVisibleBounds(mc);
				dw=nw-bounds.width;
				dh=nh-bounds.height;
			}
			
			
			/*
			 * OLD - DEPRECATED
			 * 
			 * if (obj.scale&&(dw<0||(dh<0&&obj.scaleY)||mc.scaleX<1)) {
				//trace("new width = "+(nw*(mc.width/bounds.width))+" = "+nw+"*("+mc.width+"/"+bounds.width+")");
				mc.width=nw*(mc.width/bounds.width);
				if (obj.scaleY) {
					mc.height=nh*(mc.height/bounds.height);
					mc.scaleX=Math.min(mc.scaleX,mc.scaleY,1);
				}
				else mc.scaleX=Math.min(mc.scaleX,1);
				mc.scaleY=mc.scaleX;
				//trace("new scale = "+mc.scaleX);
				bounds=getVisibleBounds(mc);
				dw=nw-bounds.width;
				dh=nh-bounds.height;
			}*/
			
			minMargin=Math.min(obj.left,obj.right);
			var newx:Number;
			if (obj.center) newx=dw/2;
			else if (dw>2*minMargin) {
				if (leftAlign) newx=obj.left;
				else newx=nw-(mc.width+obj.right);
			}
			else if (dw>=0) newx=dw/2;
			else newx=0;
			
			mc.x=newx+(mc.x-bounds.left)
			
			//---vert
			
			var topAlign:Boolean=(obj.bottom>=obj.top);
			minMargin=Math.min(obj.top,obj.bottom);
			var newy:Number;
			if (dh>2*minMargin) {
				if (topAlign) newy=obj.top;
				else newy=nh-(bounds.height+obj.bottom);
			}
			else newy=dh/2;

			mc.y=newy+(mc.y-bounds.top)
		}
		
		public static function getVisibleBounds(mc:DisplayObject):Rectangle {
			mcChecked=new Dictionary(true);
			if (mc==null) return(new Rectangle());
			return(getVisibleBoundsAux(mc,mc.parent,true));
		}

		private static function getVisibleBoundsAux(mc:DisplayObject,space:DisplayObject,topLevel:Boolean=false):Rectangle {
			if (mcChecked[mc]===true) return(null);
			else mcChecked[mc]=true;
			if (!mc.visible&&!topLevel) return(null);
			var bounds:Rectangle;
			if (mc is DisplayObjectContainer) {
				bounds=new Rectangle();
				var mcdo:DisplayObjectContainer=mc as DisplayObjectContainer;
				var childBounds:Rectangle;
				var mcChild:DisplayObject;
				for (var i=0;i<mcdo.numChildren;i++) {
					try {mcChild=mcdo.getChildAt(i);}
					catch (e:Error) {continue;}
					childBounds=getVisibleBoundsAux(mcChild,space);
					if (childBounds!=null) bounds=bounds.union(childBounds);
				}
			}
			else bounds=mc.getBounds(space);
			if (mc.mask!=null) {
				var maskBounds:Rectangle=getVisibleBoundsAux(mc.mask,space);
				if (maskBounds!=null) bounds=bounds.intersection(maskBounds)
			}
			return(bounds);
		}
	}	
}