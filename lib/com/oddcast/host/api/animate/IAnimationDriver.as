package com.oddcast.host.api.animate {
	public interface IAnimationDriver {
		function isReady() : Boolean ;
		function isActive() : Boolean ;
		function getCurrTime(timeOffset : Number = NaN,desc : String = null) : Number ;
	}
}
