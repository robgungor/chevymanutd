/**
* ...
* @author Sam Myer, Me^
* @version 0.1
* 
* extension of the HostStruct class for Workshop
* 
* url - the url of the model.  for 3d models this is the oa1 head file.
* charXml - the XML containing the character information for the 3d model.  this xml is sent to jake's engine
* to configure the characer and usually contains a url to the fg file and maybe an image.
* 
* id - Model ID.  this is the id of the unconfigured source model
* charId - character id.  this is the id of a saved character that has been configured (with colors, sizing, accessories)
* hasId - returns true if this host is coming from the server and has been assigned a character id
* tempId - if this model hasn't been assigned a character id, this returns a unique temp id for this model
* 
* is3d - true if this is a 3d model, false if 2d.
* thumbUrl - url of thumb to be displayed in the thumbselector
* 
* oa1Type - for 3d models only, this is the type of oa1 model.  this mostly just effects the autophoto process
* also, we may want to disable or enable certain options depending on the oa1 type.  see the OA1TYPE
* constants below for more details.
*/

package com.oddcast.workshop 
{
	import com.oddcast.data.*;
	import com.oddcast.assets.structures.*;

	public class WSModelStruct extends HostStruct implements IThumbSelectorData 
	{
		protected static var tempCounter		:int		= 1;
		private var _tempId						:int		= 0;
		public var isAutoPhoto					:Boolean	= false;
		public var autoPhotoSessionId			:int;
		/* the XML containing the character information for the 3d model.  this xml is sent to jake's engine to configure the characer and usually contains a url to the fg file and maybe an image. */
		public var charXml						:XML		= null;
		/* character id.  this is the id of a saved character that has been configured (with colors, sizing, accessories) */
		public var charId						:int		= -1;
		/* true if this is a 3d model, false if 2d. */
		public var is3d							:Boolean	= false;
		private var modelThumbUrl				:String;
		/* for 3d models only, this is the type of oa1 model.  this mostly just effects the autophoto process also, we may want to disable or enable certain options depending on the oa1 type.  see the OA1TYPE constants below for more details. */
		public var oa1Type						:int		= 0;
		/* indicates weather this was created from a persistent image load */
		public var created_from_persistent_image:Boolean	= false;
		/* keeps track if this model was already saved to the persistant Image DB to avoid duplicate saves */
		public var saved_to_persistent_image	:Boolean	= false;
		/* full body data for this model */
		public var full_body_struct				:WS_Body_Struct;
		
		public static var OA1TYPE_FULLPHOTO		:int = 1;  //(photofit demo)
		public static var OA1TYPE_MASKEDPHOTO	:int = 2;  //(gillette)
		public static var OA1TYPE_FACEONLY		:int = 3;  //(Nokia, Heiniken)
		public static var OA1TYPE_3DHEAD		:int = 4;  //(surrogates)
		
		public function WSModelStruct(in_url:String, in_id:int = 0, in_thumb:String = "", in_name:String = "") 
		{
			super(in_url, (in_id < 0 ? 0 : in_id) );
			engine		= null;
			_tempId		= tempCounter;
			tempCounter++;
			
			thumbUrl	= in_thumb;
			name		= in_name;
		}
		
		/**
		 * checks if this model has head information
		 * @return
		 */
		public function has_head_data(  ):Boolean
		{
			return (engine != null);
		}
		/**
		 * checks if this model has body information
		 * @return
		 */
		public function has_body_data(  ):Boolean
		{
			return (full_body_struct && full_body_struct.engine );
		}
		
		public function get thumbUrl():String {
			return(modelThumbUrl);
		}
		
		public function set thumbUrl(s:String) : void {
			modelThumbUrl=s;
		}
		
		/**
		 * returns true if this host is coming from the server and has been assigned a character id
		 */
		public function get hasId():Boolean {
			return(charId>0);
		}
		
		public function get tempId():int {
			//if (hasId) return(-1);
			//else return(_tempId);
			return(_tempId);
		}
		
		
		/**
		 * copy the model
		 * @return new model
		 */
		public function clone():WSModelStruct 
		{
			//tempid and charId should be unique, so those variables don't get cloned
			var m:WSModelStruct				= new WSModelStruct(url, id, modelThumbUrl, name);
			m.catId							= catId;
			m.catName						= catName;
			m.charXml						= new XML(charXml);
			m.is3d							= is3d;
			m.isAutoPhoto					= isAutoPhoto;
			m.oa1Type						= oa1Type;
			m.type							= type;
			m.created_from_persistent_image	= created_from_persistent_image;
			// manual clone of a engineStruct
				m.engine					= new EngineStruct( engine.url, engine.id, engine.type);
				m.engine.ctlUrl				= engine.ctlUrl;
				m.engine.catId				= engine.catId;
				m.engine.catName			= engine.catName;
				
			return(m);
		}
	}
	
}