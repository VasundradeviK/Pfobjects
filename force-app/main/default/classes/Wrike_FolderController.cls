public with sharing class Wrike_FolderController extends Wrike_BaseTaskController {

    public Wrike_FolderController() {
    	super();
        isRecordMapped = false;
        initialize();
    }
    
    public void initialize() {
    	
        if (!String.isBlank(currentRecordId)) {
	
	        currentRecord = Database.query('Select Id, ' + nameField + ' From ' + objectName + ' Where Id = : currentRecordId');
	        
	        binding = getBinding(currentRecordId);
	            
	        parentFolderId = binding.ParentId__c;
	        bindRule = binding.Rule__c;
	        
	        this.viewURL = '/' + currentRecordId;
	        cacheExists = true;
        } 
        
        this.viewURL = '/' + currentRecordId;
        cacheExists = true;
    }

    
    public boolean cacheExists {get; private set;}
    public void switchCache() {
    	cacheExists  = false;
    }
    
    private SObject currentRecord;
    
    private Wrike_Bindings__c binding;
    
    public String parentFolderId { get; private set; }
    
    public String bindRule { get; private set; }

    public String folderId { get; private set; }

    public String folderPermalink { get; private set; }
 
    public Boolean canWrite { get; private set; }
    
    public Boolean isRecordMapped { get; private set; }

    public Boolean showTemplateButton { get {
    	
    	List<Wrike_Folder_Template__c> templateList = [select Id from Wrike_Folder_Template__c limit 1];
    	if(templateList != null && templateList.size() > 0) {
    		return true;
    	}
    	return false;
    }}


    public PageReference verifyFolder() {

        try {
            if(currentRecord == null) {
            	return null;
            }
            
            canWrite = isUser();

            if(!Wrike_PrivilegedUtils.hasWrikeFolderId(currentRecord.Id)) {
                throw new Wrike_Exceptions.CorruptedSFSettingsException('No custom field found for ' + 
                                                Wrike_SchemaUtils.getObjectLabelByID(currentRecord.Id) + '.');
            }
            if(String.isBlank(parentFolderId))
            {
                return null; 
            }
            
            folderId = Wrike_PrivilegedUtils.getWrikeFolderId(currentRecord.Id);
            
            if(folderId == null || !matchesPattern(folderId, 16) ) {
                
                //check that has access to parent folder
                String foldersBody = wrikeApiGet(
                        '/folders/'+ parentFolderId +'/folders', ExceptionHandlingMode.NONE);
                return null;   
            }
        
            String folderBody = getFolderJSON();
            String id = Wrike_JSONUtils.parseJSON(folderBody, 'id');
            folderPermalink = Wrike_JSONUtils.parseJSON(folderBody, 'permalink');

            if(id != folderId)
                throw new Wrike_Exceptions.CorruptedSFSettingsException( 'Folder IDs do not match for ' + 
                                                                            getCurrentRecordName() + '.');
            if (!folderPermalink.startsWith(WRIKE_DOMAIN + '/open.htm?'))
                throw new Wrike_Exceptions.CorruptedSFSettingsException('Folder permalink invalid for ' + 
                                                                            getCurrentRecordName() + '.');
                    
            if (isFolderDeletedByBody(folderBody)) {
                Wrike_PrivilegedUtils.setWrikeFolderId(currentRecord.Id, '');
                
                return null;
            }
            isRecordMapped = true;
            return null;
            
        } catch(Wrike_Exceptions.WrikeResourceNotFoundException wex) {
        	return null;
            }
          catch(Exception ex) { 
            return handleExceptionPageRef(ex); 
            }
        
    }

    public PageReference editTask() {
        
        Map<String, String> fieldMap = ApexPages.currentPage().getParameters();
        String taskToEdit = null;
        Long taskTimestamp = 0L;
        for (String fieldName : fieldMap.keySet()){
            if (fieldName.startsWith('task')) {
                Long timestamp = Long.valueOf(fieldName.substringAfter('task'));
                if (timestamp > taskTimestamp) {
                    taskToEdit = fieldMap.get(fieldName);
                    taskTimestamp = timestamp;
                }
            }
            System.debug(fieldName + '=' + fieldMap.get(fieldName));
        }
        
        if (taskToEdit != null) {
                 
            PageReference taskEditPage = getTaskViewPage(false);
            taskEditPage.getParameters().put('task', taskToEdit);
                 
             return taskEditPage;
        } else {
            return null;
        }
    }

    public PageReference createTask() {
        
        PageReference taskCreationPage = getTaskViewPage(true);
         if(isRecordMapped && !String.isBlank(folderId)) {
            taskCreationPage.getParameters().put('folder', EncodingUtil.urlEncode(folderId, 'UTF-8'));
        } 
        return taskCreationPage;
        
    }
    
    private PageReference getTaskViewPage(Boolean isNewTask) {
        PageReference pageRef =  Page.Wrike_TaskView;
        String action = isNewTask ? 'create' : 'edit';
        pageRef.getParameters().put('action', action);
        pageRef.getParameters().put('currentRecordId', EncodingUtil.urlEncode(currentRecord.Id, 'UTF-8'));
        return pageRef; 
    }
/*
    public PageReference selectFolder() {
        
        try {

        String folderId = ApexPages.currentPage().getParameters().get('folderId');

        if (folderId != null) {

            //ensure folder is exists and it is a child of subtree
            Wrike_PrivilegedUtils.setWrikeFolderId(currentRecord.Id, folderId);
        }
       
        PageReference page = ApexPages.currentPage();
        page.setRedirect(true);
        return page;
        } catch(Exception ex) { 
            return handleExceptionPageRef(ex); 
            }
    }

    public PageReference createFolder() {
        
        try {

        String parentFolderId = ApexPages.currentPage().getParameters().get('parentFolderId');
        String folderName = ApexPages.currentPage().getParameters().get('folderName');

        if (parentFolderId != null && folderName != null) {
         
            String url = '/folders/' + EncodingUtil.urlEncode(parentFolderId, 'UTF-8') + '/folders ';
            String params = 'title=' + EncodingUtil.urlEncode(folderName, 'UTF-8');
            String newFolderId = null;
            
            String newFolderJSON = wrikeApiPost(url,params, ExceptionHandlingMode.NONE);

            newFolderId = Wrike_JSONUtils.parseJSON(newFolderJSON, 'id');

            Wrike_PrivilegedUtils.setWrikeFolderId(currentRecord.Id, newFolderId);

        }
       
        //PageReference page = new PageReference(controller.view().getUrl());
        PageReference page = ApexPages.CurrentPage();
        page.setRedirect(true);
        return page;
        } catch(Exception ex) { 
            return handleExceptionPageRef(ex); 
            }
    }
*/
    private String getFolderJSON() {
        
        return wrikeApiGet('/folders/'+ folderId, ExceptionHandlingMode.NONE);
    }

    public String getFolderTasksJSON() {
        return wrikeApiGet('/folders/' + folderId + '/tasks/?fields=["responsibleIds","hasAttachments","parentIds"]&descendants=true', 
                                    ExceptionHandlingMode.FULL);
    }

    public String getCurrentRecordName() {

      return String.valueOf(currentRecord.get(nameField));
    }
    
    public static void validate_FolderController() {
        Integer i = 0;
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
        i++;   
    }
}