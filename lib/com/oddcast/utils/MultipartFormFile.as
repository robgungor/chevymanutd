/**
* ...
* @author Jonathan Achai
* @version 0.1
* 
* A multipart/form-data post file
* 
*/

package com.oddcast.utils
{	
	import flash.utils.ByteArray;
	
	public class  MultipartFormFile 
	{
		private var _bytes:ByteArray;
		private var _name:String;
		private var _contentType:String;// = "application/octet-stream";
		private var _sBoundary:String;
		private var _fieldName:String;
		
		function MultipartFormFile(filename:String,bytes:ByteArray,boundary:String,contentType:String,fieldName:String=null):void
		{
			_name = filename;
			_bytes = bytes;
			_sBoundary = boundary;
			_contentType = contentType;
			_fieldName=fieldName;
		}
		
		public function setContentType(s:String):void
		{
			_contentType = s;
		}
		
		public function getBytes(fileIndex:uint):ByteArray
		{
			var retBytes:ByteArray = new ByteArray();
			var headerBytes:ByteArray = getHeaderBytes(fileIndex);
			retBytes.writeBytes(headerBytes,0,headerBytes.length);
			retBytes.writeBytes(_bytes,0,_bytes.length);
			var footerBytes:ByteArray = new ByteArray();
			var endHeaderBytes:ByteArray = new ByteArray();
			endHeaderBytes.writeMultiByte('\r\n--'+_sBoundary+'--\r\n',"ascii");			
			retBytes.writeBytes(endHeaderBytes,0,endHeaderBytes.length);
			return retBytes;
		}
		
		private function getHeaderBytes(fileIndex:uint):ByteArray
		{
			var s:String = '--'+_sBoundary+'\r\n';
			if (_fieldName==null) _fieldName="Filedata"+fileIndex;
			s+='Content-Disposition: form-data; name="'+_fieldName+'"; filename="'+_name+'"\r\n';
			s+='Content-Type: '+_contentType+'\r\n\r\n';			
			var retBytes:ByteArray = new ByteArray();
			retBytes.writeMultiByte(s,"ascii");
			return retBytes;			
		}
		
	}
	
	
	
}