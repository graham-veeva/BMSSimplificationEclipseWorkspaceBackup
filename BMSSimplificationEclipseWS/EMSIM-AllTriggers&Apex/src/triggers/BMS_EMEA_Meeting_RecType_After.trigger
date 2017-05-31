/*

Trigger is to change the recordtype of selected detail objects of Meetings in case of Step/Status change.
The desired status names are stored in Custom Settings.

Modified: Viktor 2014-03-04


Modified by: Raphael Krausz <raphael.krausz@veeva.com>
Date: 2014-07-24
Description:
    Changed code structure.
    Changed looking up record types in the database rather than dynamically (as this caused problems).

    The trigger goes through the meeting (medical event) materials, contracts and speakers and updates
    their record types as needed.


Modified by: Raphael Krausz <raphael.krausz@veeva.com>
Date: 2014-08-22
Description:
    Fixed record type associations as per Tristan Theurier's instructions. See "Determining recordTypeName"
    in comments below for the current record type assignations.


Modified by: Raphael Krausz <raphael.krausz@veeva.com>
Date: 2014-12-22
Description:
    Ensured that this works only for FFM meetings.


*/
trigger BMS_EMEA_Meeting_RecType_After on Medical_Event_vod__c (after insert, after update) {
 
 //code block to check if this transaction belongs to legacy Medical Events or new Events Management module
  //Added by Murugesh Naidu (murugesh.naidu@veeva.com) Nov 12, 2015
  //Assumes that groups will either use EM_Event_vod or Medical_Event_vod as the primary starting point and not both

  if(Trigger.isDelete){
        if(Trigger.old[0].EM_Event_vod__c!=null){
            return;
        }
    }
    else{
        if(Trigger.new[0].EM_Event_vod__c!=null){
            return;
        }    
    }

    system.debug('BMS_EMEA_Meeting_RecType_After STARTED with size: ' + Trigger.size);

    // GET THE RELATED OBJECTS into maps so we dont SOQL from cycle
    //Set<Id> meetingIdSet = Trigger.newMap.keySet();
    // We only want to look at FFM meetings, which means that they have an FFM Step
    // Modified by: <raphael.krausz@veeva.com>
    // Modified date: 2014-12-22
    Set<Id> meetingIdSet = new Set<Id>();

    for (Medical_Event_vod__c meeting : Trigger.new) {
        if ( meeting.FFM_Step_BMS_EMEA__c != null ) {
            meetingIdSet.add(meeting.Id);
        }
    }


    List<sObject> sObjectsToUpdateList = new List<sObject>();

    // FETCH record types
    Map<String, RecordType> nameToRecordTypeMap = new Map<String, RecordType>();
    {
        List<RecordType> recordTypes =
            [
                SELECT Id, Name
                FROM RecordType
                WHERE SObjectType IN (
                    'Meeting_Material_BMS_EMEA__c',
                    'Meeting_Contract_BMS_EMEA__c',
                    'Meeting_Speaker_BMS__c'
                )
            ];

        for (RecordType theRecordType : recordTypes) {
            String name = theRecordType.Name;
            nameToRecordTypeMap.put(name, theRecordType);
        }
    }


    System.debug('DEBUG POINT 1');

    // FETCH CUSTOM SETTINGS
    BMS_EMEA_Settings__c settings = BMS_EMEA_Settings__c.getInstance();


    String getSObjectType(SObject theSobject) {
        // Get the SObject type for an object - is it a meeting material, contract or speaker?
        String theSObjectType;
        if ( theSobject.getSObjectType() == Meeting_Material_BMS_EMEA__c.sObjectType ) {
            theSObjectType = 'meetingMaterial';
        } else if (theSobject.getSObjectType() == Meeting_Contract_BMS_EMEA__c.sObjectType ) {
            theSObjectType = 'meetingContract';
        } else {
            theSObjectType = 'meetingSpeaker';
        }
        return theSObjectType;
    }


    void checkAndAddRecordType(String recordTypeName, SObject meetingObject) {
        // Checks the record type of the meeting material/contract/speaker object
        // If needed it updates it and adds it to the list of objects to be updated

        RecordType theRecordType = nameToRecordTypeMap.get(recordTypeName);
        Boolean recordTypeExists = (theRecordType != null);
        Boolean meetingObjectRecordTypeMatches;

        String theSObjectType = getSObjectType(meetingObject);

        if (recordTypeExists) {
            if ( theSObjectType.equals('meetingMaterial') ) {
                Meeting_Material_BMS_EMEA__c meetingMaterialObject = (Meeting_Material_BMS_EMEA__c) meetingObject;
                meetingObjectRecordTypeMatches = (meetingMaterialObject.RecordTypeId == theRecordType.Id);
                if ( ! meetingObjectRecordTypeMatches ) {
                    meetingMaterialObject.RecordTypeId = theRecordType.Id;
                    sObjectsToUpdateList.add(meetingMaterialObject);
                }
            } else if ( theSObjectType.equals('meetingContract') ) {
                Meeting_Contract_BMS_EMEA__c meetingContactObject = (Meeting_Contract_BMS_EMEA__c) meetingObject;
                meetingObjectRecordTypeMatches = (meetingContactObject.RecordTypeId == theRecordType.Id);
                if ( ! meetingObjectRecordTypeMatches ) {
                    meetingContactObject.RecordTypeId = theRecordType.Id;
                    sObjectsToUpdateList.add(meetingContactObject);
                }
            } else {
                Meeting_Speaker_BMS__c meetingSpeakerObject = (Meeting_Speaker_BMS__c) meetingObject;
                meetingObjectRecordTypeMatches = (meetingSpeakerObject.RecordTypeId == theRecordType.Id);
                if ( ! meetingObjectRecordTypeMatches ) {
                    meetingSpeakerObject.RecordTypeId = theRecordType.Id;
                    sObjectsToUpdateList.add(meetingSpeakerObject);
                }
            }
        }

        if ( ( ! recordTypeExists ) ||  (meetingObjectRecordTypeMatches) ) {
            String message = 'RecordType does not need update. Name: '
                             + recordTypeName
                             + ', '
                             + theSObjectType
                             + ' ID: '
                             + meetingObject.Id
                             ;
            System.debug(message);
        }
    }


    Map<String, String> getObjectDetails(SObject theSObject) {
        // returns a map of the FFMStep and Status of the given meeting material/contract/speaker

        String theSObjectType = getSObjectType(theSObject);
        Map<String, String> objectDetails = new Map<String, String>();
        Medical_Event_vod__c theMeeting;
        if ( theSObjectType.equals('meetingMaterial') ) {
            Meeting_Material_BMS_EMEA__c meetingMaterial = (Meeting_Material_BMS_EMEA__c) theSObject;
            theMeeting = meetingMaterial.Meeting_BMS_EMEA__r;
        } else if ( theSObjectType.equals('meetingContract') ) {
            Meeting_Contract_BMS_EMEA__c meetingContract = (Meeting_Contract_BMS_EMEA__c) theSObject;
            theMeeting = meetingContract.Meeting_BMS_EMEA__r;
        } else {
            // SObjectType: 'meetingSpeaker'
            Meeting_Speaker_BMS__c meetingSpeaker = (Meeting_Speaker_BMS__c) theSObject;
            theMeeting = meetingSpeaker.Meeting__r;
        }
        String ffmStep = theMeeting.FFM_Step_BMS_EMEA__c;
        String status  = theMeeting.Status_BMS_CORE__c;

        objectDetails.put('ffmStep', ffmStep);
        objectDetails.put('status', status);

        return objectDetails;
    }


    /*

        Determining recordTypeName
        ==========================

        Planning stage: ffmStep is 'Meeting Planning' AND Status is not 'Submitted - Waiting Approval'

        Approval stage: (ffmStep is 'Meeting Post-Execution' AND Status is 'Approved')
            OR (ffmStep is 'Meeting Planing ' AND Status is 'Submitted - Waiting Approval')

        Completed stage: ffmStep is 'Meeting Post-Execution' AND Status is 'Completed'


        Meeting_Material_BMS_EMEA__c
        ----------------------------

        ffmStep: M.Meeting_BMS_EMEA__r.FFM_Step_BMS_EMEA__c
        Status:  M.Meeting_BMS_EMEA__r.Status_BMS_CORE__c

        When in Planning stage:
            - settings.Meeting_Material_Planning_RTName__c;

        When in Approval stage:
            - settings.Meeting_Material_PostExec_RTName__c;

        When in Completed stage:
            - settings.Meeting_Material_PostExecPTA_RTName__c;


        Meeting_Contract_BMS_EMEA__c
        ----------------------------

        ffmStep: M.Meeting_BMS_EMEA__r.FFM_Step_BMS_EMEA__c
        Status:  M.Meeting_BMS_EMEA__r.Status_BMS_CORE__c

        When in Planning stage:
            - settings.Meeting_Contract_Planning_RTName__c;

        When in Approval stage:
            - settings.Meeting_Contract_PostExec_RTName__c;

        When in Completed stage:
        When (M.Meeting_BMS_EMEA__r.FFM_Step_BMS_EMEA__c == 'Meeting Post-Execution' && M.Meeting_BMS_EMEA__r.Status_BMS_CORE__c == 'Completed')
            - settings.Meeting_Contract_PostExecPTA_RTName__c;


        Meeting_Speaker_BMS__c
        ----------------------

        ffmStep: M.Meeting__r.FFM_Step_BMS_EMEA__c
        Status:  M.Meeting__r.Status_BMS_CORE__c

        When in Planning stage:
            - settings.Meeting_Speaker_Planning_RTName__c;

        When in Approval stage:
            - settings.Meeting_Speaker_PostExec_RTName__c;

        When in Completed stage:
            - settings.Meeting_Speaker_PostExecPTA_RTName__c;

    */

    String getRecordTypeName(SObject meetingObject, String ffmStep, String status) {
        String theSObjectType = getSObjectType(meetingObject);
        String recordTypeName;

        // Figure out the SObject type
        Boolean isMeetingMaterial = theSObjectType.equals('meetingMaterial');
        Boolean isMeetingContract = theSObjectType.equals('meetingContract');
        Boolean isMeetingSpeaker  = theSObjectType.equals('meetingSpeaker');

        // Figure out the meeting type from FFMStep and Status
        Boolean isWaitingApproval = ( ffmStep.equals('Meeting Planning') && status.equals('Submitted - Waiting Approval') );
        Boolean isInPlanning = ( ffmStep.equals('Meeting Planning') && ( ! isWaitingApproval ) );

        Boolean isPostExecution          = ( ffmStep.equals('Meeting Post-Execution') || isWaitingApproval );
        Boolean isPostExecutionApproved  = ( (isPostExecution && status.equals('Approved')) || isWaitingApproval );
        Boolean isPostExecutionCompleted = ( isPostExecution && status.equals('Completed') );

        // Figure out correct record type names
        String planningRecordTypeName;
        String approvalRecordTypeName;
        String completedRecordTypeName;

        if ( isMeetingMaterial ) {
            planningRecordTypeName  = settings.Meeting_Material_Planning_RTName__c;
            approvalRecordTypeName  = settings.Meeting_Material_PostExec_RTName__c;
            completedRecordTypeName = settings.Meeting_Material_PostExecPTA_RTName__c;

        } else if ( isMeetingContract ) {
            planningRecordTypeName  = settings.Meeting_Contract_Planning_RTName__c;
            approvalRecordTypeName  = settings.Meeting_Contract_PostExec_RTName__c;
            completedRecordTypeName = settings.Meeting_Contract_PostExecPTA_RTName__c;

        } else if ( isMeetingSpeaker ) {
            planningRecordTypeName  = settings.Meeting_Speaker_Planning_RTName__c;
            approvalRecordTypeName  = settings.Meeting_Speaker_PostExec_RTName__c;
            completedRecordTypeName = settings.Meeting_Speaker_PostExecPTA_RTName__c;

        }

        // Assign the right record type
        if ( isInPlanning ) {
            recordTypeName = planningRecordTypeName;

        } else if ( isPostExecution ) {
            if ( isPostExecutionApproved ) {
                recordTypeName = approvalRecordTypeName;

            } else if ( isPostExecutionCompleted ) {
                recordTypeName = completedRecordTypeName;
            }
        }

        return recordTypeName;
    }


    void processMeetingComponents(List<SObject> meetingObjectList) {
        // goes through each meeting material/contract/speaker in the list
        // and processes them accordingly

        if (meetingObjectList == null || meetingObjectList.size() < 1) {
            // null or empty list means there is nothing to do - return.
            System.debug('No meetingObjectList!');
            return;
        } else {
            System.debug('meetingObjectList.size(): ' + meetingObjectList.size());
        }

        for (SObject meetingObject : meetingObjectList) {


            Map<String, String> objectDetails = getObjectDetails(meetingObject);

            String ffmStep = objectDetails.get('ffmStep');
            String status  = objectDetails.get('status');

            String recordTypeName = getRecordTypeName(meetingObject, ffmStep, status);


            Boolean blankFfmStep = String.isBlank(ffmStep);
            Boolean blankStatus  = String.isBlank(status);

            if ( blankFfmStep || String.isBlank(status) ) {
                if ( blankFfmStep ) {
                    System.debug('Unable to get ffmStep');
                    // Ensure it is blank, and not null.
                    ffmStep = '';
                } else {
                    System.debug('ffmStep: ' + ffmStep);
                }

                if ( blankStatus ) {
                    System.debug('Unable to get status');
                } else {
                    System.debug('status: ' + status);
                    // Ensure status isn't null even though it is blank
                    status = '';
                }

                system.debug('Unable to get ffmStep and/or status');
                continue;
            }

            if (
                ffmStep.equals('Meeting Planning')
                || ( ffmStep.equals('Meeting Post-Execution') && (status.equals('Approved') ||  status.equals('Completed')) )
            ) {
                checkAndAddRecordType(recordTypeName, meetingObject);
            } else {
                system.debug('Not a valid step/status: ' + ffmStep + '/' + status);
            }
        }
    }


    // GO THROUGH RELATED MATERIALS
    List<Meeting_Material_BMS_EMEA__c> meetingMaterialList =
        [
            SELECT Id,
            RecordTypeId,
            Meeting_BMS_EMEA__c,
            Meeting_BMS_EMEA__r.FFM_Step_BMS_EMEA__c,
            Meeting_BMS_EMEA__r.Status_BMS_CORE__c
            FROM Meeting_Material_BMS_EMEA__c
            WHERE Meeting_BMS_EMEA__c in :meetingIdSet
        ];
    System.debug('meetingMaterialList.size(): ' + meetingMaterialList.size());

    System.debug('About to process meeting materials');
    processMeetingComponents(meetingMaterialList);


    System.debug('DEBUG POINT 2');


    // GO THROUGH RELATED CONTRACTS
    List<Meeting_Contract_BMS_EMEA__c> meetingContractList =
        [
            SELECT Id,
            RecordTypeId,
            Meeting_BMS_EMEA__c,
            Meeting_BMS_EMEA__r.FFM_Step_BMS_EMEA__c,
            Meeting_BMS_EMEA__r.Status_BMS_CORE__c
            FROM Meeting_Contract_BMS_EMEA__c
            WHERE Meeting_BMS_EMEA__c in :meetingIdSet
        ];

    System.debug('About to process meeting contracts');
    processMeetingComponents(meetingContractList);

    System.debug('DEBUG POINT 3');

    // GO THROUGH RELATED SPEAKERS
    List<Meeting_Speaker_BMS__c> meetingSpeakerList =
        [
            SELECT Id,
            RecordTypeId, Meeting__c,
            Meeting__r.FFM_Step_BMS_EMEA__c,
            Meeting__r.Status_BMS_CORE__c
            FROM Meeting_Speaker_BMS__c
            WHERE Meeting__c in :meetingIdSet
        ];

    System.debug('About to process meeting speakers');
    processMeetingComponents(meetingSpeakerList);

    System.debug('meetingIdSet: ' + meetingIdSet);

    System.debug('DEBUG POINT 4');


    // UPDATE THE RECORDS
    Integer numberOfRecordsToUpdate = sObjectsToUpdateList.size();
    System.debug('Records to update: ' + numberOfRecordsToUpdate);

    if ( numberOfRecordsToUpdate > 0 ) {
        update sObjectsToUpdateList;
    }

    system.debug('BMS_EMEA_Meeting_RecType_After FINISHED');
}