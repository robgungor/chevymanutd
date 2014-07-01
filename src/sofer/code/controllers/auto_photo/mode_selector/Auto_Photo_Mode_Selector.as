package code.controllers.auto_photo.mode_selector 
{
	import code.HeadStruct;
	import code.controllers.auto_photo.auto_photo.Auto_Photo;
	import code.controllers.auto_photo.search.Auto_Photo_Search;
	import code.models.*;
	import code.skeleton.*;
	import code.utils.ImageSearcher;
	
	import com.oddcast.data.ThumbSelectorData;
	import com.oddcast.event.SelectorEvent;
	import com.oddcast.workshop.Persistent_Image.IPersistent_Image_Item;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSEventTracker;
	
	import fl.text.TLFTextField;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import workshop.persistent_image.Persistent_Image_Selector_Item;
	import workshop.ui.LocalizedButton;

	/**
	 * ...
	 * @author Me^
	 */
	public class Auto_Photo_Mode_Selector implements IAuto_Photo_Mode_Selector
	{
		private var ui		:Mode_Selection_UI;
		
		public function Auto_Photo_Mode_Selector( _ui:Mode_Selection_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui		= _ui;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				// init this after the application has been inaugurated
				
				init();
				
				open_win();
			}
		}
		private function init(  ):void 
		{	
			App.listener_manager.add_multiple_by_object([
				ui.btn_upload, 
				ui.btn_facebook, 
				ui.btn_webcam,
				ui.btn_googleplus,
				ui.btn_renren,
				ui.btn_weibo
				 ], MouseEvent.CLICK, btn_handler, this);
					
		}
		
		private function show_terms( _e:MouseEvent ):void 
		{
			App.mediator.open_hyperlink(App.settings.TERMS_CONDITIONS_LINK, "_blank");
		}
		private var _termsHasBeenClicked:Boolean = false;
//		private function _onCbClicked( e:MouseEvent = null):void
//		{
//			if(ui.accept_Cb.selected)
//			{
//				ui.btn_browse.mouseEnabled = ui.btn_facebook.mouseEnabled = ui.btn_webcam.mouseEnabled = true;
//				ui.btn_browse.alpha = ui.btn_facebook.alpha = ui.btn_webcam.alpha = 1;
//				// they might ask for this...
//				_termsHasBeenClicked = true;
//				
//			} else
//			{
//				ui.btn_browse.mouseEnabled = ui.btn_facebook.mouseEnabled = ui.btn_webcam.mouseEnabled = false;
//				ui.btn_browse.alpha = ui.btn_facebook.alpha = ui.btn_webcam.alpha = .35;
//			}
//			
//		}
		public function get optedIn():Boolean
		{
			return ui.accept_Cb.selected;
		}
		/**
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
		 * **************************************************************/
		public function open_win(  ) : void
		{
			ui.visible = true;	
				
			_localize();
						
			App.ws_art.oddcast.visible = true;
			
			// set
			//_onCbClicked();
			//populate_selector();
		}
		
		private function _localize():void
		{
			
			App.localizer.localize(this.ui, "homescreen");
			//ui.btn_terms.btn_terms.underline.width = (ui.btn_terms.btn_terms.btntxt_terms ).textWidth;
			var terms:btn_termsofuse_simple = ui.btn_terms.getChildByName("us") as btn_termsofuse_simple;
			
			// simpleButtons are the worst thing in the world
			if(terms) 
			{
				var upState:DisplayObjectContainer = terms.upState as DisplayObjectContainer;
				var underline:MovieClip;
				var tf:*;
				var child:*
				if(upState)
				{
					for (var i:Number = 0; i < upState.numChildren; i++){
						child = upState.getChildAt(i);
						if(child is MovieClip) underline = child;
						else tf = child;
					}
					
					if(underline && tf) underline.width = tf.textWidth;
				}
				
				var overState:DisplayObjectContainer = terms.overState as DisplayObjectContainer;
				
				if(overState)
				{
					for (i = 0; i < overState.numChildren; i++){
						child = overState.getChildAt(i);
						if(child is MovieClip) underline = child;
						else tf = child;
					}
					
					if(underline && tf) underline.width = tf.textWidth;
				}
				
				var downState:DisplayObjectContainer = terms.downState as DisplayObjectContainer;
				
				if(downState)
				{
					for (i = 0; i < downState.numChildren; i++){
						child = downState.getChildAt(i);
						if(child is MovieClip) underline = child;
						else tf = child;
					}
					
					if(underline && tf) underline.width = tf.textWidth;
				}
				
				var hitState:* = terms.hitTestState;
				hitState.width = underline.width;			
			
			}
			if(ServerInfo.lang == "jp") ui.title_upload.y = 25;
			
			ui.btn_facebook.visible = ui.btn_googleplus.visible = ServerInfo.lang != "cn";
			ui.btn_renren.visible = ui.btn_weibo.visible = ServerInfo.lang == "cn";
		}
		
		public function close_win(  ) : void
		{
			ui.visible = false;			
			App.ws_art.oddcast.visible = false;
		}
		/*****************************************************************
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
		 * 
		 * 
		 * 
		 * **************************************************************/
		private function btn_handler( _e:MouseEvent ):void 
		{				
			switch (_e.currentTarget) 
			{	
				case ui.btn_upload:			App.mediator.checkOptIn(App.mediator.autophoto_mode_browse);		
											WSEventTracker.event("ce4");			
											break;
				case ui.btn_facebook:	
					WSEventTracker.event("ce1");
					App.mediator.checkOptIn(_optInSearchConfirm);
					
					
					//App.mediator.autophoto_mode_search();
					//close_win();
					break;
				case ui.btn_googleplus: 
					WSEventTracker.event("ce2");
					App.mediator.autophoto_mode_search( Auto_Photo_Search.GOOGLE_PLUS );
					break;
				
				case ui.btn_renren: 
					App.mediator.autophoto_mode_search( Auto_Photo_Search.REN_REN );
					break;
				case ui.btn_weibo: 
					App.mediator.autophoto_mode_search( Auto_Photo_Search.WEIBO );
					break;
				case ui.btn_webcam:			
					WSEventTracker.event("ce3");
					App.mediator.checkOptIn(_webCamConfirm);
							break;
				case ui.btn_close:			close_win();
			}
			
		}
		private function _optInSearchConfirm():void
		{
			
			App.mediator.autophoto_mode_search( Auto_Photo_Search.FACEBOOK );
			
			close_win();
		}
		private function _webCamConfirm():void
		{
			close_win();
			
			App.mediator.autophoto_mode_webcam();
		}
		/*****************************************************************
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
		 */
		
		private function image_selected( _e:SelectorEvent ):void 
		{
			//if(!ui.accept_Cb.selected) return;
			//App.mediator.checkOptIn( image_selected_fin );
			image_selected_fin();
			function image_selected_fin():void {
				var head		:HeadStruct		= _e.currentTarget.data as HeadStruct;
				//var selected_image	:IPersistent_Image_Item	= wrapper_obj.obj as IPersistent_Image_Item; 
				//App.mediator.persistant_swap_head(head);
				//WSEventTracker.event("ce9");
				WSEventTracker.event("edbgs",head.url);
				close_win();
			
			}
		}
		
		private function populate_selector(  ):void 
		{
			ui.image_selector.clear();
			var num_of_images:int = App.mediator.persistantImages.length;//pi_api.get_num_of_images();
			for (var i:int = 0; i < num_of_images; i++) 
			{
				var cur_image:HeadStruct = App.mediator.persistantImages[i];
				var id:int = parseInt( cur_image.url );
				//var image:ThumbSelectorData = new ThumbSelectorData( cur_image.id, cur_image);
				var nume:String = '';
				ui.image_selector.add( i, nume, cur_image, false );
			}
			ui.image_selector.update();
		}
	}

}