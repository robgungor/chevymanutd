package com.oddcast.oc3d.shared
{
	public class Str
	{
		public static function contains(str:String, search:String):Boolean
		{
			if (str == null)
				return false;
			else
				return str.indexOf(search, 0) != -1;
		}

		public static function isNullOrEmpty(string:String):Boolean
		{
			return string==null || string.length == 0;
		}
		public static function completeSplit(str:String, delimiter:String, removeNulls:Boolean=true, transformFn:Function=null):Array // Array<String>
		{
			var result:Array = new Array();
			if (str == "")
				return result;
			do
			{
				var tup:Array = split(str, delimiter);
				if (!removeNulls || (removeNulls && !isNullOrEmpty(tup[0])))
					result.push(transformFn == null ? tup[0] : transformFn(tup[0]));
				str = tup[1];
			}
			while (!isNullOrEmpty(str));
			return result;
		}
		public static function split(str:String, pivot:String):Array
		{
			var index:int = str.indexOf(pivot);
			if (index == -1)
				return [str, ""];
			else
				return [str.substr(0, index), str.substr(index + pivot.length, str.length - (index + pivot.length))];
		}
		public static function rsplit(str:String, pivot:String):Array
		{
			var index:int = str.lastIndexOf(pivot);
			if (index == -1)
				return ["", str];
			else
				return [str.substr(0, index), str.substr(index + pivot.length, str.length - (index + pivot.length))];
		}

		public static function endsWith(str:String, match:String):Boolean
		{
			if (str.length == 0 && match.length != 0)
				return false;
			else
				return String(rsplit(str, match)[1]).length == 0;
		}
		public static function startsWith(str:String, match:String):Boolean
		{
			if (str.length == 0 && match.length != 0)
				return false;
			else
				return String(split(str, match)[0]).length == 0;
		}
		public static function xmlEscape(s:String):String
		{
			/*return Util.replaceAll(Util.replaceAll(Util.replaceAll(Util.replaceAll(Util.replaceAll(s, 
			"&", "&amp;"), 
			"'", "&apos;"), 
			"\"", "&quote;"),
			">", "&gt;"),
			"<", "&lt;");*/
			return replaceAll(replaceAll(replaceAll(replaceAll(replaceAll(replaceAll(s, 
				"&", "&amp;"), 
				"'", "&apos;"), 
				"\"", "\\\""),
				"\\", "\\\\"),
				">", "&gt;"),
				"<", "&lt;");
		}
		public static function xmlUnescape(s:String):String
		{
			/*return Util.replaceAll(Util.replaceAll(Util.replaceAll(Util.replaceAll(Util.replaceAll(s, 
			"&lt;", "<"),
			"&gt;", ">"),
			"&quote;", "\""),
			"&apos;", "'"), 
			"&amp;", "&"); */
			return replaceAll(replaceAll(replaceAll(replaceAll(replaceAll(replaceAll(s, 
				"&lt;", "<"),
				"&gt;", ">"),
				"\\\\", "\\"),
				"\\\"", "\""),
				"&apos;", "'"), 
				"&amp;", "&"); 
		}
		public static function occrpt(s:String, o:int):String
		{										
			var d:String = new String();		
			
			for (var i:int=0; i<s.length; ++i)	
			{									
				var c:int = s.charCodeAt(i);	
				
				if (c >= 48 && c <= 57)			
				{								
					c = (c - o)-48;				
					if (c < 0) c += (57-48+1);	
					c = (c % (57-48+1)) + 48;	
				}								
				else							
					if (c >= 65 && c <= 90)			
					{								
						c = (c - o)-65;				
						if (c < 0) c += (90-65+1);	
						c = (c % (90-65+1)) + 65;	
					}								
					else							
						if (c >= 97 && c <= 122)		
						{								
							c = (c - o)-97;				
							if (c < 0) c += (122-97+1);	
							c = (c % (122-97+1)) + 97;	
						}								
				
				d += String.fromCharCode(c);	
			}									
			
			return d;							
		}										

		public static function replaceAll(s:String, oldStr:String, newStr:String):String
		{
			var result:String = "";
			while (true)
			{
				var index:int = s.indexOf(oldStr, 0);
				if (index == -1)
				{
					result += s;
					return result;
				}
				else
				{
					result += s.substr(0, index) + newStr;
					s = s.substr(index + oldStr.length);
				}
			}
			
			return result;
		}

		public static function unescape(s:String):String
		{
			return replaceAll(replaceAll(replaceAll(replaceAll(replaceAll(replaceAll(s,
				"\\t", "\t"), 
				"\\'", "\'"), 
				"\\r", "\r"), 
				"\\n", "\n"), 
				"\\\"", "\""), 
				"\\\\", "\\");
		}
		public static function escape(s:String):String
		{
			return replaceAll(replaceAll(replaceAll(replaceAll(replaceAll(replaceAll(s, 
				"\\", "\\\\"), 
				"\"", "\\\""), 
				"\n", "\\n"), 
				"\r", "\\r"), 
				"\'", "\\'"), 
				"\t", "\\t");
		}	}
}