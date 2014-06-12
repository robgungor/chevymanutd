package com.oddcast.io.archive.oa1 {
	import com.oddcast.io.archive.oa1.OA1File;
	
	import com.oddcast.util.FSM;
	public class ParsingArchiveOA1 extends com.oddcast.util.FSM {
		public function ParsingArchiveOA1() : void {  {
			this.setState(PARSE_SIGNATURE);
		}}
		
		public var currfile : com.oddcast.io.archive.oa1.OA1File;
		static public var PARSE_SIGNATURE : int = com.oddcast.util.FSM.INCREMENTOR++;
		static public var PARSE_VERSION : int = com.oddcast.util.FSM.INCREMENTOR++;
		static public var PARSE_FILES : int = com.oddcast.util.FSM.INCREMENTOR++;
		static public var PARSE_FINISHED : int = com.oddcast.util.FSM.INCREMENTOR++;
	}
}
