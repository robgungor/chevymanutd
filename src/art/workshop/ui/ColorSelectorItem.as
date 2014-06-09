/**
* ...
* @author Default
* @version 0.1
*/

package workshop.ui {
	import com.oddcast.ui.ButtonSelectorItem;
	import com.oddcast.utils.ColorData;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.text.TextField;

	public class ColorSelectorItem extends ButtonSelectorItem {
		public var swatch:MovieClip;
		public var tf_button:TextField;
		
		override public function set data(o:Object):void {
			super.data=o;
			var col:ColorData=o as ColorData;
			var ct:ColorTransform=new ColorTransform();
			ct.color=col.hex;
			swatch.transform.colorTransform=ct;
		}

	}
	
}