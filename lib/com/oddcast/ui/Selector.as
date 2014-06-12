/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* This is a general Selector.  It replaces ButtonSelector and ThumbSelector from AS2.  The way it determines what
* kind of selector it is is by the type of object that it attaches.  The objects it attaches have to implement
* the SelectorItem interface.  For a button selector, you use the ButtonSelectorItem (replacing StickyButton), and
* for thumb selector, you use a ThumbSelectorItem (replacing ImageStickyButton).  You can also create custom
* selector items - you can use it any time you need to create a list of things, eg sliders, audios, etc.
* 
* The MultiSelector class exposes additional functions that allow you to select more than one item at a time.
* 
* *******************Properties:**********************************
* 
* scrollbar_direction (component prop) - whether selector scrolls horizontally and vertically (selector will overflow in scroll direction)
* 
* number_of_columns, number_of_rows (component properties)
* 
* column_spacing, row_spacing (component properties)
* 
* scrollSpeed - in seconds, how long the scrolling animation takes
* 
* isCarousel - when true, the selector loops back to the beginning after you reach the end.
* 
* libraryClassName - class name of SelectorItem in library to be attached
* 
* livePreview_width, livePreview_height - width and height of item to display in live preview
* 
* autoSizeItem (default true) - when false, use livePreview width and height for actual item dimensions.
* When true, get dimensions of item from attached MovieClip itself
*
* visibleHeight (read-only) - visible height of selector
* 
* maxScroll (read-only) - maximum value of scrollpos (number of invisible lines)
* 
* -------------------------------------------------------------------------
* Methods:
* 
* add(id,textLabel[,dataObj,doUpdate]) - add a SelectorItem with id, text label and initializing object.
* --doUpdate can be set to false if you add many items and want to update only once at the end instead of after each add
* remove(id) - remove by id
* clear() - remove all
* 
* scrollBy(dir) - dir is # of lines to scroll by.  negative values scroll backwards.  scroll is animated
* scrollUp(), scrollDown() - alias for scrollBy(-1) and scrollBy(1)
* setScrollPos(scrollpos) - scrollpos = line number to scroll to - supports fractions
* addScrollBar(scrollbar)
* 
* selectById(id) - select by id
* deselect() - select none
* 
* getItemById(id) - return SelectorItem with a certain id
* getItemArray() - return array of all SelectorItems
* getSelectedItem() - return selected SelectorItem object
* getSelectedId() - return selected id
* isSelected() - returns false if nothing is selected
* 
* addItemEventListener
* removeItemEventListener:
* these two functions function like addEventListener and removeListener, but they add and remove events
* from the SelectorItems, instead of the selector itself
* To access the id of the SelectorItem that is throwing the event, use evt.currentTarget.id
* 
* Events:
* 
* SelectorEvent.SELECTED - an Item has been selected. returns id, text, and data properties of SelectorItem
* 
* SelectorEvent.DESELECTED - an Item has been deselected. returns id, text, and data properties of SelectorItem
* This doesn't apply for buttonselectors or thumbselectors, but it could for custom SelectorItems
*  
* 
* @see
* com.oddcast.ui.SelectorItem
* com.oddcast.event.SelectorEvent
*/

