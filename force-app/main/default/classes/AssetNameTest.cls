@isTest(SeeAllData='true')
public class AssetNameTest {
 /*   
 @isTest
    static void testAssetname()
    {
        Plant_Asset__c p = new Plant_Asset__c();
        p.Customer_Plant_Asset_ID__c='Test';
        p.Plant_Name__c = 'Test1';
        insert p;
    }
*/
    
    @isTest
    static void testRFI()
    {
         Account newAcc = new Account();
        newAcc.Name = 'Test ACC';
        insert newAcc;
         Contact c = new Contact();
        c.LastName = 'Test Name';
        c.AccountId = newAcc.Id;
        c.Email='Kranthi.d@congruentindai.com';
        insert c;
      
        system.debug('contact--->'+ c);
        newAcc.Primary_Contact__c = c.Id;
        update newAcc;
     
     /*User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'PF Community'].Id,
     LastName = 'last',
     Email = 'puser000@cittest.com',
     Username = 'puser000@cittest.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US',
     ContactId = c.Id
    );
      
      insert u;      */  
        Plant_Asset__c palntAsset = new Plant_Asset__c();
        palntAsset.Name = 'Plant Asset st';
        palntAsset.RecordTypeId = [SELECT id from RecordType where Name ='Parent Asset'].Id;
        palntAsset.Project_Lifecycle_Status__c = 'Pending';
        palntAsset.Plant_Name__c = 'test';
        palntAsset.Implementation_Status__c = 'Pending Customer Submission';
        insert palntAsset;
        
        Plant_Asset__c palntAss = new Plant_Asset__c();
        palntAss.Name = 'Customer Asset Test';
        palntAss.RecordTypeId = [SELECT id from RecordType where Name ='Customer Asset'].Id;
        palntAss.Parent__c = palntAsset.Id;
        palntAss.Plant_Name__c = 'test123';
        palntAss.Customer_Plant_Asset_ID__c = '123';
        palntAss.Account__c = newAcc.Id;
        palntAss.Assigned_Customer_Contact__c = c.Id;
        insert palntAss;
        
        palntAss.Project_Lifecycle_Status__c = 'Data Validation';
        palntAss.Implementation_Status__c = 'In Progress';
        Update palntAss;
        
        RFI__c newrfi = new RFI__c();
        newrfi.Plant_Asset__c = palntAss.Id;
        insert newrfi;
        
        
    } 
    @isTest
    static void testRFI1()
    {
         Account newAcc = new Account();
        newAcc.Name = 'Test ACC';
        insert newAcc;
         Contact c = new Contact();
        c.LastName = 'Test Name';
        c.AccountId = newAcc.Id;
        c.Email='Kranthi.d@congruentindai.com';
        insert c;
      
        system.debug('contact--->'+ c);
        
        newAcc.Primary_Contact__c = c.Id;
        update newAcc;
    /* User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'PF Community'].Id,
     LastName = 'last',
     Email = 'puser000@cittest.com',
     Username = 'puser000@cittest.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US',
     ContactId = c.Id
    );
      
      insert u;  */  
        Plant_Asset__c palntAsset = new Plant_Asset__c();
        palntAsset.Name = 'Plant Asset Test';
        palntAsset.RecordTypeId = [SELECT id from RecordType where Name ='Parent Asset'].Id;
        palntAsset.Project_Lifecycle_Status__c = 'Pending';
        palntAsset.Plant_Name__c = 'test';
        palntAsset.Implementation_Status__c = 'Pending Customer Submission';
        insert palntAsset;
        
        Plant_Asset__c palntAss = new Plant_Asset__c();
        palntAss.Name = 'Customer Asset Test';
        palntAss.RecordTypeId = [SELECT id from RecordType where Name ='Customer Asset'].Id;
        palntAss.Parent__c = palntAsset.Id;
        palntAss.Plant_Name__c = 'test123';
        palntAss.Customer_Plant_Asset_ID__c = '123';
        palntAss.Account__c = newAcc.Id;
        palntAss.Assigned_Customer_Contact__c = c.Id;
        insert palntAss;
        
        palntAss.Project_Lifecycle_Status__c = 'Data Validation';
        palntAss.Implementation_Status__c = 'In Progress';
        Update palntAss;
        
        RFI__c newrfi = new RFI__c();
        newrfi.Plant_Asset__c = palntAss.Id;
        insert newrfi;
        
         RFI_Categories__c rfiCat = new RFI_Categories__c();
        rfiCat.Name = 'COD';
        rfiCat.RecordTypeId = [SELECT id from RecordType where Name ='Incorrect Information'].Id;
        rfiCat.Description__c='Description__c';
        rfiCat.Category_Classification__c='General';
         insert rfiCat;
        RFI_Categories__c rfiCat1 = new RFI_Categories__c();
        rfiCat1.Name = 'AC/DC Capacity';
        rfiCat.RecordTypeId = [SELECT id from RecordType where Name ='Missing/Incomplete Information'].Id;
        rfiCat1.Description__c='Description1';
        rfiCat1.Category_Classification__c='Solar';
        insert rfiCat1;
        
        RFI_Detail__c rfDetail = new RFI_Detail__c();
        rfDetail.Name = 'test rfi detail 1';
        rfDetail.RFI_Number__c = newrfi.id;
        //rfDetail.RFI_Detail_Description__c = 'test';
        rfDetail.Onsite_Remediation_Required__c = 'Yes';
        rfDetail.Onsite_Remediation_Description__c ='Test';
        rfDetail.Missing_Incomplete_Category__c=rfiCat1.Id;
        //rfDetail.Implementation_Blocked__c = false;
        //rfDetail.Due_Date__c = Date.today().addDays(-8);
        insert rfDetail;
        
        RFI_Detail__c rfDetail1 = new RFI_Detail__c();
        rfDetail1.Name = 'test1234';
        rfDetail1.RFI_Number__c = newrfi.id;
        rfDetail1.Onsite_Remediation_Required__c = 'Yes';
        rfDetail1.Onsite_Remediation_Description__c ='Test';
        rfDetail1.Customer_Comments__c ='Test area';
        rfDetail.Incorrect_Category__c = rfiCat.Id;
        // rfDetail1.Due_Date__c = Date.today().addDays(-8);
        insert rfDetail1;
        
        palntAss.Plant_Name__c='hello test';
        palntAss.Customer_Plant_Asset_ID__c='test hi';
        update palntAss;
        
    }
        
    
}