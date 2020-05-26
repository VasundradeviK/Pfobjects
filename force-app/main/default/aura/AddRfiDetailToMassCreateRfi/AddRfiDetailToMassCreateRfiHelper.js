({
    callController : function(component,event,selectedCat) {
        var action = component.get("c.processValues");
        action.setParams({ selectedCat : selectedCat });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log(response.getReturnValue());
                if(response.getReturnValue()>0){
                    var navLink = component.find("navService");
                    var pageRef = {
                        type: 'standard__recordPage',
                        attributes: {
                            actionName: 'view',
                            objectApiName: 'RFI__c',
                            recordId : 'a0y1F00000168NtQAI' // change record id. 
                        },
                    };
                    navLink.navigate(pageRef, true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
    callAddRfi : function(component,event,selectedPlant,selectedCategory) {
        console.log('helper'+selectedPlant+'-'+selectedCategory);
        
        var action = component.get("c.processRfiWithRfiDetail");
        action.setParams({ selectedCategory : selectedCategory,
                          selectedPlant :selectedPlant });
        action.setCallback(this, function(response){
           
            var state = response.getState(); console.log('state'+state);
            if(state === "SUCCESS"){
                console.log(response.getReturnValue());
                if(response.getReturnValue() != null){
                    var navLink = component.find("navService");
                    var pageRef = {
                        type: "standard__objectPage",
                        attributes: {
                            objectApiName	: "RFI__c",
                            actionName	: "list"
                        },
                        state: {
                            filterName	: "Recent"
                        }
                    };
                    navLink.navigate(pageRef, true);
                }
                component.set("v.showParent",true);
                component.set("v.selectedCategory",{});
            }else if(state === "ERROR"){
            
                let errors = response.getError();
                let message = 'Unknown error';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.log(errors);
                component.find("notify").showInfo(message);
            }
        });
        $A.enqueueAction(action);
        
    }
})