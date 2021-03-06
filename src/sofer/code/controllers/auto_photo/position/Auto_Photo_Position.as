﻿package code.controllers.auto_photo.position 
{
	import code.controllers.auto_photo.apc.Auto_Photo_APC;
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.event.*;
	import com.oddcast.photo.OFCWrapper;
	import com.oddcast.utils.*;
	import com.oddcast.workshop.ServerInfo;
	import com.oddcast.workshop.WSEventTracker;
	
	import custom.SlideBar;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.*;
	
	import org.casalib.util.NumberUtil;
	import org.casalib.util.RatioUtil;
	

	
	/**
	 * ...
	 * @author Me^
	 */
	public class Auto_Photo_Position //implements IAuto_Photo_Position
	{
		private var ui			:Position_UI;
		private var face_finding_utility:OFCWrapper;
		protected var image_positioner:MoveZoomUtil;
		
		public function Auto_Photo_Position( _ui:Position_UI ) 
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
			}
		}
		private function init(  ):void 
		{	
			_imageHold 	= App.ws_art.auto_photo_position.placeholder_apc.image_hold;
			_mask		= App.ws_art.auto_photo_position.placeholder_apc.mask_mc;
			_changeHairstyle(1);
			_changeContrast(0);
			
			App.mediator.autophoto_set_apc_display_size( new Point(_imageHold.width, _imageHold.height ) );
			
			App.listener_manager.add( ui.btn_close, MouseEvent.CLICK, btn_step_handler, this);
			App.listener_manager.add( ui.btn_next, MouseEvent.CLICK, btn_step_handler, this);
			App.listener_manager.add( ui.btn_back, MouseEvent.CLICK, btn_step_handler, this);
			
			App.listener_manager.add( ui.btn_hairstyle_right, MouseEvent.CLICK, _onHairstyleChangeClick, this);
			App.listener_manager.add( ui.btn_hairstyle_left, MouseEvent.CLICK, _onHairstyleChangeClick, this);
			
			App.listener_manager.add( ui.btn_zoom_in, MouseEvent.MOUSE_DOWN, _onZoomPlus, this);
			App.listener_manager.add( ui.btn_zoom_out, MouseEvent.MOUSE_DOWN, _onZoomMinus, this);
			
			App.listener_manager.add( ui.btn_contrast_less, MouseEvent.CLICK, _onContrastChangeClick, this);
			App.listener_manager.add( ui.btn_contrast_more, MouseEvent.CLICK, _onContrastChangeClick, this);
			
			App.listener_manager.add_multiple_by_object( [	ui.btn_move_up,
															ui.btn_move_down,
															ui.btn_move_right,
															ui.btn_move_left,
															
 															ui.btn_reset], MouseEvent.MOUSE_DOWN, btn_position_handler, this);
			
			_rotationSlider = new SlideBar(App.ws_art.auto_photo_position.rotate_handle, App.ws_art.auto_photo_position.rotate_slider_bar, App.ws_art.auto_photo_position.btn_rot_cc, App.ws_art.auto_photo_position.btn_rot_c);
			//_zoomSlider 	= new SlideBar(App.ws_art.auto_photo_position.zoom_handle, App.ws_art.auto_photo_position.zoom_slider_bar, App.ws_art.auto_photo_position.btn_zoom_in, App.ws_art.auto_photo_position.btn_zoom_out);
			//_zoomSlider.addEventListener(Event.CHANGE, _onZoomSliderChange);
			_rotationSlider.addEventListener(Event.CHANGE, _onRotationSliderChange);
			
			ui.cutter.addEventListener(MouseEvent.MOUSE_DOWN, _onCutterMouseDown);
			ui.cutter.addEventListener(MouseEvent.MOUSE_UP, _onCutterMouseUp);
			ui.cutter.buttonMode = true;
			
			_zoomTimer = new Timer(25);
			_zoomTimer.addEventListener(TimerEvent.TIMER, _onZooming);
		}
		protected function _onCutterMouseDown(e:MouseEvent):void
		{
			var bounds:Rectangle = new Rectangle();
			bounds.bottom 	= ui.placeholder_apc.mask_mc.localToGlobal(new Point(0, ui.placeholder_apc.mask_mc.height-20)).y;
			bounds.top 		= ui.placeholder_apc.y+100;
			bounds.left 	= ui.cutter.x;
			bounds.right 	= ui.cutter.x;
			
			ui.cutter.startDrag(false, bounds);
			ui.stage.addEventListener(MouseEvent.MOUSE_UP, _onCutterMouseUp);	
		}
		public function get cutPoint():Number
		{
			return _mask.globalToLocal(new Point(0,ui.cutter.y+17)).y;
		}
		protected function _onCutterMouseUp(e:Event):void
		{
			ui.cutter.stopDrag();
			ui.stage.removeEventListener(MouseEvent.MOUSE_UP, _onCutterMouseUp);
		}
		protected function _onZoomSliderChange(e:Event):void
		{
			var scale:Number;//= NumberUtil.map( _zoomSlider.value, 0, 1, MIN_ZOOM, MAX_ZOOM);
			if(_zoomSlider.value < .5)
			{
				scale = NumberUtil.map( _zoomSlider.value, 0, .5, MIN_ZOOM, 1);
			}
			if(_zoomSlider.value >= .5)
			{
				scale = NumberUtil.map( _zoomSlider.value, .5, 1, 1, MAX_ZOOM);
			}
			App.mediator.autophoto_zoom_to(scale);
		}
		protected var _zoomTimer:Timer;
		protected var _zoomDir:String;
		protected var _timeoutID:uint;
		protected function _onZoomPlus(e:MouseEvent):void
		{
			_zoomDir = Auto_Photo_APC.ZOOM_IN;
			_timeoutID = setTimeout(_zoomTimer.start, 75);
			ui.stage.addEventListener(MouseEvent.MOUSE_UP, _onZoomMouseUp);
			App.mediator.autophoto_move_photo(Auto_Photo_APC.ZOOM_IN, 0);
		}
		protected function _onZoomMinus(e:MouseEvent):void
		{
			_zoomDir = Auto_Photo_APC.ZOOM_OUT;			
			_timeoutID = setTimeout(_zoomTimer.start, 75);
			ui.stage.addEventListener(MouseEvent.MOUSE_UP, _onZoomMouseUp);
			App.mediator.autophoto_move_photo(Auto_Photo_APC.ZOOM_OUT, 0);
			
		}
		protected function _onZoomMouseUp(e:MouseEvent):void
		{
			if(_timeoutID) clearTimeout(_timeoutID);
			ui.stage.removeEventListener(MouseEvent.MOUSE_UP, _onZoomMouseUp);
			_zoomTimer.stop();
		}
		protected function _onZooming(e:TimerEvent):void
		{
			App.mediator.autophoto_move_photo(_zoomDir, 0);
		}
		
		protected function _onRotationSliderChange(e:Event):void
		{
			var rot:Number = NumberUtil.map( _rotationSlider.value, 1, 0, -MAX_ROTATION, MAX_ROTATION);
			App.mediator.autophoto_rotate_to(rot);
		}
		
		protected function _onHairstyleChangeClick(e:Event):void
		{
			var direction:int = e.currentTarget == ui.btn_hairstyle_left ? -1 : 1;
			_changeHairstyle( direction );
			WSEventTracker.event("ce9");
			
		}
		
		protected function _onContrastChangeClick(e:Event):void
		{
			var direction:Number = e.currentTarget == ui.btn_contrast_less ? -1 : 1;
			_changeContrast( direction );
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
		***************************** interface methods */
		protected var _imageHold:MovieClip;
		protected var _rotationSlider:SlideBar;
		protected var _zoomSlider:SlideBar;
		
		protected var _mask:DisplayObject;
		public function open_win(fromWebcam:Boolean):void 
		{	
			ui.visible = true;
			App.localizer.localize(this.ui, "adjust");
			
			if(ServerInfo.lang == 'ru')
			{
				adjustSize(ui.hairstyle, .8);
				adjustSize(ui.rotate, .8);
				adjustSize(ui.zoom, .8);
				adjustSize(ui.contrast, .8);
				ui.subtitle.y = 90;
			}
			
			function adjustSize(tf:TextField, amount:Number):void
			{
				var format:TextFormat = tf.defaultTextFormat;
				format.size = format.size.valueOf()*amount;
				tf.defaultTextFormat = format;
				if(tf.text) tf.setTextFormat(format, 0, tf.text.length);
			}
			App.ws_art.oddcast.visible = false;
			if(_imageHold.numChildren > 0)
			{
				for(var i:Number = 0; i<_imageHold.numChildren; i++)
				{
					_imageHold.removeChild(_imageHold.getChildAt(i));					
				}
			}
			
			_mask.cacheAsBitmap = true;
			_imageHold.mask = _mask;
			App.mediator.autophoto_get_apc_display().addEventListener(MouseEvent.MOUSE_DOWN, _onImageMouseDown);
			
			_imageHold.addChild( App.mediator.autophoto_get_apc_display() );
			
			_resetPosition();
			
			if(!fromWebcam) _findAndPositionFace();				
		}
		
		public function reopen_win():void
		{
			ui.visible = true;
			
			_imageHold.buttonMode = true;
			App.mediator.autophoto_get_apc_display().addEventListener(MouseEvent.MOUSE_DOWN, _onImageMouseDown);
			
		}
		
		protected function _findAndPositionFace():void
		{				
			return;
				var _bmp:Bitmap = App.mediator.autophoto_get_apc_oriBitmap();
				
				var curX:Number;
				var curY:Number;
				var curRot:Number;
				var curScale:Number;
				var face_location:Array = ( face_finding_utility.find_face(_bmp.bitmapData) );
							
//				if (face_location != null) {	
//					trace("face_location 111===> "+face_location[0]+"  "+face_location[1]+"  "+face_location[2]+"  "+face_location[3]);
//					curX	= -face_location[0];
//					curY	= -face_location[1]-25;
//					curRot 	= ( -180 * face_location[3] / Math.PI);
//					curScale = (face_location[2] / 14);
//				}else {
//					trace("face_location 222===> null: "+_bmp.width+"  "+_bmp.height);
//					curX = -_bmp.width  * 0.5;
//					curY = -_bmp.height * 0.5;
//					curRot=0;
//					curScale = Math.max((256 / _bmp.width), (256 / _bmp.height));
//				}
//				
//				_bmp.x = curX;
//				_bmp.y = curY;
//				image_positioner.scaleTo(curScale);
//				image_positioner.rotateTo(curRot);
//				
//				ui_position.position_controls.updateOriPosition((face_location!=null), curX, curY, curScale, curRot);
//				
//				
				
				
				
				
				
				
				
				
				
				if (face_location != null) {	
					trace("face_location 111===> "+face_location[0]+"  "+face_location[1]+"  "+face_location[2]+"  "+face_location[3]);
					curX= -face_location[0];
					curY= -face_location[1]-25;
					curRot = ( -180 * face_location[3] / Math.PI);
					curScale = (face_location[2] / 14);
					
					_bmp.scaleX = _bmp.scaleY = curScale;
					_bmp.x = curX;
					_bmp.y = curY;
					
					App.mediator.autophoto_rotate_to(curRot);
					
				}else {
					trace("face_location 222===> null: "+_bmp.width+"  "+_bmp.height);
					curX = _bmp.x//-_bmp.width  * 0.5;
					curY = -_bmp.y;
					curRot=0;
					curScale = _bmp.scaleY;//Math.max((256 / _bmp.width), (256 / _bmp.height));
								
					var scaled:Rectangle = RatioUtil.scaleToFill(_bmp.bitmapData.rect, new Rectangle(0,0,App.mediator.autophoto_get_apc_display_size().x, App.mediator.autophoto_get_apc_display_size().y));
					
					_bmp.width = scaled.width;
					_bmp.height = scaled.height;
					
					_bmp.x = -Math.round(_bmp.width/2);
					_bmp.y = -Math.round(_bmp.height/2);
					
				}
				
				trace("App.mediator.autophoto_get_apc_display().x: "+App.mediator.autophoto_get_apc_display().x);
			//+++++++++++++++++++++++++++++++++
		}
		
		protected function _resetPosition():void
		{
			_rotationSlider.value = NumberUtil.map(0, -MAX_ROTATION, MAX_ROTATION, 0, 1);
			//ghetto fab
			//_zoomSlider.removeEventListener(Event.CHANGE, _onZoomSliderChange);
			trace("App.mediator.autophoto_zoomer_scale(): "+App.mediator.autophoto_zoomer_scale());
			//_zoomSlider.value = App.mediator.autophoto_zoomer_scale()/2;///.5;//NumberUtil.map(1, MIN_ZOOM, MAX_ZOOM, 0, 1);
			//_zoomSlider.addEventListener(Event.CHANGE, _onZoomSliderChange);
			//App.mediator.autophoto_get_apc_display().scaleX = App.mediator.autophoto_get_apc_display().scaleY = 1;
			App.mediator.autophoto_get_apc_display().x = Math.round(App.mediator.autophoto_get_apc_display_size().x/2);
			App.mediator.autophoto_get_apc_display().y = Math.round(App.mediator.autophoto_get_apc_display_size().y/2);
		}
		public function close_win():void 
		{	
			ui.visible = false;
			
			if(App.mediator.autophoto_get_apc_display())	
			{
				trace("CLOSE autophoto_get_apc_display x: "+App.mediator.autophoto_get_apc_display().x+"; y: "+App.mediator.autophoto_get_apc_display().y);
		
				App.mediator.autophoto_get_apc_display().removeEventListener(MouseEvent.MOUSE_DOWN, _onImageMouseDown);
				_imageHold.buttonMode = true;
			}
		}
		protected function _onImageMouseDown(e:MouseEvent):void
		{
			(App.mediator.autophoto_get_apc_display() as Sprite).startDrag();
			App.mediator.autophoto_get_apc_display().addEventListener(MouseEvent.MOUSE_UP, _onImageMouseUp);
			App.ws_art.stage.addEventListener(MouseEvent.MOUSE_UP, _onImageMouseUp);
		}
		protected function _onImageMouseUp(e:MouseEvent):void
		{
			(App.mediator.autophoto_get_apc_display() as Sprite).stopDrag();
			App.mediator.autophoto_get_apc_display().removeEventListener(MouseEvent.MOUSE_UP, _onImageMouseUp);
			App.mediator.autophoto_update_zoomer_bounds();
			App.ws_art.stage.removeEventListener(MouseEvent.MOUSE_UP, _onImageMouseUp);
			
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
		***************************** PRIVATEEEEEERS */
		private function btn_step_handler( _e:MouseEvent ):void 
		{	switch ( _e.currentTarget )
			{	case ui.btn_back:		App.mediator.autophoto_change_photo();
														
													break;
				case ui.btn_next:			var snapshot:Bitmap = take_snapshot();
													close_win();
													WSEventTracker.event("ce10");
													var chinPoint:Point = new Point(Math.max(ui.placeholder_apc.hairstyle_1.x-_currentOutline.x, 0), Math.max(ui.placeholder_apc.hairstyle_1.y-_currentOutline.y, 0));													
													App.mediator.save_masked_photo(snapshot, _currentContrast, chinPoint);//cutPoint);	
													
													//App.mediator.autophoto_submit_photo_position();
					
													break;
				case ui.btn_close:
					App.mediator.autophoto_close();
					break;
				default:
			}
		}
		private function take_snapshot():Bitmap{
			//face_masker.hidePoints();
			_currentOutline.visible = false;
			
			var maskPosition:Point = new Point(_mask.x, _mask.y);
			_mask.x =_mask.y = 0;
			
			_imageHold.x -=  maskPosition.x;
			_imageHold.y -=  maskPosition.y;
						
			var data:BitmapData = new BitmapData(_mask.width, _mask.height+5, true, 0x000000);	
			var mat:Matrix = new Matrix();
			//mat.translate( -p.x, -p.y);	
			data.draw(_imageHold.parent);//,null,null,null,new Rectangle(face_masker.getMask().x, face_masker.getMask().y, face_masker.getMask().width, face_masker.getMask().height), true);
			var map:Bitmap = new Bitmap(data, "auto", true);			
			_imageHold.x = _imageHold.y = 0;
			
			_mask.x = maskPosition.x;
			_mask.y = maskPosition.y;
			
			_currentOutline.visible = true;
			
			return map;
		}
		private static const MAX_ZOOM:Number = 6.0;
		private static const MIN_ZOOM:Number = .1;
		private static const MAX_ROTATION:Number = 180;
		private function btn_position_handler( _e:MouseEvent ):void 
		{	var dir		:String;
			
			var amount	:int;
			
			switch ( _e.target )
			{	case ui.btn_move_up:		dir = Auto_Photo_APC.MOVE_UP;				amount = App.settings.APC_MOVE_AMT;	break;
				case ui.btn_move_down:		dir = Auto_Photo_APC.MOVE_DOWN;				amount = App.settings.APC_MOVE_AMT;	break;
				case ui.btn_move_right:		dir = Auto_Photo_APC.MOVE_RIGTH;			amount = App.settings.APC_MOVE_AMT;	break;
				case ui.btn_move_left:		dir = Auto_Photo_APC.MOVE_LEFT;				amount = App.settings.APC_MOVE_AMT;	break;
				case ui.btn_zoom_in:		dir = Auto_Photo_APC.ZOOM_IN;				amount = 1; break;//App.settings.APC_ZOOM_AMT;	break;
				case ui.btn_zoom_out:		dir = Auto_Photo_APC.ZOOM_OUT;				amount = 1; break;//App.settings.APC_ZOOM_AMT;	break;
				case ui.btn_rot_cc:			dir = Auto_Photo_APC.ROT_COUNTER_CLOCKWISE;	amount = App.settings.APC_ROT_AMT ;	break;
				case ui.btn_rot_c:			dir = Auto_Photo_APC.ROT_CLOCKWISE;			amount = App.settings.APC_ROT_AMT ;	break;
				case ui.btn_reset:			_resetPosition(); return;//dir = Auto_Photo_APC.RESET_IMAGE;			amount = 0;	break;
				default:
			}
			
			_move( dir, amount );
			
			// do it on repeat if possible
			if (ui.stage)	// only if we have access to the stage
			{	var timer:Timer = new Timer(50, 0);//App.settings.APC_REPEAT_TIME, 0);
				timer.start();
				App.listener_manager.add( ui.stage, MouseEvent.MOUSE_UP, stop_timer, this );
				App.listener_manager.add( ui.stage, MouseEvent.MOUSE_OUT, stop_timer, this );
				App.listener_manager.add( timer, TimerEvent.TIMER, call_on_repeat, this );
				function call_on_repeat( _e:TimerEvent ):void 
				{	_move( dir, amount );
					
				}
				function stop_timer( _e:MouseEvent ):void
				{	App.listener_manager.remove( ui.stage, MouseEvent.MOUSE_UP, stop_timer );
					App.listener_manager.remove( ui.stage, MouseEvent.MOUSE_OUT, stop_timer );
					App.listener_manager.remove_all_listeners_on_object( timer );
					timer.stop();
					timer = null;
				}
			}
		}
		protected function _move(dir:String, amount:Number):void
		{

			if(dir == Auto_Photo_APC.ROT_CLOCKWISE || dir == Auto_Photo_APC.ROT_COUNTER_CLOCKWISE)
			{
				var rot:Number = NumberUtil.map( _rotationSlider.value, 0, 1, -MAX_ROTATION, MAX_ROTATION);
				_rotationSlider.value = NumberUtil.map(rot+amount, -MAX_ROTATION, MAX_ROTATION, 0, 1);
			}
			var scale:Number = NumberUtil.map( _zoomSlider.value, 0, 1, MIN_ZOOM, MAX_ZOOM);
			if(dir == Auto_Photo_APC.ZOOM_IN)
			{	
				_zoomSlider.value = NumberUtil.map(scale+(scale*.035), MIN_ZOOM, MAX_ZOOM, 0, 1);
			}
			if( dir == Auto_Photo_APC.ZOOM_OUT)
			{
				_zoomSlider.value = NumberUtil.map(scale-(scale*.035), MIN_ZOOM, MAX_ZOOM, 0, 1);
			}
			//App.mediator.autophoto_move_photo( dir, amount );
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
		protected var _currentHairstyle:Number = 0;
		protected var _currentOutline:DisplayObject;
		protected var _currentContrast:Number = 0;
		
		private static const TOTAL_HAIRSTYLES:Number = 11;
		private static const TOTAL_NECKS:Number = 9;
		protected function _changeHairstyle( direction:Number =1 ):void
		{
			// can be +- 1
			_currentHairstyle += direction;
			
			//loop around
			if(_currentHairstyle > TOTAL_HAIRSTYLES) _currentHairstyle = 1;
			if(_currentHairstyle < 1) _currentHairstyle = TOTAL_HAIRSTYLES;
						
			
			// set to visible and invisible according to current hairstyle
			for(var i:int = 1; i<=TOTAL_HAIRSTYLES; i++)
			{				
				ui.placeholder_apc.getChildByName("hairstyle_"+i).visible = (i == _currentHairstyle);
				ui.placeholder_apc.getChildByName("outline_"+i).visible = (i == _currentHairstyle);				
			}
			
			// indexed according to 1 instead of 0
			_currentOutline = ui.placeholder_apc.getChildByName("outline_"+_currentHairstyle);
			_mask 			= ui.placeholder_apc.getChildByName("hairstyle_"+_currentHairstyle);
			_mask.cacheAsBitmap = true;
			_imageHold.mask = _mask;
			
		}
		
		protected function _changeContrast( direction:Number = 1 ):void
		{
			_currentContrast += direction;
			_currentContrast = Math.min(Math.max(_currentContrast, 0), TOTAL_NECKS-1);
			
//			var currentAlpha:Number = ui.neck.getChildByName("skin").alpha;		
//			
//			currentAlpha = _currentContrast*.1;
//			
//			ui.neck.getChildByName("skin").alpha = Math.max(Math.min(currentAlpha, 1), 0);
			var necks:Array = [ui.neck.neck_1,
								ui.neck.neck_2,
								ui.neck.neck_3,
								ui.neck.neck_4,
								ui.neck.neck_5,
								ui.neck.neck_6,
								ui.neck.neck_7,
								ui.neck.neck_8,
								ui.neck.neck_9];
			
			for(var i:int = 0; i<necks.length; i++)
			{				
				(necks[i] as DisplayObject).visible = (i == _currentContrast);							
			}
			_enableContrastBtns();
		}
		
		protected function _enableContrastBtns():void
		{
			ui.btn_contrast_less.enabled =  _currentContrast > 0;
			ui.btn_contrast_more.enabled =  _currentContrast < TOTAL_NECKS-1;
			ui.btn_contrast_less.alpha = ui.btn_contrast_less.enabled ? 1 : .5;
			ui.btn_contrast_more.alpha = ui.btn_contrast_more.enabled ? 1 : .5;
		}
	}

}