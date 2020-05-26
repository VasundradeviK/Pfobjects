@isTest
public class UpdaterfidetailTest {
      static testMethod void  updaterfiDetailTest(){
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
     
                newAcc.Primary_Contact__c = c.Id;
            Update newAcc;
        
        Plant_Asset__c palntAsset = new Plant_Asset__c();
        palntAsset.Name = 'Plant Asset Test';
        palntAsset.RecordTypeId = [SELECT id from RecordType where Name ='Parent Asset'].Id;
        palntAsset.Plant_Name__c = 'test';
        palntAsset.Project_Lifecycle_Status__c = 'Pending';
        palntAsset.Implementation_Status__c = 'Pending Customer Submission';
        insert palntAsset;
        
        Plant_Asset__c palntAss = new Plant_Asset__c();
        palntAss.Name = 'Customer Asset Test';
        palntAss.RecordTypeId = [SELECT id from RecordType where Name ='Customer Asset'].Id;
        palntAss.Plant_Name__c = 'test123';
        palntAss.Customer_Plant_Asset_ID__c = '123';
        palntAss.Parent__c = palntAsset.Id;
        palntAss.Account__c = newAcc.Id;
        //palntAss.Project_Lifecycle_Status__c = 'Pending';
        //palntAss.Implementation_Status__c = 'Pending Customer Submission';
        palntAss.Assigned_Customer_Contact__c = c.Id;
        insert palntAss;
        
        palntAss.Project_Lifecycle_Status__c = 'Data Validation';
        palntAss.Implementation_Status__c = 'In Progress';
        Update palntAss;
        
        RFI__c newrfi = new RFI__c();
        newrfi.Plant_Asset__c = palntAss.Id;
        insert newrfi;
        system.debug('RFI:-' +newrfi);
        
        RFI_Categories__c newRFICat = new RFI_Categories__c();
        newRFICat.Category_Classification__c = 'General';
        newRFICat.Name = 'Test missing';
        newRFICat.RecordTypeId = [SELECT id from RecordType where Name ='Missing/Incomplete Information'].Id;
        insert newRFICat;
        
        RFI_Categories__c newRFICat1 = new RFI_Categories__c();
        newRFICat1.Category_Classification__c = 'General';
        newRFICat1.Name = 'Test Incorrect';
        newRFICat1.RecordTypeId = [SELECT id from RecordType where Name ='Incorrect Information'].Id;
        insert newRFICat1;
        
        RFI_Detail__c newRFIdetail = new RFI_Detail__c();
        newRFIdetail.Name = 'test rfi detail 1';
        newRFIdetail.RFI_Number__c = newrfi.Id;
        newRFIdetail.Onsite_Remediation_Required__c = 'No';
        newRFIdetail.Missing_Incomplete_Category__c = newRFICat.Id;
        //newRFIdetail.RFI_Item_Status__c = 'Submitted – Pending Customer Review';
        //newRFIdetail.RFI_Detail_Owner__c = u.Id;
        insert newRFIdetail;
        
        newRFIdetail.RFI_Item_Status__c = 'In Progress';
        update newRFIdetail;
        
        //newRFIdetail.Implementation_Blocked__c = true;
        newRFIdetail.RFI_Item_Status__c = 'Canceled';
        newRFIdetail.Cancel_Cannot_Complete_Description__c = 'test';
        update newRFIdetail;
        
    }
}