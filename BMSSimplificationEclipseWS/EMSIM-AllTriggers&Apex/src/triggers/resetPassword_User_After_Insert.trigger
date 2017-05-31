/******************************************************************************
 *                                                                              
 * Reset the password of the User(s) if inserted through Integration
 *
 *******************************************************************************/
 
trigger resetPassword_User_After_Insert on User (after insert) {

    Profile profile = [select Id, Name from Profile where id = :UserInfo.getProfileId()];
    System.debug ('User Profile Name:------->' + profile.Name);

    for(User usr : Trigger.new) {
        try {
            if(profile.Name == 'BMS - Integration User') {
                System.debug ('Newly created User Name:------->' + usr.Username);
                System.setPassword(usr.id, 'interact123');
                System.debug ('User Created By:------->' + usr.CreatedById);
            }
        }catch (Exception e) {
            System.debug ('Error:------->' + e);
        }
    }
}