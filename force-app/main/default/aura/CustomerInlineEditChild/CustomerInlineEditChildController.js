({    
    doInit: function(component, event, helper) {
        helper.fetchPickListVal(component, 'RFI_Item_Status__c', 'RFIItemStatusPicklistOpts');
    },
       
    inlineEditCustomerComments : function(component,event,helper){  
        component.set("v.CustomerCommentsEditMode", true);
        setTimeout(function(){
            component.find("inputCustomerComments").focus();
        }, 100);
    },
    
    inlineEditRFIItemStatus : function(component,event,helper){  
        component.set("v.RFIItemStatusEditMode", true);
        component.find("RFIItemStatus").set("v.options" , component.get("v.RFIItemStatusPicklistOpts"));
        setTimeout(function(){
            component.find("RFIItemStatus").focus();
        }, 100);
    },
    
    inlineEditCancelcannnotcompletedescription : function(component,event,helper){  
        component.set("v.CancelcannnotcompletedescriptionEditMode", true);
        setTimeout(function(){
            component.find("inputCancelcannnotcompletedescription").focus();
        }, 100);
    },
    
    onCustomerCommentsChange : function(component,event,helper){
        if(event.getSource().get("v.value").trim() != ''){
            component.set("v.showSaveCancelBtn",true);
        }
    },
    
    onRFIItemStatusChange : function(component,event,helper){
        component.set("v.showSaveCancelBtn",true);
        
    },
    
    onCancelcannnotcompletedescriptionChange : function(component,event,helper){
        if(event.getSource().get("v.value").trim() != ''){
            component.set("v.showSaveCancelBtn",true);
        }
    },
    
    closeCustomerCommentsBox : function (component, event, helper) {       
        component.set("v.CustomerCommentsEditMode", false);        
    },
    
    closeRFIItemStatusBox : function (component, event, helper) {
        component.set("v.RFIItemStatusEditMode", false);
    },
    
    closeCancelcannnotcompletedescriptionBox : function (component, event, helper) {       
        component.set("v.CancelcannnotcompletedescriptionEditMode", false);        
    },
 })