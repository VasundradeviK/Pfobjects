trigger RFINameChangeTrigger on RFI__c (before insert,before delete) {
    if(trigger.isBefore && trigger.isInsert){
    for(RFI__c rfiObj : Trigger.New) {
        System.debug('rfiObj plant asset ' +rfiObj.Plant_Asset__c );
        Plant_Asset__c  plantAseet = [select id,name from Plant_Asset__c where Id= :rfiObj.Plant_Asset__c];
        Integer count  = [select count() from RFI__c where Plant_Asset__c =:rfiObj.Plant_Asset__c ];
        Integer altCount = count+1;
        rfiObj.Name = plantAseet.Name+' - '+altCount;
       }   
    }
    if(trigger.isBefore && trigger.isDelete){
        for(RFI__c rfiObj : Trigger.old) {
       // System.debug('rfiObj plant asset ' +rfiObj.Plant_Asset__c );
       // RFI__c  rfi = [select id,name,RFI_Status__c from RFI__c where id = :rfiObj.Id ] ;
            if(rfiObj.RFI_Status__c=='Closed'){
                 rfiObj.addError('RFI is already closed!');
               
            }
            
        	
       }
    }
}