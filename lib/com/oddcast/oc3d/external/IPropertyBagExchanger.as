package com.oddcast.oc3d.external
{
	public interface IPropertyBagExchanger
	{
		function exchange(bag:IPropertyBag):IPropertyBag;
		function unexchange(bag:IPropertyBag):IPropertyBag; 
	}
}