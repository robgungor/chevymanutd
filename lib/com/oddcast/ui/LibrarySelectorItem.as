/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* This is the equivalent of the ImageStickyButton in the AS2 Classes.
* The data object passed to this must implement IThumbSelectorData
* @see
* com.oddcast.ui.Selector
* com.oddcast.ui.SelectorItem
* com.oddcast.data.ThumbSelectorData
*/

package com.oddcast.ui {
	import com.oddcast.event.SelectorEvent;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import com.oddcast.data.ILibraryThumbSelectorData;
	import com.oddcast.data.LibraryThumbSelectorData;
	import flash.text.TextField;
	import com.oddcast.utils.DynamicClassGetter;
	

	public class LibrarySelectorItem extends ButtonSelectorItem {
		private var placeholder:MovieClip;
		private var _mcGraphicEnable:MovieClip;
		private var _mcGraphicRollover:MovieClip;
		private var _mcGraphicPress:MovieClip;
		private var _mcGraphicDisable:MovieClip;
		private var _mcCurrentGraphic:MovieClip;
		
		[Inspectable] public var maintainAspect:Boolean=false;
		
		public function LibrarySelectorItem() {
			super();		
			_bDeselectable = true;
			placeholder = getChildByName("_mcImage") as MovieClip;						
		}

		
		override protected function _onRollOver(evt:MouseEvent):void {
			super._onRollOver(evt);
			////----//----trace("_onRollOver " );
			if (_mcGraphicRollover != null)
			{
				this.removeChild(_mcCurrentGraphic);
				_mcCurrentGraphic = _mcGraphicRollover;
				this.addChild(_mcCurrentGraphic);
				graphicAdded(null);
				
			}
		}
		override protected function _onRollOut(evt:MouseEvent):void	{
			super._onRollOut(evt);
			////----//----trace("_onRollOut " );
			if (!_bSelected && !_bDisabled)
			{
				this.removeChild(_mcCurrentGraphic);
				_mcCurrentGraphic = _mcGraphicEnable;
				this.addChild(_mcCurrentGraphic);
				graphicAdded(null);
			}
		}
		
		override protected function  _onSelect(b:Boolean) {
			super._onSelect(b);
			//----//----trace("_onSelect "+b);
			if (b)
			{			
				this.removeChild(_mcCurrentGraphic);
				_mcCurrentGraphic = _mcGraphicPress!=null?_mcGraphicPress:_mcGraphicRollover!=null?_mcGraphicRollover:_mcGraphicEnable;
				this.addChild(_mcCurrentGraphic);
				graphicAdded(null);			
			}
			else if (!b)
			{
				this.removeChild(_mcCurrentGraphic);
				_mcCurrentGraphic = _mcGraphicEnable;
				this.addChild(_mcCurrentGraphic);
				graphicAdded(null);
			}
		}
		
		override public function deselect():void	{
			super.deselect();
			this.removeChild(_mcCurrentGraphic);
			_mcCurrentGraphic = _mcGraphicEnable;
			this.addChild(_mcCurrentGraphic);
			graphicAdded(null);
		}
		
		private function graphicAdded(evt:Event) {
			if (this.contains(placeholder)) {
				////----//----trace("maintain asoect ratio : "+maintainAspect);
				if (maintainAspect) {
					var scale:Number=Math.max(placeholder.width/_mcCurrentGraphic.width,placeholder.height/_mcCurrentGraphic.height);
					var dx:Number=(scale*_mcCurrentGraphic.width-placeholder.width)/2;
					var dy:Number=(scale*_mcCurrentGraphic.height-placeholder.height)/2;
					
					_mcCurrentGraphic.x=placeholder.x-dx;
					_mcCurrentGraphic.y=placeholder.y-dy;
					_mcCurrentGraphic.width=_mcCurrentGraphic.width*scale;
					_mcCurrentGraphic.height=_mcCurrentGraphic.height*scale;
					_mcCurrentGraphic.mask=placeholder;
				}
				else {
					_mcCurrentGraphic.x=placeholder.x;
					_mcCurrentGraphic.y=placeholder.y;
					_mcCurrentGraphic.width=placeholder.width;
					_mcCurrentGraphic.height=placeholder.height;
				}
			}			
		}		
		
		override public function set data(o:Object):void {
			if (!(o is ILibraryThumbSelectorData||o==null)) throw new TypeError("LibraryThumbSelector must take an object that implements com.oddcast.data.ILibraryThumbSelectorData");
			super.data = o;
			var classGetter:DynamicClassGetter = new DynamicClassGetter();
			var obj:LibraryThumbSelectorData = LibraryThumbSelectorData(data);
			//----//----trace("obj.enabledlass=" + obj.enabledlass+ classGetter.doesClassExists(obj.enabledlass));
			_mcGraphicEnable = classGetter.getInstance(obj.enabledlass) as MovieClip;
			_mcGraphicRollover = classGetter.getInstance(obj.rolloverClass) as MovieClip;
			_mcGraphicPress = classGetter.getInstance(obj.pressClass) as MovieClip;
			_mcGraphicDisable = classGetter.getInstance(obj.disableClass) as MovieClip;
			_mcCurrentGraphic = _mcGraphicEnable;
			this.addChild(_mcCurrentGraphic);
			graphicAdded(null);
		}

	}
	
}