//ColorAnalyzer class
//by Sam
//
//Initialize it with the color group members array
//
//getTransform(grpName,realCol) - pass it the group name and a hex value
//It will return the appropriate color transform object


package com.oddcast.vhost.color
{

	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;

	public class ColorAnalyzer {
		private var groupBaseColor:Object;
		
		public function ColorAnalyzer(members:Array) {
			//trace("Constructor ColorAnalyzer - "+members)
			analyze(members);
		}
		
		private function analyze(members:Array):void
		{
			//determines the most common color for each color section to use as a "base" color
			var bmp:BitmapData;
			var memb:MovieClip;
			var membPos:Object;
			var w,h,dx,dy:Number;
			
			var m:Matrix;
			var groupCount:Object=new Object();
			
			for (var i=0;i<members.length;i++) {
				if (!(members[i].getMC is Function))
				{
					continue;
				}				
				//bmp.dispose();				
				memb=members[i].getMC();
				
				
				membPos=memb.getRect(memb.parent);
				//membPos.xMax = membPos.x+membPos.w;
				//membPos.xMin = 
				w=membPos.width;//membPos.xMax-membPos.xMin;
				h=membPos.height;//membPos.yMax-membPos.yMin;
				dx=-membPos.x;
				dy=-membPos.y;				
				if (!(memb.getRect is Function) || !(w>0 && h>0)) {
					//trace("ColorAnalyzer --- PROBLEM WITH MODEL GETRECT=UNDEFINED")
					dx=memb.width;
					dy=memb.height;
					w=memb.width*2;
					h=memb.height*2;
				}
				
				//transforms mc to the 0,0 position for capturing the bitmap
				m=new Matrix(1,0,0,1,dx,dy);
				
				//trace("!ca -------------"+i+":"+memb.c_grp+"---"+memb+"--------------")
				//trace("!ca typeof :"+(typeof memb)+"  instanceof:"+(memb instanceof MovieClip));
				//trace("!ca membPos:"+membPos+"  xmin:"+membPos.xMin+"  "+(membPos==undefined))
				//trace("!ca "+memb.getBounds+"  ///  "+memb.getBounds(memb))
				//trace("!ca "+memb.getRect+"  ///  "+[memb._x,memb._y,memb._xscale,memb._yscale,memb._width,memb._height])
				//trace("!ca w,h:"+[w,h]+"  dx,dy:"+[dx,dy]+"  _w,_h:"+[memb._width,memb._height]+"  _x,_y:"+[memb._x,memb._y])
				//trace("trying to get bitmapData")
				try
				{
					bmp=new BitmapData(w,h);
				}
				catch(e:*)
				{
					dx=memb.width;
					dy=memb.height;
					w=memb.width*2;
					h=memb.height*2;
					//trace("in catch block w="+w+",h="+h+", dx="+dx+", dy="+dy );
					//some characters can't be read. I'm not sure why yet.
					//for now just set some numbers so it won't give an error 
					if (w==0 || h==0)
					{
						w = 100;
						h = 100;
						dx = 50;
						dy = 50; 
					}
					bmp=new BitmapData(w,h);
				}
				bmp.draw(memb,m)

				var colorCount:Object=getColorCount(bmp,w,h,memb);
				//for (var j in colorCount) trace(Number(j).toString(16)+":"+colorCount[j])			
			
				if (groupCount[memb.c_grp]==undefined) groupCount[memb.c_grp]=new Object();
				addColorCount(groupCount[memb.c_grp],colorCount)
			}

			groupBaseColor=new Object();
			for (var j in groupCount) {
				groupBaseColor[j]=Number(getMaxIndex(groupCount[j]));
				//trace("base:  "+i+" -- "+groupBaseColor[i].toString(16)+" in ColorAnalyzer");
			}
		}


		private function getColorCount(bmp:BitmapData, w:Number, h:Number, part:MovieClip = null):Object {
			//trace("getColorCount  "+[w,h,bmp])
			var res=20; //take 400 samples (20x20) to get color
			
			var dx=Math.ceil(w/res);
			var dy=Math.ceil(h/res);
			var weight:Number=dx*dy;
			var p:Number;
			var colCount:Object=new Object();
			for (var i=0;i<w;i+=dx) {
				for (var j=0;j<h;j+=dy) {
					p=bmp.getPixel(i,j);
					if (p!=0xFFFFFF && !(part.c_grp=="eyes" && p<=0x0e0e0e)) { //if (p!=0xFFFFFF) {
						/* if ((part.c_grp=="eyes" && p<=0x0e0e0e) )//|| (part.c_grp=="hairb" && p<=0x0e0e0e))
							continue; */
						if (colCount[p]==undefined) colCount[p]=weight
						else colCount[p]+=weight;
					}
				}
			}
			return(colCount)
		}
		
		private function addColorCount(total:Object,newCount:Object):void
		{
			for (var i in newCount) {
				if (total[i]==undefined) total[i]=newCount[i];
				else total[i]+=newCount[i];
			}
		}
		
		private function getMaxIndex(obj:Object):String {
			var max:Number=-1;
			var maxi:String="";
			for (var i in obj) {
				if (obj[i]>max) {
					max=obj[i];
					maxi=i;
				}
			}
			//if (maxi.length == 0) maxi= "0";
			return(maxi);
		}

		public function getTransform(grpName:String,realCol:uint):Object {
			var real=hexToRGB(realCol)	
			var base=hexToRGB(groupBaseColor[grpName])		
			var t={rb:real.r-base.r,gb:real.g-base.g,bb:real.b-base.b}		
			forceRange(t,-255,255);
			return(t);
		}
		
		public function getHexColor(grpName:String,trans:Object):uint {
		//trace("getHexColor in ANALYZER")
			var base=hexToRGB(groupBaseColor[grpName])		
			var real={r:trans.rb+base.r,g:trans.gb+base.g,b:trans.bb+base.b};
			//trace("base "+[base.r,base.g,base.b])
			//trace("trans "+[trans.rb,trans.gb,trans.bb])
			//trace("real "+[real.r,real.g,real.b])
			forceRange(real,0,255);
			//trace(rgbToHex(real).toString(16));
			return(rgbToHex(real));
		}
		
		private function hexToRGB(hex:Number):Object {
			var r=(hex&0xFF0000)>>16;
			var g=(hex&0x00FF00)>>8;
			var b=hex&0x0000FF;
			return({r:r,g:g,b:b})
		}
		
		private function rgbToHex(rgb:Object):Number {
			return((rgb.r<<16)+(rgb.g<<8)+rgb.b);
		}
		
		private function forceRange(rgb:Object,nmin:Number,nmax:Number):void
		{
			for (var i in rgb) {
				if (rgb[i]<nmin) rgb[i]=nmin;
				else if (rgb[i]>nmax) rgb[i]=nmax;
				else rgb[i]=Math.floor(rgb[i]);
			}
		}

	}
}
