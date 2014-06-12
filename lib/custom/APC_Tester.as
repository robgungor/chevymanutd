/*
* ...
* @author Jonathan Achai
* @version 0.1
* 
* This is a sample on how to use the apc component 
*/

package
{
	
	import fl.controls.TextArea;
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Transform;
	import flash.utils.Timer;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.events.TextEvent;
	import flash.system.Security;	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import fl.controls.Button;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;		
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.MouseEvent;
	import flash.display.LoaderInfo;
	import flash.text.TextField;		
	
	public class APC_Tester extends MovieClip
	{
		
		public var _apc:Object;
		private var loader:Loader;
		private var req:URLRequest;
		private var context:LoaderContext;
		private var _rectStage:Rectangle;
		
		//flags indicating which type of task should the apc perform
		private var _bSubmitWithPoints:Boolean; //if true call submiWithPoints()
		private var _bSubmitWithMask:Boolean; //if true call submitWithMask();
		//flag indicating if we're in the mask step (e.g. act differently on events which happen on the background - processing) 
		private var _bInMaskStep:Boolean;
		
		//on stage buttons
		public var btnSelect:Button;
		public var btnUpload:Button;
		public var btnSendUrl:Button;
		
		public var _mcWebcamHolder:MovieClip;
		public var btnWebcamInit:Button;
		public var btnWebcamCapture:Button;
		public var btnUploadWebcam:Button;
		public var btnWebcamClear:Button;
		
		public var btnZoomIn:Button;
		public var btnZoomOut:Button;
		public var btnRotateLeft:Button;
		public var btnRotateRight:Button;
		public var btnReset:Button;
		public var btnMoveLeft:Button;
		public var btnMoveRight:Button;
		public var btnMoveUp:Button;
		public var btnMoveDown:Button;
		public var btnSubmit:Button;
		public var btnSubmitPoints:Button;
		public var btnUseAnother:Button;
		public var btnResetMask:Button;
		public var btnFaceZoomIn:Button;
		public var btnFaceZoomOut:Button;
		public var btnRedoMask:Button;
		//on stage text fields
		public var _tfFilename:TextField;
		public var _tfUrl:TextField;
		public var _tfError:TextField;
		public var _tfLog:TextArea;
		public var _tfOverallProcessing:TextField
		//on stage MC holders
		public var _mcAPCHolder:MovieClip;
		public var _mcLoading:MovieClip;
		public var _mcLoadAPC:MovieClip;
		public var _mcFacesHolder:MovieClip;
		public var btnTraceRGB:Button;
		
		function APC_Tester()
		{
			Security.allowDomain("autophoto.oddcast.com", "autophoto-vd.oddcast.com","autophoto-vs.oddcast.com");
			Security.allowDomain("content.oddcast.com", "content-vd.oddcast.com", "content-vs.oddcast.com");
			Security.allowDomain('*');
			
			this.stop();
			this.loaderInfo.addEventListener(Event.COMPLETE, appLoaded);
			this.loaderInfo.addEventListener(ProgressEvent.PROGRESS, appLoadInProgress);
			_mcLoading.addEventListener(MouseEvent.CLICK,loaderClicked); //make the loader modal										
			_mcAPCHolder.visible = false; //hide APC until needed
			_mcWebcamHolder.visible = false; //hide webcam holder until needed
			this.addEventListener(Event.ADDED,objectAdded);
			_rectStage = new Rectangle(0, 0, this.width, this.height);	
			//_tfLog.addEventListener(Event.CHANGE, tfChanged);		
			_tfOverallProcessing.text = "0";
			this.addEventListener(Event.ADDED, addedToStage);
			
		}										
		
		//loading listeners
		//*********************************************************************
		private function appLoaded(evt:Event):void
		{	
			
			_mcLoadAPC.btnLoadAPC.addEventListener(MouseEvent.CLICK, loadAPC);			
		}
		
		private function loadAPC(evt:MouseEvent):void
		{
			trace("appLoaded()");
			loader = new Loader();			
			var autophotoUrl:String;
			var autophotoPhpUrl:String;
			var autophotoPhpAccUrl:String;
			if (int(_mcLoadAPC._tfParamsLive.text) == 1)
			{
				autophotoUrl = 'http://content.oddcast.com/autophoto/';// APC.swf'; //or use imageUrl
				autophotoPhpUrl = 'http://autophoto.oddcast.com/';// APC.swf'; //or use imageUrl
				autophotoPhpAccUrl = 'http://autophoto-d.oddcast.com/';// APC.swf'; //or use imageUrl
			}
			else if (int(_mcLoadAPC._tfParamsLive.text) == 2)
			{
				autophotoUrl = 'http://content-vs.oddcast.com/autophoto/';// APC.swf'; //or use imageUrl
				autophotoPhpUrl = 'http://autophoto-vs.oddcast.com/';// APC.swf'; //or use imageUrl
				autophotoPhpAccUrl = 'http://autophoto-d-vs.oddcast.com/';// APC.swf'; //or use imageUrl
			}
			else
			{
				autophotoUrl = 'http://content-vd.oddcast.com/autophoto/';// APC.swf'; //or use imageUrl
				autophotoPhpUrl = 'http://autophoto-vd.oddcast.com/';// APC.swf'; //or use imageUrl
				autophotoPhpAccUrl = 'http://autophoto-d-vd.oddcast.com/';// APC.swf'; //or use imageUrl
				
			}
			autophotoUrl += _mcLoadAPC._tfParamsSWF.text;
			autophotoUrl += "?appId=" + _mcLoadAPC._tfParamsAppId.text;
			autophotoUrl += "&dragOffCenter=" + _mcLoadAPC._tfParamsDragOffCenter.text;
			
			autophotoUrl += "&maskingStep=" + _mcLoadAPC._tfParamsMaskingStep.text;
			autophotoUrl += "&maskingStepMode=" + _mcLoadAPC._tfParamsMaskingStepMode.text;
			autophotoUrl += "&threshold=" + _mcLoadAPC._tfParamsThreshold.text;
			autophotoUrl += "&ears=" + _mcLoadAPC._tfParamsEars.text;
			autophotoUrl += "&erVer=" + _mcLoadAPC._tfParamsErrorVer.text;
			autophotoUrl += "&debugManualPlacementSnapshot=" + _mcLoadAPC._tfParamsDebugPoints.text;
			
			autophotoUrl += "&poll=" + _mcLoadAPC._tfParamsPollingInt.text;
			autophotoUrl += "&pollTimeout=" + _mcLoadAPC._tfParamsPollTimeout.text;
			autophotoUrl += "&pollDimMulti=" + _mcLoadAPC._tfParamsPollDimMulti.text;
			autophotoUrl += "&pollDimMax=" + _mcLoadAPC._tfParamsPollDimMax.text;
			autophotoUrl += "&ff=" +_mcLoadAPC._tfParamsAutoCrop.text;
			autophotoUrl += "&apad=" + autophotoPhpAccUrl;
			autophotoUrl += "&apd=" + autophotoPhpUrl;
			
			autophotoUrl += "&hsc=" + _mcLoadAPC._tfParamsHotspotColor.text;
			autophotoUrl += "&forceface=" + _mcLoadAPC._tfParamsForceFace.text;
			autophotoUrl += "&forcefacefill=" + _mcLoadAPC._tfParamsForceFaceFill.text;			
			autophotoUrl += "&faceRectMulti=" + _mcLoadAPC._tfParamsFaceRectMulti.text;		
			autophotoUrl += "&hotspots=" + _mcLoadAPC._tfParamsHotspots.text;
			
			
			if (_mcLoadAPC._tfParamsImageUrl.text.length > 0)
			{
				autophotoUrl += "&imageUrl=" + _mcLoadAPC._tfParamsImageUrl.text;
				this.gotoAndStop(2);
			}
			else			
			{
				btnSelect.addEventListener(MouseEvent.CLICK,selectFile);
				btnUpload.addEventListener(MouseEvent.CLICK, uploadFile);	
				btnSendUrl.addEventListener(MouseEvent.CLICK, uploadUrl);
				btnWebcamInit.addEventListener(MouseEvent.CLICK, webcamInit);
				btnWebcamCapture.addEventListener(MouseEvent.CLICK, webcamCapture);
				btnUploadWebcam.addEventListener(MouseEvent.CLICK, uploadWebcam);
				btnWebcamClear.addEventListener(MouseEvent.CLICK, webcamClear);
			}
			req = new URLRequest(autophotoUrl+"&w=500&h=533&output=1&pd=www.workboy.com");			
			context = new LoaderContext();			
			context.applicationDomain=new ApplicationDomain(ApplicationDomain.currentDomain);
			loader.load(req,context);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAPCLoaded);																
			_mcLoadAPC.visible = false;
			
		}
		
		private function appLoadInProgress(evt:ProgressEvent):void
		{
			showLoading("Initializing...",Math.round((evt.bytesLoaded/evt.bytesTotal)*100));
		}
		
		private function onAPCLoaded(e:Event):void 
		{
			hideLoading();
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;			
			_apc = loaderInfo.content;
			_apc.addEventListener("onDone", onProcessingDone);			
			_apc.addEventListener("onError",onError);	
			_apc.addEventListener("onRedoPosition",onRedoPosition);	
			_apc.addEventListener("processingProgress", onProcessing);
			_apc.addEventListener("overallProcessingProgress",onOverallProcessing);
			_apc.addEventListener("onPoints", onPointsReady);
			_apc.addEventListener("onMask", onMaskStep);
			_apc.addEventListener("onMaskReady", onMaskReady);			
			_apc.addEventListener("onFGReady", onFGReady);						
			_apc.addEventListener("processingImageReady", onCroppedImageReady);
			_apc.addEventListener("photoFileDownloaded",onFinishDownload);
			_apc.addEventListener("photoFileLoaded",onFinishUpload);
			_apc.addEventListener("photoFileSelected",onFileSelected);			
			_apc.addEventListener("photoUploadError",onFileUploadError);
			_apc.addEventListener("onPointPressed",onPointPressed);
			_apc.addEventListener("onPointReleased", onPointReleased);
			_apc.addEventListener("onAPCAutoCropped", onAutoCropped);
			_apc.addEventListener("onAPCReady", onAPCReady);
			
			
		} 
		
		
		function onAPCReady(evt:Object):void
		{
			_tfLog.appendText("onAPCReady\n");	
			_apc.setMaskBlurRadius(Number(_mcLoadAPC._tfParamsBlurRadius.text));
			_apc.setPointPlacementIcon(ApplicationDomain.currentDomain, "AnchorPointSymbol");
			if (ApplicationDomain.currentDomain.hasDefinition(_mcLoadAPC._tfParamsHSClass.text))
			{
				_apc.setHotSpotIcon(ApplicationDomain.currentDomain, _mcLoadAPC._tfParamsHSClass.text);
			}
			//function is not present in older APC
			try
			{
				_apc.setMaskPointIcon(ApplicationDomain.currentDomain, "MaskPointSymbol");
			}
			catch (e:Error)
			{
				trace("APC doesn't support masking");
			}
			_apc.setPointPlacementColor("FSDKP_NOSE_TIP", 0xff0000);
			_apc.setUploadLimits(10, 6144) //file sizes bet 10k - 5MB
			trace("APC_Tester::"+_mcLoadAPC._tfParamsDynamicPoints.text+", int(_mcLoadAPC._tfParamsDynamicPoints.text)="+int(_mcLoadAPC._tfParamsDynamicPoints.text));
			_apc.setMaskDynamicPoints(int(_mcLoadAPC._tfParamsDynamicPoints.text)==1);
			_apc.setMaskOutline(int(_mcLoadAPC._tfParamsMaskOutline.text)==1, int(_mcLoadAPC._tfParamsMaskOutlineColor.text));
			_apc.hideCursorForDragging(int(_mcLoadAPC._tfParamsHideCursor.text) == 1);
			_apc.zoomToFaceForPointsPlacement(int(_mcLoadAPC._tfParamsZoomFace.text) == 1);
			//_apc.setAutoCroppingActive(int(_mcLoadAPC._tfParamsAutoCrop.text) == 1);
			_apc.setSkipLuxand(int(_mcLoadAPC._tfParamsSkipLux.text) == 1);//_tfParamsSkipLux
			
			
			//customize the mask graphic (masking step only)
			/*
			var gr:Object = new Object();
			gr.lineThickness = 1;
			gr.lineColor = 0xff0000;
			gr.lineAlpha = 1;
			gr.fillType = "solid";
			gr.fillColor = 0x00ff00;
			gr.fillAlpha = 0.3;			
			gr.outsideImageAlpha = 0.2;
			_apc.setMaskGraphics(gr);						
			*/
			_mcAPCHolder.addChild(loader);//DisplayObject(_apc));		
		}
		
		
		//listeners
		//********************************************************************************		
		
		//autophoto listeners
		
		
		//triggered when the autophoto process has finished
		private function onProcessingDone(evt:Object):void
		{
			this.gotoAndStop(5);
			hideLoading();
			_mcAPCHolder.visible = false;			
			_tfLog.appendText("onProcessingDone ALL DONE sessionId=" + _apc.getSessionId() + "\n");	
			tfChanged();
			trace("onProcessingDone " + _apc.getSessionId());	
			_apc.getCharXML(charXmlReady);						
		}
		
		protected function charXmlReady(_xml:XML):void
		{
			_tfLog.appendText("charXmlReady xml=" + _xml.toString() + "\n");	
		}
		
		private function onFinishUpload(evt:Object):void
		{
			trace("APCTester:: onFinishUpload");
			_tfLog.appendText("APCTester:: onFinishUpload" + "\n");
			tfChanged();
		}
		
		private function onFinishDownload(evt:Object):void
		{
			trace("APCTester:: onFinishDownload");
			_tfLog.appendText("APCTester:: onFinishDownload" + "\n");
			tfChanged();
			hideLoading();			
			initSubmitListeners();			
			_mcAPCHolder.visible = true;
		}
		
		private function onFileUploadError(evt:Object):void
		{
			var errObj:Object = evt.data;
			trace("onFileUploadError error #"+errObj.id+": "+errObj.msg);
			_tfLog.appendText("onFileUploadError error #" + errObj.id + ": " + errObj.msg + "\n");	
			tfChanged();
			hideLoading();			
			this.gotoAndStop(1);
		}
		
		private function onFileSelected(evt:Object):void
		{			
			_tfFilename.text = String(evt.data);
		}						
		
		private function onError(evt:Object):void
		{
			var errObj:Object = evt.data;
			trace("error #" + errObj.id + ": " + errObj.msg);
			_tfLog.appendText("error #" + errObj.id + ": " + errObj.msg + "\n");	
			tfChanged();
			hideLoading();
			if (errObj.id == "apc11")
			{
				onMaskStep(null)
			}
			else if (errObj.id == "apc3.0") //points improperly placed bring back points position step
			{
				_bSubmitWithMask = false;
				_bInMaskStep = false;
				onPointsReady(null);
			}
			
		}
		
		private function onRedoPosition(evt:Object):void
		{
			onError(evt);			
		}		
		
		private function onCroppedImageReady(evt:Object):void
		{
			_tfLog.appendText("Cropped Image is ready " + evt.data.image + "\n");	
			tfChanged();
			trace("onCroppedImageReady "+evt.data.image);
		}
		
		private function onProcessing(evt:Object):void
		{
			var processingObj:Object = evt.data;
			trace("onProcessing percent=" + processingObj.percent + ", msg=" + processingObj.msg)
			_tfLog.appendText("onProcessing percent=" + processingObj.percent + ", msg=" + processingObj.msg + "\n");
			tfChanged();
			
		}
		
		private function onOverallProcessing(evt:Object):void
		{
			var processingObj:Object = evt.data;
			trace("onOverallProcessing percent=" + processingObj.percent + ", msg=" + processingObj.msg)
			_tfLog.appendText("onOverallProcessing percent=" + processingObj.percent + ", msg=" + processingObj.msg + "\n");
			_tfLog.appendText("polling XML=" + _apc.getLastPollingXML().toXMLString() + "\n");
			_tfOverallProcessing.text = processingObj.percent
			tfChanged();
			
		}
		
		
		private function onPointPressed(evt:Object):void
		{
			trace("onPointPressed " + evt.data);
			_tfLog.appendText("onPointPressed " + evt.data + "\n");
			tfChanged();
		}
		
		private function onPointReleased(evt:Object):void
		{
			trace("onPointReleased " + evt.data);
			_tfLog.appendText("onPointReleased " + evt.data + "\n");
			tfChanged();
		}
		
		
		private function onPointsReady(evt:Object):void
		{
			btnSubmit.enabled = true;
			hideLoading();
			trace("onPointsReady enable confirm/submit");
			_tfLog.appendText("onPointsReady enable confirm/submit" + "\n");
			tfChanged();
			_bSubmitWithPoints = true;
			this.gotoAndStop(3);			
		}
		
		
		private function onMaskStep(evt:Object):void
		{
			btnSubmit.enabled = true;
			_bInMaskStep = true;
			hideLoading();
			trace("onMaskPoints enable submit mask");
			_tfLog.appendText("onMaskPoints enable submit mask" + "\n");
			tfChanged();
			_bSubmitWithMask = true;		
			this.gotoAndStop(4);	
			
			
		}
		
		
		
		private function onResetClicked(evt:MouseEvent):void
		{
			trace("onResetClicked");
			_apc.resetMask();
		}
		
		private function onFGReady(evt:Object)
		{			
			btnSubmit.enabled = true;
			_tfLog.appendText("onFGReady\n");	
			tfChanged();
			trace("onFGReady ");		
		}
		
		private function onMaskReady(evt:Object)
		{		
			btnSubmit.enabled = true;
			_bInMaskStep = false;
			_tfLog.appendText("onMaskReady\n");	
			tfChanged();
			trace("onMaskReady ");		
		}
		
		//babymaker custom listeners for storing data
		
		//data was saved successfully - you may take the new user Id
		/*
		private function userDataStored(evt:Event):void
		{
		trace("DataStored. UserId=" + DataStore(evt.target).getUserId());
		_tfLog.appendText("DataStored. UserId=" + DataStore(evt.target).getUserId()+"\n");	
		tfChanged();
		}
		
		
		//data couldn't be saved see message for more details
		private function userDataStoreError(evt:ErrorEvent):void
		{
		trace("Data Store failed :" + evt.text);
		_tfLog.appendText("Data Store failed :" + evt.text+"\n");	
		tfChanged();
		}									
		*/
		//mouse listeners
		
		private function loaderClicked(evt:MouseEvent):void{} //stub
		
		private function uploadFile(evt:MouseEvent):void
		{			
			if (_apc.uploadFile())
			{
				this.gotoAndStop(2);
			}									
		}
		
		private function uploadUrl(evt:MouseEvent):void
		{
			_apc.uploadImageUrl(_tfUrl.text);
			this.gotoAndStop(2);
		}
		
		private function useAnotherPhotoClick(evt:MouseEvent):void
		{
			
			_bSubmitWithPoints = false;
			_bSubmitWithMask = false;
			_bInMaskStep = false;
			_apc.restart();
			_mcAPCHolder.visible = false;	
			_tfOverallProcessing.text = "0";
			this.gotoAndStop(1);					
			
		}
		
		private function reset(evt:MouseEvent):void
		{
			_apc.reset();						
		}
		
		private function zoomIn(evt:MouseEvent):void
		{
			_apc.startZooming(10);
		}
		
		private function stopZoom(evt:MouseEvent):void
		{
			_apc.stopZooming();
		}
		
		private function stopRotate(evt:MouseEvent):void
		{
			_apc.stopRotating();
		}
		
		private function zoomOut(evt:MouseEvent):void
		{
			_apc.startZooming(-10);
		}
		
		private function rotateLeft(evt:*):void
		{
			_apc.startRotating(-2);
		}
		
		private function rotateRight(evt:*):void
		{
			_apc.startRotating(2);
		}
		
		private function moveLeft(evt:MouseEvent):void
		{
			_apc.startPanning(-20)
			//	_apc.pan(-20);
		}
		private function moveRight(evt:MouseEvent):void
		{
			_apc.startPanning(20)
			//	_apc.pan(20);
		}
		private function moveUp(evt:MouseEvent):void
		{
			_apc.startPanning(-20,true)
			//	_apc.pan(-20,true);
		}
		private function moveDown(evt:MouseEvent):void
		{
			_apc.startPanning(20,true)
			//	_apc.pan(20,true);
		}
		private function stopMove(evt:MouseEvent):void
		{
			_apc.stopPanning();
		}
		
		private function onAutoCropped(evt:Object):void
		{
			
			//var bmpArr:Array = _apc.getFaces();			
			btnSubmit.enabled = false;// bmpArr.length > 1 || bmpArr.length == 0;
			/*
			for (var i:int = 0; i < bmpArr.length;++i)
			{
			var sprt:Sprite = new Sprite();
			sprt.name = String(i);
			var scale:Number = _mcFacesHolder.height / BitmapData(bmpArr[i]).height / 2;
			var mtrx:Matrix = new Matrix();
			mtrx.scale(scale, scale);
			trace("onAutoCropped scale=" + scale);
			var smallBMD:BitmapData = new BitmapData(BitmapData(bmpArr[i]).width * scale, BitmapData(bmpArr[i]).height * scale);
			smallBMD.draw(BitmapData(bmpArr[i]), mtrx, null, null, null, true);
			var bmp:Bitmap = new Bitmap(smallBMD, PixelSnapping.NEVER, true);				
			sprt.addChild(bmp);				
			sprt.x = i * bmp.width;
			
			_mcFacesHolder.addChild(sprt);
			}
			_mcFacesHolder.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
			{
			_apc.autoPositionByFaceFinder(int(Sprite(evt.target).name));
			});
			*/
		}
		
		private function submitClicked(evt:MouseEvent):void
		{
			trace("_bSubmitWithPoints=" + _bSubmitWithPoints + " _bSubmitWithMask=" + _bSubmitWithMask);
			if (_bSubmitWithPoints && !_bSubmitWithMask)
			{
				//_bSubmitWithPoints = false;
				_apc.submitWithPoints();
			}
			else if (_bSubmitWithMask)
			{
				hideLoading(true);
				_bSubmitWithMask = false;
				_apc.submitMask();
				_bInMaskStep = false;
				
			}
			else
			{
				_apc.submit();			
			}
		}	
		//other event listeners
		private function objectAdded(evt:Event):void
		{
			switch (evt.target.name)
			{
				case "btnSelect":
					btnSelect = getChildByName("btnSelect") as Button
					btnSelect.addEventListener(MouseEvent.CLICK,selectFile);
					break;
				case "btnUpload":
					btnUpload = getChildByName("btnUpload") as Button
					btnUpload.addEventListener(MouseEvent.CLICK,uploadFile);
					break;					
				case "btnSendUrl":
					btnSendUrl = getChildByName("btnSendUrl") as Button
					btnSendUrl.addEventListener(MouseEvent.CLICK,uploadUrl);
					break;
				case "btnWebcamInit":
					btnWebcamInit = getChildByName("btnWebcamInit") as Button
					btnWebcamInit.addEventListener(MouseEvent.CLICK, webcamInit);
					break;
				case "btnUploadWebcam":
					btnUploadWebcam = getChildByName("btnUploadWebcam") as Button
					btnUploadWebcam.addEventListener(MouseEvent.CLICK, uploadWebcam);
					break;
				case "btnWebcamCapture":
					btnWebcamCapture = getChildByName("btnWebcamCapture") as Button
					btnWebcamCapture.addEventListener(MouseEvent.CLICK, webcamCapture);
					break;
				case "btnWebcamClear":
					btnWebcamClear = getChildByName("btnWebcamClear") as Button
					btnWebcamClear.addEventListener(MouseEvent.CLICK, webcamClear);
					break;					
			}			
		}		
		
		//utility functions
		//***************************************************
		
		private function showLoading(msg:String,percent:int):void
		{
			if (!_mcLoading.visible)
			{
				_mcLoading.visible = true;
			}
			_mcLoading.gotoAndStop(percent>0?percent:1);
			TextField(_mcLoading.tf_message).text = msg;
			TextField(_mcLoading.tf_percent).text = percent+"%";
		}
		
		private function hideLoading(unhide:Boolean = false):void
		{
			_mcLoading.visible = unhide;			
		}
		
		private function selectFile(evt:MouseEvent):void
		{
			_apc.browseFileSystem();
		}
		
		private function webcamInit(evt:MouseEvent):void
		{
			trace("webcamInit");
			_apc.webcamInit(_mcWebcamHolder, 500, 533);
			_mcWebcamHolder.visible = true;						
		}
		
		private function webcamCapture(evt:MouseEvent):void
		{
			trace("webcamCapture");
			_apc.webcamCapture();
		}
		
		private function webcamClear(evt:MouseEvent):void
		{
			trace("webcamClear");
			_apc.webcamClear();
		}
		
		private function uploadWebcam(evt:MouseEvent):void
		{
			trace("uploadWebcam");
			_apc.webcamUpload();
			_apc.webcamClose();
			_mcWebcamHolder.visible = false;
			this.gotoAndStop(2);
		}
		
		//initializers
		//***********************************************************************
		
		private function addedToStage(evt:Event):void
		{
			switch (evt.target.name)
			{
				case "btnZoomIn":
					btnZoomIn = Button(evt.target);
					btnZoomIn.addEventListener(MouseEvent.MOUSE_DOWN,zoomIn);
					btnZoomIn.addEventListener(MouseEvent.MOUSE_UP,stopZoom);
					break;
				case "btnZoomOut":
					btnZoomOut = Button(evt.target);
					btnZoomOut.addEventListener(MouseEvent.MOUSE_DOWN,zoomOut);
					btnZoomOut.addEventListener(MouseEvent.MOUSE_UP,stopZoom);
					break;
				case "btnRotateLeft":
					btnRotateLeft = Button(evt.target);
					btnRotateLeft.addEventListener(MouseEvent.MOUSE_DOWN, rotateLeft);
					btnRotateLeft.addEventListener(MouseEvent.MOUSE_UP,stopRotate);
					break;
				case "btnRotateRight":
					btnRotateRight = Button(evt.target);
					btnRotateRight.addEventListener(MouseEvent.MOUSE_DOWN, rotateRight);
					btnRotateRight.addEventListener(MouseEvent.MOUSE_UP,stopRotate);
					break;
				case "btnReset":
					btnReset =Button(evt.target);
					btnReset.addEventListener(MouseEvent.CLICK,reset);
					break;
				case "btnMoveLeft":
					btnMoveLeft = Button(evt.target);
					btnMoveLeft.addEventListener(MouseEvent.MOUSE_DOWN,moveLeft);
					btnMoveLeft.addEventListener(MouseEvent.MOUSE_UP,stopMove);
					break;
				case "btnMoveRight":
					btnMoveRight = Button(evt.target);
					btnMoveRight.addEventListener(MouseEvent.MOUSE_DOWN,moveRight);
					btnMoveRight.addEventListener(MouseEvent.MOUSE_UP, stopMove);
					break;
				case "btnMoveUp":
					btnMoveUp = Button(evt.target);
					btnMoveUp.addEventListener(MouseEvent.MOUSE_DOWN,moveUp);
					btnMoveUp.addEventListener(MouseEvent.MOUSE_UP,stopMove);
					break;
				case "btnMoveDown":
					btnMoveDown = Button(evt.target);
					btnMoveDown.addEventListener(MouseEvent.MOUSE_DOWN,moveDown);
					btnMoveDown.addEventListener(MouseEvent.MOUSE_UP, stopMove);
					break;
				case "btnFaceZoomIn":
					btnFaceZoomIn = Button(evt.target);
					btnFaceZoomIn.addEventListener(MouseEvent.CLICK, faceZoomIn);
					break;
				case "btnFaceZoomOut":
					btnFaceZoomOut = Button(evt.target);
					btnFaceZoomOut.addEventListener(MouseEvent.CLICK, faceZoomOut);
					break;
				case "btnRedoMask":
					btnRedoMask = Button(evt.target);
					btnRedoMask.addEventListener(MouseEvent.CLICK, redoMask);
					break;
				case "btnResetMask":
					btnResetMask = Button(evt.target);
					btnResetMask.addEventListener(MouseEvent.CLICK, onResetClicked);
					break;
			}
		}				
		
		private function redoMask(evt:MouseEvent):void
		{
			gotoAndStop(4);
			_bSubmitWithMask = true;
			_mcAPCHolder.visible = true;
			_apc.enterPostProcessingMaskStep();
		}
		
		private function faceZoomIn(evt:MouseEvent):void
		{
			_apc.zoomInFace();
		}
		
		private function faceZoomOut(evt:MouseEvent):void
		{
			_apc.zoomOutFace();
		}
		
		private function initSubmitListeners():void
		{
			btnSubmit.addEventListener(MouseEvent.CLICK,submitClicked);
			btnUseAnother.addEventListener(MouseEvent.CLICK,useAnotherPhotoClick);
			btnTraceRGB.addEventListener(MouseEvent.CLICK,traceRGBClicke);
			
		}				
		
		private function traceRGBClicke(evt:MouseEvent):void
		{
			var res:Array = _apc.getFaceRGB();
			_tfLog.appendText("getFaceRGB response:");	
			if (res!=null)
			{
				
				for (var i:int=0; i<res.length;++i)
				{
					trace(i+"->"+int(res[i]).toString(16));
					_tfLog.appendText(i+"->"+int(res[i]).toString(16));					
				}
			}
			else
			{
				_tfLog.appendText("getFaceRGB returned null");	
			}
			tfChanged();
		}
		
		private function tfChanged():void
		{			
			_tfLog.verticalScrollPosition = _tfLog.	maxVerticalScrollPosition;			
		}
		
	}
	
}