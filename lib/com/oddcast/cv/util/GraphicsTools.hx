

	/**
	 * ...
	 * @author Jake Lewis
	 *  4/8/2010 3:30 PM
	 */
	package  com.oddcast.cv.util;
	//import com.oddcast.cv.util.GraphicsTools;					 using com.oddcast.cv.util.GraphicsTools;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;	
	import flash.display.Graphics;
	
	
	class GraphicsTools 
	{
		static public function line(graphics:Graphics, fromX:Float, fromY:Float, toX:Float, toY:Float) {
			graphics.moveTo(fromX, fromY);
			graphics.lineTo(toX, toY);
		}
		
		static public function lineBetweenPoints(graphics:Graphics, from:Point,  to:Point) {
			line(graphics, from.x, from.y, to.x, to.y);
		}
		
		/*static public function lineToPoint(graphics:Graphics, fromX:Float, fromY:Float,  to:Point) {
			line(graphics, fromX, fromY, to.x, to.y);
		}*/
		
		static public function drawRectangle(graphics:Graphics, rect:Rectangle){
			graphics.drawRect(rect.x , rect.y 	 , rect.width, rect.height);
		}
		
		static public function drawEllipsePoint(graphics:Graphics, center:Point, width:Float, height:Float){
			graphics.drawEllipse(center.x - width / 2, center.y - height / 2 , width, height);
		}
		
		static public function drawEllipseRectangle(graphics:Graphics, rect:Rectangle){
			graphics.drawEllipse(rect.x , rect.y 	 , rect.width, rect.height);
		}
		
		static public function drawRectanglePoint(graphics:Graphics, center:Point, width:Float, height:Float){
			graphics.drawRect(center.x - width / 2, center.y - height / 2 , width, height);
		}
		
		static public function moveToPoint(graphics:Graphics, point:Point) {
			graphics.moveTo(point.x, point.y);
		}
		
		static public function curveToPoint(graphics:Graphics, control:Point, point:Point) {
			graphics.curveTo(control.x, control.y, point.x, point.y);
		}
		
		static public function lineToPoint(graphics:Graphics, point:Point) {
			graphics.lineTo(point.x, point.y);
		}
		
	}

