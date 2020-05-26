trigger PF_AvoidDuplicate on Case (Before Insert) {
    List<String> subList = new List<String>();
    
    String [] emailDomain;
    String accountName;
    String AccountID;
    List <Account> lstAcc= new List<Account>();
    for(Case cs : Trigger.new){
        if(cs.Origin == 'Email' && cs.Subject.StartswithIgnorecase('re: ')){
            subList.add(cs.Subject.removeStartIgnoreCase('re: '));
        }
        else if(cs.Origin == 'Email' && cs.Subject.StartswithIgnorecase('re:')){
            subList.add(cs.Subject.removeStartIgnoreCase('re:'));
        }
        if(cs.SuppliedEmail!=null) {
            
            emailDomain = cs.SuppliedEmail.split('[\\@\\.]');            
        }
    }
    if(emailDomain!=null) {
     List <Company_Name__mdt> lstCMT = [Select MasterLabel,Domain_Name__c  from Company_Name__mdt 
                                                where Domain_Name__c IN : emailDomain];   
     if(lstCMT.size() > 0 )
     accountName = '%'+lstCMT[0].MasterLabel + '%'; 
    }
    if(accountName!=null) {
     lstAcc= [Select id from account where name like:accountName and Ticket_Dashboard__c = true]; 
     
    }
    if(lstAcc.size() > 0) {
        for (case cs : trigger.New) {
            cs.Company_Name__c = lstAcc[0].Id;
        }
    }
    system.debug('<<<<<'+subList);
        
    for(Case cs : [Select id, Subject from Case where Subject in : subList]){
        for(Case triggercs : trigger.new){
            if(cs.Subject == cs.Subject.removeStartIgnoreCase('re: ') || cs.Subject == cs.Subject.removeStartIgnoreCase('re:')){
                triggercs.addError(Label.Case_Duplicate_Error_Message);
            }
        }
    }
}