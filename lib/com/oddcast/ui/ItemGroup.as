/**
* ...
* @author Sam Myer
* @version 0.1
* @usage
* Selector Lite.  It has all of the select/deselect functions from the Selector, but without all the nice
* UI stuff.  This lets you, say, place a bunch of buttons on the stage in a circle, and register them with the
* ItemGroup, and then you can use all the selection functions of the Selector without having the rigid row/column layout.
* Also, ItemGroup isn't instantiated on the Stage and doesn't create Items like the Selector does.
* It's just a bunch of references to aready existing Items.
* 
* @see
* com.oddcast.ui.Selector
*/

package com.oddcast.ui {
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.ui.SelectorItem;
	import flash.events.EventDispatcher;
	import flash.events.Event;

	public class ItemGroup extends EventDispatcher {
		private var itemArr:Array;
		
		[Inspectable]public var libraryClassName:String;
		private var selectedId:Number=Number.NaN;
		private var listenerArr:Array;
		
		public function ItemGroup() {
			itemArr=new Array();
			listenerArr=new Array();
		}
		
		//add/remove functions
				
		public function registerItem(item:SelectorItem,id:int,textLabel:String=null,dataObj:Object=null) {
			item.id=id;
			item.text=textLabel;
			item.data=dataObj;
			item.addEventListener(SelectorEvent.SELECTED,itemSelected,false,0,true);
			//item.addEventListener(MouseEvent.CLICK,itemClicked);
			for (var i:int=0;i<listenerArr.length;i++) {
				item.addEventListener(listenerArr[i].type,listenerArr[i].listener,false,0,true);
			}
			itemArr.push(item)
			item.shown(true);
		}
		
		public function remove(id:int) {
			for (var i:int=0;i<itemArr.length;i++) {
				if (itemArr[i].id==id) {
					removeItem(itemArr[i]);
					//itemArr[i].visible=false;
					itemArr.splice(i,1);
					break;
				}
			}
			if (selectedId==id) selectedId=Number.NaN;
		}

		private function removeItem(item:SelectorItem) {
			//clean up listeners
			item.removeEventListener(SelectorEvent.SELECTED,itemSelected);
			for (var i:int=0;i<listenerArr.length;i++) {
				item.removeEventListener(listenerArr[i].type,listenerArr[i].listener);
			}
		}
		
		public function clear() {
			for (var i:int=0;i<itemArr.length;i++) removeItem(itemArr[i]);
			itemArr=new Array();
			selectedId=Number.NaN;
		}
		
		//selection/communication functions
		
		//private function itemClicked(evt:MouseEvent) {
		//	dispatchEvent(evt);
		//}
		
		private function itemSelected(evt:SelectorEvent) {
			if (evt.id==selectedId) return;
			setSelected(evt.id)
			dispatchEvent(evt);
		}
		
		public function selectById(id:Number) {
			setSelected(id);			
		}
		
		private function setSelected(id:Number) {
			for (var i:uint=0;i<itemArr.length;i++) {
				if (itemArr[i].id==id) itemArr[i].select();
				else itemArr[i].deselect();
			}
			selectedId=id;
		}
		
		public function deselect() {
			for (var i:uint=0;i<itemArr.length;i++) itemArr[i].deselect();
			selectedId=Number.NaN;
		}
		
		public function getItemArray():Array {
			return(itemArr);
		}
		
		public function getItemById(id:Number):SelectorItem {
			var item:SelectorItem=null;
			for (var i:uint=0;i<itemArr.length;i++) if (itemArr[i].id==id) item=itemArr[i];
			return(item)
		}
		
		public function getSelectedItem():SelectorItem {
			return(getItemById(selectedId));
		}
		
		public function getSelectedId():int {
			return(selectedId);
		}
		
		public function isSelected():Boolean {
			return(!isNaN(selectedId));
		}
		
		public function addItemEventListener(evtType:String,listener:Function) {
			var i:int;
			for (i=0;i<listenerArr.length;i++) { //check if listener already exists
				if (listenerArr[i].type==evtType&&listenerArr[i].listener==listener) return;				
			}
			
			listenerArr.push({type:evtType,listener:listener});
			for (i=0;i<itemArr.length;i++) {
				itemArr[i].addEventListener(evtType,listener,false,0,true);
			}
		}
		
		public function removeItemEventListener(evtType:String,listener:Function) {
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
		
	}
	
}