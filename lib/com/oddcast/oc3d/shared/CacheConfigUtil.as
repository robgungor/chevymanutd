package com.oddcast.oc3d.shared
{
	public class CacheConfigUtil
	{
		
		private static const PRE_DATA_URL:String = "char/oh/";
		public function CacheConfigUtil()
		{
		}
		//var url:String = 'char/oh/36895/m/36842/d/34402/v/1.0/oh.avt?36867=FF0000';
		public function url2config(s:String):XML
		{		
			//var urlSplit:Array = s.split("?");
			var permArr:Array = s.split("/");
			/*
			var colorArr:Array
			if (urlSplit.length>1)
			{
				colorArr = urlSplit[1].split("&");
			}
			*/
			var xml:XML = new XML('<Configuration/>');
			var asNode:XML = new XML('<AccessorySet/>');
			
			var nodeType:String = "";
			var i:int;
			for (i=1; i< permArr.length; ++i)
			{				 
				if (permArr[i]=="m" || permArr[i]=="d" || permArr[i]=="v" || permArr[i]=="oh" || permArr[i]=="c")
				{
					nodeType = permArr[i];
					continue;
				}
				else if (permArr[i]=="oh.avt") //end of ur
				{
					break;
				}
				
				switch (nodeType)
				{
					case "m":
						var mcNode:XML = new XML('<MaterialConfiguration/>');
						mcNode.@id = permArr[i];
						asNode.appendChild(mcNode);
						break;
					case "d":
						var dNode:XML = new XML('<DecalConfiguration/>');
						dNode.@id = permArr[i];
						asNode.appendChild(dNode);
						break;					
				 	case "oh":
							asNode.@id = permArr[i];
							break;
					case "v":
						xml.@version = permArr[i];
						break;
					case "c":
						var cNode:XML = new XML('<ColorMaterialLayer/>');
						var cNodeData:Array = permArr[i].split("=");
						cNode.@id = cNodeData[0];
						cNode.@value = "#"+cNodeData[1];
						asNode.appendChild(cNode);
						break;
				}
			}
			/*
			if (colorArr!=null)
			{
				for (i=0; i<colorArr.length;++i)
				{
					
					var cNode:XML = new XML('<ColorMaterialLayer/>');
					var cNodeData:Array = colorArr[i].split("=");
					cNode.@id = cNodeData[0];
					cNode.@value = "#"+cNodeData[1];
					asNode.appendChild(cNode);					
				}
			}
			*/
			xml.appendChild(asNode);			
			return xml;
		}
		
		public function config2url(_xml:XML):String
		{
			var xmlNode:XML;
			var url:String = PRE_DATA_URL+_xml.AccessorySet.@id;
			url+="/m";
			for each(xmlNode in _xml.AccessorySet.MaterialConfiguration)
			{
				url+="/"+xmlNode.@id;
			}	
			url+="/d";
			for each(xmlNode in _xml.AccessorySet.DecalConfiguration)
			{
				url+="/"+xmlNode.@id;
			}	
			
			url+="/c";
			for each(xmlNode in _xml.AccessorySet.ColorMaterialLayer)
			{
				url+="/"+xmlNode.@id+"="+String(xmlNode.@value).split("#")[1];				
			}
						
			url+="/v/"+_xml.@version
			url+="/oh.avt"			
			return url;
		}
	}
}