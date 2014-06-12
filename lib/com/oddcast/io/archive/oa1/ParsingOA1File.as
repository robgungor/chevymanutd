package com.oddcast.io.archive.oa1 {
	
	import com.oddcast.util.FSM;
	public class ParsingOA1File extends com.oddcast.util.FSM {
		public function ParsingOA1File() : void {  {
			this.setState(PARSE_FILENAMELENGTH);
		}}
		
		public var filenameLength : int;
		public var contentLength : int;
		static public var PARSE_FILENAMELENGTH : int = com.oddcast.util.FSM.INCREMENTOR++;
		static public var PARSE_FILENAME : int = com.oddcast.util.FSM.INCREMENTOR++;
		static public var PARSE_COMPRESSEDFLAG : int = com.oddcast.util.FSM.INCREMENTOR++;
		static public var PARSE_CONTENTLENGTH : int = com.oddcast.util.FSM.INCREMENTOR++;
		static public var PARSE_CONTENT : int = com.oddcast.util.FSM.INCREMENTOR++;
		static public var PARSE_FINISHED : int = com.oddcast.util.FSM.INCREMENTOR++;
	}
}
