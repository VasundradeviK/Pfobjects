({
    
    callAddRfiDetails : function(component,event,selectedCategory) {
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.RfiDetails");
        action.setParams({ selectedCategory : selectedCategory});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log(response.getReturnValue());
                if(response.getReturnValue() != null){
                    var storeResponse1 = response.getReturnValue();
                    component.set('v.RFIDetailListlst', storeResponse1);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
    callController : function(component,event,selectedCat) {
        var action = component.get("c.saveRfiDetailsLst");
        action.setParams({ selectedCat : selectedCat });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log(response.getReturnValue().length);
                if(response.getReturnValue().length>0){
                alert(response.getReturnValue().length +  'Records got updated');
                }else{
                    alert('No Records got updated')
                }
                var navLink = component.find("navService");
                var pageRef = 
                    {    
                        "type": "standard__component",
                        "attributes": {
                            "componentName": "c__CategoryDetailsPage"    
                        },
                        state: { 
                            "myAttr": "attrValue" 
                        }
                    };
                navLink.navigate(pageRef, true);
            }
        });
        $A.enqueueAction(action);
    }
    
})