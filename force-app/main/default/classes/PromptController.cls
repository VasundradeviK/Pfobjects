public with sharing class PromptController {
   
    @AuraEnabled(cacheable=true)  
    public static List<Plant_Asset__c> getPlantInfo(String Searchkey) {
        List<Plant_Asset__c> plantInfo = new List<Plant_Asset__c>();
        plantInfo = [SELECT Plant_Name__c,Plant_Id__c,Latitude__c,Longitude__c,Commercial_Operating_Date__c,Asset_SubClass__c FROM Plant_Asset__c 
                        WHERE Plant_Name__c Like '%+Searchkey+%' ];//  AND OwnerId= :UserInfo.getUserID()
        
return plantInfo;
    }
}