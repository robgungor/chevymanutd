package code.controllers.auto_photo.auto_photo 
{
	
	/**
	 * ...
	 * @author Me^
	 */
	public interface IAuto_Photo 
	{
		function image_source_type( _type:String ):void;
		function track_image_source_type():void;
		function beginMasking(_url:String):void;
	}
	
}