public class AccountContactController{
   
    public String accId;
    public String p;
    public String accountId{get;set;}
    public String customerId{get;set;}
    
    public Account account{get;set;}
    public Contact contact{get;set;}
    public Plant_Asset__c assetTag{get;set;}
    
    public boolean isAccountExists;
    public boolean isContactExists;
    public boolean assetTagFlag{get;set;}
    public boolean accountFlag{get;set;}
    public boolean contactFlag{get;set;}
    
    private static String PLANT = ' - Plant';
    
    public AccountContactController(){
        
    }
    
    public AccountContactController(ApexPages.StandardController controller){        
        accountFlag = true;
        contactFlag = false;
        assetTagFlag = false;
        isAccountExists = false;
        isContactExists = false;
        account = new Account();
        contact = new Contact();
        assetTag = new Plant_Asset__c();
        if(ApexPages.currentPage().getParameters().get('id') != null){
           account.ParentId = ApexPages.currentPage().getParameters().get('id');
           
           List<Account> accountList = [SELECT Id, 
                                               Customer_ID__c,
                                               Project_Id__c  
                                        FROM Account 
                                        WHERE Id =: account.ParentId];                             
           account.Customer_ID__c = accountList.get(0).Customer_ID__c;    
           customerId = accountList.get(0).Customer_ID__c; 
           p = accountList.get(0).Project_Id__c;                             
        }
    }
    
    public void accountNext(){
        if(accountFlag){
           /*if(String.isBlank(account.Name)){
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Account Name field is mandatory.');
              ApexPages.addMessage(myMsg);
              return;
           }*/ 
           
          
           if(account.Name != null){
              List<Account> accList = new List<Account>();
              accList = [SELECT Id,
                                Name  
                         FROM Account
                         WHERE Name =: account.Name];
              if(!accList.isEmpty()){
                 isAccountExists = true;
                 account.Id = accList.get(0).Id;
                 accId = accList.get(0).Id;
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Account ' + account.Name + ' has already been created. Do you wish to continue with the existing Account?. If yes then please enter the contact details.');
                 ApexPages.addMessage(myMsg);
              }
           }   
           accountFlag = false; 
           assetTagFlag = true;    
        }
    }
    
    public void contactNext(){
        if(contactFlag){
           /*boolean flag = false;
           ApexPages.Message myMsg;
           if(String.isBlank(contact.LastName)){
              myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Last Name field is mandatory.');
              ApexPages.addMessage(myMsg);
              flag = true;
           }
           if(String.isBlank(contact.Email)){
              myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Email field is mandatory.');
              ApexPages.addMessage(myMsg);
              flag = true;
           }
           if(flag)
             return; 
           */
         
           if(contact.Email != null && isAccountExists){
              List<Contact> contList = new List<Contact>();
              contList = [SELECT Id,
                                 Email,
                                 LastName 
                          FROM Contact
                          WHERE Email =: contact.Email
                          AND LastName =: contact.LastName 
                          AND AccountId =: accId];
              if(!contList.isEmpty()){
                 isContactExists = true;
                 contact.Id = contList.get(0).Id;
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact has already been created. Do you wish to continue with the existing Contact?. If yes then please enter the Asset Tag details.');
                 ApexPages.addMessage(myMsg);
              }
           }    
           contactFlag = false;
           assetTagFlag = true;    
        }
    }
    
    public void contactPrevious(){
        accountFlag = true;
        contactFlag = false;
        assetTagFlag = false;
    }
    
    public void assetTagPrevious(){
        accountFlag = true;
        assetTagFlag = false;
    }
    
