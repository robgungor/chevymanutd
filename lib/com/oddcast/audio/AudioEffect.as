/**
* ...
* @author Sam Myer, Me^
* @version 0.1
* data structure to hold Audio Effects information
* required : type, level
*/

package com.oddcast.audio 
{

	public class AudioEffect 
	{
		public var type:String;
		public var level:Number;
		public var typeName:String;
		public var levelName:String;
		
		public function AudioEffect(in_type:String,in_level:Number) {
			type=in_type.toLowerCase();
			level=in_level;
		}
		
		/**
		 * a complete new reference/copy of this object
		 * @return
		 */
		public function clone(  ):AudioEffect 
		{
			var cloned_effect:AudioEffect = new AudioEffect( type, level );
			cloned_effect.typeName	= typeName;
			cloned_effect.levelName	= levelName;
			return cloned_effect;
		}
		
		public static function createFromCode(s:String):AudioEffect {
			//parses a string such as "t2" into an effect object with type "t" and level 2
			var i:int = 0;
			var c:String;
			while (i <s.length) {
				c = s.charAt(s.length - i - 1);
				if (c == "-" && i > 0) {
					i++;
					break;
				}
				else if (isNumber(c)) i++;
				else break;
			}
			i = s.length - i;
			var typeStr:String = s.slice(0, i);
			var level:Number = parseFloat(s.slice(i));
			return(new AudioEffect(typeStr, level));
		}
		
		private static function isNumber(c:String):Boolean {
			return(c >= "0" && c <= "9");
		}
		
		public function get code():String {
			return(type + level.toString());
		}
	}
	
}