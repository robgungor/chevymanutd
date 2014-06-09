package code.component.skinners
{
	import com.oddcast.ui.ComponentStyle;
	
	import fl.core.UIComponent;

	public class Custom_Scrollbar_Skinner
	{
		public function Custom_Scrollbar_Skinner( _component:UIComponent )
		{		
			_component.setStyle(ComponentStyle.SCROLLBAR.ARROW_UP_DisabledSkin		,Custom_ScrollArrowUp_disabledSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.ARROW_UP_DownSkin			,Custom_ScrollArrowUp_downSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.ARROW_UP_OverSkin			,Custom_ScrollArrowUp_overSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.ARROW_UP_UpSkin			,Custom_ScrollArrowUp_upSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.ARROW_DOWN_DisabledSkin	,Custom_ScrollArrowDown_disabledSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.ARROW_DOWN_DownSkin		,Custom_ScrollArrowDown_downSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.ARROW_DOWN_OverSkin		,Custom_ScrollArrowDown_overSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.ARROW_DOWN_UpSkin			,Custom_ScrollArrowDown_upSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.TRACK_DisabledSkin			,Custom_ScrollTrack_disabledSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.TRACK_DownSkin				,Custom_ScrollTrack_skin);
			_component.setStyle(ComponentStyle.SCROLLBAR.TRACK_OverSkin				,Custom_ScrollTrack_skin);
			_component.setStyle(ComponentStyle.SCROLLBAR.TRACK_UpSkin				,Custom_ScrollTrack_skin);
			_component.setStyle(ComponentStyle.SCROLLBAR.THUMB_DownSkin				,Custom_ScrollThumb_downSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.THUMB_OverSkin				,Custom_ScrollThumb_overSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.THUMB_UpSkin				,Custom_ScrollThumb_upSkin);
			_component.setStyle(ComponentStyle.SCROLLBAR.THUMB_ICON					,Custom_ScrollBar_thumbIcon);
		}
	}
}