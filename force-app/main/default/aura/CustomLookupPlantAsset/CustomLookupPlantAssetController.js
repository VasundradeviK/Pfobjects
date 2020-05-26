({
	 selectPlantasset : function(component, event, helper){      
    // get the selected Account from list  
      var getSelectplantasset = component.get("v.oplantasset");
    // call the event   
      var compEvent = component.getEvent("oSelectedplantassetevent");
    // set the Selected Account to the event attribute.  
         compEvent.setParams({"Plant_Asset__cByEvent" : getSelectplantasset });  
    // fire the event  
         compEvent.fire();
    },
})