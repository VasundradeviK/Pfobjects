/*
    @author Andrey Kuleshov
*/
public class WrikeWebHook {

    /*
        Registers a new OAuth2 Wrike client.
        Doesn't create a new record if a client with same Organization Id already exists.
        Returns map with two keys: 'clientId' and 'clientSecret' or empty map if something goes wrong.
    */
    public static Map<String, String> registerOauthClient(final String redirectURI) {
        if(String.isNotBlank(redirectURI)) {
            final Map<String, Object> response = sendWrikeRequest('oauth_client_registration', new Map<String, String> {
                'companyName' =>  UserInfo.getOrganizationName(), 
                'salesForceId' => UserInfo.getOrganizationId(), 
                'contactName' =>  UserInfo.getName(),
                'contactEmail' => UserInfo.getUserEmail(),
                'redirectURI' => redirectURI}); // check that we can't use URL.getSalesforceBaseUrl().getHost() here
            if(response != null && !response.isEmpty()) {
                final String clientId = (String)response.get('clientId');
                final String clientSecret = (String)response.get('clientSecret');
                if(String.isNotBlank(clientId) && String.isNotBlank(clientSecret)) {
                    return new Map<String, String> {'clientId' => clientId, 'clientSecret' => clientSecret};
                }
            }
        }
        return new Map<String, String>();
    }

    private static Map<String, Object> sendWrikeRequest(final String action, final Map<String, String> params) {
        final HttpRequest req = new HttpRequest();
        req.setEndpoint(getWrikeURL() + '/gw/salesforce/' + action);
        req.setMethod('POST');
        req.setBody('data=' + getEncryptedData(params));  
        try {
            final String response = new Http().send(req).getBody();
            System.debug('--- webhook response ' + response);
            final Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            return (Map<String, Object>)responseMap.get('data');
        } catch (Exception e) {
            system.debug(Logginglevel.ERROR, e.getMessage());
            return new Map<String, String>();
        }
    }
    
    private static String getEncryptedData(final Map<String, String> params) {
        final String encodedData = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(params != null ? params : new Map<String, String>())));
        final Blob key = EncodingUtil.base64Decode(WrikeAccountSettings__c.getInstance().WebHookKey__c);
        final Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(encodedData));
        return EncodingUtil.urlEncode(EncodingUtil.base64Encode(cipherText), 'UTF-8');
    }
    
    private static String getWrikeURL() {
        return Wrike_AbstractSectionController.WRIKE_DOMAIN;
    }
}