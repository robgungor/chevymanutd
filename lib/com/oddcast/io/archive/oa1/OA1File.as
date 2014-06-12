package com.oddcast.io.archive.oa1 {
	import flash.utils.IDataOutput;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import com.oddcast.io.archive.oa1.ParsingOA1File;
	
	public class OA1File {
		public function OA1File(filename : String = null) : void {  {
			this.name = filename;
		}}
		
		public var name : String;
		public var index : int;
		public var content : flash.utils.ByteArray;
		public function fill(content : flash.utils.ByteArray,bCompressed : Boolean) : void {
			this.content = content;
			this.bCompressed = bCompressed;
			this.bCurrentlyCompressed = false;
		}
		
		public function serialize(stream : flash.utils.IDataOutput) : void {
			stream.writeUTF(this.name);
			stream.writeBoolean(this.bCompressed);
			var uncompressedLength : uint = this.content.length;
			this.compress();
			stream.writeInt(this.content.length);
			stream.writeBytes(this.content,0,this.content.length);
		}
		
		public function parse(stream : flash.utils.IDataInput) : Boolean {
			if(this.parsingOA1 == null) this.parsingOA1 = new com.oddcast.io.archive.oa1.ParsingOA1File();
			do {
				var avail : uint = stream.bytesAvailable;
				switch(this.parsingOA1.getState()) {
				case com.oddcast.io.archive.oa1.ParsingOA1File.PARSE_FILENAMELENGTH:{
					if(avail < 4) return false;
					this.parsingOA1.filenameLength = stream.readUnsignedShort();
					this.parsingOA1.incState();
				}break;
				case com.oddcast.io.archive.oa1.ParsingOA1File.PARSE_FILENAME:{
					if(avail < this.parsingOA1.filenameLength) return false;
					this.name = stream.readUTFBytes(this.parsingOA1.filenameLength);
					null;
					this.parsingOA1.incState();
				}break;
				case com.oddcast.io.archive.oa1.ParsingOA1File.PARSE_COMPRESSEDFLAG:{
					if(avail < 4) return false;
					this.bCompressed = this.bCurrentlyCompressed = stream.readBoolean();
					null;
					this.parsingOA1.incState();
				}break;
				case com.oddcast.io.archive.oa1.ParsingOA1File.PARSE_CONTENTLENGTH:{
					if(avail < 4) return false;
					this.parsingOA1.contentLength = stream.readInt();
					null;
					this.parsingOA1.incState();
				}break;
				case com.oddcast.io.archive.oa1.ParsingOA1File.PARSE_CONTENT:{
					if(avail < this.parsingOA1.contentLength) {
						return false;
					}
					this.content = new flash.utils.ByteArray();
					stream.readBytes(this.content,0,this.parsingOA1.contentLength);
					if(this.bCompressed) {
						this.uncompress();
					}
					null;
					this.parsingOA1.incState();
					this.parsingOA1 = null;
					return true;
				}break;
				}
			} while(stream.bytesAvailable > 0);
			return false;
		}
		
		public function getContentAsString() : String {
			this.content.position = 0;
			return this.content.readUTFBytes(this.content.bytesAvailable);
		}
		
		protected var bCompressed : Boolean;
		protected var bCurrentlyCompressed : Boolean;
		protected var parsingOA1 : com.oddcast.io.archive.oa1.ParsingOA1File;
		protected function compress() : void {
			if(this.bCompressed && !this.bCurrentlyCompressed) {
				this.content.position = 0;
				this.content.compress();
				this.bCurrentlyCompressed = true;
			}
			this.content.position = 0;
		}
		
		protected function uncompress() : void {
			if(this.bCurrentlyCompressed) {
				this.content.position = 0;
				this.content.uncompress();
				this.bCurrentlyCompressed = false;
			}
			this.content.position = 0;
		}
		
		public function filesize() : int {
			return this.content.length;
		}
		
	}
}
