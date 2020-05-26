public class UpdateUserOnCreation {
    @future 
    public static void createUser(String id)
    {
       User u = [select Id,FirstName,LastName from User where Id=:id limit 1 ];
       u.CommunityNickname =  u.FirstName+' '+u.LastName;
        System.debug('CommunityNickname:--'+u.CommunityNickname);
        update u;   
        }
        
    }