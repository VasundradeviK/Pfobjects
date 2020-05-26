public abstract class Wrike_BaseTaskController extends Wrike_AbstractSectionController {
    
    public Wrike_BaseTaskController() {
    	
    	try {

	        String recordId =  ApexPages.currentPage().getParameters().get('currentRecordId');
	        if(!String.isBlank(recordId)) {
	            this(recordId);
	        } else {
	            throw new Wrike_Exceptions.SalesforceAccessDeniedException();
	        }
    	} catch(Exception ex){
            handleException(ex, ExceptionHandlingMode.FULL);
    	}
    }
    
    public Wrike_BaseTaskController(String recordId) {
        
        currentRecordId = recordId;
        binding = getBinding(currentRecordId);
        if(binding != null) {           
            objectName = binding.Full_Name__c;
            nameField = Wrike_SchemaUtils.getNameFieldByID(currentRecordId);
            System.debug('--nameField ' + nameField);
        }
    }
    
    
    public String currentRecordId {get; private set;}
    public Wrike_Bindings__c binding;
    protected String nameField = 'Name';
    public String objectName;
    
    protected Wrike_Bindings__c getBinding(Id recordId) {
        
        return Wrike_PrivilegedUtils.getBindingByObjectName(Wrike_SchemaUtils.getObjectNameByID(recordId));
    }
    
    protected SObject getCurrentRecord() {
        return Database.query('Select Id, ' + nameField + ' From ' + objectName + ' Where Id = : currentRecordId');
    }
    
    public String getWorkflowsJSON() {
        
        return wrikeApiGet('/accounts/' + getWrikeAccountId() + '/workflows', ExceptionHandlingMode.LOG);
    }
    
    public Map<String, String> restoreFolderTree(String recordId, Wrike_Bindings__c objBinding) {
        
        String salesforceFolderId = getSalesforceFolderId();
        String objectFolderId = objBinding.ParentId__c;
        
        if(isFolderDeleted(salesforceFolderId)) {
            salesforceFolderId = createSalesforceFolder(getWrikeAccountId());   
            objectFolderId = '';                  
        }
        
        if (String.isBlank(objectFolderId) || isFolderDeleted(objectFolderId)) {
            objectFolderId = createFolder(salesforceFolderId, 
                         Wrike_SchemaUtils.getPluralLabelByName(binding.Full_Name__c ));
        }
                                                       
        if(String.isBlank(objectFolderId) || String.isBlank(salesforceFolderId)) {
            throw new Wrike_Exceptions.CorruptedWrikeSettingsException('Failed to restore folder tree in Wrike.');
        }                                                      
        return new Map<String, String> {'objectFolderId' => objectFolderId, 
                                                       'salesforceFolderId' => salesforceFolderId};
    }
    
    public void saveRestoredTree(Map<String, String> folders, String objectName) {
        
        Wrike_PrivilegedUtils.updateBindedFolder(objectName, folders.get('objectFolderId'));
        Wrike_PrivilegedUtils.updateSalesforceFolder(folders.get('salesforceFolderId'));
    }
    
}