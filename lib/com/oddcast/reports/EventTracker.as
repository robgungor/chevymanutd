/*
* 
* Track usage events from the voki and vhss players and workshop
* 10.04.2007
* David Segal
* 
* example request
* http://track.oddcast.com/event.php?acc=1&shid=1&skid=1&dom=dave.blogspot.com&uni=1&et=0&ev[25]=sv& ev[25]=aptts& ev[26]=sv&rnd=474747
* 
* 
* 
*/

package com.oddcast.reports {
	import com.oddcast.utils.OddcastSharedObject;
	
	import flash.display.LoaderInfo;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.sendToURL;
	import flash.utils.Timer;

	public class EventTracker
	{

		private var req_domain:String = "http://track.oddcast.com/event.php";
		private var send_frequency:Number = 2000;
		private var sendTimer:Timer;
		//private var session_recover_time:Number = 420000; // 7 minutes
		private var max_so_size:Number = 10000;
		private var session_end:Number = 1200000; // max session time is 20 minutes 
		
		private var app_type:String;			// W - Workshop editor, w - Workshop player, v - VHSS player, k - Voki player, K - Voki editor, S - SitePal editor, P - Pro Editor
		private var account_id:String;		// for workshop this is the door id
		private var show_id:String;			// for workshop this is the message id
		private var skin_id:String;			// for workshop this is the topic id
		private var scene_id:String;
		private var partner_id:String;
		private var app_id:String;
		private var email_session:String;
		private var embed_session:String;
		private var swf_name:String;
		
		private var page_domain:String;
		
		private var so:OddcastSharedObject;
		private var so_data:Object;
		private var unique:Number;
		private var eventtime:Date;
		
		private var events:Object;
		private var init_obj:Object;
		private var session_event_map:SessionEventMap;
		
		public function EventTracker() {
		}
		
		public function init(in_req_url:String, in_init_obj:Object, in_loader:LoaderInfo = null):void
		{	
			//trace("EVENTTRACKER V2 --------- INIT");
			if (in_req_url != null)				req_domain = in_req_url;
			if (in_init_obj == null) in_init_obj = new Object();
			init_obj = in_init_obj;
			if (in_init_obj["apt"] != null) 	app_type = in_init_obj["apt"];
			if (in_init_obj["acc"] != null) 	account_id = in_init_obj["acc"];
			if (in_init_obj["shw"] != null) 	show_id = in_init_obj["shw"];
			if (in_init_obj["skn"] != null) 	skin_id = in_init_obj["skn"];
			if (in_init_obj["prt"] != null) 	partner_id = in_init_obj["prt"];
			if (in_init_obj["api"] != null) 	app_id = in_init_obj["api"];
			if (in_init_obj["eml"] != null) 	email_session = in_init_obj["eml"];	
			if (in_init_obj["dom"] != null) 	page_domain = in_init_obj["dom"];
			if (in_init_obj["scn"] != null) 	scene_id = in_init_obj["scn"];
			if (in_init_obj["emb"] != null)		embed_session = in_init_obj["emb"];
			try
			{
				var t_regex:RegExp = /(?<=\/|\\)(\w*)\.swf/gi;
				var t_swf_url:String = in_loader.loaderURL;
				swf_name = t_regex.exec(t_swf_url)[0];
			}catch($e:Error){}
			events = new Object();

			//SharedObject.defaultObjectEncoding = ObjectEncoding.AMF0;
			
			//var tmp_so:SharedObject = SharedObject.getLocal("oddcast_tracker_"+account_id);
			//tmp_so.clear();
			//delete tmp_so;

			try
			{
				var t_so_date:Date = new Date();
				t_so_date.setMonth(t_so_date.getMonth()+1);
				so = new OddcastSharedObject(account_id, t_so_date);
				
				//so = new OddcastSharedObject(
				//so = SharedObject.getLocal("oddcast_so", "/");
			}
			catch(e:Error)
			{
				trace("EVENTTRACKER SHARED OBJECT ERROR !!! "+e.message);
			}
			
			//trace("EVENTTRACKER ---- so size "+so.getSize());
			if (so != null)
			{
				var t_so_data:Object = so.getDataObject();
				t_so_data = cleanUpOldData(t_so_data);
				so.write(t_so_data);
				//if (so.size > max_so_size) so.clear();
				so_data = getSOData();
			}
			
			
			var t_date:Date = new Date();
			var t_m:Number = t_date.getMonth();
			var t_d:Number = t_date.getDate();
			/*if (so_data.eventtime.getTime() > t_date.getTime()-session_recover_time) // < than 7 minutes since last visit, continue previous session
			{
				//trace("EVENTTRACKER INIT ---- same session - use last sesssion parameters");
				session_event_map = new SessionEventMap(so_data, true);
				unique = so_data.visits;
				eventtime = so_data.eventtime;
			}
			else */// new session
			//{
				session_event_map = new SessionEventMap();//so_data);
				// it is a new month for this year, ergo a new day as well
				if (so != null)
				{
					if (so_data.date_mn == undefined || so_data.date_mn.getMonth() != t_date.getMonth())
					{
						unique = so_data.visits = 1;
						so_data.date_mn = new Date();
						so_data.date_day = new Date();
					} 
					// it is a new day for this user
					else if (so_data.date_day == undefined || so_data.date_day.getDate() != t_date.getDate())
					{
						unique = ++so_data.visits;
						so_data.date_day = new Date();
					}
					// this user has been here before during this day
						else
					{
						unique = 0;
					}
					so.write(so.getDataObject());
					//if (so.size > max_so_size) so.clear();
				}
				else
				{
					unique = 0;
				}
			
				
				
				//trace("EVENTTRACKER INIT ---- acc: "+account_id+" show: "+show_id+" app: "+app_type+" skin: "+skin_id);
				event("tss", "0"); // tss - tracking session started. sent only the first time
				sendEvents();
			//}
			sendTimer=new Timer(send_frequency);
			sendTimer.addEventListener(TimerEvent.TIMER,sendEvents, false, 0, true);
			sendTimer.start();
		}
		
		public function setAccountId(in_acc:String):void
		{
			account_id = in_acc;
		}
		
		public function setShowId(in_show:String):void
		{
			show_id = in_show;
		}
		
		public function setSceneId(in_scene:String):void
		{
			scene_id = in_scene;
		}
		
		public function setAppType(in_app:String):void
		{
			app_type = in_app;
		}
		
		public function setPageDomain(in_pd:String):void
		{
			page_domain = in_pd;
		}
		
		public function setSkinId(in_skin:String):void
		{
			skin_id = in_skin;
		}
		
		public function setPartnerId(in_partner:String):void
		{
			partner_id = in_partner;
		}
		
		public function setAppId(in_app_id:String):void
		{
			app_id = in_app_id;
		}
		
		public function setEmailSession(in_eml_session:String):void
		{
			email_session = in_eml_session;
		}
		
		public function setRequestDomain(in_str:String):void
		{
			req_domain = in_str;
		}
		
		public function event(in_event:String, in_scene:String=null, in_count:Number = 0, in_value:String=null):void
		{
			if (account_id != null && app_type != null && in_event != null)
			{
				var t_et:Number = (eventtime != null) ? Math.round((new Date().getTime() - eventtime.getTime())) : 0;
				if (t_et > session_end)  // 20 minutes has elapsed - RESTART SESSION 
				{
					eventtime = new Date();
					sendTimer.removeEventListener(TimerEvent.TIMER, sendEvents);
					sendTimer.stop();
					init(req_domain, init_obj);
				}
				if (in_scene == null && scene_id == null)
				{
					in_scene = "0";
				}
				else if (in_scene == null)
				{
					in_scene = scene_id;
				}
				if (events[in_scene] == null) events[in_scene] = new Array();
				events[in_scene].push({event:in_event, count:in_count, value:in_value});
				session_event_map.sessionEvent(in_event);
			}
		}
		
		protected function sendEvents(evt:TimerEvent=null):void
		{
			var t_ev_str:String = new String();
			for (var i:String in events)
			{
				for (var n:Number = 0; n < events[i].length; ++n)
				{
					t_ev_str += "&ev[" + i + "][]=" + events[i][n].event;
					if (events[i][n].count > 1)
					{
						t_ev_str += "&cnt[" + events[i][n].event + "]=" + events[i][n].count;
					}
					if (events[i][n].value != null)
					{
						t_ev_str += "&val[" + i + "][" + events[i][n].event + "][]="+String(events[i][n].value).substr(0, 20);
					}
				}
			}
			events = new Object();
			if (t_ev_str.length > 6)
			{		
				var t_str:String = "?";
				
				// top level parameters
				t_str += "apt="+app_type;
				t_str += "&acc="+account_id;
				if (swf_name != null) t_str+= "&swf="+swf_name;
				if (show_id != null) t_str += "&shw="+show_id;
				if (skin_id != null) t_str += "&skn="+skin_id;
				if (partner_id != null) t_str += "&prt="+partner_id;
				if (app_id != null) t_str += "&api="+app_id;
				if (email_session == "1") t_str += "&eml="+email_session;
				if (embed_session != null) t_str += "&emb="+embed_session;
				if (page_domain != null) t_str += "&dom="+page_domain;
				t_str += "&uni="+unique;
				var t_obj:Object = session_event_map.getSessionEventData();
				t_str += "&sm="+t_obj["session_mask"] ;
				if (t_obj["interval_mask"] != 0) t_str += "&st["+t_obj["interval_mask"]+"]="+t_obj["session_time"];
				//end top level parameters
				
				var et:Number = (eventtime == null) ? 0 : Math.round((new Date().getTime() - eventtime.getTime())/1000);
				t_str += "&et="+et+t_ev_str;
				
				//trace("EVENTTRACKER ---- send event "+t_str);
				//so.deleteSO();
				//so.traceSO(so);
				//sendToURL(new URLRequest(t_str));
				sendRequest(t_str);
				//var lv:LoadVars = new LoadVars();
				//lv.sendAndLoad(t_str, new LoadVars());
				
				eventtime = new Date();
				//so_data.eventtime = eventtime = getTimer();
				/* trace("EVENT TRACKER -- send events " +so);
				if (so != null)
				{
					trace("EVENT TRACKER -- write to so");
					so.write(so_data);//.flush();
					//if (so.size > max_so_size) so.clear();
				} */
			}
		}
		
		protected function sendRequest(in_str:String):void
		{
			sendToURL(new URLRequest(req_domain+in_str));
		}
		
		public function destroy():void
		{
			trace("EVENT TRACKER ))) DESTROY ");
			req_domain = null;
			app_type = null;
			account_id = null;
			show_id = null;
			skin_id = null;
			scene_id = null;
			partner_id = null;
			app_id = null;
			email_session = null;
			embed_session = null;
			page_domain = null;
			eventtime = null;
			events = null;
			init_obj = null;
			if (sendTimer != null)
			{
				sendTimer.stop();
				sendTimer.removeEventListener(TimerEvent.TIMER, sendEvents);
				sendTimer = null;
			}
			if (so != null)
			{
				//so.write(so_data);
				//so.close();
				so = null;
			}
			so_data = null;
			if (session_event_map != null)
			{
				session_event_map.destroy();
				session_event_map = null;
			}
			
		}
		
		private function cleanUpOldData(o:Object, ref:String=null, st:String=null):Object
		{
			//var o:Object = (o_level == null) ? o_orig : o_level;
			var i:String;
			for (i in o)
			{
				var t_str:String = (ref == null) ? i : ref;
				var t_str1:String = (st == null) ? "" : "    "+st;
				//trace(t_str1+"EVENTTRACKER --- clean "+i+" :: "+o[i]+"   object: "+(o[i] instanceof Object));
				if (o[i] is Object)
				{
					//trace("    EVENTTRACKER --- re-clean");
					cleanUpOldData(o[i], t_str, t_str1);
				}
			}
			//var t_date:Date = new Date();
			if (o.hasOwnProperty("eventtime")&&o.eventtime is Date)
			{
				//trace("EVENTTRACKER ---- CLEAN THIS!!!!  "+ref+"   size: "+so.getSize());
				for (i in o)
				{
					if (i != "date_day" && i != "date_mn" && i != "visits") delete o[i];
					//trace("		EVENTTRACKER --- clean !!! "+i+" :: "+o[i]+"   object: "+ref);
				}
				//if (so != null) so.flush();
				//trace("EVENTTRACKER ---- CLEAN THIS!!!! done  "+ref+"   size: "+so.getSize());
			}
			return o;
		}
		
		/* private function writeToSharedObject():void
		{
			var o:Object = so.getDataObject();
			if (account_id != null){
				o = o[account_id];
			}
			if (show_id != null){
				o = o[show_id];
				
			}
			if (scene_id != null){
				
			}
		} */
		
		private function getSOData():Object
		{
			var o:Object = so.getDataObject();
			if (account_id != null){
				if (o[account_id] == null) o[account_id] = new Object();
				o = o[account_id];
			}
			if (show_id != null){
				if (o[show_id] == null) o[show_id] = new Object();
				o = o[show_id];
			}
			if (scene_id != null){
				if (o[scene_id] == null) o[scene_id] = new Object();
				o = o[scene_id];
			}
			return o;
		}
	}
	
}