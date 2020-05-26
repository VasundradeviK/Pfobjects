({
    doinit : function(component, event, helper) {
       
        var action = component.get("c.getConAttachments");
        var artId = component.get("v.recordId");
        
        console.log(artId);

    action.setParams({
        "artId":artId
        });
        console.log("action");
        console.log(action);
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("state");
            console.log(state);
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log("result");
                console.log(result);
                component.set("v.wrapperList", result);
                alert(result);
            }
        });
        $A.enqueueAction(action);
        
    },
    handleClick : function(component, event, helper) {
        console.log("In Handleclick");
        var lis = event.getSource().get("v.value");
        console.log(lis);
        $A.get('e.lightning:openFiles').fire({
            recordIds: [lis],
           
        });
    },
    
    handleComponentEvent : function(component, event, helper) {
        
        var callDoinit = component.get('c.doinit');
        $A.enqueueAction(callDoinit);
    },
    
    handleDelete : function(component, event, helper) {
       
        var OpenModalEvent = component.getEvent("OpenModalEvent");
        OpenModalEvent.fire();
        
        var childcomponent= component.find("childComp");
        console.log("In handle delete");
        var Ids = event.getSource().get("v.value");
        console.log("To be deleted Ids::::::");
        console.log(Ids);
        childcomponent.childmethod(Ids);
    },
    
    detailPage : function(component, event, helper) {
        var detailId1 = event.currentTarget.title;
        console.log("detailId1:::::"+detailId1);
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": detailId1,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    openDetail : function(component, event, helper) {
        console.log("Event fired");
        
        
        var files = event.getSource().get("v.value");
        console.log("files are: ", JSON.stringify(files));
                
        var appEvent = $A.get("e.c:DeleteAttachmentsEvent");
        appEvent.setParams({
            "toDeleteIds" :  files
        });
        appEvent.fire();
        
    },
    
    DeleteNotify : function(component, event, helper) {
        
        var init = component.get('c.doinit');
        $A.enqueueAction(init);
        window.Location.Reload();
        
        
    },
    
    showSpinner : function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component, event, helper) {
        component.set("v.Spinner", false); 
    },
    
    openNotify : function(component, event, helper) {
        console.log("In open notify in poc");
        

        var rec = event.getSource().get("v.value");
        console.log(rec);
        component.set("v.recordId", rec);
        
        var open = component.get("v.isOpen");
        console.log(open);
        
        component.set("v.isOpen", true);
    },
    
    closeModal : function(component, event, helper) {
;
        component.set("v.isOpen", false);
        console.log("In close notify");
        //var callDoinit = component.get('c.doinit');
        //$A.enqueueAction(callDoinit);
        
    },
})