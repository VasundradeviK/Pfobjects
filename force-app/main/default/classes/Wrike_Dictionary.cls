public with sharing class Wrike_Dictionary {
    
    public static final List<String> SETTINGS_FIELDS = new List<String> {'WrikeClientId__c', 'WrikeClientSecret__c',
                      'SetupOwnerId','WrikeAccountId__c','SalesforceFolderId__c', 'WebHookKey__c', 'WrikeServer__c'};
                    
    public static final Set<String> API_TOKEN_FIELDS = new Set<String> {'SetupOwnerId', 'RefreshToken__c'};
                    
    public static final Set<String> BINDING_FIELDS = new Set<String> {'Name', 'NameTemplate__c', 
                                                        'ParentId__c', 'Rule__c, Type__c'};
                                                        
    public static final String SOURCE_PAGE_NAME = 'Wrike_FolderViewEntry';
    public static final String FOLDER_CONTROLLER_NAME = 'Wrike_FolderViewEntryController';
                    
    public static String getTargetPageName(String objName)
    {
        String targetPageName = ('WrikeView_' + objName).replaceAll('__','_');
        if(targetPageName.length() > 40) {
            targetPageName = targetPageName.substring(0, 39);
        }           
        return targetPageName; 
    }
    
    public static String getBindingName(String objectName) {

        // max length is 38
        String bindingName = objectName.replaceAll('__','_');
        if(bindingName.length() > 38) {
            bindingName = bindingName.substring(0, 38);
        }           
        return bindingName;
    }

}