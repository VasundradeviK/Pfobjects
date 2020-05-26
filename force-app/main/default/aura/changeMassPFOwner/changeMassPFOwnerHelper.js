({
    saveRfiItems : function(component, event, recordId, listRfiUpdated) {
        //alert('helper');
       // var totalListRfiItem = component.get('v.rfiItemList');
       // alert('type of'+ typeof totalListRfiItem);
        var selectedId = component.get('v.selectedId');
       // var recordId = 'a11R0000006OVJGIA4';

        var action = component.get("c.updateRfiItems");
        action.setParams({ listRfiUpdated : JSON.stringify(listRfiUpdated) });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
               // alert(response.getReturnValue());
               // console.log(response.getReturnValue());
                if(response.getReturnValue() > 0){
                    //alert('Update Successfully');
                    if(response.getReturnValue()>0){
                    window.location.reload();
                    $A.get('e.force:refreshView').fire();
                    window.location.reload(true);
                    var navLink = component.find("navService");
                    var pageRef = {
                        type: 'standard__recordPage',
                        attributes: {
                            actionName: 'view',
                            objectApiName: 'RFI__c',
                            recordId : recordId // change record id. 
                        },
                    };
                    navLink.navigate(pageRef, true);
                }
                }
               
            }
        });
        $A.enqueueAction(action);
    }
})