package com.oddcast.workshop.fb3d 
{
	import com.oddcast.event.EventDescription;
	import com.oddcast.event.FB3dControllerEvent;
	import com.oddcast.host.api.fullbody.IHeadPlugin;
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	import com.oddcast.utils.ByteArray_Uploader;
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.workshop.fb3d.dataStructures.AnimationData;
	import com.oddcast.workshop.fb3d.dataStructures.AnimationListData;
	import com.oddcast.workshop.fb3d.dataStructures.CategoryData;
	import com.oddcast.workshop.fb3d.dataStructures.ClickedAccessoryData;
	import com.oddcast.workshop.fb3d.dataStructures.ColorableListData;
	import com.oddcast.workshop.fb3d.dataStructures.CommandData;
	import com.oddcast.workshop.fb3d.dataStructures.DecalConfigurationData;
	import com.oddcast.workshop.fb3d.dataStructures.DecalConfigurationListData;
	import com.oddcast.workshop.fb3d.dataStructures.FBModelData;
	import com.oddcast.workshop.fb3d.dataStructures.FBModelListData;
	import com.oddcast.workshop.fb3d.dataStructures.MaterialConfigurationData;
	import com.oddcast.workshop.fb3d.dataStructures.MaterialConfigurationListData;
	import com.oddcast.workshop.fb3d.dataStructures.PresetData;
	import com.oddcast.workshop.fb3d.dataStructures.PresetListData;
	import com.oddcast.workshop.fb3d.playback.AudioPlayback;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Vector3D;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	
	
	/**
	 * ...
	 * @author Jonathan Achai
	 */
	public class FB3dController extends EventDispatcher
	{					
		private var _iPresetId:int = 0;
		//private var _bInAvatarMode:Boolean;		
		//private var _xmlAvatarConfig:XML;						
		private var _currentDecalCategory:String;
		private var _currentDecalConfig:IDecalConfiguration;
		private var _bChangedSinceLastSave:Boolean = true;
		
		private var _dataProvider:FB3dDBContentDataProvider;					
		private var _accessorySetWrapper:FB3dAccessorySetWrapper;				
		private var _sprtHolder:Sprite;	
		private var _sCacheBaseUrl:String;
		private var _sPackageUrl:String;		
		protected var _aniCurrent:IAnimationProxy;	
		
		public var audioPlayback:AudioPlayback;
		
		
		public function FB3dController() 
		{
			//DBContentDataProviderRead.API_ZIP_RESPONSE = true;
			audioPlayback = new AudioPlayback(
				function(
					url:String, 
					triggerAudio:Boolean,
					offset:Number,
					finishedLoadingCallback:Function=null, // Function<void(Vector.<ITalkChannel>)> 
					finishedPlayingCallback:Function=null, // Function<void()>
					failedFn:Function=null,
					progressedFn:Function=null):void
				{
					_accessorySetWrapper.loadSoundAndPlayVisemeOnAllAvailableMorphDeformers(url, triggerAudio, offset, finishedLoadingCallback, finishedPlayingCallback, failedFn, progressedFn);
				});	
		}
		
		/**
		 * Initializes the FB3dController. This includes loading the engine, setting up the 3d environment and dispatching the ENGINE_LOADED and ENGINE_LOAD_PROGRESS events
		 * @param   domain - the application domain in which the engine will load into		 
		 * @param	engineUrl - absolute url of the engine
		 * @param	apiUrl - absolute url of the fb3d api
		 * @param	contentUrl - base url for the fb3d content
		 * @param	holder - Sprite to contain the fb3d scene
		 */
		public function init(domain:ApplicationDomain, engineUrl:String, apiUrl:String, contentUrl:String, holder:Sprite, accessorySetId:int, modelId:int, head:IHeadPlugin, configXML:XML, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{						
			_sprtHolder = holder;
			_dataProvider = new FB3dDBContentDataProvider();
			_dataProvider.setAPIURLs(apiUrl);
			_dataProvider.setContentDomain(contentUrl);
			if (_sPackageUrl!=null)
			{
				_dataProvider.setPackageUrl(_sPackageUrl);
			}
			_dataProvider.isAccelerated = true; // BLAKE: this is where the problem starts
			
			FB3dAccessorySetWrapper.Create
			(
				_sprtHolder, 					// the rendering surface
				accessorySetId,					// set accessory set id
				modelId,						// the model id (if zero, the default is loaded)
				_dataProvider, 					// the content provider
				engineUrl, 						// fb3d engine url
				"",								// boot script
				head,
				
				function(wrapper:FB3dAccessorySetWrapper, 
						 builder:IAvatarBuilder, 
						 scene:IScene3D, 
						 camera:ICameraObject3D, 
						 viewManip:ViewportManipulator, 
						 aSet:IAccessorySet):void
				{
					_accessorySetWrapper = wrapper;
					_accessorySetWrapper.setDebug(true);
					
					//wrapper.setDebug(true);
					if (_sprtHolder.stage!=null)
					{
						configureSpriteHolderListeners();
					}
					else
					{
						_sprtHolder.addEventListener(Event.ADDED_TO_STAGE, holderAddedToStage);
					}
					
					initDone(domain);
					//dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.ENGINE_LOADED));
					
					var k:Function = function():void
					{
						_accessorySetWrapper.start(function():void
						{
							trace("STARTED!");
							
							contFn();
							//dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.ACCESSORY_SET_LOADED));							
						});
					};
					
					if (configXML == null)
						k();
					else
						_accessorySetWrapper.inputConfiguration(configXML, k, failFn, progressFn);
						
				}, failFn, progressFn); 					
			
		}		
		
	/*
		private function failedFn(s:String)
		{
			trace("failedFn " + s); 
			var evtDesc:EventDescription = new EventDescription();
			evtDesc.description = s;
			dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.ON_ERROR, evtDesc));			
		}
	*/			
		
	//if you want to do stuff when initialization is done
		private function initDone(domain:ApplicationDomain):void
		{
			
		}
		
		//if the holder wasn't added to stage, when it is added configure the listeners
		private function holderAddedToStage(evt:Event):void
		{
			_sprtHolder.removeEventListener(Event.ADDED_TO_STAGE, holderAddedToStage);
			configureSpriteHolderListeners();
		}
		
		//connect event handlers
		private function configureSpriteHolderListeners():void
		{
			
			_sprtHolder.doubleClickEnabled = true;
			_sprtHolder.addEventListener(MouseEvent.DOUBLE_CLICK, _accessorySetWrapper.postDoubleClickEvent);
			_sprtHolder.addEventListener(MouseEvent.MOUSE_MOVE, _accessorySetWrapper.postMouseMoveEvent);
			_sprtHolder.addEventListener(MouseEvent.MOUSE_DOWN, _accessorySetWrapper.postMouseDownEvent);
			_sprtHolder.addEventListener(MouseEvent.MOUSE_UP, _accessorySetWrapper.postMouseUpEvent);
			_sprtHolder.stage.addEventListener(Event.ENTER_FRAME, _accessorySetWrapper.postEnterFrameEvent);
			_sprtHolder.stage.addEventListener(KeyboardEvent.KEY_DOWN, _accessorySetWrapper.postKeyDownEvent);
			_sprtHolder.stage.addEventListener(KeyboardEvent.KEY_UP, _accessorySetWrapper.postKeyUpEvent);
			_sprtHolder.stage.addEventListener(Event.ACTIVATE, _accessorySetWrapper.postActivateEvent);
			_sprtHolder.stage.addEventListener(Event.DEACTIVATE, _accessorySetWrapper.postDeactivateEvent);								
			//for tryPickAccessory
			_sprtHolder.stage.addEventListener(MouseEvent.MOUSE_UP, stageClicked);
		}
		
		/**
		 * Sets the base url for cache operations performed by the playback class
		 */
		public function setCacheUrl(s:String):void
		{			
			_sCacheBaseUrl = s;
		}
		
		/**
		 * Set the url to use (and enables) the use of packages for faster loading
		 * @param	url - the packages base url
		 */	
		public function setPackageUrl(url:String):void
		{
			_sPackageUrl = url;			
		}
		

		/**
		 * Plays an audio. If the character supports lip sync it will be triggred with the audio. Use FB3dControllerEvent and EventDescription to monitor the following events on the public audioPlayback object:
		 * AUDIO_DOWNLOADED, AUDIO_STARTED, AUDIO_ENDED, TALK_STARTED, TALK_ENDED, AUDIO_ERROR and AUDIO_DOWNLOAD_PROGRESS 
		 * @param	url - url to an mp3 audio
		 * @param	sec - offset of the audio to being playing		 
		 */
		public function say(url:String, sec:Number=0):void
		{
			audioPlayback.say(url, sec);									
		}
		
		/**
		 * Stops currently playing audio.  		 		 
		 */
		public function stopSpeech():void
		{
			audioPlayback.stopSpeech();			
		}
		
		/**
		 * Freezes currently playing audio and engine  		 		 
		 */
		public function freeze():void
		{
			audioPlayback.freeze();
			_accessorySetWrapper.setPaused(true);
		}
		/**
		 * Resumes currently playing audio and engine  		 		 
		 */
		public function resume():void
		{
			audioPlayback.resume();
			_accessorySetWrapper.setPaused(false);
		}
		
		/**
		 * Sets the volume for current and future audios played
		 * @param	n - The volume level	 		 
		 */
		public function setVolume(n:Number):void
		{
			audioPlayback.setVolume(n);			
		}
		
		/**
		 * Sets the move of the say function. If interrupt is on each call to say will stop the previous audio otherwise they will stack and play one after the other
		 * @param	b - Boolean interrupt mode	 		 
		 */
		public function setInterrupt(b:Boolean):void
		{
			audioPlayback.setInterrupt(b);			
		}
		
		
		/**
		 * Pauses the engine 
		 * @param	b - true for pause, false to resume	 		 
		 */
		public function setPaused(b:Boolean):void
		{
			_accessorySetWrapper.setPaused(b);
		}
		/**
		 * Gets the pause state 
		 * @return Boolean	 		 
		 */
		public function paused():Boolean
		{
			return _accessorySetWrapper.paused();
		}
		
		/**
		 * Enables shift and mouse drag for panning the view
		 * @param	b
		 */
		public function enableTrucking(b:Boolean):void
		{
			_accessorySetWrapper.enableTrucking(b);
		}
		/**
		 * Enables ctrl and mouse drag for zooming the view
		 * @param	b
		 */
		public function enableZooming(b:Boolean):void
		{
			_accessorySetWrapper.enableZooming(b);
		}

		
		/**
		 * Gets the current selected material configurations		 
		 * @return	xml of the current configuration
		 */
		public function getCurrentConfiguration():XML
		{			
			return _accessorySetWrapper.outputConfiguration();
		}
		
		/**
		 * Sets the accessory set with configuration from an XML
		 * @param	xml - xml which was produced using the getCurrentConfiguration method
		 * @param	contFn - called when done
		 * @param	failFn - called with a string explaining what went wrong
		 * @param	progressFn
		 */
		public function setConfigurationFromXML(xml:XML, contFn:Function, failFn:Function, progressFn:Function = null):void
		{
			_accessorySetWrapper.inputConfiguration(xml, contFn, failFn, progressFn);
		}
		
		/**
		 * Loads the editable accessory set (avatar)
		 * @param	accessorySetId - accessorySetId is the id of the accessorySet in the fb3d database
		 * @param	contFn - function to call when loaded
		 * @param	failFn - function to call when loading failed, passes a string with an error msg
		 * @param	progressFn - function to call upon progress of the upload, passes loaded:uint and total:uint
		 */
		/*
		public function loadAccessorySet(accessorySetId:int,contFn:Function, failFn:Function, progressFn:Function = null):void
		{			
			_bChangedSinceLastSave = true;
			trace("fb3dController::loadAccessorySet " + accessorySetId);
			if (_bInAvatarMode)
			{				
				//dispose of everything and reinit scene keep material so we later can apply itconfig and build new one
				var _currentCameraLocation:Object = { aim:_accCamera.aim(), pos:_accCamera.position() };
				_xmlAvatarConfig = _avatar.configuration();
				
				//dispose();
				//init(_sAPIUrl, _factory, _sprtHolder, _headPlugin);				
			}
			_bInAvatarMode = false;
			setAvatarManager(_avatarManager);					
			
				
			_avatarManager.loadAccessorySet(accessorySetId, function (accSet:IAccessorySet):void
			{				
				trace("accessory set loaded")
				accSet.startup("",function():void
				{					
					_accessorySet = accSet;				
					_treeManagerObj = _accessorySet;
					if (_xmlAvatarConfig != null)
					{
						_avatarManager.inputConfiguration(_xmlAvatarConfig);
					}	
					trace("accessory set startup done")
					contFn();
				}, failFn, progressFn);
			}, failFn , progressFn);
		
		}
		*/
		/**
		 * loads the playback avatar
		 * @param	avtUrl - .avt file url
		 * @param	contFn - function to call when  loaded
		 * @param	failFn - function to call when loading failed, passes a string with an error msg
		 * @param	progressFn - function to call upon progress of the upload, passes loaded:uint and total:uint
		 */
		/*
		override public function loadAvatar(avtUrl:String, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{		
			_bInAvatarMode = true;
			super.loadAvatar(avtUrl, contFn, failFn, progressFn);			
		}
		*/
		
		public function dispose(continuationFn:Function):void
		{						
			if (_sprtHolder!=null)
			{
				_sprtHolder.removeEventListener(MouseEvent.DOUBLE_CLICK, _accessorySetWrapper.postDoubleClickEvent);
				_sprtHolder.removeEventListener(MouseEvent.MOUSE_MOVE, _accessorySetWrapper.postMouseMoveEvent);
				_sprtHolder.removeEventListener(MouseEvent.MOUSE_DOWN, _accessorySetWrapper.postMouseDownEvent);
				_sprtHolder.removeEventListener(MouseEvent.MOUSE_UP, _accessorySetWrapper.postMouseUpEvent);
				if (_sprtHolder.stage!=null)
				{
					_sprtHolder.stage.removeEventListener(Event.ENTER_FRAME, _accessorySetWrapper.postEnterFrameEvent);
					_sprtHolder.stage.removeEventListener(KeyboardEvent.KEY_DOWN, _accessorySetWrapper.postKeyDownEvent);
					_sprtHolder.stage.removeEventListener(KeyboardEvent.KEY_UP, _accessorySetWrapper.postKeyUpEvent);
					_sprtHolder.stage.removeEventListener(Event.ACTIVATE, _accessorySetWrapper.postActivateEvent);
					_sprtHolder.stage.removeEventListener(Event.DEACTIVATE, _accessorySetWrapper.postDeactivateEvent);
					//for tryPickAccessory
					_sprtHolder.stage.removeEventListener(MouseEvent.MOUSE_UP, stageClicked);
				}
			}	
			_dataProvider.destroy();
			_accessorySetWrapper.dispose(function ():void
			{
				onDefferedDispose();				
				continuationFn();
			});							
		}
		
		private function onDefferedDispose():void
		{
			_currentDecalCategory = null;
			_currentDecalConfig = null;
			_accessorySetWrapper = null;
		}
		
		
		/**
		 * test if the class is currently handling a playback avatar or an editable accessory set
		 * @return boolean indicating the mode
		 */
		/*
		public function isInAvatarMode():Boolean
		{
			return _bInAvatarMode;
		}
		*/
		
		/**
		 * loads a material configuration by id. Material configuration are the selectable items from the workshop
		 * @param	matConfId - material configuration id
		 * @param	contFn - function to call when  loaded
		 * @param	failFn - function to call when loading failed, passes a string with an error msg
		 * @param	progressFn - function to call upon progress of the upload, passes loaded:uint and total:uint
		 */
		public function loadMaterialConfig(matConfId:int, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			_bChangedSinceLastSave = true;
			_accessorySetWrapper.loadMaterialConfiguration(matConfId, function (mat:IMaterialConfiguration):void
			{
				IMaterialConfiguration(mat).select(contFn, failFn, progressFn);				
			}
			, failFn, progressFn);			
		}				
				
		/**
		 * loads and makes visible a group of decalConfig by their category
		 * @param	categoryName - decal config catgeory to load
		 * @param	contFn - function to call when loaded
		 * @param	failFn - function to call when loading failed, passes a string with an error msg
		 * @param	progressFn - function to call upon progress of the load, passes loaded:uint and total:uint
		 */
		public function loadDecalConfigCategory(categoryName:String, contFn:Function, failFn:Function, progressFn:Function):void
		{
			_bChangedSinceLastSave = true;
			//remove previous decals
			var decalConfig:IDecalConfiguration;
			var category:ICategory;
			
				for each (category in _accessorySetWrapper.categories())
				{
					if (_currentDecalCategory!=null && category.name() == _currentDecalCategory)
					{
						for each (decalConfig in category.children([IDecalConfiguration]))
						{
							decalConfig.setVisible(false);
						}
					}
					if (categoryName == category.name())
					{
						for each (decalConfig in category.children([IDecalConfiguration]))
						{
							decalConfig.setVisible(true);
						}
					}
				}				
			
			
			if (_currentDecalConfig != null)
			{
				_currentDecalConfig.setVisible(false);
				_currentDecalConfig = null;
			}
			
			_currentDecalCategory = categoryName;
			contFn();
		}
		
		/**
		 * removes currently applied decal config category
		 */
		public function removeCurrentDecalCategory():void
		{
			_bChangedSinceLastSave = true;
			if (_currentDecalCategory != null)
			{
				for each (var category:ICategory in _accessorySetWrapper.categories())
				{
					if (category.name() == _currentDecalCategory)
					{
						for each (var decalConfig:IDecalConfiguration in category.children([IDecalConfiguration]))
						{
							IDecalConfiguration(decalConfig).setVisible(false);
						}
					}
				}
				_currentDecalCategory = null;				
			}
		}
		
		/**
		 * returns a flag if the scene has changed since the last save,
		 * save is indicated (changed to false) when a successful MID is created
		 * @return
		 */
		public function scene_has_changed():Boolean
		{
			return _bChangedSinceLastSave;
		}
		/**
		 * scene has been saved, used for resending
		 */
		 public function scene_was_saved():void
		 {
		 	_bChangedSinceLastSave = false;
		 }
		
		/**
		 * loads and makes visible a decalConfig by id
		 * @param	decalConfigId - decal config id
		 * @param	contFn - function to call when loaded
		 * @param	failFn - function to call when loading failed, passes a string with an error msg
		 * @param	progressFn - function to call upon progress of the load, passes loaded:uint and total:uint
		 */
		public function loadDecalConfig(decalConfigId:int, contFn:Function, failFn:Function, progressFn:Function):void
		{			
			_bChangedSinceLastSave = true;
			_accessorySetWrapper.loadDecalConfiguration(decalConfigId, function (decalConfig:IDecalConfiguration)
			{
				IDecalConfiguration(decalConfig).setVisible(true);
				_currentDecalConfig = IDecalConfiguration(decalConfig);
				contFn();
			} , failFn, progressFn);
		}
		/**
		 * removes (hides) a decal config by id
		 * @param	decalConfigId - decal config id
		 */
		public function removeDecalConfig(decalConfigId:int):void
		{
			_bChangedSinceLastSave = true;
			_accessorySetWrapper.loadDecalConfiguration(decalConfigId, function (decalConfig:IDecalConfiguration)
			{
				IDecalConfiguration(decalConfig).setVisible(false);
			});
		}
		
		/**
		 * removes current decalConfig
		 */
		public function removeCurrentDecalConfig():void
		{
			_currentDecalConfig.setVisible(false);
			_currentDecalConfig = null;
		}
		
		/**
		 * Loads a preset by id
		 * @param	presetId - preset id
		 * @param	contFn - function to call when loaded
		 * @param	failFn - function to call when loading failed, passes a string with an error msg
		 * @param	progressFn - function to call upon progress of the upload, passes loaded:uint and total:uint
		 */
		public function loadPreset(presetId:int, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			_bChangedSinceLastSave = true;			
			if (presetId>0)
			{
				_accessorySetWrapper.loadPreset(presetId, function (preset:IPreset)
				{
					
					//trace("preset loading");
					IPreset(preset).select(function():void {contFn(); } );
				}
				, failFn, progressFn);
			}
			else
			{
				if (failFn != null)
				{
					failFn("Preset Id has to be greater than 0");
				}
			}
		}				
		
		/**
		 * Creates an avatar byte array for saving an avt file and calls the contFn when ready with the new avatar's id
		 * @param	contFn - function to call when loaded with byte array
		 * @param	failFn - function to call when loading failed, passes a string with an error msg
		 * @param	progressFn - function to call upon progress of the upload, passes loaded:uint and total:uint
		 */
		public function getAvatarByteArray(contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			_accessorySetWrapper.generateAvatar(function(avatarId:int):void
			{					
				contFn(_dataProvider.getAvatarByteArray(avatarId));
					
			}, failFn, progressFn);			
		}
		
		/**
		 * Creates a cache url based on current configuration
		 * @return	fb3d cache url		 
		 */
		public function getAvatarCacheUrl():String
		{
			var cfgUtil:CacheConfigUtil = new CacheConfigUtil();
			return cfgUtil.config2url(_accessorySetWrapper.outputConfiguration());			
		}
		
		/**
		 * Creates an avatar byte array and saves the avt file to cache system if necessary. When done calls the contFn
		 * @param	contFn - function to call when done
		 * @param	baCreatedFn - function to call after bytearray is created which is cpu intensive 
		 * @param	failFn - function to call when loading failed, passes a string with an error msg
		 * @param	progressFn - function to call upon progress of saving , passes loaded:uint and total:uint
		 */
		
		public function saveAvatar(contFn:Function, baCreatedFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			sendAvatarByteArrayToCache(getAvatarCacheUrl(), contFn, baCreatedFn, failFn, progressFn);				
		}
		
		protected function sendAvatarByteArrayToCache(cacheUrl:String, contFn:Function, byteArrCreatedFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			/*
			if (failFn!=null)
			{
				failFn("sendAvatarByteArrayToCache needs to be reimplemented");
			}
			*/
			
			if (_sprtHolder.stage==null)
			{
				if (failFn!=null)
				{
					failFn("The controller must access the stage to create the avatar byte array");
				}
				return;
			}
			
			if (_sCacheBaseUrl==null)
			{
				if (failFn!=null)
				{
					failFn("The cache base url is not set. Use setCacheUrl to set it.");
				}
				return;
			}
			
			var urlSig:String = cacheUrl.split("/oh/")[1].split("?")[0];
			trace("sendAvatarByteArrayToCache check if already in cache "+_sCacheBaseUrl+"oh/startAVTentry.php?entryStr="+urlSig);
			XMLLoader.loadVars(_sCacheBaseUrl+"oh/startAVTentry.php?entryStr="+urlSig, function (urlVars:URLVariables)
			{
				if (urlVars==null)
				{
					trace("sendAvatarByteArrayToCache bad response continue...");
					if (failFn!=null)
					{
						failFn("startAVTentry.php bad response could not save avatar...")
					}
					//contFn();
				}
				else if (String(urlVars.ok)=="1")
				{
					trace("sendAvatarByteArrayToCache OK=1 create byteArray ");
					_accessorySetWrapper.generateAvatar(function(avatarId:int):void
					{						
						byteArrCreatedFn();
						var ba:ByteArray = _dataProvider.getAvatarByteArray(avatarId);
						var postVars:URLVariables = new URLVariables();
						postVars.entryStr = urlSig;
						var baUpload:ByteArray_Uploader = new ByteArray_Uploader();
						baUpload.addEventListener( ProgressEvent.PROGRESS, onByteArrayUploaderProgress);
						baUpload.upload_ByteArray(ba,_sCacheBaseUrl+"oh/saveAVTentry.php","avt", completeFn, errorFn, postVars);
			
						function onByteArrayUploaderProgress(evt:ProgressEvent):void
						{
							if (progressFn!=null)
							{								
								progressFn(evt.bytesLoaded, evt.bytesTotal);
							}
						}
				
						function completeFn(res:String):void
						{
							if (res!=null)
							{
								if (res=="ok=1" || res.indexOf("http://")>=0)
								{
									contFn();
								}
								else
								{
									errorFn("saveAVTentry script returned an error")
								}
							}
							else
							{
								errorFn("saveAVTentry script returned an error")
							}
						}
				
						function errorFn(err:String):void
						{
							if (failFn!=null)
							{
								failFn(err);
							}
						}												
				}, failFn, progressFn);					
			}
			else
			{
				//trace("sendAvatarByteArrayToCache error response "+urlVars.error);
				if (failFn!=null)
				{
					//failFn("sendAvatarByteArrayToCache error response "+urlVars.error);
				}
				contFn();
			}
			});						
		}
		
				
		/**
		 * get the selected material configurations
		 * @return array of material configurations ids
		 */
		public function getSelectedMaterialConfigurations():Array
		{
			var retArr:Array = new Array();
			var matArr:Vector.<IMaterialConfiguration> = _accessorySetWrapper.selectedMaterialConfigurations();
			for (var i:int = 0; i < matArr.length; ++i)
			{			
				retArr.push(matArr[i].id());
			}
			return retArr;	
		}
		
		function stripUrlDoubleSlashes(s:String):String
		{
			var httpStr:String = "http://";
			var sNoHttp:String;
			var needHttp:Boolean;
			if (s.indexOf(httpStr)>=0)
			{
				sNoHttp = s.split(httpStr)[1];
				needHttp = true;
			}
			else
			{
				sNoHttp = s;
			}	
			var regex:RegExp = /\/\//g;
			return (needHttp?httpStr:'')+sNoHttp.replace(regex,"/");	
		}
		
		public function getCurrentModel():FBModelData
		{
			var modelData:FBModelData = new FBModelData(_accessorySetWrapper.currentModel());
			for each (var category:ICategory in
				_accessorySetWrapper.currentModel().children([ICategory])) {
					var categoryData:CategoryData = new CategoryData(category);
					var catThumbs:Array = category.children([IThumbnail]);
					if (catThumbs.length > 0)
					{
						var catThumb:IThumbnail = IThumbnail(catThumbs[0]);
						var catThumbUrl:String = catThumb != null? 
							catThumb.uri() : null;
						categoryData.thumbUrl = catThumb!=null ? 
							stripUrlDoubleSlashes(_dataProvider.selectProperty(_accessorySetWrapper.accessorySet().id(),
								"", 0, "CONTENT_DOMAIN") + catThumbUrl) : null;
					}
					modelData.addCategory(categoryData);
				}
			
			var thumbs:Array =
				_accessorySetWrapper.currentModel().children([IThumbnail]);
			if (thumbs.length > 0) {
				var modelThumb:IThumbnail = IThumbnail(thumbs[0]);
				var modelThumbUrl:String = modelThumb != null ? 
					modelThumb.uri() : null;
				modelData.thumbUrl = catThumb!=null ? 
					stripUrlDoubleSlashes(_dataProvider.selectProperty(_accessorySetWrapper.accessorySet().id(),
						"", 0, "CONTENT_DOMAIN") + modelThumbUrl) : null;
			}
			return modelData;
		}

		/**
		 * Gets available presets which are selectable items		
		 * @return	PresetListData
		 */
		public function getModels():FBModelListData
		{
			var listData:FBModelListData = new FBModelListData();
			for each (var model:IModel in _accessorySetWrapper.models())
			{
				var modelData:FBModelData = new FBModelData(model);

				for each (var category:ICategory in model.children([ICategory]))
				{
					var categoryData:CategoryData = new CategoryData(category);
					var catThumbs:Array = category.children([IThumbnail]);
					if (catThumbs.length > 0)
					{
						var catThumb:IThumbnail = IThumbnail(catThumbs[0]);
						var catThumbUrl:String = catThumb != null? catThumb.uri() : null;
						categoryData.thumbUrl = catThumb!=null ? stripUrlDoubleSlashes(_dataProvider.selectProperty(_accessorySetWrapper.accessorySet().id(), "", 0, "CONTENT_DOMAIN") + catThumbUrl) : null;
					}
					modelData.addCategory(categoryData);
				}
				
				var thumbs:Array = model.children([IThumbnail]);
				if (thumbs.length > 0)
				{
					var modelThumb:IThumbnail = IThumbnail(thumbs[0]);
					var modelThumbUrl:String = modelThumb != null ? modelThumb.uri() : null;
					modelData.thumbUrl = catThumb!=null ? stripUrlDoubleSlashes(_dataProvider.selectProperty(_accessorySetWrapper.accessorySet().id(), "", 0, "CONTENT_DOMAIN") + modelThumbUrl) : null;
				}
				listData.addModel(modelData);
			}
			return listData;
		}
		
		/**
		 * Gets available presets which are selectable items		
		 * @return	PresetListData
		 */
		public function getPresets():PresetListData
		{			
			var listData:PresetListData = new PresetListData();
			for each (var category:ICategory in _accessorySetWrapper.categories())
			{				
				for each (var preset:IPreset in category.children([IPreset]))
				{
					var thumb:IThumbnail = IThumbnail(preset.children([IThumbnail])[0]);
					var thumbUrl:String = thumb != null? thumb.uri() : null;
					var presetData:PresetData = new PresetData(preset);
					var categoryData:CategoryData = new CategoryData(category);
					if (category.children([IThumbnail]).length > 0)
					{
						var catThumb:IThumbnail = IThumbnail(category.children([IThumbnail])[0]);
						var catThumbUrl:String = catThumb != null? catThumb.uri() : null;
						categoryData.thumbUrl = catThumb!=null ? stripUrlDoubleSlashes(_dataProvider.selectProperty(_accessorySetWrapper.accessorySet().id(), "", 0, "CONTENT_DOMAIN") + catThumbUrl) : null;
					}
					presetData.thumbUrl = thumb!=null ? stripUrlDoubleSlashes(_dataProvider.selectProperty(_accessorySetWrapper.accessorySet().id(), "", 0, "CONTENT_DOMAIN") + thumbUrl) : null;
					listData.addPreset(presetData, categoryData);	
				}	
			}
			return listData;			
		}
				
		
		/**
		 * Gets available material configurations which are the selecatble items.		 
		 * @return  MaterialConfigurationListData
		 */
		public function getMaterialConfigurations():MaterialConfigurationListData
		{
			var listData:MaterialConfigurationListData = new MaterialConfigurationListData();						
			
			for each (var category:ICategory in _accessorySetWrapper.categories())
			{				
				for each (var matConfig:IMaterialConfiguration in category.children([IMaterialConfiguration]))
				{
					var thumb:IThumbnail = IThumbnail(matConfig.children([IThumbnail])[0]);
					var thumbUrl:String = thumb != null? thumb.uri() : null;
					var matConfigData:MaterialConfigurationData = new MaterialConfigurationData(matConfig);
					var categoryData:CategoryData = new CategoryData(category);
					if (category.children([IThumbnail]).length > 0)
					{
						var catThumb:IThumbnail = IThumbnail(category.children([IThumbnail])[0]);
						var catThumbUrl:String = catThumb != null? catThumb.uri() : null;
						categoryData.thumbUrl = catThumb!=null ? _dataProvider.selectProperty(_accessorySetWrapper.accessorySet().id(), "", 0, "CONTENT_DOMAIN") + catThumbUrl : null;
					}
					matConfigData.thumbUrl =thumb!=null? stripUrlDoubleSlashes(_dataProvider.selectProperty(_accessorySetWrapper.accessorySet().id(), "", 0, "CONTENT_DOMAIN") + thumbUrl) : null;
					listData.addMaterialConfiguration(matConfigData, categoryData);	
				}	
			}
			return listData;
		}
										
		/**
		 * Gets availble decal configs (for the selected accessories)
		 * @return DecalConfigurationListData
		 */
		public function getDecalConfigurations():DecalConfigurationListData
		{
			var listData:DecalConfigurationListData = new DecalConfigurationListData();
			var matConfArr:Vector.<IMaterialConfiguration> = _accessorySetWrapper.selectedMaterialConfigurations();
			for (var i:int = 0; i < matConfArr.length; ++i)			
			{
				var matConfig:IMaterialConfiguration = matConfArr[i];
				var accessory:IAccessory = matConfig.parents([IAccessory])[0];
				//if mat config is selected then get this accessory's decals				
				for each (var decalConfig:IDecalConfiguration in accessory.children([IDecalConfiguration]))
				{
					;
					var decal:ITexture = ITexture(decalConfig.children([ITexture])[0]);
					var children:Array = decal.children([IThumbnail]);
					var thumb:IThumbnail;
					if (children.length > 0)
						thumb = children[0]; 
										
					var thumbUrl:String = thumb != null? thumb.uri() : null;
					//trace("fb3dController:getDecals accessory.id()=" + accessory.id() + ", decal.id()=" + decalConfig.id() + ", decal.name()=" + decalConfig.name()+" , decal.visible()="+decalConfig.visible());
					
					var decalConfigData:DecalConfigurationData = new DecalConfigurationData(decalConfig);
					decalConfigData.thumbUrl = thumb!=null? stripUrlDoubleSlashes(_dataProvider.selectProperty(_accessorySetWrapper.accessorySet().id(), "", 0, "CONTENT_DOMAIN") + thumbUrl) : null;
										
					var decalCategories:Vector.<CategoryData> = new Vector.<CategoryData>();
					for (var j:int = 0; j < decalConfig.parents([ICategory]).length; ++j)
					{
						var category:ICategory = decalConfig.parents([ICategory])[j];
						var categoryData:CategoryData = new CategoryData(category);
						if (category.children([IThumbnail]).length > 0)
						{
							var catThumb:IThumbnail = IThumbnail(category.children([IThumbnail])[0]);
							var catThumbUrl:String = catThumb != null? catThumb.uri() : null;
							categoryData.thumbUrl = catThumb!=null ? stripUrlDoubleSlashes(_dataProvider.selectProperty(_accessorySetWrapper.accessorySet().id(), "", 0, "CONTENT_DOMAIN") + catThumbUrl) : null;
						}
						decalCategories.push(categoryData);
					}
					listData.addDecalConfiguration(decalConfigData, decalCategories);
										
				}								
			}										
			return listData;
		}				
		
		
		/**
		 * Gets animations as AnimationListData 	 		 
		 * @return 	AnimationListData
		 */
		public function getAnimations():AnimationListData
		{		
			var listData:AnimationListData = new AnimationListData();
			var matConfArr:Vector.<IMaterialConfiguration> = _accessorySetWrapper.selectedMaterialConfigurations();
			for (var i:int = 0; i < matConfArr.length; ++i)
			{			
				var matConfig:IMaterialConfiguration = matConfArr[i];
				var accessory:IAccessory = matConfig.parents([IAccessoryProxy])[0];
				//if mat config is selected then get this accessory's animations				
				for each (var animation:IAnimation in accessory.children([IAnimationProxy]))
				{
					
					var animData:AnimationData = new AnimationData(animation);																	
					var animCategories:Vector.<CategoryData> = new Vector.<CategoryData>();
					for (var j:int = 0; j < animation.parents([ICategoryProxy]).length; ++j)
					{
						var category:ICategory = animation.parents([ICategoryProxy])[j];
						var categoryData:CategoryData = new CategoryData(category);
						if (category.children([IThumbnail]).length > 0)
						{
							var catThumb:IThumbnail = IThumbnail(category.children([IThumbnail])[0]);
							var catThumbUrl:String = catThumb != null? catThumb.uri() : null;
							categoryData.thumbUrl = catThumb!=null ? stripUrlDoubleSlashes(_dataProvider.selectProperty(_accessorySetWrapper.accessorySet().id(), "", 0, "CONTENT_DOMAIN") + catThumbUrl): null;
						}
						animCategories.push(categoryData);
					}
					listData.addAnimation(animData, animCategories);												
				}								
			}										
			return listData;			
			
		}
		
		/**
		 * Gets colorable categories to be used by setColorableMaterialLayersColor and getColorableMaterialLayersColor 	 		 
		 * @return 	ColorableListData
		 */
		public function getColorableCategories():ColorableListData
		{
			var listData:ColorableListData = new ColorableListData();		
			var matConfArr:Vector.<IMaterialConfiguration> = _accessorySetWrapper.selectedMaterialConfigurations();
			for (var i:int = 0; i < matConfArr.length; ++i)			
			{
				var matConfig:IMaterialConfiguration = matConfArr[i];
				//trace("matConfig "+matConfig.id()+" "+matConfig.name());
				for each(var slot:ISlot in matConfig.children([ISlot]))
				{
					//trace("slot "+slot.id()+" "+slot.name());
					for each (var material:IMaterial in slot.children([IMaterial]))
					{
						//trace("material "+material.id()+" "+material.name());
						for each (var ml:IMaterialLayer in material.children([IMaterialLayer]))
						{
							//trace("ml "+ml.id()+" "+ml.name());
							if (ml is IColorMaterialLayer)
							{								
								for (var j:int=0; j< material.parents([ICategoryProxy]).length; ++j)
								{									
									var catData:CategoryData = new CategoryData(material.parents([ICategoryProxy])[j]);
									catData.color = IColorMaterialLayer(ml).color();
									listData.addCategory(catData);								
								}				
							}
						}
					}
				}
			}					
			return listData;
		}
		
		/**
		 * This funcions colors materials by the category name
		 * @param	categoryName the category name
		 * @param	rgb the color value
		 */
		public function setColorableMaterialLayersColor(categoryName:String, rgb:uint):void
		{
			_bChangedSinceLastSave = true;
			for each (var category:ICategory in _accessorySetWrapper.categories())
			{
				if (categoryName == category.name())
				{
					for each (var material:IMaterial in category.children([IMaterial]))
					{
						for each (var ml:IMaterialLayer in material.children([IMaterialLayer]))
						{
							if (ml is IColorMaterialLayer)
							{							
								IColorMaterialLayer(ml).setColor(new Color(rgb));
							}
						}
					}
				}
			}			
		}
		/**
		 * This function return the color of the category name (based on the first color material it encountes
		 * @param	categoryName the category name
		 * @return the rgb color value
		 */
		public function getColorableMaterialLayersColor(categoryName:String):int
		{
			for each (var category:ICategory in _accessorySetWrapper.categories())
			{
				if (categoryName == category.name())
				{
					for each (var material:IMaterial in category.children([IMaterial]))
					{
						for each (var ml:IMaterialLayer in material.children([IMaterialLayer]))
						{
							if (ml is IColorMaterialLayer)
							{							
								return IColorMaterialLayer(ml).color().rgb();
							}
						}
					}
				}
			}									
			return -1;
		}
												
		
		/**
		 * invoked by a mouse click on the stage. If an avatar part is under the mouth an FB3dControllerEvent.AVATAR_CLICKED is dispatched with a ClickedAccessoryData accessible through the EventDescription object of event.data
		 * @param	e
		 */
		private function stageClicked(e:MouseEvent):void
		{
			_accessorySetWrapper.tryPickAccessory(e.stageX, e.stageY, function (acc:IAccessory)
			{		
				if (acc != null)
				{
					var catNames:Array = new Array();
					for each (var category:ICategory in acc.parents([ICategory]))
					{
						catNames.push(category.name());
					}
					
					var geomName:String = IAccessory(acc).lastPickedGeometryName();
					var clickedAccData:ClickedAccessoryData = new ClickedAccessoryData();
					clickedAccData.id = IAccessory(acc).id();
					clickedAccData.name = IAccessory(acc).name();
					clickedAccData.categories = catNames
					clickedAccData.geomName = geomName;		
					var evtDesc:EventDescription = new EventDescription();
					evtDesc.obj = clickedAccData;
					dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.AVATAR_CLICKED, evtDesc));
				}
				
			});
		}

		/**
		 * loads a model by id
		 * @param	modelId - model id
		 * @param	contFn - function to call when loaded
		 * @param	failFn - function to call when loading failed, passes a string with an error msg
		 * @param	progressFn - function to call upon progress of the upload, passes loaded:uint and total:int
		 */
		public function loadModel(modelId:int, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			trace("FB3dControllerPlayback::loadModel " + modelId);
			_accessorySetWrapper.loadModel(modelId, function(model:IModelProxy):void
			{
				model.select(contFn, failFn, progressFn);
				
			}, failFn, progressFn);
		}
		
		/**
		 * loads and plays an animation by id
		 * @param	animationId - animation id
		 * @param	loop - if this flag is set to true the animation will loop
		 * @param	interrupt - if set to true it will stop the previous loaded animation
		 * @param	contFn - function to call when loaded
		 * @param	endedFn - function to call when animation cycle is end
		 * @param	failFn - function to call when loading failed, passes a string with an error msg
		 * @param	progressFn - function to call upon progress of the upload, passes loaded:uint and total:uint
		 */
		public function loadAnimation(animationId:int, loop:Boolean, interrupt:Boolean, contFn:Function, endedFn:Function = null, failFn:Function = null, progressFn:Function = null):void
		{		
			trace("FB3dControllerPlayback::loadAnimation "+animationId);
			_accessorySetWrapper.loadAnimation(animationId, function(ani:IAnimationProxy):void
			{
				ani.setIsLooping(loop);					
				ani.preload(function ()
				{
					//keep animation for interruption											
					if (_aniCurrent != null && interrupt)
					{
						_aniCurrent.stop();
					}
					_aniCurrent = ani;												
					
					IAnimationProxy(ani).play(endedFn, failFn, progressFn);
					contFn();
				});										
			} , failFn, progressFn);			
		}
		
		/**
		 * Execute custom commands (you can get the names for commands from the getCommands call)
		 * @param	cmdName - the command name
		 * @param	arg - used by the command. Can be a arguments the command uses or a continuation function
		 */
		public function executeCommand(cmdName:String, arg:Array = null):Object
		{
			return _accessorySetWrapper.executeCommand(cmdName, arg);
		}			
		
		/**
		 * get available commands
		 * @return Vector.<String> of Command Names objects
		 */
		public function getCommandNames():Vector.<String>
		{
			//trace("getCommands");
			var ret:Vector.<String> = new Vector.<String>();
			var cmds:Vector.<ICommandProxy> = _accessorySetWrapper.commands();
			for (var i:int=0; i<cmds.length; ++i)
			{
				ret.push(cmds[i].name());
			}
			return ret;//_accessorySetWrapper.commandNames();
		}
		
		/**
		 * get available commands data
		 * @param 	sceneId - If 0 returns all accessory set commands, if a sceneId passed only commands which intersect with accessory set commands
		 * @param 	contFn - continuation function is called with Vector.<CommandData> of Command Data objects
		 * @param	failFn - function to call when loading failed, passes a string with an error msg		 
		 * 
		 */
		public function getCommandsData(sceneId:int, contFn:Function, failFn:Function):void
		{
			var prepareData:Function = function(contFn:Function, sceneCmdNames:Vector.<String> = null)
			{
				
				var ret:Vector.<CommandData> = new Vector.<CommandData>();
				var cmds:Vector.<ICommandProxy> = _accessorySetWrapper.commands();
				for (var i:int=0; i<cmds.length; ++i)
				{
					if (sceneCmdNames==null || sceneCmdNames.indexOf(cmds[i].name())>=0)
					{
						var cmdData:CommandData = new CommandData(cmds[i]);
						ret.push(cmdData);
					}
					//trace(cmdData.name + " -> "+cmdData.argDescription);
				}
				contFn(ret);
			}
			
			if (sceneId>0)
			{
				getSceneCommandNames(sceneId, function(v:Vector.<String>)
				{
					prepareData(contFn, v);
				}, failFn);
			}
			else
			{
				prepareData(contFn);
			}
			
			
		}
		
		/**
		 * get available scene commands
		 * @param sceneSetId - id of the scene
		 * @param contFn - continuation function is called with Vector.<String> of Command Names		 
		 */
		public function getSceneCommandNames(sceneSetId:int, contFn:Function, failedFn:Function = null):void
		{
			_dataProvider.getSceneCommandNames(_accessorySetWrapper.accessorySet().id(), sceneSetId, contFn, failedFn);					
		}			
		
		/**
		 * Preloads animations based on category name
		 * @param	categoryName - name of category		 
		 */		
		public function preloadAnimationsByCategory(categoryName:String = null, contFn:Function = null, failFn:Function = null, progressFn:Function = null):void
		{
			//step 1 put all the animation objects in a temp array
			var categories:Vector.<ICategoryProxy> = _accessorySetWrapper.categories();
			var animationsArray:Array = new Array();
			for each (var category:ICategoryProxy in categories)
			{
				if (categoryName != null)
				{
					if (category.name() != categoryName)
					{
						continue;
					}
				}
				for each (var animationProxy:IAnimationProxy in category.children([IAnimationProxy]))
				{
					animationsArray.push(animationProxy.id());
				}
			}
			
			_dataProvider.preloadPackage(_accessorySetWrapper.accessorySet().id(), animationsArray, contFn, failFn, progressFn);
			/*
			var force:Function = Util.delayN(animationsArray.length, contFn);
			for (var i:int = 0; i < animationsArray.length; ++i)
			{
			animationsArray[i].preload(force, failFn, progressFn);				
			}
			*/
		}		
		
		/**
		 * sets the aim vector of the camera
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		public function setCameraAim(x:Number, y:Number, z:Number):void
		{
			_accessorySetWrapper.setCameraAim(x, y, z);
		}
		
		/**
		 * returns the current aim of the camera
		 * @return Number3D
		 */
		public function getCameraAim():Vector3D
		{
			return _accessorySetWrapper.cameraAim();
		}
		
		/**
		 * sets the pos vector of the camera
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		public function setCameraPos(x:Number, y:Number, z:Number):void
		{
			_accessorySetWrapper.setCameraPosition(x, y, z);
		}
		
		/**
		 * returns the current position of the camera
		 * @return Number3D
		 */
		public function getCameraPos():Vector3D
		{
			return _accessorySetWrapper.cameraPosition();
		}
		
		public function setLightPos(x:Number, y:Number, z:Number):void
		{
			_accessorySetWrapper.setLightPosition(x, y, z);
		}
		
		/**
		 * Sets the viewable yaw limits (around)
		 * @param	min - minimum angle (degrees)
		 * @param	max - maximum angle (degress)
		 */
		public function setViewYawLimits(min:Number, max:Number):void
		{
			_accessorySetWrapper.setViewYawLimits(min, max);
		}
		
		/**
		 * Sets the viewable pitch limits (up/down)
		 * @param	min - minimum angle (degrees)
		 * @param	max - maximum angle (degress)
		 */
		public function setViewPitchLimits(min:Number, max:Number):void
		{
			_accessorySetWrapper.setViewPitchLimits(min, max);
		}

		public function setDropFrames(b:Boolean):void { _accessorySetWrapper.setDropFrames(b); }
		
		public function set useActivationEvents(value:Boolean):void
		{
			if (value) {
				_sprtHolder.stage.addEventListener(Event.ACTIVATE,
					_accessorySetWrapper.postActivateEvent);
				_sprtHolder.stage.addEventListener(Event.DEACTIVATE,
					_accessorySetWrapper.postDeactivateEvent);
			} else {
				_sprtHolder.stage.removeEventListener(Event.ACTIVATE,
					_accessorySetWrapper.postActivateEvent);
				_sprtHolder.stage.removeEventListener(Event.DEACTIVATE,
					_accessorySetWrapper.postDeactivateEvent);
			}
		}
		
		public function getCategories():Vector.<CategoryData>
		{
			var categories:Vector.<CategoryData> = new Vector.<CategoryData>();
			var catProxies:Vector.<ICategoryProxy> = _accessorySetWrapper.categories();
			for (var i:int = 0; i < catProxies.length; i++) {
				var categoryData:CategoryData = new CategoryData(catProxies[i]);
				categories.push(categoryData);
			}
			return categories;
		}
	}
}