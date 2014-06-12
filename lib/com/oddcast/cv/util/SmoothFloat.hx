

	/**
	 * ...
	 * @author Jake Lewis
	 *  4/9/2010 4:16 PM
	 */
	package  com.oddcast.cv.util;
	//import com.oddcast.cv.util.SmoothFloat;
	
	
	import com.oddcast.host.engine3d.math.Float3D;
	import flash.geom.Point;
	import com.oddcast.util.VectorTools; using com.oddcast.util.VectorTools;
	
	
	
	class SmoothFloat
	{
		public function new(    nSamples:Int = 6, 
								v:Float = 0.0
							) {
			smooth = v;
			this.nSamples = nSamples;
			data = new ContArray();
			dataIndex = 0;
		}
		
		public function update(v:Float):Float{
			data[dataIndex++] = v;
			
			if(dataIndex == nSamples)
				dataIndex = 0;
			smooth = 0.0;
			
			for ( d in data ) {
				//if (d != null) 
				{
					smooth += d;
				}
			}
			smooth /= data.length;
			return smooth;
		}
		
		public function float():Float { return smooth; }
		
		
		public function toString():String {
			var ret = "smooth:"+com.oddcast.util.Utils.formatFloat(smooth)+" index:" + dataIndex;
			for ( d in data ) {
				//if (d != null) 
				{
					ret += "  " + com.oddcast.util.Utils.formatFloat(d);
				}
			}
			return ret;
		}
		
		private var nSamples		:Int;
		private var dataIndex		:Int;
		private var data			:ContArray<Float>;
		private var smooth			:Float;
	}
	
	
	
	typedef SmoothingValue  = UInt;
	class SmoothFloat3D{
		public function new (smoothingValue:SmoothingValue) {
			//nMaxSize >>= 1; //MUSTDO
			setSmoothingValue(smoothingValue);
		}
		
		public function setSmoothingValue(smoothingValue:SmoothingValue) {
			data = new ContArray(
									#if flash10
									smoothingValue, true
									#end
								);
			for (i in 0...smoothingValue) {
				data[i] = new Float3D();
			}
			reset();
		}
		
		public function getSmoothingValue():SmoothingValue { return data.length; }
		
		public function reset() {
			iIdealSize = data.length;
			mean 		= new Float3D();
			direction 	= new Float3D();
			stanDev 	= 1.0;
			iDataIndex  = 0;
			iCurrSize	= 0;
			
			lastIdealSizeDEBUG = -1;
			lastCurrSizeDEBUG = -1;
		//	trace(" reset()");
		}
		
		public function updatePoint(point:Point, bDebug:Bool = false):Point {
			update(point.x, point.y, 0.0, bDebug);
			return pointXY();
		}
		
		public function updateFloat3D(f3d:Float3D, bDebug:Bool=false):Float3D {
			return update(f3d.x, f3d.y, f3d.z, bDebug);
		}
		
		function changeBy():Float {
			return Math.max(1.0, data.length / 5);
		}
		
		public function update(x:Float, y:Float, z:Float, bDebug:Bool=false):Float3D {
			data[iDataIndex].assign(x,y,z);
			
				
			//vector to last average
			var vectorFromMean = Float3D.sub(data[iDataIndex],  mean);
			var distFromMean = vectorFromMean.length();
			var deviance = distFromMean / stanDev;
			vectorFromMean.normalize();
			
			
			if (deviance > 2.0  && Float3D.dot(vectorFromMean, direction) > 0.80) {
				var reduceBy = Std.int(Math.min(Math.max(1, deviance * changeBy()), iIdealSize-1));
				iIdealSize -= reduceBy;
				if(bDebug)	trace(  iIdealSize + " " + reduceBy);
			}else {
				var datalength :Int = data.length;
				if(iIdealSize<datalength){
					iIdealSize++;
					if(bDebug) trace(iIdealSize );
				}
			}
			
			
			if (lastIdealSizeDEBUG != iIdealSize && bDEBUG){
				//trace(" iIdealSize:" + iIdealSize);
				lastIdealSizeDEBUG = iIdealSize;
			}
	
			direction.copyFrom(vectorFromMean);
			if (iCurrSize < iIdealSize)
				iCurrSize++;
			if (iCurrSize > iIdealSize)
				iCurrSize = iIdealSize;
				
			if (lastCurrSizeDEBUG != iCurrSize && bDEBUG){
			//	trace("                                  iCurrSize:"+iCurrSize);
				lastCurrSizeDEBUG = iCurrSize;
			}	
				
			//make new mean
			mean.assign(0, 0, 0);
			var i = iDataIndex;
			var c = 0;
			while (c < iCurrSize) {
				mean.addFloat3D( data[i]);
				 
				if (--i < 0)
					i = data.length - 1;
				c++;
			}
			mean.scaleConstant(1.0 / c);
			
			// standard deviation
			stanDev = 0.0;
			var i = iDataIndex;
			var c = 0;
			while (c < iCurrSize) {
				
				stanDev += mean.distSqr(data[i]);
				if (--i < 0)
					i = data.length - 1;
				c++;
			}
			stanDev = Math.max(1.0, Math.sqrt(stanDev / c ));  //dont want div by zeros
			
			
			var dataLength:Int = data.length;	
			if (++iDataIndex == dataLength)
				iDataIndex = 0;
				
			return float3D();	
		}
		
		public function float3D():Float3D { return mean; }
		
		public function pointXY():Point { return new Point(mean.x, mean.y); }
		
		public function z():Float { return mean.z; }
		
		
		
		private var data 			:ContArray<Float3D>;
		private var iCurrSize		:Int;
		private var iIdealSize		:Int;
		private var iDataIndex		:Int;
		private var mean			:Float3D;
		
		private var direction		:Float3D;
		private var stanDev			:Float;
		
		private var lastIdealSizeDEBUG	:Int;
		private var lastCurrSizeDEBUG	:Int;
		public  var bDEBUG				:Bool;
	}

	
