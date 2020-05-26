public with sharing class Wrike_SchemaUtils {
    
    public static String getObjectNameByID(Id recordId) {
        
        return recordId.getSObjectType().getDescribe().getName();
    }
    
    public static Schema.SObjectType getObjectTypeByID(Id recordId) {
        
        return recordId.getSObjectType();
    }
    
    public static String getPluralLabelByName(String objectName) {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        return objType.getDescribe().getLabelPlural();
    }
    
    public static String getObjectLabelByID(Id recordId) {
        return recordId.getSObjectType().getDescribe().getLabel();
    }
    
    public static String getNameFieldByID(Id recordId) {
        
        String nameField = 'Name';
        String basicNameField = 'Name';
        
        Schema.SObjectType objType = recordId.getSObjectType();
        if (objType != null) {
        Map<String, Schema.SObjectField> fieldsmap = objType.getDescribe().fields.getMap();
                      
        for(Schema.sObjectField f : fieldsmap.values()) {
          if (f.getDescribe().isNameField()) {
            nameField = f.getDescribe().getName();
            System.debug('--- current nameField ' + nameField);
            if(nameField == basicNameField) {
                // normally, it should be true
                break;
            }
          }
        }
       }
       
       return nameField;
    }
}