package com.oddcast.ui {
	import com.oddcast.event.ScrollEvent;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.animation.*;
	import com.oddcast.ui.animation.IScrollEasing;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;

	public class Selector extends MovieClip {
		protected var itemArr:Array;
		private var holder:Sprite;
		private var holderMask:Sprite;
		private var scrollbar:Slider;
		private var scrollBtnArr:Array;
		private var autosizeScrollbar:Boolean = false;
		private var lockScrollbarPos:Boolean = true;
		
		private var itemUpdateRequired:Boolean = false;
		private var scrollUpdateRequired:Boolean = false;
		private var selectionUpdateRequired:Boolean = false;
		private var selectionFocusRequired:Boolean = false;
		
		[Inspectable]public var libraryClassName:String;
		[Inspectable]public var isCarousel:Boolean=false;
		[Inspectable]public var scrollSpeed:Number=0; //number of seconds to scroll
		[Inspectable (defaultValue=0)]public var livePreview_width:Number=0;
		[Inspectable (defaultValue=0)]public var livePreview_height:Number=0;
		private var autoSizeItem:Boolean=false;
		private var numColumns:uint=4;
		private var numRows:uint=2;
		private var columnSpacing:Number=5;
		private var rowSpacing:Number=3;
		private var scrollHoriz:Boolean=false;
		
		private var scrollPos:Number = 0;
		public static var defaultScrollEasingClass:Class = ConstantSpeedScroll;
		public var scrollEasingClass:Class;
		private var scrollEasing:IScrollEasing;
		private var startScrollPos:Number;
		private var targetScrollPos:Number;
		private var isScrolling:Boolean = false;
		private var scrollShift:Number = 0;

		//An Array selected ids.  When allowMultiple is false, this can be an array of either 0 or 1 int.
		//When allowMultiple is true, this can contain more than 1 id.
		protected var selectedIdArr:Array = []; 
		
		//You can optionally set a particular ID to be the "none" id
		//Clicking the item with this ID deselects all other buttons,
		//and deselecting all other buttons highlights this item		
		protected var noneId:int = -1;
		protected var noneIdSet:Boolean = false;
		
		protected var _allowMultiple:Boolean = false; //when this is false, you can only select one at a time
		private var listenerArr:Array;
		
		public function Selector() {
			addEventListener(Event.RENDER, onRender);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoved,false,0,true);
			holder=new Sprite();
			holder.name="item_holder";
			addChild(holder);
			holderMask=new Sprite();
			addChild(holderMask);
			itemArr=new Array();
			listenerArr=new Array();
			scrollBtnArr = new Array();
		}
		
//---------------------------------------------------------------------------------------------------------------------
//---------------------------------------------  add/remove functions  ------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------		

		public function add(id:int, textLabel:String, dataObj:Object = null, doUpdate:Boolean = true):Object {
			//the doUpdate variable is deprecated and is no longer used - here for backwards compatibility only
			
			if (libraryClassName==null) {
				throw new Error("Selector: library class has not been initialized yet");
				return;
			}
			var classDefinition:Class = getDefinitionByName(libraryClassName) as Class;
			var item:SelectorItem = new classDefinition() as SelectorItem;
			if (item == null) {
				throw new Error("Selector: cannot create new instance of class - " + libraryClassName + ".  Verify that the class name is correct.");
			}
			item.id=id;
			item.text=textLabel;
			item.data=dataObj;
			item.addEventListener(SelectorEvent.SELECTED,itemSelected,false,0,true);
			item.addEventListener(SelectorEvent.DESELECTED,itemDeselected,false,0,true);
			//item.addEventListener(MouseEvent.CLICK,itemClicked);
			for (var i:int=0;i<listenerArr.length;i++) {
				item.addEventListener(listenerArr[i].type,listenerArr[i].listener,false,0,true);
			}
			holder.addChild(item as DisplayObject);
			itemArr.push(item)
			requireItemUpdate();
			return item;
		}
		
		public function remove(id:int) : void {
			for (var i:int=0;i<itemArr.length;i++) {
				if (itemArr[i].id==id) {
					removeItem(itemArr[i]);
					itemArr.splice(i,1);
					break;
				}
			}
			var pos:int = selectedIdArr.indexOf(id);
			if (pos >= 0) selectedIdArr.splice(pos, 1);
			if (scrollPos>maxScroll) setScrollPos(maxScroll);
			requireItemUpdate();
		}
		
		public function clear() : void {
			for (var i:int=0;i<itemArr.length;i++) {
				removeItem(itemArr[i]);
			}
			itemArr=new Array();
			selectedIdArr = [];
			setScrollPos(0);
			requireItemUpdate()
		}
		
		private function removeItem(item:SelectorItem) : void {
			item.removeEventListener(SelectorEvent.SELECTED,itemSelected);
			item.removeEventListener(SelectorEvent.DESELECTED,itemDeselected);
			for (var i:int=0;i<listenerArr.length;i++) {
				item.removeEventListener(listenerArr[i].type,listenerArr[i].listener);
			}
			holder.removeChild(item as DisplayObject);
		}

		/*returns -1 if item doesn't exist*/
		public function getItemOrderById(id:int):int {
			var item:SelectorItem = getItemById(id);
			if (item == null) return( -1);
			else return(itemArr.indexOf(item));
		}
		public function setItemOrderById(id:int, order:uint) : void {
			var item:SelectorItem = getItemById(id);
			if (item == null) return;
			if (order > itemArr.length) order = itemArr.length;
			var curOrder:int = itemArr.indexOf(item);
			itemArr.splice(curOrder, 1);
			itemArr.splice(order, 0, item);
			requireItemUpdate();
		}
//---------------------------------------------------------------------------------------------------------------------	
//--------------------------------------------------  update functions  --------------------------------------------
//---------------------------------------------------------------------------------------------------------------------

		
		private function requireItemUpdate() : void {
			if (stage == null) update();
			else {
				itemUpdateRequired = true;
				addEventListener(Event.RENDER, onRender);
				stage.invalidate();
			}
		}
		
		private function requireScrollUpdate() : void {
			if (stage == null) updatePosition();
			else {
				scrollUpdateRequired = true;
				addEventListener(Event.RENDER, onRender);
				stage.invalidate();
			}
		}
		
		private function requireSelectionUpdate(focusOnSelected:Boolean=false) : void {
			if (stage == null) {
				updateSelected();
				if (focusOnSelected) gotoSelected();
			}
			else {
				selectionUpdateRequired = true;
				if (focusOnSelected) selectionFocusRequired = true;
				addEventListener(Event.RENDER, onRender);
				stage.invalidate();
			}
		}
		

		private function onRender(evt:Event) : void {
			removeEventListener(Event.RENDER, onRender);
			if (itemUpdateRequired||scrollUpdateRequired) update();
			if (selectionUpdateRequired) updateSelected();
			if (selectionFocusRequired) gotoSelected();
			
			itemUpdateRequired = scrollUpdateRequired = selectionUpdateRequired = selectionFocusRequired = false;
		}
		
		public function update() : void
		{
			if (itemArr.length>0) {
				var posX:uint;
				var posY:uint;
				var i:uint;
				for (i=0;i<itemArr.length;i++) {
					if (scrollHoriz) {
						posY=i%numRows;
						posX=Math.floor(i/numRows);
					}
					else {
						posX=i%numColumns;
						posY=Math.floor(i/numColumns);
					}
					itemArr[i].x=posX*(itemWidth+columnSpacing);
					itemArr[i].y=posY*(itemHeight+rowSpacing);
				}
				createMask();
				
				if (itemArr.length <= (numLines * itemsPerLine)) {
					if (scrollHoriz) holder.x = 0;
					else holder.y=0;
				}
			}
			updatePosition();
		}
		
		private function updatePosition() : void {
			//notify items if they are shown
			for (var i:uint=0;i<itemArr.length;i++) {
				itemArr[i].shown(itemArr[i].hitTestObject(holderMask));
				//itemScrollPos=Math.floor(i/(scrollHoriz?numRows:numColumns));
				//itemArr[i].shown(itemScrollPos>=getMinVisScroll&&itemScrollPos<=getMaxVisScroll);
			}			
			if (scrollbar!=null) updateScrollBar();
			updateScrollBtns();
			
			var scrPercent:Number = maxScroll == 0?0:(scrollPos / maxScroll);
			var scrPos:int = Math.floor(isScrolling?targetScrollPos:scrollPos);
			dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL, scrPercent,scrPos));
		}
		
		private function updateScrollBar() : void {
			if (maxScroll>0) {
				scrollbar.totalSteps=maxScroll+1;
				scrollbar.visible=true;
				scrollbar.draggerPercentSize=numLines/Math.ceil(itemArr.length/itemsPerLine);
				//scrollbar.step = Math.round(scrollPos);
				if (!lockScrollbarPos&&isScrolling) scrollbar.percent = targetScrollPos / maxScroll;
				else scrollbar.percent = scrollPos / maxScroll;
				if (autosizeScrollbar) scrollbar.length = maskHeight;
			}
			else {
				scrollbar.percent=0;
				scrollbar.visible=false;
			}
		}
		
		private function updateScrollBtns() : void {
			var btn:InteractiveObject;
			var dir:Number;
			for (var i:int = 0; i < scrollBtnArr.length; i++) 
			{
				btn = scrollBtnArr[i].btn;
				dir = scrollBtnArr[i].dir;
				if (isCarousel) 
				{
					if (numItems > numLines) enable_btn( btn, true );
					else enable_btn( btn, false );
				}
				else 
				{
					if (itemArr.length == 0 || (dir < 0 && getScrollPos() <= 0) || (dir > 0 && getScrollPos() >= maxScroll)) enable_btn( btn, false );
					else enable_btn( btn, true );
				}
			}
			
			function enable_btn( _btn:InteractiveObject, _enable:Boolean ):void
			{
				(_btn is BaseButton) ? (_btn as BaseButton).disabled = !_enable : _btn.mouseEnabled = _btn.visible =  _enable;
			}
		}
		
		private function createMask() : void {
			if (itemArr.length==0) return;
			holderMask.graphics.clear();
			holderMask.graphics.beginFill(0);
			holderMask.graphics.drawRect(0,0,maskWidth,maskHeight);
			holderMask.graphics.endFill();
			holder.mask=holderMask;
		}
		
