global with sharing class Wrike_FolderViewEntryController {
    
    private Id currentRecordId;
    
    global Wrike_FolderViewEntryController(ApexPages.StandardController controller) {
        currentRecordId = controller.getId();
    }
    
    global PageReference redirectToFolderView() {
        
        PageReference pageRef =  Page.Wrike_FolderView;
        pageRef.getParameters().put('currentRecordId', currentRecordId);
        return pageRef;
    }
    
    global Wrike_FolderViewEntryController() { }
}