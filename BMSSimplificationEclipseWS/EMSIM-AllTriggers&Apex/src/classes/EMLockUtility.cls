global class EMLockUtility{
    
    global static Set<Id> idsThatHaveBeenChecked;
    global static Integer hasModifyAllData;

    public map<Id,String> EMLockUtilityTestIsLocked(List<EMTableEntry> newEntries){

        //System.debug('newEntries: ' + newEntries);

        if(idsThatHaveBeenChecked == null){
            // this is the first call to the class
            idsThatHaveBeenChecked = new Set<Id>();
            for(EMTableEntry e: newEntries){
                idsThatHaveBeenChecked.add(e.objectToInsert.Id);
            }
        }else{
            // this is not the first call, see if the records we are
            // working with have already been checked in this context
            List<EMTableEntry> newNewEntries = new List<EMTableEntry>();
            for(EMTableEntry e: newEntries){
                if(idsThatHaveBeenChecked.contains(e.objectToInsert.Id)){
                    // this object has been run through the utility already
                }else{
                    idsThatHaveBeenChecked.add(e.objectToInsert.Id);
                    newNewEntries.add(e);
                }
            }
            newEntries = newNewEntries;
        }

        if(newEntries.size() == 0){
            //System.debug('Returning Empty Map');
            return new Map<Id,String>();
        }

        map<Id, String> errorMap = new map<Id, String>();

        // get the hierarchy custom setting
        LockActivityChildrenContainer__c t = LockActivityChildrenContainer__c.getInstance();

        // get all of the list custom settings from LockActivityChildren
        // once we have all of them, we can decide which ones we need later
        List<LockActivityChildren__c> locks = LockActivityChildren__c.getall().values();

        Set<LockActivityChildren__c> myLockSettings = new Set<LockActivityChildren__c>();

        // create lists on list custom setting records that we need
        String recordAPIName = string.valueOf(newEntries[0].objectToInsert.getSObjectType());
        for(LockActivityChildren__c lock: locks){
            if(t.RecordIDs1__c != null && t.RecordIDs1__c.contains(lock.Name) && recordAPIName == lock.Object__c && !myLockSettings.contains(lock)){
                myLockSettings.add(lock);
            }else if(t.RecordIDs2__c != null && t.RecordIDs2__c.contains(lock.Name) && recordAPIName == lock.Object__c && !myLockSettings.contains(lock)){
                myLockSettings.add(lock);
            }else if(t.RecordIDs3__c != null && t.RecordIDs3__c.contains(lock.Name) && recordAPIName == lock.Object__c && !myLockSettings.contains(lock)){
                myLockSettings.add(lock);
            }
        }

        if(myLockSettings.size() == 0){
            //System.debug('myLockSettings empty, returning empty map');
            return new Map<Id,String>();
        }

        // get the current user's profile
        if(hasModifyAllData == null){
            List<Profile> currentUserProfileLst = [SELECT Id,PermissionsModifyAllData FROM Profile WHERE Id = :newEntries[0].UserProfileID];
            Profile currentUserProfile = new Profile();
            if(currentUserProfileLst.size() != 1){
                //system.debug('not exaclty one profile: ' + currentUserProfileLst);
            }else{
                currentUserProfile = currentUserProfileLst[0];
            }
            if(currentUserProfile.PermissionsModifyAllData == true){
                hasModifyAllData = 1;
            }else{
                hasModifyAllData = 0;
            }
        }
        

        // make a list of parent IDs
        // make a list f activity IDs
        List<Id> parentIDs = new List<Id>();
        List<Id> eventIDs = new List<Id>();
        List<EMTableEntry> newEntriesUpdated = new List<EMTableEntry>();
        for(EMTableEntry e: newEntries){
            for(LockActivityChildren__c lock: myLockSettings){
                //System.debug('lock: '+lock);
                sObject obj = e.objectToInsert;
                //System.debug('lock.Parent_Object__c: '+lock.Parent_Object__c);
                e.ParentID = (Id)obj.get((String)lock.Parent_Object__c);
                //System.debug('e.ParentId: ' + e.ParentId);
                if((Id)obj.get((String)lock.Parent_Object__c) != null){
                    parentIDs.add((Id)obj.get((String)lock.Parent_Object__c));
                }
                if(lock.Activity_Lookup_API_Name__c != null){
                    e.ActivityID = (Id)obj.get((String)lock.Activity_Lookup_API_Name__c);
                    eventIDs.add((Id)obj.get((String)lock.Activity_Lookup_API_Name__c));
                }
                //System.debug('e.ParentId: ' + e.ParentId);
                
                EMTableEntry newEM = new EMTableEntry();
                newEM.ParentID = e.ParentID;
                newEM.ActivityID = e.ActivityID;
                newEM.RecordID = e.RecordID;
                newEM.UserProfileID = e.UserProfileID;
                newEM.Operation = e.Operation;
                newEM.objectToInsert = e.objectToInsert;

                newEntriesUpdated.add(newEM);
            }
        }

        for(EMTableEntry b: newEntriesUpdated){
            //System.debug('b.parentID: '+b.parentID);
        }

        //System.debug('newEntriesUpdated: '+newEntriesUpdated);
        //System.debug('newEntriesUpdated.size: '+newEntriesUpdated.size());

        // inserting activities will make this null, and no validation will be needed
        List<Id> tempParentIds = new List<Id>();
        for(integer i = 0; i < parentIDs.size(); i++){
            if(parentIDs[i] != null){
                //break;
                tempParentIds.add(parentIDs[i]);
            }
            /*
            if(i == parentIDs.size()-1){
                // they were all null
                System.debug('All were inserting parent records, returning empty map');
                return new Map<Id,String>();
            }
            */
        }
        if(tempParentIds.size() == 0){
            return new Map<Id,String>();
        }else{
            parentIDs = tempParentIds;
        }

        Id aParentId = parentIDs[0];
        //System.debug('parent ID: ' + aParentId);
        String parentObjectAPIName = aParentId.getSObjectType().getDescribe().getName();
        //System.debug('parentObjectAPIName: '+parentObjectAPIName);
        //System.debug('parentIDs: ' + parentIDs);
        //system.debug('eventIDs: ' + eventIDs);

        String statusValues = '';
        
        for(EMTableEntry newEntry: newEntriesUpdated){
            String myObjectType = '';
            if(newEntry.Operation == 'Insert'){
                myObjectType = string.valueOf(newEntry.objectToInsert.getSObjectType());
            }else{
                myObjectType = Id.valueOf(newEntry.RecordID).getSObjectType().getDescribe().getName();
            }

            for(LockActivityChildren__c lockSetting: myLockSettings){
                //System.debug('lockSetting: '+lockSetting.Name);
                //System.debug('lockSetting.Parent_Status_Field__c: '+lockSetting.Parent_Status_Field__c);
                if(lockSetting.Object__c == myObjectType && lockSetting.Parent_API_Name__c == parentObjectAPIName){
                    if(statusValues == ''){
                        statusValues = lockSetting.Parent_Status_Field__c;
                    }else{
                        if(!statusValues.contains(lockSetting.Parent_Status_Field__c)){
                            statusValues = statusValues+','+lockSetting.Parent_Status_Field__c;
                        }
                    }
                }
            }
            break;
        }

        //System.debug('statusValues: '+statusValues);

        if(statusValues == ''){
            //System.debug('Returning, there were no status values for this object in the custom setting');
            return new Map<Id,String>();
        }

        String qry = 'SELECT Id,'+statusValues+',RecordType.DeveloperName FROM ' + parentObjectAPIName + ' WHERE Id IN :parentIDs';
        //System.debug('qry: '+qry);
        Map<Id,sObject> parentMap = new Map<Id,sObject>(database.query(qry));
        //System.debug('parentMap: '+parentMap);

        Map<Id,sObject> eventMap = new Map<Id,sObject>([SELECT Id,RecordType.DeveloperName FROM EM_Event_vod__c WHERE Id IN :eventIDs]);
        
        // find the list setting for the current object
        for(EMTableEntry newEntry: newEntriesUpdated){
            //System.debug('---------newEntry.parentID: '+newEntry.parentID);
            if(newEntry.parentID == null){
                // There is not event tied to this object, so we cannot do any validaiton
                //system.debug('there is not a parent tied to this activity');
            }else{

                String objectType = '';
                if(newEntry.Operation == 'Insert'){
                    objectType = string.valueOf(newEntry.objectToInsert.getSObjectType());
                }else{
                    objectType = Id.valueOf(newEntry.RecordID).getSObjectType().getDescribe().getName();
                }
                //System.debug('objectType: '+objectType);

                for(LockActivityChildren__c lockSetting: myLockSettings){
                    //System.debug('lockSetting.Object__c: '+lockSetting.Object__c);
                    //System.debug('parentMap: '+parentMap);
                    //System.debug('newEntry.parentID: '+newEntry.parentID);
                    Id newId = newEntry.parentID;
                    if(lockSetting.Object__c == objectType && parentMap.containsKey(newEntry.parentID)
                            && newId.getSObjectType().getDescribe().getName() == lockSetting.Parent_API_Name__c){
                        // we have found the setting
                        //System.debug('Found the setting');
                        String statusField = lockSetting.Parent_Status_Field__c;

                        //System.debug('statusField: '+statusField);

                        sObject myParent = parentMap.get(newEntry.parentID);
                        sObject myEvent;
                        if(newEntry.ActivityID != null){
                            myEvent = eventMap.get(newEntry.ActivityID);
                        }
                        // see if the record type of the parent applies for the validation
                        boolean correctParentRecordType = false;
                        boolean correctActivityRecordType = false;
                        //system.debug((String)myParent.getsObject('RecordType').get('Name'));
                        if(lockSetting.Applicable_Parent_Recordtypes__c != null && lockSetting.Applicable_Parent_Recordtypes__c.contains('All')){
                            correctParentRecordType = true;
                        }else if(lockSetting.Applicable_Parent_Recordtypes__c != null && lockSetting.Applicable_Parent_Recordtypes__c.contains((String)myParent.getsObject('RecordType').get('DeveloperName'))){
                            correctParentRecordType = true;
                        }else{
                            correctParentRecordType = false;
                        }
                        //system.debug('correctParentRecordType: ' + correctParentRecordType);

                        // see if the record type if the activity applies for the validaiton
                        if(lockSetting.Applicable_Activity_Recordtypes__c != null && lockSetting.Applicable_Activity_Recordtypes__c.contains('All')){
                            correctActivityRecordType = true;
                        }else if(lockSetting.Applicable_Activity_Recordtypes__c != null && lockSetting.Applicable_Activity_Recordtypes__c.contains((String)myEvent.getsObject('RecordType').get('DeveloperName'))){
                            correctActivityRecordType = true;
                        }else{
                            correctActivityRecordType = false;
                        }
                        //system.debug('correctActivityRecordType: ' + correctActivityRecordType);
                        //system.debug('correctParentRecordType: ' + correctParentRecordType);
                        //system.debug('Parent Status: ' + (String)myParent.get(statusField));
                        if((String)myParent.get(statusField) == null){return new Map<Id,String>();}
                        if(lockSetting.Parent_Statuses__c.contains((String)myParent.get(statusField)) && correctActivityRecordType && correctParentRecordType){
                            // we do meet the criteria
                            // check the operation and add any needed error messages
                            // check for modify all override
                            //if(lockSetting.ModifyAllOverride__c == true && currentUserProfile.PermissionsModifyAllData == true){
                            //system.debug('Got here');
                            if(lockSetting.ModifyAllOverride__c == true && hasModifyAllData == 1){
                                // this user can modify anything
                                //System.debug('This user can modify anything');
                            }else{
                                //system.debug('adding error');
                                //system.debug(newEntry.Operation);
                                if(newEntry.Operation == 'Update' && lockSetting.EditLock__c == true){
                                    errorMap.put(newEntry.RecordID, System.Label.Locked_Record_Error_Message);
                                }else if(newEntry.Operation == 'Insert' && lockSetting.CreateLock__c == true){
                                    errorMap.put(newEntry.RecordID, System.Label.Locked_Record_Error_Message);
                                }else if(newEntry.Operation == 'Delete' && lockSetting.DeleteLock__c == true){
                                    errorMap.put(newEntry.RecordID, System.Label.Locked_Record_Error_Message);
                                }else{
                                    //system.debug('Operation was not update, insert or delete: ' + newEntry.Operation);
                                }
                            }
                        }
                    }
                }
            }
        }
        return errorMap;
    }
}