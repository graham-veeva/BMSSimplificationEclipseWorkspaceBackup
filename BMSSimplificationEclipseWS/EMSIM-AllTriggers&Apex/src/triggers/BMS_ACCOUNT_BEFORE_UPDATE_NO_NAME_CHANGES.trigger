trigger BMS_ACCOUNT_BEFORE_UPDATE_NO_NAME_CHANGES on Account (before update) {
        
/*
* Author: Todd Taylor
* Date: 3/16/2011
* Updated: 4/24/2012 (Colin McRavey)
* Summary: Prevent updates of ALL account names (business and person).
* 1. Determine whether name changes
* 2. Determine if salutation changes
* 3. If a change happened, determines if user is an Admin (saves query)
* 4. If not an Admin, revert the change
*/
    Boolean bChangeExists = false;    
    Boolean bModAllData = false;
    
    for (integer i=0;i<Trigger.new.size();i++) {   
        if (Trigger.new[i].isPersonAccount == true) {
            if ((Trigger.new[i].FirstName != Trigger.old[i].FirstName) || (Trigger.new[i].LastName != Trigger.old[i].LastName) || (Trigger.new[i].Middle_vod__c != Trigger.old[i].Middle_vod__c)) {
                bChangeExists = true;
            }
            if (Trigger.new[i].Salutation != Trigger.old[i].Salutation ) {
                bChangeExists = true;
            }
        } 
        else {
            if ((Trigger.new[i].Name != Trigger.old[i].Name)) {
                bChangeExists = true;
            }
        }
    }

    /* Prevent update if name change happened and non-admin user */
    if (bChangeExists == true) {
    
        String ProfileId = UserInfo.getProfileId();
        Profile pr = [Select Id, PermissionsModifyAllData From Profile where Id = :ProfileId];   
    
        if (pr != null && pr.PermissionsModifyAllData) {
            bModAllData = true;              
        }

        if (bModAllData == false) {
            for (integer i=0;i<Trigger.new.size();i++) {   
                if (Trigger.new[i].isPersonAccount == true) {
                    if ((Trigger.new[i].FirstName != Trigger.old[i].FirstName) || (Trigger.new[i].LastName != Trigger.old[i].LastName) || (Trigger.new[i].Middle_vod__c != Trigger.old[i].Middle_vod__c)) {
                        Trigger.new[i].FirstName = Trigger.old[i].FirstName;
                        Trigger.new[i].LastName = Trigger.old[i].LastName;                    
                        Trigger.new[i].Middle_vod__c = Trigger.old[i].Middle_vod__c;
                    }
                    if (Trigger.new[i].Salutation != Trigger.old[i].Salutation) {
                        Trigger.new[i].Salutation = Trigger.old[i].Salutation;
                    }
                }       
                else {
                    if ((Trigger.new[i].Name != Trigger.old[i].Name)) {
                        Trigger.new[i].Name = Trigger.old[i].Name;
                    }
                }
            }
        }
    }                   
}