public with sharing class WrikeUpdate_ExportController {
    
    @RemoteAction
    public static String init() {
        
        String obj = WrikeUpdate_Utils.getNextObject(null);
        
        return WrikeUpdate_Utils.nextResponse('info', 'Retrieving system info');

    }
    
    @RemoteAction
    public static String step(String step, String data) {
       
       try {
       // Info
        if (step == 'info') {
            //WrikeUpdate_Utils.getInstalledPackage();
            
            String info = '{ "created": ' + JSON.serialize(datetime.now()) + ' }';
                            
            return WrikeUpdate_Utils.nextDataResponse('settings', 'Retrieving package settings', info);
        }
       
       // Settings
        else if (step == 'settings') {
            
            List<String> fieldNames = Wrike_Dictionary.SETTINGS_FIELDS;
            Map<String,String> fieldsMap = new Map<String,String>();
            
            String query = 'Select '+
                String.join(fieldNames, ',')+
                ' From WrikeAccountSettings__c';
            System.debug(query);
                
            SObject[] records = WrikeUpdate_Utils.queryRecords(query);

            if (records == null)
                return WrikeUpdate_Utils.databaseErrorResponse;
            
            if (records != null && records.size() == 1) {
                for (String name: fieldNames) {
                    fieldsMap.put(name, (String) records[0].get(name));
                }            
                
                JSONGenerator generator = JSON.createGenerator(false);
                generator.writeObject(fieldsMap);
    
                String result = generator.getAsString();
                System.debug(result);
                
                return WrikeUpdate_Utils.nextDataResponse('apitokens', 'Retrieving Wrike API tokens', result);
                //return WrikeUpdate_Utils.lastDataResponse(result);
            }
            else {
                return WrikeUpdate_Utils.unknownStepResponse;
            } 
            
        } 
        
        // API tokens
        else if (step == 'apitokens') {

            String query = 'Select SetupOwnerId, RefreshToken__c From Wrike_API__c';
            SObject[] records = WrikeUpdate_Utils.queryRecords(query);
            
            if (records == null)
                return WrikeUpdate_Utils.databaseErrorResponse;
                
            List<String> tokens = new List<String>();
            
            for (SObject record: records) {
                tokens.add('{ "SetupOwnerId" : "'+ WrikeUpdate_Utils.getFieldValue(record, 'SetupOwnerId') +
                     +'", "RefreshToken__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'RefreshToken__c') + '" }');                
            }
            String result = '['+ String.join(tokens, ',') +']'; 
            
            return WrikeUpdate_Utils.nextDataResponse('templates', 'Retrieving folder templates', result);
        }
        
        else if (step == 'templates') {
        	
        	String query = 'Select Name, Description__c, Wrike_Folder_Name__c, Order__c,' + 
                       + 'Wrike_Folder_Id__c, Wrike_Folder_Permalink__c From Wrike_Folder_Template__c ORDER BY Order__c';
            SObject[] records = WrikeUpdate_Utils.queryRecords(query);
            System.debug('--templates: ' + records);
            if (records == null)
                return WrikeUpdate_Utils.databaseErrorResponse;
                
            List<String> tokens = new List<String>();
            
            for (SObject record: records) {
                tokens.add('{ "Name" : "'+ WrikeUpdate_Utils.getFieldValue(record, 'Name') +
                     +'", "Description__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'Description__c') + 
                     +'", "Wrike_Folder_Name__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'Wrike_Folder_Name__c') +
                     +'", "Order__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'Order__c') +
                     +'", "Wrike_Folder_Id__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'Wrike_Folder_Id__c') +
                     +'" , "Wrike_Folder_Permalink__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'Wrike_Folder_Permalink__c') + '"}');                
            }
            String result = '['+ String.join(tokens, ',') +']';
            System.debug(result);
            return WrikeUpdate_Utils.nextDataResponse('bindings', 'Retrieving linked objects list', result);
        }
        
        // Bindings
        if (step == 'bindings') {

            String query = 'Select Name, NameTemplate__c, ParentId__c, Rule__c, Type__c, Full_Name__c From Wrike_Bindings__c ORDER BY Name';
            SObject[] records = WrikeUpdate_Utils.queryRecords(query);
            
            if (records == null)
                return WrikeUpdate_Utils.databaseErrorResponse;
            
            List<String> tokens = new List<String>();
            
            for (SObject record: records) {
            	System.debug('--- binding ' + WrikeUpdate_Utils.getFieldValue(record, 'Name') + ': ' + record);
                tokens.add('{ "Name" : "'+ WrikeUpdate_Utils.getFieldValue(record, 'Name') +
                     +'", "Full_Name__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'Full_Name__c') +
                     +'", "NameTemplate__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'NameTemplate__c') +
                     +'", "ParentId__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'ParentId__c') + 
                     +'", "Rule__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'Rule__c') + 
                     +'", "Type__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'Type__c') + 
                     '" }');                
            }
            
            if (!records.isEmpty()) {
                String obj = (String) records[0].get('Full_Name__c');
                String result = '['+ String.join(tokens, ',') +']';
                
                System.debug(result);
                
                return WrikeUpdate_Utils.nextDataResponse('binding-' + obj + '-field',
                    'Looking for relationship key field in '+ obj, result);
            }
            else {
                return WrikeUpdate_Utils.lastDataResponse('[]');
            } 
        }
        //profiles page accesses
        else if (step == 'profiles') {
        	
        	String current = '';
        	String firstProfile = WrikeUpdate_Utils.getNextProfile(null);
        	
        	return WrikeUpdate_Utils.nextDataResponse('profiles-' + firstProfile, 'Retrieving page access for ' + firstProfile, '{}');
	
        }     
        else if (step.startsWith('profiles-')) {
            
            String[] chunks = step.split('-', 2);
            String current = chunks[1];
            
            
            List<String> bindingNames = new List<String>();
        
	        List<Wrike_Bindings__c> bindings = Wrike_Bindings__c.getAll().values();
	            
	        for(Wrike_Bindings__c binding : bindings)
	        {
	              bindingNames.add(binding.Full_name__c);
	        }           

            String result = '';

            List<String> bindingsWithAccess = WrikeUpdate_Utils.getProfileAccesses(current, bindingNames);
                
            if(bindingsWithAccess != null && bindingsWithAccess.size()>0) {
                   result = '{ "pagesFor" : "'+  String.join(bindingsWithAccess,',') +'" }';   
            } else result = '{}';
            
            String nextProfile = WrikeUpdate_Utils.getNextProfile(current);
            
            if(String.isBlank(nextProfile)) {
            	return WrikeUpdate_Utils.lastDataResponse(result);
            }
            
            return WrikeUpdate_Utils.nextDataResponse('profiles-' + nextProfile, 'Retrieving page access for ' + nextProfile, result);          
        }      
        // Fields and data
        else  if (step.startsWith('binding-')) {
            String[] chunks = step.split('-', 4);
            String obj = chunks[1];
            String substep = chunks[2];
            
            if (substep == 'field') {
                System.debug('field');
                
                return WrikeUpdate_Utils.nextDataResponse(                    
                    'binding-' + obj + '-data', 'Retrieving relationship data for '+ obj, '{}');
            }
            else if (substep == 'data') {
                
                String query = 'Select ID, Wrike_Folder_ID__c from ' + obj + ' Where Wrike_Folder_ID__c != \'\'';
                
                SObject[] records;
                
                try {
                    records = WrikeUpdate_Utils.queryRecords(query);
                } catch(Exception ex) {System.debug(ex);}
                
         /*       if (records == null)
                    return WrikeUpdate_Utils.databaseErrorResponse;*/
                List<String> tokens = new List<String>();
                if(records != null) {
	                
	                for (SObject record: records) {
	                    tokens.add('{' +
	                         ' "ID" : "'+ WrikeUpdate_Utils.getFieldValue(record, 'ID') +
	                         '", "Wrike_Folder_ID__c" : "'+  WrikeUpdate_Utils.getFieldValue(record, 'Wrike_Folder_ID__c') +
	                         '" }');                
	                }
                }
                String result = '['+ String.join(tokens, ',') +']';

                return WrikeUpdate_Utils.nextDataResponse(                    
                    'binding-' + obj + '-page', 'Verifying Visualforce page for '+ obj, result);                    
            }
            else if (substep == 'page') {
                
                String nextLayout = WrikeUpdate_Utils.getNextLayout(obj, null);
                
                if (nextLayout != null) {
                    return WrikeUpdate_Utils.nextDataResponse(                    
                            'binding-' + obj + '-layout-' + nextLayout,
                            'Retrieving data from layout '+ nextLayout, '{}');
                }
                
                String nextObj = WrikeUpdate_Utils.getNextObject(obj);
                
                if (nextObj != null)
                    return WrikeUpdate_Utils.nextDataResponse('binding-' + nextObj + '-field',
                            'Looking for relationship key field in '+ nextObj, '{}');
                else
                    return WrikeUpdate_Utils.lastDataResponse('{}');
            
            }
            else if (substep =='layout') {
                
                String layout = chunks[3];
                String[] objectLayoutNames = new String[] { layout };
     
                String apexPageName = WrikeUpdate_Utils.getTargetPageName(obj);
                
                Wrike_MetadataService.IMetadataPort service = WrikeUpdate_Utils.createService();
                Wrike_MetadataService.Layout[] layouts =
                        (Wrike_MetadataService.Layout[])
                        service.readMetadata('Layout', objectLayoutNames).getRecords();
                
                Map<String,Object> layoutInfo = new Map<String,Object>();        
                
                if (!layouts.isEmpty()) {
                    Wrike_MetadataService.Layout l = layouts[0];
                    
                    if(l.layoutSections != null) {
                        for(Integer s=0; s < l.layoutSections.size(); s++) {
                    
                            final Wrike_MetadataService.LayoutSection section = l.layoutSections[s];
                            if(section.layoutColumns != null) {
                                
                                for(Integer c=0; c < section.layoutColumns.size(); c++) {
                                    Wrike_MetadataService.LayoutColumn column = section.layoutColumns[c];
                                      
                                    if(column.layoutItems != null) {
                                        for(Integer i=0; i < column.layoutItems.size(); i++) {
                                            
                                            if(column.layoutItems[i].page_x == apexPageName) {
                                                layoutInfo.put('pageName', apexPageName); 
                                                layoutInfo.put('sectionIndex', s); 
                                                layoutInfo.put('columnIndex', c);
                                                layoutInfo.put('itemIndex', i);
                                                layoutInfo.put('itemWidth', column.layoutItems[i].width);
                                                layoutInfo.put('itemHeight', column.layoutItems[i].height);
                                                layoutInfo.put('itemShowLabel', column.layoutItems[i].showLabel);
                                                layoutInfo.put('itemShowScrollbars', column.layoutItems[i].showScrollbars);
                                            }
                                        }
                                    }
                                }
                            }
                             
                        }
                    }
                    
                    /* question: related list - do we need to look there? */
                }
                /* else
                    layout did not read! */
                
                String result = JSON.serialize(layoutInfo);

                String nextLayout = WrikeUpdate_Utils.getNextLayout(obj, layout);
                
                if (nextLayout != null) {
                    return WrikeUpdate_Utils.nextDataResponse(                    
                            'binding-' + obj + '-layout-' + nextLayout,
                            'Retrieving data from layout '+ nextLayout, result);
                }
                
                String nextObj = WrikeUpdate_Utils.getNextObject(obj);
                
                if (nextObj != null)
                    return WrikeUpdate_Utils.nextDataResponse('binding-' + nextObj + '-field',
                            'Looking for relationship key field in '+ nextObj, result);
                else
                   // return WrikeUpdate_Utils.lastDataResponse(result);
                    return WrikeUpdate_Utils.nextDataResponse('profiles','Retrieving page access info for profiles',result);
            
            }
            else {
                return WrikeUpdate_Utils.unknownStepResponse;
            }
        }

           else {
            return WrikeUpdate_Utils.unknownStepResponse;
        }
        } catch(Exception ex) {
           return WrikeUpdate_Utils.errorResponse(ex.getMessage());
        } 
    }   
}