/**
* ...
* @author Jonathan Achai
* @version 0.1
*/

package workshop.ui {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.oddcast.ui.BaseButton;
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.workshop.ServerInfo;
	import flash.net.URLVariables;
	import com.oddcast.workshop.ProcessingEvent;

	public class AudioTruthWindow extends MovieClip {
		
		public var _mcBtnIsItTrue:BaseButton;
		public var _mcTruthBar:MovieClip;
		private var _sAudioUrl:String;
		
		public function AudioTruthWindow() 
		{
			_mcBtnIsItTrue.addEventListener(MouseEvent.CLICK, checkAudio);
		}
		
		public function setAudioUrl(s:String):void
		{
			trace("AudioTruthWindow::setAudioUrl " + s);
			_mcTruthBar.visible = false;
			_sAudioUrl = s;
		}
		
		private function checkAudio(evt:MouseEvent):void
		{
			dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED,"truth"));
			var v:URLVariables = new URLVariables("url=" + escape(_sAudioUrl));
			XMLLoader.sendVars(ServerInfo.globalURL+"php/api/checkAudioTruth",gotAudioTruthXML,v);
		}
		
		private function gotAudioTruthXML(xml:XML):void
		{
			if (xml != null)
			{
				if (xml.@OK == "1")
				{
					_mcTruthBar.visible = true;
					trace("Audio Truth Value is " + xml.@METER);
					_mcTruthBar.gotoAndStop(5-int(xml.@METER))
				}
				else
				{
					trace("Audio Truth Error " + xml.@ERR);
				}
			}
			dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,"truth")); //hostLoadingStop();
		}
	}
	
}