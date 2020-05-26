public class Wrike_PrivilegedUtils {
   
    public static String getWrikeFolderId(Id recordId) {
        
        String objectName = Wrike_SchemaUtils.getObjectNameByID(recordId);
        
        SObject record = Database.query(
            'Select Id, Wrike_Folder_ID__c From ' + objectName +' Where Id = \'' + recordId + '\'');
        
        return (String) record.get('Wrike_Folder_ID__c');
    }
    
    public static void setWrikeFolderId(Id recordId, String value) {
        
        String objectName = Wrike_SchemaUtils.getObjectNameByID(recordId);
        
        SObject record = Database.query(
            'Select Id, Wrike_Folder_ID__c From ' + objectName +' Where Id = \'' + recordId + '\'');
            
        record.put('Wrike_Folder_ID__c', value);
        update record;
    }
    
    public static boolean hasWrikeFolderId(Id recordId) {
          
          Map<String, Schema.SobjectField> fields = 
            Wrike_SchemaUtils.getObjectTypeByID(recordId).getDescribe().fields.getMap();
        
        return fields.containsKey('Wrike_Folder_ID__c');
    }
    
    public static String getWrikeTaskId(Id recordId) {
        
        String objectName = Wrike_SchemaUtils.getObjectNameByID(recordId);
        
        SObject record = Database.query(
            'Select Id, Wrike_Task_ID__c From ' + objectName +' Where Id = \'' + recordId + '\'');
        
        return (String) record.get('Wrike_Task_ID__c');
    }
    
    public static void setWrikeTaskId(Id recordId, String value) {
        
        String objectName = Wrike_SchemaUtils.getObjectNameByID(recordId);
        
        SObject record = Database.query(
            'Select Id, Wrike_Task_ID__c From ' + objectName +' Where Id = \'' + recordId + '\'');
            
        record.put('Wrike_Task_ID__c', value);
        update record;
    }
    
    public static boolean hasWrikeTaskId(Id recordId) {
    	
    	 Map<String, Schema.SobjectField> fields = 
            Wrike_SchemaUtils.getObjectTypeByID(recordId).getDescribe().fields.getMap();
        
        return fields.containsKey('Wrike_Task_ID__c');
    }
       
    public static void updateBindedFolder(String objectName, String folderId) {
            
        Wrike_Bindings__c binding = 
            getBindingByObjectName(objectName);
            
        if (binding != null) {
            binding.ParentId__c = folderId;
            update binding;
        }           
    }
    
    public static Wrike_Bindings__c getBindingByObjectName(String objName) {
        
        String query = 'Select Name, NameTemplate__c, ParentId__c, Rule__c, Type__c, Full_Name__c From Wrike_Bindings__c '+
                            'Where Full_Name__c = \'' + objName + '\'';
        return Database.query(query);                            
    }
    
    public static void updateSalesforceFolder(String folderId) {
    	WrikeAccountSettings__c settings = WrikeAccountSettings__c.getOrgDefaults();
    	settings.SalesforceFolderId__c = folderId;
        upsert settings;
    }
}