@isTest
private class AccountContactControllerTest{
   
    static testMethod void myUnitTest1() {
        
        Account parentAcct = new Account ();
        parentAcct.Name = 'Parent Account 1';
        parentAcct.Account_Email__c = 'parentuser@gmail.com';
        parentAcct.Customer_ID__c = '1005';
        insert parentAcct;
        
        Account a1 = new Account();
        a1.Name = 'Project Account Test';
        a1.Account_Email__c = 'anyuser@gmail.com';
        a1.Site = 'www.google.com';
        a1.Project_Id__c = '1021.0001';
        a1.ParentId = parentAcct.Id;
        insert a1;
        
        Contact c1 = new Contact();
        c1.FirstName = 'Test first name';
        c1.LastName = 'Test last name';
        c1.Email = 'contactemail@gmail.com';
        c1.Phone = '5546747737';
        c1.AccountId = a1.Id;
        insert c1;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Plant_Asset__c; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = AccountRecordTypeInfo.get('Location').getRecordTypeId();
        
        Plant_Asset__c assetTag = new Plant_Asset__c();
        assetTag.Name = '1021.0001 - Plant';
        assetTag.Plant_Business_Segment__c = 'EV';
        assetTag.Operator__c = 'CalCom';
        assetTag.Service_Region__c = 'DG - CO';
        assetTag.RecordTypeId = rtId;
        assetTag.Plant_Name__c ='test';
        assetTag.Customer_Plant_Asset_ID__c='678.908';
        assetTag.Full_plant_name__c='test 123345';
        insert assetTag;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(parentAcct);
        AccountContactController c = new AccountContactController(sc);
        PageReference pageRef = Page.AccountContactDetailPage;
        pageRef.getParameters().put('id', String.valueOf(a1.Id));
        Test.setCurrentPage(pageRef);
        c.account = new Account();
        c.account.Name = 'Project Account Test';
        c.account.ParentId = a1.id;
        c.account.Account_Email__c = 'anyuser@gmail.com';
        c.account.Site = 'www.google.com';
        c.account.Customer_ID__c = '1019';
        c.account.Project_Id__c = '1012.0122';
        c.accountNext();
        
        c.contact.FirstName = 'Test first name';
        c.contact.LastName = 'Test last name';
        c.contact.Email = 'contactemail@gmail.com';
        c.contact.Phone = '5546747737';
        c.contactNext();
        
        c.contactPrevious();
        c.assetTagPrevious();
        c.cancel();
        c.populateCustomerId();
        c.save();
    }
    
    static testMethod void myUnitTest2() {
        
        Account parentAcct = new Account ();
        parentAcct.Name = 'Parent Account 1';
        parentAcct.Account_Email__c = 'parentuser@gmail.com';
        parentAcct.Customer_ID__c = '1005';
        
        insert parentAcct;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Plant_Asset__c; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = AccountRecordTypeInfo.get('Location').getRecordTypeId();
        
        Plant_Asset__c assetTag = new Plant_Asset__c();
        assetTag.Name = '1021.0001 - Plant';
        assetTag.Plant_Business_Segment__c = 'EV';
        assetTag.Operator__c = 'CalCom';
        assetTag.Service_Region__c = 'DG - CO';
        assetTag.RecordTypeId = rtId;
        assetTag.Plant_Name__c ='test';
        assetTag.Customer_Plant_Asset_ID__c='678.908';
        assetTag.Full_plant_name__c='test 123345';
        insert assetTag;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(parentAcct);
        AccountContactController c = new AccountContactController(sc);
        PageReference pageRef = Page.AccountContactDetailPage;
        pageRef.getParameters().put('id', String.valueOf(parentAcct.Id));
        Test.setCurrentPage(pageRef);
        
        c.account = new Account();
        c.account.Name = 'Project Account Test';
        c.account.ParentId = parentAcct.id;
        c.account.Account_Email__c = 'anyuser@gmail.com';
        c.account.Site = 'www.google.com';
        c.account.Customer_ID__c = '1012';
        c.account.Project_Id__c = '1017.0132';
        c.accountNext();
        
        c.contactFlag = true;
        c.isAccountExists = true;
        c.contact.FirstName = 'Test first name';
        c.contact.LastName = 'Test last name';
        c.contact.Email = 'contactemail@gmail.com';
        c.contact.Phone = '5546747737';
        c.contactNext();
        
        c.contactPrevious();
        c.assetTagPrevious();
        c.cancel();
        c.populateCustomerId();
        c.save();
    }
    
