package com.oddcast.utils
{
	import flash.text.TextField;
	
	/**
	 * @usage
	 * 			tf_tweener:TexfField_Number_Tweener = new TexfField_Number_Tweener();
	 * 			tf_tweener.init( '>', '%', tf, parseInt(tf_from.text));
	 * 			tf_tweener.update_current_tween( parseInt(tf_to.text), parseInt(tf_in.text) );
	 * 
	 * @author Me^
	 */
	public class TexfField_Number_Tweener 
	{
		private var prefix:String;
		private var postfix:String;
		private var textfield:TextField;
		private var num_tweener:Number_Tweener = new Number_Tweener();
		
		public function TexfField_Number_Tweener() 
		{	}
		
		/**
		 * initialize the textfield which will be later tweened
		 * @param	_prefix text prefix
		 * @param	_postfix text postfix
		 * @param	_tf textfield where updates will be applied
		 * @param	_current current number value, what it starts out with
		 */
		public function init( _prefix:String, _postfix:String, _tf:TextField, _current:int ):void 
		{
			prefix		= _prefix;
			postfix		= _postfix;
			textfield	= _tf;
			num_tweener.tween( _current, _current, 0, num_updated );
		}
		/**
		 * starts or updates a current tween
		 * @param	_to to what were animating to, from its current value
		 * @param	_seconds duration of animation
		 */
		public function update_current_tween( _to:int, _seconds:Number ):void 
		{
			if (textfield == null )	throw( new Error('CALLED PREMATURELY, TF NOT SET, suggestion: CALL init(...) FIRST :: TexfField_Number_Tweener.update_current_tween()') );
			else					num_tweener.update_current_tween( _to, _seconds );
		}
		/**
		 * callback to update the textfield value has been updated
		 * so we add the prefix and postfix with the number to the textfield
		 * @param	_new_value the updated number value
		 */
		private function num_updated( _new_value:int ):void 
		{
			textfield.text = prefix + _new_value.toString() + postfix;
		}
	}
	
}














import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * This is the number tweener, simply takes in a number and increments it 
 * @author Me^
 */
internal class Number_Tweener 
{
	private var timer					:Timer;
	private var cur_value				:Number;
	private var cur_from				:Number;
	private var cur_to					:Number;
	private var cur_total_time			:Number;
	private var update_callback			:Function;
	private var increment				:Number;
	/* this is optimal setting, lower and timing isnt accurate and higher fls drops */
	private const timer_delay_seconds	:Number		= 0.08;
	
	public function Number_Tweener() 
	{	}
	
	/**
	 * tween a number from to and calls the specified function when the current value is updated
	 * @param	_from
	 * @param	_to
	 * @param	_seconds time this will take to complete the tween
	 * @param	_update_callback call when finished
	 */
	public function tween( _from:int, _to:int, _seconds:Number, _update_callback:Function ):void 
	{
		save_values( _from, _to, _seconds, _update_callback );
		validate_increment();
		reset_timer();
		start_timer();
	}
	/**
	 * saves the passed in values to be used outside
	 * @param	_from
	 * @param	_to
	 * @param	_seconds
	 * @param	_update_callback
	 */
	private function save_values( _from:int, _to:int, _seconds:Number, _update_callback:Function ):void 
	{
		update_callback = _update_callback;
		cur_value = _from;
		cur_from = _from;
		cur_to = _to;
		cur_total_time = _seconds;
	}
	/**	
	 * check if from is less than to	
	 */
	private function validate_increment(  ):void 
	{
		if (cur_to < cur_from)
		{
			cur_from = cur_to;
			cur_value = cur_from;
		}
	}
	private function reset_timer(  ):void 
	{
		if (timer)	timer.reset();
	}
	/**	
	 * starts the timer based on the preset delay	
	 */
	private function start_timer(  ):void 
	{
		var difference:Number = cur_to - cur_from;
		var repeat_count:int = cur_total_time / timer_delay_seconds;
		increment = difference / repeat_count;
		if (isNaN(increment)) increment = 0;
		if (repeat_count > 0)
		{
			timer = new Timer( timer_delay_seconds * 1000, repeat_count );
			timer.addEventListener(TimerEvent.TIMER, increment_count);
			timer.start();
		}
		else	notify_callback();
	}
	/**
	 * tweens from the current value to the new specified value in  seconds
	 * @param	_to
	 * @param	_seconds
	 */
	public function update_current_tween( _to:int, _seconds:Number ):void 
	{
		tween( Math.round(cur_value), _to, _seconds, update_callback );
	}
	/**
	 * updates the current value based on the increment
	 * @param	e
	 */
	private function increment_count( e:TimerEvent = null ):void 
	{
		cur_value += increment;
		notify_callback();
	}
	/**
	 * notifies the listeners
	 */
	private function notify_callback(  ):void 
	{
		if (update_callback != null) update_callback( Math.round(cur_value) );
	}
	
}