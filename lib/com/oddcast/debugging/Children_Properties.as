package com.oddcast.debugging 
{
	
	/**
	 * @about displays information about all the children from a selected root
	 * @author Me^
	 */
	public class Children_Properties 
	{
		/**
		 * recursive call to reference all objects starting with the one passed
		 * sample usage: new Children_Properties( this, false);
		 * @param	_root root where to look in
		 * @param	_dig_deeper if to look into child objects
		 */
		public function Children_Properties(_root:*, _dig_deeper:Boolean = false) 
		{
			reference_all_inside(_root, ' ', _dig_deeper);
		}
		/**
		 * recursive call to reference all objects starting with the one passed
		 * @param	_root root where to look in
		 * @param	_spacing spacing for nicer display
		 * @param	_dig_deeper if to look into child objects
		 */
		private function reference_all_inside( _root:*, _spacing:String = '', _dig_deeper:Boolean = false) : void 
		{
			var has_kids:Boolean = true;

			try{_root.numChildren;}	catch (e:Error)	{has_kids = false;}
			
			if (has_kids)
			{
//				for (var i:int = 0; i < _root.numChildren; i++)		// lowest item in display list is referenced first
				for (var i:int = _root.numChildren-1; i >= 0; i--)	// highest item in display list is referenced first
					if (_root.getChildAt(i))
					{
						var cur:* = _root.getChildAt(i)
						show_this( cur, _spacing);
						if (_dig_deeper)
							reference_all_inside( cur, _spacing + ' ' );
					}
			}
		}
		/**
		 * displays general information about this object
		 * @param	_this the object
		 * @param	_spacing spacing in front representative of the depth
		 */
		private function show_this(_this:*, _spacing:String):void
		{
			var cur			:*			= _this;
			var nume		:String;	try {	nume = cur.name; }									catch (e:Error) { nume = '-'; }
			var lable		:String;	try {	lable = cur.label; }								catch (e:Error) { lable = '-'; }
			var heigt		:String;	try {	heigt = cur.height.toString(); } 					catch (e:Error) { heigt = '-'; }
			var widt		:String; 	try {	widt = cur.width.toString(); } 						catch (e:Error) { widt = '-'; }
			var parent_name	:String;	try {	parent_name = cur.parent.name; }					catch (e:Error) { parent_name = '-'; }
			var maskk		:*;			try {	maskk = cur.mask; } 								catch (e:Error) { maskk = null; }
			var mask_name	:String;	try {	mask_name = maskk.name; }							catch (e:Error) { mask_name = '-'; }
			var alph		:String;	try {	alph = cur.alpha.toString(); } 						catch (e:Error) { alph = '-'; }
			var vizz		:String;	try {	vizz = cur.visible.toString(); }					catch (e:Error) { vizz = '-'; }
			var dept		:String;	try {	dept = cur.parent.getChildIndex(cur).toString(); }	catch (e:Error) { dept = '-'; }
			var ruut		:String;	try {	ruut = cur.root.name; }								catch (e:Error) { ruut = '-'; }
			var rott		:String;	try {	rott = cur.rotation.toString(); }					catch (e:Error) { rott = '-'; }
			var scaley 		:String;	try {	scaley = cur.scaleY.toString(); }					catch (e:Error) { scaley = '-'; }
			var scalex 		:String;	try {	scalex = cur.scaleX.toString(); }					catch (e:Error) { scalex = '-'; }
			
			trace(	_spacing, 
					parent_name + '.' + nume, 
					'\t',
					'class:' + _this, 
					'mask:' + maskk, 
					'mask name:' + mask_name, 
					'label:' + lable, 
					'width:' + widt, 
					'height:' + heigt, 
					'rotation:' + rott, 
					'scaleX:' + scalex,
					'scaleY:' + scaley,
					'alpha:' + alph, 
					'visible:' + vizz, 
					'depth:' + dept, 
					'root:' + ruut );
		}
	}
	
}