    public void save(){
        
        /*if(assetTag.Name == null){
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Please enter Asset Id');
           ApexPages.addMessage(myMsg);
           return null;
        }*/    
       
        Profile profile = [Select Id, Name from Profile where Id =: UserInfo.getProfileId()];
        String projId, parentId, pId;
        Integer level = 0;
        List<Account> accList = new List<Account>();
        Savepoint sp = Database.setSavepoint();
        try{
            if(isAccountExists){
               accList = [SELECT Id,
                                 Account_Email__c,
                                 Customer_ID__c,
                                 Project_Id__c   
                          FROM Account
                          WHERE Name =: account.Name];
               if(!accList.isEmpty()){
                  accList.get(0).Account_Email__c = account.Account_Email__c;
                  if(profile != null && profile.Name.contains('MaxGen'))
                     accList.get(0).Customer_ID__c = '1021';
                  else
                     accList.get(0).Customer_ID__c = account.Customer_ID__c;     
                  update accList.get(0);
                  accountId = accList.get(0).Id;
                  projId = accList.get(0).Project_Id__c;
               }  
            }else{
              parentId = account.ParentId;
              for(Integer i = 0; i < 100; i++){
                 accList = [SELECT Id,
                                   ParentId
                            FROM Account 
                            WHERE Id =: parentId];
                 if(!accList.isEmpty()){
                    parentId = accList.get(0).ParentId;
                    pId = accList.get(0).Id;
                    level = level + 1;
                 }
                 if(parentId == null)
                    break;           
              } 
              System.debug('pId1: '+pId);
                              
              System.debug('accList: '+accList);
              level = level - 1;
              if(level == 0){
                  if(profile != null && profile.Name.contains('MaxGen')){
                      accList = [SELECT Id,
                                        Project_Id__c                                    
                                    FROM Account 
                                    WHERE Customer_ID__c = '1021'
                                    ORDER BY Project_Id__c DESC NULLS LAST];
                  }else{
                      accList = [SELECT Id,
                                        Project_Id__c                                    
                                    FROM Account 
                                    WHERE ParentId =: pId 
                                    ORDER BY Project_Id__c DESC NULLS LAST];
                  }       
                  System.debug('Level : '+level);         
                  if(!accList.isEmpty()){
                     String projectId = accList.get(0).Project_Id__c;
                     String s1 = projectId.subStringAfterLast('.');
                     Integer v = Integer.valueOf(s1);
                     System.debug('value of v: '+v);
                     v = v + 1;
                     if(v < 10){
                        s1 = '000' + v; 
                        System.debug('value of incremented v: '+s1);
                     }else if (v > =10 && v < 100){
                        s1 = '00'+v;
                        System.debug('value of incremented v: '+s1);
                     }else if(v > =100 && v < 1000){
                        s1 = '0'+v; 
                     }    
                     account.Project_Id__c = customerId + '.' + s1;            
                  }else{
                     account.Project_Id__c = customerId + '.' + '0001';
                  }  
              }else if(level == 1){
                  System.debug('Level : '+level);
                   
                  accList = [SELECT Id,
                                    Project_Id__c                                   
                             FROM Account 
                             WHERE ParentId =: account.ParentId
                             ORDER BY Project_Id__c DESC NULLS LAST];               
                  String proId;
                  proId = p;
                  if(!accList.isEmpty()){
                     String s1 = proId.subStringAfterLast('.');
                     Integer v = Integer.valueOf(s1);
                     System.debug('value of v: '+v);
                     v = v + 1;
                     if(v < 10){
                        s1 = '0' + v; 
                        System.debug('value of incremented v: '+s1);
                     }    
                     account.Project_Id__c = proId + '.' + s1;            
                  }else{
                     account.Project_Id__c = proId + '.' + '01';
                  } 
              }
              if(profile != null && profile.Name.contains('MaxGen'))     
                 account.Customer_ID__c = '1021';
              else
                 account.Customer_ID__c = customerId;
              account.Name = account.Project_Id__c + ' - ' + account.Name;
              insert account;
              accountId = account.Id;
              projId = account.Project_Id__c;
              System.debug('projId: '+projId);
            }
            
            RecordType assetTagRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Location'];
            assetTag.Name = projId + ' ' + PLANT;
            System.debug('assetTag.Name: '+assetTag.Name);
            assetTag.Account__c = accountId;
            assetTag.RecordTypeId = assetTagRecordType.Id;
            insert assetTag;
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Created Successfully.Thank you!');
            ApexPages.addMessage(myMsg);
            
            return;
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'System error. Please contact your system administrator.');
            ApexPages.addMessage(myMsg);
            return;
        }
    }
    
    public PageReference cancel(){
        PageReference ref = new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
        return ref;
    }
    
    public void populateCustomerId(){
        System.debug('account.ParentId: '+customerId);
        List<Account> parentAccountList = new List<Account>();
        parentAccountList = [SELECT Id,
                                    Customer_ID__c 
                             FROM Account
                             WHERE Id =: customerId];
        System.debug('parentAccountList: '+parentAccountList);                   
        if(parentAccountList != null && !parentAccountList.isEmpty())  
           account.Customer_ID__c = parentAccountList.get(0).Customer_ID__c;  
        else
           account.Customer_ID__c = null;                        
    } 
}