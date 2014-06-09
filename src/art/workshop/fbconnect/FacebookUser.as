
package workshop.fbconnect {
	import com.oddcast.data.IThumbSelectorData;
	
	/**
	 * ...
	 * @author Sam Myer
	 */
	public class FacebookUser implements IThumbSelectorData {
		public var id:Number;
		public var name:String
		public var city:String;
		public var state:String;
		public var country:String;
		public var zip:String;
		private var _thumbUrl:String;
		public var data:XML;
		
		/*public function FacebookUser($id:Number=0, $name:String=null, $thumbUrl:String=null, $city:String = "", $state:String = "", $country:String = "", $zip:String = "") {
		id = $id;
		name = $name;
		_thumbUrl = $thumbUrl;
		city = $city;
		state = $state;
		country = $country;
		zip = $zip;
		}*/
		public function FacebookUser(data:XML):void
		{
			var props:XMLList = data.children();
			//trace("PROPS: "+props);
			var prop:XML;
			this.data = data;
			for each(prop in props) 
			{
				//trace("item: " + prop.toXMLString());
				if(	this.hasOwnProperty(prop.name()) )
				{
					if(prop.children().length() > 1) this[prop.name()] = prop.toXMLString();
					else this[prop.name()] = prop.text().toString();
				}
				//trace(prop.name()+": "+this[prop.name()]);
			}
			id = parseFloat(data.uid.toString());
			if(this.family)
			{
				_familyMembers = [];
				_immediateFamily = [];
				var fam:XML = new XML(this.family.toString());
				var members:XMLList = fam.children();
				var immediate:Array  = [];
				/*for each(var member:XML in members)
				{
					var value:String = member..uid.text() || member..name.text();
					var f:FamilyMember = new FamilyMember(member..relationship.text(), member..uid.text(), member..name.text());
					_familyMembers.push(f);
					if(isImmediate(f.relationship)) _immediateFamily.push(f);
				}
				trace("FAMILY: "+_familyMembers);*/
				
			}
			
			function isImmediate(val:String):Boolean
			{
				return val == "sister" || val == "brother" || val == "mother" || val == "father";
			}
			
		}
		public var spouseLastName:Object;
		
		protected var _immediateFamily:Array;
		public function get immediateFamily():Array
		{
			return _immediateFamily;
		}
		protected var _familyMembers:Array;
		public function get familyMembers():Array
		{
			return _familyMembers;
		}
		public function get thumbUrl():String{
			return((pic || pic_square) as String);
		}
		public function set thumbUrl(s:String):void {
			_thumbUrl = s;
		}
		public function getLocation():String {
			
			var loc:XML = new XML(current_location.toString());
			return loc.child("name").text();
			
			
			var locationArr:Array=new Array();
			if (city!=null&&city.length > 0) locationArr.push(city);
			if (state!=null&&state.length > 0) locationArr.push(state);
			if (country != null && country.length > 0 && locationArr.length < 2) locationArr.push(country);
			return(locationArr.join(", "));
		}
		
		public var uid					:Object 
		public var first_name			:Object 
		public var middle_name			:Object 
		public var last_name			:Object  
		public var pic_small			:Object 
		public var pic_big				:Object 
		public var pic_square			:Object 
		public var pic					:Object 
		public var affiliations			:Object 
		public var profile_update_time	:Object 
		public var timezone				:Object 
		public var religion				:Object 
		public var birthday				:Object 
		public var birthday_date		:Object 
		public var sex					:Object 
		public var hometown_location	:Object 
		public var meeting_sex			:Object 
		public var meeting_for			:Object 
		public var relationship_status	:Object 
		public var significant_other_id	:Object 
		public var political			:Object 
		public var current_location		:Object 
		public var activities			:Object 
		public var interests			:Object 
		public var is_app_user			:Object 
		public var music				:Object 
		public var tv					:Object 
		public var movies				:Object 
		public var books				:Object 
		public var quotes				:Object 
		public var about_me				:Object 
		public var hs_info				:Object 
		public var education_history	:Object 
		public var work_history			:Object 
		public var notes_count			:Object 
		public var wall_count			:Object 
		public var status				:Object 
		public var has_added_app		:Object 
		public var online_presence		:Object 
		public var locale				:Object 
		public var proxied_email		:Object 
		public var profile_url			:Object 
		public var email_hashes			:Object 
		public var pic_small_with_logo	:Object 
		public var pic_big_with_logo	:Object 
		public var pic_square_with_logo	:Object 
		public var pic_with_logo		:Object 
		public var allowed_restrictions	:Object 
		public var verified				:Object 
		public var profile_blurb		:Object 
		public var family				:Object 
		public var username				:Object 
		public var website				:Object 
		public var is_blocked			:Object 
		public var contact_email		:Object 
		public var email				:String;
		
		
	}
	
}

/*package workshop.fbconnect {
	import com.oddcast.data.IThumbSelectorData;
	
	public class FacebookUser implements IThumbSelectorData {
		public var id:Number;
		public var name:String
		public var city:String;
		public var state:String;
		public var country:String;
		public var zip:String;
		private var _thumbUrl:String;
		
		public function FacebookUser($id:Number=0, $name:String=null, $thumbUrl:String=null, $city:String = "", $state:String = "", $country:String = "", $zip:String = "") {
			id = $id;
			name = $name;
			_thumbUrl = $thumbUrl;
			city = $city;
			state = $state;
			country = $country;
			zip = $zip;
		}
		
		public function get thumbUrl():String{
			return(_thumbUrl);
		}
		public function set thumbUrl(s:String):void {
			_thumbUrl = s;
		}
		public function getLocation():String {
			var locationArr:Array=new Array();
			if (city!=null&&city.length > 0) locationArr.push(city);
			if (state!=null&&state.length > 0) locationArr.push(state);
			if (country != null && country.length > 0 && locationArr.length < 2) locationArr.push(country);
			return(locationArr.join(", "));
		}
	}
	
}*/