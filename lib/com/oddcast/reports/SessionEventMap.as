/**
* SessionEventMap
* @author David Segal
* @version 0.1
* 
* 
* 
*/
package com.oddcast.reports {
	public class SessionEventMap {
		
		private var session_events_ar:Array;
		private var interval_mask:Number = 0;
		private var session_mask:Number = 0;
		private var start_time:Date;
		//private var so_data:Object;
		
		public function SessionEventMap()//in_so_data:Object)
		{
			//so_data = in_so_data;
			/*if (in_continue){
				session_events_ar = so_data.session_events_ar;
				interval_mask = so_data.interval_mask;
				session_mask = so_data.session_mask;
				start_time = so_data.start_time;
			} else {*/
				//so_data.session_events_ar = session_events_ar;
				//so_data.start_time = 
				//delete so_data.session_events_ar;
				//delete so_data.start_time;
				
			session_events_ar = new Array(	{event:"acmic", bit:0},
											{event:"actts", bit:1},
											{event:"acph",  bit:2},
											{event:"acup", bit:3},
											{event:"edems", bit:4},
											{event:"edsv", bit:5},
											{event:"uirt", bit:6},
											{event:"edvscr", bit:7},
											{event:"edapu", bit:8},
											{event:"edbgu", bit:9},
											{event:"ce1", bit:10},
											{event:"ce2", bit:11},
											{event:"ce3", bit:12},
											{event:"ce4", bit:13},
											{event:"ce5", bit:14},
											{event:"ce6", bit:15},
											{event:"ce7", bit:16},
											{event:"ce8", bit:17},
											{event:"uieb", bit:18},
											{event:"uiebms", bit:19},
											{event:"uiebfb", bit:20},
											{event:"edphs", bit:21},
											//{event:"edmbls", bit:22},
											{event:"accc", bit:22},
											{event:"edvdx", bit:23},
											{event:"edaux", bit:24},
											{event:"edfbc", bit:25},
											{event:"uiebws", bit:26},
											{event:"edecs", bit:27},
											{event:"uiebyt", bit:28},
											{event:"eddlph", bit:29},
											{event:"edsrhd", bit:30},
											{event:"edsrse", bit:31},
											{event:"edsrsm", bit:32},
											{event:"edsrpb", bit:33},
											{event:"edsrpp", bit:34},
											{event:"edsrpl", bit:35},
											{event:"edsrwc", bit:36},
											{event:"edmbls", bit:37},
											{event:"ce9", bit:38},
											{event:"ce10", bit:39},
											{event:"ce11", bit:40},
											{event:"ce12", bit:41},
											{event:"ce13", bit:42},
											{event:"ce14", bit:43},
											{event:"ce15", bit:44},
											{event:"ce16", bit:45}
			)
			start_time = new Date();
		}

		public function getSessionEventData():Object
		{
			var t_obj:Object = new Object();
			t_obj["session_mask"] = session_mask;
			t_obj["interval_mask"] = interval_mask;
			t_obj["session_time"] = Math.round((new Date().getTime() - start_time.getTime())/1000);
			//so_data.session_mask = 
			session_mask += interval_mask;
			//so_data.interval_mask = 
			interval_mask = 0;
			return t_obj;
		}
			
		public function sessionEvent(in_event:String):void
		{
			for (var i:Number =0; i < session_events_ar.length; ++i)
			{
				if (session_events_ar[i].event == in_event)
				{
					var t_o:Object = session_events_ar[i];
					session_events_ar.splice(i, 1);
					//so_data.session_events_ar = session_events_ar;
					//so_data.interval_mask = 
					interval_mask += Math.pow(2, t_o.bit);
					break;
				}
			}
		}
		
		public function destroy():void
		{
			session_events_ar = null;
			start_time = null;
			//so_data = null;
		}
		
	}
}