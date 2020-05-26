public abstract class Wrike_BaseController {
    
    public Wrike_BaseController() {
        settings = WrikeAccountSettings__c.getOrgDefaults();
        errorDisplay =  new List<String>();
        isAuthorized = true;
    }
    
    public boolean isAuthorized {get; protected set;}
    public boolean isError {get { return (!errorDisplay.isEmpty()); } }
    
    protected List<String> errorDisplay {get; set;}
    public enum ExceptionHandlingMode { NONE, FULL, LOG }
    
    protected WrikeAccountSettings__c settings;
    
    public String getSalesforceHost() {
        return URL.getSalesforceBaseUrl().getProtocol() +
            '://' + URL.getSalesforceBaseUrl().getHost();
    }
    
    protected PageReference handleExceptionPageRef(Exception ex) {
        
        if(ex instanceof Wrike_Exceptions.NotAuthorizedException) {
            try {
                if(Wrike_ApiUtils.refreshExpiredToken()) {
                    return refreshAndReset();
                }
            } catch(Exception e) {
                handleException(e, ExceptionHandlingMode.LOG);
            }
            
            isAuthorized = false;
            return null;
        }
        
        Wrike_Exceptions.CustomException wex = Wrike_Exceptions.castException(ex);

        handleException(wex, ExceptionHandlingMode.FULL);
        
        addErrorsToPage();

        return null;
    }
    
    protected void handleException(Exception ex, ExceptionHandlingMode exMode) {
        
        if(exMode == ExceptionHandlingMode.NONE)
            throw ex;
        
        Wrike_Exceptions.CustomException wex = Wrike_Exceptions.castException(ex);
        logException(wex);
        if(exMode == ExceptionHandlingMode.FULL) {
            errorDisplay.add(wex.getUserFriendlyMessage());
            addErrorsToPage();     
        }
    }
    
    // logging method TBD
    private void logException(Wrike_Exceptions.CustomException ex) {
        
        System.debug('===ex.toString(): ' + ex.toString());
    }
    
    public void addErrorsToPage() {
        System.debug('===adding errors: ' + errorDisplay);
        for(String errorText : errorDisplay) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorText));
        }
    }
    
    protected PageReference refresh() {
        return null;
    }
    
    public PageReference refreshAndReset() {
        PageReference page = new PageReference(ApexPages.currentPage().getUrl());
        page.setRedirect(true);
           return page;
    }
    
    public void clearErrors() {
    	errorDisplay =  new List<String>();
    }
}