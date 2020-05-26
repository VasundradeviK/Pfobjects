global with sharing class WrikeUpdate_CleanController {
    
    @RemoteAction
    global static String init() {
        
        String obj = WrikeUpdate_Utils.getNextObject(null);
        if (obj == null) {
            return WrikeUpdate_Utils.nextResponse('bindings', 'Cleaning linked objects list');
        }

        String nextLayout = WrikeUpdate_Utils.getNextLayout(obj, null);
        if (nextLayout != null) {
            return WrikeUpdate_Utils.nextResponse(                    
                    'binding-' + obj + '-layout-' + nextLayout,
                    'Removing Visualforce page from layout '+ nextLayout);
        }
        
        return WrikeUpdate_Utils.nextResponse('binding-' + obj + '-page',
                'Deleting Visualforce page for '+ obj);
    }
    
    @RemoteAction
    global static String step(String step, String data) {
        
        try {
        // Fields and data
        if (step.startsWith('binding-')) {
            String[] chunks = step.split('-',4);
            String obj = chunks[1];
            String substep = chunks[2];
            
            if (substep == 'layout') {
                String layout = chunks[3];
                String[] objectLayoutNames = new String[] { layout };
                
                String label = WrikeUpdate_Utils.getObjectLabel(obj);                
                
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
                                                  column.layoutItems.remove(i);
                                                  
                                                  List<Wrike_MetadataService.SaveResult> results =
                                                          service.updateMetadata(layouts);
                                                
                                                Wrike_MetadataService.SaveResult result = results[0];
                                                System.debug(Logginglevel.INFO, result);
                                                
                                                /* should we raise error here? */
                                                //return result==null || result.success;
                                                
                                                c = section.layoutColumns.size();
                                                s = l.layoutSections.size();
                                                break;
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
                            
                String nextLayout = WrikeUpdate_Utils.getNextLayout(obj, layout);
                if (nextLayout != null) {
                    return WrikeUpdate_Utils.nextResponse(                    
                            'binding-' + obj + '-layout-' + nextLayout,
                            'Removing Visualforce page from layout '+ nextLayout);
                }
                return WrikeUpdate_Utils.nextResponse('binding-' + obj + '-page', 'Deleting Visualforce page for '+ obj);
            }
            else
            if (substep == 'page') {
                    
                WrikeUpdate_Utils.deletePage(obj);
                
                /*if (! WrikeUpdate_Utils.deletePage(obj, label)) {                    
                    return '{"error": "Metadata API call failed" }';
                }*/
                
                return WrikeUpdate_Utils.nextResponse('binding-' + obj + '-data', 'Cleaning relationship data for '+ obj);            
            }
            else if (substep == 'data') {
                
                return WrikeUpdate_Utils.nextResponse('binding-' + obj + '-field', 'Removing relationship key field in '+ obj);
            }
            else if (substep == 'field') {
                
                WrikeUpdate_Utils.deleteCustomField(obj, true); 
                
                /*if (! WrikeUpdate_Utils.deleteCustomField(obj)) {                    
                    return '{"error": "Metadata API call failed" }';
                }*/
                
                obj = WrikeUpdate_Utils.getNextObject(obj);
                if (obj == null) {
                    return WrikeUpdate_Utils.nextResponse('bindings', 'Cleaning linked objects list');
                }
                
                String nextLayout = WrikeUpdate_Utils.getNextLayout(obj, null);
                if (nextLayout != null) {
                    return WrikeUpdate_Utils.nextResponse(                    
                            'binding-' + obj + '-layout-' + nextLayout,
                            'Removing Visualforce page from layout '+ nextLayout);
                }
                return WrikeUpdate_Utils.nextResponse('binding-' + obj + '-page',
                        'Deleting Visualforce page for '+ obj);
                
                    
            }
            else {
                return WrikeUpdate_Utils.unknownStepResponse;
            }
        }
        
        // Bindings
        else if (step == 'bindings') {

            String query = 'Select Full_Name__c From Wrike_Bindings__c';
            
            SObject[] records = WrikeUpdate_Utils.queryRecords(query);
            
            if (records == null ||
                    (records.size() > 0 && ! WrikeUpdate_Utils.deleteRecords(records)))             
                return WrikeUpdate_Utils.databaseErrorResponse;
            
            return WrikeUpdate_Utils.nextResponse('apitokens', 'Deleting Wrike API tokens');
        }
        
        // API tokens
        else if (step == 'apitokens') {

            String query = 'Select SetupOwnerId From Wrike_API__c';
            SObject[] records = WrikeUpdate_Utils.queryRecords(query);
            
            if (records == null ||
                    ! WrikeUpdate_Utils.deleteRecords(records))
                return WrikeUpdate_Utils.databaseErrorResponse;
            
            return WrikeUpdate_Utils.nextResponse('templates', 'Deleting folder templates');
        }
        
        else if (step == 'templates') {

            String query = 'Select Id from Wrike_Folder_Template__c';
            SObject[] records = WrikeUpdate_Utils.queryRecords(query);
            
            if (records == null ||
                    (records.size() > 0 && ! WrikeUpdate_Utils.deleteRecords(records)))
                return WrikeUpdate_Utils.databaseErrorResponse;
            
            return WrikeUpdate_Utils.nextResponse('settings', 'Deleting package settings');
        }
        
        // Settings
        else if (step == 'settings') {
            
            String query = 'Select Id From WrikeAccountSettings__c';
            SObject[] records = WrikeUpdate_Utils.queryRecords(query);
            
            if (records == null) {
                query = 'Select Id From Wrike_Settings__c';
                records = WrikeUpdate_Utils.queryRecords(query);
            }
            
            if (records == null ||
                    ! WrikeUpdate_Utils.deleteRecords(records))
                return WrikeUpdate_Utils.databaseErrorResponse;
            
            return WrikeUpdate_Utils.lastResponse();
        }
    
        else {
            return WrikeUpdate_Utils.unknownStepResponse;
        }
        } catch(Exception ex) {
           return WrikeUpdate_Utils.errorResponse(ex.getMessage());
        }
    }
}