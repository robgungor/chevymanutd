/**
* ...
* @author Default
* @version 0.1
*/

package com.oddcast.workshop.videostar {
	import com.oddcast.data.IThumbSelectorData;
	import com.oddcast.workshop.WSModelStruct;

	public class ActorStruct implements IThumbSelectorData {
		public var id:int;
		public var name:String;
		private var _model:WSModelStruct;
		public var defaultModel:WSModelStruct;
		
		public function ActorStruct($id:int,$name:String) {
			id=$id;
			name = $name;
		}
		
		public function set thumbUrl(s:String) : void {
			if (_model == null) _model = new WSModelStruct(null);
			_model.thumbUrl = s;
		}
		
		public function get thumbUrl():String {
			if (_model == null) return(null);
			else return(_model.thumbUrl);
		}
		
		public function get charXML():XML {
			if (_model == null) return(null);
			else return(_model.charXml);
		}
		
		public function set charXML(_xml:XML) : void {
			if (_model == null) _model = new WSModelStruct(null);
			model.charXml = _xml;
		}
		
		public function get model():WSModelStruct {
			return(_model);
		}
		
		public function set model(m:WSModelStruct) : void {
			_model = m;
		}
		
		public function setModelWithCurrentCharXML(m:WSModelStruct) : void {
			if (m!=null) m.charXml = charXML;
			_model = m;
		}
		
		public function get fgUrl():String {
			if (charXML == null) return(null);
			else return(charXML.url.(@id == "fgfile").@url.toString());
		}
		
		public function set fgUrl(s:String) : void {
			//charXML=<fgchar><url id="photoface" url="http://content.dev.oddcast.com/ccs1/customhost/239/3d/z_Kiera.jpg"/><url id="fgfile" url="http://content.dev.oddcast.com/ccs1/customhost/239/3d/z_Kiera.fg"/></fgchar>

			if (charXML == null) charXML =<fgchar><url id="fgfile" /></fgchar>
			charXML.url.(@id == "fgfile").@url = s;
		}
		
		public function hasModel(v2:Boolean=false):Boolean {
			if (_model == null) return(false);
			if (v2) {
				return(_model.charXml != null && _model.url != null && _model.engine != null);
			}
			else { //v1 videostar only requires an fg file, not an oa1 file or engine
				return(_model.charXml != null && fgUrl != null && fgUrl.length > 0);
			}
		}
		
		public function clone():ActorStruct {
			var a:ActorStruct=new ActorStruct(id,name);
			a.model = model;
			a.defaultModel = defaultModel;
			return(a);
		}
	}
	
}