package com.destroytoday.twitteraspirin.demo.contexts {
	import com.destroytoday.twitteraspirin.Twitter;
	import com.destroytoday.twitteraspirin.demo.controllers.AuthenticationController;
	import com.destroytoday.twitteraspirin.demo.mediators.AuthenticationMediator;
	import com.destroytoday.twitteraspirin.demo.views.AuthenticationView;
	
	import flash.display.DisplayObjectContainer;
	
	import org.robotlegs.mvcs.Context;
	
	public class ApplicationContext extends Context {
		public function ApplicationContext(contextView:DisplayObjectContainer = null, autoStartup:Boolean = true) {
			super(contextView, autoStartup);
		}
		
		override public function startup():void {
			injector.mapValue(Twitter, new Twitter("40iqOgCcXcJYwqoa02D7nQ", "o0emdpQvijub2tMXpA7wAVwt3tI4FSx447NfWECS8"));
			
			mediatorMap.mapView(AuthenticationView, AuthenticationMediator);
		}
	}
}