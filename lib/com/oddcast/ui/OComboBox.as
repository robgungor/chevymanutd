/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* This is the Oddcast combo box
* 
* MovieClips:
* _mcBtn - dropdown button
* _tfSelected - textfield on top of _mcBtn
* dropBox
* dropBox.comboBG
* dropBox._mcSelector
* dropBox._mcScrollbar
* 
* Some differences from the AS2 ComboBox:
* -dropdown button includes the entire top bar and not just the arrow on the right
* -comboBG background to the dropdown box is part of the movieclip
* 
* This uses the ComboSelectorItem, which behaves differently from the StickyButton:
* it is not sticky, and the items highlight on rollover.
* 
* Properties:
* libraryClassName
* rows - maximum number of rows to be displayed in the box. A scrollbar is visible when there are more rows
* boxWidth - width of combo box.  when you change the boxWidth, it also changes the width of all the individual SelectorItems
* 
* Methods:
* add(id,name,obj) - add an Item to the Combobox.
* remove - remove by id
* clear - remove all Items
* selectById
* getSelectedId
* 
* @see com.oddcast.ui.ComboSelectorItem
*/

package com.oddcast.ui {
	import com.oddcast.event.SelectorEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;

	public class OComboBox extends MovieClip {
		public var _mcSelector:Selector;
		public var _mcScrollbar:OScrollBar;
		public var dropBox:MovieClip;
		public var comboBG:MovieClip;
		public var _mcBtn:BaseButton;
		public var _tfSelected:TextField;
		
		protected var _nWidth:Number;
		protected var marginTop:Number;
		protected var marginLeft:Number;
		protected var marginRight:Number;
		protected var tfSelectedMargin:Number;
		protected var enabledTextColor:uint;
		[Inspectable (defaultValue = false)] public var disabledTextChangeColor:Boolean = true;
		[Inspectable (type=Color, defaultValue="#999999")] public var disabledTextColor:uint=0x999999;
		protected var _bDisabled:Boolean = false;
		
		public function OComboBox() {
			//trace("constructor")
			_mcSelector=dropBox.getChildByName("_mcSelector") as Selector;
			_mcScrollbar=dropBox.getChildByName("_mcScrollbar") as OScrollBar;
			comboBG=dropBox.getChildByName("comboBG") as MovieClip;
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved, false, 0, true);
			addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
			
			_mcSelector.addScrollBar(_mcScrollbar);
			_mcSelector.scrollbar_direction="vertical"
			_mcSelector.addEventListener(SelectorEvent.SELECTED,optionSelected,false,0,true);
			_mcSelector.addItemEventListener(MouseEvent.ROLL_OVER,optionRollOver);
			_mcSelector.addEventListener(MouseEvent.MOUSE_UP,selectorClick,false,0,true);
			_mcBtn.addEventListener(MouseEvent.MOUSE_DOWN,btnPressed,false,0,true);
			if (stage != null) 
				stage.addEventListener(MouseEvent.MOUSE_DOWN,stagePressed,false,0,true);

			_tfSelected.mouseEnabled=false;
			dropBox.visible=false;
			
			_nWidth=_mcBtn.width;
			marginTop=_mcSelector.y-comboBG.y;
			marginLeft=_mcSelector.x-comboBG.x;
			marginRight = (comboBG.x + comboBG.width) - (_mcScrollbar.x + _mcScrollbar.width);
			tfSelectedMargin = (_mcBtn.width - _tfSelected.width);
			enabledTextColor = _tfSelected.textColor;
			
			_mcSelector.keyEnabled = true;
			_mcSelector.focusRect = false;
			
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
		}
						
		public function add(id:int,name:String,obj:Object=null,doUpdate:Boolean=true) : void {
			_mcSelector.add(id,name,obj,doUpdate);
			if (doUpdate) updateDropBox();
		}
		
		public function update() : void {
			_mcSelector.update();
			updateDropBox();
		}
		
		public function remove(id:int) : void {
			_mcSelector.remove(id);
			updateDropBox();
		}
		
		public function clear() : void {
			_mcSelector.clear();
			updateDropBox();
		}
		
		public function selectById(id:int) : void {
			_mcSelector.selectById(id);
			var selectedItem:SelectorItem=_mcSelector.getSelectedItem();
			if (selectedItem==null) _tfSelected.text="";
			else _tfSelected.text=selectedItem.text;
		}
		
		public function getSelectedId():int {
			return(_mcSelector.getSelectedId())
		}
		public function getSelectedItem():SelectorItem {
			return(_mcSelector.getSelectedItem());
		}
		
		public function isSelected():Boolean {
			return(_mcSelector.isSelected());
		}
	
		private function stagePressed(evt:MouseEvent) : void {
			//if pressed outside combobox, close box
			if (!hitTestPoint(evt.stageX,evt.stageY,true)) {
				dropBox.visible=false;			
			}
		}		
		private function btnPressed(evt:MouseEvent) : void {
			//mouse down on top button - toggle dropbox
			dropBox.visible=!dropBox.visible;
			if (dropBox.visible) {
				if (_mcSelector.isSelected()) _mcSelector.getSelectedItem().select();
				if (stage != null) stage.focus = _mcSelector;
			}
		}
		private function selectorClick(evt:MouseEvent) : void {
			//mouse up over selector - close dropbox
			dropBox.visible=false;
		}
		
		protected function optionSelected(evt:SelectorEvent) : void {
			_tfSelected.text=evt.text;
			dispatchEvent(evt);
		}
		protected function optionRollOver(evt:MouseEvent) : void {
			if (_mcSelector.isSelected()&&evt.currentTarget.id!=_mcSelector.getSelectedId()) {
				_mcSelector.getSelectedItem().deselect();
			}
		}
		
		private function onKeyPressed(evt:KeyboardEvent) : void {
			if (evt.keyCode == Keyboard.ESCAPE)  dropBox.visible = false;
		}
		
		protected function updateDropBox() : void {
			//trace("updateDropBox")
			var selectorItems:Array=_mcSelector.getItemArray();
			
			if (selectorItems==null||selectorItems.length==0) {
				_mcBtn.disabled=true;
				_tfSelected.text="";
				return;
			}
			else _mcBtn.disabled=_bDisabled;

			comboBG.x=0;
			comboBG.y=0;
			comboBG.width=_nWidth;
			comboBG.height=_mcSelector.visibleHeight+2*marginTop;
			_mcScrollbar.x=_nWidth-marginRight-_mcScrollbar.width;
			_mcScrollbar.y=marginTop;
			_mcScrollbar.scrollbarLength=_mcSelector.visibleHeight;
			
			for (var i:int=0;i<selectorItems.length;i++) {
				selectorItems[i].width=_nWidth-marginLeft-_mcScrollbar.width-2*marginRight;
			}
			_mcSelector.update();
		}
				
		
		//clean-up
		private function onAdded(evt:Event) : void {
			stage.addEventListener(MouseEvent.MOUSE_DOWN,stagePressed,false,0,true);			
		}
		private function onRemoved(evt:Event) : void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,stagePressed);			
		}
		
		[Inspectable (defaultValue="")]
		public function set libraryClassName(s:String) : void {
			_mcSelector.libraryClassName=s;
		}
		
		[Inspectable (defaultValue=4)]
		public function set rows(n:Number) : void {
			_mcSelector.number_of_rows=n;
			updateDropBox();
		}
		
		[Inspectable (defaultValue=0)]
		public function set boxWidth(n:Number) : void {
			if (isNaN(n)||n==0) return;
			//trace("set boxWidth for real")
			
			_nWidth=n;
			_mcBtn.width = _nWidth;
			_tfSelected.width = _mcBtn.width - tfSelectedMargin;
			updateDropBox();
		}
		
		public function get boxWidth():Number {
			return(_nWidth);
		}
		
		public function get disabled():Boolean {
			return(_bDisabled);
		}
		
		public function set disabled(b:Boolean) : void {
			_bDisabled = b;
			dropBox.visible = false;
			_mcBtn.disabled = b;
			if (b && disabledTextChangeColor) _tfSelected.textColor = disabledTextColor;
			else _tfSelected.textColor = enabledTextColor;
		}
	}
	
}