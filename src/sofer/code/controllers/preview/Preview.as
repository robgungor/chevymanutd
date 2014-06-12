package code.controllers.preview
{
	import code.skeleton.App;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import org.casalib.util.RatioUtil;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Preview
	{
		/** user interface for this controller */
		private var ui					:PreviewUI;
		/** button, generally outside of the UI which opens this view */
		private var btn_open			:DisplayObject;
		
		/*******************************************************
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
		 * ******************************** INIT */
		/**
		 * Constructor
		 */
		public function Preview( _ui:PreviewUI) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			//			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_PLAYBACK_STATE;
			//			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to the controllers UI
			ui			= _ui;
			
			//btn_open	= _btn_open;
			
			// provide the mediator a reference to communicate with this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// calls made before the initialization starts
			close_win();
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
				// init this after the application has been inaugurated
				init();
			}
		}
		/**
		 * initializes the controller if the check above passed
		 */
		private function init(  ):void 
		{	
			_faceSize = new Rectangle( ui.photo.face.x, ui.photo.face.y, ui.photo.face.width, ui.photo.face.height );
			init_shortcuts();
			set_ui_listeners();
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
		 ***************************** PUBLIC INTERFACE */
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
		 ***************************** PRIVATE */
		/*******************************************************
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
		 * ******************************** VIEW MANIPULATION - PRIVATE */
		/**
		 * displays the UI
		 * @param	_e
		 */
		public function open_win(  ):void 
		{	
			ui.visible = true;
			set_tab_order();
			set_focus();
		}
		/**
		 * hides the UI
		 * @param	_e
		 */
		private function close_win(  ):void 
		{	
			ui.visible = false;
		}
		/**
		 * adds listeners to the UI
		 */
		private function set_ui_listeners():void 
		{
			App.listener_manager.add_multiple_by_object( 
				[
					//btn_open,
					ui.btn_googleplus,
					ui.btn_upload_new 
				], MouseEvent.CLICK, mouse_click_handler, this );
			
			
		}
		/**
		 * handler for Click MouseEvents from the UI
		 * @param	_e
		 */
		private function mouse_click_handler( _e:MouseEvent ):void
		{
			switch ( _e.currentTarget )
			{	
//				case btn_open:		
//					open_win();		
//					break;
				case ui.btn_googleplus:
					App.mediator.postToGooglePlus();
					break;
				case ui.btn_upload_new:	
					close_win();
					App.mediator.autophoto_open_mode_selector();
					break;
			}
		}
		/**
		 *sets the tab order of ui elements 
		 * 
		 */		
		private function set_tab_order():void
		{
			App.utils.tab_order.set_order( [ ui.tf_one, ui.tf_two, ui.btn ] );// SAMPLE
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
		 ***************************** KEYBOARD SHORTCUTS */
		/**
		 * sets stage focus to the UI
		 */
		private function set_focus():void
		{	
			ui.stage.focus = ui;
		}
		/**
		 * initializes keyboard shortcuts
		 */
		private function init_shortcuts():void
		{	
			App.shortcut_manager.api_add_shortcut_to( ui, Keyboard.ESCAPE, shortcut_close_win );
		}
		/**
		 * hides the UI
		 */
		private function shortcut_close_win(  ):void 		
		{	
			if (ui.visible)		
				close_win();	
		}
		/************************************************
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 */
		protected var _faceSize:Rectangle;
		public function placeHead( bmp:Bitmap, contrast:Number, chinPoint:Point):void
		{
			
			if(bmp.bitmapData) bmp = new Bitmap(bmp.bitmapData, "auto", true);
			
			//var size:Rectangle = new Rectangle( ui.photo.face.x, ui.photo.face.y, ui.photo.face.width, ui.photo.face.height )
			
			var headSize	:Rectangle 	= RatioUtil.scaleToFill( new Rectangle(0,0,bmp.width, bmp.height), _faceSize);

			//set size
//			bmp.width 				= headSize.width;
//			bmp.scaleY 				= bmp.scaleX;
			var body:BodyImage = ui.photo.body;
			// set body contras
			for (var i:int = 0; i < body.numChildren; i++){				
				body.getChildAt(i).visible = false;
			}			
			// these are indexed at 1, the other is indexed at 0
			body.getChildByName("photo_"+(contrast+1)).visible = true;
			//center the bitmap in the head
			var hold:MovieClip = ui.photo.face.head_hold;
			bmp.x = (hold.x/hold.scaleX)-(chinPoint.x);//(_faceSize.width/2)-(bmp.width/2);
			bmp.y = (hold.y/hold.scaleY)-(chinPoint.y);//-_faceSize.y;
			for(i = 0; i<hold.numChildren; i++)
			{
				if(hold.getChildAt(i) != null) hold.removeChildAt(i);
			}
			hold.addChild(bmp);
			//if(ui.photo.face.numChildren > 0) ui.photo.face.removeChildAt( 0 );
			//ui.photo.face.addChild( bmp );
		}
		public  function take_snapshot():Bitmap{
			
			var data:BitmapData = new BitmapData(ui.photo.width, ui.photo.height, true, 0x000000);	
			var mat:Matrix = new Matrix();	
			data.draw(ui.photo);//,null,null,null,new Rectangle(face_masker.getMask().x, face_masker.getMask().y, face_masker.getMask().width, face_masker.getMask().height), true);
			var map:Bitmap = new Bitmap(data, "auto", true);			
				
			return map;
		}
	}
	
}