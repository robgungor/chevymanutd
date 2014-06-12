package com.oddcast.utils 
{
	import com.dynamicflash.util.Base64;
	import com.oddcast.encryption.md5;
	import flash.display.BitmapData;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import org.gif.encoder.GIFEncoder;
	/**
	 * @GENERAL give me some bitmaps and ill give you a url
	 * @author Me^
	 */
	public class GIF_Builder
	{
		private var gif_encoder:GIFEncoder;
		
		public function GIF_Builder() 
		{
			
		}
		public function create_gif( _bitmap_data_list:Array, _frame_ms_delay:int, _looping_gif:Boolean ):void 
		{
			if (!_bitmap_data_list)
				throw(new Error('com.oddcast.utils.GIF_Builder.create_gif() MISSING BITMAP DATA LIST.'));
			
			// prepare a new gif encoder
			gif_encoder = new GIFEncoder();
			gif_encoder.start();
			gif_encoder.setRepeat( _looping_gif?0:1 );
			
			// add gif frames
			for (var i:int = 0; i < _bitmap_data_list.length; i++) 
			{
				var bmp_data:BitmapData = _bitmap_data_list[i] as BitmapData;
				if (!bmp_data)
					throw(new Error('com.oddcast.utils.GIF_Builder.create_gif() BITMAP DATA IN LIST IS INCORRECT.'));
				gif_encoder.setDelay( _frame_ms_delay );
				gif_encoder.addFrame( bmp_data );
			}
			
			// wrap up gif
			gif_encoder.finish();
		}
		public function get_gif_bytes(  ):ByteArray
		{
			return gif_encoder.stream;
		}
		public function upload_current_gif( _upload_api:String, _door:String, _fin:Function ):void 
		{
			if (!gif_encoder)
				throw(new Error('com.oddcast.utils.GIF_Builder.upload_current_gif() BUILD A GIF BEFORE UPLOADING IT.'));
				
			var uploading_session	:String	= new Date().getTime().toString() + Math.ceil(Math.random() * 1000).toString();
			var gif_data			:String = Base64.encodeByteArray( gif_encoder.stream );
			
			// data to be sent
			var cur_packet	:String			= gif_data;	// full packet
			var post_vars	:URLVariables	= new URLVariables();
			post_vars.FileDataBase64 		= cur_packet;
			post_vars.type			 		= 'animGif';
			post_vars.compress 			 	= 'false';
			post_vars.serve 			 	= 'false';
			post_vars.forceSave  			= 'false';
			post_vars.doorId				= _door;
			
			// if this is the last packet add full md5 check
			if ( true )	// were uploading the full packet here
				post_vars.multi_md5_final	= ( new md5() ).hash( gif_data );
			
			// upload data
			var upload_api:String = _upload_api + '?rand=' + Math.floor(Math.random() * 1000000).toString()
			XMLLoader.sendAndLoad( upload_api, its_uploaded, post_vars, String );
			
			function its_uploaded( _response:String ):void 
			{
				_fin( _response );
			}
		}/*
		public function upload_current_gif( _upload_api:String, _door:String, _fin:Function ):void 
		{
			if (!gif_encoder)
				throw(new Error('com.oddcast.utils.GIF_Builder.upload_current_gif() BUILD A GIF BEFORE UPLOADING IT.'));
				
			var uploading_session	:String	= new Date().getTime().toString() + Math.ceil(Math.random() * 1000).toString();
			var gif_data			:String = Base64.encodeByteArray( gif_encoder.stream );
			
			// data to be sent
			var cur_packet	:String			= gif_data;	// full packet
			var post_vars	:URLVariables	= new URLVariables();
			post_vars.multi_tot				= 1;
			post_vars.multi_cur				= 1;
			post_vars.multi_ses				= uploading_session;
			post_vars.multi_md5				= ( new md5() ).hash( cur_packet );
			post_vars.FileDataBase64		= cur_packet;
			post_vars.doorId				= _door;
			
			// if this is the last packet add full md5 check
			if ( true )	// were uploading the full packet here
				post_vars.multi_md5_final	= ( new md5() ).hash( gif_data );
			
			// upload data
			var upload_api:String = _upload_api + '?rand=' + Math.floor(Math.random() * 1000000).toString()
			XMLLoader.sendAndLoad( upload_api, its_uploaded, post_vars, String );
			
			function its_uploaded( _response:String ):void 
			{
				_fin( _response );
			}
		}*/
		
	}

}