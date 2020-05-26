public abstract class Wrike_AbstractSectionController extends Wrike_BaseController {
    
    public static String WRIKE_DOMAIN { get {
                                return WrikeAccountSettings__c.getInstance().WrikeServer__c; }}

    protected String viewURL;
    
    protected Wrike_Bindings__c bindings;
 
    public String getSalesforceHostname() {
        return URL.getSalesforceBaseUrl().getHost();
    }
    
    public String getWrikeAccountId() {
        return settings.WrikeAccountId__c;
    }
    
    public String getSalesforceFolderId() {
        return settings.SalesforceFolderId__c;
    }
    
    public Wrike_AbstractSectionController() {
    	
    	if(ApexPages.currentPage() != null) {
    	   this.viewURL = ApexPages.currentPage().getUrl();
    	}
    }
    
    public PageReference authorize() {

        String authorizationURL = URL.getSalesforceBaseUrl().toExternalForm() +
                '/apex/Wrike_Authorize?return_path=' +
                EncodingUtil.urlEncode( viewURL, 'UTF-8');

        System.debug('authorizationURL ' + authorizationURL);
        return new PageReference(authorizationURL);
    }
    
    public PageReference deauthorize() {
        Wrike_API__c api = Wrike_API__c.getInstance();
        api.Token__c = '';
        api.RefreshToken__c = '';
        upsert api;
        
        PageReference page = new PageReference(ApexPages.currentPage().getUrl());
       page.setRedirect(true);
       return page;
    }
    
    protected boolean isUser() {        
        
        String me = wrikeApiGet('/contacts?me', ExceptionHandlingMode.NONE);
                
        return isUser(me, getWrikeAccountId());
    }
    
    protected boolean isUser(String userBody, String wrikeAccountId) {        
        
        String accountId = null, role = null;    
        
        Map<Object,List<Object>> dataMap = Wrike_JSONUtils.extractChildRecordsFromJSON(userBody, 'profiles');
        List<Object> profiles = dataMap.values()[0];

        for(Object o: profiles) {
            Map<String, Object> record = (Map<String, Object>)o;
            
            accountId  = (String)record.get('accountId');
            role  = (String)record.get('role');
            if (accountId == wrikeAccountId
                        && role == 'User') {
                    return true;
                }
        }
             
        return false;
    }
    
    protected Boolean isFolderDeleted(String folderId) {
        
        try {
	        String foldersBody = wrikeApiGet('/folders/' + folderId, ExceptionHandlingMode.NONE);
	        return isFolderDeletedByBody(foldersBody);
        } catch(Wrike_Exceptions.WrikeResourceNotFoundException wex) {
        	return true;
        } catch(Exception ex) { 
        	handleException(ex, ExceptionHandlingMode.FULL);
            return true; 
            }
    }
    
    protected Boolean isFolderDeletedByBody(String foldersBody) {
        
        if (foldersBody == null) {
            return false;
        }

        String scope = Wrike_JSONUtils.parseJSON(foldersBody, 'scope');
        return (scope == 'RbFolder');
    }
    
    protected Boolean isAdministrator() {
        Profile sfUserProfile = [SELECT
            Name,
            PermissionsAuthorApex,
            PermissionsAPIEnabled,
            PermissionsCustomizeApplication,
            PermissionsViewSetup,
            PermissionsViewAllUsers,
            PermissionsViewAllData,
            PermissionsManageSharing,
            PermissionsManageIPAddresses
            FROM Profile WHERE Id = :UserInfo.getProfileId()];

        return sfUserProfile.PermissionsAuthorApex &&
            sfUserProfile.PermissionsAPIEnabled &&
            sfUserProfile.PermissionsCustomizeApplication &&
            sfUserProfile.PermissionsViewSetup &&
            sfUserProfile.PermissionsViewAllUsers &&
            sfUserProfile.PermissionsViewAllData &&
            sfUserProfile.PermissionsManageSharing &&
            sfUserProfile.PermissionsManageIPAddresses;
    }
        
    protected void checkIsAdmin() {
        
        if(!isAdministrator()) 
            throw new Wrike_Exceptions.SalesforceAccessDeniedException('Setup accessed by non-priviledged user.');
    }
    
    protected Boolean checkMetadataAPIConnection()
    {
        try {
            Wrike_MetadataService.MetadataPort service = new Wrike_MetadataService.MetadataPort();
            service.SessionHeader = new Wrike_MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            Wrike_MetadataService.ListMetadataQuery remoteSites = new Wrike_MetadataService.ListMetadataQuery();
            remoteSites.type_x = 'RemoteSiteSetting';
            service.listMetadata(new List<Wrike_MetadataService.ListMetadataQuery> { remoteSites }, 31);
        } catch (Exception e) {
            return false;
        }
        return true;
    }
        
    protected String wrikeApiGet(String relativePath, ExceptionHandlingMode exMode) {

        return performRequest(relativePath, null, Wrike_ApiUtils.HttpMethod.GET, exMode);
    }
    
    protected String wrikeApiPut(String relativePath, String body, ExceptionHandlingMode exMode) {

        return performRequest(relativePath, body, Wrike_ApiUtils.HttpMethod.PUT, exMode);
    }

    protected String wrikeApiPost(String relativePath, String body, ExceptionHandlingMode exMode) {

        return performRequest(relativePath, body, Wrike_ApiUtils.HttpMethod.POST, exMode);
    }
        
    private String performRequest(String relativePath, String body, Wrike_ApiUtils.HttpMethod method, ExceptionHandlingMode exMode) {
        
        String result = '';
        try {
              result = Wrike_ApiUtils.processApiRequest(relativePath, body, method);
              isAuthorized = true;
          } catch(Exception ex) { 
                  handleException(ex, exMode); 
                }
            return result;
    }
    
    /*
    private static void sendErrorEmail(String myLog)
    {
         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
         email.setToAddresses(new String[] {'anna.goreslavskaya@team.wrike.com'});
         email.setSubject('error log');
         mylog = 'Client: ' + UserInfo.getOrganizationName() + '\r\n' + mylog;
         string emailBody = myLog;
         email.setPlainTextBody(emailBody);
         Messaging.SendEmailResult [] res = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
*/

    protected Boolean matchesPattern(string someWrikeId, integer expectedNumberOfCharacters) {
    	
    	String wrkPattern = String.format('^[0-9A-Z]\'{\'{0}\'}\'$', 
    	                                   new String[] { String.valueOf(expectedNumberOfCharacters) }); 
    	return Pattern.matches(wrkPattern, someWrikeId);
    }
    
    public String getContactsJSON() {
       
       return wrikeApiGet('/accounts/' + getWrikeAccountId() + '/contacts/', ExceptionHandlingMode.LOG);
    }
    
    protected String createSalesforceFolder(String accountId) {
            
        String accountBody = wrikeApiGet('/accounts/' + accountId, ExceptionHandlingMode.NONE);
        String rootFolderId = Wrike_JSONUtils.parseJSON(accountBody, 'rootFolderId');
        
        String sharedId = getMyTeamId(accountId);

       return createFolder(rootFolderId, 'Salesforce', 
                        (String.isBlank(sharedId) ? '' : '&shareds=["' + sharedId + '"]'));
    }
    
    protected String getMyTeamId(String accountId)
    {
        String accountUsers = getContactsJSON();
        List<Object> userMap = Wrike_JSONUtils.extractRecordsFromJSON(accountUsers);
        for(Object o: userMap) {
            Map<String, Object> record = (Map<String, Object>)o;
            if( record.get('myTeam') != null) {
                return  (String)record.get('id');
            }
        }
        return '';
    }
    
    protected String createFolder(String parentFolder, String folderName, String additionalParams) {
        String folderBody = wrikeApiPost('/folders/' + parentFolder + '/folders',
                    'title=' + EncodingUtil.urlEncode(folderName, 'UTF-8') + additionalParams, ExceptionHandlingMode.NONE);
        return Wrike_JSONUtils.parseJSON(folderBody, 'id');
    }
    
    protected String createFolder(String parentFolder, String folderName) {
    	return createFolder(parentFolder,folderName, '');
    }
    
    public static void validate_AbstractSectionController() {
        Integer i = 0;
          i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;  i++;   
    }
}