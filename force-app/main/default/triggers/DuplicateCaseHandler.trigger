trigger DuplicateCaseHandler on Case (before insert) {
    List<String> subList = new List<String>();
    String [] emailDomain;
    system.debug('case '+Trigger.new);
 for(Case cs : Trigger.new){
          cs.Status_Start_Time__c = DateTime.now();
     
    if(cs.Origin == 'Email' && cs.Subject!=null && cs.Subject.StartswithIgnorecase('FW: ')){
            subList.add(cs.Subject.removeStartIgnoreCase('FW: '));
        }
     else if(cs.Origin == 'Email' && cs.Subject!=null && cs.Subject.StartswithIgnorecase('FW:')){
            subList.add(cs.Subject.removeStartIgnoreCase('FW:'));
        }
    else if(cs.Origin == 'Email' && cs.Subject!=null && cs.Subject.StartswithIgnorecase('RE: ')){
            subList.add(cs.Subject.removeStartIgnoreCase('RE: '));
        }
   else if(cs.Origin == 'Email' && cs.Subject!=null && cs.Subject.StartswithIgnorecase('RE:')){
            subList.add(cs.Subject.removeStartIgnoreCase('RE:'));
        }
    
        System.debug('subList' +subList);
    
    List<Case> oldCslst =  [Select id, Subject,SuppliedEmail from Case where Subject in : subList];
       System.debug('oldCslst' +oldCslst);
    for(Case oldCs:oldCslst){
          System.debug('oldCs' +oldCs);
         Group groupDetail = [select Id from Group where Name = 'Duplicate Cases' and Type = 'Queue'] ;
       // if(cs.SuppliedEmail==oldCs.SuppliedEmail  ) {
            if(cs.Subject.removeStartIgnoreCase('FW: ') == oldCs.Subject || cs.Subject.removeStartIgnoreCase('FW:') == oldCs.Subject){
               cs.Status = 'Closed';
               cs.Parent_Case__c = oldCs.Id;
               System.debug('id1 --> ' +groupDetail.Id);
               cs.OwnerId = groupDetail.Id;
      }
            if(cs.Subject.removeStartIgnoreCase('RE: ') == oldCs.Subject || cs.Subject.removeStartIgnoreCase('RE:') == oldCs.Subject){
              System.debug(' cs.Subject');
              cs.Status = 'Closed';
              cs.Parent_Case__c = oldCs.Id;  
                 cs.OwnerId = groupDetail.Id;
            }
       // }
    }
    }
    
    
}