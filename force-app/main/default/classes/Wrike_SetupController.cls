public with sharing class Wrike_SetupController extends Wrike_AbstractSectionController {

        ApexPages.StandardController controller;

        public String userName { get; private set;}
        
        public String accountsJSON { get; private set;}
        
        public String accountName { get; private set;}

        public String objectsJSON { get; private set;}
        
        public String bindingsJSON { get; private set;}
        
        public boolean hasMultipleAccounts { get; private set;}
        
        public Boolean isWrikeAccountLinked { get { 
        	return !String.isBlank(getWrikeAccountId()); 
        	} }
        
        public Boolean showManualOAuthKeysBlock { get; private set;}
        
        
        ///
        public Boolean setupExists { get { return !String.isBlank(settings.WrikeServer__c); } }

        public PageReference redirectToImport() {
            return Page.WrikeUpdate_Main;
        } 
        
        public PageReference redirectToTemplateManager() {
            return Page.Wrike_TemplateManager;
        } 
         
        public PageReference ensureWrike() {

            try {
            
            checkIsAdmin();    
            
            // Check Metadata access
            
            if(!checkMetadataAPIConnection()) {
                return new PageReference('/apex/Wrike_RemoteSettings');
            }

            // Check API keys
            if (String.isBlank(settings.WrikeClientId__c ) || String.isBlank(settings.WrikeClientSecret__c)) {
                upsert settings;
                PageReference page = new PageReference('/apex/Wrike_OAuthPage');
                page.setRedirect(true);
                return page;
            }
            
            // Check Wrike access
            String userBody = getUserJSON();
            if (String.isBlank(userBody)) {
                isAuthorized = false;
                return null;
            }
            
            Map<String, String> wrikeUser = Wrike_JSONUtils.parseJSON(userBody, new String[] {'firstName', 'lastName'});
            userName = wrikeUser.get('firstName') + ' ' + wrikeUser.get('lastName');
            
            isAuthorized = true;
            System.debug('--------userBody '+ userBody);
            // Read available accounts
            
            Map<String,String> accounts = getAccounts();
            if (accounts == null || accounts.size() == 0){
                 throw new Wrike_Exceptions.CorruptedWrikeSettingsException('Could not get information on user Wrike account.');
            } else if (accounts.size() > 1) {
                hasMultipleAccounts = true;
            }
            
            JSONGenerator generator = JSON.createGenerator(false);
            generator.writeObject(accounts);
            accountsJSON = generator.getAsString();
            
            

            // Check customizations enabled
            if (settings.WrikeAccountId__c == null) {
                
                if (accounts.size() == 1) {
                    
                    List<String> accountIds =  new List<String>(accounts.keySet());
                       String accountId = accountIds.get(0);
                       
                    if(!isUser(userBody, accountId))
                        throw new Wrike_Exceptions.WrikeCollaboratorException();

                    saveAccountToSettings(accountId);
                    PageReference page = new PageReference(
                     ApexPages.currentPage().getUrl().split('\\?')[0]);
                    
                    page.setRedirect(true);
                    return page;
                }

                return null;
            } else if(!isUser(userBody, settings.WrikeAccountId__c)) {
            	throw new Wrike_Exceptions.WrikeCollaboratorException();
            }
            
            // Check Wrike account
            if (!accounts.containsKey(settings.WrikeAccountId__c)) {
               throw new Wrike_Exceptions.CorruptedWrikeSettingsException( 
                                                    'You are not listed in the Wrike account linked to your Salesforce organization.');
            }
            
            accountName = accounts.get(settings.WrikeAccountId__c);
            
            generator = JSON.createGenerator(false);
            generator.writeObject(getObjects());
            objectsJSON = generator.getAsString();
            
            generator = JSON.createGenerator(false);
            generator.writeObject(getBindings());
            bindingsJSON = generator.getAsString();
            return null;
            } catch(Exception ex) { 
                return handleExceptionPageRef(ex); 
                }
        
        }
        
        public PageReference saveApiKeys() {
               String clientId = ApexPages.currentPage().getParameters().get('clientId');
               String clientSecret = ApexPages.currentPage().getParameters().get('clientSecret');

            return saveOAuthKeys(clientId, clientSecret);
        }
        
        public PageReference getOAuthKeys()
        { 
            try {
                
                checkIsAdmin();
                
                Map<String, String> oauthKeys = WrikeWebHook.registerOauthClient(getSalesforceHost());
                System.debug('oauthKeys: ' + oauthKeys);
    
                String clientId = oauthKeys.get('clientId');
                String clientSecret = oauthKeys.get('clientSecret');
                if (!String.IsBlank(clientId) && !String.IsBlank(clientSecret)) {
                    return saveOAuthKeys(clientId, clientSecret);
                } else {
                	showManualOAuthKeysBlock = true;
                	return sendOAuthSupportRequest();
                }
            } catch(Exception ex) {
                return handleExceptionPageRef(ex); 
            }
        }
        
        private PageReference saveOAuthKeys(String clientId, String clientSecret)
        {
            if(Wrike_ApiUtils.checkOAuthClient(clientId)) {
                if (settings == null) settings = new WrikeAccountSettings__c(setupOwnerId = System.Userinfo.getOrganizationId());
                settings.WrikeClientId__c = clientId;
                settings.WrikeClientSecret__c = clientSecret;
                upsert settings;
                PageReference page = new PageReference('/apex/Wrike_SetupPage');
                page.setRedirect(true);
                return page;
            }
            return null;
        }
        
        private PageReference sendOAuthSupportRequest()
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {'support@team.wrike.com'});
            email.setSubject('Salesforce integration app personal keys');
            string emailBody = '--- Auto-generated by Wrike Salesforce Integration Package ---\r\n'
                                + 'Company Name: ' + UserInfo.getOrganizationName() + '\r\n'
                                + 'Salesforce Org Id: ' + UserInfo.getOrganizationId() + '\r\n'
                                + 'Contact Name: ' + UserInfo.getName() + '\r\n'
                                + 'Contact Email: ' + UserInfo.getUserEmail() + '\r\n'
                                + 'Redirect URI: ' + getSalesforceHost();                               
                                
            email.setPlainTextBody(emailBody);
            Messaging.SendEmailResult [] res = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            return null;
        }
        
        private void saveAccountToSettings(String accountId) {
            
            if (settings == null) {
                settings = new WrikeAccountSettings__c(setupOwnerId = System.Userinfo.getOrganizationId());
            }    
            settings.WrikeAccountId__c = accountId;
            settings.SalesforceFolderId__c = createSalesforceFolder(accountId);
            
            upsert settings;
            
           // resetBindings();
        }
        
        public PageReference saveAccount() {
            
            try {
                
                checkIsAdmin();
                
                String accountId = ApexPages.currentPage().getParameters().get('accountId');
                
                 if (accountId != null) {
                 	
                 	if(!isUser(getUserJSON(), accountId)) {
                 		throw new Wrike_Exceptions.WrikeCollaboratorException();
                 	}
                 	
                    saveAccountToSettings(accountId);
                }
                
                PageReference page = new PageReference(
                     ApexPages.currentPage().getUrl().split('\\?')[0]);
                page.setRedirect(true);
                return page;
            } catch(Exception ex) { 
                return handleExceptionPageRef(ex); 
                }
        }
        
        public PageReference disconnectUser() {
        	
        	try {
	        	resetSettings();
	        	
	        	return deauthorize();
        	} catch(Exception ex) { 
	            return handleExceptionPageRef(ex); 
	            }
        }
        
        public PageReference disconnectAccount() {
        	
             try {
                
                resetSettings();
                
                PageReference page = new PageReference(
                     ApexPages.currentPage().getUrl().split('\\?')[0]);
                page.setRedirect(true);
                return page;
            } catch(Exception ex) { 
                return handleExceptionPageRef(ex); 
                }
        }
        
        private void resetSettings() {
            
            if (settings != null) {
                settings.WrikeAccountId__c = null;
                settings.SalesforceFolderId__c = null;
            
                upsert settings;
                //resetBindings();
            }
        }
        
        private void resetBindings()
        {
            List<Wrike_Bindings__c> bindings = Wrike_Bindings__c.getAll().values();
            
            for(Wrike_Bindings__c binding : bindings)
            {
                 binding.ParentId__c = null;
            }
            update bindings;
        }
          
          /* out of use */
          /*     
        public PageReference saveBinding() {
            
            try {
                
                if (isAdministrator() && settings != null) {
                    String name = ApexPages.currentPage().getParameters().get('name');
                    String typee  = ApexPages.currentPage().getParameters().get('type');
                    String rule = ApexPages.currentPage().getParameters().get('rule');
                    String parentFolderId = ApexPages.currentPage().getParameters().get('folderId');
                    
                    Wrike_Bindings__c binding = 
                        Wrike_Bindings__c.getValues(name);
                    if (binding == null) {
                        binding = new Wrike_Bindings__c(Name = name);
                        binding.Type__c = typee;
                        
                        Schema.SObjectType objType = Schema.getGlobalDescribe().get(name);
                      //  String label = objType.getDescribe().getLabel();
                        
                        createCustomField(name, binding.Type__c); 
                        createPage(name, binding.Type__c);
                    }
                    binding.Rule__c = rule;
                    binding.ParentId__c = parentFolderId;
                    
                    upsert binding;
                }
    
                PageReference page = new PageReference(
                     ApexPages.currentPage().getUrl().split('\\?')[0]);
                page.setRedirect(true);
                return page;
            } catch(Exception ex) { 
                return handleExceptionPageRef(ex); 
                }
        }
        */
        public PageReference addBinding() {
            
            try {
                
                if (settings != null) {
                    String name = ApexPages.currentPage().getParameters().get('name');
                    
                    String bindingName = Wrike_Dictionary.getBindingName(name);
    
                    Wrike_Bindings__c binding = Wrike_Bindings__c.getValues(bindingName);
                    if (binding != null) return null; 
                                        
                    binding = new Wrike_Bindings__c(Name = bindingName);
                    binding.Type__c = 'FOLDER';
                    binding.Rule__c = 'AUTO';
                    binding.Full_Name__c = name;

                    String labelPlural = Wrike_SchemaUtils.getPluralLabelByName(name);
                                    
                    createCustomField(name, binding.Type__c); 
                    createPage(name, binding.Type__c);
                    
                    if(isFolderDeleted(settings.SalesforceFolderId__c)) {
                         settings.SalesforceFolderId__c = createSalesforceFolder(settings.WrikeAccountId__c);                    
                    }
                    
                    String folderBody = wrikeApiPost('/folders/'
                        + settings.SalesforceFolderId__c + '/folders',
                        'title=' + EncodingUtil.urlEncode(labelPlural, 'UTF-8'), ExceptionHandlingMode.NONE);
                     System.debug('folderBody: ' + folderBody);   
                    binding.ParentId__c = Wrike_JSONUtils.parseJSON(folderBody, 'id');

                    upsert binding;
                    upsert settings;
                }
    
                PageReference page = new PageReference(
                     ApexPages.currentPage().getUrl().split('\\?')[0]);
                page.setRedirect(true);
                return page;
            } catch(Exception ex) { 
                return handleExceptionPageRef(ex); 
                }
        }       
        
        public PageReference deleteBinding() {
            
            try {
                
                checkIsAdmin();
                    
                String name = ApexPages.currentPage().getParameters().get('name');
                String bindingName = Wrike_Dictionary.getBindingName(name);
                Wrike_Bindings__c binding =  Wrike_Bindings__c.getValues(bindingName);             
                if (binding != null) {
                    
                    if (!deletePage(name, binding.Type__c)) return null;
                    deleteCustomField(name, binding.Type__c);
                    
                    Map<String,Object> bindings = getBindings();
                    bindings.remove(bindingName);

                    delete binding;
                    
                    JSONGenerator generator = JSON.createGenerator(false);
                    generator.writeObject(bindings);
                    bindingsJSON = generator.getAsString();
                }
                return null;
            } catch(Exception ex) { 
                return handleExceptionPageRef(ex); 
                }
        }
        
        private String getUserJSON() {
          return wrikeApiGet('/contacts/?me', ExceptionHandlingMode.NONE);
        }
        
        private Map<String,String> getAccounts() {
            String accountsBody = wrikeApiGet('/accounts/', ExceptionHandlingMode.NONE);
            List<Object> accts = Wrike_JSONUtils.extractRecordsFromJSON(accountsBody);
            Map<String,String> result = new Map<String,String>();            
            
            for(Object o: accts) {
                Map<String, Object> acct = (Map<String, Object>)o;
                result.put((String)acct.get('id'), (String)acct.get('name'));
            }
            
            return result;            
        }
        
        private List<Object> getObjects() {
            
            // Standard objects list with extandable fields is taken from
            // http://www.salesforce.com/us/developer/docs/object_reference/Content/sforce_api_objects_custom_objects.htm#i1436378
            
            Set<String> standardObjectNames = new Set<String> { 
                'Account','Campaign','Case','Contact','Contract','Event',
                'Lead','Opportunity','Product2','Solution','Task','User' };
            
            List<Object> objects = new List<Object>();
                
            //Put custom objects here too
            List<Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe().Values();    

            for(Schema.SObjectType obj : globalDescribe) {
                DescribeSObjectResult describe = obj.getDescribe();
                if (standardObjectNames.contains(describe.getName()) ||
                        describe.isCustom() && !describe.isCustomSetting() ) {
                    
                    Map<String,Object> props = new Map<String,Object>();
                    props.put('name', describe.getName());
                    props.put('label', describe.getLabel());
                    props.put('labelPlural', describe.getLabelPlural()); 
                    props.put('custom', describe.isCustom());
                    props.put('bindingName', Wrike_Dictionary.getBindingName(describe.getName()));
                    
                    Map<String, Schema.SobjectField> fieldsmap = 
                        describe.fields.getMap();
                    
                    props.put('wrikeTaskField', fieldsmap.containsKey('Wrike_Task_ID__c'));
                    props.put('wrikeFolderField', fieldsmap.containsKey('Wrike_Folder_ID__c'));

                 //   System.debug(Logginglevel.INFO, describe);
                    objects.add(props);
                }
            }
            
            return objects;
        }
        
        private Map<String,Object> getBindings() {
            Map<String,Object> bindingsMap = new Map<String,Object>();
            for (Wrike_Bindings__c binding : Wrike_Bindings__c.getAll().values()) {
                Map<String,String> bindingParams = new Map<String,String>();
                bindingParams.put('type', binding.Type__c);
                bindingParams.put('rule', binding.Rule__c);
                bindingParams.put('parentId', binding.ParentId__c);
                bindingParams.put('nameTemplate', binding.NameTemplate__c);
                bindingsMap.put(binding.Name, bindingParams);
            }
            return bindingsMap;
        }
        
        public static Boolean createCustomField(String objName, String typee) {
            
            return WrikeUpdate_Utils.createCustomField(objName);
        }
        
        public static Boolean deleteCustomField(String objName, String typee) {
            
           return WrikeUpdate_Utils.deleteCustomField(objName, false);
        }
        
        private static String getCustomFieldName(String typee)
        {
            return (typee == 'FOLDER')?
                'Wrike_Folder_ID' : 'Wrike_Task_ID';
        }
        
        
        public static Boolean createPage(String objName, String typee) {
            return WrikeUpdate_Utils.createPage(objName);
        }
     
        private static void addApexPageToLayouts(final String apexPageName, final String objectName, final Wrike_MetadataService.MetadataPort service) {
            final String[] objectLayoutNames = listObjectLayouts(objectName, service);
            if(!objectLayoutNames.isEmpty()) {
                Wrike_MetadataService.Metadata[] layouts = service.readMetadata('Layout', objectLayoutNames).getRecords();
                for(Wrike_MetadataService.Layout layout : (Wrike_MetadataService.Layout[])layouts) {
                    if(layout.layoutSections == null) {
                        layout.layoutSections = new List<Wrike_MetadataService.LayoutSection>();
                    } 
                    Wrike_MetadataService.LayoutSection section = new Wrike_MetadataService.LayoutSection();
                    section.style = 'OneColumn';
                    Wrike_MetadataService.LayoutColumn column = new Wrike_MetadataService.LayoutColumn();
                    Wrike_MetadataService.LayoutItem layoutItem = new Wrike_MetadataService.LayoutItem();
                    layoutItem.page_x = apexPageName;
                    layoutItem.height = 355;
                    layoutItem.width = '100%';
                    column.layoutItems = new List<Wrike_MetadataService.LayoutItem> { layoutItem }; 
                    section.layoutColumns = new List<Wrike_MetadataService.LayoutColumn> { column };        
                    layout.layoutSections.add(section); 
                }                  
                service.updateMetadata(layouts);
            }
        }
        
        private static void removeApexPageFromLayouts(final String apexPageName, final String objectName, final Wrike_MetadataService.MetadataPort service) {
            final String[] objectLayoutNames = listObjectLayouts(objectName, service);
            if(!objectLayoutNames.isEmpty()) {
                Wrike_MetadataService.Metadata[] layouts = service.readMetadata('Layout', objectLayoutNames).getRecords();
                Wrike_MetadataService.Metadata[] updatedLayouts = new Wrike_MetadataService.Metadata[] {};
                for(Wrike_MetadataService.Layout layout : (Wrike_MetadataService.Layout[])layouts) {
                    final Wrike_MetadataService.Layout updatedLayout = removeApexPageFromLayout(layout, apexPageName);
                    if(updatedLayout != null) {
                        updatedLayouts.add(updatedLayout);
                    }
                } 
                if(!updatedLayouts.isEmpty()) {
                    service.updateMetadata(updatedLayouts);
                }                 
            }
        }
        
        private static Wrike_MetadataService.Layout removeApexPageFromLayout(final Wrike_MetadataService.Layout layout, final String apexPageName) {
            if(layout.layoutSections != null) {
                for(Integer s = 0; s < layout.layoutSections.size(); s++) {
                    final Wrike_MetadataService.LayoutSection section = layout.layoutSections[s];
                    if(section.layoutColumns != null) {
                        for(Wrike_MetadataService.LayoutColumn column : section.layoutColumns) {
                            if(column.layoutItems != null) {
                                for(Integer i=0; i < column.layoutItems.size(); i++) {
                                    if(column.layoutItems[i].page_x == apexPageName) {
                                        if(section.layoutColumns.size() == 1 && column.layoutItems.size() == 1) {
                                            layout.layoutSections.remove(s);    
                                        } else {
                                            column.layoutItems.remove(i);
                                        }
                                        return layout;
                                    }
                                }
                            }
                        }
                    }
                     
                }
            }
            if(layout.relatedContent != null && layout.relatedContent.relatedContentItems != null) {
                for(Integer i = 0; i < layout.relatedContent.relatedContentItems.size(); i++) {
                    final Wrike_MetadataService.RelatedContentItem contentItem = layout.relatedContent.relatedContentItems[i];
                    if(contentItem.layoutItem != null && contentItem.layoutItem.page_x == apexPageName) {
                        layout.relatedContent.relatedContentItems.remove(i);
                        return layout;
                    }
                }
            }
            return null;
        }
        
        private static String[] listObjectLayouts(final String objectName, final Wrike_MetadataService.MetadataPort service) {
            Wrike_MetadataService.ListMetadataQuery layoutQuery = new Wrike_MetadataService.ListMetadataQuery();
            layoutQuery.type_x = 'Layout';
            Wrike_MetadataService.FileProperties[] layoutMetaList = service.listMetadata(new List<Wrike_MetadataService.ListMetadataQuery> { layoutQuery }, 31);
            String[] objectLayoutNames = new String[] {};
            for(Wrike_MetadataService.FileProperties layoutMeta : layoutMetaList) {
                if(layoutMeta.fullName.startsWith(objectName + '-')) {
                    objectLayoutNames.add(layoutMeta.fullName);
                }
            }
            return objectLayoutNames;
        }
        
        public static Boolean deletePage(String objName, String typee) {
            return WrikeUpdate_Utils.deletePage(objName);
        }

        
        public static Wrike_MetadataService.MetadataPort createService() {
             
            Wrike_MetadataService.MetadataPort service = new Wrike_MetadataService.MetadataPort();
            service.SessionHeader = new Wrike_MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            return service;     
        }

 }