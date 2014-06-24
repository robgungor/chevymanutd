package code.utils 
{
	import code.HeadStruct;
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.assets.structures.BackgroundStruct;
	import com.oddcast.audio.*;
	import com.oddcast.event.*;
	import com.oddcast.oc3d.shared.Image;
	import com.oddcast.oc3d.shared.PNGEncoder;
	import com.oddcast.utils.*;
	import com.oddcast.utils.gateway.Gateway;
	import com.oddcast.utils.gateway.Gateway_Request;
	import com.oddcast.workshop.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.system.*;
	import flash.ui.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class MID_Save
	{
		private const PROCESS_SAVING_MID	:String = 'PROCESS_SAVING_MID';
		private const MSG_SAVING_MID		:String = 'Saving data';
		private var is_initted				:Boolean = false;
		private var saver					:WorkshopSaver;
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INIT */
		/**
		 * Constructor
		 */
		public function MID_Save() 
		{
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERFACE API */
		/**
		 *saves an MID 
		 * @param _e	can be null
		 * @param _callbacks
		 * 
		 */		
		public function save_message( _e:SendEvent, _callbacks:Callback_Struct ):void 
		{	
			// set a default event type
			if (_e==null)
				_e=new SendEvent(SendEvent.SEND,SendEvent.SAVE, null);
			
			init();
			if (reuse_previous_mid(_e))
			{
				_callbacks.fin();
			}
			else	// save a new message
			{
				add_listeners();
				start_processing();
				start_saving( _e );
				// crops the background then 
				//crop_background( new Callback_Struct( heads_ready, null, null ) );
			}
			
			function heads_ready(  ):void 
			{	start_saving( _e );
			}
			
			function saving_fin( _e:SendEvent ):void
			{	remove_listeners();				
				save_complete( _e, _callbacks );				
			}
			function saving_error( _e:AlertEvent ):void
			{	remove_listeners();
				end_processing();
				App.mediator.alert_user( _e );
				if (_callbacks && _callbacks.error != null)
					_callbacks.error( _e );
			}
			function saving_progress( _e:ProcessingEvent ):void 
			{	var percent:int = _e.percent * 100;
				if (_callbacks && _callbacks.progress != null)
					_callbacks.progress( percent );
				App.mediator.processing_start( PROCESS_SAVING_MID, MSG_SAVING_MID, percent );
			}
			
			function add_listeners(  ):void 
			{	App.listener_manager.add( saver, SendEvent.DONE, saving_fin, this );
				App.listener_manager.add( saver, AlertEvent.EVENT, saving_error, this );
				App.listener_manager.add( saver, ProcessingEvent.PROGRESS, saving_progress, this );
			}
			function remove_listeners(  ):void 
			{	App.listener_manager.remove( saver, SendEvent.DONE, saving_fin );
				App.listener_manager.remove( saver, AlertEvent.EVENT, saving_error );
				App.listener_manager.remove( saver, ProcessingEvent.PROGRESS, saving_progress );
			}
			
			function start_processing(  ):void 
			{	App.mediator.processing_start( PROCESS_SAVING_MID, MSG_SAVING_MID, 99, 20, true );
			}
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERNALS */
		private function init():void
		{
			if (!is_initted)
			{
				saver = new WorkshopSaver( App.settings.MAX_EMAIL_RECIPIENTS );
				is_initted=true;
			}	
		}
		private function reuse_previous_mid( _send_data:SendEvent ):Boolean
		{
			
			// probably a smoother way to do this - but loop through and make sure at least one of the heads
			
			if(!App.asset_bucket.lastPhotoSavedURL) return false;//if(_send_data.sendMode != SendEvent.EMAIL) return true;
			
			
			if (	// there were updates so new save is required
				!App.asset_bucket.last_mid_saved ||						// we dont have a valid previous MID to use
				_send_data.sendMode == SendEvent.EMAIL ||							// we have to resend it if its an email mode
				_send_data.sendMode == SendEvent.POST)
				return false;
			
			// scene hasnt changed and we have a valid MID
			return true;
		}
		
		private function end_processing(  ):void 
		{	App.mediator.processing_ended( PROCESS_SAVING_MID );
		}
		private function crop_background( _callbacks:Callback_Struct ):void 
		{	if (App.asset_bucket.bg_controller.isUploadPhoto) 
			{	add_listeners();
				App.asset_bucket.bg_controller.crop();
				
				function bgCropFailed(evt:SceneEvent):void
				{	remove_listeners();
				}
				function bgCropped(evt:SceneEvent):void
				{	remove_listeners();
					_callbacks.fin( );
				}
				function add_listeners():void
				{	App.listener_manager.add(App.asset_bucket.bg_controller, SceneEvent.BG_CROPPED, bgCropped, this );
					App.listener_manager.add(App.asset_bucket.bg_controller, SceneEvent.BG_CROP_FAILED, bgCropFailed, this );
				}
				function remove_listeners(  ):void 
				{	App.listener_manager.remove(App.asset_bucket.bg_controller, SceneEvent.BG_CROPPED, bgCropped );
					App.listener_manager.remove(App.asset_bucket.bg_controller, SceneEvent.BG_CROP_FAILED, bgCropFailed );
				}
			}
			else setTimeout(_callbacks.fin, 250);
		}
		private function start_saving( _e:SendEvent ):void
		{	var extraData:URLVariables = new URLVariables();
			var tags:String = null;
			
			var msgParams:MessageParameters = new MessageParameters();
			/*if (_e.messageXML != null && _e.messageXML.optin.length() > 0)
			{
				msgParams.optIn = 1;//_e.messageXML.optin[0].text().toString();
				delete _e.messageXML.optin;
			}*/
			msgParams.optIn = "1";
			
			//extraData.danceIndex = App.mediator.danceIndex;
			//extraData.registerData = App.mediator.optInMessage;
			// save bg position and size
				/*if (App.mediator.scene_editing.bg != null) 
				{	var bgX			:String = App.asset_bucket.bg_controller.zoomer.x.toFixed(1);
					var bgY			:String = App.asset_bucket.bg_controller.zoomer.y.toFixed(1);
					var bgScale		:String = App.asset_bucket.bg_controller.zoomer.scale.toFixed(3);
					var bgRotation	:String = App.asset_bucket.bg_controller.zoomer.rotation.toFixed(1);
					extraData.bgPos = [bgX, bgY, bgScale, bgRotation].join(",");
					if (App.asset_bucket.bg_controller.hasDynamicMask) 
					{	var ptArr:Array = App.asset_bucket.bg_controller.getDynamicMask().getPoints();
						var pt:Point;
						for (var i:int = 0; i < ptArr.length; i++) 
						{	pt = ptArr[i];
							ptArr[i] = pt.x.toFixed(1) + "," + pt.y.toFixed(1);
						}
						extraData.maskPoints = ptArr.join(";");
					}
				}*/
			
				//var scenes:Array = [];
				var scene:SceneStruct;
				// if sharing from the big show
				if(App.asset_bucket.is_playback_mode && App.asset_bucket.mid_message)
				{
					var message:WorkshopMessage = App.asset_bucket.mid_message;

//					for(var i:Number = 0; i<message.sceneArr.length; i++)
//					{
//						var image:WSBackgroundStruct = message.sceneArr[i].bg as WSBackgroundStruct;
//						scene = new SceneStruct(null, image);
//						scenes.push(scene);
//					}
//					saver.saveWorkshop(_e, scenes, extraData, tags, msgParams);
					
					
					return;
				} 
				
				//var dances:Array = ["Classic","Soul","Hip_Hop","80s","Charleston"];
				//extraData.audioFile = "misc/"+dances[App.mediator.danceIndex]+"_"+scenes.length+".mp3";
				//extraData.audioFile = "misc/"+dances[App.mediator.danceIndex]+".mp3";
				
				function onUploadComplete(url:String):void
				{
					var bg:WSBackgroundStruct = new WSBackgroundStruct(url);//, 0, String(i), String(i), i, i);
					scene = new SceneStruct(null, bg);//, null, new Matrix(head.mouthCutPoint), new Matrix(head.mouthCutPoint));
					saver.saveWorkshop(_e, scene, extraData, tags, msgParams);
//					App.asset_bucket.lastPhotoSavedURL = url;
					
				}
				App.mediator.uploadPhoto(onUploadComplete);
				
//				if(scenes.length > 0)
//				{
//					saver.saveWorkshop(_e, scenes, extraData, tags, msgParams);
//				} else
//				{
//					saver.saveWorkshop(_e, new SceneStruct(), extraData, tags, msgParams);
//					//App.asset_bucket.last_mid_saved = "111";
//					//report_mid( "111" );
//					//saver.dispatchEvent( new SendEvent(SendEvent.DONE, "true") );
//					
//				}
			// save or resave scene
				/*if (App.asset_bucket.is_playback_mode && ServerInfo.hasMessage)	// resend the same MID in playback mode
				{	
					saver.resend(_e, ServerInfo.mid, extraData, tags, msgParams)
				}
				else if (App.mediator.scene_editing.sceneChangedSinceLastSave() || // the scene has not change
					!App.asset_bucket.last_mid_saved) 								// we dont have an MID to resave
				{	
					App.mediator.scene_editing.compile_scene( new Callback_Struct( save_scene, null, error ) );
					function error( _msg:String ):void 
					{
						App.mediator.alert_user( new AlertEvent(AlertEvent.ALERT, 'f9t533', 'unable to save at this time', { details:_msg } ) );
						end_processing();
					}
					
					 //once all the data is prepared start the saving process
					 
					function save_scene( _scene:SceneStruct ):void 
					{	
						saver.saveWorkshop(_e, _scene, extraData, tags, msgParams);
					}
				}
				else 
					saver.resend(_e, App.asset_bucket.last_mid_saved, extraData, tags, msgParams);*/
		}
		private function save_complete( _msg_event:SendEvent, _callbacks:Callback_Struct):void
		{	// track only if the MID has changed
			var cur_mid:String;
			if (_msg_event && _msg_event.messageXML)					cur_mid = _msg_event.messageXML.@MID;
			if (cur_mid != App.asset_bucket.last_mid_saved)	WSEventTracker.event("edsv");
			//if (App.mediator.scene_editing.full_body_ready())
			//	App.mediator.scene_editing.full_body.scene_was_saved();
			trace("MID_Save::save_complete::"+_msg_event.messageXML);
			
			App.asset_bucket.last_mid_saved = cur_mid;
			
			var doc_query	:String = ServerInfo.acceleratedURL + 'php/api/playScene/doorId=' + ServerInfo.door + '/clientId=' + ServerInfo.client + '/mId=' + cur_mid;
			Gateway.retrieve_XML( doc_query, new Callback_Struct( fin_fin, null, error ) );
			function fin_fin( _content:XML ):void 
			{	
				trace("MidSave::saving_fin::fin_fin: "+_content);;
				var result:String = unescape(_content.toString().split("+").join(" "));
				
				var mid_message:WorkshopMessage = new WorkshopMessage( parseInt(App.asset_bucket.last_mid_saved) );
				mid_message.parseXML( _content);
				
				for(var i:Number = 0; i<mid_message.sceneArr.length; i++)
				{
					var scene:SceneStruct = mid_message.sceneArr[i];
					var image:WSBackgroundStruct = mid_message.sceneArr[i].bg as WSBackgroundStruct;
					if(image && image.url) 
					{
						trace("AFTER MIDSAVE: "+image.url);
						App.asset_bucket.lastPhotoSavedURL = image.url;
					}
				}				
				end_processing();
				if (_callbacks && _callbacks.fin != null)
					_callbacks.fin();
			}
			function error(e:*):void
			{
				
			}
			
			
			//image:WSBackgroundStruct = mid_message.sceneArr[i].bg as WSBackgroundStruct;
			//App.asset_bucket.lastPhotoSavedURL = _msg_event.messageXML.@bg
			report_mid( cur_mid );
		}
		/**
		 * report new mid creation 
		 * @param _new_mid
		 * 
		 */		
		private function report_mid( _new_mid:String ):void
		{
			/** http://intranet.oddcast.com/wiki/index.php/RandD:Multi-tier_tracking_system
				doorId = Door id
				mId = Message id
				dId = Distribution id
				baseMid = Parent message id
			 */
			var vars:URLVariables = new URLVariables();
			vars.mId = _new_mid;
			vars.doorId = ServerInfo.door;
			if (ServerInfo.distribution_id)
				vars.dId = ServerInfo.distribution_id;
			if (ServerInfo.parent_mId)
				vars.baseMid = ServerInfo.parent_mId;
			
			var url:String = ServerInfo.distribution_id_reporting_url;
			var request:Gateway_Request = new Gateway_Request( url, new Callback_Struct( fin, progress, error ) );
			request.background = true;
			Gateway.upload( vars, request );
			function fin( _content:String ) : void
			{				
				trace(_content);
			}
			function progress( _percent:int ) : void
			{
			}
			function error( _msg:String ) : void 
			{
				trace(_msg);
			}
		}
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** KEYBOARD SHORTCUTS */
		/************************************************
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		*/
		
	}

}