public with sharing class Wrike_ApiUtils {
    
    private static final String WRIKE_API = '/api/v3';
    private static final String WRIKE_OAUTH2_TOKEN = '/oauth2/token';
    private static final String WRIKE_OAUTH2_AUTHORIZE = '/oauth2/authorize?response_type=code';
    
    public enum HttpMethod { GET, PUT, POST }
    
    public static String getAuthorizeURL() {
        return WrikeAccountSettings__c.getOrgDefaults().WrikeServer__c + WRIKE_OAUTH2_AUTHORIZE;
    }
    
    public static String processApiRequest(String relativePath, String body, Wrike_ApiUtils.HttpMethod method) {
        
        HttpRequest req = constructApiRequest(relativePath, body, method);
        HttpResponse res = sendRequest(req);
        processResponse(res, req);
        return res.getBody();
    }
    
    private static HttpResponse sendRequest(HttpRequest req) {
        
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
        } catch(CalloutException cex) {
            if ('Read timed out'.equals(cex.getMessage())) {
                res = retryRequest(req);
            } else {
                throw new Wrike_Exceptions.BaseCalloutException(cex.getMessage(), cex);   
            }         
        } catch(Exception ex) {
            throw new Wrike_Exceptions.BaseCalloutException(ex.getMessage(), ex);
        }
        
        return res;
    }
 
    private static void processResponse(HttpResponse res, HttpRequest req) {
        System.debug('===res.toString(): ' + res.toString() + '\n' + res.getBody());
      //  System.debug('===req.toString(): ' + req.toString() + '\n' + req.getBody());
   //   System.debug('===res.toString(): ' + res.toString());
      System.debug('===req.toString(): ' + req.toString());
        Integer statusCode = res.getStatusCode();
        if(statusCode >= 400) {            
            if(statusCode == 401) {
                throw new Wrike_Exceptions.NotAuthorizedException();            
            }    
            if(statusCode == 403) {
                throw new Wrike_Exceptions.WrikeAccessDeniedException();    
            }
            if(statusCode == 400) {
                throw new Wrike_Exceptions.InvalidRequestException();    
            }
            if(statusCode == 404) {
            	throw new Wrike_Exceptions.WrikeResourceNotFoundException();
            }
            throw new Wrike_Exceptions.ApiErrorException(res.toString() + '\r\n' + req.toString());
        }
    }
    
    private static HttpResponse retryRequest(HttpRequest req) {
        
        Http http = new Http();
        req.setTimeout(40000);
        HttpResponse res;
        try {
            res = http.send(req);
        } catch(Exception ex) {
            throw new Wrike_Exceptions.BaseCalloutException(ex.getMessage(), ex);
        }
        return res;
    }
 
    private static HttpRequest constructApiRequest(String relativePath, String body, Wrike_ApiUtils.HttpMethod method) {
        
        String wrikeHost = WrikeAccountSettings__c.getOrgDefaults().WrikeServer__c;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(wrikeHost + WRIKE_API + relativePath);
        req.setHeader('Authorization', 'Bearer ' + Wrike_API__c.getInstance().Token__c);
        if(!String.isBlank(body)) {
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');        
            req.setBody(body);
        }
        req.setMethod(method.Name());
        return req;
    }
    
    /// OAuth methods ///
    public static boolean refreshExpiredToken() {
       
           Wrike_API__c api = Wrike_API__c.getInstance();
        
        if (api.RefreshToken__c == null ||
            api.RefreshToken__c == '') {

            return false;
        }

        String refreshTokenResponse = Wrike_ApiUtils.requestTokenRefresh();
        System.debug('==refreshTokenResponse ' + refreshTokenResponse);
        if (refreshTokenResponse == null) return false;
        
        api.Token__c = '';
        api.RefreshToken__c = '';
        Map<String, String> tokens = extractTokens(refreshTokenResponse);
        api.Token__c = tokens.get('access_token');
        api.RefreshToken__c = tokens.get('refresh_token');

        if (api.Token__c != '') {
            upsert api;
            return true;
        }

        return false;
    }
    
    public static void acquireTokens(String redirectUri, String code, String state) {
        
        Wrike_API__c api = Wrike_API__c.getInstance();
        
        if (api.State__c == state) {
            String requestTokenResponse = requestToken(redirectUri, code);
            Map<String, String> tokens = extractTokens(requestTokenResponse);
            api.Token__c = tokens.get('access_token');
            api.RefreshToken__c = tokens.get('refresh_token');
            api.State__c = '';
            
            if (api.Token__c != '') {
                upsert api;
            }     
        }
    }

    private static String requestTokenRefresh() {
        
        String params = '&grant_type=refresh_token' +
                            '&refresh_token=' + Wrike_API__c.getInstance().RefreshToken__c;
        return sendOAuthRequest(params);
    }
    
    private static String requestToken(String redirectUri, String code) {
        
        String params = '&grant_type=authorization_code' +
                            '&redirect_uri=' + redirectUri + '&code=' + code;
        return sendOAuthRequest(params);
    }
    
    private static String sendOAuthRequest(String params) {
        
        HttpRequest req = new HttpRequest();
        
        WrikeAccountSettings__c settings = WrikeAccountSettings__c.getInstance();
        
        req.setEndpoint(settings.WrikeServer__c + WRIKE_OAUTH2_TOKEN);
        req.setMethod('POST');

        req.setBody('client_id=' + settings.wrikeClientId__c+
            '&client_secret=' + settings.wrikeClientSecret__c + params);
    
        HttpResponse res = sendRequest(req);
        return res.getBody();
    }
    
    private static Map<String, String> extractTokens(String oauthResponse) {
        Map<String, Object> tokenMap = (Map<String, Object>) JSON.deserializeUntyped(oauthResponse);
        return new Map<String, String> {'access_token' => (String)tokenMap.get('access_token'), 
                                        'refresh_token' => (String)tokenMap.get('refresh_token')};
    }
    
    public static Boolean checkOAuthClient(String clientId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getAuthorizeURL() + '&client_id=' + clientId);
        req.setMethod('GET');

        HttpResponse res = sendRequest(req);
        processResponse(res, req);
        return true;
    }
}