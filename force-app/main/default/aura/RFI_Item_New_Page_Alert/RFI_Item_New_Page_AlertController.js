({
    handleOpenModal: function(component, event, helper) {
        //For Display Modal, Set the "openModal" attribute to "true"
        component.set("v.openModal", true);
    },
     
    handleCloseModal: function(component, event, helper) {
        //For Close Modal, Set the "openModal" attribute to "fasle"
        component.set("v.openModal", false);
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "RFI_Detail__c"
        });
        homeEvent.fire();
 
 

        
    },
    
})