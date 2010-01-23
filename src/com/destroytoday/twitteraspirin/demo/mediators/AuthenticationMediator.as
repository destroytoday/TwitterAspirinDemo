package com.destroytoday.twitteraspirin.demo.mediators {
	import com.destroytoday.net.StringLoader;
	import com.destroytoday.net.XMLLoader;
	import com.destroytoday.twitteraspirin.Twitter;
	import com.destroytoday.twitteraspirin.demo.constants.ViewState;
	import com.destroytoday.twitteraspirin.demo.views.AuthenticationView;
	import com.destroytoday.twitteraspirin.oauth.OAuth;
	
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.iotashan.oauth.OAuthToken;
	import org.robotlegs.mvcs.Mediator;

	public class AuthenticationMediator extends Mediator {
		[Inject]
		public var twitter:Twitter;
		
		[Inject]
		public var view:AuthenticationView;
		
		public var authenticationSO:SharedObject = SharedObject.getLocal("authentication");
		
		public function AuthenticationMediator() {
		}
		
		override public function onRegister():void {
			view.requestTokenClickSignal.add(requestTokenButtonClickHandler);
			view.authorizeClickSignal.add(authorizeButtonClickHandler);
			view.verifyAccessTokenClickSignal.add(verifyAccessTokenButtonClickHandler);
			view.logoutClickSignal.add(logoutButtonClickHandler);
			
			twitter.oauth.requestTokenSignal.add(requestTokenHandler);
			twitter.oauth.accessTokenSignal.add(accessTokenHandler);
			twitter.oauth.verifyAccessTokenSignal.add(verifyAccessTokenHandler);
			
			var accessToken:Object = authenticationSO.data['accessToken'];
			var skipVerification:Boolean = authenticationSO.data['skipVerification'];
			
			if (accessToken) {
				twitter.oauth.accessToken = new OAuthToken(accessToken.key, accessToken.secret);
				view.accessToken = accessToken.key + " / " + accessToken.secret;
				
				if (skipVerification) {
					view.currentState = ViewState.AUTHORIZED;
					view.status.text = "Authorized, but not verified"
				} else {
					view.currentState = ViewState.VERIFY_ACCESS_TOKEN;
					
					twitter.oauth.verifyAccessToken(twitter.oauth.accessToken);
				}
			}
		}
		
		override public function onRemove():void {
			
		}
		
		protected function requestTokenHandler(oauth:OAuth, token:OAuthToken):void {
			view.currentState = ViewState.PIN;
			view.requestToken = token.key + " / " + token.secret;
			view.status.text = "Awaiting pin...";
			
			navigateToURL(new URLRequest(twitter.oauth.getAuthorizeURL()));
		}
		
		protected function accessTokenHandler(oauth:OAuth, token:OAuthToken):void {
			if (view.rememberAccessToken.selected) {
				authenticationSO.data['accessToken'] = token;
			}
			
			authenticationSO.data['skipVerification'] = view.skipVerification.selected;
			
			view.currentState = ViewState.VERIFY_ACCESS_TOKEN;
			view.accessToken = token.key + " / " + token.secret;
			view.status.text = "Idle";
		}
		
		protected function verifyAccessTokenHandler(oauth:OAuth, token:OAuthToken):void {
			view.currentState = ViewState.AUTHORIZED;
			view.status.text = "Verified";
		}
		
		protected function requestTokenButtonClickHandler():void {
			twitter.oauth.getRequestToken();
			
			view.status.text = "Loading request token...";
		}
		
		protected function authorizeButtonClickHandler():void {
			var loader:StringLoader = twitter.oauth.getAccessToken(uint(view.pinInput.text));
			
			loader.errorSignal.addOnce(getAccessTokenErrorHandler);
			
			view.status.text = "Loading access token...";
		}
		
		protected function getAccessTokenErrorHandler(loader:StringLoader, type:String, message:String):void {
			trace(type, message);
		}
		
		protected function verifyAccessTokenButtonClickHandler():void {
			twitter.oauth.verifyAccessToken(twitter.oauth.accessToken);
			
			view.status.text = "Verifying access token...";
		}
		
		protected function logoutButtonClickHandler():void {
			view.currentState = ViewState.REQUEST_TOKEN;
			
			view.status.text = "Idle";
			view.requestToken = null;
			view.pin = 0;
			view.accessToken = null;
			authenticationSO.data['accessToken'] = null;
			authenticationSO.data['skipVerification'] = null;
		}
	}
}