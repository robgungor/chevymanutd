package code.controllers.main_loader 
{
	import code.models.*;
	import code.skeleton.*;
	
	import com.oddcast.workshop.ServerInfo;
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;
	
	/**
	 * ...
	 * @author Me^
	 */
	public class Main_Loader implements IMain_Loader
	{
		private var ui							:Main_Loader_UI;
		
		private var arr_processes				:Array;
		private var tf_overall					:TextField;
		private var tf_specific					:TextField;
		private var percentage_increment_force	:Percentage_Increment_Force;
		
		// main loader types... have to use these to know what tier they fall into
		public static const TYPE_GET_WORKSHOP_INFO	:String = 'GWI';
		public static const TYPE_SETTINGS			:String = 'settings';
		public static const TYPE_ERRORS				:String = 'errors';
		public static const TYPE_MODELS_LIST		:String = 'models list';
		public static const TYPE_BG_LIST			:String = 'bg list';
		public static const TYPE_BACKGROUND			:String = 'background';
		public static const TYPE_FACE				:String = 'face';
		public static const TYPE_BODY				:String = 'body';
		
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
		public function Main_Loader( _ui:Main_Loader_UI ) 
		{
			// listen for when the app is considered to have loaded and initialized all assets
			var loaded_event:String = App.mediator.EVENT_WORKSHOP_LOADED;
			App.listener_manager.add(App.mediator, loaded_event, app_initialized, this);
			
			// reference to controllers UI
			ui = _ui;
			
			// provide the mediator a reference to send data to this controller
			var registered:Boolean = App.mediator.register_controller(this);
			
			// init this immediately not when the app is initialized since this is needed for the inauguration process
			init();
			
			/** called when the application has finished the inauguration process */
			function app_initialized(_e:Event):void
			{
				App.listener_manager.remove_caught_event_listener( _e, arguments );
			}
		}
		/**
		 * initializes the controller if the check above passed
		 */
		private function init(  ):void 
		{	
			tf_overall		= ui.tf_overall;
			tf_specific		= ui.tf_loadingMsg;
			arr_processes	= new Array();
			percentage_increment_force = new Percentage_Increment_Force( tf_overall );
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
		public function close_win(  ):void 
		{	
			ui.visible = false;
			percentage_increment_force.destroy();
		}
		public function process_status_update( _type:String, _percent:int ):void
		{
			percentage_increment_force.start_timer();
			status_update( _type, _percent );
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
		public function status_update( _type:String, _percent:int ):void
		{
			var index:int = item_index(_type);
			if (index >= 0)
				arr_processes[index].percent = _percent;
			else
				arr_processes.push( process_item( _type, _percent ) );
				
			update_texts()
		}
		private function update_texts(  ):void
		{
			var total_percent:int;
			var num_of_tiers:int = 5;
			
			var tier_1_total:int, tier_1_items:int;	// first is first... like getWorkshopInfo... we have to wait for this
			var tier_2_total:int, tier_2_items:int;	// items loaded by inaugurator, such as settings.xml and errors.xml, things used for big show and small show
			var tier_3_total:int, tier_3_items:int;	// items loaded by big show or small show such as small show loading models and backgrounds xml
			var tier_4_total:int, tier_4_items:int;	// loading of the model and background after the xmls in tier 3 loaded
			var tier_5_total:int, tier_5_items:int;	// loading of the final items such as full body after the models face loads
			var message:String = '';
			
			for (var n:int = arr_processes.length , i:int = 0; i < n; i++)
			{
				var item_percent:int = arr_processes[i].percent;
				var item_type:String = arr_processes[i].type;
				switch ( item_type )
				{	
					case Main_Loader.TYPE_GET_WORKSHOP_INFO	:	tier_1_total += item_percent;	tier_1_items++;		message += item_type + ' : ' + item_percent + '\n';		break;
					case Main_Loader.TYPE_SETTINGS			:	tier_2_total += item_percent;	tier_2_items++;		message += item_type + ' : ' + item_percent + '\n';		break;
					case Main_Loader.TYPE_ERRORS			:	tier_2_total += item_percent;	tier_2_items++;		message += item_type + ' : ' + item_percent + '\n';		break;
					case Main_Loader.TYPE_MODELS_LIST		:	tier_3_total += item_percent;	tier_3_items++;		message += item_type + ' : ' + item_percent + '\n';		break;
					case Main_Loader.TYPE_BG_LIST			:	tier_3_total += item_percent;	tier_3_items++;		message += item_type + ' : ' + item_percent + '\n';		break;
					case Main_Loader.TYPE_BACKGROUND		:	tier_4_total += item_percent;	tier_4_items++;		message += item_type + ' : ' + item_percent + '\n';		break;
					case Main_Loader.TYPE_FACE				:	tier_4_total += item_percent;	tier_4_items++;		message += item_type + ' : ' + item_percent + '\n';		break;
					case Main_Loader.TYPE_BODY				:	tier_5_total += item_percent;	tier_5_items++;		message += item_type + ' : ' + item_percent + '\n';		break;
					default									:	tier_5_total += item_percent;	tier_5_items++;		message += item_type + ' : ' + item_percent + '\n';		
				}        
			}
			
			if (tier_1_items > 0)	// past GWI so we know what type of app it is
				switch ( ServerInfo.app_type )
				{	
					case ServerInfo.APP_TYPE_Flash_10_FB_3D:	
						num_of_tiers = 5;
						break;
					default:									
						num_of_tiers = 2;
				}
			num_of_tiers++;// we dont want it to go directly to 100... give it some buffer for animation
			
			total_percent +=	calculate_tier( tier_1_total, tier_1_items ) +
								calculate_tier( tier_2_total, tier_2_items ) +
								calculate_tier( tier_3_total, tier_3_items ) +
								( tier_4_total*.6 ) 
								//calculate_tier( tier_5_total, tier_5_items );
								
			tf_specific.text	= message;
			percentage_increment_force.update_tf_percent( Math.round(total_percent) );
			
			
			function calculate_tier( _total:int, _items:int ):int
			{
				if (_total > 0)
					return (_total / _items) / num_of_tiers;
				return 0;
			}
		}
		private function item_index( _type:String ):int
		{
			for (var n:int = arr_processes.length, i:int = 0; i < n; i++)
				if (arr_processes[i].type == _type)
					return i;
			return -1;
		}
		private function process_item( _type:String, _percent:int ):Object
		{
			return {type:_type, percent:_percent};
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











import code.skeleton.*;
import flash.events.*;
import flash.text.TextField;
import flash.utils.Timer;

class Percentage_Increment_Force
{
	private var percentage_timer:Timer;
	private var forced_percentage:int = 0;
	private var tf_percent:TextField;
	private const FORCE_INCREASE_EVERY:int = 250;
	public function Percentage_Increment_Force( _tf:TextField)
	{
		if (_tf)
		{
			tf_percent = _tf;
			percentage_timer = new Timer(FORCE_INCREASE_EVERY);
			App.listener_manager.add( percentage_timer, TimerEvent.TIMER, force_increment_percentage, this );
		}
		else throw new Error('invalid text field used');
	}
	/**
	 * start the timer if its not already running
	 * @param	_current_value
	 */
	public function start_timer( _current_value:int = 0 ):void
	{
		if (percentage_timer && !percentage_timer.running)
		{
			forced_percentage = _current_value;
			restart_percentage_timer();
		}
	}
	private function force_increment_percentage(_e:TimerEvent):void
	{
		forced_percentage++;
		update_tf_percent( forced_percentage );
	}
	/**
	 * restart the timer because the value has increased
	 */
	private function restart_percentage_timer():void
	{
		if (percentage_timer)
		{
			percentage_timer.reset();
			percentage_timer.start();
		}
	}
	public function update_tf_percent( _new_percent:int ):void
	{
		if (_new_percent > forced_percentage)
		{
			forced_percentage = _new_percent;
			restart_percentage_timer();
		}
		if (forced_percentage > 99)
			forced_percentage = 99;
		
		App.ws_art.main_loader.load_bar.gotoAndStop(forced_percentage);
		
		tf_percent.text = forced_percentage.toString() + '%';
	}
	public function destroy(  ):void
	{
		if (percentage_timer)
		{
			percentage_timer.stop();
			App.listener_manager.remove_all_listeners_on_object( percentage_timer );
			percentage_timer = null;
		}
	}
}