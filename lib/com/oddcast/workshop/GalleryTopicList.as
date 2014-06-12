package com.oddcast.workshop {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.XMLLoader;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	* ...
	* @author Sam Myer, Me^
	*/
	public class GalleryTopicList extends EventDispatcher {
		private var default_topic_id:int;
		private var arr:Array;
		/* true if the list has already been loaded */
		public var is_loaded:Boolean = false;
		
		public function GalleryTopicList() 
		{
			
		}
		
		/**
		 * 
		 * @param	_fin		finished callback
		 * @param	_error		on error callback -- need to accept {AlertEvent}
		 */
		/**
		 * 
		 * @param _callbacks fin(), error(AlertEvent)
		 * 
		 */		
		public function load_gallery_topics( _callbacks:Callback_Struct ):void 
		{
			if (is_loaded)
				_callbacks.fin();
			else
			{	add_listeners();
				loadTopics();
				
				function loaded( _e:Event ):void
				{	remove_listeners();
					_callbacks.fin();
				}
				function error( _e:AlertEvent ):void
				{	remove_listeners();
					_callbacks.error(_e);
				}
				function add_listeners():void
				{	addEventListener( Event.COMPLETE, loaded );
					addEventListener( AlertEvent.EVENT, error );
				}
				function remove_listeners():void
				{	
					removeEventListener( Event.COMPLETE, loaded );
					removeEventListener( AlertEvent.EVENT, error );
				}
			}
		}
		
		private function loadTopics():void
		{
			default_topic_id = ServerInfo.topic;
			var url:String = ServerInfo.acceleratedURL + "php/galleryAPI/getTopics/doorId=" + ServerInfo.door;
			XMLLoader.loadXML(url, gotTopics);
		}
		
		private function gotTopics(_xml:XML) : void {
			var alertEvt:AlertEvent = XMLLoader.checkForAlertEvent("f9t130");
			if (alertEvt != null) {
				dispatchEvent(alertEvt);
				return;
			}
			
			parseTopics(_xml);
			is_loaded = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function parseTopics(_xml:XML) : void {
			default_topic_id = parseInt(_xml.TINFO.@ID.toString());
			
			var topicNode:XML;
			arr = new Array();
			for (var i:int = 0; i < _xml.TOPIC.length(); i++) {
				topicNode = _xml.TOPIC[i];
				arr.push( new GalleryTopic(parseInt(topicNode.@ID.toString()), topicNode.@NAME.toString()));
			}
		}
		
		public function get topics():Array {
			return(arr);
		}
		
		public function get defaultTopicId():int {
			return(default_topic_id);
		}
		
		public function getTopicById(id:int):GalleryTopic {
			if (arr == null) return(null);
			for (var i:int = 0; i < arr.length; i++) {
				if (arr[i].id == id) return(arr[i]);
			}
			return null;
		}
	}
	
}