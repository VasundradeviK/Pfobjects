global class DailyReportPFOwnerSchedule Implements Schedulable{
     global void execute(SchedulableContext sc)
    {
        sendmail();
    }
    
    public void sendmail()
    {
      List<RFI_Detail__c> rfiDetailList = new List<RFI_Detail__c>();
            Set<string> emailaddress = new  Set<string>();
            rfiDetailList = [select id,RFI_Number__c,Account__r.Name,Due_in_days__c,IE_Owner__r.Email,IE_Owner__r.Name,RFI_Item_Status__c,Due_Date__c from RFI_Detail__c where  RFI_Item_Status__c = 'Completed – Pending PF Review'];
           Set<string> ownernames = new  Set<string>();
        if(rfiDetailList.size()>0){
            for(RFI_Detail__c rf: rfiDetailList){
               // if(rf.IE_Owner__r.Email!=null){
               // emailaddress.add(rf.IE_Owner__r.Email);
               // }
                 if(rf.IE_Owner__r.Email!=null){
                  ownernames.add(rf.IE_Owner__r.Name);
                }
             }
                System.debug('ownernames:-' +ownernames);
           }
         Map<String,List<RFI_Detail__c>> mapObj = new Map<String,List<RFI_Detail__c>>();
        for(String ownerName: ownernames){
            List<RFI_Detail__c> rfiDetailsLst1 = new List<RFI_Detail__c>();
            for(RFI_Detail__c rf: rfiDetailList){
                if(ownerName ==rf.IE_Owner__r.Name){
                    rfiDetailsLst1.add(rf);
                }
                
            }
             mapObj.put(ownerName,rfiDetailsLst1);
        }
        
       
         List <Report> reportList = new List<Report>();
          reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'Daily_RFI_Report_GmS']; 
          
        
        for(String ownersName : mapObj.keySet()){
            Set<String> accountNames = new Set<String>();
            Integer rfiNumber=0;
            Integer CompletedPendingPFReview=0;
            Integer InProgress = 0;
            Integer NeedsDetails=0;
            Integer Overdue=0;
            Integer TotalDuein2Days = 0;
            List<string> toEmailaddress = new  List<string>() ;
            
            List<RFI_Detail__c> rfiDetails = mapObj.get(ownersName);
            toEmailaddress.add(rfiDetails[0].IE_Owner__r.Email);
            
              List<String> rfiCount = new List<String>();
            for(RFI_Detail__c RfiDetail :rfiDetails){
               
                if(RfiDetail.RFI_Item_Status__c == 'Completed – Pending PF Review'){
                     rfiCount.add(RfiDetail.RFI_Number__c);
                     CompletedPendingPFReview++;
                      if(RfiDetail.Due_in_days__c == 'Overdue'){
                         Overdue++;
                       }
                     if(RfiDetail.Account__r.Name != null){
                     accountNames.add(RfiDetail.Account__r.Name);
                }
                }
          
            }
          
             System.debug('emailId' +ownersName+'######+'+'rfiDetails size' +rfiDetails.size()+'CompletedPendingPFReview :# '+CompletedPendingPFReview+ ''+
                            'InProgress#'+InProgress + ' '+
                            'NeedsDetails#' +NeedsDetails+''+
                            'Overdue#' +Overdue+' '+
                            'TotalDuein2Days##' +TotalDuein2Days);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(reportList.size()>0){
                 email.setSubject('Daily RFI Report - Action Requested');
                String fullRecordURL='';
                fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' +reportList[0].Id;
               
                email.setHtmlBody(' Total Completed - Pending PF Review RFIs: '+CompletedPendingPFReview+'<br>'+
                                       ' Overdue: '+Overdue+'<br>'+
                                       ' Please click the link below to view all RFIs that are ready for your review.'+'<br>'+
                                       ' Customers  '+accountNames+'<br><br>'+
                                  '<a href='+fullRecordURL+'>'+fullRecordURL+'</a>');
                                
                                email.setToAddresses(toEmailaddress);
                       if(CompletedPendingPFReview>0){
                                Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
                          }
            }
         
            
        } 
           
                    
        
    }
}