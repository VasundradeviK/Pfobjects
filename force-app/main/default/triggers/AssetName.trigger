trigger AssetName on Plant_Asset__c (before insert,before update) {
    
    for(Plant_Asset__c pa : Trigger.New) {
        if(pa.Customer_Plant_Asset_ID__c==null){
             if(pa.Plant_Name__c.length() >72){
                pa.addError('Plant Name is too long (max 72 characters). Please type in abbreviated name in Plant Name field. Input entire plant name in Full Plant Name field.');
            }else{
             pa.Name = pa.Plant_Name__c;
            }
        } else{
             if((pa.Customer_Plant_Asset_ID__c.length()+pa.Plant_Name__c.length()) >72){
                pa.addError('Plant Name is too long (max 72 characters). Please type in abbreviated name in Plant Name field. Input entire plant name in Full Plant Name field.');
            }else{
            pa.Name = pa.Customer_Plant_Asset_ID__c+' - '+pa.Plant_Name__c;
            }
        }
        
    }   


}