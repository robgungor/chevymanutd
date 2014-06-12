package com.oddcast.io
{		
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import com.oddcast.encryption.Base64;
	

	public class OCLoader extends Loader
	{
		
		public static var appDomain:ApplicationDomain;
		public static const loaderAPIClassName:String = "LOADER_API";
		
		public function OCLoader()
		{
			//appDomain = root.loaderInfo.applicationDomain;
		}
		
		override public function load(request:URLRequest, context:LoaderContext=null) : void
		{
			
			var assetLibName:String = getBaseName(request.url);				
			trace("OCLoader::load "+request.url);
			if (appDomain.hasDefinition(loaderAPIClassName))
			{
				trace("OCLoader::load hasDefinition "+loaderAPIClassName);
				var loaderAPIClass:Class = appDomain.getDefinition(loaderAPIClassName) as Class;
				var loaderResourceAPI:* = new loaderAPIClass();		
				trace("OCLoader::load got data for "+assetLibName+" = "+loaderResourceAPI.getData(assetLibName));
				var ba:ByteArray = Base64.decode(loaderResourceAPI.getData(assetLibName));//Base64.decode("Q1dTCssHAAB4nKVVz0/jRhSecRwbwu8lZNFWlVy2UvewiccJsIoFKRCvKw4RK4K0e0FksCdkqGNb44GEU1c99NAeKvXW22pP/Qd6rPZfSE+VKnGr9tx7D+k4CZAApWxrJbJm3vd98+Z7T89tkDwAYOYNAIsQWHOLAICv5uUkAGvMrZu7lq21m54fmWK1vtTgPDR1vdVq5VqFXMCOdKNYLOoor+fzWYHIRmc+x+2sHz1eKmk9BYtEDqMhp4GvxWt8GJzw9aWlgWy7GV7K+lEOu8EhyTlBU2/jUDdySI91BMgsM4J5wPaCwCttxijN9nDU0MrVZe0FC+okisQR2FvTr6OH+MQS/1IeGSiLClnj2Z5hmIVVc0Usl02Ehrh9ZJ9aIRy7mOMb5IJZWDaXjWHyCHZAD1xaP7sX+QqprenX3Lu3n5XK3Y42m/oFOuK7pH43Oto7C4m+S6LghDlEwB8PKlKpmNt+xLHvkG2rJDZylLom2nqWXyna6PlmwbBswyhaq6vlwupWAZWLZRvZvYuOUi/UrMA5aRKfD9TcD1Abol6o7TB6REU/3KJa3DK2VvJo09q6W/UWictcCaOnxLVZ0OxVIcQsIrFT60sXVsU29fw16U2biva/pXCDeqHm3nKhe6q5wxfpbwX/x6Z/lNAuC3Pl039uade57NDwhHm9seM6OvFIfFokutToTQnXMesBa2JewmHoUQfHgno7GzUC58sWPiXZejwx1vQr4K0p6YPBV9JAWep2u+8WJsRQhKDqEJ9oBgDd9MveRiP9QIPWMWhkfpiEfxAAIeiKKEyL6Pn5eXdu5fuv//xl4ffvHoG0/TrZ2v91/7eaTDfgoyc/n6eyp+9Buvha+vZt5+1PbxI/boD3L4+fgG8UBQpt8C79F4wPEc8syMWvxWlG3AOHMscjB+IqkxVM/T3aJB71yVTvbqJuUejhs/FKcEpJ2aPhR6Mcc5gDYKRUOaP+kVJnuEmMFMfsiPBc1KonOcMOgfonA+evBsNmtaDnEVrVD0+ox6mfFCdSngiDcBq7otJCqNpzU9k5PCYOn+xnRk7jYs08j1+WyBJzp0HYlNVPuA+d2/Y5Eedy0TP9ncxIvByIr4tInCnVkFFOxjIwk1hMZpSHcGwq8wDMqlBSJVmVVVUeU5PjqjyhKtOqMqPKs6o8p6rzqpRWpQVVyqjSQxlcfyCUxhJAkhIAyCDZKwNMQChDsYRwPJXooC96W6mJxQ7qPE01EvtKp554Ommr0B4DOwoUcSmOz4r4Ntgf/xR06smdcUnsJySh8VkHEVBLodoEqk2i2hSqTaPaDKpJ4vcKfNx/GrHM5/Ma6DfAaAlzIyXcEPG/AWXLTdU=");					
				this.loadBytes(ba,context);
				return;				
			}			
			//if failed load normally
			trace("load swf normally");
			super.load(request, context);			
		}
		
		private function getBaseName(s:String):String
		{			
			return s.split("/").pop();
		}				
	}
}