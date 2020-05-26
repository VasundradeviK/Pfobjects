public with sharing class Wrike_RemoteSettingsController extends Wrike_AbstractSectionController {

    public Wrike_RemoteSettingsController() {            
        showManualSettingsBlock = false;
    }
    
    public boolean showManualSettingsBlock {get; private set;}

    public PageReference proceedInstallation() {
            if(!checkMetadataAPIConnection()) {
                   showManualSettingsBlock = true; // something went wrong with auto remote site setting insertion, let user do it manually
                   return null;
            }
            return new PageReference('/apex/Wrike_SetupPage');
    }
    
    public String getHost() {
        return 'https://' +  ApexPages.currentPage().getHeaders().get('Host');
    }
    
    @RemoteAction
    public static String getMetadataRequestBody(string remoteSiteURL)
    {
        string remoteSiteName = new URL(remoteSiteURL).getHost().replaceAll('[^a-zA-Z0-9]', ''); // name should be alphanumeric

        return '<?xml version="1.0" encoding="utf-8"?>' + 
            '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                '<env:Header>' + 
                    '<urn:SessionHeader xmlns:urn="http://soap.sforce.com/2006/04/metadata">' + 
                      '<urn:sessionId>' + UserInfo.getSessionId() + '</urn:sessionId>' + 
                    '</urn:SessionHeader>' + 
                '</env:Header>' + 
                '<env:Body>' +
                    '<createMetadata xmlns="http://soap.sforce.com/2006/04/metadata">' + 
                        '<metadata xsi:type="RemoteSiteSetting">' + 
                            '<fullName>' + remoteSiteName +'</fullName>' + 
                            '<description>salesforce own host to access metadata api</description>' + 
                            '<disableProtocolSecurity>false</disableProtocolSecurity>' + 
                            '<isActive>true</isActive>' + 
                            '<url>'+ remoteSiteURL +'/'+'</url>' +
                        '</metadata>' +
                    '</createMetadata>' +
                '</env:Body>' + 
            '</env:Envelope>';
    }
    
}