//---------------------------------------------------------------------------------------------------------------------
//--------------------------------------------   properties   --------------------------------------------
//---------------------------------------------------------------------------------------------------------------------
		
		public function get numLines():int { //number of visible lines
			return(scrollHoriz?numColumns:numRows);
		}
		
		public function get itemsPerLine():int {
			return(scrollHoriz?numRows:numColumns);
		}
		
		private function get lineHeight():Number {
			if (itemArr.length==0) return(0);
			else if (scrollHoriz) return(itemWidth+columnSpacing);
			else return(itemHeight+rowSpacing)
		}
		
		private function get itemHeight():Number {
			if (autoSizeItem||livePreview_height<=0) return(itemArr.length==0?0:itemArr[0].height);
			else return(livePreview_height);
		}
		private function get itemWidth():Number {
			if (autoSizeItem||livePreview_width<=0) return(itemArr.length==0?0:itemArr[0].width);
			else return(livePreview_width);
		}
		
		public function get visibleHeight():Number {
			return(Math.min(holderMask.height,itemHeight*itemArr.length+rowSpacing*(itemArr.length-1)))
		}
		
		public function get maskHeight():Number {
			//trace("maskHeight=("+itemHeight+"*"+numRows+"+"+rowSpacing+"*("+numRows+"-1))="+(itemHeight*numRows+rowSpacing*(numRows-1)));
			return(itemHeight*numRows+rowSpacing*(numRows-1));
		}
				
		public function get maskWidth():Number {
			return(itemWidth*numColumns+columnSpacing*(numColumns-1));
		}
		[Inspectable(defaultValue=4)]
		public function set number_of_columns(x:uint):void
		{
			numColumns = x;		
		}
		
		public function get number_of_columns():uint { return(numColumns);	}

		[Inspectable(defaultValue=2)]
		public function set number_of_rows(x:uint) : void {
			numRows = x;	
		}
		
		public function get number_of_rows():uint { return(numRows);	}

		[Inspectable(defaultValue=5)]
		public function set column_spacing(x:Number) : void {
			columnSpacing = x;		
		}	

		[Inspectable(defaultValue=3)]
		public function set row_spacing(x:Number):void
		{
			rowSpacing = x;		
		}	

		[Inspectable(type=Array, enumeration="vertical,horizontal", defaultValue="vertical")]
		public function set scrollbar_direction(s:String) : void {
			if (s=="horizontal") scrollHoriz=true;
			else scrollHoriz=false;
		}
		
		[Inspectable(defaultValue=false)]
		public function set autosize_item(b:Boolean) : void {
			autoSizeItem=b;
			requireItemUpdate();
		}
		
		[Inspectable(defaultValue=false)]
		public function set keyEnabled(b:Boolean) : void {
			if (b) addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			else removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
		}	
		
