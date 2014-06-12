package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.core.ITalkChannel;
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	public class FakeTalkChannel implements ITalkChannel
	{
		private var sound_:Sound;
		private var savedOffset_:Number;
		private var channel_:SoundChannel;
		private var isDone_:Boolean = false;
		
		public function FakeTalkChannel(sound:Sound, triggerSound:Boolean, offset:Number, continuationFn:Function, failedFn:Function=null)
		{
			isDone_ = false;
			sound_ = sound;
			savedOffset_ = Number.MIN_VALUE;
			channel_ = sound_.play(offset);
			channel_.addEventListener(Event.SOUND_COMPLETE, function(e:Event):void
			{
				isDone_ = true;
				if (continuationFn != null)
					continuationFn();
				channel_.removeEventListener(Event.COMPLETE, arguments.callee);
			});
		}
		public function volume():Number
		{
			return channel_.soundTransform.volume;
		}
		public function setVolume(v:Number):void
		{
			var transform:SoundTransform = channel_.soundTransform;
			transform.volume = v;
			channel_.soundTransform = transform;
		}
		public function pause():void
		{
			if (isDone_)
				return;
			
			if (savedOffset_ != Number.MIN_VALUE)
				return;
			
			savedOffset_ = channel_.position;
			stop();
		}
		public function resume():void
		{
			if (isDone_)
				return;
			
			if (savedOffset_ == Number.MIN_VALUE)
				return;
			
			channel_ = sound_.play(savedOffset_);
		}
		public function stop():void
		{
			if (channel_ != null)
				channel_.stop();
		}
	}
}