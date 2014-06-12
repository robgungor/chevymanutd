package custom
{
	import code.skeleton.App;
	
	import com.oddcast.workshop.WSEventTracker;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	

	
	public class PhotoMaskingScreen 
	{
		private var in_snapshot:Bitmap;
		private var initialized:Boolean; 
		public var btn_submit:SimpleButton;
		public var btn_back:SimpleButton;
		public var face_masker:FaceMasker;
		private var standard_points:Array;
		public var face_holder:MovieClip;
		private var ui:PhotoMaskingScreen_UI;
		/**
		 * 
		 */
		public function PhotoMaskingScreen()
		{
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED_EDITING_STATE;
			
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to UI and external assets
			ui		= App.ws_art.mc_masking_screen;
			ui.visible 				= false;
			face_holder				= App.ws_art.auto_photo_position.placeholder_apc;
			btn_submit				= ui.btn_submit;
			btn_back				= ui.btn_back;
			
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
			}
		}
		private function init(  ):void 
		{	
			face_masker 			= new FaceMasker();
			standard_points 		= create_outline_points(new Rectangle(50, 40, 130, 170));
			
			App.listener_manager.add_multiple_by_object( [ 	ui.btn_submit,
				ui.btn_back, ui.btn_close] , MouseEvent.CLICK, btn_step_handler, this);
		}
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERFACE */
		public function open_win(  ):void
		{
			//ui.visible = true;
			App.mediator.autophoto_submit_mask_position();
			//ui.placeholder_apc.addChild( App.mediator.autophoto_get_apc_display() );
		}
		public function close_win(  ):void
		{
			ui.visible = false;
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
		/*
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		* 
		***************************** INTERNALS */
		private function btn_step_handler( _e:MouseEvent ):void
		{
			switch ( _e.target )
			{	
				case ui.btn_back:		App.mediator.autophoto_position_photo();
					break;
				case ui.btn_submit:				
					App.mediator.autophoto_submit_mask_position();
					//WSEventTracker.event("ce10");
					break;
				case ui.btn_close:
					App.mediator.autophoto_close();
					close_win();
					break;
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
		 */
		/**
		 * 
		 */
		public function mask(snapshot:Bitmap):void 
		{
			//if (initialized) return;
			if(initialized) destroy();
			in_snapshot = snapshot;
			initialized = true;
			click_submit();
			return;
			//Bridge.core.cached_snapshots.makingSnapshot = snapshot;
			face_holder.bgHolder.addChild(snapshot);
			ui.visible = true; //Bridge.tween_item(this);
			add_listeners(true);
			init_facemasker();
			//face_holder.bgHolder.x = face_masker.getMask().x;
			//face_holder.bgHolder.y = face_masker.getMask().y;
			//trace("face_holder.bgHolder.x"+face_holder.bgHolder.x+" ;face_masker.getMask().x: "+face_masker.getMask().x);
		}
		
		/**
		 * 
		 */
		public function destroy():void
		{
			if (!initialized)
				return;
			initialized 		= false;
			ui.visible 			= false;
			destroy_facemasker();
			add_listeners(false);
		}
		
		/**
		 * 
		 * @param	add
		 */
		private function add_listeners(add:Boolean):void
		{
			if (add){
				ui.btn_submit.addEventListener(MouseEvent.CLICK, click_submit);
				ui.btn_back.addEventListener(MouseEvent.CLICK, click_backBtn);
			}else {
				ui.btn_submit.removeEventListener(MouseEvent.CLICK, click_submit);
				ui.btn_back.removeEventListener(MouseEvent.CLICK, click_backBtn);
			}
		}
		
		

		private function take_snapshot():Bitmap{
			//face_masker.hidePoints();
			/*face_holder.bgHolder.x = face_masker.getMask().x=  -face_masker.getPointsBoundingBox(face_masker.getPoints()).x;
			face_holder.bgHolder.y = face_masker.getMask().y = -face_masker.getPointsBoundingBox(face_masker.getPoints()).y;
*/			
			
			var data:BitmapData = new BitmapData(App.ws_art.auto_photo_position.placeholder_apc.width, App.ws_art.auto_photo_position.placeholder_apc.height, true, 0x000000);
			var mat:Matrix = new Matrix();
			//mat.translate( -p.x, -p.y);	
			data.draw(face_holder)//,null,null,null,new Rectangle(face_masker.getMask().x, face_masker.getMask().y, face_masker.getMask().width, face_masker.getMask().height), true);
			var map:Bitmap = new Bitmap(data, "auto", true);
			//face_masker.showPoints();
			return map;
		}
		
        private function init_facemasker():void
		{
			/*
			face_masker.setDimensions( new Point(226,191), new Point(face_holder.width, face_holder.height) );
			face_masker.setCenterPoint( new Point( 315, 182 ));
			face_masker.hideCursorWhenDragging(true);
			face_masker.setDynamicPoints(true);
			face_masker.setOutline(true,0x345667);
			face_holder.mask 		= face_masker.getMask();
			face_masker.x 			= 206;
			face_masker.y 			= 96; */
			
			face_masker = new FaceMasker();
			face_masker.setMaskingMode("JJ");
			face_masker.setPointIcon(MaskPointArt_UI);
			face_masker.setDimensions( new Point(505, 382), new Point(505, 382) );
			face_masker.setCenterPoint( new Point( 252, 191 ));
			face_masker.hideCursorWhenDragging(true);
			face_masker.setDynamicPoints(true);
			face_masker.setOutline(true, 0x345667);
			face_masker.x 			= 0;
			face_masker.y 			= 0;
			face_holder.addChild(face_masker);
			face_holder.bgHolder.mask = face_masker.getMask();
			ui.addChild(ui.btn_submit);
			face_masker.setPoints(standard_points);
			face_masker.init();
		//	face_masker.addEars();
		}
		
		/**
		 * 
		 * @param	_rect
		 * @return
		 */
        private function create_outline_points( _rect:Rectangle ):Array
		{
			trace('___ ::: custom.PhotoMaskingScreen.create_outline_points() ', _rect);
			_rect.width 				*= 0.5;
			_rect.height 				*= 0.5;
			var two_PI:Number 			= 2 * Math.PI;
			var phase_shift:Number 	= 0.25 * two_PI;
			var increment:Number 		= two_PI * 0.05;
			var points_arr:Array 		= new Array();
			var mid_point:Point 		= new Point(_rect.x + _rect.width, _rect.y + _rect.height)

			for( var t:Number = 0; t < two_PI; t += increment)
			{
				points_arr.push
					(
						new Point(
							_rect.width * Math.cos(t - phase_shift) + mid_point.x,
							- _rect.height * Math.sin(t - phase_shift) + mid_point.y
						)
					)
			}
			return points_arr;
		}
		
		
		/**
		 * 
		 */
		private function destroy_facemasker():void
		{
			if (in_snapshot) {
				//face_holder.bgHolder.removeChild(in_snapshot);
				in_snapshot = null;
			}
			
			if(face_masker){
				face_masker.destroy();
				//face_holder.removeChild(face_masker);
				face_masker = null;
			}
		}
		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		public function click_submit(evt:Event=null):void {
			var snapshot:Bitmap = take_snapshot();
			//Bridge.core.mc_game_screen.init(snapshot);
			create_saveInfo_masking();
			App.mediator.save_masked_photo(snapshot);
			destroy();
			//WSEventTracker.event("ce4");
		}
		public function click_backBtn(evt:Event=null):void {
			//Bridge.core.mc_photo_position_panel.init();
			destroy();
		}
		
		private function create_saveInfo_masking():void {
			var ptArr:Array = face_masker.getPoints();
			var pt:Point;
			for (var i:int = 0; i < ptArr.length; i++) {
				pt = ptArr[i];
				ptArr[i] = pt.x.toFixed(1) + "," + pt.y.toFixed(1);
			}
			//Bridge.core.createMidInfo.maskPoints = ptArr.join(";");
		}
		//++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	}
}