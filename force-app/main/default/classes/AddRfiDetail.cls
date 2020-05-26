public class AddRfiDetail {
    //for rfi category
    @AuraEnabled
    public static List<wrapperClassNew> getMissingCat(sObject objectNeeded,String fieldNeeded,String recordTypeName){
        List<RFI_Categories__c> listMissingCat = [select Id, Name,RecordType.Name,Description__c,Category_Classification__c from RFI_Categories__c where RecordType.Name =:recordTypeName ORDER BY Category_Classification__c ASC];
        List<wrapperClassNew> returnwrapperClass = new  List<wrapperClassNew> ();     
        
        //to get picklist
        List<String> pickList = new List<String>();
        Schema.sObjectType objType = objectNeeded.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        MAP<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List < Schema.PicklistEntry> values = fieldMap.get(fieldNeeded).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a: values) {
            pickList.add(a.getValue());
        }
        pickList.sort();
        
        // Assign Values
        if(listMissingCat.size() > 0){
            for(RFI_Categories__c cat : listMissingCat){
                wrapperClassNew ins = new wrapperClassNew();
                ins.lstRfiCat = cat;
                ins.description = '';
               // ins.statusPicklist = pickList;
                ins.selOption = '';
                returnwrapperClass.add(ins);
            }
        }
        return returnwrapperClass;    
    }
    
    //for two category
    @AuraEnabled
    public static String processCatValues(Map<String,String> selectedCategory, String recordId){
        String value; 
        List<RFI_Detail__c> lstMissingDetail = new List<RFI_Detail__c>();
        
        for(String str: selectedCategory.keySet()){
            for(RFI_Categories__c rfi : [SELECT Id,RecordType.Name FROM RFI_Categories__c WHERE Id=:str]){
                wrapperClassNew wrpCls	= (wrapperClassNew)JSON.deserialize(selectedCategory.get(str), wrapperClassNew.class);
                RFI_Detail__c rfiDetial = new RFI_Detail__c();
                if(rfi.RecordType.Name == 'Incorrect Information'){
                    rfiDetial.Incorrect_Category__c = rfi.Id;
                }else if(rfi.RecordType.Name == 'Missing/Incomplete Information'){
                    rfiDetial.Missing_Incomplete_Category__c = rfi.Id;
                }
                rfiDetial.RFI_Number__c = recordId;//record Id
                rfiDetial.RFI_Detail_Description__c = wrpCls.description;
                rfiDetial.RFI_Item_Status__c 		= wrpCls.selOption;
                lstMissingDetail.add(rfiDetial);
            } 
        }
        
        try{
            RFIBatchProcess be = new RFIBatchProcess(lstMissingDetail);
            value = Database.executeBatch(be,25);
        }catch(Exception e){
            System.debug('Error in insert');
        }
        return value;           
    }
    
    //add RFI with RFI detail 
    @AuraEnabled
    public static String processRfiWithRfiDetail(Map<String,String> selectedCategory,
                                                 String recordId,List<String> selectedPlant){
                                                     
                                                     // return selectedMissingCat.size()+'-'+selectedIncorrectCat.size();
                                                     List<RFI_Detail__c> lstMissingDetail = new List<RFI_Detail__c>();
                                                     List<RFI__c> lstRFI = new List<RFI__c>();
                                                     String value; 
                                                     
                                                     for(String plantVar : selectedPlant){
                                                         RFI__c rfiVar = new RFI__c();
                                                         rfiVar.Plant_Asset__c = plantVar;
                                                        // rfiVar.Onsite_Remediation_Required__c = 'No';
                                                         lstRFI.add(rfiVar);                                         
                                                     }                                                                       
                                                     try{                                                  
                                                         insert lstRFI;
                                                     }catch(Exception e){
                                                         System.debug('Error in insert');
                                                     }
                                                     //    return value;     
                                                     if(lstRFI.size()>0){  
                                                         for(RFI__c idVar : lstRFI){                                                            
                                                             for(RFI_Categories__c rfi : [SELECT Id,RecordType.Name FROM RFI_Categories__c WHERE Id=:selectedCategory.keySet()]){
                                                                 wrapperClassNew wrpCls	= (wrapperClassNew)JSON.deserialize(selectedCategory.get(rfi.Id), wrapperClassNew.class);
                                                                 RFI_Detail__c rfiDetial = new RFI_Detail__c();
                                                                 if(rfi.RecordType.Name == 'Incorrect Information'){
                                                                     rfiDetial.Incorrect_Category__c = rfi.Id;
                                                                 }else if(rfi.RecordType.Name == 'Missing/Incomplete Information'){
                                                                     rfiDetial.Missing_Incomplete_Category__c = rfi.Id;
                                                                 }
                                                                 rfiDetial.RFI_Number__c = idVar.Id;//record Id
                                                                 rfiDetial.RFI_Detail_Description__c = wrpCls.description;
                                                                 rfiDetial.RFI_Item_Status__c 		= wrpCls.selOption;
                                                                 lstMissingDetail.add(rfiDetial);
                                                             } 
                                                         }
                                                     }
                                                     try{
                                                         RFIBatchProcess be = new RFIBatchProcess(lstMissingDetail);
                                                         value = Database.executeBatch(be,25);
                                                     }catch(Exception e){
                                                         System.debug('Error in insert');
                                                     }
                                                     return value;
                                                 }
    
    @AuraEnabled
    public static List<RFI_Detail__c> RfiDetails(Map<String,String> selectedCategory){
        System.debug('selectedCategory:--->' +selectedCategory);
        Set<Id> catId = new Set<Id>();
        for(String s:selectedCategory.keySet()){
            catId.add(s);
        }
        
        System.debug('selectedCat' +catId.size());
        List<RFI_Detail__c> rfiDetailLst =  [select Id,RFI_Number__r.name,Name,Customer_Comments__c,RFI_Detail_Description__c from RFI_Detail__c where Incorrect_Category__c =:catId and RFI_Number__r.RFI_Status__c!='Closed' ];
        List<RFI_Detail__c> rfiDetailLst1 =  [select Id,RFI_Number__r.name,Name,Customer_Comments__c,RFI_Detail_Description__c from RFI_Detail__c where Missing_Incomplete_Category__c =:catId and RFI_Number__r.RFI_Status__c!='Closed'];  
        rfiDetailLst.addAll(rfiDetailLst1);
        System.debug('rfiDetailLst' +rfiDetailLst1.size());
        System.debug('rfiDetailLst:-' +rfiDetailLst.size());
        //List<Contact> conLst = [select id,name from contact];
        return rfiDetailLst;
    }
    
    
    @AuraEnabled
    public static List<RFI_Detail__c> saveRfiDetailsLst(Map<String,String> selectedCat){
        System.debug('selectedCat' +selectedCat);
        List<RFI_Detail__c> rfiDetailLst = new List<RFI_Detail__c>();
        for(String s:selectedCat.keySet() ){
            RFI_Detail__c rfdetail = new RFI_Detail__c();
          Map<String, Object> m =   (Map<String, Object>) JSON.deserializeUntyped(selectedCat.get(s));
            rfdetail.id = m.get('Id').toString();
            if(m.get('Customer_Comments__c')!= null){
            rfdetail.Customer_Comments__c = m.get('Customer_Comments__c').toString();
            }
            rfiDetailLst.add(rfdetail);
            System.debug('m id value' +m.get('Id'));
             System.debug('cc value' +m.get('Customer_Comments__c'));
            
        }
        update rfiDetailLst;
        return rfiDetailLst;
    }
}