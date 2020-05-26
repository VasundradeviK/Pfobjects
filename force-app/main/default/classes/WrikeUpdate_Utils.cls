public class WrikeUpdate_Utils {

    
    public static String errorResponse(String error) {
        return '{ "error": "' + error + '" }';
    }
    
    public static String databaseErrorResponse = errorResponse('Database query error');
    
    public static String metadataErrorResponse = errorResponse('Metadata API call failed');
    
    public static String unknownStepResponse  = errorResponse('Unknown step');
    
    public static String nextResponse(String nextStep, String nextDescription) {
        return '{ "next": "'+ nextStep +'", "nextDescription": "'+ nextDescription + '" }';
    }
    
    public static String nextDataResponse(String nextStep, String nextDescription, String data) {
        return '{ "next": "'+ nextStep +'", "nextDescription": "'+ nextDescription + '", "data": ' + data + ' }';
    }
    
    public static String nextResponse(String nextStep, String nextDescription, String data) {
    	if(String.isBlank(data)) {
    		return nextResponse(nextStep, nextDescription);
    	}
        return '{ "next": "'+ nextStep +'", "nextDescription": "'+ nextDescription + '", "warnings": ' + data + ' }';
    }
    
    public static String lastResponse() {
        return '{}';
    }
    
    public static String lastDataResponse(String data) {
        return '{ "data": ' + data + ' }';
    }
    
    private static Wrike_MetadataService.IMetadataPort serviceInstance; 
    
    public static Wrike_MetadataService.IMetadataPort createService() {
        
        if (serviceInstance == null) {
            Wrike_MetadataService.MetadataPort port =
                    new Wrike_MetadataService.MetadataPort();
                    
            port.SessionHeader = new Wrike_MetadataService.SessionHeader_element();
            port.SessionHeader.sessionId = UserInfo.getSessionId();
            port.timeout_x = 60000;
            serviceInstance = port;
        }
        
        return serviceInstance;     
    }
    
    public static Wrike_MetadataService.IMetadataPort replaceService(
        Wrike_MetadataService.IMetadataPort service) {
        
        Wrike_MetadataService.IMetadataPort old = serviceInstance;
        serviceInstance = service;
        return old;
    }
    
    /*public static Boolean getInstalledPackage() {
        
        Wrike_MetadataService.MetadataPort service = createService();     
        Wrike_MetadataService.IReadResult result =        
            service.readMetadata(
                'InstalledPackage', new String[] { 'Wrike Integraion' });            
        
        System.debug(Logginglevel.INFO, result);
        
        //ReadInstalledPackageResult
        
        return true;
    }*/
    
    public static Boolean createCustomField(String objName) {
            
        String field = 'Wrike_Folder_ID';
        
        objName = verifyObjectName(objName);
                            
        Wrike_MetadataService.IMetadataPort service = createService();     
        Wrike_MetadataService.CustomField customField =
            new Wrike_MetadataService.CustomField();
        customField.fullName = objName + '.' + field + '__c';
        customField.label = field;
        customField.type_x = 'Text';
        customField.length = 42;
        List<Wrike_MetadataService.SaveResult> results =
                service.createMetadata(
                new Wrike_MetadataService.Metadata[] { customField });                
        
        Wrike_MetadataService.SaveResult result = results[0];
        System.debug(Logginglevel.INFO, result);

        return result==null || result.success;
    }
    
    public static Boolean deleteCustomField(String objName, Boolean forceDelete) {
            
        String field = 'Wrike_Folder_ID';
        
        if('Task'.equals(objName) || 'Event'.equals(objName))
        {
               Wrike_Bindings__c coupledBinding =  Wrike_Bindings__c.getValues('Task'.equals(objName) ? 'Event' : 'Task');
               if (coupledBinding != null && !forceDelete) return false;
               objName = 'Activity';
        }
                            
        Wrike_MetadataService.IMetadataPort service = createService();     
        List<Wrike_MetadataService.DeleteResult> results =
                service.deleteMetadata(
                    'CustomField', new String[] { objName + '.' + field + '__c' });            
        
        Wrike_MetadataService.DeleteResult result = results[0];
        System.debug(Logginglevel.INFO, result);
        
        return result==null || result.success;
    }
    
    public static String verifyObjectName(String objName) {
        if('Task'.equals(objName) || 'Event'.equals(objName)) objName = 'Activity';
        return objName;
    }


    public static Boolean createPage(String objName) {
            
            String sourcePageName = Wrike_Dictionary.SOURCE_PAGE_NAME;
            String controllerString = Wrike_Dictionary.FOLDER_CONTROLLER_NAME;
            
            String searchString = 'controller="' +  controllerString + '"';
            String replaceString = + 'standardController="'+ objName +'" '+
                'extensions="' +  controllerString + '"';
                
            String targetPageName = getTargetPageName(objName);
            
            Wrike_MetadataService.IMetadataPort service = createService();     
            Wrike_MetadataService.IReadResult readResult =        
                    service.readMetadata('ApexPage', new String[] { sourcePageName });
            Wrike_MetadataService.Metadata[] records = readResult.getRecords();

            if(records == null || records.isEmpty()) return false;
            
            Wrike_MetadataService.ApexPage sourcePage =
                    (Wrike_MetadataService.ApexPage) records[0];
            String source = EncodingUtil.base64Decode(sourcePage.content).toString(); 
            
            Integer i = source.indexOf(searchString); 
            if (i < 0) return false;
            
            Integer len = searchString.length();
            String modifiedSource =
                    source.substring(0, i) + replaceString + source.substring(i + len);
            
           // String targetPageName = Wrike_Dictionary.getTargetPageName(objName);
            String labelName = 'Wrike Tasks';

            Wrike_MetadataService.ApexPage apexPage = new Wrike_MetadataService.ApexPage();
            apexPage.apiVersion = 31;
            apexPage.fullName = targetPageName;
            apexPage.label = labelName;
            apexPage.content = EncodingUtil.base64Encode(Blob.valueOf(modifiedSource));
            List<Wrike_MetadataService.SaveResult> results = 
                    service.createMetadata(new Wrike_MetadataService.Metadata[] { apexPage });                
            
            Wrike_MetadataService.SaveResult saveResult = results[0];
            System.debug('--- VF page saveResult ' + saveResult);
            
            return saveResult==null || saveResult.success;
    }

    public static Boolean deletePage(String objName) {
        
        String targetPageName = getTargetPageName(objName);
        
        Wrike_MetadataService.IMetadataPort service = createService();
            
        List<Wrike_MetadataService.DeleteResult> results =        
                service.deleteMetadata(
                    'ApexPage', new String[] { targetPageName });              
        
        Wrike_MetadataService.DeleteResult result = results[0];
        System.debug(Logginglevel.INFO, result);
        
        return result==null || result.success;
    }
    
    public static String getTargetPageName(String objName) {

        return Wrike_Dictionary.getTargetPageName(objName);
    }

    public static Boolean insertRecord(SObject obj) {
        if (Test.isRunningTest()) {
            return true;
        }
        try {
            insert obj;
            return true;
        }
        catch (System.QueryException q) {
            return false;
        }
    }
    
    public static Boolean insertRecords(List<SObject> objs) {
        if (Test.isRunningTest()) {
            return true;
        }
        try {
            insert objs;
            return true;
        }
        catch (System.QueryException q) {
            return false;
        }
    }
    
    public static Boolean updateRecords(List<SObject> objs) {
        if (Test.isRunningTest()) {
            return true;
        }
        try {
            
            /*update objs;*/
            
            Database.DMLOptions dmo = new database.DMLOptions();
            dmo.optAllOrNone = false;
            Database.SaveResult[] sr = Database.update(objs,dmo);
            return true;
        }
        catch (System.QueryException q) {
            return false;
        }
    }
    
    public static Map<Id, String> updateRecordsAndReturnFails(List<SObject> objs) {
    	
    	Map<Id, String> updateFails = new Map<Id, String>();
    	
        if (Test.isRunningTest()) {
            return updateFails;
        }
        try {

            Database.DMLOptions dmo = new database.DMLOptions();
            dmo.optAllOrNone = false;
            Database.SaveResult[] saveResults = Database.update(objs,dmo);
            
            for(Integer i = 0; i < saveResults.size(); i++)
		    {

		      if(!saveResults[i].isSuccess()) {
		        String failReasons = '';
		        for(Database.Error err: saveResults[i].getErrors()) { failReasons = (failReasons == '' ? err.getMessage() : ', ' + err.getMessage());}
		        updateFails.put(objs[i].Id,failReasons);      
		      }
		    }
            
            return updateFails;
        }
        catch (Exception ex) {
            return updateFails;
        }
    }
    
    public static Boolean deleteRecords(List<SObject> objs) {
        if (Test.isRunningTest()) {
            return true;
        }
        try {
            delete objs;
            return true;
        }
        catch (System.QueryException q) {
            return false;
        }
    }
    
    public static List<SObject> queryRecords(String query) {
        if (Test.isRunningTest()) {
            return new List<SObject>();
        }
        try {
            return Database.query(query);
        }
        catch (System.QueryException q) {
        	System.debug(q);
            return null;
        }
    }
            
    public static String getNextObject(String current) {
        
        if (current == null && Test.isRunningTest())
            return 'test';
        
        String query = 'Select Full_Name__c From Wrike_Bindings__c order by Name asc';
        
        try {
            SObject[] records = Test.isRunningTest()? new List<SObject>() :
                Database.query(query);
        
            Integer i = 0;
            String last = null;
            while (i < records.size()) {
                if (last == current) {
                    return (String) records[i].get('Full_Name__c');
                }
                last = (String) records[i].get('Full_Name__c');
                i++;
            }
        }
        catch (System.QueryException q) {
        } 
        
        return null;
    }
    
    
     public static String getNextLayout(String obj, String current) {
        
        if (current == null && Test.isRunningTest())
            return 'test layout';
            
        Wrike_MetadataService.IMetadataPort service = createService();
        
         Wrike_MetadataService.ListMetadataQuery layoutQuery =
             new Wrike_MetadataService.ListMetadataQuery();             
        layoutQuery.type_x = 'Layout';
        
        Wrike_MetadataService.FileProperties[] layoutMetaList =
                service.listMetadata(
                    new List<Wrike_MetadataService.ListMetadataQuery> { layoutQuery }, 31);
        
        List<String> objectLayoutNames = new List<String>();
        for(Wrike_MetadataService.FileProperties layoutMeta : layoutMetaList) {
            if(layoutMeta.fullName.startsWith(obj + '-')) {
                objectLayoutNames.add(layoutMeta.fullName);
            }    
        }
        objectLayoutNames.sort();
            
        String last = null;
        System.debug(current);
        
        for (String layoutName : objectLayoutNames) {
            System.debug(layoutName);
            if (last == current) {
                return (String) layoutName;
            }
            last = (String) layoutName;
        }

        return null;
    }
    
    public static String getNextProfile(String current) {

        List<String> profileNames = getApiProfileList();
        if(profileNames == null || profileNames.size() == 0) return null;
        
        if(current == null) return profileNames[0];
        
        for(Integer i = 0; i < profileNames.size(); i++) {
        	if(current == profileNames[i] &&  (i < profileNames.size()-1)) {
        		return profileNames[i+1];
        	}
        }
        
        return null;
    }

    public static List<String> getApiProfileList() {
    	
    	List<String> profileNames = new List<String>();
    	
    	Wrike_MetadataService.ListMetadataQuery query = new Wrike_MetadataService.ListMetadataQuery();    
    	query.type_x = 'Profile';
    	double asOfVersion = 31.0;
    	
    	Wrike_MetadataService.IMetadataPort service = createService();
    	
    	Wrike_MetadataService.FileProperties[] lmr = service.listMetadata(
    	   new Wrike_MetadataService.ListMetadataQuery[] {query}, asOfVersion);
    	   
    	if(lmr!=null) {
    		for (Wrike_MetadataService.FileProperties n : lmr) {
    			
    			profileNames.add(n.fullName);
    		}  
    		
    		profileNames.sort(); 		
    	}
    	return profileNames;     	
    }

    public static List<String> getProfileAccesses(String profileName, List<String> bindingFullNames) {
    	
    	List<String> bNames = new List<String>();
        
        if(!String.isBlank(profileName)) {
            Wrike_MetadataService.IMetadataPort service = createService();     
            Wrike_MetadataService.IReadResult readResult =        
                    service.readMetadata('Profile', new String[] { profileName });
            Wrike_MetadataService.Metadata[] records = readResult.getRecords();
            
           Wrike_MetadataService.Profile p = (Wrike_MetadataService.Profile)records[0];

           if(p.pageAccesses == null) return bNames;
           
           Wrike_MetadataService.ProfileApexPageAccess[] pas = p.pageAccesses;
           
           Map<String, String> bindingPages = new Map<String, String>();
           for(String bfn : bindingFullNames) {
                    String pageName =  getTargetPageName(bfn);
                    bindingPages.put(pageName, bfn);
           }
           
           for(Wrike_MetadataService.ProfileApexPageAccess pa : pas) {
            
                if(pa.enabled && bindingPages.keySet().contains(pa.apexPage)) {
                    bNames.add(bindingPages.get(pa.apexPage));
                }
           }
       }
       return bNames;
    }
    
    public static void restoreProfileAccesses(String profileName, List<String> bindingFullNames) {
        
        if(!String.isBlank(profileName)) {
            Wrike_MetadataService.IMetadataPort service = createService();     
            Wrike_MetadataService.IReadResult readResult =        
                    service.readMetadata('Profile', new String[] { profileName });
            Wrike_MetadataService.Metadata[] records = readResult.getRecords();
            
           Wrike_MetadataService.Profile p = (Wrike_MetadataService.Profile)records[0];
           
           System.debug('--- tabVisibilities: ' + p.tabVisibilities);
           p.tabVisibilities = new Wrike_MetadataService.ProfileTabVisibility[] {};
           
           for(String bfn : bindingFullNames) {
                String pageName =  getTargetPageName(bfn);
                
                System.debug('----profle: ' +profileName+', page:  ' + pageName);
                
                Boolean isPageEnabled = false;
                for(Wrike_MetadataService.ProfileApexPageAccess pa : p.pageAccesses) {

                    if(pa.apexPage == pageName) {
                        pa.enabled = true;
                        isPageEnabled = true;
                        break;
                    }
                }
                if(!isPageEnabled) {
                	Wrike_MetadataService.ProfileApexPageAccess pap = new Wrike_MetadataService.ProfileApexPageAccess();
                	pap.apexPage = pageName;
                	pap.enabled = true;
                	p.pageAccesses.add(pap);
                }
           }

           Wrike_MetadataService.UpsertResult[] sr = service.upsertMetadata(new Wrike_MetadataService.Metadata[] {p});
           if(sr!=null) {
           	    System.debug('----sr error ' + sr[0].errors);
           }  
       }
    }
    
    public static String getObjectLabel(String obj) {
        
        if (Test.isRunningTest()) {
            return 'Test';
        }
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(obj);
        return objType.getDescribe().getLabel();
    }
    
    public static String getFieldValue(SObject record, String fieldName) {
    	// workaround for getting 'null' string values for fields
    	String val = record.get(fieldName)==null? '' : String.valueOf(record.get(fieldName));
    	val = (val == null || val == 'null') ? '' : val;
    	return val;
    }

}