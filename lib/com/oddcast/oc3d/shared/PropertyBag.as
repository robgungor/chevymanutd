package com.oddcast.oc3d.shared
{
	import com.oddcast.oc3d.external.IPropertyBag;
	
	import flash.utils.Dictionary;
	
	public class PropertyBag implements IPropertyBag
	{
		private var registrationChangedFns_:Dictionary = new Dictionary(); // Dictionary<name:String, registrationChangedFn:Function<propertyChangedFn:Function>>
		private var properties_:Dictionary = new Dictionary(); // Dictionary<name:String, PropertyBagEntry>
		
		public function setProperty(name:String, value:Object):void
		{
			var entry:PropertyBagEntry = PropertyBagEntry(properties_[name]);
			if (entry == null)
				properties_[name] = entry = new PropertyBagEntry();
			entry.value = value;
			entry.changedSignal.invoke(value);
		}
		public function isPropertyBeingWatched(name:String):Boolean
		{
			var entry:PropertyBagEntry = PropertyBagEntry(properties_[name]);
			if (entry == null)
				return false;
			else
				return entry.changedSignal.count() > 0;
		}
		public function registerRegistrationWatcher(name:String, property:String, registrationChangedFn:Function):void
		{
			var key:String = name + ":" + property;
			
			var fn:Function = registrationChangedFns_[key];
			if (fn != null)
				throw new Error("registration \"" + name + "\" is already being watched");
			registrationChangedFns_[key] = registrationChangedFn;
			
			var entry:PropertyBagEntry = PropertyBagEntry(properties_[property]);
			if (entry == null)
				registrationChangedFn(null);
			else
				registrationChangedFn(entry.changedSignal.invoke);
		}
		public function unregisterRegistrationWatcher(name:String, property:String):void
		{
			var key:String = name + ":" + property;
			
			var fn:Function = registrationChangedFns_[key];
			if (fn != null)
				fn(null) 
			delete registrationChangedFns_[key];
		}

		// -- IMPL BEGIN IPropertyBag --
		public function tryGetProperty(property:String):* // returns null of the property is not found
		{
			var entry:PropertyBagEntry = PropertyBagEntry(properties_[property]);
			return entry == null ? null : entry.value;
		}
		
		// changedFn:Function<Object>
		public function registerPropertyWatcher(name:String, changedFn:Function):void
		{
			var bag:PropertyBagEntry = PropertyBagEntry(properties_[name]);
			if (bag == null)
				properties_[name] = bag = new PropertyBagEntry();

			bag.changedSignal.add(changedFn);

			for each (var key:String in registrationChangedFns_)
			{
				var property:String = Str.rsplit(key, ":")[1];
				if (name == property)
				{
					var fn:Function = registrationChangedFns_[key];
					if (fn != null)
						fn(bag.changedSignal.invoke);
				}
			}
		}
		// changedFn:Function<Object>
		public function unregisterPropertyWatcher(name:String, changedFn:Function):void
		{
			var bag:PropertyBagEntry = new PropertyBagEntry();
			if (bag == null)
				return;
				
			bag.changedSignal.remove(changedFn);
			
			for each (var key:String in registrationChangedFns_)
			{
				var property:String = Str.rsplit(key, ":")[1];
				if (name == property)
				{
					var fn:Function = registrationChangedFns_[key];
					if (fn != null)
						fn(null);
					
					if (bag.changedSignal.count() == 0)
						delete properties_[name];
				}
			}
		}
		// -- IMPL BEGIN IPropertyBag --
	}
}