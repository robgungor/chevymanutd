package com.oddcast.workshop.fb3d.dataStructures 
{		
	import com.oddcast.oc3d.content.IAnimationProxy;
	/**
	 * ...
	 * @author jachai
	 */
	public class AnimationData 
	{
		
		private var _animation:IAnimationProxy;				
		public function AnimationData(animation:IAnimationProxy) 
		{			
			_animation = animation;			
		}				
						
		public function get id():int
		{
			return _animation.id();
		}
		
		public function get name():String
		{
			return _animation.name();
		}				
		
		public function get animation():IAnimationProxy
		{
			return _animation;
		}
				
	}
	
}