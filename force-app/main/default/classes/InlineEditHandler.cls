public class InlineEditHandler {
     @AuraEnabled
    public static List <RFI_Detail__c> getRFIdetail(Id artId) {
      List <RFI_Detail__c> lstOfRFIdetails = [SELECT Id,RFI_Number__c,Name,RFI_Item_Status__c,RFI_Detail_Description__c,Cancel_Cannot_Complete_Description__c,Customer_Comments__c,
                                              Implementation_Blocked__c, Onsite_Remediation_Required__c, Onsite_Remediation_Description__c, 
                                               Assigned_Customer_Contact__r.Name, IE_Owner__r.Name,Due_Date__c from RFI_Detail__c Where RFI_Number__c =: artId];
       return lstOfRFIdetails;
        
        
    }
    
    @AuraEnabled
    public static List <RFI_Detail__c> saveRFIdetails(List<RFI_Detail__c> lstRFIDetails) {
        System.debug('lstRFIDetails :--' +lstRFIDetails.size());
         System.debug('lstRFIDetails :--' +lstRFIDetails[0].RFI_Number__c);
        List<RFI_Detail__c> finalLst = new List<RFI_Detail__c>();
        try{
            List <RFI_Detail__c> lstOfRFIdetails = [SELECT Id, Name,RFI_Item_Status__c,RFI_Detail_Description__c,Cancel_Cannot_Complete_Description__c,Customer_Comments__c,
                                              Implementation_Blocked__c, Onsite_Remediation_Required__c, Onsite_Remediation_Description__c, 
                                               Assigned_Customer_Contact__r.Name, IE_Owner__r.Name,Due_Date__c from RFI_Detail__c Where RFI_Number__c =: lstRFIDetails[0].RFI_Number__c];
            
            System.debug('lstOfRFIdetails' +lstOfRFIdetails);
            List <RFI_Detail__c> changedLstOfRFIdetails = new  List <RFI_Detail__c>();
            for(RFI_Detail__c oldrfiDetail: lstOfRFIdetails){
               for(RFI_Detail__c newrfiDetail: lstRFIDetails){
                   if(oldrfiDetail.Id == newrfiDetail.Id){
                    if(oldrfiDetail.RFI_Item_Status__c != newrfiDetail.RFI_Item_Status__c ||oldrfiDetail.Due_Date__c != newrfiDetail.Due_Date__c
                     || oldrfiDetail.RFI_Detail_Description__c != newrfiDetail.RFI_Detail_Description__c ||oldrfiDetail.Onsite_Remediation_Required__c != newrfiDetail.Onsite_Remediation_Required__c
                      ||oldrfiDetail.Cancel_Cannot_Complete_Description__c != newrfiDetail.Cancel_Cannot_Complete_Description__c ||
                       oldrfiDetail.Customer_Comments__c!=newrfiDetail.Customer_Comments__c ||oldrfiDetail.Implementation_Blocked__c !=newrfiDetail.Implementation_Blocked__c ||
                        oldrfiDetail.Onsite_Remediation_Description__c != newrfiDetail.Onsite_Remediation_Description__c ||
                         oldrfiDetail.Assigned_Customer_Contact__r.Name != newrfiDetail.Assigned_Customer_Contact__r.Name ||
                        oldrfiDetail.IE_Owner__r.Name != newrfiDetail.IE_Owner__r.Name
                       ){
                        changedLstOfRFIdetails.add(newrfiDetail);
                      }
                   }
               }
            }
            System.debug('changedLstOfRFIdetails' +changedLstOfRFIdetails.size());
            if(changedLstOfRFIdetails.size()>0){
                System.debug('changedLstOfRFIdetails' +changedLstOfRFIdetails.size());
                update changedLstOfRFIdetails;
            }
           
            for(RFI_Detail__c rfiObj:lstRFIDetails){
                for(RFI_Detail__c crfi:changedLstOfRFIdetails){
                    if(rfiObj.id==crfi.id){
                        finalLst.add(crfi);
                    }else{
                        finalLst.add(rfiObj);
                    }
                }
            }
                  
		}
		catch(Exception e){
            if(e.getMessage().contains('is must')){
                throw new AuraHandledException('Cancel/Cannot Complete Descriptionis must');
            } else if(e.getMessage().contains('Please remove description in Cancel/Cannot complete')){
                throw new AuraHandledException('Please remove description in Cancel/Cannot Complete Description');
               } else if(e.getMessage().contains('Cannot save Due Date since RFI Item is closed')){
                   throw new AuraHandledException('Cannot save Due Date since RFI Item is closed');
               	}  else if(e.getMessage().contains('Community Users cannot edit Closed RFI. Please Contact PF Owner')){
                   	   throw new AuraHandledException('Community Users cannot edit Closed RFI. Please Contact PF Owner');
               		}  else if(e.getMessage().contains('Customer users cannot choose status other')){
                   	   throw new AuraHandledException('Customer users cannot choose status other than "In progress" and "Completed pending PF review"');
               		}	else if(e.getMessage().contains('Please contact the PF Owner')){
                   	   throw new AuraHandledException('Community Users cannot edit Closed RFI Item. Please contact the PF Owner');
               		}else if(e.getMessage().contains('Please remove off onsite remediation description as onsite remediation required is set to No')){
                   	   throw new AuraHandledException('Please remove off onsite remediation description as onsite remediation required is set to No');
                    } else if(e.getMessage().contains('Required fields are missing')){
                   	   throw new AuraHandledException('Please choose an RFI status as it is a required field');
                    }
                 else{
                    throw new AuraHandledException(e.getMessage());
                }
		}
        return finalLst;
    }
    
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld) {       
        List < String > allOpts = new list < String > ();
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        MAP < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        List < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        allOpts.sort();
        return allOpts;
    }    
    
    @AuraEnabled
    public static Map<String,String> mapValues(String mapDescription){
       /* Map<String,String> mapValue = new  Map<String,String>();
        mapValue.put(type,value);
        Map<ID,Map<String,String>> mapKey = new Map<ID,Map<String,String>>();
        mapKey.put(id,mapValue);
        return mapKey;
        */
        Map<String,String> mapv = (Map<String,String>)JSON.deserialize(mapDescription, Map<String,String>.class);
        return mapv;
    }
    //field permission
   @AuraEnabled
    public static Map<String,Boolean> getPermission(){
        FieldPermissions fieldNeeded= [SELECT SobjectType, Field, PermissionsRead, PermissionsEdit, Parent.ProfileId FROM FieldPermissions
         WHERE SobjectType =: 'RFI_Detail__c' 
        AND Field =:'RFI_Detail__c.Due_Date__c' AND Parent.ProfileId =:Userinfo.getProfileId()];

        System.debug('fieldNeeded'+fieldNeeded);
        Map<String,Boolean> fieldsNeedMap = new Map<String,Boolean>();
        fieldsNeedMap.put('PermissionsRead',fieldNeeded.PermissionsRead);
        fieldsNeedMap.put('PermissionsEdit',fieldNeeded.PermissionsEdit);
        return fieldsNeedMap;
    }
 }