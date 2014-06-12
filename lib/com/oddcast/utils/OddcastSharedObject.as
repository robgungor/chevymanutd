package com.oddcast.utils
{
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;

	/**
	 * Oddcast SharedObject impementation to manage the size and to generalize the name and read/write methodology
	 */
	public class OddcastSharedObject //extends SharedObject
	{
		public static const PERMANENT:String = "permanent";
		private static var _enabled:Boolean = true;
		private static var flush_status:String = "";
		
		public static function set enabled(val:Boolean):void
		{
			_enabled = val;
		}
		public static function get enabled():Boolean
		{
			return _enabled;
		}
		
		private var shared_obj:SharedObject;
		private var so_data:Object;
		private var max_so_size:Number = 10000;
		private var so_id:String;
		private var auto_delete_tries:int = 4;
		
		/**
		 * constructor. Write the SharedObject under a common name at the top level of the directory. Whenever
		 * a users SharedObject becomes larger the 10k the entire object is cleaned.
		 * 
		 * @param $id String to identify the data for this application. Should be unique per application
		 * 
		 * @param $expiration <code>Date</code> that the object will naturally expire. Note that other aplications
		 * will be cleaning up after your application based on this date.
		 * 
		 * @param $priority  should be used only with explict approval. Setting this property to <code>OddcastSharedObject.PERMANENT</code> will 
		 * maintain the data during size overrun clean up. This setting will not override the expiration however.
		 */
		public function OddcastSharedObject($id:String, $expiration:Date, $priority:String = ""):void
		{
			if (!enabled)
				return;
			//trace("OSO -- constructor");
			try
			{
				shared_obj = SharedObject.getLocal("oddcast_so", "/");
			}
			catch(e:Error)
			{
				trace("SHARED OBJECT ERROR !!! "+e.message);
				throw(e);
			}
			if (shared_obj != null && $id.length > 0)
			{
				//traceSO(shared_obj.data);
				trace("SO SIZE "+shared_obj.size);
				if (shared_obj.size > max_so_size) internalDeleteSO();
				shared_obj.addEventListener(NetStatusEvent.NET_STATUS, e_netStatus);
				cleanUp();
				so_id = $id;
				if (shared_obj.data[so_id] == null)
				{
					shared_obj.data[so_id] = new Object();
				}
				if (shared_obj.data[so_id].data == null)
				{
					shared_obj.data[so_id].data = new Object();
				}
				so_data = shared_obj.data[so_id].data;
				shared_obj.data[so_id].expiration = $expiration;
				shared_obj.data[so_id].priority = $priority;
				shared_obj.data[so_id].name = so_id;
				flushSO();
			}
		}
		
		/**
		 * 
		 * Get a reference the unique data object for this application
		 * 
		 * @return <code>Object</code> that can be used to store data
		 * 
		 */ 
		public function getDataObject():Object
		{
			if (!enabled)
				return null;
			
			if (so_data == null)
			{
				return new Object();
			}
			else
			{
				return so_data;
			}
		}
		
		/**
		 * Write your data to your unique object location.
		 * 
		 * @return <code>Boolean</code> for a successful or unsuccessful write
		 */
		public function write($obj:Object):Boolean
		{
			if (!enabled)
				return false;
			
			//trace("OSO -- write");
			if (shared_obj != null && so_id.length > 0 && shared_obj.data[so_id] != null && shared_obj.data[so_id].data != null)
			{
				so_data = $obj;
				shared_obj.data[so_id].data = so_data;
				flushSO();
				//trace("SO SIZE - "+shared_obj.size);
				if (shared_obj.size > max_so_size) internalDeleteSO();
				//traceSO(shared_obj.data);
				return true;
			}
			else
			{
				return false;
			}
				
		}
		
		/**
		 * Deletes the contents of the SharedObject but maintains data marked as PERMANENT
		 * 
		 * @param $remove_all <code>Boolean</code> Passing <code>true</code> also deletes any <code>PERMANENT</code> data
		 * 
		 */
		public function deleteSO($remove_all:Boolean = false):void
		{
			if (!enabled)
				return;
			
			if (shared_obj != null)
			{
				if ($remove_all)
				{
					shared_obj.clear();
				}
				else
				{
					var t_obj:Object = new Object();
					for (var s1:String in shared_obj.data)
					{
						if (shared_obj.data[s1].priority == PERMANENT)
						{
							t_obj[s1] = shared_obj.data[s1];
						}
					}
					shared_obj.clear();
					for (var s2:String in t_obj)
					{
						shared_obj.data[s2] = t_obj[s2];
					}
					flushSO();
					//traceSO(shared_obj.data);
				}
			}
		}
		
		public function traceSO($o:Object = null, $tab:String = ""):String
		{
			if (!enabled)
				return null;
			
			//trace("trace so --- " + $o);
			var t_str:String = "";
			if ($o == null) $o = shared_obj.data;
			for (var i:Object in $o)
			{
				t_str += $tab+" "+ i+"  "+ $o[i].toString()+"\n";
				trace($tab+" "+ i+"  "+ $o[i].toString());
				if ($o[i] is Object && $o[i] != null) t_str += traceSO($o[i], $tab+"\t");
			}
			return t_str;
		}
		
		public function getSOSize():Number
		{
			if (!enabled)
				return Number.NaN;
			
			return shared_obj.size;
		}
		
		private function internalDeleteSO():void
		{
			if (!enabled)
				return;
			
			if (auto_delete_tries == 0) 
			{
				//trace("OSO - SIZE OVERRUN DELETE -- PERMANENT");
				deleteSO(true);
			}
			else
			{
				//trace("OSO - SIZE OVERRUN DELETE");
				deleteSO();
			}
			--auto_delete_tries;
		}
		
		private function flushSO():void
		{
			if (!enabled)
				return;
			
			//trace("OSO --- FLUSH SO -- flush_status: "+flush_status);
			//traceSO(shared_obj.data);
			if (flush_status != SharedObjectFlushStatus.PENDING)
			{
				try
				{
					flush_status = shared_obj.flush();
				}
				catch($e:Error)
				{
					trace("SHARED OBJECT - FLUSH ERROR - "+$e.message);
				}
			}
		}
		
		private function cleanUp():void
		{
			if (!enabled)
				return;
			
			var t_obj:Object = new Object();
			for (var s1:String in shared_obj.data)
			{
				if (s1.length > 0 && shared_obj.data[s1] != null)
				{
					var t_so_date:Date;
					if (shared_obj.data[s1].toString() == "[object Object]" && shared_obj.data[s1].expiration != null && shared_obj.data[s1].expiration is Date) t_so_date = shared_obj.data[s1].expiration as Date
					var t_now_date:Date = new Date();
					if (t_so_date == null || t_so_date.getTime() > t_now_date.getTime())
					{
						t_obj[s1] = shared_obj.data[s1]
					}
				}
			}
			shared_obj.clear();
			for (var s2:String in t_obj)
			{
				shared_obj.data[s2] = t_obj[s2];
			}
			flushSO();
		}
		
		private function e_netStatus($ne:NetStatusEvent):void
		{
			if (!enabled)
				return;
			
			//trace("OSO -- NET STATUS EVENT "+$ne.toString()+"  "+$ne.info.code);
			if ($ne.info.level == "error")
			{
				//trace("OSO --- set to null  !! type "+ shared_obj)
				//USER_DENY = true;
				shared_obj = null;
			}
			
		}
	}
}