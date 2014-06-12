package com.oddcast.mmo{

	import com.oddcast.mmo.data.ExtensionData;
	import com.oddcast.mmo.events.ChatroomEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;	
	
	public class ChatroomBasic extends MovieClip
	{		
				
		protected var _nWidth:Number;
		protected var _nHeight:Number;
		protected var _arrSpeakerIds:Array;				
		
		protected var roomHalfSizeX:Number;
		protected var roomHalfSizeZ:Number;
		protected var _nMaxDistance:Number
				
		protected var _iClientUserId:int;
		protected var _sClientUserName:String = "";
				
		protected var _mcSceneCover:Sprite;
		protected var _mcSceneBg:Sprite;
		
		public function ChatroomBasic()
		{
			trace("ChatroomBasic::ChatroomBasic");
					
			_nWidth = this.loaderInfo.parameters.w!=null?this.loaderInfo.parameters.w:640;
			_nHeight = this.loaderInfo.parameters.h!=null?this.loaderInfo.parameters.h:480;						
			
			_mcSceneCover = new Sprite();	
			_mcSceneCover.graphics.beginFill(0x000000,0);
            _mcSceneCover.graphics.drawRect(0, 0, _nWidth, _nHeight);
            _mcSceneCover.graphics.endFill();  
			
			_mcSceneBg = new Sprite();	
			_mcSceneBg.graphics.beginFill(0x000000,1);
            _mcSceneBg.graphics.drawRect(0, 0, _nWidth, _nHeight);
            _mcSceneBg.graphics.endFill();  
						
		}
						
		//handler for chatManager events
		public function onNewCommand(extData:ExtensionData,username:String=""):void
		{			
			trace("Chatroom3d::onNewCommand " + extData.getCmd());					
			switch (extData.getCmd())
			{
				case "makeNewAvOk": 
					// Our (or someone else's) av-creation request was approved (by the
					// server extension) so we create (or mirror) that avatar.					
					var uid:int = int(extData.getDataByIndex(2))					
					var thumbUrl:String = extData.getDataByIndex(4);					
					if (uid==_iClientUserId)
					//only my own avatar creation has these values 
					{
						_sClientUserName = username.length > 0?username:_sClientUserName;
						roomHalfSizeX = Number(extData.getDataByIndex(4));// as Number; // Capture for later use.
						roomHalfSizeZ = Number(extData.getDataByIndex(5));// as Number; //radius if round
						if (roomHalfSizeX==-1)//circle
						{
							_nMaxDistance = 2*roomHalfSizeZ; //twice the radius (koter)
						}
						else
						{
							_nMaxDistance = Math.sqrt((2*roomHalfSizeX*2*roomHalfSizeX)+(2*roomHalfSizeZ*2*roomHalfSizeZ));
						}												
					}
					else if (thumbUrl.length > 0)
					{
						dispatchEvent(new ChatroomEvent(ChatroomEvent.ON_RECEIVE_DATA,"thumb,"+thumbUrl+","+uid+","+username));
					}
					addAvatar(uid, uid==_iClientUserId, extData,username);
					break;
				case "addAv":					
					var uid:int = int(extData.getDataByIndex(2))					
					addAvatar(uid, uid==_iClientUserId, extData,username);
					var thumbUrl:String = extData.getDataByIndex(4);
					if (thumbUrl.length>0)
					{
						dispatchEvent(new ChatroomEvent(ChatroomEvent.ON_RECEIVE_DATA,"thumb,"+thumbUrl+","+uid));
					}
					break;
				case "rmAv":
					removeAvatar(int(extData.getDataByIndex(0)));					
					break;
				case "orient":
					var uid:int = int(extData.getDataByIndex(1))	
					updateAvatarYaw(uid,int(extData.getDataByIndex(0)));					
					break;
				case "move":
					moveAvatar(int(extData.getDataByIndex(1)), extData.getDataByIndex(0));														
					break;
				case "text":										
					var uid:int = int(extData.getDataByIndex(1));					
					var msgStr:String = extData.getDataByIndex(0);
					msgAvatar(uid, msgStr);										
					break;
				case "lipMic":
					//trace("Chatroom3d::onNewCommand lipMic f="+extData.getDataByIndex(1));
					//var uid:int = int(extData.getDataByIndex(0));
					micAmpChanged(int(extData.getDataByIndex(1))); //use amp2lipFrame					
					break;
				case "lipSpeaker":
					//trace("Chatroom3d::onNewCommand lipSpeaker f="+extData.getDataByIndex(1));
					speakerAmpChanged(int(extData.getDataByIndex(1)));					
					break;
				case "setSpeaker":
					trace("Chatroom3d::onNewCommand setSpeaker 0 speakerId="+extData.getDataByIndex(0));	
					setSpeakersList(extData.getDataByIndex(0).split("|"));					
					break;
				case "geturl":
					trace("chatroom3d::onNewCommand playVideo "+extData.getDataByIndex(0));					
					playVideo(extData.getDataByIndex(0));
					break;
				case "onAvUpdate":
					trace("chatroomBasic::onNewCommand onAvUpdate");
					onOtherAvPosUpdate(extData.getDataByIndex(0));
					break;
			}	
			chatroomUpdated();		
		}
		
		public function setClientUserId(i:int):void
		{
			_iClientUserId = i;
		}
		
		public function mute(b:Boolean):void{};
		
		public function disconnect():void{};				
		
		protected function onOtherAvPosUpdate(dataStr:String):void
		{
			
		}
		
		protected function addAvatar(userId:int, isMe:Boolean, data:ExtensionData, username:String=""):void{};
		protected function removeAvatar(userId:int):void{};
		protected function updateAvatarYaw(userId:int, yaw:int):void{};
		protected function moveAvatar(userId:int, dir:String):void{};
		protected function msgAvatar(userId:int, msg:String):void{};
		protected function micAmpChanged(vol:int):void{};
		protected function speakerAmpChanged(vol:int):void{};
		protected function setSpeakersList(userIds:Array):void
		{
			_arrSpeakerIds = userIds;
		}
		public function playVideo(url:String):void{};
								
		protected function amp2lipFrame(micLevel:Number):int
		{
			var ret:int = int((micLevel*100)%16)+1; //16 frames of mouth - this function should be rewritten for better lipsync
			//trace("Conference::amp2lipFrame micLevel="+micLevel+" -> ret="+ret);
			return ret;
		}		
		
		protected function chatroomUpdated():void{};
	}
}
