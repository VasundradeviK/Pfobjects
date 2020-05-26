@isTest(SeeAllData='true')
public class DailyReportCustomerScheduleTest {
     @isTest
    static void testRFIReportSchedule()
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
     User u = new User(
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
      
      insert u;        
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
        system.debug('RFI:-' +newrfi);
        
        RFI_Detail__c rfDetail = new RFI_Detail__c();
        rfDetail.RFI_Number__c = newrfi.id;
        rfDetail.Onsite_Remediation_Required__c = 'Yes';
        rfDetail.Onsite_Remediation_Description__c ='Test';
        rfDetail.Due_Date__c = Date.today().addDays(-8);
		rfDetail.RFI_Detail_Owner__c = u.Id;
        rfDetail.RFI_Item_Status__c = 'Submitted – Pending Customer Review';
         insert rfDetail;
          system.debug('rfDetail##'+rfDetail);  
         /*RFI_Detail__c rfDetail1 = new RFI_Detail__c();
        rfDetail1.RFI_Number__c = newrfi.id;
        rfDetail1.Onsite_Remediation_Required__c = 'Yes';
        rfDetail1.Onsite_Remediation_Description__c ='Test';
        rfDetail1.RFI_Item_Status__c = 'Submitted – Pending Customer Review';
          rfDetail1.Due_Date__c = Date.today().addDays(-1);
         insert rfDetail1;
        rfDetail1.RFI_Item_Status__c = 'In Progress';
        Update rfDetail1;
          RFI_Detail__c rfDetail2 = new RFI_Detail__c();
        rfDetail2.RFI_Number__c = newrfi.id;
        rfDetail2.Onsite_Remediation_Required__c = 'Yes';
        rfDetail2.Onsite_Remediation_Description__c ='Test';
        rfDetail2.RFI_Item_Status__c = 'Needs Detail';
        rfDetail.RFI_Detail_Owner__c = u.Id;
          rfDetail2.Due_Date__c = Date.today().addDays(-8);
         insert rfDetail2;*/
        
        
      Test.StartTest();
        
        String CRON_EXP = '0 0 23 * * ?'; 
       DailyReportCustomerSchedule reportSchedule = new DailyReportCustomerSchedule();
      // reportSchedule.sendmail();
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new DailyReportCustomerSchedule());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }

}