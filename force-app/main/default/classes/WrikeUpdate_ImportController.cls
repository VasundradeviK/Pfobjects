global with sharing class WrikeUpdate_ImportController {
    
    
    @RemoteAction
    global static String init() {
        
        return '{ "next": "settings", "nextDescription": "Restoring package settings" }';
    }
    
    private static Map<String,String> parseJSONFields(String str) {

        Map<String,String> result = new Map<String,String>();
        JSONParser parser = JSON.createParser(str);
            
        while (parser.nextToken() != null) {

            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String name = parser.getText();
                parser.nextToken();
                String value = parser.getText();
                
                result.put(name, value);
            }
        }
        return result;
    }
    
    @RemoteAction
    global static String step(String step, String data) {
        
        System.debug(data);
        
        try {
        // Settings
        if (step == 'settings') {
            
            List<String> fieldNames = Wrike_Dictionary.SETTINGS_FIELDS;
            
            SObjectType wrikeSettingsType = Schema.getGlobalDescribe().get('WrikeAccountSettings__c');
            
            SObject settings = wrikeSettingsType.newSObject();
            
            Map<String,String> jsonmap = parseJSONFields(data);
                 
            for (String name: fieldNames) {
                String savedVal = (String) jsonmap.get(name);
                if(!String.isBlank(savedVal)) {
                    settings.put(name, savedVal);
                }
            }           
            
            if (WrikeUpdate_Utils.insertRecord(settings)) {
                return WrikeUpdate_Utils.nextResponse('apitokens', 'Restoring Wrike API tokens');
            }
            else {
                return WrikeUpdate_Utils.databaseErrorResponse;
            }            
        }
        
        // API tokens
        else if (step == 'apitokens') {
            
            SObjectType wrikeAPIType = Schema.getGlobalDescribe().get('Wrike_API__c');
            List<SObject> apis = new List<SObject>();
            SObject api = null;
            
            JSONParser parser = JSON.createParser(data);
            
            String owner = null, token = null;          
            while (parser.nextToken() != null) {
                if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                    api = wrikeAPIType.newSObject();
                }
                else if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    if(parser.getText() == 'SetupOwnerId'){
                        parser.nextToken();
                        api.put('SetupOwnerId', parser.getText());
                    }
                    else if(parser.getText() == 'RefreshToken__c'){
                        parser.nextToken();
                        api.put('RefreshToken__c', parser.getText());
                    }
                }
                else if(parser.getCurrentToken() == JSONToken.END_OBJECT){
                    if (api.get('SetupOwnerId') != null) {
                        apis.add(api);
                    }
                }
            }

            if (WrikeUpdate_Utils.insertRecords(apis)) {
                return WrikeUpdate_Utils.nextResponse('templates', 'Restoring folder templates');
            }
            else {
                return WrikeUpdate_Utils.databaseErrorResponse;
            }
            
        }
        
        else if (step == 'templates') {
            
            SObjectType wrikeTemplateType = Schema.getGlobalDescribe().get('Wrike_Folder_Template__c');
            List<SObject> templates = new List<SObject>();
            SObject template = null;
            
            JSONParser parser = JSON.createParser(data);
                
            while (parser.nextToken() != null) {
                if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                    template = wrikeTemplateType.newSObject();
                }
                else if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    if(parser.getText() == 'Name'){
                        parser.nextToken();
                        template.put('Name', parser.getText());
                    }
                    else if(parser.getText() == 'Description__c'){
                        parser.nextToken();
                        template.put('Description__c', parser.getText());
                    }
                    else if(parser.getText() == 'Wrike_Folder_Name__c'){
                        parser.nextToken();
                        template.put('Wrike_Folder_Name__c', parser.getText());
                    }
                    else if(parser.getText() == 'Order__c'){
                        parser.nextToken();
                        template.put('Order__c', Integer.valueOf(parser.getText()));
                    }
                    else if(parser.getText() == 'Wrike_Folder_Id__c'){
                        parser.nextToken();
                        template.put('Wrike_Folder_Id__c', parser.getText());
                    }
                    else if(parser.getText() == 'Wrike_Folder_Permalink__c'){
                        parser.nextToken();
                        template.put('Wrike_Folder_Permalink__c', parser.getText());
                    }
                }
                else if(parser.getCurrentToken() == JSONToken.END_OBJECT){
                    if (template.get('Name') != null) {
                        templates.add(template);
                    }
                }
            }

            if (WrikeUpdate_Utils.insertRecords(templates)) {
                return WrikeUpdate_Utils.nextResponse('bindings', 'Restoring linked objects list');
            }
            else {
                return WrikeUpdate_Utils.databaseErrorResponse;
            }
            
        }
        
        // Bindings
        if (step == 'bindings') {

            Set<String> fieldNames = new Set<String> {'Name', 'NameTemplate__c', 'ParentId__c', 'Rule__c', 'Type__c', 'Full_Name__c' };
            
            SObjectType wrikeBindingType = Schema.getGlobalDescribe().get('Wrike_Bindings__c');
            List<SObject> bindings = new List<SObject>();            
            SObject binding = null;
            
            JSONParser parser = JSON.createParser(data);
            
            while (parser.nextToken() != null) {
                if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                    binding = wrikeBindingType.newSObject();
                }
                else if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    String name = parser.getText();
                    if (fieldNames.contains(name)) {
                        parser.nextToken();
                        String value = parser.getText();
                        binding.put(name, value);
                    }
                }
                else if(parser.getCurrentToken() == JSONToken.END_OBJECT){
                    if (String.isBlank((String)binding.get('Full_Name__c'))) {
                        binding.put('Full_Name__c',  (String)binding.get('Name'));
                    }
                    bindings.add(binding);
                }
            }
            
            if (! WrikeUpdate_Utils.insertRecords(bindings)) {
                return WrikeUpdate_Utils.databaseErrorResponse;
            }

            if (bindings.size() > 0) {
                String obj = (String) bindings[0].get('Full_Name__c');

                return WrikeUpdate_Utils.nextResponse('binding-' + obj + '-field', 'Creating relationship key field in '+ obj);
            }
            else {
                return WrikeUpdate_Utils.lastResponse();
            } 
        }
        
        // Fields and data
        else if (step.startsWith('binding-')) {
            
            String[] chunks = step.split('-', 4);
            String obj = chunks[1];
            String substep = chunks[2];
            
            if (substep == 'field') {
            	
                WrikeUpdate_Utils.createCustomField(obj);
               /* if (! WrikeUpdate_Utils.createCustomField(obj)) {                    
                    return WrikeUpdate_Utils.metadataErrorResponse;
                }*/
                
                return WrikeUpdate_Utils.nextResponse('binding-' + obj + '-data', 'Restoring relationship data for '+ obj); 
            }
            else if (substep == 'data') {
            	
            	String errors = '';

                List<String> idlist = new List<String>();
                Map<String,String> idmap = new Map<String,String>();
                
                JSONParser parser = JSON.createParser(data);
                
                String id, wrikeId; 
                while (parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                        id = null; wrikeId = null;
                    }
                    else if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                        String name = parser.getText();
                        if (name == 'ID') {
                            parser.nextToken();
                            id = parser.getText();
                        }
                        else if (name == 'Wrike_Folder_ID__c') {
                            parser.nextToken();
                            wrikeId = parser.getText();
                        }
                    }
                    else if(parser.getCurrentToken() == JSONToken.END_OBJECT){
                        if (id != null && wrikeId != null) {
                            idmap.put(id,wrikeId);
                            idlist.add('\'' + id + '\'');
                        }
                    }
                }
                
                if (idlist.size() > 0) {
                 
                    String ids = String.join(idlist, ',');
                    String query = 'SELECT ID, Wrike_Folder_ID__c from ' + obj + ' WHERE ID IN ( ' + ids +' )';
                    System.debug(query);
                    
                    SObject[] records = WrikeUpdate_Utils.queryRecords(query);            
                    for (SObject record: records) {
                        String rid = (String) record.get('ID');
                        record.put('Wrike_Folder_ID__c', idmap.get(rid));
                    }
                    /*
                    if (! WrikeUpdate_Utils.updateRecords(records)) {
                        return WrikeUpdate_Utils.databaseErrorResponse;
                    }
                    */
                    Map<Id, String> updateFails = WrikeUpdate_Utils.updateRecordsAndReturnFails(records);
                    
                    if(updateFails !=null && updateFails.size() > 0) {
                    	
                    	String nameField = Wrike_SchemaUtils.getNameFieldByID(records[0].Id);
                    	ids = '\'' + String.join(new List<Id>(updateFails.keySet()), '\',\'') + '\'';
                    	String fquery = 'SELECT ID, ' + nameField + ' from ' + obj + ' WHERE ID IN ( ' + ids +' )';
                    	System.debug(fquery);
                    	List<SObject> failedRecords = WrikeUpdate_Utils.queryRecords(fquery); 
                    	
	                    List<String> fileRows = new List<String>();
            
                            for (SObject fr : failedRecords) {

                                fileRows.add(
                                   + '{"recordId":"' + fr.Id + '",'
                                   + '"recordName":"' + fr.get(nameField) + '",'
                                   + '"errors":"' + updateFails.get(fr.Id) + '"}');                
                            }
                            
                            errors = '['+ String.join(fileRows, ',') +']';
                            
                            System.debug('---- data update errors: ' + errors);
                    }
                }    

                return WrikeUpdate_Utils.nextResponse('binding-' + obj + '-page',
                        'Creating Visualforce component for '+ obj, errors);          

            }
            else if (substep == 'page') {
            
                WrikeUpdate_Utils.createPage(obj);
                
                String nextLayout = WrikeUpdate_Utils.getNextLayout(obj, null);
                
                if (nextLayout != null) {
                    return WrikeUpdate_Utils.nextResponse(                    
                            'binding-' + obj + '-layout-' + nextLayout,
                            'Updating layout '+ nextLayout);
                }
                
                String nextObj = WrikeUpdate_Utils.getNextObject(obj);
                if (nextObj != null)
                    return WrikeUpdate_Utils.nextResponse('binding-' + nextObj + '-field',
                            'Creating relationship key field in '+ nextObj);
                else
                    return WrikeUpdate_Utils.lastResponse();
                
            }
            else if (substep == 'layout') {
                String layout = chunks[3];
                
                Map<String, Object> dataFields = (Map<String, Object>)
                      JSON.deserializeUntyped(data);
                      
                if (dataFields.containsKey('pageName')) {
                    
                    String[] objectLayoutNames = new String[] { layout };
                
                    String label = WrikeUpdate_Utils.getObjectLabel(obj);                
                    String apexPageName = WrikeUpdate_Utils.getTargetPageName(obj);
                    
                    Wrike_MetadataService.IMetadataPort service = WrikeUpdate_Utils.createService();
                    Wrike_MetadataService.Layout[] layouts =
                            (Wrike_MetadataService.Layout[])
                    service.readMetadata('Layout', objectLayoutNames).getRecords();
                    
                    if (!layouts.isEmpty()) {
                        Wrike_MetadataService.Layout l = layouts[0];
                    
                        Integer sectionIndex = (Integer) dataFields.get('sectionIndex');
                        Integer columnIndex = (Integer) dataFields.get('columnIndex');
                        Integer itemIndex = (Integer) dataFields.get('itemIndex');
                        
                        Wrike_MetadataService.LayoutSection section;
                        Wrike_MetadataService.LayoutColumn column;
                        
                        if(l.layoutSections != null &&
                                 sectionIndex < l.layoutSections.size()) {
                            section = l.layoutSections[sectionIndex];
                            
                            if(section.layoutColumns != null &&
                                    columnIndex < section.layoutColumns.size()) {
                                column = section.layoutColumns[columnIndex];
                            }
                        }
                        if (column == null) {
                            section = new Wrike_MetadataService.LayoutSection();
                            section.style = 'OneColumn';
                            if(l.layoutSections == null) {
                                l.layoutSections = new List<Wrike_MetadataService.LayoutSection>();
                            }        
                            l.layoutSections.add(section);
                            
                            column = new Wrike_MetadataService.LayoutColumn();
                            section.layoutColumns = new List<Wrike_MetadataService.LayoutColumn> { column };
                        }
                        
                        Wrike_MetadataService.LayoutItem layoutItem =
                                new Wrike_MetadataService.LayoutItem();
                        layoutItem.page_x = apexPageName;
                        layoutItem.height = 360;//(Integer) dataFields.get('itemHeight');
                        layoutItem.width = (String) dataFields.get('itemWidth');
                        layoutItem.showLabel = (Boolean) dataFields.get('itemShowLabel');
                        layoutItem.showScrollbars = (Boolean) dataFields.get('itemShowScrollbars');
                        
                        if (column.layoutItems == null) {
                            column.layoutItems = new List<Wrike_MetadataService.LayoutItem>();
                        }
                        if (itemIndex < column.layoutItems.size()){
                            column.layoutItems.add(itemIndex, layoutItem);
                        }
                        else {
                            column.layoutItems.add(layoutItem);
                        }
                        
                        //save
                        List<Wrike_MetadataService.SaveResult> results =
                                  service.updateMetadata(layouts);
                                                
                        Wrike_MetadataService.SaveResult result = results[0];
                        System.debug(Logginglevel.INFO, result);
                        
                        /* should we raise error here? */
                        //return result==null || result.success; 
                    }
                    /* else 
                        layout not loaded? */
                }

                String nextLayout = WrikeUpdate_Utils.getNextLayout(obj, layout);
                if (nextLayout != null) {
                    return WrikeUpdate_Utils.nextResponse(                    
                            'binding-' + obj + '-layout-' + nextLayout,
                            'Updating layout '+ nextLayout);
                }
                
                String nextObj = WrikeUpdate_Utils.getNextObject(obj);
                if (nextObj != null)
                    return WrikeUpdate_Utils.nextResponse('binding-' + nextObj + '-field',
                            'Creating relationship key field in '+ nextObj);
                else
                 //   return WrikeUpdate_Utils.lastResponse();
                   return WrikeUpdate_Utils.nextResponse('profiles','Restoring page access info for profiles');
            }
              
            else {
                return WrikeUpdate_Utils.unknownStepResponse;
            }
        }
        //profiles page accesses
        else if (step == 'profiles') {
            
            String current = '';
            String firstProfile = WrikeUpdate_Utils.getNextProfile(null);
            
            return WrikeUpdate_Utils.nextResponse('profiles-' + firstProfile, 'Restoring page access for ' + firstProfile);
    
        }     
        else if (step.startsWith('profiles-')) {
            
            String[] chunks = step.split('-', 2);
            String current = chunks[1];

            Map<String, Object> dataFields = (Map<String, Object>) JSON.deserializeUntyped(data);
            
            String result = '';
                  
            if(dataFields.containsKey('pagesFor')) {
                
                result = (String)dataFields.get('pagesFor');
                if(!String.isBlank(result)) {
                    WrikeUpdate_Utils.restoreProfileAccesses(current, result.split(','));
                }
            }

            String nextProfile = WrikeUpdate_Utils.getNextProfile(current);
            
            if(String.isBlank(nextProfile)) {
                return WrikeUpdate_Utils.lastResponse();
            }
            
            return WrikeUpdate_Utils.nextResponse('profiles-' + nextProfile, 'Restoring page access for ' + nextProfile);          
            }                   
        else {
            return WrikeUpdate_Utils.unknownStepResponse;
        }
        } catch(Exception ex) {
           return WrikeUpdate_Utils.errorResponse(ex.getMessage());
        } 
    }
    
}