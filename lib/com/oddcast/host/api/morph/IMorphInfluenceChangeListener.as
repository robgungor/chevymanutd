package com.oddcast.host.api.morph {
	import com.oddcast.host.api.morph.MorphInfluence;
	public interface IMorphInfluenceChangeListener {
		function morphInfChangedHandler(morphInfluence : com.oddcast.host.api.morph.MorphInfluence,changeType : int) : void ;
	}
}
