/**
 * Created by saaltimas on 11/4/2018.
 */
({
    redirect : function(component, event, helper) {
        if(component.get("v.vfPage")){
            var url = '/' + component.get("v.recordId");
            window.open(url, '_self');
        } else {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "isredirect": true
            });
            navEvt.fire();
        }
    },
})