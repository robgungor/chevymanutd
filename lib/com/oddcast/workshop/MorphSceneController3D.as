package com.oddcast.workshop
{
	import com.oddcast.host.api.API_Constant;
	import com.oddcast.host.api.EditLabel;
	import com.oddcast.host.api.morph.MorphMomPop;
	import com.oddcast.host.api.morph.MorphMomPopBaby;
	
	import flash.display.Sprite;
	import flash.events.Event;

	public class MorphSceneController3D extends SceneController3D
	{
		private var babyMorpher:MorphMomPopBaby;
		private var _mom:WSModelStruct;
		private var _pop:WSModelStruct;		
		private var _bFirstTime:Boolean = true;
		private var _nMomPercent:Number;
		
		public function MorphSceneController3D(in_player:Sprite)
		{
			super(in_player);
			
		}				
		
		public function setSmile(p:Number,time:int):void
		{
			if (hostMC.api != null)
			{
				hostMC.api.clearExpressionList();
				var _arrExpressions:Array = hostMC.api.getEditorList(API_Constant.EXPRESSION);
				for (var i:uint=0;i<_arrExpressions.length;++i)
				{
					//trace("MorphSceneController3D::setSmile "+_arrExpressions[i]);
					if ("ClosedSmile"==_arrExpressions[i])
					{
						var currTime:Number = hostMC.api.getAudioTime();
						trace("setExpression "+_arrExpressions[i]+", p="+p+", currTime="+currTime+",currTime+time="+(currTime+time) );
						hostMC.api.setExpression(_arrExpressions[i],p,currTime,currTime+time);
					}
				}
			}			
		}
		
		public function loadMorphBaby(pop:WSModelStruct,mom:WSModelStruct,baby:WSModelStruct,momWeight:Number = 0.5):void
		{
			
			if (_bFirstTime)
			{				
				hostMC.api.setEditValue(API_Constant.ADVANCED,  EditLabel.F_EYES_IRIS_SIZE, 0.4, 0);
				_bFirstTime = false;
			}
			
			if (babyMorpher==null)
			{
				babyMorpher = new MorphMomPopBaby(hostMC.api,momWeight,1.5);//initialize morpher
			}
			_nMomPercent = momWeight;
			_mom = mom;
			_pop = pop;
			hostMC.api.addEventListener("processingEnded",morphBabyBabyLoaded,false,0,true);
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED,"morphBaby"));
			trace("loadMorphBaby momWeight="+momWeight);
			
			babyMorpher.setBaby(baby.charXml);
			//babyMorpher.setBaby("<fgchar><url id=\"photoface\" url=\"http://content.dev.oddcast.com/content2/customhost/3dtemp/babymaker/babies/95090a11463f9cb571f75a1934fda03b-PhotoFit.jpg\"/><url id=\"fgfile\" url=\"http://content.dev.oddcast.com/content2/customhost/3dtemp/babymaker/babies/95090a11463f9cb571f75a1934fda03b-PhotoFit.fg\"/></fgchar>");			
		}
		
		public function setMomPercent(p:Number):void
		{
			trace("setMomWeighting "+p);
			if (babyMorpher!=null)
			{
				babyMorpher.setMomWeighting(p);
			}
			_nMomPercent = p
		}
		
		public function setMom(model:WSModelStruct):void
		{
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED,"changeParent"));
			hostMC.api.addEventListener("processingEnded",parentLoaded,false,0,true);
			babyMorpher.setParent(MorphMomPop.MOM,model.charXml);		
		}
		
		public function setPop(model:WSModelStruct):void
		{
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED,"changeParent"));
			hostMC.api.addEventListener("processingEnded",parentLoaded,false,0,true);
			babyMorpher.setParent(MorphMomPop.POP,model.charXml);		
		}
		
		private function parentLoaded(evt:Event):void
		{
			hostMC.api.removeEventListener("processingEnded",parentLoaded);
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,"changeParent"));
		}
		
		private function morphBabyBabyLoaded(evt:Event):void
		{
			trace("morphBabyBabyLoaded "+evt);
			hostMC.api.removeEventListener("processingEnded",morphBabyBabyLoaded);
			hostMC.api.addEventListener("processingEnded",morphBabyMomLoaded,false,0,true);
			babyMorpher.setParent(MorphMomPop.MOM,_mom.charXml);
		}
		
		private function morphBabyMomLoaded(evt:Event):void
		{
			trace("morphBabyMomLoaded "+evt);
			hostMC.api.removeEventListener("processingEnded",morphBabyMomLoaded);
			hostMC.api.addEventListener("processingEnded",morphBabyPopLoaded,false,0,true);
			babyMorpher.setParent(MorphMomPop.POP,_pop.charXml);
		}
		
		private function morphBabyPopLoaded(evt:Event):void
		{
			trace("morphBabyPopLoaded "+evt);
			hostMC.api.removeEventListener("processingEnded",morphBabyPopLoaded);
			setMomPercent(_nMomPercent);
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,"morphBaby"));
		}
		
		
		
		public function getEditorAPI():*
		{
			return hostMC.api;
		}
		
	}
}