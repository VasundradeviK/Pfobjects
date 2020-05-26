@isTest 
private class Wrike_Test {
    
    static testMethod void validate() {
        insertTestSettings();
        Wrike_AbstractSectionController.validate_AbstractSectionController();
        Wrike_AuthorizeController.validate_AuthorizeController();
        Wrike_FolderController.validate_FolderController();
        
    }
    
    static testMethod void coverTemplateStuff() {
    	
    	User testUser = insertTestUser();
    	
    	System.runAs(testUser) {
    		
    		insertTestSettings();
    	
	    	PageReference pageRef = new PageReference('/apex/Wrike_TemplateEdit');
	    	pageRef.getParameters().put('templateId', 'NEW');
	    	pageRef.getParameters().put('folderName', 'folder name');
	    	pageRef.getParameters().put('folderId', '1234567891234567');
			Test.setCurrentPageReference(pageRef);
			
			Wrike_TemplateManagerController tm = new  Wrike_TemplateManagerController();
			tm.saveTemplate();
			
			pageRef = new PageReference('/apex/Wrike_TemplateEdit');
			pageRef.getParameters().put('showSort', '123');
			pageRef.getParameters().put('templateIds', '123,321');
			Test.setCurrentPageReference(pageRef);
			tm = new  Wrike_TemplateManagerController();
			tm.saveSorting();
			
			pageRef = new PageReference('/apex/Wrike_TemplateManager');
			Test.setCurrentPageReference(pageRef);
			tm = new  Wrike_TemplateManagerController();
			tm.deleteTemplate();
			
			
			String recordId = insertTestBinding();
			//if(String.isBlank(recordId)) throw new Wrike_Exceptions.CorruptedSFSettingsException('empty recordId');
			
			pageRef = new PageReference('/apex/Wrike_TemplateWizard');
			pageRef.getParameters().put('currentRecordId', recordId);
			Test.setCurrentPageReference(pageRef);
			
			Wrike_TemplateWizardController tw = new Wrike_TemplateWizardController();
    	}
    	
    }
    
    private static User insertTestUser()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
          User u = new User(Alias = 'test', Email='testuser@44dev.com', 
          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='testuser@44dev.com');
        
        return u;
    }

    public static void insertTestSettings()
    {        
        WrikeAccountSettings__c newSetting = new WrikeAccountSettings__c(setupOwnerId = System.Userinfo.getOrganizationId());
        insert newSetting;
    }
    
    private static void insertTestTemplate() {
    	
    }
    
    private static String insertTestBinding() {
    	
        Wrike_Bindings__c b = new Wrike_Bindings__c();
        b.Name = 'Account';
        b.Full_Name__c = 'Account';
        b.ParentId__c = '123456';
        b.Type__c = 'FOLDER';
        b.Rule__c = 'AUTO';
        upsert b;
        
        Account a = new Account(Name = 'qwerty ltd');
        upsert a;
        
        return a.Id;
    }
}