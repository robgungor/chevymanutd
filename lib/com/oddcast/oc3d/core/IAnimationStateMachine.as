package com.oddcast.oc3d.core
{
	public interface IAnimationStateMachine
	{
		function resume():void;
		function pause():void;
		
		// playFn:Function<k:Function> stopFn:Function<>
		function newState(name:String, playFn:Function, stopFn:Function):void;
		
		// playFn:Function<k:Function> stopFn:Function<>
		function newTransition(name:String, oldStateName:String, newStateName:String, isInterruptible:Boolean, cost:int, playFn:Function, stopFn:Function):void;
		
		function setGoal(stateNames:Array, goalReachedFn:Function):void;
		
		function dispose():void;
	}
}