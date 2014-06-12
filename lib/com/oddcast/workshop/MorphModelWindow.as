/*
 * Jon Achai 
 */

package com.oddcast.workshop
{
	import com.oddcast.event.ModelEvent;
	import com.oddcast.event.ScrollEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.ui.Slider;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	
	import workshop.panels.ModelPanel;

	public class MorphModelWindow extends MovieClip
	{
		public var _mcModelsPanel:ModelPanel;
		public var _mcBtnUpload:BaseButton;
		public var _mcSlider:Slider;
		public var _tfTitle:TextField;
		public var _mcPreview:MovieClip;
		
		private var _iIndex:int;	
		private var _host:WSModelStruct;
		private var _nMaxWeight:Number = 1;	
		private var _sModelListFilter:String = "";	
		private var _iSelectDefault:int;
		
		public function MorphModelWindow()
		{	
			trace("MorphModelWindow::MorphModelWindow");	
			_mcSlider.visible = false;							
		}
		
		public function init(defaultWeight:Number = 0.5):void
		{
			_mcSlider.percent = defaultWeight;
			_mcModelsPanel.addEventListener(Event.INIT,onModelPanelInit,false,0,true);
			_mcModelsPanel.addEventListener(ModelEvent.SELECT,modelSelected,false,0,true);
			_mcBtnUpload.addEventListener(MouseEvent.CLICK,uploadClicked,false,0,true);
			_mcSlider.addEventListener(ScrollEvent.SCROLL,sliderScrolled,false,0,true);
			_mcSlider.addEventListener(ScrollEvent.RELEASE,sliderChanged,false,0,true);
			_mcModelsPanel.loadModels(_sModelListFilter);
		}
		
		public function addModel(model:WSModelStruct):void
		{
			_mcModelsPanel.addModel(model);
		}
		
		public function selectModel(model:WSModelStruct):void
		{
			trace("MorphModelWindow::selectModel "+model.name);				
			_host = model;
			loadPreview();
			_mcModelsPanel.selectModel(model);						
		}
		
		private function loadPreview():void
		{
			trace("MorphModelWindow::loadPreview "+_host.name);		
			if (_host!=null)
			{
				var tempXML:XML = _host.charXml;
				var tempList:XMLList = tempXML.url;
				var item:XML;
				for each(item in tempList)
				{				
					if (item.@id=="photoface")
					{
						var loader:Loader = new Loader();
						var ctx:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
						//content
						var myPattern:RegExp = /autophoto/;  					 
						var str:String = item.@url
						str = str.replace(myPattern,"content");					
						//{
						trace("item.@url="+item.@url);
							var req:URLRequest = new URLRequest(str);
							loader.contentLoaderInfo.addEventListener(Event.INIT,previewLoaded);
							loader.load(req,ctx);
						//}
					}
				}
			}
		}
		
		private function previewLoaded(evt:Event):void
		{		
			trace("MorphModelWindow::previewLoaded "+_host.name);	
			if (_mcPreview.numChildren>0)
			{
				_mcPreview.removeChildAt(0);
			}
			var _do:DisplayObject = LoaderInfo(evt.target).content;
			var scaleBy:Number = 250/_do.height;
			_do.scaleX = _do.scaleY = 	scaleBy;													
			_mcPreview.addChild(_do);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function selectModelByIndex(i:int):void
		{
			_mcModelsPanel.selectModelById(i);
			_host = _mcModelsPanel.modelArr[i];
			loadPreview();		
		}
		
		public function getFirstModel():WSModelStruct
		{
			return _mcModelsPanel.modelArr[0];
		}
		
		public function hideScrollers():void
		{
			_mcModelsPanel.hideScrollers();
		}
		
		public function setModelsFilter(s:String):void
		{
			_sModelListFilter = s;
		}
		
		public function set uploadBtnVisible(b:Boolean):void
		{
			_mcBtnUpload.visible = b;
		}
		
		public function set title (s:String):void
		{
			_tfTitle.text = s;
		}
		
		public function set selectDefault (i:int):void
		{
			_iSelectDefault = i;
		}
		
		public function get selectDefault ():int
		{
			return _iSelectDefault;
		}
		
		public function set index (i:int):void
		{
			_iIndex = i;
		}
				
		
		public function get index():int
		{
			return _iIndex;
		}
		
		public function get model():WSModelStruct
		{
			return _host;
		}
		
		public function set maxWeight(n:Number):void // 0.0 - 1.0
		{
			_nMaxWeight = n; 
		}
		
		public function get maxWeight():Number
		{
			return _nMaxWeight;
		}
		
		public function get weight():Number
		{
			return _mcSlider.percent*_nMaxWeight;
		}
		
		public function get percent():Number
		{
			return _mcSlider.percent;
		}
		
		public function set percent(n:Number):void
		{
			_mcSlider.percent = n;
		}				
		
		private function onModelPanelInit(evt:Event):void
		{
			_mcModelsPanel.removeEventListener(Event.INIT,onModelPanelInit);//,false,0,true);
			_mcModelsPanel.openWin();
			dispatchEvent(evt);
			
			
		}
		
		private function modelSelected(evt:ModelEvent):void
		{
			
			trace("MorphModelWindow::modelSelected "+evt.model.id);
			_host = WSModelStruct(evt.model);
			dispatchEvent(new Event(Event.SELECT)); //select for model selected
			loadPreview(); 
		}
		
		private function uploadClicked(evt:MouseEvent):void
		{
			trace("MorphModelWindow::uploadClicked");
			dispatchEvent(new Event(Event.OPEN)); //open for initiating a autophoto process
		}
		
		private function sliderChanged(evt:ScrollEvent):void
		{
			trace("MorphModelWindow::sliderChanged "+evt.percent);
		}
		
		private function sliderScrolled(evt:ScrollEvent):void
		{
			trace("MorphModelWindow::sliderScrolled "+evt.percent);
		}
		
	}
}