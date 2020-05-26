public with sharing class PicklistController {

@AuraEnabled(cacheable = true)
Public static List<Plant_Asset__c> getPlantdetails() {
List<Plant_Asset__c> pAsset = new List<Plant_Asset__c>();
pAsset = [SELECT Id, Name FROM Plant_Asset__c];
return pAsset;

}
}