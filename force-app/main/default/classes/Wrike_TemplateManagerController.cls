public with sharing class Wrike_TemplateManagerController extends Wrike_TemplateBaseController {
    
    public Wrike_TemplateManagerController() {
        
        super(10);
        templates = [select Id, Name from Wrike_Folder_Template__c ORDER BY Order__c ASC];
        
        String templateId = Apexpages.currentPage().getParameters().get('templateId');
        
        if(!String.isBlank(templateId)) {
            
          if(templateId != 'NEW') {
            currentTemplate = getTemplateById(templateId);
          } else {
            currentTemplate = new Wrike_Folder_Template__c();
          }
            editMode = true;
        } else {
        	
            editMode = false;
            
            if(Apexpages.currentPage().getParameters().get('showSort') !=null) {
                showSort = true;
            }
        }
        
        saveComplete = false;
    }

    public Wrike_Folder_Template__c currentTemplate {get; private set;}
    public List<Wrike_Folder_Template__c> templates {get; private set;}
    
    public Boolean editMode {get; private set;}
    
    public Boolean showSort {get; private set;}
    public Boolean showSortButton {get {return templates.size() > 1;}}
    
    public Boolean saveComplete {get; private set;}
    
    public String getTemplatesJSON() {
    	
    	JSONGenerator generator = JSON.createGenerator(false);
	    generator.writeObject(templates);
	    return generator.getAsString();
    }

    public PageReference saveTemplate() {
        
     try {
        
        if(currentTemplate.Order__c == null) {
          currentTemplate.Order__c = templates.size();
        }
        
        String fname = Apexpages.currentPage().getParameters().get('folderName');
        String fid = Apexpages.currentPage().getParameters().get('folderId');
        String tname = Apexpages.currentPage().getParameters().get('templateName');
        
        fname = String.isBlank(fname) ? currentTemplate.Wrike_Folder_Name__c : fname;
        
        if(String.isBlank(fid) || String.isBlank(fname))
          throw new Wrike_Exceptions.CorruptedSFSettingsException('Folder info is missing. Please re-enter folder data.');
        
        currentTemplate.Name = tname;
        
        checkFolderCanBeCopied(fid, currentTemplate.Name);

        currentTemplate.Wrike_Folder_Permalink__c = shareFolderAndGetPermalink(fid);
              
        currentTemplate.Wrike_Folder_Name__c = fname;
        currentTemplate.Wrike_Folder_Id__c = fid;
                
        upsert currentTemplate;
        
        saveComplete = true;

        return null;
     } catch(Exception ex) { 
     	System.debug('---ex ' + ex);
            return handleExceptionPageRef(ex); 
        //  throw ex;
        }
        
    }
    
    private String shareFolderAndGetPermalink(String folderId) {

        String sharedId = getMyTeamId(getWrikeAccountId());
        String params = String.isBlank(sharedId) ? '' : 'addShareds=["'+ sharedId +'"]';

        String folderBody = wrikeApiPut('/folders/'+ folderId, params, ExceptionHandlingMode.NONE);
        return Wrike_JSONUtils.parseJSON(folderBody, 'permalink');
    }
    
    public PageReference refreshPage() {
        
        PageReference pageRef = Page.Wrike_TemplateManager;
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    private void updateFolderSharing(String folderId) {
    	//share with myteam
    	String sharedId = getMyTeamId('accountId');
    }
    
    public PageReference deleteTemplate() {
    	
    	try {
        
	        String templateId = Apexpages.currentPage().getParameters().get('templateId');
	        if(!String.isBlank(templateId)) {
	          currentTemplate = [select Id, Name, Description__c, Wrike_Folder_Name__c, Order__c, Wrike_Folder_Id__c from Wrike_Folder_Template__c where Id =: templateId];
	          delete currentTemplate;
	        }
	        
	        return refreshPage();
    	} catch(Exception ex) { 
            return handleExceptionPageRef(ex); 
        }
    }
    
    public String getFolderTreeJSON() {
        
        return wrikeApiGet('/accounts/' + getWrikeAccountId() +'/folders', ExceptionHandlingMode.FULL);
    }
    
    public PageReference saveSorting() {
    	
    	try {
        
	        String[] templateIds = Apexpages.currentPage().getParameters().get('templateIds').split(',');
	        System.debug('---templateIds : ' + Apexpages.currentPage().getParameters().get('templateIds'));
	        
	        if(templateIds.size() != templates.size()) {
	            throw new Wrike_Exceptions.CorruptedSFSettingsException('Page returned invalid data.');
	        }
	        
	        Map<Id, Wrike_Folder_Template__c> templateMap = new Map<Id, Wrike_Folder_Template__c>(templates);
	        List<Wrike_Folder_Template__c> sortedTemplates = new List<Wrike_Folder_Template__c>();
	        
	        for(Integer i = 0; i < templateIds.size(); i++) {
	            
	            Wrike_Folder_Template__c t = templateMap.get(templateIds[i]);
	            t.Order__c = i;
	            
	            sortedTemplates.add(t);
	        }
	        
	        upsert sortedTemplates;
	        
	        return null;
    	} catch(Exception ex) { 
            return handleExceptionPageRef(ex); 
        }
    }
    
    public PageReference verifyWrike() {
    
        try {
            isUser();
            return null;
        } catch(Exception ex) { 
            return handleExceptionPageRef(ex); 
        }
    }

}