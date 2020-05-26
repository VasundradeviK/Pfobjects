global class DailyReportCustomerSchedule Implements Schedulable{
    
    global void execute(SchedulableContext sc)
    {
        sendmail();
    }
    
    public void sendmail()
    {
        List<RFI_Detail__c> rfiDetailsLst = [select id,RFI_Number__c,RFI_Number__r.RFI_Status__c,Assigned_Customer_Contact__c,Due_in_days__c,RFI_Item_Status__c,Due_Date__c from RFI_Detail__c where RFI_Item_Status__c!='Canceled' and RFI_Item_Status__c!='Cannot Complete'and RFI_Item_Status__c!='Closed' and RFI_Detail_Owner__r.contactId!=null ];
      
        List<Id> rfiConatcts = new List<Id>();
        for(RFI_Detail__c rfiDetailObj: rfiDetailsLst){
            rfiConatcts.add(rfiDetailObj.Assigned_Customer_Contact__c);
        }
        List<User> userLst = [select id,name,email,contactId from User where contactid=: rfiConatcts and contactId != null];
         System.debug('userLst'+userLst.size());
        Map<String,List<RFI_Detail__c>> mapObj = new Map<String,List<RFI_Detail__c>>();
        
        for(User userObj: userLst){
             List<RFI_Detail__c> rfiDetailsLst1 = new List<RFI_Detail__c>();
            for(RFI_Detail__c rfiDetailsObj :rfiDetailsLst){
               
                if(userObj.contactId == rfiDetailsObj.Assigned_Customer_Contact__c){
                    rfiDetailsLst1.add(rfiDetailsObj);
                   
                }
            }
             mapObj.put(userObj.email,rfiDetailsLst1);
             }
       
        List <Report> reportList = new List<Report>();
        reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'RFI_Daily_Customer_Report'];
       
        
        if(mapObj.keySet()!=null){
            
        for(String emailId : mapObj.keySet()){
            Integer rfiNumber=0;
        Integer SubmittedPendingCustomerReview=0;
        Integer InProgress = 0;
        Integer NeedsDetails=0;
        Integer Overdue=0;
        Integer TotalDuein2Days = 0;
            List<string> toEmailaddress = new  List<string>() ;
               toEmailaddress.add(emailId);
            List<RFI_Detail__c> rfiDetails = mapObj.get(emailId);
            System.debug('emailId' +emailId+'######+'+'rfiDetails size' +rfiDetails.size());
              List<String> rfiCount = new List<String>();
            for(RFI_Detail__c RfiDetail :rfiDetails){
                if(RfiDetail.RFI_Number__c!=null){
                 
                  }
                if(RfiDetail.RFI_Number__r.RFI_Status__c!='Colsed' && RfiDetail.RFI_Item_Status__c == 'Submitted – Pending Customer Review'){
                    rfiCount.add(RfiDetail.RFI_Number__c);
                    SubmittedPendingCustomerReview++;
                }
                if(RfiDetail.RFI_Number__r.RFI_Status__c!='Colsed' && RfiDetail.RFI_Item_Status__c == 'In Progress'){
                   rfiCount.add(RfiDetail.RFI_Number__c);
                    InProgress++;
                }
                if(RfiDetail.RFI_Number__r.RFI_Status__c!='Colsed' && RfiDetail.RFI_Item_Status__c == 'Needs Detail'){
                   rfiCount.add(RfiDetail.RFI_Number__c);
                    NeedsDetails++;
                }
                if(RfiDetail.RFI_Number__r.RFI_Status__c!='Colsed' && RfiDetail.Due_in_days__c == 'Overdue'){
                    Overdue++;
                }
                 if(RfiDetail.RFI_Number__r.RFI_Status__c!='Colsed' && RfiDetail.Due_in_days__c == 'Due in Two Days'){
                    TotalDuein2Days++;
                }
            }
          
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Daily RFI Report - Customer Response Required');
            
            
            if(reportList.size()>0){
                String fullRecordURL='';
               
                Network myNetwork = [SELECT Id FROM Network WHERE Name ='PF Drive Customer Community'];
                
                ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
              
                fullRecordURL = myCommunity.siteUrl + '/' +reportList[0].Id;
                System.debug('emailId' +emailId+'######+'+'rfiCount' +rfiCount.size()+'rfiDetails size' +rfiDetails.size()+'SubmittedPendingCustomerReview :# '+SubmittedPendingCustomerReview+ ''+
                            'InProgress#'+InProgress + ' '+
                            'NeedsDetails#' +NeedsDetails+''+
                            'Overdue#' +Overdue+' '+
                            'TotalDuein2Days##' +TotalDuein2Days);
               
  email.setHtmlBody('Total Active Customer RFIs: ' +rfiCount.size()+'<br>'+
                                       'Submitted - Pending Customer Review: ' +SubmittedPendingCustomerReview+'<br>'+
                                       'In Progress: ' +InProgress+'<br>'+
                                       'Needs Details: ' +NeedsDetails+'<br>'+
                                       'Overdue: ' +Overdue+'<br>'+
                                       'Total Due in 2 Days: '+TotalDuein2Days+'<br> <br>'+
                                       'Please click the link below to review all active RFI items that require your input. To provide'+'<br>'+
                                       'clarifying feedback on these RFIs:'+'<br>'+
                                        '<ol>'+
                                       '<li>Click the Salesforce link below to view all plant RFIs assigned to you</li>'+
                                       '<li>Click a specific RFI</li>'+
                                       '<li>Click the Related tab to view all RFI Items related to the RFI</li>'+
                                       '<li>Click Mass Edit RFI Items tab</li>'+
                                       '<li>Provide feedback by entering comments into the Customer Comments field</li>'+
                                       '<li>Change the the RFI Item Status to the appropriate status:</li>'+
                                       
                                       '<ol type="a">'+
                                         '<li>In Progress: You are actively working to collect the RFI Item information</li>'+
                                         '<li>Completed - Pending PF Review: You have provided the requested information'+'<br>'+
                                        'and the Implementation Engineer is assigned the RFI Item. They will review your feedback'+'<br>'+
                                        'to confirm no additional details are needed.</li></ol></ol>'+'<br>'+
                                       'Please note this is an automated message. If you have any immediate questions regarding '+'<br>'+
                                       'RFIs, please leave a comment in Chatter and ping the Implementation Engineer (@name) or'+'<br>'+
                                       'contact your Customer Success Manager.'+'<br>'+
                                       '<br>'+'<a href='+fullRecordURL+'>'+fullRecordURL+'</a>');
               
                                      email.setToAddresses(toEmailaddress);
                                     Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
            }
        }
        }
     }
  }