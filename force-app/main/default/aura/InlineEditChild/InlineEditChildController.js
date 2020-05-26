({    
    doInit: function(component, event, helper) {
        helper.fetchPickListVal(component, 'RFI_Item_Status__c', 'RFIItemStatusPicklistOpts');
        helper.fetchPickListVal(component, 'Onsite_Remediation_Required__c', 'OnsiteRemediationPicklistOpts');
        // to fetch the field permission
        helper.fetchPermission(component,event);
    },
       
    inlineEditRFIDetailDescription : function(component,event,helper){  
        component.set("v.RFIDetailDescriptionEditMode", true);
        setTimeout(function(){
            component.find("inputRFIDetailDescription").focus();
        }, 100);
    },
    
    inlineEditOnsiteremediation : function(component,event,helper){  
        component.set("v.OnsiteremediationEditMode", true);
        component.find("OnsiteRemediation").set("v.options" , component.get("v.OnsiteRemediationPicklistOpts"));
        setTimeout(function(){
            component.find("OnsiteRemediation").focus();
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
            component.find("inputOnsiteRemediationdescription").focus();
        }, 100);
    },
    
    inlineEditonsiteremediationdescription : function(component,event,helper){  
        component.set("v.OnsitedescriptionEditMode", true);
        setTimeout(function(){
            component.find("inputCancelcannnotcompletedescription").focus();
        }, 100);
    },
    
    
    inlineEditimplementationBlocked : function(component,event,helper){
    	component.set("v.implementationBlockedEditMode", true);
        setTimeout(function(){
            component.find("inputImplementationBlocked").focus();
        }, 100);
    },
    
    inlineEditduedate : function(component,event,helper){  
        component.set("v.duedateEditMode", true);
        setTimeout(function(){
            component.find("duedate").focus();
        }, 100);
    },
    
    onRFIDetailDescriptionChange : function(component,event,helper){
        if(event.getSource().get("v.value").trim() != ''){
            component.set("v.showSaveCancelBtn",true);
        }
    },
    
    oninputImplementationBlocked : function(component,event,helper){
        component.set("v.showSaveCancelBtn",true);
    },
    
    onduedateChange : function(component,event,helper){
        alert('date---->');
        component.set("v.showSaveCancelBtn",true);
        
        /*var oDate = component.find("duedate");
        var date = event.getSource().get("v.value");
        oDate.set("v.singleRec.Due_Date__c",date);
        alert('date---->'+date);
        component.set("v.duedate", date);*/
    },
    
    onRFIItemStatusChange : function(component,event,helper){
        component.set("v.showSaveCancelBtn",true);
        if(event.getSource().get("v.value") == 'Canceled' ||event.getSource().get("v.value") == 'Cannot Complete'){
        component.set("v.CancelcannnotcompletedescriptionEditMode", true);
        if(event.getSource().get("v.value").trim() != ''){
            component.set("v.CancelcannnotcompletedescriptionEditMode", true);
            component.set("v.makerequired", true);
        }
        }
        else{
            component.set("v.CancelcannnotcompletedescriptionEditMode", false);
            component.set("v.makerequired", false);
        }
        if(event.getSource().get("v.value") == 'Submitted – Pending Customer Review'){
            component.find("dueDate").set("v.disabled", true);
        }else{
            component.find("dueDate").set("v.disabled", false);
        }
    },
    
    ononsiteremediationChange : function(component,event,helper){
        component.set("v.showSaveCancelBtn",true);
        if(event.getSource().get("v.value") == 'Yes'){
            component.set("v.OnsitedescriptionEditMode", true);
            if(event.getSource().get("v.value").trim() != ''){
            component.set("v.OnsitedescriptionEditMode", true);
            component.set("v.makeonsiterequired", true);
        }
        }
        else{
            component.set("v.OnsitedescriptionEditMode", false);
            component.set("v.makeonsiterequired", false);
        }
    },
    
    ononsiteremediationdescriptionChange : function(component,event,helper){
        if(event.getSource().get("v.value").trim() != ''){
        	component.set("v.showSaveCancelBtn",true);
        }
    },
    
    
    onCancelcannnotcompletedescriptionChange : function(component,event,helper){
        if(event.getSource().get("v.value").trim() != ''){
            component.set("v.showSaveCancelBtn",true);
        }
    },
    
    closeRFIDetailDescriptionBox : function (component, event, helper) {       
        component.set("v.RFIDetailDescriptionEditMode", false);
		
    },
    
    closeRFIItemStatusBox : function (component, event, helper) {
        component.set("v.RFIItemStatusEditMode", false);
    },
    
    closeonsiteremediationBox : function (component, event, helper) {
        component.set("v.OnsiteremediationEditMode", false);
    },
    
    closeonsiteremediationdescriptionBox : function (component, event, helper) {
        component.set("v.OnsitedescriptionEditMode", false);
    },
        
    closeinputImplementationBlocked : function (component, event, helper) {       
        component.set("v.implementationBlockedEditMode", false);
	},
    
    closeCancelcannnotcompletedescriptionBox : function (component, event, helper) {       
        component.set("v.CancelcannnotcompletedescriptionEditMode", false);        
    },
    
    closeduedateBox : function (component, event, helper) {       
        component.set("v.duedateEditMode", false);        
    },
    
    onChangeDate : function (component, event, helper) {
       // alert('hi');
        var dueDate = component.find("dueDate").get("v.value");
       // alert('dueDate'+dueDate);
        component.set("v.showSaveCancelBtn",true);
     }

 })