//---------------------------------------------------------------------------------------------------------------------
//--------------------------------------------  scrolling functions  --------------------------------------------
//---------------------------------------------------------------------------------------------------------------------
		
		public function addScrollBtn(in_btn:InteractiveObject, in_dir:Number) : void
		{
			scrollBtnArr.push({btn:in_btn,dir:in_dir})
			in_btn.addEventListener(MouseEvent.MOUSE_DOWN,scrollBtnClick,false,0,true);
			requireScrollUpdate();
		}
		
		private function scrollBtnClick(evt:MouseEvent):void
		{
			for (var i:int = 0; i < scrollBtnArr.length; i++) 
				if (scrollBtnArr[i].btn == evt.target) 
					scrollBy(scrollBtnArr[i].dir);
		}
		
		public function addScrollBar(in_scrollbar:Slider, autoSize:Boolean = false, lockPos:Boolean = true) : void {
			//when autoSize is true, the scrollbar will automatically be resized to the size of the selector
			//when lockPos is true, the selector will move to the exact position of the scrollbar.  when it
			//is false, the selector will animate towards the position of the scrollbar.
			
			scrollbar = in_scrollbar;
			autosizeScrollbar = autoSize;
			lockScrollbarPos = lockPos;
			//scrollbar.setScrollBarHeight(scrollHoriz?holderMask.width:holderMask.height);
			scrollbar.addEventListener(ScrollEvent.SCROLL,scrollChanged,false,0,true);
			requireScrollUpdate();
		}
		
		private function scrollChanged(evt:ScrollEvent) : void {
			if (lockScrollbarPos) setScrollPos(evt.percent * maxScroll, false);
			else scrollAnimateTo(evt.percent * maxScroll);
		}
		
		public function scrollUp() : void {scrollBy(-1)}
		public function scrollDown() : void {scrollBy(1)}
		
		public function scrollBy(delta:Number) : void {
			scrollAnimateTo(Math.round((isScrolling?targetScrollPos:scrollPos)+delta));
		}
		
		public function scrollAnimateTo($targetScrollPos:Number) : void {
			targetScrollPos = $targetScrollPos;
			
			//if it's already scrolling, add the delta onto the target position
			//otherwise use the actual current position
			if (scrollEasingClass==null) scrollEasingClass = defaultScrollEasingClass;
			if (scrollEasing==null) scrollEasing = new scrollEasingClass() as IScrollEasing;
			
			if (!isCarousel&&targetScrollPos>maxScroll) targetScrollPos=maxScroll;
			if (!isCarousel&&targetScrollPos<0) targetScrollPos=0;			
			if (scrollSpeed==0) setScrollPos(targetScrollPos);
			else {
				addEventListener(Event.ENTER_FRAME, animateScroll, false, 0, true);
				if (!isScrolling) {
					scrollEasing.setStartPos(scrollPos);
					scrollShift = 0;
				}
				isScrolling = true;
				scrollEasing.setTargetPos(targetScrollPos-scrollShift);
			}
		}
		
		private function animateScroll(evt:Event) : void {
			var deltaPercent:Number = 1 / (stage.frameRate * scrollSpeed + 1);
			setScrollPos(scrollEasing.getNextPos(deltaPercent)+scrollShift);
			if (scrollEasing.getComplete()) {
				removeEventListener(Event.ENTER_FRAME,animateScroll);
				isScrolling=false;
			}
			
			/*
			var deltaScroll:Number=1/(stage.frameRate*scrollSpeed+1);
			if (Math.abs(targetScrollPos-scrollPos)<=deltaScroll) {
				setScrollPos(targetScrollPos);
				removeEventListener(Event.ENTER_FRAME,animateScroll);
				isScrolling=false;
			}
			else if (targetScrollPos>scrollPos) setScrollPos(scrollPos+deltaScroll)
			else if (targetScrollPos<scrollPos) setScrollPos(scrollPos-deltaScroll)
			*/
		}		
		
		private function getScrollPos():Number {
			if (isScrolling) return(targetScrollPos);
			else return(scrollPos);
		}
		
		public function setScrollPos(in_scroll:Number,updateScrollPercent:Boolean=true) : void {
			scrollPos=in_scroll;
			
			//shift order of items for carousel
			if (isCarousel) {
				if (scrollPos<0) shiftItems(Math.floor(scrollPos))
				else if (scrollPos>maxScroll) shiftItems(Math.ceil(scrollPos-maxScroll));
			}
			
			if (scrollPos>maxScroll) scrollPos=maxScroll;
			if (scrollPos<0) scrollPos=0;
			
			if (scrollHoriz) holder.x=-scrollPos*lineHeight
			else holder.y=-scrollPos*lineHeight
			
			//notify items if they are shown
			requireScrollUpdate();
		}
		
		private function shiftItems(dir:int) : void {
			//shift the order of the items "dir" rows/columns
			if (dir>maxScroll) dir=maxScroll;
			if (dir<-maxScroll) dir=-maxScroll;
			
			var itemShift:int=dir*itemsPerLine;
			if (scrollHoriz) holder.x+=dir*(itemWidth+columnSpacing);
			else holder.y+=dir*(itemHeight+rowSpacing);
			
			itemArr=itemArr.slice(itemShift).concat(itemArr.slice(0,itemShift));
			requireItemUpdate();
			scrollPos-=dir;
			targetScrollPos -= dir;
			scrollShift -= dir;
		}
		
		public function get maxScroll():int {
			var maxscr:int=Math.floor((itemArr.length-1)/itemsPerLine)-numLines+1;
			if (maxscr<0) maxscr=0;
			return(maxscr);
		}
				
