public abstract class Wrike_TemplateBaseController extends Wrike_AbstractSectionController {

    public Wrike_TemplateBaseController() {
    	
    	this(10);   	
    }
    
    public Wrike_TemplateBaseController(Integer templatesPerPage) {
        
        List<Wrike_Folder_Template__c> templateList = [select Id, Name, Description__c, Wrike_Folder_Name__c, Order__c, 
                       Wrike_Folder_Id__c, Wrike_Folder_Permalink__c from Wrike_Folder_Template__c ORDER BY Order__c ASC];
                       
        templatePages = formTemplatePages(templatesPerPage, templateList);
        
        currentPage = 1;
        numberOfPages = templatePages.keySet().size();
    }
    
    public Map<Integer,List<Wrike_Folder_Template__c>> templatePages {get; private set;}
    public Integer currentPage {get; private set;}
    public Integer numberOfPages {get; private set;}
    
    public List<Wrike_Folder_Template__c> getTemplatePage() {
        return templatePages.get(currentPage);
    }
    
    public void nextPage() {
        currentPage++;
        currentPage = Math.min(numberOfPages, currentPage);
    }

    public void previousPage() {
        currentPage--;
        currentPage = Math.max(1, currentPage);
    }
    
    public void firstPage() {
        currentPage = 1;
    }

    public void lastPage() {
        currentPage = numberOfPages;
    }
    
    private Map<Integer,List<Wrike_Folder_Template__c>> formTemplatePages(Integer templatesPerPage, List<Wrike_Folder_Template__c> allTemplates) {
        
        Map<Integer,List<Wrike_Folder_Template__c>> tp = new Map<Integer,List<Wrike_Folder_Template__c>>();
        
        if(templatesPerPage > 0) {
        
            Integer noOfPages = allTemplates.size() > 0 ?
                     (Integer)(allTemplates.size()* (1.00/templatesPerPage)).round(System.RoundingMode.UP) : 1;

            for(Integer i = 1; i < noOfPages+1; i++) {
                
                List<Wrike_Folder_Template__c> newPage = new List<Wrike_Folder_Template__c>();
                for(Integer j = (i-1)*templatesPerPage; j < i*templatesPerPage; j++) {
                    if( j < allTemplates.size() ) {
                        newPage.add(allTemplates[j]);
                    }
                    else {
                        newPage.add(new Wrike_Folder_Template__c());
                    }
                }
                tp.put(i, newPage);
            }
        }
        
        return tp;      
    }
    
    public Wrike_Folder_Template__c getTemplateById(String templateId) {
        return [select Id, Name, Description__c, Wrike_Folder_Name__c, Order__c, Wrike_Folder_Id__c, Wrike_Folder_Permalink__c 
                                                                       from Wrike_Folder_Template__c where Id =: templateId];
    }
    
    protected void checkFolderCanBeCopied(String folderId, String templateName) {
    	
    	checkFolderStillExists(folderId, templateName);

        String folderTree = wrikeApiGet('/folders/' + folderId +'/folders', ExceptionHandlingMode.NONE);
        
        List<Object> folderMap = Wrike_JSONUtils.extractRecordsFromJSON(folderTree);
        Integer numberOfFolders = folderMap.size();
        
        System.debug('--numberOfFolders '+ numberOfFolders);
        
        String folderBody = WrikeApiGet('/folders/'+folderId+'/tasks/?fields=["responsibleIds"]', ExceptionHandlingMode.NONE);
        List<Object> folderTasks = Wrike_JSONUtils.extractRecordsFromJSON(folderBody); 
        Integer numberOfTasks = folderTasks.size();
        
        System.debug('--numberOfTasks '+ numberOfTasks);
        
        if(numberOfFolders + numberOfTasks > 100)
            throw new Wrike_Exceptions.TemplateTooLargeException();
    }
    
    private void checkFolderStillExists(String fid, String tname) {
    
	    try {
	        
	        String folderBody =  wrikeApiGet('/folders/'+ fid, ExceptionHandlingMode.NONE);
	        fid = Wrike_JSONUtils.parseJSON(folderBody, 'id');
	        
	        if(String.isBlank(fid) || isFolderDeletedByBody(folderBody)) {
	            throw new Wrike_Exceptions.WrikeResourceNotFoundException();
	        }
	        
	    } catch(Wrike_Exceptions.WrikeResourceNotFoundException wex) {
	        
	        throw new Wrike_Exceptions.CorruptedWrikeSettingsException(
	              ( String.isBlank(tname) ? 'Template' : '\'' + tname + '\'' ) 
	              + ' cannot be used. The template folder has been deleted in Wrike.');     
	    } catch(Exception ex) {
	       throw ex;
	    }
    
}
    
}