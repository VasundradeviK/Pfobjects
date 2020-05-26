public with sharing class Wrike_TaskController extends Wrike_BaseTaskController {
    
    ApexPages.StandardController controller;
    
    /*****this constructor is not in use atm since mapping to individual tasks is not supported*****/
    public Wrike_TaskController(ApexPages.StandardController controller) {
        
        this.viewURL = controller.view().getUrl();
        this.controller = controller;
        
        controller.addFields(new List<String>{'Wrike_Task_ID__c', nameField });
        SObject record = controller.getRecord();        
        
        binding = Wrike_Bindings__c.getValues(Wrike_SchemaUtils.getObjectNameByID(record.Id));       
    }
    /********************************************************************************************/
    
    public Wrike_TaskController() {
        
        super();
        parentFolderId = binding.ParentId__c;
        DateInput = new Task();
        DateInput.ActivityDate = Date.today();
    }
    
    public Wrike_TaskController(String recordId) {
    	super(recordId);
    }

    public String taskId { get; private set; }
    
    public String taskStatus { get; private set; }
    
    private String folderId { get; set; }
    private String parentFolderId { get; set; }

    private String accountId { get; set; }

    public String taskPermalink { get; private set; }

    private String preloadedTaskJSON { get; set; }
    
    public String callbackUrl { get { return String.valueOf(back()); } }
    
    public Boolean getIsNewTask() {
    	return taskId == 'NEW';
    }
    
    public Task DateInput {get;set;}

    public PageReference ensureTask() {
        
        try {
 
             String action = Apexpages.currentPage().getParameters().get('action');
            if (action != null && action == 'create') {
                taskId = 'NEW';
                folderId = Apexpages.currentPage().getParameters().get('folder');
            } else if (action != null && action == 'edit') {
                taskId = Apexpages.currentPage().getParameters().get('task');
            } else {
        		return null;
            	/// this block is not in use since mapping to individual tasks is not supported
            	/*
                SObject record = controller.getRecord();
               
                if(!Wrike_PrivilegedUtils.hasWrikeTaskId(record.Id)) {
                    state = 'corrupted';
                    return null;
                }
                
                taskId = Wrike_PrivilegedUtils.getWrikeTaskId(record.Id);
        
                if(taskId == null || !matchesPattern(taskId, 16) ) {
                    //create one
    
                    String leadName = String.valueOf(record.get(nameField));
        
                    String newTaskJSON = wrikeApiPost('/folders/' +  
                        binding.ParentId__c + '/tasks ',
                        'title=' + EncodingUtil.urlEncode(leadName, 'UTF-8') +
                        '&dates=%7Btype%3D%22Backlog%22%3Bduration%3D480%7D',
                        ExceptionHandlingMode.NONE);
             
                    taskId = Wrike_JSONUtils.parseJSON(newTaskJSON, 'id');
                    if (taskId == null || !matchesPattern(taskId, 16)) {
                        state = 'corrupted';
                        return null;
                    } else {
                        Wrike_PrivilegedUtils.setWrikeTaskId(record.Id, taskId);
                        update record;
        
                        PageReference page = new PageReference(ApexPages.currentPage().getUrl());
                        page.setRedirect(true);
                        return page;
                    }
        
                }   
                */   
            }
            
            if (taskId != 'NEW') {
                
                preloadedTaskJSON = getTaskJSON();            
                
                Map<String, String> taskData = Wrike_JSONUtils.parseJSON(preloadedTaskJSON, 
                                                        new String[] {'id', 'status', 'accountId', 'permalink'});
                                                        
                taskStatus = taskData.get('status');
                accountId = taskData.get('accountId');
                taskPermalink = taskData.get('permalink');

                if(taskData.get('id') != taskId)
                    throw new Wrike_Exceptions.CorruptedSFSettingsException( 'Task IDs do not match.');
                if(!matchesPattern(accountId, 8))
                    throw new Wrike_Exceptions.CorruptedSFSettingsException('Wrike account ID is incorrect.');                                                            
                if (!taskPermalink.startsWith(WRIKE_DOMAIN + '/open.htm?'))
                    throw new Wrike_Exceptions.CorruptedSFSettingsException('Task permalink is invalid.');
            }
            return null;
        } catch(Exception ex) {
                return handleExceptionPageRef(ex); 
            }
    }

    public String getTaskJSON() {

        String json = preloadedTaskJSON != null ?
            preloadedTaskJSON : wrikeApiGet('/tasks/' + taskId, ExceptionHandlingMode.NONE);

        preloadedTaskJSON = null;
        return json;
    }

    public String getTaskCommentsJSON() {

        return wrikeApiGet('/tasks/' + taskId + '/comments', ExceptionHandlingMode.LOG);
    }

    public String getTaskAttachmentsJSON() {

        return wrikeApiGet('/tasks/' + taskId + '/attachments', ExceptionHandlingMode.LOG);
    }

    public PageReference back() {
        if (currentRecordId != null) {
            PageReference pageRef =  Page.Wrike_FolderView;
            pageRef.getParameters().put('currentRecordId', currentRecordId);
            pageRef.setRedirect(true);
            return pageRef;    
            
        } else {
            return null;
        }
    }
        
    public PageReference save() {
        
        try {
        
            String changeSet = Apexpages.currentPage().getParameters().get('changeSet');
                System.debug('--changeSet ' + changeSet);
            if (taskId == 'NEW') {
            	
            	String currentParentFolderId = parentFolderId;
            	String targetFolderId = folderId;
            	
            	Map<String, String> folders;
            	
            	if(String.isBlank(folderId)) {
            		
            		folders = restoreFolderTree(currentRecordId, binding);
            		
            		currentParentFolderId = folders.get('objectFolderId');

            		targetFolderId = createFolder(currentParentFolderId, getRecordName());
            	}
            	
                String response = wrikeApiPost('/folders/' + targetFolderId + '/tasks', changeSet, ExceptionHandlingMode.NONE);
                
                if(folders != null) {
                	saveRestoredTree(folders, objectName);
                }
                
                Wrike_PrivilegedUtils.setWrikeFolderId(currentRecordId, targetFolderId);
                
            } else {
                String response = wrikeApiPut('/tasks/' + taskId, changeSet, ExceptionHandlingMode.NONE);
                System.debug(response);
            }
             
             return back();
        } catch(Exception ex) {
                return handleExceptionPageRef(ex); 
            }
    }
    
    public PageReference complete() {
        
        try {

            String response = wrikeApiPut('/tasks/' + taskId, 'status=Completed', ExceptionHandlingMode.NONE);
            System.debug(response);
    
            return back();
        } catch(Exception ex) {
                return handleExceptionPageRef(ex); 
            }
    }
    
    public String getRecordName() {
    	return String.valueOf(getCurrentRecord().get(nameField));
    }

}