package com.oddcast.ui {
	
	/**
	* ...
	* @author Sam Myer
	* this is necessary for the OAccordion class
	*/
	public interface ISelectable {
		function get selected():Boolean;
		function set selected(b:Boolean):void;
	}
	
}