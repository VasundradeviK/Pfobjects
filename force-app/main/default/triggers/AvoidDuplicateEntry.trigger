trigger AvoidDuplicateEntry on Attribute_Requirement__c (before insert,before Update) {
    if(Trigger.isBefore && Trigger.isInsert){
        List<ID> MasterCoreAttributeIds = new List<ID>();
        List<String> oldValue = new List<String>();
        for(Attribute_Requirement__c newEntry :Trigger.new){
            MasterCoreAttributeIds.add(newEntry.Core_Attribute__c);
        }
        System.debug('MasterCoreAttributeIds:'+MasterCoreAttributeIds);
        for(Attribute_Requirement__c oldEntry : [Select id,Required__c,System__c,Core_Attribute__c FROM Attribute_Requirement__c WHERE Core_Attribute__c IN:MasterCoreAttributeIds ]){
            oldValue.add(oldEntry.Core_Attribute__c+oldEntry.Required__c+oldEntry.System__c);
        }
        for(Attribute_Requirement__c compareValues:Trigger.new ){
            if(oldValue .contains(compareValues.Core_Attribute__c+compareValues.Required__c+compareValues.System__c)){
                compareValues.AddError('DuplicaterecordsFound');
            }
        }
    }
}