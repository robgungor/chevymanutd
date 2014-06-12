package com.oddcast.graphics{
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import fl.motion.BezierSegment;
	
	public class CurveDrawer{								
		/*
			g:Graphics				- draw lines on this object		
			p:Array					- array of points (anchors)
			sizeMultiplier:Number	- bet 0-1 limits the distance from anchor point		 						 
			angleMultiplier:Number	- bet 0-1 adjust the curves angle 
			closeShaper:Boolean		- close the shape
		*/
		function CurveDrawer(){};			
		
		public function curveThroughPoints(g:Graphics, p:Array, sizeMultiplier:Number = .5, angleMultiplier:Number = .75, closeShape:Boolean = false):void
		{
				if (points.length < 3) return; //do nothing				
				if (closeShape)
				{
					p.push(p[0]);
				}
				var duplicates:Array = new Array();	// Array to hold indices of duplicate points
				// Check to make sure array contains only Points
				for (var i=0; i<p.length; i++){
					if (!(p[i] is Point)){
						throw new Error("Array must contain Point objects");
					}
					// Check for the same point twice in a row
					if (i > 0){
						if (p[i].x == p[i-1].x && p[i].y == p[i-1].y){
							duplicates.push(i);	// add index of duplicate to duplicates array
						}
					}
				}
				// Loop through duplicates array and remove points from the points array
				for (i=duplicates.length-1; i>=0; i--){
					p.splice(duplicates[i],1);
				}
				// Make sure sizeMultiplier is between 0 and 1 (too messy otherwise)
				if (sizeMultiplier <= 0){
					sizeMultiplier = .5;
				} else if (sizeMultiplier > 1){
					sizeMultiplier = 1;
				}
				// Make sure angleMultiplier is between 0 and 1
				if (angleMultiplier < 0){
					angleMultiplier = 0;
				} else if (angleMultiplier > 1){
					angleMultiplier = 1;
				}
				
				//
				// First calculate all the curve control points
				//
				
				// None of this junk will do any good if there are only two points
				if (p.length > 2){
					// Ordinarily, curve calculations will start with the second point and go through the second-to-last point
					var firstPt = 1;
					var lastPt = p.length-1;
					// Check if this is a closed line (the first and last points are the same)
					if (p[0].x == p[p.length-1].x && p[0].y == p[p.length-1].y){
						// Include first and last points in curve calculations
						firstPt = 0;
						lastPt = p.length;
					}
					
					var controlPts:Array = new Array();	// An array to store the two control points (of a cubic Bézier curve) for each point
					
					// Loop through all the points (except the first and last if not a closed line) to get curve control points for each.
					for (i=firstPt; i<lastPt; i++) {
						
						// The previous, current, and next points
						var p0 = (i-1 < 0) ? p[p.length-2] : p[i-1];	// If the first point (of a closed line), use the second-to-last point as the previous point
						var p1 = p[i];
						var p2 = (i+1 == p.length) ? p[1] : p[i+1];		// If the last point (of a closed line), use the second point as the next point
						var a = Point.distance(p0,p1);	// Distance from previous point to current point
						if (a < 0.001) a = .001;		// Correct for near-zero distances, which screw up the angles or something
						var b = Point.distance(p1,p2);	// Distance from current point to next point
						if (b < 0.001) b = .001;
						var c = Point.distance(p0,p2);	// Distance from previous point to next point
						if (c < 0.001) c = .001;
						var C = Math.acos((b*b+a*a-c*c)/(2*b*a));	// Angle formed by the two sides of the triangle (described by the three points above) adjacent to the current point
						// Duplicate set of points. Start by giving previous and next points values RELATIVE to the current point.
						var aPt = new Point(p0.x-p1.x,p0.y-p1.y);
						var bPt = new Point(p1.x,p1.y);
						var cPt = new Point(p2.x-p1.x,p2.y-p1.y);
						/*
						We'll be adding adding the vectors from the previous and next points to the current point,
						but we don't want differing magnitudes (i.e. line segment lengths) to affect the direction
						of the new vector. Therefore we make sure the segments we use, based on the duplicate points
						created above, are of equal length. The angle of the new vector will thus bisect angle C
						(defined above) and the perpendicular to this is nice for the line tangent to the curve.
						The curve control points will be along that tangent line.
						*/
						if (a > b){
							aPt.normalize(b);	// Scale the segment to aPt (bPt to aPt) to the size of b (bPt to cPt) if b is shorter.
						} else if (b > a){
							cPt.normalize(a);	// Scale the segment to cPt (bPt to cPt) to the size of a (aPt to bPt) if a is shorter.
						}
						// Offset aPt and cPt by the current point to get them back to their absolute position.
						aPt.offset(p1.x,p1.y);
						cPt.offset(p1.x,p1.y);
						// Get the sum of the two vectors, which is perpendicular to the line along which our curve control points will lie.
						var ax = bPt.x-aPt.x;	// x component of the segment from previous to current point
						var ay = bPt.y-aPt.y; 
						var bx = bPt.x-cPt.x;	// x component of the segment from next to current point
						var by = bPt.y-cPt.y;
						var rx = ax + bx;	// sum of x components
						var ry = ay + by;
						var r = Math.sqrt(rx*rx+ry*ry);	// length of the summed vector - not being used, but there it is anyway
						var theta = Math.atan(ry/rx);	// angle of the new vector
						
						var controlDist = Math.min(a,b)*sizeMultiplier;	// Distance of curve control points from current point: a fraction the length of the shorter adjacent triangle side
						var controlScaleFactor = C/Math.PI;	// Scale the distance based on the acuteness of the angle. Prevents big loops around long, sharp-angled triangles.
						controlDist *= ((1-angleMultiplier) + angleMultiplier*controlScaleFactor);	// Mess with this for some fine-tuning
						var controlAngle = theta+Math.PI/2;	// The angle from the current point to control points: the new vector angle plus 90 degrees (tangent to the curve).
						var controlPoint2 = Point.polar(controlDist,controlAngle);	// Control point 2, curving to the next point.
						var controlPoint1 = Point.polar(controlDist,controlAngle+Math.PI);	// Control point 1, curving from the previous point (180 degrees away from control point 2).
						// Offset control points to put them in the correct absolute position
						controlPoint1.offset(p1.x,p1.y);
						controlPoint2.offset(p1.x,p1.y);
						/*
						Haven't quite worked out how this happens, but some control points will be reversed.
						In this case controlPoint2 will be farther from the next point than controlPoint1 is.
						Check for that and switch them if it's true.
						*/
						if (Point.distance(controlPoint2,p2) > Point.distance(controlPoint1,p2)){
							controlPts[i] = new Array(controlPoint2,controlPoint1);	// Add the two control points to the array in reverse order
						} else {
							controlPts[i] = new Array(controlPoint1,controlPoint2);	// Otherwise add the two control points to the array in normal order
						}
						// Uncomment to draw lines showing where the control points are.
						/*
						g.moveTo(p1.x,p1.y);
						g.lineTo(controlPoint2.x,controlPoint2.y);
						g.moveTo(p1.x,p1.y);
						g.lineTo(controlPoint1.x,controlPoint1.y);
						*/						
					}
					
					//
					// Now draw the curve
					//
					g.moveTo(p[0].x, p[0].y);
					// If this isn't a closed line
					if (firstPt == 1){
						// Draw a regular quadratic Bézier curve from the first to second points, using the first control point of the second point
						g.curveTo(controlPts[1][0].x,controlPts[1][0].y,p[1].x,p[1].y);
					}
					// Loop through points to draw cubic Bézier curves through the penultimate point, or through the last point if the line is closed.
					for (i=firstPt;i<lastPt-1;i++){
						// BezierSegment instance using the current point, its second control point, the next point's first control point, and the next point
						var bezier:BezierSegment = new BezierSegment(p[i],controlPts[i][1],controlPts[i+1][0],p[i+1]);
						// Construct the curve out of 100 segments (adjust number for less/more detail)
						for (var t=.01;t<1.01;t+=.01){
							var val = bezier.getValue(t);	// x,y on the curve for a given t
							g.lineTo(val.x,val.y);
						}
					}
					// If this isn't a closed line
					if (lastPt == p.length-1){
						// Curve to the last point using the second control point of the penultimate point.
						g.curveTo(controlPts[i][1].x,controlPts[i][1].y,p[i+1].x,p[i+1].y);
					}					
				// just draw a line if only two points
				} else if (p.length == 2){	
					g.moveTo(p[0].x,p[0].y);
					g.lineTo(p[1].x,p[1].y);
				}			
		}
		
	}
	
}
