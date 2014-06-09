package code.component.skinners
{
	import com.oddcast.ui.ComponentStyle;
	
	import fl.controls.ComboBox;
	
	import code.controllers.tts.TTS_ComboBox_List_CellRenderer;

	public class Custom_ComboBox_Skinner
	{
		public function Custom_ComboBox_Skinner( _combo_box:ComboBox )
		{
			_combo_box.setStyle(ComponentStyle.COMBO_BOX.DisabledSkin				,Custom_ComboBox_disabledSkin);
			_combo_box.setStyle(ComponentStyle.COMBO_BOX.DownSkin					,Custom_ComboBox_downSkin);
			_combo_box.setStyle(ComponentStyle.COMBO_BOX.OverSkin					,Custom_ComboBox_overSkin);
			_combo_box.setStyle(ComponentStyle.COMBO_BOX.UpSkin						,Custom_ComboBox_upSkin);
		}
	}
}