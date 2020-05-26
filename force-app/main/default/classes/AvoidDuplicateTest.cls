@isTest(seeAllData=true)
public class AvoidDuplicateTest {
    public static testMethod void testDuplicate()
         {
             Case cs = new Case();
             cs.Origin = 'Email';
             cs.Subject ='Test case';
             cs.Drive_Customer_Id__c = '1008';
             cs.Reason = 'Request';
             cs.Case_Sub_Reason__c='Dev Request';
             cs.Description = 'test data';
             cs.SuppliedEmail = 'test@crm.com';
             insert cs;
             Case cs4 = new Case();
             cs4.Origin = 'Email';
             cs4.Subject ='FW: Test case';
             cs4.Drive_Customer_Id__c = '1008';
             cs4.Reason = 'Request';
             cs4.Case_Sub_Reason__c='Dev Request';
             cs4.Description = 'test data';
             cs4.SuppliedEmail = 'test@crm.com';
             insert cs4;
             
             Case cs1 = new Case();
             cs1.Origin = 'Email';
             cs1.Subject ='RE: Test case';
             cs1.Drive_Customer_Id__c = '1008';
             cs1.Reason = 'Request';
             cs1.Case_Sub_Reason__c='Dev Request';
             cs1.Description = 'test data';
             cs1.SuppliedEmail = 'test@crm.com';
             insert cs1;
             
             Case cs2 = new Case();
             cs2.Origin = 'Email';
             cs2.Subject ='RE:Test case';
             cs2.Drive_Customer_Id__c = '1008';
             cs2.Reason = 'Request';
             cs2.Case_Sub_Reason__c='Dev Request';
             cs2.Description = 'test data';
             cs2.SuppliedEmail = 'test@crm.com';
             insert cs2;
             
             Case cs3 = new Case();
             cs3.Origin = 'Email';
             cs3.Subject ='FW:Test case';
             cs3.Drive_Customer_Id__c = '1008';
             cs3.Reason = 'Request';
             cs3.Case_Sub_Reason__c='Dev Request';
             cs3.Description = 'test data';
             cs3.SuppliedEmail = 'test@crm.com';
             insert cs3;
             
          }

}