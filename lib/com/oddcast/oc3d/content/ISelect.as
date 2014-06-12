package com.oddcast.oc3d.content
{
	public interface ISelect
	{
		function internalSelect():void;
		function internalDeselect():void;
		function select():void;
		function deselect():void;
		function isSelected():Boolean;
	}
}