package custom
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import org.casalib.events.RemovableEventDispatcher;
	
	public class ProgressBar extends RemovableEventDispatcher
	{
		protected var _ui:*;
		public function ProgressBar(ui:*)
		{
			super();
			_ui = ui;
			_ui.buttonMode = true;
			_ui.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
		}
		protected function _onMouseDown(e:MouseEvent):void
		{
			_ui.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			if(_ui.stage) _ui.stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			
			_ui.bar.width = Math.min(Math.max(_ui.mouseX, 0), _ui.bg.width);
			dispatchEvent(new Event(Event.CHANGE));
		}
		protected function _onMouseMove(e:MouseEvent):void
		{	
			_ui.bar.width = Math.min(Math.max(_ui.mouseX, 0), _ui.bg.width);
			dispatchEvent(new Event(Event.CHANGE));
		}
		protected function _onMouseUp(e:MouseEvent):void
		{
			_ui.stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp)
			_ui.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
		}
		public function update(percent:Number):void
		{
			_ui.bar.width = Math.round( percent*_ui.bg.width );
		}
		public function get progress():Number
		{
			return _ui.bar.width/_ui.bg.width;
		}
		override public function destroy():void
		{
			_ui.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			super.destroy();
		}
	}
}