//---------------------------------------------------------------------------------------------------------------------
//------------------------------------   selection/communication functions  -------------------------------------------
//---------------------------------------------------------------------------------------------------------------------
		
		//private function itemClicked(evt:MouseEvent) {
		//	dispatchEvent(evt);
		//}
		
		protected function itemSelected(evt:SelectorEvent) : void {
			if (isNoneId(evt.id)) {
				if (!isSelected()) return;
				deselect();
			}
			else {
				if (selectedIdArr.indexOf(evt.id)>=0) return;
				setSelected(evt.id)
			}
			dispatchEvent(evt);
		}
		
		protected function itemDeselected(evt:SelectorEvent) : void {
			if (evt.id==noneId) { //you can't deselect "none"
				evt.currentTarget.select();
				return;
			}
			if (!(selectedIdArr.indexOf(evt.id) >= 0)) return;
			
			setDeselected(evt.id);
			dispatchEvent(evt);
			
		}
		
		public function selectById(id:int) : void {
			setSelected(id);
			
			requireSelectionUpdate(true);
		}
		
		public function gotoSelected() : void {
			if (selectedIdArr.length == 0) return;
			var id:int = selectedIdArr[0];
			var selectedArrPos:int=0;
			for (var i:uint=0;i<itemArr.length;i++) if (itemArr[i].id==id) selectedArrPos=i;
			var newScroll:int=selectedArrPos/itemsPerLine;
			var minVisScroll:int=Math.ceil(scrollPos);
			var maxVisScroll:int=Math.floor(scrollPos)+numLines-1;
			if (newScroll<minVisScroll) setScrollPos(newScroll);
			else if (newScroll > maxVisScroll) setScrollPos(newScroll - numLines + 1)
		}
		
		protected function setSelected(id:int) : void {
			if (allowMultiple) {
				if (selectedIdArr.indexOf(id)==-1) selectedIdArr.unshift(id);
			}
			else {
				var isValidId:Boolean=false;
				var i:int;
				for (i=0;i<itemArr.length;i++) {
					if (itemArr[i].id == id) {
						isValidId = true;
						break;
					}
				}
				selectedIdArr = isValidId?[id]:[];
			}
			requireSelectionUpdate();
		}
		
		protected function setDeselected(id:int) : void {
			var pos:int = selectedIdArr.indexOf(id);
			if (pos >= 0) selectedIdArr.splice(pos, 1);
			requireSelectionUpdate();
		}
		
		protected function updateSelected() : void {
			var i:int;
			var pos:int;
			var itemSelected:Boolean;
			var item:SelectorItem;
			for (i = 0; i < itemArr.length; i++) {
				item = itemArr[i];
				itemSelected=false;
				if (isNoneId(item.id)&&!isSelected()) itemSelected=true;
				else {
					pos = selectedIdArr.indexOf(item.id);
					if (pos >= 0) itemSelected = true;
				}
				if (itemSelected) item.select();
				else item.deselect();
			}
		}
		
		public function deselect() : void {
			selectedIdArr = [];
			requireSelectionUpdate();
		}
		
		public function get numItems():uint {
			return(itemArr.length);
		}
		
		public function getItemArray():Array {
			return(itemArr);
		}
		
		public function getItemById(id:int):SelectorItem {
			var item:SelectorItem=null;
			for (var i:uint=0;i<itemArr.length;i++) if (itemArr[i].id==id) item=itemArr[i];
			return(item)
		}
		
		public function getItemByName(name:String):SelectorItem {
			var item:SelectorItem=null;
			for (var i:uint=0;i<itemArr.length;i++) if (itemArr[i].text==name) item=itemArr[i];
			return(item)
		}
		
		public function getSelectedItem():SelectorItem {
			if (isSelected()) return(getItemById(selectedIdArr[0]));
			else return(null);
		}
		
		public function getSelectedId():int {
			if (isSelected()) return(selectedIdArr[0]);
			else return(noneId);
		}
		
		public function isSelected():Boolean {
			return(selectedIdArr.length>0);
		}
		
		public function addItemEventListener(evtType:String,listener:Function) : void {
			var i:int;
			for (i=0;i<listenerArr.length;i++) { //check if listener already exists
				if (listenerArr[i].type==evtType&&listenerArr[i].listener==listener) return;				
			}
			
			listenerArr.push({type:evtType,listener:listener});
			for (i=0;i<itemArr.length;i++) {
				itemArr[i].addEventListener(evtType,listener,false,0,true);
			}
		}
		
		public function removeItemEventListener(evtType:String,listener:Function) : void {
			var i:int;
			for (i=0;i<itemArr.length;i++) {
				itemArr[i].removeEventListener(evtType,listener);
			}			
			for (i=0;i<listenerArr.length;i++) {
				if (listenerArr[i].type==evtType&&listenerArr[i].listener==listener) {
					listenerArr.splice(i,1);
					break;
				}
			}
		}
	
		private function isNoneId(id:int) : Boolean {
			return(noneIdSet&&id==noneId);
		}
		
		public function get allowMultiple():Boolean { return _allowMultiple; }
		
		/*private function getLibraryItem(className:String):DisplayObject {
			var classDefintion:Class = getDefinitionByName(className) as Class;
			var customClassInstance:DisplayObject = new classDefintion() as DisplayObject;			
			return(customClassInstance);
		}*/

