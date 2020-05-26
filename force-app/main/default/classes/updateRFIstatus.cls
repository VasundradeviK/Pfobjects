public class updateRFIstatus {
    public static void getrfidetails(List<RFI_Detail__c> rfiDetailsLst){
        Set<Id> rfiId= new Set<Id>();
        System.debug('rfiDetailsLst' +rfiDetailsLst.size());
        for(RFI_Detail__c a : rfiDetailsLst){
            rfiId.add(a.RFI_Number__c);
        }
        list<RFI_Detail__c> rfiDetail = [SELECT Id, RFI_Number__c, RFI_Item_Status__c, Implementation_Blocked__c FROM RFI_Detail__c WHERE RFI_Number__c =:rfiId];
        Map<Id,List<RFI_Detail__c>> mapRfiwiseRfidetails = new Map<Id,List<RFI_Detail__c>>();
        for(RFI_Detail__c b:rfiDetail){
            if(mapRfiwiseRfidetails.containsKey(b.RFI_Number__c))
            {
                List<RFI_Detail__c> lstRFId = mapRfiwiseRfidetails.get(b.RFI_Number__c);
                lstRFId.add(b);
            }
            
            else
            {
                List<RFI_Detail__c> lstRFId = new List<RFI_Detail__c>();
                lstRFId.add(b);
                mapRfiwiseRfidetails.put(b.RFI_Number__c,lstRFId);
            }
        }
        system.debug(mapRfiwiseRfidetails);
        for(ID idVar :mapRfiwiseRfidetails.keySet()){
            list<RFI_Detail__c> closedlst = new list<RFI_Detail__c>();
            list<RFI_Detail__c> inprogresslst = new list<RFI_Detail__c>();
            list<RFI_Detail__c> submittedlst = new list<RFI_Detail__c>();
            list<RFI_Detail__c> iblsttrue = new list<RFI_Detail__c>();
            list<RFI_Detail__c> iblstfalse = new list<RFI_Detail__c>();
            for(RFI_Detail__c rfiVar : mapRfiwiseRfidetails.get(idVar)){
                if(rfiVar.RFI_Item_Status__c == 'Closed' || rfiVar.RFI_Item_Status__c == 'Canceled' || 
                   rfiVar.RFI_Item_Status__c == 'Cannot Complete'){
                    closedlst.add(rfiVar);
                   }
                if(rfiVar.RFI_Item_Status__c == 'In Progress' || rfiVar.RFI_Item_Status__c == 'Needs Detail' ||
                   rfiVar.RFI_Item_Status__c == 'Completed – Pending PF Review'){
                       inprogresslst.add(rfiVar);
                   }
                if(rfiVar.RFI_Item_Status__c == 'Submitted – Pending Customer Review'){
                       submittedlst.add(rfiVar);
                   }
                if(rfiVar.Implementation_Blocked__c == true && (rfiVar.RFI_Item_Status__c == 'In Progress' || rfiVar.RFI_Item_Status__c == 'Needs Detail' || 
                   rfiVar.RFI_Item_Status__c == 'Completed – Pending PF Review' || rfiVar.RFI_Item_Status__c == 'Completed – Pending PF Review')){
                       iblsttrue.add(rfiVar);
                   }
                if(rfiVar.Implementation_Blocked__c == false || (rfiVar.Implementation_Blocked__c == true && (rfiVar.RFI_Item_Status__c == 'Closed' || rfiVar.RFI_Item_Status__c == 'Canceled' || 
                   rfiVar.RFI_Item_Status__c == 'Cannot Complete'))){
                       iblstfalse.add(rfiVar);
                   }
            }
            //system.debug(closedlst);
            //system.debug(inprogresslst);
            //system.debug(submittedlst);
            system.debug(iblsttrue);
            RFI__c  statusUpdate = [SELECT id,Plant_Asset__c, RFI_Status__c FROM RFI__c WHERE id =:idVar LIMIT 1];
            //RFI__c  IbUpdate = [SELECT id, RFI_Status__c FROM RFI__c WHERE id =:idVar LIMIT 1];
            
            if(inprogresslst.size() == mapRfiwiseRfidetails.get(idVar).size()){
                //RFI__c  inprogress = [SELECT id, RFI_Status__c FROM RFI__c WHERE id =:idVar LIMIT 1];
                //system.debug(inprogress);
                statusUpdate.RFI_Status__c = 'In Progress';
                update statusUpdate;
            }
            if(submittedlst.size() == mapRfiwiseRfidetails.get(idVar).size()){
                //RFI__c  statusUpdate = [SELECT id, RFI_Status__c FROM RFI__c WHERE id =:idVar LIMIT 1];
                //system.debug(submitted);
                statusUpdate.RFI_Status__c = 'Submitted';
                update statusUpdate;
            }
            if(iblsttrue != null){
                statusUpdate.Implementation_Blocked__c = true;
                update statusUpdate;
                 Plant_Asset__c plantAsset = [select id,Implementation_Status__c from Plant_Asset__c where id=:statusUpdate.Plant_Asset__c limit 1];
                 plantAsset.Implementation_Status__c='Blocked';
                 update plantAsset;
            }
            if(iblstfalse.size() == mapRfiwiseRfidetails.get(idVar).size()){
                statusUpdate.Implementation_Blocked__c = false;
                Plant_Asset__c plantAsset = [select id,Implementation_Status__c from Plant_Asset__c where id=:statusUpdate.Plant_Asset__c limit 1];
                update statusUpdate; 
                plantAsset.Implementation_Status__c='In Progress';
                 update plantAsset;
                
            }
            if( closedlst.size() == mapRfiwiseRfidetails.get(idVar).size() ){
                //RFI__c  closed = [SELECT id, RFI_Status__c FROM RFI__c WHERE id =:idVar LIMIT 1];
                //system.debug(closed);
                statusUpdate.RFI_Status__c = 'Closed';
                update statusUpdate;
            }
            if( submittedlst.size() != mapRfiwiseRfidetails.get(idVar).size()){
                if( closedlst.size() != mapRfiwiseRfidetails.get(idVar).size()){
                	//RFI__c  closed = [SELECT id, RFI_Status__c FROM RFI__c WHERE id =:idVar LIMIT 1];
                	//system.debug(closed);
                	statusUpdate.RFI_Status__c = 'In Progress';
                	update statusUpdate;
            	}
            }
        }
    }
    
}