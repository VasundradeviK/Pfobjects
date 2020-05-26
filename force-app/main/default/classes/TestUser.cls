@isTest
public class TestUser {
    @isTest
    static void createUser(){
        Id portalProfileId = [select id from profile where name='PF Community'].id;
 // + system.label.PortalEmailSuffix
        Account portalAccount = new Account(name = 'portalAccount');//create a portal account first
  insert portalAccount;
  Contact portalContact = new contact(LastName = 'portalContact', AccountId = portalAccount.Id); //create a portal contact
  insert portalContact;
  User u1 = new User( email='genelia.dsouza@gmail.com',
                profileid = portalProfileId, 
                UserName='genelia.dsouza@gmail.com', 
                Alias = 'GDS',
                TimeZoneSidKey='America/New_York',
                EmailEncodingKey='ISO-8859-1',
                LocaleSidKey='en_US', 
                LanguageLocaleKey='en_US',
                ContactId = portalContact.Id,
                PortalRole = 'Manager',
                FirstName = 'Genelia',
                LastName = 'Dsouza');
        insert u1;
    }

    
}