public class ParentAccountController{
    
    public String accId;
    public String accountId{get;set;}
    
    public Account account{get;set;}
    public Contact contact{get;set;}
    
    public boolean isAccountExists;
    public boolean isContactExists;
    public boolean accountFlag{get;set;}
    public boolean contactFlag{get;set;}
    
    public ParentAccountController(){
        
    }
    
    public ParentAccountController(ApexPages.StandardController controller){        
        accountFlag = true;
        contactFlag = false;
        isAccountExists = false;
        isContactExists = false;
        account = new Account();
        contact = new Contact();
    }
    
    public void accountNext(){
        if(accountFlag){ 
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
           contactFlag = true;    
        }
    }
    
    public void contactNext(){
        if(contactFlag){
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
        }
    }
    
    public void contactPrevious(){
        accountFlag = true;
        contactFlag = false;
    }
    
    public void save(){    
        String contactId, projId;
        List<Account> accList = new List<Account>();
        Savepoint sp = Database.setSavepoint();
        try{
            if(isAccountExists){
               accList = [SELECT Id,
                                 Name,
                                 Account_Email__c    
                          FROM Account
                          WHERE Name LIKE: '%' + account.Name];
               if(!accList.isEmpty()){
                  //accList.get(0).Name = account.Name;
                  accList.get(0).Account_Email__c = account.Account_Email__c;
                  //accList.get(0).Site = account.Site;
                  //accList.get(0).Customer_ID__c = account.Customer_ID__c;  
                  update accList.get(0);
                  accountId = accList.get(0).Id;
               }  
            }else{
               Profile profile = [Select Id, Name from Profile where Id =: UserInfo.getProfileId()];
               accList = [SELECT Id,
                                Customer_ID__c
                         FROM Account 
                         WHERE ParentId = null 
                         AND Customer_ID__c < '9000' 
                         ORDER BY Customer_ID__c DESC NULLS LAST];             
               if(profile != null && !profile.Name.contains('MaxGen')){
                  if(!accList.isEmpty()){
                     String customerId = accList.get(0).Customer_ID__c;
                     if(customerId != null && Integer.valueOf(customerId) < 9000){
                        Integer v = Integer.valueOf(customerId) + 1;
                        account.Customer_ID__c = String.valueOf(v);            
                     }  
                  }else{
                     account.Customer_ID__c = '1';
                  }   
                  insert account;
                  accountId = account.Id;
              }else{
                  account.Customer_ID__c = '1021';
                  insert account;
                  accountId = account.Id;
              }
            }
            //if(isContactExists){
                  contact.AccountId = account.Id;
                  insert contact;
                  contactId = contact.Id;
            //}
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Created Successfully.Thank you!');
            ApexPages.addMessage(myMsg);
            
            return;
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Record."Please enter a Unique Asset ID"');
            ApexPages.addMessage(myMsg);
            return;
        }
    }
    
    public PageReference cancel(){
        PageReference ref = new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
        return ref;
    }
}