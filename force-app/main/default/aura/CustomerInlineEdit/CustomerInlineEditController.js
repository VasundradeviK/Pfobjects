({
    
    initRecords: function(component, event, helper) {
        var action = component.get("c.getRFIdetail");    
    	var artId = component.get("v.recordId");
        console.log(artId);

    action.setParams({
        "artId":artId
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();                
                component.set("v.RFIDetailList", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    
    Save: function(component, event, helper) {
        var allRecords = component.get("v.RFIDetailList");
      /*var isValid = 0;
      for(var i = 0; i < allRecords.length;i++){
          if((allRecords[i].RFI_Item_Status__c == 'Canceled' ||
              allRecords[i].RFI_Item_Status__c == 'Cannot Complete') &&
              allRecords[i].Cancel_Cannot_Complete_Description__c == null){
              //console.log(allRecords[i].RFI_Item_Status__c);
              //console.log(allRecords[i].Cancel_Cannot_Complete_Description__c);
              isValid ++;
          }
      }*/
      //if(isValid == 0){
      var action = component.get("c.saveRFIdetails");
      action.setParams({
          "lstRFIDetails" : component.get("v.RFIDetailList")
      });
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              var storeResponse = response.getReturnValue();
              component.set("v.lstRFIDetails", storeResponse);
              component.set("v.showSaveCancelBtn",false);
              alert('Record Updated');
               $A.get('e.force:refreshView').fire();
              window.location.reload(true)
          }else if(state === "ERROR"){
                var errors = action.getError();
                //var res = v.split(":", 2);
                if (errors) {
                    //alert(res[0].message);
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                        
                        
                        console.log('error Message'+ errors);
                    }
                }
            } 
          
      });
      $A.enqueueAction(action);
  
      
      /*else{
          alert('Cancel/Cannot complete description should not be null');
      }*/
 
  },
    
    cancel : function(component,event,helper){
        $A.get('e.force:refreshView').fire();
        window.location.reload(true)
    }
 })