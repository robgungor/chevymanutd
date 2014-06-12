package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.content.*;
	import com.oddcast.oc3d.core.*;
	
	import flash.media.Sound;
	import flash.utils.Dictionary;

	public class Utilities
	{
		public static function playViseme(builder:IAvatarBuilderProxy, sound:Sound, morphDeformerName:String, triggerAudio:Boolean, offset:Number, finishedPlayingCallback:Function=null, failedFn:Function=null):ITalkChannel
		{
			return builder.instance().talk(sound, morphDeformerName, triggerAudio, offset, function():void
			{
				if (finishedPlayingCallback != null)
					finishedPlayingCallback();
				
			}, failedFn);
		}

		public static function queryAvailbleMorphDeformerNames(builder:IAvatarBuilderProxy):Vector.<String>
		{
			var result:Vector.<String> = new Vector.<String>();
			builder.instance().deformationManager().forEachMorphDeformer(function(deformer:IMorphDeformer):void { result.push(deformer.name()); });
			return result;
		}
		public static function loadSoundAndPlayVisemeOnAllAvailableMorphDeformers(
			builder:IAvatarBuilderProxy, 
			url:String, 
			triggerAudio:Boolean,
			offset:Number,
			finishedLoadingCallback:Function=null, // Function<void(Vector.<ITalkChannel>)> 
			finishedPlayingCallback:Function=null, // Function<void()>
			failedFn:Function=null,
			progressedFn:Function=null):void
		{
			var morphDeformsNames:Vector.<String> = queryAvailbleMorphDeformerNames(builder);
			
			builder.instance().scene().engine().resourceManager().accessSound(url, false, function(sound:Sound):void
			{
				if (sound.bytesTotal == 0)
				{
					var err:String = "Warning - invalid zero length mp3 found at url \"" + url + "\"";
					trace(err);
					if (failedFn != null)
						failedFn(err);
				}
				else
				{
					if (morphDeformsNames.length > 0)
					{
						var k:Function = Utilities.delayN(morphDeformsNames.length, function():void
						{
							if (finishedPlayingCallback != null)
								finishedPlayingCallback();
						});

						var result:Vector.<ITalkChannel> = new Vector.<ITalkChannel>(morphDeformsNames.length, true);
						if (finishedLoadingCallback != null)
							finishedLoadingCallback(result);
						for (var i:uint=0; i<morphDeformsNames.length; ++i)
						{
							if (!triggerAudio)
								result[i] = playViseme(builder, sound, morphDeformsNames[i], false, offset, k, failedFn);
							else
								result[i] = playViseme(builder, sound, morphDeformsNames[i], (i==0?true:false), offset, k, failedFn);
						}
					}
					else
					{
						var result2:Vector.<ITalkChannel> = new Vector.<ITalkChannel>(1, true);
						result2[0] = new FakeTalkChannel(sound, triggerAudio, offset, function():void
						{
							if (finishedPlayingCallback != null)
								finishedPlayingCallback();
							
						}, failedFn);
						if (finishedLoadingCallback != null)
							finishedLoadingCallback(result2);
					}
				}
				
			}, failedFn, progressedFn);
		}
		public static function dictionaryLength(dict:Dictionary):uint
		{
			var result:uint = 0;
			for (var k:String in dict)
				++result;
			return result;
		}

		private static var debugCounter:int = 0;
		public static function delayN(n:uint, lambda:Function):Function
		{
			//++debugCounter;
			//trace("delayN BEGIN - " + n + " (" + debugCounter + ")");
			if (n == 0)
			{
				lambda();
				return null;
			}
			else
			{
				return (function (i:int, c:int):Function { return function():void
				{
					--i;
					if (i == 0)
						lambda();
					else if (i < 0)
						throw new Error("force underflow");
					//throw new Error("force underflow (" + c + ")");
					
				}; })(n, debugCounter);
			}
		}
		private static var sameTimestampCounter_:uint;
		private static var prevTimestamp_:String;
		public static function currentTimestamp():String
		{
			var date:Date = new Date();
			var ts:String = String(date.fullYearUTC) + date.monthUTC + date.dayUTC + date.hoursUTC + date.minutesUTC + date.secondsUTC + date.millisecondsUTC;
			if (!Str.isNullOrEmpty(prevTimestamp_))
			{
				if (ts == prevTimestamp_)
					++sameTimestampCounter_;
				else
					sameTimestampCounter_ = 0;
			}
			prevTimestamp_ = ts;
			if (sameTimestampCounter_ > 0)
				return ts + "_" + sameTimestampCounter_;
			else
				return ts;
		}
	}
}