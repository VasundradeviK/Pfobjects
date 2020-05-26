trigger UpdateUserNickname on User (after insert) {
     for(User us : Trigger.new)
        {
            UpdateUserOnCreation.createUser(us.Id);
        }

}