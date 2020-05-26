public with sharing class Wrike_TemplateWizardController extends Wrike_TemplateBaseController {

public Wrike_TemplateWizardController() {

    super(5);

    DateInput = new Task();
    DateInput.ActivityDate = Date.today();
    
    currentRecordId =  ApexPages.currentPage().getParameters().get('currentRecordId');
    helper = new Wrike_TaskController(currentRecordId);
}

private Wrike_TaskController helper;
private String currentRecordId;  

public Task DateInput {get;set;}

private String extractDate() {
    Date dInputDate = DateInput.ActivityDate;

    DateTime dtValue = DateTime.newInstance(dInputDate.year(), dInputDate.month(), dInputDate.day());
    return dtValue == null ? '' : dtValue.format('yyyy-MM-dd');

}

public PageReference verifyWrike() {
    
    try {
        isUser();
        return null;
    } catch(Exception ex) { 
        return handleExceptionPageRef(ex); 
    }
}

public Boolean canManageTemplates {get { return isAdministrator(); }}

public string templateFolderId {get; private set;}
public string targetFolderId {get;private set;}

public PageReference saveFolderId() {
	
	templateFolderId = '';
	clearErrors();
	
	try {
	
		String fid = Apexpages.currentPage().getParameters().get('templateFolderId');
		String tname = Apexpages.currentPage().getParameters().get('templateName');

	    checkFolderCanBeCopied(fid, tname);
	     
	    templateFolderId = fid;
	     
	    return null;

	} catch(Exception ex) { 
        return handleExceptionPageRef(ex); 
    }
}


public String getFolderTasksJSON() {
	
	try {
		
		String folderBody = '';
		
		if(!String.isBlank(templateFolderId)) {

			folderBody = WrikeApiGet('/folders/'+templateFolderId+'/tasks/?fields=["responsibleIds"]&descendants=true', ExceptionHandlingMode.NONE);
		}
		return folderBody;
		
	} catch(Exception ex){
		handleException(ex, ExceptionHandlingMode.FULL);
		return null;
	}
}


public PageReference createTasks() { 
    
    try {
    
        String templateId = Apexpages.currentPage().getParameters().get('templateId');
        String assigneeId = Apexpages.currentPage().getParameters().get('assigneeId');
        String assignOption = Apexpages.currentPage().getParameters().get('assignOption');
        String dateOption = Apexpages.currentPage().getParameters().get('dateOption');
        String formattedDate = extractDate();
        
        if(String.isBlank(templateId) || String.isBlank(dateOption) || String.isBlank(formattedDate)) {
             throw new Wrike_Exceptions.CorruptedSFSettingsException('Template info is missing. Please try again.');
        }
        
        Wrike_Folder_Template__c currentTemplate = [select Id, Name, Description__c, Wrike_Folder_Name__c, Order__c, Wrike_Folder_Id__c from Wrike_Folder_Template__c where Id =: templateId];
        
        String folderTitle = String.format('{0} - {1}', 
                       new String[] {helper.getRecordName(), currentTemplate.Name});
                       
        folderTitle = EncodingUtil.urlEncode(folderTitle, 'UTF-8');
    
        String paramsTemplate = 'parent={0}&title={1}&rescheduleDate={2}&rescheduleMode={3}&copyCustomStatuses=false&copyStatuses=false';
        
        Map<String, String> folders = helper.restoreFolderTree(currentRecordId, helper.binding);
        
        String params = String.format(paramsTemplate, 
                       new String[] {folders.get('objectFolderId'), folderTitle, formattedDate, dateOption});     
                           
        if(assignOption != 'copy') {
            params+= '&copyResponsibles=false';
        }
        
        if(!String.isBlank(assigneeId)) {
        	 params+= '&addResponsibles=["' + assigneeId + '"]';
        }
        
        System.debug('--params ' + params);
    
        String folderBody = wrikeApiPost('/internal/copy_folder/'+ currentTemplate.Wrike_Folder_Id__c, 
                                   params, ExceptionHandlingMode.NONE);
        
        System.debug('--folderBody ' + folderBody);
        
        String targetFolderId = Wrike_JSONUtils.parseJSON(folderBody, 'id');

        helper.saveRestoredTree(folders, helper.objectName);
        Wrike_PrivilegedUtils.setWrikeFolderId(currentRecordId, targetFolderId);

            this.targetFolderId = targetFolderId;
            
            return null;
    } catch(Exception ex) { 
        return handleExceptionPageRef(ex); 
        }
}

}