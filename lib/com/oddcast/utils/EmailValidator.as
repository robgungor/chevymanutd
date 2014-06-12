/**
* ...
* @author Sam, Me^
* @version 0.5
* 
*/

package com.oddcast.utils {

	public class EmailValidator {		
		//public static const EMAIL_REGEXP:RegExp=/^[a-z][\w.-]+@\w[\w.-]+\.[a-z]{2,4}$/i;	// sams
		//public static const EMAIL_REGEXP:RegExp =/([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}/; // naphtalis pick
		//public static const EMAIL_REGEXP:RegExp = /^[a-z][\w.-]+@[\w.-]+\.[\w.-]*[a-z][a-z]$/i; // mihai pick
		public static const EMAIL_REGEXP:RegExp = /^[a-z0-9][\w.-]+@[\w.-]+\.[\w.-]*[a-z][a-z]$/i; // mihai pick now allowing ###@something.com
		
		
		/**
		 *checks the email provided if valid or not 
		 * @param s email
		 * @return true if valid, false if not valid
		 * 
		 */		
		public static function validate(s:String):Boolean {
			return(EMAIL_REGEXP.test(s));
		}
		
		/**takes a string containing a bunch of emails separated by whitespace, comma, or semicolon.
		returns a string with those emails separated by commas
		e.g. "homer@simpson.com   marge@simpson.com ; bart@simpson.com,lisa@simpson.com" becomes
		"homer@simpson.com, marge@simpson.com, bart@simpson.com, lisa@simpson.com"*/
		public static function commaSeparate(s:String):String {
			s=s.replace(/(^\s+)|(\s+$)/g,"") //trim
			s=s.replace(/[\s,;]+/,", ") //comma-separate
			return(s);
		}
		
		/**given a string of emails separated by whitespace, comma, or semicolons,
		this will return true if all of the emails in the list are valid*/
		public static function validateMultiple(s:String):Boolean {
			s=s.replace(/(^\s+)|(\s+$)/g,"") //trim
			var a:Array=s.split(/[\s,;]+/) //split by whitespace, comma or semicolon
			if (a.length==0) return(false);
			for (var i:int=0;i<a.length;i++) {
				if (!validate(a[i])) return(false);
			}
			return(true);
		}
	}
	
}