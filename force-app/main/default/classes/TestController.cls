@isTest
public class TestController {
     @isTest
    static void testController()
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
   /*  User u = new User(
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
       Plant_Asset__c pa = new Plant_Asset__c();
        pa.Name = 'Plant Asset Test1';
        pa.RecordTypeId = [SELECT id from RecordType where Name ='Parent Asset'].Id;
        pa.Plant_Name__c = 'test1';
        pa.Project_Lifecycle_Status__c = 'Pending';
        pa.Implementation_Status__c = 'Pending Customer Submission';
        insert pa;
        
        
        Plant_Asset__c cps = new Plant_Asset__c();
        cps.Name = 'Customer Asset Test1';
        cps.RecordTypeId = [SELECT id from RecordType where Name ='Customer Asset'].Id;
        cps.Plant_Name__c = 'test123';
        cps.Customer_Plant_Asset_ID__c = '123';
        cps.Parent__c = pa.Id;
        cps.Account__c = newAcc.Id;
        //palntAss.Project_Lifecycle_Status__c = 'Pending';
        //palntAss.Implementation_Status__c = 'Pending Customer Submission';
        cps.Assigned_Customer_Contact__c = c.Id;
        insert cps;
         cps.Project_Lifecycle_Status__c = 'Data Validation';
        cps.Implementation_Status__c = 'In Progress';
        Update cps;
        RFI__c newrfi = new RFI__c();
        newrfi.Plant_Asset__c = cps.Id;
        insert newrfi;
        system.debug('RFI:-' +newrfi);
        
        RFI_Detail__c rfDetail = new RFI_Detail__c();
        rfDetail.RFI_Number__c = newrfi.id;
        rfDetail.Onsite_Remediation_Required__c = 'Yes';
        rfDetail.Onsite_Remediation_Description__c ='Test';
        rfDetail.Due_Date__c = Date.today().addDays(-8);
        //rfDetail.RFI_Item_Status__c = 'Submitted – Pending Customer Review';
         insert rfDetail;
        
          system.debug('rfDetail##'+rfDetail); 
        
         RFI_Detail__c rfDetail1 = new RFI_Detail__c();
        rfDetail1.RFI_Number__c = newrfi.id;
        rfDetail1.Onsite_Remediation_Required__c = 'Yes';
        rfDetail1.Onsite_Remediation_Description__c ='Test';
        rfDetail1.Customer_Comments__c ='Test area';
       // rfDetail1.RFI_Item_Status__c = 'Submitted – Pending Customer Review';
        rfDetail1.Due_Date__c = Date.today().addDays(-8);
         insert rfDetail1;
        
          RFI_Detail__c rfDetail2 = new RFI_Detail__c();
         rfDetail2.RFI_Number__c = newrfi.id;
         rfDetail2.Onsite_Remediation_Required__c = 'Yes';
         rfDetail2.Onsite_Remediation_Description__c ='Test';
       //  rfDetail2.RFI_Item_Status__c = 'Submitted – Pending Customer Review';
         rfDetail2.Due_Date__c = Date.today();
         insert rfDetail2;


        
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
        
       // RFI_Categories__c s = new RFI_Categories__c();
        AddRfiDetail.getMissingCat(new RFI_Categories__c(), 'Category_Classification__c', 'Incorrect Information');
        
        wrapperClassNew wrapperCalss = new wrapperClassNew();
        wrapperCalss.lstRfiCat= rfiCat;
        wrapperCalss.lstRfiDetails= rfDetail1;
        wrapperCalss.description = 'test';
        wrapperCalss.selOption= '';
        wrapperCalss.onsitePicklist = new List<String>{'inProgress', 'needDeatils'};
       wrapperCalss.onsiteDescription = 'Test';
       wrapperCalss.implementationBlock= true;
        
        String s = Json.serialize(wrapperCalss);
         wrapperClassNew wrapperCalss1 = new wrapperClassNew();
        wrapperCalss1.lstRfiCat= rfiCat1;
        wrapperCalss1.lstRfiDetails= rfDetail;
        wrapperCalss1.description = 'test';
        wrapperCalss1.selOption= '';
        wrapperCalss1.onsitePicklist = new List<String>{'inProgress', 'needDeatils'};
       wrapperCalss1.onsiteDescription = 'Test';
       wrapperCalss1.implementationBlock= true;
        
        String s1 = Json.serialize(wrapperCalss1);

    Map<String,String> selectedCategory = new  Map<String,String>();
        selectedCategory.put(rfiCat.Id, s);
         selectedCategory.put(rfiCat1.Id, s1);
        //selectedCategory.put(rfiCat.Id, rfiCat.Id);
        
        
        AddRfiDetail.processCatValues(selectedCategory,newrfi.Id);
       List<String> lstPs = new List<String>();
        lstPs.add(cps.Id);
        AddRfiDetail.processRfiWithRfiDetail(selectedCategory, newrfi.Id,lstPs);
        AddRfiDetail.RfiDetails(selectedCategory);
        Map<String,String> selectedCat = new  Map<String,String>();
        selectedCat.put(rfDetail1.Id,Json.serialize(rfDetail1));
        AddRfiDetail.saveRfiDetailsLst(selectedCat);
        InlineEditHandler.getRFIdetail(newrfi.id);
        List<RFI_Detail__c> lstRdetails = new List<RFI_Detail__c>();
        rfDetail.Customer_Comments__c = 'test123';
        rfDetail1.RFI_Detail_Description__c='test1';
        rfDetail1.Onsite_Remediation_Required__c='Yes';
        rfDetail1.Onsite_Remediation_Description__c='Tesr';
        
        
        
        lstRdetails.add(rfDetail);
         lstRdetails.add(rfDetail1);
        
        InlineEditHandler.saveRFIdetails(lstRdetails);
        List<RFI_Detail__c> lstRdetails2 = new List<RFI_Detail__c>();
        rfDetail1.RFI_Item_Status__c ='Canceled';
        lstRdetails2.add(rfDetail);
         //lstRdetails.add(rfDetail1);
        InlineEditHandler.saveRFIdetails(lstRdetails2);
        InlineEditHandler.getselectOptions(new RFI_Detail__c(), 'Onsite_Remediation_Required__c');
        InlineEditHandler.getPermission();
        Map<String,String> mapDescription = new Map<String,String>();
        mapDescription.put('test','Test');
        InlineEditHandler.mapValues(JSON.serialize(mapDescription));
        RFI_Detail__c rfDetail3 = new RFI_Detail__c();
         rfDetail3.RFI_Number__c = newrfi.id;
         rfDetail3.Onsite_Remediation_Required__c = 'Yes';
         rfDetail3.Onsite_Remediation_Description__c ='Test';
         //rfDetail3.RFI_Item_Status__c = 'Submitted – Pending Customer Review';
         rfDetail3.Due_Date__c = Date.today();
        rfDetail3.Cancel_Cannot_Complete_Description__c='Test';
        try{
         insert rfDetail3;
        List<RFI_Detail__c> lstRdetails4 = new List<RFI_Detail__c>();
        lstRdetails4.add(rfDetail3);
        InlineEditHandler.saveRFIdetails(lstRdetails4);
        } catch(Exception e){
            
        }
        
        
    }

}