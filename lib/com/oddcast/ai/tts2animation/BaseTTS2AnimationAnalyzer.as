package com.oddcast.ai.tts2animation
//import com.oddcast.ai.tts2animation.BaseTTS2AnimationAnalyzer;
/**
	 * ...
	 * @author Jake 3/2/2011 5:28 PM
*/
{
	import com.oddcast.host.morph.sync.SyncDatum;
	import com.oddcast.audio.ID3comment;
	import com.oddcast.workshop.fb3d.playback.FB3dControllerPlayback;
	
	
	public class BaseTTS2AnimationAnalyzer implements ITTS2AnimationAnalyzer
	{
		                        
		public function BaseTTS2AnimationAnalyzer() {}
		
		// implement ITTS2AnimationAnalyzer 
		/**
		 * 
		 * @param	controller :FB3dControllerPlayback 
		 * @param	avatarInstanceName :String - must match that stored in the scene
		 */
		public function init(controller:FB3dControllerPlayback, avatarInstanceName:String):void{
			this.avatarInstanceName = avatarInstanceName;
			var result:Object = controller.executeCommandWithResult("getAnimations", [avatarInstanceName]);
			setAvailableAnimations(String(result));
		}
		
		/**
		 * 
		 * @param	controller :FB3dControllerPlayback 
		 * @param	text	   :the tts text to speak;
		 * @param	finishedCallback(controller:FB3dControllerPlayback, text:String, this:ITTS2AnimationAnalyzer):void
		 *  		will be called when both mp3 and associated animations are finished.
		 */
		public function say(controller:FB3dControllerPlayback, text:String, finishedCallback:Function=null):void {
			controller.executeCommand("ttsWithPlaylist",
									[
										avatarInstanceName, // which avatar instance?
										text, // text to say
										function(id3:Object):Object // id3 to playlist handler
										{
											return getAnimationFromID3(String(id3));
										}, 
										function(param:Object):Object // playlist callback handler 
										{
											trace(param);
											return null;
										},
										function():void		//id3 and its animations have finished
										{
											if(finishedCallback!=null)
												finishedCallback();
										}
									]);
		}
		
		/**
		 * destructor
		 */
		public function destroy():void {
			
		}
		
		//  ------------------- PROTECTED -------------------------------------------------
		
		protected static var GESTURE 				= "Gesture: ";
		
		
		protected static var GESTURE_QUESTION 		= GESTURE + "Question";
		protected static var GESTURE_EXLAMATION		= GESTURE + "Exclamation";
		
		protected static var GESTURE_ME 			= GESTURE + "Me";
		protected static var GESTURE_YOU 			= GESTURE + "You";
		protected static var GESTURE_THIS 			= GESTURE + "This";
		protected static var GESTURE_THAT 			= GESTURE + "That";
		
		protected static var GESTURE_SPEECH_1 		= GESTURE + "Speech 1";
		protected static var GESTURE_SPEECH_2 		= GESTURE + "Speech 2";
		protected static var GESTURE_SPEECH_3 		= GESTURE + "Speech 3";
		
		protected static var WAVE					= "Wave";
		
		protected var avatarInstanceName			:String;
		
		protected function setAvailableAnimations(animations:String):void {
			trace("BaseTTS2AnimationAnalyzer " + animations);
			var animationNames:Array = animations.split(";");
			var junk = 1;
			//TODO  - ensure that animatations are actually there for this avatar.
		}
		
		
		protected function getAnimationFromID3(id3:String):String {
			trace("BaseTTS2AnimationAnalyzer id3:" + id3);
			/*
			audio_duration = "3.627";
			date = "20110302_17:02:00.821";
			host = "ODDAPS003";
			kbps = "16";
			khz = "11025";
			lip_string = "f0=5&f1=12&f2=1&f3=1&f4=1&f5=11&f6=12&f7=12&f8=6&f9=6&f10=3&f11=5&f12=7&f13=5&f14=3&f15=15&f16=9&f17=3&f18=4&f19=4&f20=4&f21=3&f22=3&f23=0&f24=0&f25=0&f26=0&f27=0&f28=1&f29=9&f30=13&f31=7&f32=5&f33=5&f34=5&f35=5&f36=3&f37=3&f38=0&f39=0&f40=0&f41=0&f42=0&f43=0&f44=0&nofudge=1&lipversion=2&ok=1";
			timed_phonemes = "P,0,46,81,x S,46,1846,72,. G,46,266,83,13 W,46,266,83,hello P,46,76,90,H P,76,126,86,! P,126,206,84,l P,206,266,76,O W,266,816,57,world P,266,386,75,w P,386,476,88,r P,476,626,75,l P,626,816,17,d G,816,976,87,1 W,816,976,87,my P,816,866,83,m P,866,976,90,I W,976,1226,83,name P,976,1036,80,n P,1036,1166,87,A P,1166,1226,77,m W,1226,1396,77,is P,1226,1276,87,i P,1276,1396,73,z W,1396,1846,71,Bob P,1396,1456,78,b P,1456,1686,92,c P,1686,1846,40,b P,1846,2276,0,X S,2276,3136,73,? W,2276,2446,63,What P,2276,2386,52,w P,2386,2416,88,^ P,2416,2446,82,t W,2446,2546,85,is P,2446,2476,85,i P,2476,2546,85,z G,2546,2666,85,3 W,2546,2666,85,your P,2546,2606,86,y P,2606,2636,85,C P,2636,2666,82,R W,2666,3136,71,name P,2666,2726,81,n P,2726,2946,87,A P,2946,3136,49,m P,3136,3606,0,x";
			*/
			//open playlist
			
			var id3comment = new ID3comment(id3);
			var timedPhonemeStr = id3comment.extract(ID3comment.TIMED_PHONEMES);
			var timedPhonemes = timedPhonemeStr.split("\t");
			trace("BaseTTS2AnimationAnalyzer timedPhonemes:" + timedPhonemes);
			var syncData = new Array();
			for each (var line:String in timedPhonemes){
				var syncDatum:SyncDatum = new SyncDatum();
				if(syncDatum.extractFromCompressedString(line, 0, 1, 1) !=SyncDatum.NO_EVENT)
					syncData.push(syncDatum);
			}
			return getAnimationFromTimedPhonemes(syncData);
		}
		
		protected function getAnimationFromTimedPhonemes(syncData:Array):String {
			
			
			
			
			var keys = new Array();
			
			//SENTENCE ENDINGS
			var sentencePunctuation  = filterSyncData(syncData, "S");
			{	for each(var sentenceSyncDatum:SyncDatum in sentencePunctuation) {
					var animationNiceName : String = null;
					switch (sentenceSyncDatum.eventString) {
						case "?": animationNiceName = GESTURE_QUESTION;   break;
						case "!": animationNiceName = GESTURE_EXLAMATION; break;
						case ".":                                         break;
						default: throw "Unknown Sentence Type:"+sentenceSyncDatum.eventString
					}
					if (animationNiceName != null) {
						keys.push( new Key().init(sentenceSyncDatum.endTime, animationNiceName, 1.0, true));
					}
				}
			}
			sentenceSyncDatum = null;
			
			//GROUPS
			var groups      		 = filterSyncData(syncData, "G");
			for each(var group:SyncDatum in groups) {
				var animationNiceName : String = null;
				switch (group.eventString) {
					case "1": animationNiceName = GESTURE_ME;   break;  //firstPersonSingular,  Words like "I me mine" ,
					case "2": animationNiceName = GESTURE_ME;	break;  //firstPersonPlural,    Words like "we us ourselves"
					case "3": animationNiceName = GESTURE_YOU;  break;  //secondPerson,  Words like "you your yours"
					case "4":  									break;  //thirdPersonMale,  Words like "him he his" 
					case "5":  									break;  //thirdPersonFemale,  Words like "she her hers" 
					case "6": animationNiceName = GESTURE_THIS;	break;  //thirdPersonNeutral,  Words like "it that this" 
					case "7":  									break;  //thirdPersonPlural,  Words like "them they their" 
					case "8":  									break; // numberSmall,  Numbers: less than 100 
					case "9":  									break; // numberHundred,  Numbers: 100 
					case "10":  								break; // numberThousand,  Numbers:1000
					case "11":  								break; // numberBig,  Numbers: million, billion, etc 
					case "12":  								break; // anyEvery,  Words like "any every all" 
					case "13": animationNiceName = WAVE; 		break; // greetingOpen,  Words like "hi hello welcome"
					case "14": animationNiceName = WAVE; 		break; // greetingClose Words like "bye goodbye ciao" 					

					default:	throw "Unknown Group Type:"+group.eventString								
				}
				if (animationNiceName != null) {
					keys.push( new Key().init(group.peakTime  , animationNiceName, 1.0, true, "(before 1 2)", "(after)"));
				}
			}
			group = null;
			
			
			//sort keys for time
			
			keys = keys.sort(	function(a:Key, b:Key):int {
									return (a.getTime() < b.getTime()) ? -1 : 1;
								}
							)
			//
			
			//write playlist
			/*	+serializeKey(0,    "Fall", 1, 	true, " (before 1 2)", " (after)") 
				+serializeKey(2000, "Fall", 1, 	true) 
				+serializeKey(2500, "Fall", 0.25, true)
			*/
			
			
			//write playlist
			var aniString =  "(playlist ";
			
			for each (var key:Key in keys) {
				var keyString = key.serialize();
				aniString += keyString;
				trace("BaseTTS2AnimationAnalyzer " + keyString);
			}
			
			aniString += ")";
			
			
			
			
			trace("BaseTTS2AnimationAnalyzer " + aniString);	
		//	trace("BaseTTS2AnimationAnalyzer " + "(playlist (key 0 \"Fall\" 1 #t (before 1 2) (after)) (key 2000 \"Fall\" 1 #t) (key 2500 \"Fall\" 0.25 #t))");
			//(playlist (key 0 "Fall" 1 #t (before 1 2) (after)) (key 2000 "Fall" 1 #t) (key 2500 "Fall" 0.25 #t))
			  
			return aniString;
		}
		
		protected function filterSyncData(syncData:Array, typeStrFilter:String):Array {
			
			return syncData.filter( 
				function(syncDatum:SyncDatum, index:int, arr:Array):Boolean {
					var label:String =  syncDatum.typeStr;
					var retval:Boolean = label == typeStrFilter;
					return retval;
				}
			);
			
		}

		
	}
}