@isTest 
private class WrikeUpdate_Test {
    
    static testMethod void validateMainController() {
        
        new WrikeUpdate_MainController();
        WrikeUpdate_MainController.getStatus();
    }
     
     static testMethod void validateExportController() {
        
        WrikeUpdate_Utils.replaceService(new DataServiceMock());
        
        new WrikeUpdate_ExportController();
        WrikeUpdate_ExportController.init();
        WrikeUpdate_ExportController.step('info', null);
        WrikeUpdate_ExportController.step('settings', null);
        WrikeUpdate_ExportController.step('apitokens', null);
        WrikeUpdate_ExportController.step('bindings', null);
        
        WrikeUpdate_ExportController.step('binding-test-field', null);
        WrikeUpdate_ExportController.step('binding-test-data', null);
        WrikeUpdate_ExportController.step('binding-test-page', null);
        WrikeUpdate_ExportController.step('binding-test-layout-test layout', null);
        
        WrikeUpdate_Utils.replaceService(new EmptyServiceMock());
        
        WrikeUpdate_ExportController.step('binding-test-page', null);
        WrikeUpdate_ExportController.step('binding-test-layout-test layout', null);
    }

     static testMethod void validateCleanController() {
        
        WrikeUpdate_Utils.replaceService(new DataServiceMock());
        
        new WrikeUpdate_CleanController();
        WrikeUpdate_CleanController.init();
        WrikeUpdate_CleanController.step('binding-test-layout-test layout','{}');
        WrikeUpdate_CleanController.step('binding-test-page','{}');
        WrikeUpdate_CleanController.step('binding-test-data','{}');
        WrikeUpdate_CleanController.step('binding-test-field','{}');
        WrikeUpdate_CleanController.step('bindings','{}');
        WrikeUpdate_CleanController.step('apitokens','{}');
        WrikeUpdate_CleanController.step('settings','{}');
        
        WrikeUpdate_Utils.replaceService(new EmptyServiceMock());
    }

    static testMethod void validateImportController() {
  
        WrikeUpdate_Utils.replaceService(new DataServiceMock());
        
        new WrikeUpdate_ImportController();
        WrikeUpdate_ImportController.init();
        WrikeUpdate_ImportController.step('settings',
                '{"WrikeAccountId__c":"XXXXXXXX"}');
        WrikeUpdate_ImportController.step('apitokens',
                '[{"SetupOwnerId":"0000000000000000","RefreshToken__c":"TOKEN"}]');
        WrikeUpdate_ImportController.step('bindings',
                '[{"Name":"Test"}]');
        WrikeUpdate_ImportController.step('binding-test-field','{}');
        WrikeUpdate_ImportController.step('binding-test-data',
                '[{"ID":"0000000000000000","Wrike_Folder_ID__c":"XXXXXXXXXXXXXXXXX"}]');
        WrikeUpdate_ImportController.step('binding-test-page','{}');
        WrikeUpdate_ImportController.step('binding-test-layout-test layout',
                 '{"itemHeight":355,"itemWidth":"100%","itemShowScrollbars":false,"itemShowLabel":false,'+
                 '"sectionIndex":0,"columnIndex":1,"itemIndex":0,"pageName":"Wrike_FolderView_Test"}');
        
        WrikeUpdate_Utils.replaceService(new EmptyServiceMock());  
        WrikeUpdate_ImportController.step('binding-test-page','{}');      
     }
     
     static testMethod void validateUtils() {
         
         WrikeUpdate_Utils.createService();         
     }
     
     public class DataServiceMock implements Wrike_MetadataService.IMetadataPort {
         
         public DataServiceMock() {
         }
         
