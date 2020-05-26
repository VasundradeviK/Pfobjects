({
    getPlantAsset : function(component, event) {
        var action = component.get("c.getListOfPlantAsset");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var listPA = response.getReturnValue();
                if(listPA.length>0){
                    component.set('v.loadedSpinner',false);
                component.set('v.listPlantAsset',response.getReturnValue()); 
                }else{
                    component.set('v.loadedSpinner',false);
                    component.set('v.showError',true); 
                }
                
                
            }else if(state === "ERROR"){
                var error = response.getError(error);
                component.find("notify").showError(error);
            }
        });
        $A.enqueueAction(action);   
    },
    
    
})