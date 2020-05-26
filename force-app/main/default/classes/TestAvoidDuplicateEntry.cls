@isTest
public class TestAvoidDuplicateEntry {
    @isTest static void AvoidDuplicateEntryonCoreAttribute() {
        Base_Asset_Template__c BassitTemplate = new Base_Asset_Template__c(Description__c ='TestDescritpion');
        insert BassitTemplate;
        Core_Attribute__c CAttribute = new Core_Attribute__c(Name ='Test Attribute',Base_Asset_Name__c =BassitTemplate.id );
        insert CAttribute;
        Attribute_Requirement__c AttReq = new Attribute_Requirement__c(Core_Attribute__c =CAttribute.id,Required__c ='Yes',System__c= 'Drive');
        insert AttReq;
        Attribute_Requirement__c SecondAttReq = new Attribute_Requirement__c(Core_Attribute__c =CAttribute.id,Required__c ='Yes',System__c= 'Drive');
        Test.startTest();
        insert SecondAttReq;
        Test.stopTest();
        
    }
}