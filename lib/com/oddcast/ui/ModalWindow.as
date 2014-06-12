/**
* @author Jonathan Achai
* @version 0.1
* 
* @usage
* This class's puprose is for opening modal windows (alerts, confirmations, etc.) -> this class should be extended see ModalAlertWindow
* 
* variables/properties:
* text - button caption
* disabled - toggles disabled state
* 
*/



package com.oddcast.ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	
	public class ModalWindow extends MovieClip
	{			
		public var _mcBtnClose:BaseButton;
		private var _uintBgEffectType:uint = 0;		
		private var _mcParentButton:MovieClip;
		private var _root:*;
		
		//event name constants
		public static var CLOSED:String="onClose";
		
		//constructor
		function ModalWindow()
		{
			this.addEventListener(Event.ADDED_TO_STAGE,init);
			_root = this.root;
		}
		
		public function close():void
		{
			applyEffect(false);
			this.parent.removeChild(_mcParentButton);
			_mcParentButton = null;
			trace("ModalWindow::close()");
			
			parent.removeChild(this);
			dispatchEvent(new MouseEvent(ModalWindow.CLOSED,true));
		}
		
		public function setRoot(o:*):void
		{
			_root = o;
		}
		
		public function setCloseButtonText(s:String):void
		{
			_mcBtnClose.text = s;
		}
		
		public function setBgEffect(effectType:uint):void
		{
			_uintBgEffectType = effectType;
		}
				
		
		public function centerIn(rect:Rectangle):void
		{		
			this.x = rect.x+rect.width/2 - this.width/2;
			this.y = rect.y+rect.height/2 - this.height/2;			
		}
		
		protected function init(evt:Event):void
		{												
			drawTransparentButtonOverParent();
			applyEffect(true);		
			//_mcBtnClose = getChildByName("closeBtn") as BaseButton;
			_mcBtnClose.addEventListener(MouseEvent.CLICK,closeClicked);
		}
		
		private function drawTransparentButtonOverParent():void
		{
			_mcParentButton = new MovieClip();
			_mcParentButton.graphics.beginFill(0xffffff,0);
			_mcParentButton.graphics.drawRect(0,0,parent.width,parent.height);
			_mcParentButton.graphics.endFill();			            
			_mcParentButton.addEventListener(MouseEvent.CLICK,parentClicked);
			trace("this.parent.name="+this.parent.name+", this.name="+this.name);
			var myParent:* = this.parent;
			var hadError:Boolean;
			try
			{
				myParent.rawChildren.addChild(_mcParentButton);
			}
			catch (e:Error) {
    			trace(e); // output: ArgumentError: Error #2024: An object may not be added as a child of itself.
    			hadError = true;
			}

			
			if (hadError)
			{
				myParent.addChild(_mcParentButton);
			}
			this.parent.swapChildren(_mcParentButton,this);
		}
		
		public function closeClicked(evt:MouseEvent):void
		{
			close();
		}
		
		private function parentClicked(evt:MouseEvent):void
		{
			
		}
		
		private function applyEffect(apply:Boolean):void
		{
			//blur brothers, then uncles, then grandparents' brothers, etc.
			recursiveApplyEffect(this,apply);
			
			
			/*
			var doc:DisplayObjectContainer = this.root as DisplayObjectContainer;
			for (var i:uint=0;i<doc.numChildren;++i)
			{
				var dObj:DisplayObject = doc.getChildAt(i);
				if (dObj.name!=this.name)
				{
						switch(_uintBgEffectType)
						{
							case 0:
								blurEffect(dObj,apply);
								break;
						}
				}
				
			}
			*/			
		}
		
		private function recursiveApplyEffect(in_do:*,apply:Boolean):void
		{				
				trace("ModalWindow::in_do.name="+in_do+", in_do.parent.name="+in_do.parent.name+", root.name="+root.name);
				if (in_do==in_do.parent || in_do.parent.name==null)
				{
					return;
				}
				var doc:DisplayObjectContainer = in_do.parent;
				for (var i:uint=0;i<doc.numChildren;++i)
				{
					var dObj:DisplayObject = doc.getChildAt(i);
					trace("ModalWindow::checking sibling "+dObj.name);
					if (dObj.name!=in_do.name)
					{
							
							switch(_uintBgEffectType)
							{
								case 0:
									blurEffect(dObj,apply);
									break;
							}
					}
					
				}
				recursiveApplyEffect(in_do.parent,apply);
				
		}
		
		private function blurEffect(dObj:DisplayObject,apply:Boolean):void
		{
			trace("ModalWindow::blurEffect on "+dObj.name+" ->"+apply);
			var filters:Array = new Array();
			if (apply)
			{				
				var blurX:Number = 15;
				var blurY:Number = 15;
				var filter:BitmapFilter = new BlurFilter(blurX,blurY,BitmapFilterQuality.HIGH);
				filters.push(filter);
			}
			dObj.filters = filters;						
		}
		
		
	}
	
}

/*
package {
    import flash.display.Sprite;
    import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.BlurFilter;

    public class BlurFilterExample extends Sprite {
        private var bgColor:uint = 0xFFCC00;
        private var size:uint    = 80;
        private var offset:uint  = 50;

        public function BlurFilterExample() {
            draw();
            var filter:BitmapFilter = getBitmapFilter();
            var myFilters:Array = new Array();
            myFilters.push(filter);
            filters = myFilters;
        }

        private function getBitmapFilter():BitmapFilter {
            var blurX:Number = 30;
            var blurY:Number = 30;
            return new BlurFilter(blurX, blurY, BitmapFilterQuality.HIGH);
        }

        private function draw():void {
            graphics.beginFill(bgColor);
            graphics.drawRect(offset, offset, size, size);
            graphics.endFill();
        }
    }
}

*/