trigger Updaterfidetail on RFI_Detail__c (before insert, before update, after insert, after update) {
    for(RFI_Detail__c rfi : Trigger.new){
        if(trigger.isBefore && trigger.isInsert){
            rfi.RFI_Item_Status__c = 'Submitted – Pending Customer Review';
            if(rfi.Missing_Incomplete_Category__c != null){
                //System.debug('tt' +rfi.Missing_Incomplete_Category__r.Name);
               rfi.Name =  rfi.Missing_Incomplete_Category__r.Name;
            } else{
                 //System.debug('tt' +rfi.Incorrect_Category__c);
              rfi.name=  rfi.Incorrect_Category__r.Name;
            }
        }
    }
    
    if(trigger.isBefore && trigger.isInsert || trigger.isBefore && trigger.isUpdate){
        updateRFIstatus.getrfidetails(Trigger.new);
    }
    
}