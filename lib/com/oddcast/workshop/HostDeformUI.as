/**
* ...
* @author Sam
* @version 0.1
* 
* This class is to interact with Jake's 3D Host to do the deform function
* 
* FUNCTIONS:
* 
* HostDeformUI($host) - $host is the HostLoader movieclip - can be accessed through the SceneController
* e.g.
* scene:SceneController;
* new HostDeform(scene.mc)
* 
* enable(b) - enables/disables point dragging
* 
************** EVENTS *******************
* 
* 
*/

package com.oddcast.workshop {
	import com.oddcast.host.api.API_Constant;
	import com.oddcast.workshop.HostLoader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;

	public class HostDeformUI extends EventDispatcher {
		private var host:HostLoader;
		private var enabled:Boolean=false;
		private var mouseState:int;
		private var overHost:Boolean=false;
		private var deforming:Boolean=false;
		
		public static const CURSOR_OUT:String="cursorOut";
		public static const CURSOR_OVER:String="cursorOver";
		public static const CURSOR_DRAG:String="cursorDrag";
		
		public function HostDeformUI($host:HostLoader) {
			host=$host;
			host.mouseChildren=false;
			mouseState=API_Constant.FREE_FORM_DEFORM_RETURN_INVALID;
		}
		
		public function enable(b:Boolean=true) {
			enabled=b;
			
			if (b) {
				host.addEventListener(MouseEvent.MOUSE_MOVE,mouseMove,false,0,true);
				host.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown,false,0,true);
				host.addEventListener(MouseEvent.MOUSE_UP,mouseUp,false,0,true);
				host.addEventListener(MouseEvent.MOUSE_OVER,mouseOver,false,0,true);
				host.addEventListener(MouseEvent.MOUSE_OUT,mouseOut,false,0,true);
				mouseMove(null);
			}
			else {
				host.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
				host.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
				host.removeEventListener(MouseEvent.MOUSE_UP,mouseUp);
				host.removeEventListener(MouseEvent.MOUSE_OVER,mouseOver);
				host.removeEventListener(MouseEvent.MOUSE_OUT,mouseOut);
				if (deforming) endDeform();
			}
		}
		
		private function startDeform() {
			host.api.freeFormDeform(host.mouseX, host.mouseY, API_Constant.FREE_FORM_DEFORM_STATE_BEGIN, API_Constant.FREE_FORM_DEFORM_SYMMETRIC, API_Constant.FREE_FORM_DEFORM_POWER_DEFAULT);			
			deforming=true;
			checkState();
		}
		private function endDeform() {
			host.api.freeFormDeform(host.mouseX, host.mouseY, API_Constant.FREE_FORM_DEFORM_STATE_END, API_Constant.FREE_FORM_DEFORM_SYMMETRIC, API_Constant.FREE_FORM_DEFORM_POWER_DEFAULT);			
			deforming=false;
			checkState();
		}
		
		private function mouseDown(evt:MouseEvent) {
			trace("DEFORM::start  "+host.mouseX+","+host.mouseY);
			startDeform();
		}
		
		private function mouseUp(evt:MouseEvent) {
			trace("DEFORM::end  "+host.mouseX+","+host.mouseY);
			endDeform();
		}		
		
		private function mouseOver(evt:MouseEvent) {
			overHost=true;
			checkState();
		}
		
		private function mouseOut(evt:MouseEvent) {
			if (deforming) endDeform();
			overHost=false;
			checkState();
		}
		
		private function getState():int {
			if (!enabled) return(API_Constant.FREE_FORM_DEFORM_RETURN_INVALID);
			if (!overHost) return(API_Constant.FREE_FORM_DEFORM_RETURN_INVALID);
			else if (deforming) return(API_Constant.FREE_FORM_DEFORM_RETURN_DEFORMING);
			else return(host.api.freeFormDeform(host.mouseX, host.mouseY, API_Constant.FREE_FORM_DEFORM_STATE_INQUIRE, API_Constant.FREE_FORM_DEFORM_SYMMETRIC, API_Constant.FREE_FORM_DEFORM_POWER_DEFAULT));			
		}
		
		private function checkState() {
			var newState:int=getState();
			if (newState!=mouseState) {
				if (newState==API_Constant.FREE_FORM_DEFORM_RETURN_INVALID) dispatchEvent(new Event(CURSOR_OUT));
				else if (newState==API_Constant.FREE_FORM_DEFORM_RETURN_AVAILABLE) dispatchEvent(new Event(CURSOR_OVER));
				else if (newState==API_Constant.FREE_FORM_DEFORM_RETURN_DEFORMING) dispatchEvent(new Event(CURSOR_DRAG));
				mouseState=newState;
			}
		}
		
		private function mouseMove(evt:MouseEvent) {
			checkState();
			if (deforming) {
				host.api.freeFormDeform(host.mouseX, host.mouseY, API_Constant.FREE_FORM_DEFORM_STATE_DEFORM, API_Constant.FREE_FORM_DEFORM_SYMMETRIC, API_Constant.FREE_FORM_DEFORM_POWER_DEFAULT);
			}
		}
		
		
	}
	
}