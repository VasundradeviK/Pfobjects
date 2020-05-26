({
    loadData: function(component, event, helper) {
        //to show First Category
         //call Missing category
         /*checks */
          component.set("v.showCatMissing",true);
        component.set("v.showIncorrectData",false);
        component.set("v.showRfiDetails",false);
        /*checks and */
        var action = component.get('c.getMissingCat');
        action.setParams({
            "objectNeeded"	: component.get("v.objectNeeded"),
            "fieldNeeded"	: component.get("v.fieldNeeded"),
            "recordTypeName"	:	"Missing/Incomplete Information"
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.wrapperMissingCat', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        //call Incorrect category
        var action = component.get('c.getMissingCat');
        action.setParams({
            "objectNeeded"	: component.get("v.objectNeeded"),
            "fieldNeeded"	: component.get("v.fieldNeeded"),
            "recordTypeName"	:	"Incorrect Information"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.wrapperIncorrectCat', response.getReturnValue());
                
            }
        });
        $A.enqueueAction(action);
    },
    
    handleFocus: function (cmp, event) {
        // console.log('Input Seven has recieved the focus.');
    },
    
    handleBlur: function (cmp, event) {
        // console.log('Input Seven has released the focus.');
    },
      selectAll : function(component, event, helper) {
        
        var selectedHeaderCheck = event.getSource().get("v.value");
        var getAllId = component.find("boxPack");
        
        if (selectedHeaderCheck == true) {
            if(getAllId.length > 0){
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPack")[i].set("v.value", true);
                }
            }else{
                component.find("boxPack").set("v.value", true);
            }
        } else {
            if(getAllId.length > 0){
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPack")[i].set("v.value", false);
                }
            }else{
                component.find("boxPack").set("v.value", false);
            }
        }        
        },
     selectAllMissing : function(component, event, helper) {
        
        var selectedHeaderCheck = event.getSource().get("v.value");
        var getAllMissingId = component.find("boxPackMissing");
        
        if (selectedHeaderCheck == true) {
            if(getAllMissingId.length > 0){
                for (var i = 0; i < getAllMissingId.length; i++) {
                    component.find("boxPackMissing")[i].set("v.value", true);
                }
            }else{
                component.find("boxPackMissing").set("v.value", true);
            }
        } else {
            if(getAllMissingId.length > 0){
                for (var i = 0; i < getAllMissingId.length; i++) {
                    component.find("boxPackMissing")[i].set("v.value", false);
                }
            }else{
                component.find("boxPackMissing").set("v.value", false);
            }
        }
        
       
    },
     
    selectAllRFI : function(component, event, helper) {
        
        var selectedHeaderCheck = event.getSource().get("v.value");
        var getAllId = component.find("boxPackrfi");
        
        if (selectedHeaderCheck == true) {
            if(getAllId.length > 0){
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPackrfi")[i].set("v.value", true);
                }
            }else{
                component.find("boxPackrfi").set("v.value", true);
            }
        } else {
            if(getAllId.length > 0){
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPackrfi")[i].set("v.value", false);
                }
            }else{
                component.find("boxPackrfi").set("v.value", false);
            }
        }        
        },
     previous : function(component, event, helper) {
          /* checks */
        component.set("v.showCatMissing",true);
        component.set("v.showIncorrectData",false);
        component.set("v.showRfiDetails",false);
        /* checks end */
        
        //to store second set of list 
        var checkvalue = [];
        checkvalue = component.find("boxPack");
        var selectedCategory = component.get("v.selectedCategory");
        var wrapperIncorrectCat = component.get('v.wrapperIncorrectCat');
        var valuesCheck = JSON.stringify(selectedCategory);
        
        console.log('selectedCategory'+selectedCategory);
        
        if(checkvalue.length > 0){
            for (var i = 0; i < checkvalue.length; i++){
                if (checkvalue[i].get("v.value") == true){
                    selectedCategory[checkvalue[i].get("v.text")] = JSON.stringify(wrapperIncorrectCat[i]);
                }
            }
        }else{
            var checkboxValue = checkvalue.get("v.value");
            if(checkboxValue){
                selectedCategory[checkvalue.get("v.text")] = JSON.stringify(wrapperIncorrectCat[0]);
            }
        }  
        component.set("v.selectedCategory",selectedCategory);
        
        //for duplicate values in previous
     	var catValue1 =[];
        catValue1 = Object.keys(selectedCategory);
        console.log('fruits - '+catValue1.length) ;
        
        if(checkvalue.length > 0){
            for (var i = 0; i < checkvalue.length; i++){
                if (catValue1.includes(checkvalue[i].get("v.text"))){
                    if(checkvalue[i].get("v.value") != true){     
                       // var chkV = checkvalue[i].get("v.text");
                  		delete selectedCategory[checkvalue[i].get("v.text")];
                    }
                }
            }
        }else{
            var checkboxValue = checkvalue.get("v.value");
            if (catValue1.includes(checkvalue[i].get("v.text"))){
                if(checkvalue[i].get("v.value") != true){
                	delete selectedCategory[checkvalue[i].get("v.text")];
                }
            }
        }   
        
		console.log('selectedCategory'+JSON.stringify(selectedCategory));

        // to check the check box in missing category
       //
       //  component.set("v.showCatMissing",true);
        var selectedCategory = component.get('v.selectedCategory');
        var selectedHeaderCheck = event.getSource().get("v.value");
        var wrapperMissingCat = component.get('v.wrapperMissingCat');
        var valuesCheck = JSON.stringify(selectedCategory);
        
        for(var i = 0; i < wrapperMissingCat.length; i++){
            //console.log('Tets $$$ '+wrapperMissingCat[i].lstRfiCat.Id);
            if(valuesCheck.includes(wrapperMissingCat[i].lstRfiCat.Id)){
                console.log(' IF $$$ '+wrapperMissingCat[i].lstRfiCat.Id);
                component.find("boxPackMissing")[i].set("v.value", true);
            }
        }
    },
    
   
    
    next : function(component, event, helper){
         /* test */
        component.set("v.showCatMissing",false);
        component.set("v.showIncorrectData",true);
        component.set("v.showRfiDetails",false);
         /* test end */
        //to add the selected category in missing category
        var checkvalue = [];
        checkvalue = component.find("boxPackMissing");
        var selectedCategory = new Map();
        selectedCategory = component.get("v.selectedCategory");
        var wrapperMissingCat = component.get('v.wrapperMissingCat');
        var valuesCheck = JSON.stringify(selectedCategory);

        if(checkvalue.length > 0){
            for (var i = 0; i < checkvalue.length; i++){
                if (checkvalue[i].get("v.value") == true){
                    selectedCategory[checkvalue[i].get("v.text")] = JSON.stringify(wrapperMissingCat[i]);
                }
            }
        }else{
            var checkvalue = checkvalue.get("v.value");
            if(checkvalue){
                selectedCategory[checkvalue.get("v.text")] = JSON.stringify(wrapperMissingCat[0]);
            }
        }  
        component.set("v.selectedCategory",selectedCategory);
        //    console.log('selectedCategory'+JSON.stringify(selectedCategory));
        var catValue1 =[];
        catValue1 = Object.keys(selectedCategory);
        console.log('fruits - '+catValue1.length) 
  
        //for duplicate values in previous
        if(checkvalue.length > 0){
            for (var i = 0; i < checkvalue.length; i++){
                if (catValue1.includes(checkvalue[i].get("v.text"))){
                    if(checkvalue[i].get("v.value") != true){     
                       // var chkV = checkvalue[i].get("v.text");
                  		delete selectedCategory[checkvalue[i].get("v.text")];
                    }
                }
            }
        }else{
            var checkboxValue = checkvalue.get("v.value");
            if (catValue1.includes(checkvalue[i].get("v.text"))){
                if(checkvalue[i].get("v.value") != true){
                	delete selectedCategory[checkvalue[i].get("v.text")];
                }
            }
        }   
        
		console.log('selectedCategory'+JSON.stringify(selectedCategory));
        
        //to check the check box in incorrect category
     //   component.set("v.showCatMissing",false);
        var wrapperIncorrectCat = component.get('v.wrapperIncorrectCat');
        for(var i = 0; i < wrapperIncorrectCat.length; i++){
            //console.log('Tets $$$ '+wrapperMissingCat[i].lstRfiCat.Id);
            if(valuesCheck.includes(wrapperIncorrectCat[i].lstRfiCat.Id)){
                console.log(' IF $$$ '+wrapperIncorrectCat[i].lstRfiCat.Id);
                component.find("boxPack")[i].set("v.value", true);
            }
        }
        
        // to show the conformation box
        var parentOn = component.get("v.selectedPlant");
        console.log('parentOn'+parent.length);
        if(parentOn.length > 0){
            component.set("v.parentOn",true);
        }
        
    }
    
    
   ,
    //to save all records
   
    
    doCancel : function(component, event, helper){
       /* var recordId = component.get("v.recordId");
        var navLink = component.find("navService");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'RFI__c',
                recordId : recordId // change record id. 
            },
        };
        navLink.navigate(pageRef, true);*/
      //  alert('cancel Page');
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
    },
      getRFiData : function(component, event, helper){
        
        var checkvalue = [];
        checkvalue = component.find("boxPack");
        var selectedCategory = component.get("v.selectedCategory");
        var wrapperIncorrectCat = component.get('v.wrapperIncorrectCat');
          component.set("v.showCatMissing",false);
        component.set("v.showIncorrectData",false);
        component.set("v.showRfiDetails",true);
        //console.log('selectedMissingCat'+JSON.stringify(selectedMissingCat));
        
        if(checkvalue.length > 0){
            for (var i = 0; i < checkvalue.length; i++){
                if (checkvalue[i].get("v.value") == true){
                    selectedCategory[checkvalue[i].get("v.text")] = JSON.stringify(wrapperIncorrectCat[i]);
                }
            }
        }else{
            var checkboxValue = checkvalue.get("v.value");
            if(checkboxValue){
                selectedCategory[checkvalue.get("v.text")] = JSON.stringify(wrapperIncorrectCat[0]);
            }
        }  
        component.set("v.selectedCategory",selectedCategory);
       // component.set("v.showCatMissing",false);
            helper.callAddRfiDetails(component,event,selectedCategory);
        
        //using parent value
      //  var selectedPlant = component.get("v.selectedPlant");
      //  console.log('selected Plant'+selectedPlant.length);
     //   if( selectedPlant.length >0 &&  typeof selectedCategory != 'undefined'){
      //      helper.callAddRfi(component,event,selectedPlant,selectedCategory);
       // }else if(typeof selectedCategory != 'undefined'){ //call Incorrect category
        //    helper.callControllerCategory(component,event,selectedCategory);
       // }
    },
    
    saveRTFDetails : function(component, event, helper){
        var checkvalue = [];
        checkvalue = component.find("boxPackrfi");
        var RFIDetailListlst = component.get("v.saveRfiDetailsLst");
        var selectedCat = new Map();
        
        if(checkvalue.length > 0){
            for (var i = 0; i < checkvalue.length; i++){
                if (checkvalue[i].get("v.value") == true){
                    selectedCat[checkvalue[i].get("v.text")] = JSON.stringify(RFIDetailListlst[i]);
                }
            }
        }else{
            var checkboxValue = checkvalue.get("v.value");
            if(checkboxValue){
                selectedCat[checkvalue.get("v.text")] = JSON.stringify(RFIDetailListlst[i]);
            }
        }  
        if(typeof selectedCat != 'undefined'){
            helper.callController(component,event,selectedCat);
        }
      	
        
       /* var rfiDetailsLst = component.get("c.saveRfiDetailsLst");
        rfiDetailsLst.setParams({
            "selectedCat" : component.get("v.RFIDetailListlst")
        });

      rfiDetailsLst.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.selectedCat", storeResponse);
                
                alert('Record Updated');
            }
            
        }); 
        $A.enqueueAction(rfiDetailsLst);
    */
    },
    navigate : function(component, event, helper){
    }
    
    
})