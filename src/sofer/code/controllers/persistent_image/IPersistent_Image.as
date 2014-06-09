package code.controllers.persistent_image
{
	import com.oddcast.workshop.WSModelStruct;

	public interface IPersistent_Image
	{
		function update_fb_username( _fb_userid:String ):void;
		function save_new_model( _model:WSModelStruct, _complete_callback:Function = null ):void;
	}
}