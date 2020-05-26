global with sharing class WrikeUpdate_MainController {

    @RemoteAction
    global static String getStatus() {
        
        if (!isAdministrator())
            return '{ "exists": false }';
            
        
        String query = 'Select Id From WrikeAccountSettings__c';
        System.debug(query);
            
        SObject[] records = WrikeUpdate_Utils.queryRecords(query);

        System.debug('---records ' + records);
        
        if(records == null) {
            return '{ "exists": false }';
        }
        
        return '{ "exists": true, "active": '+
                (records.size() == 0? 'false': 'true')
            + ' }';
            
        }

    
    public WrikeUpdate_MainController() {
    }
    
    private static Boolean isAdministrator() {
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
    
    
}