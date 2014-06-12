/**
* @author Sam Myer
* 
* Stores a lookup table of keys and text.  This is used currently to translate error messages in the workshops
* 
* FUNCTIONS:
* 
* addEntry(key,val)
* adds a key-value pair to the lookup table
* 
* autoParse(XMLList,attributeName)
* this takes an XMLList of the format:
* <???  attributeName="key1">value1</???>
* <???  attributeName="key2">value2</???>
* where:
* -??? can be anything
* -attributeName is the name you provide.  If you don't provide an attribute name, it will use the first
* attribute it finds in the node
* -key,value are the key-value pairs
* 
* translate(key,defaultVal,varReplace)
* returns a value from the lookup table where
* where:
* 
* key - is the key associated with that value
* 
* defaultVal - if the key is not found in the lookup table, return this value.  "" by default
* 
* varReplace - if this is specified it allows you to replace template variables in the value with data.
* variables are specified by putting them within curly braces.
* e.g.
* addEntry("msg1","Today's date is {date}")
* translate("msg1","",{date:"Jan 6 2009"})
* will return - "Today's date is Jan 6 2009"
* 
*/
package com.oddcast.workshop {
	
	public class TranslationLookup {
		private var struct:Object;
		
		public function TranslationLookup()
		{
			struct = new Object();
		}
		
		public function addEntry(key:String, val:String):void
		{
			struct[key] = val;
		}
		
		public function autoParse(xlist:XMLList,attributeName:String=null):void
		{
			if (xlist.length() == 0) 
				return;
			if (attributeName==null) 
			{
				if (xlist[0].attributes().length() == 0) 
					return;
				attributeName = xlist[0].attributes()[0].name();
			}
			var key:String;
			var val:String;
			var node:XML;
			LOOP1: for (var i:int = 0, n:int = xlist.length(); i<n; i++ )
			{
				node = xlist[ i ];
				key = unescape(node.attribute(attributeName).toString());
				val = unescape(node.toString());
				struct[key] = val;
				// break LOOP1;
			}
		}
		
		public function translate(key:String, defaultVal:String="", varReplace:Object=null):String {
			if (key == null || 
				key == ""||
				struct==null) 
				return(defaultVal);
			var val:String = struct[key];
			if (val == null)
				return(defaultVal);
			
			var infoKey:String;
			//replace placeholders in text surrounded by {} brackets with values from evt.moreInfo
			//e.g. "You cannot use the word {badWord}" - becomes - You cannot use the word "balzac"
			if (varReplace != null) 
			{
				for (infoKey in varReplace)
				{
					val = val.split("{" + infoKey + "}").join(varReplace[infoKey]);
				}
			}
			return(val);
		}
	}
	
}