    static testMethod void myUnitTest3() {
        
        Account parentAcct = new Account ();
        parentAcct.Name = 'Parent Account 1';
        parentAcct.Account_Email__c = 'parentuser@gmail.com';
        parentAcct.Customer_ID__c = '1005';
        insert parentAcct;
        
        Account a1 = new Account();
        a1.Name = 'Project Account Test';
        a1.Account_Email__c = 'anyuser@gmail.com';
        a1.Site = 'www.google.com';
        a1.Project_Id__c = '1021.0001';
        a1.ParentId = parentAcct.Id;
        insert a1;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Plant_Asset__c; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = AccountRecordTypeInfo.get('Location').getRecordTypeId();
        
        Plant_Asset__c assetTag = new Plant_Asset__c();
        assetTag.Name = '1021.0001 - Plant';
        assetTag.Plant_Business_Segment__c = 'EV';
        assetTag.Operator__c = 'CalCom';
        assetTag.Service_Region__c = 'DG - CO';
        assetTag.RecordTypeId = rtId;
        assetTag.Plant_Name__c ='test';
        assetTag.Customer_Plant_Asset_ID__c='678.908';
        assetTag.Full_plant_name__c='test 123345';
        insert assetTag;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a1);
        AccountContactController c = new AccountContactController(sc);
        PageReference pageRef = Page.AccountContactDetailPage;
        pageRef.getParameters().put('id', String.valueOf(a1.Id));
        Test.setCurrentPage(pageRef);
        
        c.account = new Account();
        c.account.Name = 'Project Account Test11';
        c.account.ParentId = a1.id;
        c.account.Account_Email__c = 'anyuseasdr@gmail.com';
        c.account.Site = 'www.google.com';
        c.account.Customer_ID__c = '1012';
        c.account.Project_Id__c = '1017.0132';
        c.accountNext();
        
        c.contact.FirstName = 'Test first name';
        c.contact.LastName = 'Test last name';
        c.contact.Email = 'contactemail@gmail.com';
        c.contact.Phone = '5546747737';
        c.contactNext();
        
        c.contactPrevious();
        c.assetTagPrevious();
        c.cancel();
        c.populateCustomerId();
        c.save();
    }
    
    static testMethod void myUnitTest4() {
        
        Account parentAcct = new Account ();
        parentAcct.Name = 'Parent Account 1';
        parentAcct.Account_Email__c = 'parentuser@gmail.com';
        parentAcct.Customer_ID__c = '1005';
        insert parentAcct;
        
        Account a1 = new Account();
        a1.Name = 'Project Account Test';
        a1.Account_Email__c = 'anyuser@gmail.com';
        a1.Site = 'www.google.com';
        a1.Project_Id__c = '1021.0001';
        a1.ParentId = parentAcct.Id;
        insert a1;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Plant_Asset__c; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = AccountRecordTypeInfo.get('Location').getRecordTypeId();
        
        Plant_Asset__c assetTag = new Plant_Asset__c();
        assetTag.Name = '1021.0001 - Plant';
        assetTag.Plant_Business_Segment__c = 'EV';
        assetTag.Operator__c = 'CalCom';
        assetTag.Service_Region__c = 'DG - CO';
        assetTag.RecordTypeId = rtId;
        assetTag.Plant_Name__c ='test';
        assetTag.Customer_Plant_Asset_ID__c='678.908';
        assetTag.Full_plant_name__c='test 123345';
        insert assetTag;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(parentAcct);
        AccountContactController c = new AccountContactController(sc);
        PageReference pageRef = Page.AccountContactDetailPage;
        pageRef.getParameters().put('id', String.valueOf(parentAcct.Id));
        Test.setCurrentPage(pageRef);
        
        c.account = new Account();
        c.account.Name = 'Project Account Test11';
        c.account.ParentId = parentAcct.id;
        c.account.Account_Email__c = 'anyuseasdr@gmail.com';
        c.account.Site = 'www.google.com';
        c.account.Customer_ID__c = '1012';
        c.account.Project_Id__c = '1017.0132';
        c.accountNext();
        
        c.contact.FirstName = 'Test first name';
        c.contact.LastName = 'Test last name';
        c.contact.Email = 'contactemail@gmail.com';
        c.contact.Phone = '5546747737';
        c.contactNext();
        
        c.contactPrevious();
        c.assetTagPrevious();
        c.cancel();
        c.populateCustomerId();
        c.save();
    } 
}