/* methods for parsing API responses */
public with sharing class Wrike_JSONUtils {
	
	public static String parseJSON(String jsonString, String field) {
        return parseJSON(jsonString, new String[] {field}).get(field);
    }
    
    public static Map<String, String> parseJSON(String jsonString, List<String> fieldNames) {
        
        Map<String, String> resultMap = new Map<String, String>();

        List<Object> jsonData = extractRecordsFromJSON(jsonString);
        
        Map<String, Object> dataMap = (Map<String, Object>)(jsonData[0]);

        for(String field: fieldNames) {
            resultMap.put(field, (String)dataMap.get(field));
        }
        
        return resultMap;
    }

    public static List<Object> extractRecordsFromJSON(String jsonString) {
        
        return (List<Object>)((Map<String, Object>) JSON.deserializeUntyped(jsonString)).get('data');
    }
    
    // for extracting child objects of the response
    public static Map<Object,List<Object>> extractChildRecordsFromJSON(String jsonString, String childName) {
        
        Map<Object,List<Object> > result = new Map<Object,List<Object> > ();
        
        List<Object> parentRecords = extractRecordsFromJSON(jsonString);
        
        for(Object parentRecord : parentRecords) {
            Map<String, Object> dataMap = (Map<String, Object>) parentRecord;
            List<Object> childRecords = (List<Object>) dataMap.get(childName);
            
            result.put(parentRecord, childRecords);
        }
        return result;
    }

}