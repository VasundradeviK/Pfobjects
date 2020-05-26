public with sharing class Wrike_Exceptions {
    
    public static CustomException castException(Exception ex) {

        if(ex instanceof CustomException) {
            return (CustomException)ex;
        } else {
            return new UnexpectedException(ex.getMessage(), ex);
        }
    }
    
    public abstract class CustomException extends Exception {
                                    
        
        public String toString() {
            return this.getTypeName() + '\r\n Message: ' + this.getMessage() 
                            + '\r\n Stack Trace: ' + this.getStackTraceString() + '\r\n Cause: ' 
                            + this.getCause() + '\r\n Line Number: ' + this.getLineNumber();
        }
        
        public String getUserFriendlyMessage() {
            String result = '';

            if(this instanceof NotAuthorizedException) {
                result = 'Click "Authorize" to gain access to the Wrike tasks linked to this record.';
            } else if(this instanceof WrikeAccessDeniedException) {
                result = 'You are trying to access Wrike tasks not shared with you. Contact your Wrike account administrator to gain access.';
            } else if(this instanceof BaseCalloutException) {
                    result = 'Unable to connect to Wrike. If this error persists, contact your Salesforce administrator.';
            } else if(this instanceof SalesforceAccessDeniedException) {
                    result = 'You do not have permission to view this page. Contact your Salesforce account administrator to gain access.';
          /*  } else if(this instanceof CorruptedSettingsException) {
                result = 'An unexpected error occurred. ' + this.getMessage();*/
            } else if(this instanceof CorruptedSFSettingsException) {
            result = 'An unexpected error occurred. ' + this.getMessage() + ' If this error persists, contact your Salesforce administrator.';
            } else if(this instanceof CorruptedWrikeSettingsException) {
            result = this.getMessage() + ' Contact your Wrike administrator.';
            } else if(this instanceof WrikeCollaboratorException) {
                    result = 'Based on your Wrike license (Collaborator), you cannot set up the integration. ' +
                                    'Please contact your Wrike account administrator to change license.';   
            } else if(this instanceof TemplateTooLargeException) {
                result = 'The Wrike folder you\'ve chosen is too big to be used as a template. Please check the package manual for recommendations.';
            } else {
                result = 'An unexpected error occurred. If this error persists, contact Wrike support.';        
            // SF standard text: An unexpected error has occurred. Your development organization has been notified.
            }
            
            return result;
        }
    }
    
/*    public class CorruptedSettingsException extends CustomException {}*/
    public class CorruptedWrikeSettingsException extends CustomException {}
    public class CorruptedSFSettingsException extends CustomException {}
    public class NotAuthorizedException extends CustomException {}
    public class WrikeAccessDeniedException extends CustomException {}
    public class WrikeCollaboratorException extends CustomException {}
    public class SalesforceAccessDeniedException extends CustomException {}
    public class ApiErrorException extends CustomException {}
    public class WrikeResourceNotFoundException extends CustomException {}
    public class InvalidRequestException extends CustomException {}
    public class BaseCalloutException extends CustomException {}
    public class UnexpectedException extends CustomException {}
    public class TemplateTooLargeException extends CustomException {}
}