package com.oddcast.host.api.animate {
	import com.oddcast.host.api.animate.AnimationValues;
	public interface ISetAnimationCallback {
		function updateAnimation(animVal : com.oddcast.host.api.animate.AnimationValues,timeOffset : Number) : Boolean ;
		function resetAnimation(animVal : com.oddcast.host.api.animate.AnimationValues,origAnimVal : com.oddcast.host.api.animate.AnimationValues) : Boolean ;
	}
}
