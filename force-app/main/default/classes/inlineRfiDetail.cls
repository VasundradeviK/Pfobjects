public class inlineRfiDetail {
    //for rfi category
    @AuraEnabled
    public static List<wrapperClassNew> getMissingCat(sObject objectNeeded,String fieldNeeded,String recordTypeName,String recordId){
        List<RFI_Detail__c> existingDet = [select Missing_Incomplete_Category__r.Name,Incorrect_Category__r.Name,RFI_Item_Status__c from RFI_Detail__c where RFI_Number__c =:recordId AND (RFI_Item_Status__c  != 'Closed' AND RFI_Item_Status__c != 'Canceled' AND RFI_Item_Status__c != 'Cannot Complete')];
        
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
        
        
        Set<String> existingCat = new Set<String>();
        if(existingDet.size() >0){
            for(RFI_Detail__c rfi : existingDet){
                System.debug('rfi.RFI_Item_Status__c- '+rfi.RFI_Item_Status__c);
                if(rfi.Missing_Incomplete_Category__r.Name != null){
                    existingCat.add(rfi.Missing_Incomplete_Category__r.Name);
                }else if(rfi.Incorrect_Category__r.Name != null){
                    existingCat.add(rfi.Incorrect_Category__r.Name);
                }
            }
        }
        System.debug('existingCat'+existingCat.size());
        List<RFI_Categories__c> listMissingCat = [select Id, Name,RecordType.Name,Description__c,Category_Classification__c from RFI_Categories__c where RecordType.Name =:recordTypeName AND Name NOT IN: existingCat ORDER BY  Category_Classification__c ASC,NAME ASC];
        List<wrapperClassNew> returnwrapperClass = new  List<wrapperClassNew> ();     
        
        // Assign Values
        if(listMissingCat.size() > 0){
            for(RFI_Categories__c cat : listMissingCat){
                wrapperClassNew ins = new wrapperClassNew();
                ins.lstRfiCat = cat;
                ins.description = '';
                ins.onsitePicklist = pickList;
                ins.selOption = '';
                ins.onsiteDescription = ''; 
                ins.implementationBlock = false;
                returnwrapperClass.add(ins);
            }
        }
        return returnwrapperClass;    
        
    }
    
    //for two category
    @AuraEnabled
    public static String processCatValues(Map<String,String> selectedCategory, String recordId){
        
        List<RFI_Detail__c> lstMissingDetail = new List<RFI_Detail__c>();
        List<RFI_Detail__c> lstIncorrectDetail = new List<RFI_Detail__c>();
        String value; 
        
        RFI__c rfiVariable = [SELECT Id,Plant_Asset__c FROM RFI__c WHERE Id =: recordId LIMIT 1];
        
        for(String str: selectedCategory.keySet()){
            for(RFI_Categories__c rfi : [SELECT Id,RecordType.Name FROM RFI_Categories__c WHERE Id=:str]){
                wrapperClassNew wrpCls	= (wrapperClassNew)JSON.deserialize(selectedCategory.get(str), wrapperClassNew.class);
                RFI_Detail__c rfiDetial = new RFI_Detail__c();
                if(rfi.RecordType.Name == 'Incorrect Information'){
                    rfiDetial.Incorrect_Category__c = rfi.Id;
                }else if(rfi.RecordType.Name == 'Missing/Incomplete Information'){
                    rfiDetial.Missing_Incomplete_Category__c = rfi.Id;
                }
                rfiDetial.RFI_Number__c = rfiVariable.Id;//record Id
                rfiDetial.RFI_Detail_Description__c = wrpCls.description;
                rfiDetial.RFI_Item_Status__c 		= 'Submitted – Pending Customer Review';
                //rfiDetial.Plant_Asset__c = rfiVariable.Plant_Asset__c;
                rfiDetial.Onsite_Remediation_Required__c = wrpCls.selOption;
                rfiDetial.Implementation_Blocked__c = wrpCls.implementationBlock;
                if(wrpCls.selOption == 'Yes'){
                    rfiDetial.Onsite_Remediation_Description__c = wrpCls.onsiteDescription;
                } 
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
    
    //to get rfi detail
    // getCheckRfi
    @AuraEnabled
    public static Integer getCheckRfi(string recordId){
        System.debug('recordId');
        List<Plant_Asset__c> listOfPlantAsset = new List<Plant_Asset__c>(); 
        RFI__c instatVariable = [SELECT Id,RFI_Status__c FROM RFI__c where Id =: recordId];
        System.debug('instatVariable'+recordId+'instatVariable'+instatVariable.Id+'instatVariable'+instatVariable.RFI_Status__c);
        Integer proceed = 0;
        if(instatVariable.RFI_Status__c != 'Closed')
        {
            proceed++;
        }
        return proceed; 
    }
    
    //for Plant asset tag component
    @AuraEnabled
    public static List<Plant_Asset__c> getListOfPlantAsset(){
        List<Plant_Asset__c> listOfPlantAsset = new List<Plant_Asset__c>(); 
        for(Plant_Asset__c var : [SELECT Id, Name,RecordType.Name,Account__r.Name,Parent__r.Name,Active_RFI__c FROM Plant_Asset__c where RecordType.Name = 'Customer Asset' AND Active_RFI__c = 0 AND (Project_Lifecycle_Status__c  != 'Pending' AND Project_Lifecycle_Status__c != 'Customer Validation' AND Project_Lifecycle_Status__c != 'Operations' AND Project_Lifecycle_Status__c != 'Decommissioned') ORDER BY NAME ASC ] ){
            listOfPlantAsset.add(var); 
        }
        return listOfPlantAsset; 
    }
    
    //add RFI with RFI detail 
    @AuraEnabled
    public static Map<String,String> processRfiWithRfiDetail(Map<String,String> selectedCategory,String recordId,List<String> selectedPlant){
        
        // return selectedMissingCat.size()+'-'+selectedIncorrectCat.size();
        List<RFI_Detail__c> lstMissingDetail = new List<RFI_Detail__c>();
        List<RFI_Detail__c> lstIncorrectDetail = new List<RFI_Detail__c>();
        List<RFI__c> lstRFI = new List<RFI__c>();
        String value; 
        String error = ''; 
        Map<String,String> resultantValue = new Map<String,String>();
        
        for(String plantVar : selectedPlant){
            RFI__c rfiVar = new RFI__c();
            rfiVar.Plant_Asset__c = plantVar;
            lstRFI.add(rfiVar);                                         
        }                       
        
        try{                                                  
            insert lstRFI;
        }catch(Exception e){
            System.debug('Error in insert');
            error = e.getMessage();
            System.debug('error: ' + error);
        } 
        if(error == ''){
            //    return value;    
            List<RFI__c> rfiList = new  List<RFI__c>();
            if(lstRFI != null){
                for(RFI__c idVar : [SELECT Id, Name,Plant_Asset__c FROM RFI__c WHERE Id IN: lstRFI]){
                    rfiList.add(idVar);
                }                                              
            }
            
            List<RFI_Categories__c> rfiCat = new List<RFI_Categories__c>();
            if(selectedCategory.keySet() != null){
                for(RFI_Categories__c rfi : [SELECT Id,RecordType.Name FROM RFI_Categories__c WHERE Id=:selectedCategory.keySet()]){
                    rfiCat.add(rfi);
                }
            }
            
            if(lstRFI.size()>0){  
                for(RFI__c idVar : rfiList){                                                            
                    for(RFI_Categories__c rfi : rfiCat){
                        wrapperClassNew wrpCls	= (wrapperClassNew)JSON.deserialize(selectedCategory.get(rfi.Id), wrapperClassNew.class);
                        RFI_Detail__c rfiDetial = new RFI_Detail__c();
                        if(rfi.RecordType.Name == 'Incorrect Information'){
                            rfiDetial.Incorrect_Category__c = rfi.Id;
                        }else if(rfi.RecordType.Name == 'Missing/Incomplete Information'){
                            rfiDetial.Missing_Incomplete_Category__c = rfi.Id;
                        }
                        rfiDetial.RFI_Number__c = idVar.Id;//record Id
                        rfiDetial.RFI_Detail_Description__c = wrpCls.description;
                        rfiDetial.RFI_Item_Status__c 		= 'Submitted – Pending Customer Review';
                        rfiDetial.Plant_Asset__c = idVar.Plant_Asset__c ;
                        rfiDetial.Onsite_Remediation_Required__c = wrpCls.selOption;
                        rfiDetial.Implementation_Blocked__c = wrpCls.implementationBlock;
                        if(wrpCls.selOption == 'Yes'){
                            rfiDetial.Onsite_Remediation_Description__c = wrpCls.onsiteDescription;
                        }
                        lstMissingDetail.add(rfiDetial);
                    } 
                }
            }
            try{
                System.debug('lstMissingDetail'+lstMissingDetail);
                RFIBatchProcess be = new RFIBatchProcess(lstMissingDetail);
                value = Database.executeBatch(be,25);
            }catch(Exception e){
                System.debug('Error in insert');
            }
            resultantValue.put('Success', value);
            
            return resultantValue;
        }else
            resultantValue.put('Error in RFI', error);
        	return resultantValue;
        // return error;
    }

    //for Mass Change PF owner component
    //load active rfi
   
    @AuraEnabled
    public static List<wrapperForChangeMassPF> loadRfiItem(Id recordId) {
         System.debug('recordId:---'+recordId);
        List <RFI_Detail__c> lstOfRFIdetails = [SELECT Id,Name,RFI_Detail_Description__c,Assigned_Customer_Contact__c,Assigned_Customer_Contact__r.Name,IE_Owner__c,IE_Owner__r.Name from RFI_Detail__c Where RFI_Number__c =: recordId];
        System.debug('lstOfRFIdetails:---'+lstOfRFIdetails);

         List<wrapperForChangeMassPF> returnwrapperClass = new  List<wrapperForChangeMassPF> ();     
        
         // Assign Values
         if(lstOfRFIdetails.size() > 0){
             for(RFI_Detail__c detail : lstOfRFIdetails){
                wrapperForChangeMassPF ins = new wrapperForChangeMassPF();
                 ins.lstRfiDetails = detail;
                 ins.selOptionOwner = detail.IE_Owner__c;
                 returnwrapperClass.add(ins);
             }
         }
         return returnwrapperClass;  
    }

    @AuraEnabled
    public static Integer updateRfiItems(String listRfiUpdated) {
        String value2; 

        System.debug('totalListRfiItem'+listRfiUpdated);
        List<RFI_Detail__c> rfiListValues = (List<RFI_Detail__c>)JSON.deserialize(listRfiUpdated, List<RFI_Detail__c>.class);
       // List<wrapperForChangeMassPF> wrpCls	= (List<wrapperForChangeMassPF>)JSON.deserialize(totalListRfiItem, wrapperForChangeMassPF.class);
        System.debug('wrpCls'+rfiListValues);
        
        List<RFI_Detail__c> rfiListUpdate = new List<RFI_Detail__c>();

        for(RFI_Detail__c wrapperVariable : rfiListValues){
            System.debug('wrapperVariable.selOptionOwner'+wrapperVariable.IE_Owner__c);
            RFI_Detail__c rfiVar = new RFI_Detail__c();
            rfiVar.Id = wrapperVariable.Id;
            rfiVar.IE_Owner__c = wrapperVariable.IE_Owner__c;
            rfiVar.Assigned_Customer_Contact__c = wrapperVariable.Assigned_Customer_Contact__c;
            rfiListUpdate.add(rfiVar); 
        }

        try{
            System.debug('lstMissingDetail'+rfiListUpdate);
            RFIBatchProcess rfiBathVar = new RFIBatchProcess(rfiListUpdate);
            value2 = Database.executeBatch(rfiBathVar,25);

            //update rfiListUpdate;
        }catch(Exception e){
            System.debug('Error in Update');
        }

        return rfiListUpdate.size();
    }


}