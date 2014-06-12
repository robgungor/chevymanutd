package com.oddcast.workshop.Persistent_Image 
{
	
	/**
	 * ...
	 * @author Me^
	 */
	public interface IPersistent_Image_Item 
	{
		/**
		 * id of of the current image
		 * @return id
		 */
		function id():String
		/**
		 * full url of the thumnail for this image
		 * @return full url
		 */
		function thumb_url():String
		/**
		 * full xml as its stored in the DB
		 * @return xml
		 */
		function stored_xml():XML
		/**
		 * XML prepared for autophoto usage similar to what APC creates
		 * @return xml
		 */
		function prepared_xml():XML
	}
	
}