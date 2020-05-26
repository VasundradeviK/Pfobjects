public with sharing class wrapperClassNew {
    @AuraEnabled public RFI_Categories__c lstRfiCat{get;set;}
    @AuraEnabled public RFI_Detail__c lstRfiDetails{get;set;}
    @AuraEnabled public String description {get;set;}
    @AuraEnabled public String selOption {get;set;}
    @AuraEnabled public List<String> onsitePicklist {get;set;}
    @AuraEnabled public String onsiteDescription {get;set;}
    @AuraEnabled public Boolean implementationBlock {get;set;}

    public wrapperClassNew(){
        lstRfiCat = new RFI_Categories__c();
        onsitePicklist = new List<String>();
        onsiteDescription = '';
    }
}