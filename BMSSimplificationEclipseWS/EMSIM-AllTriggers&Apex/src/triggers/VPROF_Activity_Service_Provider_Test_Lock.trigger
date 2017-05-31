trigger VPROF_Activity_Service_Provider_Test_Lock on EM_Event_Speaker_vod__c (before insert, before update, before delete) {

    /*
    ** This trigger can be used on any object that should be locked based on the status is it's parent. When puting this
    ** trigger on a new object, change the trigger name and the trigger object (above) as well as the two strings 
    ** "lookupToActivity" and "lookupToParent" (below). This trigger will only work on objects that are a child of
    ** both the parent and the activity referenced below. The parent and the activity can be the same. The parent object's
    ** status will be checked during validation. The Activity's record type will be checked during validation.
    ** This trigger can also be placed on the parent/activity object. If this is the case, the Strings below should be 
    ** set to 'Id'.
    */

    private EMLockUtility lockUtil = new EMLockUtility();
    List<EMTableEntry> newEntries = new List<EMTableEntry>();
    Map<Id,String> errorMap = new Map<Id,String>();

    // get all of the needed data to pass to the apex class
    if(!Trigger.isDelete){
        for(sObject theThing: Trigger.new){
            EMTableEntry newEntry = new EMTableEntry();
            newEntry.RecordID = String.valueOf(theThing.get('Id'));
            newEntry.UserProfileID = userinfo.getProfileId();
            newEntry.objectToInsert = theThing;
            if(Trigger.isInsert){
                newEntry.Operation = 'Insert';
            }else if(Trigger.isUpdate){
                newEntry.Operation = 'Update';
            }
            newEntries.add(newEntry);
        }
    }else if(Trigger.isDelete){
        for(sObject theThing: Trigger.old){
            EMTableEntry newEntry = new EMTableEntry();
            newEntry.RecordID = String.valueOf(theThing.get('Id'));
            newEntry.UserProfileID = userinfo.getProfileId();
            newEntry.Operation = 'Delete';
            newEntry.objectToInsert = theThing;
            newEntries.add(newEntry);
        }
    }
        
    // call the apex class, passing the needed information
    errorMap = lockUtil.EMLockUtilityTestIsLocked(newEntries);
    
    // add the errors from the map
    if(!Trigger.isDelete){
        for(sObject theThing: Trigger.new){
            String errorMessage = errorMap.get(theThing.Id);
            if(errorMessage != null){
                theThing.addError(errorMessage);
            }
        }
    }else if(Trigger.isDelete){
        for(sObject theThing: Trigger.old){
            String errorMessage = errorMap.get(theThing.Id);
            if(errorMessage != null){
                theThing.addError(errorMessage);
            }
        }
    }
}