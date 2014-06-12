package com.oddcast.graphics{
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;	
	
	public class CurveDrawerWithAnchors implements ICurveDrawer{								
		
			
		private var points:Array;
		private var sprt:Sprite;
		private var sprtOutline:Sprite;
		private var _bBottomLineFlat:Boolean;
		private var _lastPointsArr:Array;
			
		function  CurveDrawerWithAnchors()
		{
			
		}
		
		public function setSprite(s:Sprite):void
		{
			sprt = s;
		}
		public function setOutlineSprite(s:Sprite):void
		{
			sprtOutline = s;
		}
		
		public function getPointsArr():Array
		{
			return points;
		}
		
		public function setPoints(arr:Array):void
		{
			points = arr.slice();
			//trace out points
			/*
			for (var i:int=0; i<points.length;++i)
			{
				trace("CurveDrawer:: "+i+" x="+points[i].x+","+points[i].y);
			}
			*/
		}
		
		public function setBottomLineFlat(b:Boolean):void
		{
			_bBottomLineFlat = b;
		}
		
		public function addPoint(p:Point):void
		{
			if (points == null)
			{
				points = new Array();
			}
			points.push(p);
		}
		
		public function drawCurvedShape(closeShape:Boolean = false, curveDetails:int = 100, sizeMultiplier:Number = .5, angleMultiplier:Number = .75):void
		{			
			if (points.length < 3) return; //do nothing
			
			var g:Graphics = sprt.graphics;	
			var gOutline:Graphics;
			if (sprtOutline!=null)
			{
				gOutline = sprtOutline.graphics;
			}
			
			var anchorPoint:Point;
			var nextPoint:Point;
			var controlPoint:Point;
			var middlePoint:Point;
			var xOffset:Number;
			var yOffset:Number;	
			//split to control and anchor points
			var anchorPoints:Array = new Array();
			var controlPoints:Array = new Array();
			for (var i:int=5; i<points.length;++i)
			{
				if (i%2==0)
				{
					controlPoints.push(points[i]);
				}	
				else
				{
					anchorPoints.push(points[i]);
				}
			}
			for (i = 0; i<5;++i)
			{
				if (i%2==0)
				{
					controlPoints.push(points[i]);
				}	
				else
				{
					anchorPoints.push(points[i]);
				}
			}
			//controlPoints.push(points[0]);
			//controlPoints.push(points[0]);
			
			g.moveTo(anchorPoints[0].x, anchorPoints[0].y);
			if (gOutline!=null)
			{
				gOutline.moveTo(anchorPoints[0].x, anchorPoints[0].y);
			}
			
			var pointsNum:int = anchorPoints.length;
			var substractPoint:Point;
			for (i=1; i<pointsNum; ++i)
			{
				anchorPoint = anchorPoints[i-1];
				nextPoint = anchorPoints[i];
				controlPoint = controlPoints[i-1];	
				/*
				var tf1:TextField = new TextField();
				tf1.text = String(i)+"a";
				tf1.x = anchorPoint.x;
				tf1.y = anchorPoint.y;
				
				var tf2:TextField = new TextField();
				tf2.text = String(i);
				tf2.x = controlPoint.x;
				tf2.y = controlPoint.y;
				
				sprt.addChild(tf1);
				sprt.addChild(tf2);
				*/
				//trace("anchor="+anchorPoint+", control="+controlPoint);		
				middlePoint = Point.interpolate(anchorPoint,nextPoint, 0.5);
				substractPoint = controlPoint.subtract(middlePoint);
				xOffset = substractPoint.x;
				yOffset = substractPoint.y;
				g.curveTo(controlPoint.x+xOffset, controlPoint.y+yOffset, nextPoint.x, nextPoint.y);
				if (gOutline!=null)
				{
					gOutline.curveTo(controlPoint.x+xOffset, controlPoint.y+yOffset, nextPoint.x, nextPoint.y);
				}
			}
			anchorPoint = anchorPoints[pointsNum-1];
			nextPoint = anchorPoints[0];
			controlPoint = controlPoints[pointsNum-1];
			//trace("--anchor="+anchorPoint+", control="+controlPoint);
			middlePoint = Point.interpolate(anchorPoint,nextPoint, 0.5);
			//trace("middlePoint="+middlePoint);
			substractPoint = controlPoint.subtract(middlePoint);
			//trace("substractPoint="+substractPoint);
			xOffset = substractPoint.x;
			yOffset = substractPoint.y;
			//trace("xOffset="+xOffset+", yOffset="+yOffset);
						
			//trace((controlPoint.x+xOffset)+","+(controlPoint.y+yOffset)+","+nextPoint.x+","+nextPoint.y);
			g.curveTo((controlPoint.x+xOffset), (controlPoint.y+yOffset), nextPoint.x, nextPoint.y);
			if (gOutline!=null)
			{
				gOutline.curveTo(controlPoint.x+xOffset, controlPoint.y+yOffset, nextPoint.x, nextPoint.y);
			}
					
		}
				
		
		/*		
		sizeMultiplier:Number	- bet 0-1 limits the distance from anchor point		 						 
		angleMultiplier:Number	- bet 0-1 adjust the curves angle 
		closeShaper:Boolean		- close the shape
		*/
		/*
		public function drawCurvedShape(closeShape:Boolean = false, curveDetails:int = 100, sizeMultiplier:Number = .5, angleMultiplier:Number = .75):void
		{
								
				if (points.length < 3) return; //do nothing				
				if (closeShape && points[0]!=points[points.length-1])
				{
					points.push(points[0]);
				}								
				// Calculating ctrl points
				var firstPoint:int;
				var lastPoint:int;
				
				if (closeShape)
				{
					firstPoint = 0;
					lastPoint = points.length;
				}
				else
				{
					firstPoint = 1;
					lastPoint = points.length - 1;
				}
							
				var ctrlPoints:Array = new Array();	// two ctrl points for each point								
				for (var i:int=firstPoint; i<lastPoint; i++) {										
					var p0:Point = (i-1 < 0) ? points[points.length-2] : points[i-1]; //the first point of a close shape	
					var p1:Point = points[i];
					var p2:Point = (i+1 == points.length) ? points[1] : points[i+1];
					var a:Number = Point.distance(p0, p1);
					a = a < 0.001 ? 0.001 : a;
					var b:Number = Point.distance(p1,p2);
					b = b < 0.001 ? 0.001 : b;
					var c:Number = Point.distance(p0,p2);
					c = c < 0.001 ? 0.001 : c;
					var Cu:Number = Math.acos(.5*((b*b+a*a-c*c)/(b*a)));
						
					var aPoint:Point = new Point(p0.x-p1.x,p0.y-p1.y);
					var bPoint:Point = new Point(p1.x,p1.y);
					var cPoint:Point = new Point(p2.x-p1.x,p2.y-p1.y);					
					if (a > b){
						aPoint.normalize(b);
					} else if (b > a){
						cPoint.normalize(a);	
					}					
					aPoint.offset(p1.x,p1.y);
					cPoint.offset(p1.x,p1.y);
					// add the two vectors
					var ax:Number = bPoint.x-aPoint.x;	
					var ay:Number = bPoint.y-aPoint.y; 
					var bx:Number = bPoint.x-cPoint.x;	
					var by:Number = bPoint.y-cPoint.y;
					var rx:Number = ax + bx;
					var ry:Number = ay + by;					
					var theta:Number = Math.atan(ry/rx);
					
					//trace(i+" ax,ay,bx,by,theta, Cu"+ax+","+ay+","+bx+","+by+","+theta+","+Cu);
					var ctrlDist = Math.min(a,b)*sizeMultiplier;	// the distance of control points from current point
					var ctrlScaleFactor = Cu/Math.PI;	// scale the distance based on the angle
					ctrlDist *= ((1-angleMultiplier) + angleMultiplier*ctrlScaleFactor);	// use the angleMultiplier for adjusting the curves
					var ctrlAngle = Math.PI/2 + theta;	// angle from the current point to the control points
					var ctrlPoint1 = Point.polar(ctrlDist,ctrlAngle+Math.PI);	// curving from the previous point
					var ctrlPoint2 = Point.polar(ctrlDist,ctrlAngle);	// curving to the next point.
					//trace(i+" after polar ctrlPoint1="+ctrlPoint1.toString()+"ctrlPoint2="+ctrlPoint2.toString())
					ctrlPoint1.offset(p1.x,p1.y);
					ctrlPoint2.offset(p1.x,p1.y);
					//trace(i+" after offset ctrlPoint1="+ctrlPoint1.toString()+"ctrlPoint2="+ctrlPoint2.toString())
					//trace()
					//switch order of points depending on the distance from the point					
					if (Point.distance(ctrlPoint2,p2) > Point.distance(ctrlPoint1,p2)){
						ctrlPoints[i] = new Array(ctrlPoint2,ctrlPoint1);
					} else {
						ctrlPoints[i] = new Array(ctrlPoint1,ctrlPoint2);
					}					
				}
				var g:Graphics = sprt.graphics;	
				var gOutline:Graphics;
				if (sprtOutline!=null)
				{
					gOutline = sprtOutline.graphics;
				}
				g.moveTo(points[0].x, points[0].y);
				if (gOutline!=null)
				{
					gOutline.moveTo(points[0].x, points[0].y);
				}
				//trace("CurveDrawer:: moveTo "+points[0].x+","+points[0].y);				
				if (!closeShape){					
					g.curveTo(ctrlPoints[1][0].x,ctrlPoints[1][0].y,points[1].x,points[1].y);
					if (gOutline!=null)
					{
						gOutline.curveTo(ctrlPoints[1][0].x,ctrlPoints[1][0].y,points[1].x,points[1].y);
					}
					//trace("CurveDrawer:: !closeShape CurveTo "+ctrlPoints[1][0].x+","+ctrlPoints[1][0].y+","+points[1].x+","+points[1].y);
				}				
				for (i=firstPoint;i<lastPoint-1;i++){
					// BezierSegment instance using the current point, its second control point, the next point's first control point, and the next point
					//new BeizerSegment (x=52.89, y=0) | (x=73.46292328287946, y=-0.7618254639392263) | (x=184.49, y=0)
					//trace("new BeizerSegment "+points[i].toString()+" | "+ctrlPoints[i][1].toString()+" | "+ctrlPoints[i + 1][0]+" | "+points[i + 1]);
					if (isNaN(ctrlPoints[i][1].x) || isNaN(ctrlPoints[i][1].y) || isNaN(ctrlPoints[i + 1][0].x) || isNaN(ctrlPoints[i + 1][0].y) || (_bBottomLineFlat && points[i + 1].y==points[i].y))
					{
						//trace("NaN encountered just draw a straight line");
						g.lineTo(points[i + 1].x,points[i + 1].y);
						if (gOutline!=null)
						{
							gOutline.lineTo(points[i + 1].x,points[i + 1].y);
						}
					}
					else
					{
						//trace("CurveDrawer::i="+i+" -> "+points[i].x+","+points[i].y);
						var bezier:BezierSegment = new BezierSegment(points[i], ctrlPoints[i][1], ctrlPoints[i + 1][0], points[i + 1]);
						var curveSegStart:Number = 0.01;
						var curveSegEnd:Number = 1.01;
						var curveSegInc:Number = 1 / curveDetails;
						// Construct the curve out of 100 segments (adjust number for less/more detail)
						for (var t=.01;t<1.01;t+=.01){
							var val = bezier.getValue(t);	// x,y on the curve for a given t
							g.lineTo(val.x,val.y);
							if (gOutline!=null)
							{
								gOutline.lineTo(val.x,val.y);
							}
							//trace("CurveDrawer:: lineTo "+i+"("+t+")"+val.x+","+val.y);
						}
					}
				}
				// If this isn't a closed line
				if (lastPoint == points.length-1){
					//trace("last point _bBottomLineFlat="+_bBottomLineFlat);
					// Curve to the last point using the second control point of the penultimate point.
					
						g.curveTo(ctrlPoints[i][1].x,ctrlPoints[i][1].y,points[i+1].x,points[i+1].y);
					
					if (gOutline!=null)
					{
						
						gOutline.curveTo(ctrlPoints[i][1].x,ctrlPoints[i][1].y,points[i+1].x,points[i+1].y);
						
					}
				}									
		}
		*/
		
	}
	
}
