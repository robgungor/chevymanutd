package com.oddcast.workshop.fb3d.playback
{
	import com.oddcast.event.EventDescription;
	import com.oddcast.event.FB3dControllerEvent;
	import com.oddcast.host.api.fullbody.IHeadPlugin;
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.*;
	import com.oddcast.oc3d.shared.*;
	import com.oddcast.workshop.fb3d.FB3dDBContentDataProvider;
	import com.oddcast.workshop.fb3d.dataStructures.AnimationData;
	import com.oddcast.workshop.fb3d.dataStructures.AnimationListData;
	import com.oddcast.workshop.fb3d.dataStructures.CategoryData;
	import com.oddcast.workshop.fb3d.dataStructures.ClickedAccessoryData;
	import com.oddcast.workshop.fb3d.dataStructures.CommandData;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Vector3D;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	
	
	/**
	 * ...
	 * @author Jonathan Achai
	 */
	public class FB3dControllerPlayback extends EventDispatcher
	{		
		protected var _dataProvider:FB3dDBContentDataProvider;					
		protected var _sceneSetWrapper:FB3dSceneSetWrapper				
		protected var _sprtHolder:Sprite;						
		protected var _avatar:IAvatar;
		protected var _aniCurrent:IAnimationProxy;					
		public var audioPlayback:AudioPlayback;
		public var _bSaveToCacheEnabled:Boolean;
		private var _sCacheBaseUrl:String;
		private var _sPackageUrl:String;
		//private var _bSceneStarted:Boolean;
		private var _sActiveInstanceName:String;
		private var _sSceneSetDataUrl:String;
		
		private var _iAvatarIdCounter:int = 0;
		private var _iLastAvatarIdIndexLoaded:int;
				
		public function FB3dControllerPlayback() 
		{
			DBContentDataProviderRead.API_ZIP_RESPONSE = true;
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
				_sceneSetWrapper.loadSoundAndPlayVisemeOnAllAvailableMorphDeformers(_sActiveInstanceName, url, triggerAudio, offset, finishedLoadingCallback, finishedPlayingCallback, failedFn, progressedFn);
			});	
		}	
		
		/**
		 * Makes API calls using the compression parameter and reads it accordingly 
		 * @param	b - true is compressed		 		 
		 */
		public function useCompressedAPI(b:Boolean):void
		{
			DBContentDataProviderRead.API_ZIP_RESPONSE = b;
		}
		
		/**
		 * Makes playback support local execution 
		 * @param	b - true is local		 		 
		 */
		public function setLocalPlayback(b:Boolean):void
		{
			DBContentDataProviderRead.IS_LOCAL = b;
		}
		
		/**
		 * Returns a reference to the sceneSetWrapper		 
		 * @return	FB3dSceneSetWrapper		 
		 */
		public function sceneSetWrapper():FB3dSceneSetWrapper { return _sceneSetWrapper; } 		
		
		/**
		 * Returns the available avatar instances in the scene		 
		 * @return	Vector.<String>		 
		 */
		public function getAvatarInstanceNames():Vector.<String>
		{
			return _sceneSetWrapper.avatarInstanceNames();
		}
		
		public function setSceneSetDataUrl(s:String):void
		{
			_sSceneSetDataUrl = s;
		}
		
		public function setActiveInstanceName(s:String):void
		{
			_sActiveInstanceName = s;
		}
		
		public function getActiveInstanceName():String
		{
			return _sActiveInstanceName;
		}
		
		/**
		 * Initializes the FB3dController. This includes loading the engine, setting up the 3d environment and dispatching the ENGINE_LOADED and ENGINE_LOAD_PROGRESS events		 
		 * @param	engineUrl - absolute url of the engine
		 * @param	apiUrl - absolute url of the fb3d api
		 * @param	contentUrl - base url for the fb3d content
		 * @param	holder - Sprite to contain the fb3d scene
		 */
		public function init(domain:ApplicationDomain, engineUrl:String, apiUrl:String, contentUrl:String, holder:Sprite, sceneSetId:int, head:IHeadPlugin, contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{						
			_sprtHolder = holder;
			
			//_colorWireframe = Color.createWithComponents(0, 0, 0, 0); //transparent
			//Data Provider
			_dataProvider = new FB3dDBContentDataProvider();			
			_dataProvider.setAPIURLs(apiUrl);
			_dataProvider.setContentDomain(contentUrl);
			/*
			if (_sSceneSetDataUrl!=null)
			{
				_dataProvider.setSceneSetDataUrl(_sSceneSetDataUrl);
			}
			*/
			if (_sPackageUrl!=null)
			{
				_dataProvider.setPackageUrl(_sPackageUrl);
			}
			_dataProvider.isAccelerated = true; // BLAKE: this is where the problem starts
			//IAvatarParameter(a).setAvatarId(321039)
			//_arrPlugIns = new Array();
			FB3dSceneSetWrapper.Create(_sprtHolder, sceneSetId, _dataProvider, engineUrl, "", head, 
				function(wrapper:FB3dSceneSetWrapper):void
			{
				_sceneSetWrapper = wrapper;

				_sceneSetWrapper.setDebug(true);
				
				if (_sprtHolder.stage!=null)
				{
					configureSpriteHolderListeners();
				}
				else
				{
					_sprtHolder.addEventListener(Event.ADDED_TO_STAGE, holderAddedToStage);
				}
				
				initDone(domain);
				contFn();
				//dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.ENGINE_LOADED));
			}, failFn, progressFn);																							
		}
		
		//if you want to do stuff when initialization is done
		protected function initDone(domain:ApplicationDomain):void
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
			_sprtHolder.addEventListener(MouseEvent.DOUBLE_CLICK, _sceneSetWrapper.postDoubleClickEvent);
			_sprtHolder.addEventListener(MouseEvent.MOUSE_MOVE, _sceneSetWrapper.postMouseMoveEvent);
			_sprtHolder.addEventListener(MouseEvent.MOUSE_DOWN, _sceneSetWrapper.postMouseDownEvent);
			_sprtHolder.addEventListener(MouseEvent.MOUSE_UP, _sceneSetWrapper.postMouseUpEvent);
			_sprtHolder.stage.addEventListener(Event.ENTER_FRAME, _sceneSetWrapper.postEnterFrameEvent);
			_sprtHolder.stage.addEventListener(KeyboardEvent.KEY_DOWN, _sceneSetWrapper.postKeyDownEvent);
			_sprtHolder.stage.addEventListener(KeyboardEvent.KEY_UP, _sceneSetWrapper.postKeyUpEvent);
			_sprtHolder.stage.addEventListener(Event.ACTIVATE, _sceneSetWrapper.postActivateEvent);
			_sprtHolder.stage.addEventListener(Event.DEACTIVATE, _sceneSetWrapper.postDeactivateEvent);
			//for tryPickAccessory
			_sprtHolder.stage.addEventListener(MouseEvent.MOUSE_UP, stageClicked);
		}
		
		
		/**
		 * Gets the current selected material configurations		 
		 * @return	xml of the current configuration
		 */
		public function getCurrentConfiguration():XML
		{			
			return _sceneSetWrapper.outputConfiguration(_sActiveInstanceName);
		}
		
		/**
		 * Sets the base url for cache operations performed by the playback class
		 */
		public function setCacheUrl(s:String):void
		{
			_bSaveToCacheEnabled = true;
			_sCacheBaseUrl = s;
		}
		
		
		/**
		 * Returns a reference to the IAvatarBuilderProxy
		 * @return IAvatarBuilderProxy 
		 
		 */
		//public function getAvatarBuilderProxy():IAvatarBuilderProxy
		//{
		//	return IAvatarBuilderProxy(_avatarManager);
		//}
		
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
			_sceneSetWrapper.setPaused(true);
		}
		/**
		 * Resumes currently playing audio and engine  		 		 
		 */
		public function resume():void
		{
			audioPlayback.resume();
			_sceneSetWrapper.setPaused(false);
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
			_sceneSetWrapper.setPaused(b);
		}
		/**
		 * Gets the pause state 
		 * @return Boolean	 		 
		 */
		public function paused():Boolean
		{
			return _sceneSetWrapper.paused();
		}
		
		/**
		 * Enables shift and mouse drag for panning the view
		 * @param	b
		 */
		public function enableTrucking(b:Boolean):void
		{
			_sceneSetWrapper.enableTrucking(b);
		}
		/**
		 * Enables ctrl and mouse drag for zooming the view
		 * @param	b
		 */	
		public function enableZooming(b:Boolean):void
		{
			_sceneSetWrapper.enableZooming(b);
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
		 * returns the last triggered animation
		 * @return IAnimationProxy
		 */
		public function getCurrentAnimation():IAnimationProxy
		{
			return _aniCurrent;
		}		
		
		/**
		 * sets the aim vector of the camera
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		public function setCameraAim(x:Number, y:Number, z:Number):void
		{
			_sceneSetWrapper.setCameraAim(x, y, z);
		}
		
		/**
		 * returns the current aim of the camera
		 * @return Number3D
		 */
		public function getCameraAim():Vector3D
		{
			return _sceneSetWrapper.cameraAim();
		}
		
		/**
		 * sets the pos vector of the camera
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		public function setCameraPos(x:Number, y:Number, z:Number):void
		{
			_sceneSetWrapper.setCameraPosition(x, y, z);
		}
		
		/**
		 * returns the current position of the camera
		 * @return Number3D
		 */
		public function getCameraPos():Vector3D
		{
			return _sceneSetWrapper.cameraPosition();
		}
		
		public function setLightPos(x:Number, y:Number, z:Number):void
		{
			_sceneSetWrapper.setLightPosition(x, y, z);
		}
		
		/**
		 * Sets the viewable yaw limits (around)
		 * @param	min - minimum angle (degrees)
		 * @param	max - maximum angle (degress)
		 */
		public function setViewYawLimits(min:Number, max:Number):void
		{
			_sceneSetWrapper.setViewYawLimits(min, max);
		}
		
		/**
		 * Sets the viewable pitch limits (up/down)
		 * @param	min - minimum angle (degrees)
		 * @param	max - maximum angle (degress)
		 */
		public function setViewPitchLimits(min:Number, max:Number):void
		{
			_sceneSetWrapper.setViewPitchLimits(min, max);
		}										
		
		
		/**
		 * applies the color of color material layers based on oh string.
		 * @param	s - a string that looks like "33668=0000FF&34345=FF0000" 		 		 
		 */
		public function applyColorsFromString(s:String):void
		{
			if (s!=null)
			{
				trace("applyColorsFromString "+s);
				var matColorVars:URLVariables = new URLVariables(s);
				
				for each (var category:ICategoryProxy in _sceneSetWrapper.avatarInstanceCategories(_sActiveInstanceName))
				{					
					for each (var material:IMaterial in category.children([IMaterial]))
					{
						for each (var ml:IMaterialLayer in material.children([IMaterialLayer]))
						{
							if (ml is IColorMaterialLayer)
							{			
								trace("found color material layer:"+ml.id());
								if (matColorVars[String(ml.id())]!= undefined)
								{
									trace("setColor of "+ml.id()+" to "+matColorVars[String(ml.id())]);
									IColorMaterialLayer(ml).setColor(new Color(int("0x"+matColorVars[String(ml.id())])));
								}
							}
						}
					}					
				}			
				/*
				var cfgUtil:CacheConfigUtil = new CacheConfigUtil();
				var cfgXML:XML = cfgUtil.url2config(cacheUrl);
				var cNode:XML;
				for each(cNode in cfgXML.AccessorySet.ColorMaterialLayer)
				{
					IAvatarBuilderProxy(_avatarManagerObj).loadColorMaterialLayer(int(cNode.@id), function (cmLayer:IColorMaterialLayer)
					{
						cmLayer.setColor(Color.createWithWebString(cNode.@value));					
					});
				}
				contFn();
				*/
			}
		}
		/*
		public function loadDefaultAvatars(contFn:Function, failFn:Function=null, progressFn:Function=null):void
		{
			startScene(contFn, failFn, progressFn);			
		}
				
		public function startDefault(contFn:Function, failFn:Function=null, progressFn:Function=null):void
		{
			if (!_bSceneStarted)
				_sceneSetWrapper.start(function():void { contFn(); }, failFn, progressFn);
			else
				contFn();
		}
		*/
		/**
		 * starts the playback scene. This function should be called after loading the avatars		
		 * @param	contFn - function to call when  loaded
		 * @param	failFn - function to call when loading failed, passes a string with an error msg
		 * @param	progressFn - function to call upon progress of the upload, passes loaded:uint and total:uint
		 */
		public function startScene(contFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			_sceneSetWrapper.start(function ()
			{
				var names:Vector.<String> = getAvatarInstanceNames();
				if (names.length>_iLastAvatarIdIndexLoaded)
				{
					_sActiveInstanceName = names[_iLastAvatarIdIndexLoaded];
				}
				contFn();
			}, failFn, progressFn);
		}
		
		/**
		 * loads the playback avatar
		 * @param	avtUrl - .avt file url
		 * @param	index - which character in the scene should this load into. Most cases this will be 0		 
		 */
		public function loadAvatar(avtUrl:String, index:uint):void
		{					
			//var d:Date = new Date();
			//var timestamp:int = int(d.getTime());
			var avtUrlArr:Array = avtUrl.split("?");
			var colorsConfig:String = avtUrlArr.length>1? avtUrlArr[1] : null;			
			_iAvatarIdCounter++;
			_dataProvider.setAvatarUrl(_iAvatarIdCounter, avtUrlArr[0]);
			
			var paramNames:Vector.<String> = _sceneSetWrapper.avatarParameterNames();
			if (index > paramNames.length-1)
			{
				throw new Error("No avatar parameter found in scene");
				return
			}
			_sceneSetWrapper.setAvatarParameterAvatarId(paramNames[index], _iAvatarIdCounter);
			_iLastAvatarIdIndexLoaded = index;														
		}
		
		private function avatarLoaded(cacheUrl:String, contFn:Function):void
		{
			/*
			var cfgUtil:CacheConfigUtil = new CacheConfigUtil();
			var cfgXML:XML = cfgUtil.url2config(cacheUrl);
			var cNode:XML;
			for each(cNode in cfgXML.AccessorySet.ColorMaterialLayer)
			{
				IAvatarBuilderProxy(_avatarManagerObj).loadColorMaterialLayer(int(cNode.@id), function (cmLayer:IColorMaterialLayer)
				{
					cmLayer.setColor(Color.createWithWebString(cNode.@value));					
				});
			}
			contFn();
			*/
			
		}
		
		protected function sendAvatarByteArrayToCache(cacheUrl:String, contFn:Function, byteArrCreatedFn:Function, failFn:Function = null, progressFn:Function = null):void
		{
			if (failFn!=null)
			{
				failFn("sendAvatarByteArrayToCache needs to be reimplemented");
			}
			/*
			if (_sprtHolder.stage==null)
			{
				if (failFn!=null)
				{
					failFn("The controller must access the stage to get the avatar byte array");
				}
				return;
			}
			var urlSig:String = cacheUrl.split("/oh/")[1].split("?")[0];
			trace("sendAvatarByteArrayToCache check if should start upload "+_sCacheBaseUrl+"oh/startAVTentry.php?entryStr="+urlSig);
			XMLLoader.loadVars(_sCacheBaseUrl+"oh/startAVTentry.php?entryStr="+urlSig, function (urlVars:URLVariables)
			{
				if (urlVars==null)
				{
					trace("sendAvatarByteArrayToCache bad response continue...");
					contFn();
				}
				else if (String(urlVars.ok)=="1")
				{
					trace("sendAvatarByteArrayToCache OK=1 create byteArray ");
					_avatarManager.newAvatar("Avatar", _sprtHolder.stage, false,  function(avatar:IAvatar):void
					{						
						byteArrCreatedFn();
						var ba:ByteArray = _dataProvider.getAvatarByteArray(IAvatar(avatar).id());
						var postVars:URLVariables = new URLVariables();
						postVars.entryStr = urlSig;
						var baUpload:ByteArray_Uploader = new ByteArray_Uploader();
						baUpload.addEventListener( ProgressEvent.PROGRESS, onByteArrayUploader);
						baUpload.upload_ByteArray(ba,_sCacheBaseUrl+"oh/saveAVTentry.php","avt", completeFn, errorFn, postVars);
						
						function onByteArrayUploader(evt:ProgressEvent):void
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
												
						trace("sendAvatarByteArrayToCache byteArray ready post to "+_sCacheBaseUrl+"oh/saveAVTentry.php");
						//trace("ba="+ba.toString());
						//trace("b64a="+postVars.FileDataBase64);
						//trace("md5Str="+postVars.md5Str);
																		
					}, function (s:String){trace(s); contFn();}, progressFn);					
				}
				else
				{
					trace("sendAvatarByteArrayToCache error response "+urlVars.error);
					contFn();
				}
			});			
			*/
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
			_sceneSetWrapper.loadAnimation(_sActiveInstanceName, animationId, function(ani:IAnimationProxy):void
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
			return _sceneSetWrapper.executeCommand(cmdName, arg);
		}
		
		/**
		 * get available commands names
		 * @return Vector.<String> of Command Names objects
		 */
		public function getCommandNames():Vector.<String>
		{
			var ret:Vector.<String> = new Vector.<String>();
			var cmds:Vector.<ICommandProxy> = _sceneSetWrapper.commands();
			for (var i:int=0; i<cmds.length; ++i)
			{
				ret.push(cmds[i].name());
			}
			return ret;//_accessorySetWrapper.commandNames();
		}
		
		/**
		 * get available commands data
		 * @return Vector.<CommandData> of Command Data objects
		 */
		public function getCommandsData():Vector.<CommandData>
		{
			var ret:Vector.<CommandData> = new Vector.<CommandData>();
			var cmds:Vector.<ICommandProxy> = _sceneSetWrapper.commands();
			for (var i:int=0; i<cmds.length; ++i)
			{
				var cmdData:CommandData = new CommandData(cmds[i]);
				ret.push(cmdData);
				//trace(cmdData.name + " -> "+cmdData.argDescription);
			}
			return ret;
		}
						
		/**
		 * Gets animations as AnimationListData 	 		 
		 * @return 	AnimationListData
		 */
		public function getAnimations():AnimationListData
		{
			var categories:Vector.<ICategoryProxy> = _sceneSetWrapper.avatarInstanceCategories(_sActiveInstanceName);
			
			var listData:AnimationListData = new AnimationListData();						
			for each (var category:ICategoryProxy in categories)
			{						
				for each (var animationProxy:IAnimationProxy in category.children([IAnimationProxy]))
				{	
					var categoryData:CategoryData = new CategoryData(category);
					if (category.children([IThumbnail]).length > 0)
					{
						var catThumb:IThumbnail = IThumbnail(category.children([IThumbnail])[0]);
						var catThumbUrl:String = catThumb != null? catThumb.uri() : null;
						categoryData.thumbUrl = catThumb!=null ? _dataProvider.selectProperty(0, "", 0, "CONTENT_DOMAIN") + catThumbUrl : null;
					}
					var catDataVec:Vector.<CategoryData> = new Vector.<CategoryData>();
					catDataVec.push(categoryData);
					listData.addAnimation(new AnimationData(animationProxy), catDataVec);					
				}
			}							
			return listData;
		}
		
		/**
		 * Preloads animations based on category name
		 * @param	categoryName - name of category		 
		 */		
		public function preloadAnimationsByCategory(categoryName:String = null, contFn:Function = null, failFn:Function = null, progressFn:Function = null):void
		{
			//step 1 put all the animation objects in a temp array
			var categories:Vector.<ICategoryProxy> = _sceneSetWrapper.avatarInstanceCategories(_sActiveInstanceName);
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
			
			_dataProvider.preloadPackage(_sceneSetWrapper.sceneSet().id(), animationsArray, contFn, failFn, progressFn);
			/*
			var force:Function = Util.delayN(animationsArray.length, contFn);
			for (var i:int = 0; i < animationsArray.length; ++i)
			{
				animationsArray[i].preload(force, failFn, progressFn);				
			}
			*/
		}				
		
		/**
		 * invoked by a mouse click on the stage. If an avatar part is under the mouth an FB3dControllerEvent.AVATAR_CLICKED is dispatched with a ClickedAccessoryData accessible through the EventDescription object of event.data
		 * @param	e
		 */
		protected function stageClicked(e:MouseEvent):void
		{
			trace("stageClicked");	
			var instance:IAvatarInstance = _sceneSetWrapper.tryPickAvatarInstance(e.stageX, e.stageY);
			if (instance != null)
			{
				_sceneSetWrapper.tryPickAccessory(instance, e.stageX, e.stageY, function(acc:IAccessoryProxy):void
				{
					var accessoryName:String = acc.name();
					var catNames:Array = new Array();
					for each (var category:ICategoryProxy in acc.parents([ICategoryProxy]))
					{
						catNames.push(category.name());
					}
					
					var geomName:String = IAccessoryProxy(acc).lastPickedGeometryName();				
					
					var clickedAccData:ClickedAccessoryData = new ClickedAccessoryData();
					clickedAccData.id = IAccessoryProxy(acc).id();
					clickedAccData.name = accessoryName;
					clickedAccData.categories = catNames;
					clickedAccData.geomName = geomName;				
					var evtDesc:EventDescription = new EventDescription();
					evtDesc.obj = clickedAccData;
					dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.AVATAR_CLICKED, evtDesc));
					
				})
			}
		}
					
		
		/**
		 * destroys the objects and remove listeners 
		 * @param	called when finished disposing
		 */
		public function dispose(continuationFn:Function):void
		{						
			if (_sprtHolder!=null)
			{
				_sprtHolder.removeEventListener(MouseEvent.DOUBLE_CLICK, _sceneSetWrapper.postDoubleClickEvent);
				_sprtHolder.removeEventListener(MouseEvent.MOUSE_MOVE, _sceneSetWrapper.postMouseMoveEvent);
				_sprtHolder.removeEventListener(MouseEvent.MOUSE_DOWN, _sceneSetWrapper.postMouseDownEvent);
				_sprtHolder.removeEventListener(MouseEvent.MOUSE_UP, _sceneSetWrapper.postMouseUpEvent);
				if (_sprtHolder.stage!=null)
				{
					_sprtHolder.stage.removeEventListener(Event.ENTER_FRAME, _sceneSetWrapper.postEnterFrameEvent);
					_sprtHolder.stage.removeEventListener(KeyboardEvent.KEY_DOWN, _sceneSetWrapper.postKeyDownEvent);
					_sprtHolder.stage.removeEventListener(KeyboardEvent.KEY_UP, _sceneSetWrapper.postKeyUpEvent);
					_sprtHolder.stage.removeEventListener(Event.ACTIVATE, _sceneSetWrapper.postActivateEvent);
					_sprtHolder.stage.removeEventListener(Event.DEACTIVATE, _sceneSetWrapper.postDeactivateEvent);
					//for tryPickAccessory
					_sprtHolder.stage.removeEventListener(MouseEvent.MOUSE_UP, stageClicked);
				}
			}			
			_dataProvider.destroy();
			_sceneSetWrapper.dispose(function ():void
			{
				onDefferedDispose();				
				continuationFn();
			});							
		}
		
		protected function onDefferedDispose():void
		{			
			_aniCurrent = null;					
			//_arrPlugIns = null;	
			//_avatarManager = null;
			_sceneSetWrapper = null;
			//_treeManagerObj = null;
			_dataProvider.destroy();			
		}				
						
		protected function failedFn(s:String)
		{
			trace("failedFn " + s); 
			var evtDesc:EventDescription = new EventDescription();
			evtDesc.description = s;
			dispatchEvent(new FB3dControllerEvent(FB3dControllerEvent.ON_ERROR, evtDesc));			
		}
		
		protected function kernelFail(s:String):void
		{
			failedFn(s);
		}
		
		protected function kernelMessage(s:String):void
		{
			trace("FB3dController:KernelMessage "+s);
		}
		
		
		protected function inArray(search:String,arr:Array, exact:Boolean):Boolean
		{
			for (var k in arr)
			{
				if (exact)
				{
					if (arr[k] == search)
					{
						return true;
					}
				}
				else
				{
					if (arr[k].indexOf(search)>=0)
					{
						return true;
					}
				}
			}
			return false;
		}
		public function setDropFrames(b:Boolean):void { _sceneSetWrapper.setDropFrames(b); }

	}
	
}