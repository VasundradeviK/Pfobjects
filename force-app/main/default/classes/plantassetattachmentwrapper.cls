public class plantassetattachmentwrapper {
    @AuraEnabled
    public static List<attachWrap> getConAttachments(Id artId){
        
        map<Id, List<ContentVersion>> mapParentIdFiles = new map<Id, List<ContentVersion>>();
        
        Map<Id,Plant_Asset_Attachment__c> plantAssetAttachmentList = new Map<Id,Plant_Asset_Attachment__c>([Select id, Name,Has_Attachment__c, Plant_Asset_Name__r.Name from Plant_Asset_Attachment__c Where Plant_Asset_Name__c =: artId]);
        System.debug(':::plantAssetAttachmentList:::'+plantAssetAttachmentList);
        List<ContentDocumentLink> CDLs = new List<ContentDocumentLink>();
        
        Map<String, List<Id>> cvMap = new Map<String, List<Id>>();
        
        set<Id> plantAssetAttachmentIds = plantAssetAttachmentList.keySet();
        System.debug(':::plantAssetAttachmentIds:::'+plantAssetAttachmentIds);
        
        if(plantAssetAttachmentList.Size() > 0 && plantAssetAttachmentList != NULL){
            CDLs = [Select ContentDocumentId, LinkedEntityId 
                    from ContentDocumentLink 
                    where LinkedEntityId IN : plantAssetAttachmentIds];
            //System.debug(':::CDLs:::'+CDLs);
        }System.debug(':::CDLs:::'+CDLs);
        
        if(CDLs.Size() > 0 && CDLs != NULL){
            for(ContentDocumentLink c : CDLs){
                if(cvMap.containsKey(c.LinkedEntityId)){
                    List<Id> cd = cvMap.get(c.LinkedEntityId);
                    if(c.ContentDocumentId != NULL)
                        cd.add(c.ContentDocumentId);
                    System.debug(':::cd:::'+cd);
                    cvMap.put(c.LinkedEntityId, cd);
                }else{
                    cvMap.put(c.LinkedEntityId, new List<Id> { c.ContentDocumentId });
                }
            }
            System.debug(':::cvMap:::'+cvMap);
            System.debug(':::cvMap.parent id:::'+cvMap.keyset());
        }                
        set<Id> setDocumentIds = new set<Id>();
        List<ContentDocumentLink> fileLinks = [select Id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where LinkedEntityId in: plantAssetAttachmentIds];
        for(ContentDocumentLink fileLink: fileLinks){
            setDocumentIds.add(fileLink.ContentDocumentId);
        }                
        map<Id, ContentVersion> mapContentVersion = new map<Id, ContentVersion>();
        for(ContentVersion cv: [select Id, title, ContentDocumentId from ContentVersion where ContentDocumentId in: setDocumentIds]){
            mapContentVersion.put(cv.ContentDocumentId, cv);
        }                
        for(ContentDocumentLink fileLink: fileLinks){
            if(mapContentVersion.containsKey(fileLink.ContentDocumentId)){
                if(mapParentIdFiles.containsKey(fileLink.LinkedEntityId)){
                    mapParentIdFiles.get(fileLink.LinkedEntityId).add(mapContentVersion.get(fileLink.ContentDocumentId));
                }else{
                    mapParentIdFiles.put(fileLink.LinkedEntityId, new List<ContentVersion>{mapContentVersion.get(fileLink.ContentDocumentId)});
                }                   
            }
        }                
        List<attachWrap> wrapList = new List<attachWrap>();
        list<Plant_Asset_Attachment__c> listPAACL = [Select id, Name, Plant_Asset_Name__r.Name from Plant_Asset_Attachment__c Where Id =: cvMap.keyset() AND Plant_Asset_Name__c =: artId ];  
        list<Plant_Asset_Attachment__c> listattach = new list<Plant_Asset_Attachment__c>();
        list<Plant_Asset_Attachment__c> listdelete = [Select id, Name, Plant_Asset_Name__r.Name from Plant_Asset_Attachment__c Where Id NOT IN : cvMap.keyset() AND Plant_Asset_Name__c =: artId ];
        	for(Plant_Asset_Attachment__c check : listPAACL){
                check.Has_Attachment__c = true;
                listattach.add(check);
            }
            for(Plant_Asset_Attachment__c check1 : listdelete){
                check1.Has_Attachment__c = false;
                listattach.add(check1);
            }
            update listattach;
        
            
        for(Plant_Asset_Attachment__c c : plantAssetAttachmentList.values()){
            wrapList.add(new attachWrap(c, mapParentIdFiles.get(c.id)));           
        }
        //update listPAACL;
        System.debug(':::listattach:::'+listattach);
        System.debug(':::listPAACL:::'+listPAACL);
        System.debug(':::wrapList:::'+wrapList);
        return wrapList;
        
        
    }           
    public class attachWrap{
        
        @AuraEnabled public Plant_Asset_Attachment__c  wCon {get;set;}
        @AuraEnabled public List<ContentVersion> wCV {get;set;}      
        //@AuraEnabled public String selected {get; set;}        
        public attachWrap(Plant_Asset_Attachment__c con, List<ContentVersion> CV){
            wCon = con;
            wCV =  CV;
            
        }
    }
    
    @AuraEnabled
    public static boolean deleteAttachments(Id attachId){
        
        if(attachId != NULL){
            ContentDocument file = [Select Id from ContentDocument where Id = :attachId];
            delete file;
            return true;
        }
        else{
            return false;
        }
    }
}