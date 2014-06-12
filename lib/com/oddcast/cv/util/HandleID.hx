

	/**
	 * ...
	 * @author Jake Lewis
	 * 5/24/2010 11:48 AM
	 */
	package  com.oddcast.cv.util;
	//import com.oddcast.cv.util.HandleID;
	
	typedef ID			= Int;
	typedef ID_Type		= Int;
	
	class HandleID 
	{
			//do not use bit 31
			inline public static var VALID  		:Int =  0x40000000;
			
			inline public static var FACEID			:Int =  0x00100000;
			inline public static var FRAMESTOREID	:Int =  0x00200000;
			
			inline public static var HANDLE_MASK    :Int =  0x000FFFFF;
			
			inline public static var NULL_ID        :ID	 =  0x80000000;
			
			public function new(type:ID_Type) {
				this.type = type;
				currID = 0;
			}
			
			public function createHandle():ID{
				if (currID > HANDLE_MASK)	
					throw "out of handles for type " + type;
				return VALID + type + (currID++);
			}
			
			public function checkHandle(handle:ID):Bool {
				if ( handle == NULL_ID)
					throw "Null Handle of type " + type;
				if ( (handle & VALID) != VALID)
					throw "Invalid Handle " + handle + " of type " + type;
				if ( (handle & type) != type)
					throw "Invalid Handle type. is " + (handle & type) + ", should be " + type;
				return true;
			}
			
			public function releaseHandle(handle:ID	):ID {
				handle &= (VALID ^ 0xffffffff);
				return NULL_ID;
			}
			
			var type 		:ID_Type;
			var currID		:ID;
			
			
	}

