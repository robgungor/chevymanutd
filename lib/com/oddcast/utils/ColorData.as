/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* Holds a Color
* can express data as hex, RGB, or HSV
* 
* Properties:
* hex - 0xRRGGBB hex value
* r -  	int from 0-255
* g - 	int from 0-255
* b - 	int from 0-255
* hue - range 0-1 where 0=red 0.33=green 0.67=blue and 1=red again
* sat - range 0-1 where 0=greyscale and 1=fully saturated
* bright - range 0-1 where 0=black and 1=undarkened colour (not necessarily white)
* 
* Methods:
* getRGB - returns array [r,g,b] where r,g,b are in the range 0-1
* setRGB(array) - sets rgb from array [r,g,b] where r,g,b are in the range 0-1
* clone() - returns a ColorData object representing this colour
* getHSB() - returns an object in form {hue:0.2,sat:0.6,bright:0.8}
* setHSBObj(obj) - sets colour from an object
* setHSB(hue,sat,bright) - sets HSB values
*/

package com.oddcast.utils {
	import flash.geom.ColorTransform;

	public class ColorData {
		private var _rgb:Array; //store in range 0-1
		
		public function ColorData(in_hex:uint=0x000000) {
			_rgb=new Array(3);
			hex=in_hex;
		}
				
		public function getRGB():Array { //range is 0-1
			return(_rgb);
		}

		public function setRGB(rgb:Array) : void {
			_rgb=rgb;
		}
		
		public function getTransform():ColorTransform {
			return(new ColorTransform(0,0,0,1,r,g,b,0));
		}

		public function get hex():uint {		
			var _hex:uint=(r<<16)+(g<<8)+b;
			return(_hex);
		}
		
		public function set hex(_hex:uint) : void {
			r=(_hex&0xFF0000)>>16;
			g=(_hex&0x00FF00)>>8;
			b=_hex&0x0000FF;
		}
		
		public function get r():uint { //range is 0-255 int
			return(range256(_rgb[0]));
		}
		
		public function set r(n:uint) : void {
			_rgb[0]=n/255;
		}

		public function get g():uint { //range is 0-255 int
			return(range256(_rgb[1]));
		}
		
		public function set g(n:uint) : void {
			_rgb[1]=n/255;
		}

		public function get b():uint { //range is 0-255 int
			return(range256(_rgb[2]));
		}
		
		public function set b(n:uint) : void {
			_rgb[2]=n/255;
		}
		
		public function get hue():Number { //range is 0-1
			return(getHSBArr()[0]);
		}
		
		public function set hue(n:Number) : void {
			if (n<0||n>1) throw new RangeError("hue out of range")
			var hsb:Array=getHSBArr();
			hsb[0]=n;
			setHSBArr(hsb);
		}

		public function get sat():Number { //range is 0-1
			return (getHSBArr()[1]);
		}
		
		public function set sat(n:Number) : void {
			if (n<0||n>1) throw new RangeError("saturation out of range")
			var hsb:Array=getHSBArr();
			hsb[1]=n;
			setHSBArr(hsb);
		}

		public function get bright():Number { //range is 0-1
			return (getHSBArr()[2]);
		}
		
		public function set bright(n:Number) : void {
			if (n<0||n>1) throw new RangeError("brightness out of range")
			var hsb:Array=getHSBArr();
			hsb[2]=n;
			setHSBArr(hsb);
		}
		
		public function clone():ColorData {
			var c:ColorData=new ColorData();
			c.setRGB(getRGB());
			return(c);
		}
		
		private function range256(n:Number):uint { //takes value from 0-1 and converts to 0-255
			if (n<0) return(0);
			else if (n>=1) return(255);
			else return(Math.floor(n*256));
		}
						
/*		public function getHSB():Object { //range is 0-1
			
			var ordered:Array=_rgb.concat().sort(Array.NUMERIC|Array.DESCENDING); //concat clones the array
			if (ordered[0]==ordered[2]) { //if all values are same  ie. color is greyscale
				return({hue:0, sat:0, bright:ordered[0]})
			}
			
			var hsb:Object=new Object();
			
			hsb.sat=1-ordered[2]/ordered[0]; //1-min/max
			hsb.bright=ordered[0]; //maximum value
			
			var colName:Array=["r","g","b"];
			var colOrder:Array=_rgb.sort(Array.NUMERIC|Array.DESCENDING|Array.RETURNINDEXEDARRAY);
			var cols:String=colName[colOrder[0]]+colName[colOrder[1]];
			//cols is top two colors in order eg if r=0.8 g=0.2 b=0.9 then cols="br"
			
			var hueF:Number=(ordered[1]-ordered[2])/(ordered[0]-ordered[2]);
			if (cols=="rg") hsb.hue=hueF;
			else if (cols=="gr") hsb.hue=2-hueF;
			else if (cols=="gb") hsb.hue=2+hueF;
			else if (cols=="bg") hsb.hue=4-hueF;
			else if (cols=="br") hsb.hue=4+hueF;
			else if (cols=="rb") hsb.hue=6-hueF;
			hsb.hue/=6;
			
			return(hsb);
		}*/
		
		public function getHSBArr():Array { 
			//this is a better, faster implementation of getHSB, but harder to understand
			var i1:int;
			var i2:int;
			var i3:int;
			var c1:Number;
			var c2:Number;
			var c3:Number;
			if (_rgb[0]>=_rgb[1]&&_rgb[0]>=_rgb[2]) {
				i1=0;
				if (_rgb[1]>=_rgb[2]) {
					i2=1;
					i3=2;
				}
				else {
					i2=2;
					i3=1;
				}
			}
			else if (_rgb[1]>=_rgb[2]) {
				i1=1;
				if (_rgb[0]>=_rgb[2]) {
					i2=0;
					i3=2;
				}
				else {
					i2=2;
					i3=0;
				}
			}
			else {
				i1=2;
				if (_rgb[0]>=_rgb[1]) {
					i2=0;
					i3=1;
				}
				else {
					i2=1;
					i3=0;
				}
			}
			c1=_rgb[i1];
			c2=_rgb[i2];
			c3=_rgb[i3];
			
			if (c1==c3) { //if all values are same  ie. color is greyscale
				return([0,0,c1])
			}
			
			var hsb:Array=new Array(3);
			hsb[1]=1-c3/c1; //1-min/max
			hsb[2]=c1; //maximum value
			
			var colOrd:int=i1*10+i2;
			//colOrg is top two colors in order eg if r=0.8 g=0.2 b=0.9 then cols=20 ("br")
			
			var hueF:Number=(c2-c3)/(c1-c3);
			if (colOrd==1) hsb[0]=hueF;
			else if (colOrd==10) hsb[0]=2-hueF;
			else if (colOrd==12) hsb[0]=2+hueF;
			else if (colOrd==21) hsb[0]=4-hueF;
			else if (colOrd==20) hsb[0]=4+hueF;
			else if (colOrd==2) hsb[0]=6-hueF;
			hsb[0]/=6;
			
			return(hsb);
		}
		
		public function setHSBArr(hsb:Array) : void {
			setHSB(hsb[0],hsb[1],hsb[2]);
		}
		
		/*public function setHSBObj(hsb:Object) {
			setHSB(hsb.hue,hsb.sat,hsb.bright);
		}*/
		
		public function setHSB(_hue:Number,_sat:Number,_bright:Number) : void { //range is 0-1
			//calculate base color of hue at full saturation and brightness
			//as hue increases from 0 to 1: this has following values:
			//0=red 1/6=yellow 2/6=green 3/6=cyan 4/6=blue 5/6=magenta 1=red
			var hueW:int=Math.floor(_hue*6); //whole number of sixths
			var hueF:Number=_hue*6-hueW;		//fraction part of hue*6
			hueW%=6;
			var valR:Array=[1,1-hueF,0,0,hueF,1];
			
			var rgbArr:Array=new Array();
			var c:Number;
			for (var i:int=0;i<3;i++) {
				c=valR[(hueW+6-2*i)%6];
				c=c*(_sat)+(1-_sat);  //add saturation
				c*=_bright;  //add brightness
				rgbArr[i]=c;
			}			
			_rgb=rgbArr;
		}
		
	}
	
}