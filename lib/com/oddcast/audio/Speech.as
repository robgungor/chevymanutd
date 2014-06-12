package com.oddcast.audio
{
	import com.oddcast.event.SpeechEvent;
	import com.oddcast.host.morph.lipsync.*;
	import com.oddcast.host.morph.mouth.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	public class Speech extends EventDispatcher
	{
		private static const RETRIES:int = 3;
		public static var INSTANCE_COUNT:int = 0;
		
		private var _phonemes:PhonemeOddcast17;		
		private var _visemes:TimedVisemes;
		private var _snd:Sound;
		private var _sndChannel:SoundChannel;
		private var _oLipData:URLVariables;
		private var _sUrl:String;
		private var _nPosition:Number;		
		private var _bGotId3:Boolean; //make sure we don't get 2 id3 tags
		private var _nSafeToPlayPercent:Number;
		private var _uintFPS:uint;
		
		private var _bLoadedDispatched:Boolean;		
		private var _nLength:Number;
		private var _bSpeechEnded:Boolean;
		private var _nSampleRateDiffRatio:Number = 1;		
		private var _nOffset:Number;
		private var _bNewWord:Boolean;
		private var _bError:Boolean;
		private var _nLastPausePosition:Number;
		private var _nSecPosition:Number;		
		private var _iSecondsFromEndWithNoWordEnded:int = 2;
		private var _sessionRetries:int = 0;
		
		private var _instance_name:String;
		
		function Speech(url:String,fps:uint=12,percent:Number=0.5)
		{
			_instance_name = "sound_"+(++INSTANCE_COUNT);
			_sUrl = url;
			_sndChannel = new SoundChannel();	
			_snd = new Sound();	
			_snd.addEventListener(Event.ID3,soundId3Ready);
			_snd.addEventListener(Event.COMPLETE, soundLoaded);            
            _snd.addEventListener(IOErrorEvent.IO_ERROR, soundError);
            _snd.addEventListener(ProgressEvent.PROGRESS, soundProgressHandler);
			_nPosition = 0;			
			_nSafeToPlayPercent = percent;
			_uintFPS = fps;
			_bError = false;
			_nLastPausePosition = 0;
			 _phonemes = new PhonemeOddcast17("Oddcast17");
            _phonemes.load("auto");
			
		}
		
		public function load():void
		{
			//trace("SPEECH load - "+_sUrl);
			var req:URLRequest = new URLRequest(_sUrl);
			var ctx:SoundLoaderContext = new SoundLoaderContext(1000,true);          
            try 
			{
				_snd.load(req,ctx);                        
            }
            catch (err:Error) {
            	trace("Speech class :: error load function: "+err.message);
				_bError = true;				            	
				dispatchEvent(new SpeechEvent(SpeechEvent.SPEECH_LOAD_ERROR, "aud_url: "+_sUrl+" "+err.toString()));
            }

		}
		
		public function play(sec:Number =0):void
		{			
			//trace("Speech::play sec="+sec+", _nLength="+_nLength);
			//_nPosition = 0;
			if (!_bLoadedDispatched)
			{
				//the sound wasn't loaded yet
				return;
			}
			_bSpeechEnded = false;
			if (sec > _nLength)
			{
				//trace("Speech :: reset sec");
				sec = 0;
			} 
			/* if (sec < _nLength || sec == 0)
			{ */			
			_nOffset = sec;								
			var playHeadPos:Number = sec*1000*_nSampleRateDiffRatio;
			try
			{
				//trace("Speech ::: play sec: "+sec+", _nLength: "+_nLength);
				_sndChannel = _snd.play(playHeadPos);
				_visemes.play(playHeadPos);				
				dispatchEvent(new SpeechEvent(SpeechEvent.SPEECH_STARTED,this));								
				if (!_sndChannel.hasEventListener(Event.SOUND_COMPLETE))
				{
					_sndChannel.addEventListener(Event.SOUND_COMPLETE,soundEnded,false,0,true);
				}
			}
			catch(e:Error)
			{
				//trace("Speech :: error ");
				_bError = true;
				if (_snd!=null)
				{
					_snd.removeEventListener(Event.ID3,soundId3Ready);
					_snd.removeEventListener(Event.COMPLETE, soundLoaded);            
    				_snd.removeEventListener(IOErrorEvent.IO_ERROR, soundError);
    				_snd.removeEventListener(ProgressEvent.PROGRESS, soundProgressHandler);
    				_snd = null;
  				}
  				trace("Speech class :: error play function - "+e.toString());
  				dispatchEvent(new SpeechEvent(SpeechEvent.SPEECH_ERROR, "aud_url: "+_sUrl+" "+e.toString()));//new Error("Failed to open a SoundChannel")));
    			dispatchEvent(new SpeechEvent(SpeechEvent.SPEECH_ENDED,this));
    			
			}
			/* }
			else
			{
				//trace("Speech::play called for a position greater than length");				
				//dispatchEvent(new SpeechEvent(SpeechEvent.SPEECH_ENDED,this));
				_bError = true;
				dispatchEvent(new SpeechEvent(SpeechEvent.SPEECH_LOAD_ERROR,new Error("Speech::play called for a position greater than length")));
			} */
		}
		
		public function pause():void
		{
			if (_sndChannel is SoundChannel)
			{
				_nLastPausePosition = getCurrentSecond();
				_nPosition = getPosition();//+((_nOffset*1000)); //when resuming we want to go a little back;
				_sndChannel.stop();			
			}
		}
		
		public function resetSoundState():void
		{
			_bSpeechEnded = false;
			//trace("SPEECH RESET SOUND STATE -- _bSpeechEnded: "+_bSpeechEnded+"  name: "+_instance_name);
		}
		
		
		public function resume():void
		{
			if (_sndChannel is SoundChannel)
			{
				//trace("Speech::resume from "+_nPosition);
				play(_nLastPausePosition);
			}
			else
			{
				soundEnded();
			}
		}
		
		public function stop():void
		{
			_nPosition = 0;
			if (_sndChannel is SoundChannel)
			{				
				_sndChannel.stop();
			}
			if (_bLoadedDispatched)
			//sound can't end if it didn't start
			{
				soundEnded();
			}						
		}
		
		public function getPosition():Number
		{			
			return _sndChannel.position;
		}
		
		
		public function getLipFrame():int
		{
			
			if (!_bSpeechEnded && _bLoadedDispatched)
			{
				//var currentFrame:Number = getFrameNumber();
				//var lipForFrame:Number = getLipByFrame(currentFrame);
				var t_lip_frame:int = getLipByFrame(getFrameNumber())
				//trace("Speech --- getLip Frame  lip_frame: "+t_lip_frame);//currentFrame="+currentFrame+", returning lipForFrame="+lipForFrame);
				return t_lip_frame;
				 //return getFrameNumber();
			}
			else
			{
				//trace("SPEECH --- _bSpeechEnded: "+_bSpeechEnded+"  _bLoadedDispatched: "+ _bLoadedDispatched+"  name: "+_instance_name);
				return -1;
			}
		}
		
		public function isNewWord():Boolean
		{
			var currentFrame:uint = getFrameNumber();
			//trace("isNewWord::getCurrentSecond()="+getCurrentSecond()+", _nLength="+_nLength);
			if (currentFrame> _uintFPS && getCurrentSecond()<(_nLength-_iSecondsFromEndWithNoWordEnded)) //starting to look only 2 seconds after audio begun
			{
				var ret:Boolean = (getLipByFrame(currentFrame-1,true)<=1 && getLipByFrame(currentFrame-2,true)<=1);				
				//trace("*** found new word ret="+ret+", prev value="+_bNewWord);
				if (!_bNewWord && ret)
				{
					dispatchEvent(new SpeechEvent(SpeechEvent.SPEECH_NEW_WORD,new Object()));
				}
				_bNewWord = ret;
				return _bNewWord;
			}
			/*
			else if (currentFrame==1)
			{
				_bNewWord = true;
				return _bNewWord;
			}
			*/
			else
			{
				_bNewWord = false;
				return _bNewWord;
			}
		}
		
		public function isLoaded():Boolean
		{
			return _bLoadedDispatched;
		}
		
		public function getURL():String
		{
			return _sUrl;
		}
		
		public function getLipVersion():Number
		{
			return Number(_oLipData.lipversion);
		}
		
		public function setSampleRateDiffRatio(n:Number):void
		{
			_nSampleRateDiffRatio = n;
		}
		
		public function isError():Boolean
		{
			return _bError;
		}
		
		public function getPlayedPercent():Number
		{
			return Math.round(getCurrentSecond()*100/_nLength)/100;
		}
		
		public function getUrl():String
		{
			return _sUrl;
		}
		
		private function getFrameNumber():uint
		{			
			
			var sec:Number = getCurrentSecond();
			return Math.ceil(sec*_uintFPS);
			
			//if sound was offsets position gets screwed because of sample rate differences
			//need to make the opposite adjustment to the play adjustsment based on ratio (getCurrentSecond)
			/*
			var pos:Number = _sndChannel.position;
			if (_nOffset>0)
			{
				var adjustment:Number = (_nOffset*1000*(1-_nSampleRateDiffRatio));				
				//trace("adjustment = "+adjustment);
				pos+= adjustment;
			}
			*/
			
			/*
			var _loc_2:int;
            _loc_1 = Math.round(getCurrentSecond() * 1000);
            _loc_2 = _phonemes.getMouthFrame(null, _visemes.findCurrentTarget(_loc_1, null));
            if (_loc_2 >= 0)
            {
                _loc_2++;
            }// end if
			*/
			
			var milisec:int =  Math.round(getCurrentSecond() * 1000);
			var f:int = _phonemes.getMouthFrame(null, _visemes.findCurrentTarget(milisec, null));;//Math.ceil(sec*_uintFPS);			
			//trace("Speech::getFrameNumber _sndChannel.position="+_sndChannel.position+", pos="+pos+" , f="+f);
			//f = f==0?1:f;
			f = f>=0?f+1:f;	
			//trace("SPEECH ----------------------------  "+f);				
			return f;
		}
		
		private function getCurrentSecond():Number
		{
			var pos:Number = _sndChannel.position;
			if (_nOffset>0)
			{
				var adjustment:Number = (_nOffset*1000*(1-_nSampleRateDiffRatio));				
				//trace("adjustment = "+adjustment);
				pos+= adjustment;
			}
			return pos/1000;		
		}		
		
		private function getLipByFrame(i:uint,newWordTest:Boolean = false):int
		{
			var frame:Number = _oLipData["f"+i];
			/*
			if (newWordTest)
			{
				trace("Speech::getLipByFrame "+i+" frame="+frame);
			}
			*/
			/* 
			Dave 05.22.09
			This was changed from -1 to 0 if the condition passes. 
			The SPEECH_ENDED event now triggers the change of frame to -1
			 */
			return isNaN(frame)||_bSpeechEnded ? 0:frame; 
		}
		
		private function initID3():Boolean
		{
			try 
			{
				
				 _visemes = new TimedVisemes(TimedVisemes.DEFAULT_SYNC_AHEAD_OF_SOUND);
	            _visemes.addID3(_snd.id3.comment);
	          
				
				var _regexLipString:RegExp = new RegExp('lip_string.+?(f.+?ok=1)',"s");
				var _regexLength:RegExp = new RegExp('audio_duration.+?([0-9].+?)";',"s");
				
				var _sLipString:String = _regexLipString.exec(_snd.id3.comment)[1];			
				
				_nLength = Number( _regexLength.exec(_snd.id3.comment)[1]);
				//trace("**** read length from id3 tag -> "+_nLength+", lip="+_sLipString);
				_oLipData = new URLVariables();
				_oLipData.decode(_sLipString);
				_bGotId3 = true;
				return true;	
			}
			catch ($e:Error)
			{
				trace("Speech class :: error initID3 function --- retry : "+_sessionRetries);
				if (++_sessionRetries <= RETRIES)
				{
					_snd.removeEventListener(Event.ID3,soundId3Ready);
					_snd.removeEventListener(Event.COMPLETE, soundLoaded);            
            		_snd.removeEventListener(IOErrorEvent.IO_ERROR, soundError);
            		_snd.removeEventListener(ProgressEvent.PROGRESS, soundProgressHandler);
					_snd = new Sound();	
					_snd.addEventListener(Event.ID3,soundId3Ready);
					_snd.addEventListener(Event.COMPLETE, soundLoaded);            
            		_snd.addEventListener(IOErrorEvent.IO_ERROR, soundError);
            		_snd.addEventListener(ProgressEvent.PROGRESS, soundProgressHandler);
					load();
				}
				return false;
			}
		}
				
		private function soundEnded(evt:Event=null):void
		{
			_bSpeechEnded = true;
			//trace("Speech:: soundEnded ----------- _bSpeechEnded: "+_bSpeechEnded);
			dispatchEvent(new SpeechEvent(SpeechEvent.SPEECH_ENDED,this));
		}
		
		
		
		private function soundId3Ready(evt:Event):void
		{
			//trace("SPEECH CLASS ID3 READY EVENT");
			//if (_bGotId3)
			//{
			//	return;
			//}
			/*
			_bGotId3 = true;
			 _visemes = new TimedVisemes(TimedVisemes.DEFAULT_SYNC_AHEAD_OF_SOUND);
            _visemes.addID3(_snd.id3.comment);
          
			
			var _regexLipString:RegExp = new RegExp('lip_string.+?(f.+?ok=1)',"s");
			var _regexLength:RegExp = new RegExp('audio_duration.+?([0-9].+?)";',"s");
			
			var _sLipString:String = _regexLipString.exec(_snd.id3.comment)[1];			
			
			_nLength = Number( _regexLength.exec(_snd.id3.comment)[1]);
			//trace("**** read length from id3 tag -> "+_nLength+", lip="+_sLipString);
			_oLipData = new URLVariables();
			_oLipData.decode(_sLipString);
				*/											
			/*
			for (var i in _oResult)
			{
				trace("Speech::soundId3Ready _oResult "+i+"->"+_oResult[i]);
			}
			*/						
		}
		
		private function soundLoaded(evt:Event):void
		{			
			//trace("Speech::soundLoaded _snd.length="+_snd.length);
			
			if (initID3() && !_bLoadedDispatched)
			{
				dispatchEvent(new SpeechEvent(SpeechEvent.SPEECH_LOADED,this));
				_bLoadedDispatched = true;
			}
		}
		
		private function soundError(evt:IOErrorEvent):void
		{
			trace("Speech class :: error soundError function "+evt.toString());
			dispatchEvent(new SpeechEvent(SpeechEvent.SPEECH_LOAD_ERROR, "aud_url: "+_sUrl+" "+evt.toString()));//new Error(evt.text)));
		}
		
		private function soundProgressHandler(evt:ProgressEvent):void
		{
			if (_bLoadedDispatched)
			{
				return;
			}
			if (_bGotId3)
			{
				var loaded:Number = _snd.bytesLoaded/_snd.bytesTotal;
				//trace("Speech::soundProgressHandler "+loaded);
				if (loaded>=_nSafeToPlayPercent)
				{					
					dispatchEvent(new SpeechEvent(SpeechEvent.SPEECH_LOADED,this));
					_bLoadedDispatched = true;
				}				
			}
		}
	}
}