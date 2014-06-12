/**
* ...
* @author Sam
* @version 0.1
* 
* This class allows you to have customized cursor art.  The art should be a movieclip with 2 frames. The first frame
* has the graphics when the mouse is up.  The second is for when the mouse is down
* 
* setStage - must be called on initialization
* setCursorClass(linkageName) - switches to the cursor with that linkage name
* [optional]setCursor(mc) - switches cursor to the movieclip mc
* removeCursor() - reverts back to the default cursor
* 
* Example:
* 1.Create a movieclip in the library called oc_cursor_hand and give it a linkage class name oc_cursor_hand
* In the first frame, put an image of an open hand.  In the second, put a closed hand.
* 
* 2.Somewhere in your code when the application starts up, call:
* CustomCursor.setStage(stage);
* 
* 3. Say you want to have the hand cursor over when you mouse over a box:
* function onMouseOverBox() {
*    CustomCursor.setCursorClass("oc_cursor_hand")
* }
* 
* function onMouseOutBox() {
*    CustomCursor.removeCursor()
* }
* 
*/

package com.oddcast.utils {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.utils.getDefinitionByName;

	public class CustomCursor {
		private static var stage:Stage
		private static var cursor:DisplayObject;
		
		public static function setStage($stage:Stage) {
			if (stage == $stage) return;
			try {
				if (stage!=null) {
					stage.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
					stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUp);				
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
				}
				stage=$stage;
				stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
				stage.addEventListener(MouseEvent.MOUSE_UP,mouseUp);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			}
			catch (err:SecurityError) {
				trace("Stage does not have required permissions to implement com.oddcst.utils.CustomCursor");
			}
		}
		
		public static function setCursor($cursor:DisplayObject) {
			if ($cursor==null) {
				removeCursor();
				return;
			}
			cursor=$cursor;
			if (cursor is Sprite) {
				(cursor as Sprite).mouseEnabled=false;
				(cursor as Sprite).mouseChildren=false;
				(cursor as Sprite).buttonMode=false;
			}
			//if (cursor.stage!=null) setStage(cursor.stage);
			showCursor();
		}
		
		public static function setCursorClass(cursorClassName:String) {
			if (stage==null) return;
			if (cursorClassName==null||cursorClassName=="") {
				removeCursor();
				return;
			}
			
			var cursorClass:Class=getDefinitionByName(cursorClassName) as Class;
			if (!(cursor is cursorClass))	cursor=new cursorClass();
			if (!(cursor is DisplayObject)) {
				throw new Error("Cursor must be a subclass of MovieClip");
				return;
			}
			if (cursor is Sprite) {
				(cursor as Sprite).mouseEnabled=false;
				(cursor as Sprite).mouseChildren=false;
				(cursor as Sprite).buttonMode=false;
			}
			showCursor();
		}
		
		private static function showCursor() {
			cursor.x=stage.mouseX;
			cursor.y=stage.mouseY;
			stage.addChildAt(cursor,stage.numChildren);
			if (cursor is MovieClip) (cursor as MovieClip).gotoAndStop(1);
			Mouse.hide();
		}
		
		public static function removeCursor() {
			stage.removeChild(cursor);
			Mouse.show();
		}
		
		private static function mouseDown(evt:MouseEvent) {
			if (cursor!=null&&cursor is MovieClip) {
				var cursorMC:MovieClip=cursor as MovieClip;
				if (cursorMC.totalFrames>1) cursorMC.gotoAndStop(2);
			}
		}
		
		private static function mouseUp(evt:MouseEvent) {
			if (cursor!=null&&cursor is MovieClip) (cursor as MovieClip).gotoAndStop(1);						
		}
		
		private static function mouseMove(evt:MouseEvent) {
			if (cursor==null||stage==null) return;
			cursor.x=stage.mouseX;
			cursor.y=stage.mouseY;
			evt.updateAfterEvent();
		}
	}
	
}