//-------------------------------------------------------------------------------------------------------------------
//---------------------------------------------keyboard selection  --------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------

		private function onKeyPressed(evt:KeyboardEvent) : void {
			if (evt.keyCode == Keyboard.UP) incrementSelected(-1);
			else if (evt.keyCode == Keyboard.DOWN) incrementSelected( 1);
			else if (evt.keyCode == Keyboard.PAGE_UP) incrementSelected( -numRows*numColumns);
			else if (evt.keyCode == Keyboard.PAGE_DOWN) incrementSelected( numRows*numColumns);
			else selectByKey(String.fromCharCode(evt.charCode).toLowerCase());
		}
		
		private function incrementSelected(increment:int) : void {
			if (itemArr.length == 0) return;
			var item:SelectorItem;
			var selectedItemOrder:int=-1;
			
			var i:int;
			for (i = 0; i < itemArr.length; i++) {
				item = itemArr[i];
				if (isSelected() && item.id == getSelectedId()) selectedItemOrder = i;
			}
			var nextOrder:int=selectedItemOrder + increment;
			if (nextOrder < 0) nextOrder = 0;
			if (nextOrder >= itemArr.length) nextOrder = itemArr.length - 1;
			if (nextOrder != selectedItemOrder) {
				item = itemArr[nextOrder];
				selectById(item.id);
				dispatchEvent(new SelectorEvent(SelectorEvent.SELECTED, item.id, item.text, item.data));
			}
		}
		
		private function selectByKey(key:String) : void {
			//select by first letter of entry
			
			if (itemArr.length == 0) return;
			var item:SelectorItem;
			var matchingItemOrder:Array = new Array();
			var selectedItemOrder:int = -1;
			var nextOrder:int = -1;
			var useNext:Boolean = false;
			
			//chooses the next matching entry which follows the currently selected entry
			//if not selected or there are no matches following selected, choose the first entry
			for (var i:int = 0; i < itemArr.length; i++) {
				item = itemArr[i];
				if (item.text.slice(0, 1).toLowerCase() == key) {
					if (nextOrder < 0 || useNext) {
						nextOrder = i;
						useNext = false;
					}
				}
				//if the current entry is selected flag the next matching entry to be selected
				if (isSelected() && item.id == getSelectedId()) {
					selectedItemOrder = i;
					useNext = true;
				}
			}

			if (nextOrder>=0&&nextOrder != selectedItemOrder) {
				item = itemArr[nextOrder];
				selectById(item.id);
				dispatchEvent(new SelectorEvent(SelectorEvent.SELECTED, item.id, item.text, item.data));
			}
		}
		
//---------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------  clean-up  -----------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------
		
		private function onRemoved(evt:Event) : void { //do clean-up
			removeEventListener(Event.ENTER_FRAME,animateScroll);
		}
		
		public function destroy() : void { //clean-up everything
			if (scrollbar!=null) scrollbar.removeEventListener(ScrollEvent.SCROLL,scrollChanged);
			for (var i:int=0;i<scrollBtnArr.length;i++) {
				scrollBtnArr[i].removeEventListener(MouseEvent.MOUSE_DOWN,scrollBtnClick);
			}
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			removeEventListener(Event.ENTER_FRAME, animateScroll);
			clear();			
		}		
	}
	
}