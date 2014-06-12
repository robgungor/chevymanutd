package custom
{
	import code.skeleton.App;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import org.casalib.events.RemovableEventDispatcher;

	public class SlideBar extends RemovableEventDispatcher
	{
		protected var _handle	:MovieClip;
		protected var _plus		:DisplayObject;
		protected var _minus	:DisplayObject;
		protected var _bar		:DisplayObject;
		
		protected var _value	:Number;
		
		public function SlideBar(handle:DisplayObject, bar:DisplayObject, plus:DisplayObject, minus:DisplayObject)
		{
			_handle = handle as MovieClip;
			_plus 	= plus;
			_minus 	= minus;
			_bar 	= bar;
			
			_init();
		}
		
		protected function _init():void
		{
			_handle.buttonMode = true;
			_addListeners();
		}
		
		protected function _addListeners():void
		{
			_handle.addEventListener(MouseEvent.MOUSE_DOWN, _onHandleMouseDown);
			_handle.addEventListener(MouseEvent.MOUSE_UP, _onHandleMouseUp);
			_plus.addEventListener(MouseEvent.MOUSE_DOWN, _onPlusMouseDown);
			_minus.addEventListener(MouseEvent.MOUSE_DOWN, _onMinusMouseDown);
			_bar.addEventListener(MouseEvent.MOUSE_DOWN, _onBarMouseDown);
		}
		protected function _onPlusMouseDown(e:MouseEvent):void
		{
			value += .0015;
			_moveDraggerOnInterval();
		}
		protected function _onMinusMouseDown(e:MouseEvent):void
		{
			value -= .0015;
			_moveDraggerOnInterval(false);
		}
		protected var timer:Timer;
		protected var moveDraggerRight:Boolean;
		
		protected function _moveDraggerOnInterval(towardsRight:Boolean = true):void
		{	
			moveDraggerRight = towardsRight;
			stop_timer();
			timer = new Timer(24/1000, 0);
			timer.start();
			_handle.stage.addEventListener( MouseEvent.MOUSE_UP, stop_timer);
			_handle.stage.addEventListener(MouseEvent.MOUSE_OUT, stop_timer);
			timer.addEventListener( TimerEvent.TIMER, call_on_repeat);
			
		}
		protected function call_on_repeat( _e:TimerEvent ):void 
		{	
			value = moveDraggerRight ? value+0.0015 : value-0.0015;
		}
		protected function stop_timer( _e:MouseEvent = null ):void
		{	
			_handle.stage.removeEventListener( MouseEvent.MOUSE_UP, stop_timer);
			_handle.stage.removeEventListener(MouseEvent.MOUSE_OUT, stop_timer);
			if(timer){
				timer.removeEventListener( TimerEvent.TIMER, call_on_repeat);
				timer.stop();
				timer = null;
			}
		}
		protected function _onBarMouseDown(e:MouseEvent):void
		{
			_handle.x = _bar.parent.globalToLocal(_bar.localToGlobal(new Point(_bar.mouseX, _bar.mouseY))).x;
			_onHandleMouseDown();			
			dispatchEvent(new Event(Event.CHANGE));
		}
		protected function _onHandleMouseDown(e:MouseEvent=null):void
		{
			_handle.startDrag(true, new Rectangle(_bar.x+Math.round(_handle.width/2), _handle.y, _bar.width-Math.round(_handle.width), 0));
			_handle.stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			_handle.stage.addEventListener(MouseEvent.MOUSE_UP, _onHandleMouseUp);
			_value = (_localHandleX-Math.round(_handle.width/2))/(_bar.width-_handle.width);
		}
		protected function _onHandleMouseUp(e:MouseEvent):void
		{
			_handle.stopDrag();
			_handle.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			_handle.stage.removeEventListener(MouseEvent.MOUSE_UP, _onHandleMouseUp);
		}
		
		protected function _onMouseMove(e:MouseEvent):void
		{
			_value = (_localHandleX-Math.round(_handle.width/2))/(_bar.width-_handle.width);
			dispatchEvent(new Event(Event.CHANGE));
		}
		protected function get _localHandleX():Number
		{
			return _bar.globalToLocal(
				_handle.parent.localToGlobal(new Point(_handle.x, _handle.y))
			).x
		}
		//between 0-1;
		public function get value():Number
		{
			if(isNaN(_value)) _value = (_localHandleX-Math.round(_handle.width/2))/(_bar.width-_handle.width);
			return _value;
			//return ((_bar.globalToLocal(new Point(_handle.x, _handle.y)).x-Math.round(_handle.width/2))/(_bar.width-_handle.width));
		}

		public function set value(val:Number):void
		{
			_value = Math.min(Math.max(val, 0), 1);
			
			//_handle.x =  Math.round(_handle.width/2+(_bar.localToGlobal(new Point(_value*(_bar.width-(_handle.width)), 0)).x));
			var loc:Point = new Point(_value*(_bar.width-(_handle.width)), 0);
			var targX:Number = _bar.parent.globalToLocal(_bar.localToGlobal(loc)).x
			_handle.x = Math.round(_handle.width/2+targX);
			//_handle.x =  _bar.parent.globalToLocal(_handle.localToGlobal(new Point(_handle.x, _handle.y))).x;
		/*	var left:Number = _bar.x+Math.round(_handle.width/2);
			var right:Number = _bar.localToGlobal(new Point(_bar.width-Math.round(_handle.width/2), 0)).x;
			_handle.x = Math.min(Math.max(_handle.x, left), right);*/
			
			dispatchEvent(new Event(Event.CHANGE));
		}

	}
}