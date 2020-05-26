({
loadData : function(component, event, helper) {

    var IEOwner = component.find("IEOwner");
   // alert(IEOwner.length);
   // alert(IEOwner[1]);
    $A.util.toggleClass(IEOwner, "toggle");

    var action = component.get('c.loadRfiItem');
    var recordId = component.get("v.recordId");
    //var recordId = 'a11R0000006OVJGIA4';
    action.setParams({
        recordId: recordId
    });
    action.setCallback(this, function(response) {
       // alert('Hi2');
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
            var lstOfRFIdetails = response.getReturnValue();
            var PfIdList = [];
            var AssignedCustomerIdList = [];
          //  alert('proceed'+lstOfRFIdetails.length);
           // alert('va;'+lstOfRFIdetails[0].IE_Owner__c);
            
           if(lstOfRFIdetails.length > 0){
            component.set('v.rfiItemList',lstOfRFIdetails);
            component.set('v.rfiItemListOld',lstOfRFIdetails);
            component.set("v.showPfOwner",true);
            component.set("v.showAssignedContact",true);
                for(var inc = 0; inc < lstOfRFIdetails.length; inc++){
                   // alert('we need'+JSON.stringify(lstOfRFIdetails[inc].lstRfiDetails.IE_Owner__r.Name));
                }
                component.set('v.PfIdList',PfIdList);
                component.set("v.AssignedCustomerIdList",AssignedCustomerIdList);
            }
            
        }
    });
    $A.enqueueAction(action);    
},

handleKeyUp: function (component, evt) {
   // alert('hi');
    var isEnterKey = evt.keyCode === 13;
    //alert('hi');
    if (isEnterKey) {
        var queryTerm = component.find('lookUpPFOwner');
       // alert('queryTerm.length'+queryTerm.length);
        /*for(var i = 0; i <queryTerm.length; i++){
            alert('hi - find'+queryTerm[i]);
            alert('hi- value'+queryTerm[i].get('v.value'));
            component.set('v.issearching', true);
            setTimeout(function() {
                alert('Searched for "' + queryTerm[i].get('v.value') + '"!');
                component.set('v.issearching', false);
            }, 2000);
        }*/
    }
},

onSave : function (component, event, helper){
   
    var totalListRfiItem = component.get('v.rfiItemList');
    var recordId = component.get("v.recordId");
    var boxChange = component.find("boxChange");
    var listRfiUpdated = [];
    //helper.saveRfiItems(component, event, recordId);
    if(boxChange.length > 0){
        for(var iterateRfi = 0; iterateRfi < boxChange.length; iterateRfi++){
            if(boxChange[iterateRfi].get("v.checked") == true){
               // alert('pf owner name-'+JSON.stringify(totalListRfiItem[iterateRfi].lstRfiDetails));
                listRfiUpdated.push(totalListRfiItem[iterateRfi].lstRfiDetails);
            }
         }
    }else{
        if(boxChange.get("v.checked") == true){
            //alert('pf owner name-'+JSON.stringify(totalListRfiItem.lstRfiDetails));
            listRfiUpdated.push(totalListRfiItem.lstRfiDetails);
        }
    }
    

    helper.saveRfiItems(component, event, recordId,listRfiUpdated);
},

undoPfOwner : function(component, event, helper){
   // alert('hi');
},

onChangeOwner : function(component, event, helper){
   // alert('hi - Owner');
},

//for selectAll
selectAll : function(component, event, helper) {
    var selectedHeaderCheck = component.find("selectAll").get("v.checked");
    var getBoxPlant = component.find("boxChange");
    var lookUpPFOwner = component.find("lookUpPFOwner");
    var lookUpAssignedContact = component.find("lookUpAssignedContact");
    
    if (selectedHeaderCheck == true) {
        if(getBoxPlant.length > 0){
            for (var i = 0; i < getBoxPlant.length; i++) {
                component.find("boxChange")[i].set("v.checked", true);
                lookUpPFOwner[i].set("v.show",true);
                lookUpAssignedContact[i].set("v.show",true);
                /*component.set("v.showPfOwner",false);
                component.set("v.showAssignedContact",false);*/
            }
        }else{
            component.find("boxChange").set("v.checked", true);
            lookUpPFOwner.set("v.show",false);
            lookUpAssignedContact.set("v.show",false);
            /*component.set("v.showPfOwner",true);
            component.set("v.showAssignedContact",true);*/
        }
    } else if (selectedHeaderCheck == false){
        if(getBoxPlant.length > 0){
            for (var i = 0; i < getBoxPlant.length; i++) {
                component.find("boxChange")[i].set("v.checked", false);
                lookUpPFOwner[i].set("v.show",false);
                lookUpAssignedContact[i].set("v.show",false);
                /*component.set("v.showPfOwner",true);
                component.set("v.showAssignedContact",true);*/
            }
        }else{
            component.find("boxChange").set("v.checked", false);
            lookUpPFOwner.set("v.show",false);
            lookUpAssignedContact.set("v.show",false);
            /*component.set("v.showPfOwner",true);
            component.set("v.showAssignedContact",true);*/
        }
    }
},

selectElement : function(component, event, helper){ 
    //alert('hi');
    var checkBoxMissing = component.find("boxChange");
    var lookUpPFOwner = component.find("lookUpPFOwner");
    var lookUpAssignedContact = component.find("lookUpAssignedContact");
    var ieOwner = document.getElementsByClassName("ieOwner");
    var assignedCustomerContact = document.getElementsByClassName("assignedCustomerContact");
    var lstOfRFIdetails = component.get("v.rfiItemListOld");

    //alert(lstOfRFIdetails[0]);
    if(checkBoxMissing.length > 0){
        for (var i = 0; i < checkBoxMissing.length; i++){
            if (checkBoxMissing[i].get("v.checked") == true){
                lookUpPFOwner[i].set("v.show",true);
                lookUpAssignedContact[i].set("v.show",true);
                /*alert(i+JSON.stringify(lstOfRFIdetails[i].lstOfRFIdetails.IE_Owner__r.Name))
                ieOwner[i].innerHTML = "";
                assignedCustomerContact[i].innerHTML = "";*/
            }else{
               // alert(JSON.stringify(lstOfRFIdetails[i].lstOfRFIdetails.IE_Owner__r.Name));
                lookUpPFOwner[i].set("v.show",false);
                lookUpAssignedContact[i].set("v.show",false);
                /*ieOwner[i].innerHTML = lstOfRFIdetails[i].lstOfRFIdetails.IE_Owner__r.Name;
                assignedCustomerContact[i].innerHTML = lstOfRFIdetails[i].lstOfRFIdetails.Assigned_Customer_Contact__r.Name;*/
            }
        }
    }else{
        var checkBoxMissing = checkBoxMissing.get("v.checked");
        if(checkBoxMissing){
            lookUpPFOwner.set("v.show",true);
            lookUpAssignedContact.set("v.show",true);
           /* ieOwner.innerHTML = "";
            assignedCustomerContact.innerHTML = "";
           // alert(lookUpPFOwner.set("v.show",true));*/
        }else{
            lookUpPFOwner.set("v.show",false);
            lookUpAssignedContact.set("v.show",false);
           // alert(lookUpPFOwner.set("v.show",false));
        }
    } 
},

doCancel : function(component, event, helper){
    var recordId = component.get("v.recordId");
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


})