         public Wrike_MetadataService.SaveResult[] updateMetadata(Wrike_MetadataService.Metadata[] metadata) {
            Wrike_MetadataService.SaveResult result = new Wrike_MetadataService.SaveResult();
            result.success = true;
            return new Wrike_MetadataService.SaveResult[] { result };
         }
        public Wrike_MetadataService.AsyncResult retrieve(Wrike_MetadataService.RetrieveRequest retrieveRequest) {
            return null;
        }
        public Wrike_MetadataService.DeployResult checkDeployStatus(String asyncProcessId,Boolean includeDetails) {
            return null;
        }
        public Wrike_MetadataService.SaveResult renameMetadata(String type_x,String oldFullName,String newFullName) {
            return null;
        }
        public Wrike_MetadataService.CancelDeployResult cancelDeploy(String String_x) {
            return null;
        }
        public Wrike_MetadataService.FileProperties[] listMetadata(
                Wrike_MetadataService.ListMetadataQuery[] queries, Double asOfVersion) {
            if (queries.size() > 0) {
                Wrike_MetadataService.ListMetadataQuery query = queries[0];
                if (query.type_x == 'Layout') {
                    Wrike_MetadataService.FileProperties prop = new
                        Wrike_MetadataService.FileProperties();
                        prop.fullName = 'test-test layout';
                    return new Wrike_MetadataService.FileProperties[] { prop };
                }
            }
            return null;            
        }
        public Wrike_MetadataService.DeleteResult[] deleteMetadata(String type_x,String[] fullNames) {
            Wrike_MetadataService.DeleteResult result = new Wrike_MetadataService.DeleteResult();
            result.success = true;
            return new Wrike_MetadataService.DeleteResult[] { result };
        }
        public Wrike_MetadataService.UpsertResult[] upsertMetadata(Wrike_MetadataService.Metadata[] metadata) {
            return null;
        }
        public Wrike_MetadataService.SaveResult[] createMetadata(Wrike_MetadataService.Metadata[] metadata) {
            Wrike_MetadataService.SaveResult result = new Wrike_MetadataService.SaveResult();
            result.success = true;
            return new Wrike_MetadataService.SaveResult[] { result };
        }
        public Wrike_MetadataService.RetrieveResult checkRetrieveStatus(String asyncProcessId) {
            return null;
        }
        public Wrike_MetadataService.IReadResult readMetadata(String type_x,String[] fullNames) {
            if (type_x == 'Layout') {
                Wrike_MetadataService.LayoutItem item = new Wrike_MetadataService.LayoutItem();
                item.width = '100%';
                item.height = 355;
                item.showLabel = false;
                item.showScrollbars = false;
                item.page_x = 'Wrike_FolderView_Test';
                                           
                Wrike_MetadataService.LayoutColumn column = new Wrike_MetadataService.LayoutColumn();
                column.layoutItems = new Wrike_MetadataService.LayoutItem[] { item };
                
                Wrike_MetadataService.LayoutSection section = new Wrike_MetadataService.LayoutSection();
                section.layoutColumns = new Wrike_MetadataService.LayoutColumn[] { column };
                
                Wrike_MetadataService.Layout layout = new Wrike_MetadataService.Layout();
                layout.layoutSections = new Wrike_MetadataService.LayoutSection[] { section };
                
                Wrike_MetadataService.ReadLayoutResult result
                        = new Wrike_MetadataService.ReadLayoutResult();
                result.records = new Wrike_MetadataService.Layout[] { layout }; 
                
                return result;
            }
            else if (type_x == 'ApexPage') {
                Wrike_MetadataService.ApexPage page = new Wrike_MetadataService.ApexPage();
                page.content = EncodingUtil.base64Encode( Blob.valueOf(
                        '<apex:page standardStylesheets="true" action="{!ensueFolder}" cache="false" '+
                          'controller="Wrike_FolderController">PAGE<apex:page>'
                  )); 
                Wrike_MetadataService.ReadApexPageResult result
                        = new Wrike_MetadataService.ReadApexPageResult();
                result.records = new Wrike_MetadataService.ApexPage[] { page }; 
                return result;
            }
            return null;
        }
        public Wrike_MetadataService.DescribeMetadataResult describeMetadata(Double asOfVersion) {
            return null;
        }
        public Wrike_MetadataService.AsyncResult deploy(String ZipFile,Wrike_MetadataService.DeployOptions DeployOptions) {
            return null;            
        }
    
     }
     
     public class EmptyServiceMock implements Wrike_MetadataService.IMetadataPort {
         
         public EmptyServiceMock() {
         }
         
         public Wrike_MetadataService.SaveResult[] updateMetadata(Wrike_MetadataService.Metadata[] metadata) {
            Wrike_MetadataService.SaveResult result = new Wrike_MetadataService.SaveResult();
            result.success = true;
            return new Wrike_MetadataService.SaveResult[] { result };
         }
        public Wrike_MetadataService.AsyncResult retrieve(Wrike_MetadataService.RetrieveRequest retrieveRequest) {
            return null;
        }
        public Wrike_MetadataService.DeployResult checkDeployStatus(String asyncProcessId,Boolean includeDetails) {
            return null;
        }
        public Wrike_MetadataService.SaveResult renameMetadata(String type_x,String oldFullName,String newFullName) {
            return null;
        }
        public Wrike_MetadataService.CancelDeployResult cancelDeploy(String String_x){
            return null;
        }
        public Wrike_MetadataService.FileProperties[] listMetadata(Wrike_MetadataService.ListMetadataQuery[] queries,Double asOfVersion){            
            return new List<Wrike_MetadataService.FileProperties>();
        }
        public Wrike_MetadataService.DeleteResult[] deleteMetadata(String type_x,String[] fullNames) {
            Wrike_MetadataService.DeleteResult result = new Wrike_MetadataService.DeleteResult();
            result.success = true;
            return new Wrike_MetadataService.DeleteResult[] { result };
        }
        public Wrike_MetadataService.UpsertResult[] upsertMetadata(Wrike_MetadataService.Metadata[] metadata) {
            return null;
        }
        public Wrike_MetadataService.SaveResult[] createMetadata(Wrike_MetadataService.Metadata[] metadata) {
            Wrike_MetadataService.SaveResult result = new Wrike_MetadataService.SaveResult();
            result.success = true;
            return new Wrike_MetadataService.SaveResult[] { result };
        }
        public Wrike_MetadataService.RetrieveResult checkRetrieveStatus(String asyncProcessId) {
            return null;
        }
        public Wrike_MetadataService.IReadResult readMetadata(String type_x,String[] fullNames) {
            if (type_x == 'Layout') {
                Wrike_MetadataService.ReadLayoutResult result
                        = new Wrike_MetadataService.ReadLayoutResult();
                result.records = new Wrike_MetadataService.Layout[] {}; 
                return result;
            }
            else if (type_x == 'ApexPage') {
                Wrike_MetadataService.ReadApexPageResult result
                        = new Wrike_MetadataService.ReadApexPageResult();
                result.records = new Wrike_MetadataService.ApexPage[] {}; 
                return result;
            }
            return null;
        }
        public Wrike_MetadataService.DescribeMetadataResult describeMetadata(Double asOfVersion) {
            return null;
        }
        public Wrike_MetadataService.AsyncResult deploy(String ZipFile,Wrike_MetadataService.DeployOptions DeployOptions) {
            return null;            
        }
    
     }
     
 
}