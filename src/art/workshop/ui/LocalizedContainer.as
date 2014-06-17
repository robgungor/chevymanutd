package workshop.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	
	
	public class LocalizedContainer extends MovieClip
	{
		public function LocalizedContainer()
		{
			super();
		}
		public function setLanguage(lang:String):DisplayObjectContainer
		{
			var view:*;
			for(var i:int = 0; i < numChildren; i++)
			{
				view = 	getChildAt(i);
				if(view is DisplayObjectContainer)
				{
					view.visible = view.name == lang;
				}	
			}
			
			_localView  = (getChildByName(lang) as DisplayObjectContainer) != null ? (getChildByName(lang) as DisplayObjectContainer) : (getChildByName("us") as DisplayObjectContainer);
			
			// we have to add this to make a default view visible
			_localView.visible = true;
			
			return _localView;
		}
		private var _localView:DisplayObjectContainer;
		public function get localView():DisplayObjectContainer
		{
			return _localView;
		}
	}
}