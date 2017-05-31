/*
    Modification: Fixed problem obtaining record type - now uses DB look-up.
    Modified by: Raphael Krausz <raphael.krausz@veeva.com>
    Date: 2014-07-24

    Modified by: <raphael.krausz@veeva.com>
    Modified date: 2014-12-15
    We only want those meetings which are FFM


*/
trigger MeetingMaterialCreationOnMeetingInsert_BMS_EMEA on Medical_Event_vod__c (after insert) {

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
    public id masterFileId;
    public id meetingId;
    public List<Master_File_Material_BMS_EMEA__c> masterFileMaterials = new List<Master_File_Material_BMS_EMEA__c>();
    public List<Meeting_Material_BMS_EMEA__c> insertMeetingMaterialList = new List<Meeting_Material_BMS_EMEA__c>();
    public Id insertRecordTypeId;

    public List<Master_File_Participant_BMS_EMEA__c> masterFileParticipants = new List<Master_File_Participant_BMS_EMEA__c>();
    public List<Meeting_Planned_Participant_BMS_EMEA__c> insertMeetingPlannedParticipantsList = new List<Meeting_Planned_Participant_BMS_EMEA__c>();

    for (Medical_Event_vod__c ME : Trigger.new) {
        // Ignore non-FFM meetings
        if ( ME.FFM_Step_BMS_EMEA__c == null ) {
            continue;
        }

        meetingId = ME.Id;
        masterFileId = ME.Master_File_BMS_EMEA__c;
    }

    if ( meetingId == null || masterFileId == null ) {
        System.debug('Not an FFM meeting');
        return;
    }


    //---------------Copy the Master File Materials into the Meeting Material table ----------------------------------------------------


    masterFileMaterials = [select id, Material_BMS_EMEA__c, Ref_No_BMS_EMEA__c, Status_BMS_EMEA__c from Master_File_Material_BMS_EMEA__c where Master_File_BMS_EMEA__c = : masterFileId];

    if ( ! masterFileMaterials.isEmpty() ) {

        Id meetingMaterialRTID;

        //GET the a RT for the MM
        String RTname = String.valueOf(BMS_EMEA_Settings__c.getInstance().get('Meeting_Material_Planning_RTName__c'));

        System.debug('DEBUG POINT: RTname - ' + RTname);

        RecordType theRecordType =
            [
                SELECT Id, Name, DeveloperName
                FROM RecordType
                WHERE Name = :RTname AND Sobjecttype = 'Meeting_Material_BMS_EMEA__c'
            ];

        if (theRecordType == null) {
            System.debug('theRecordType is NULL!');
        } else {
            System.debug('theRecordType.Id: ' + theRecordType.Id);
            System.debug('theRecordType.Name: ' + theRecordType.Name);
            System.debug('theRecordType.DeveloperName: ' + theRecordType.DeveloperName);
        }

        if (theRecordType != null) {
            meetingMaterialRTID = theRecordType.Id;
        }

        for (Master_File_Material_BMS_EMEA__c masterFileMaterials2 : masterFileMaterials) {
            Meeting_Material_BMS_EMEA__c meetingMaterial = new Meeting_Material_BMS_EMEA__c();
            meetingMaterial.Material_BMS_EMEA__c = masterFileMaterials2.Material_BMS_EMEA__c;
            meetingMaterial.Ref_No_BMS_EMEA__c   = masterFileMaterials2.Ref_No_BMS_EMEA__c;
            meetingMaterial.Status_BMS_EMEA__c   = masterFileMaterials2.Status_BMS_EMEA__c;


            if (meetingMaterialRTID != null) {
                //Forced RT ID based on Tristan's request by Viktor 2014-03-06
                meetingMaterial.RecordTypeId = meetingMaterialRTID;
            }

            meetingMaterial.Meeting_BMS_EMEA__c  = meetingId;
            insertMeetingMaterialList.add(meetingMaterial);

            System.debug('Adding new Meeting_Material_BMS_EMEA__c!');
            System.debug('Material_BMS_EMEA__c: '   + meetingMaterial.Material_BMS_EMEA__c);
            System.debug('Ref_No_BMS_EMEA__c: '     + meetingMaterial.Ref_No_BMS_EMEA__c);
            System.debug('Status_BMS_EMEA__c: '     + meetingMaterial.Status_BMS_EMEA__c);
            System.debug('RecordTypeId: '           + meetingMaterial.RecordTypeId);
            System.debug('Meeting_BMS_EMEA__c: '    + meetingMaterial.Meeting_BMS_EMEA__c);
            System.debug('*********************');
        }

        system.debug('-- MAterials--' + insertMeetingMaterialList);
        insert insertMeetingMaterialList;
        System.debug('inserted!');
    }


    //---------------Copy the Master File Planned Participants into the Meeting Material Planned Participants---------------------------------


    System.debug('DEBUG POINT: A');

    Id MasterSponsoredId = [Select  Id From RecordType where SobjectType = 'Master_File_Participant_BMS_EMEA__c' and Name = 'BMS - EMEA - Sponsored'].Id;
    Id MasterAudienceId = [Select  Id From RecordType where SobjectType = 'Master_File_Participant_BMS_EMEA__c' and Name = 'BMS - EMEA - Audience'].Id;
    Id MasterBMSEmployeeId = [Select  Id From RecordType where SobjectType = 'Master_File_Participant_BMS_EMEA__c' and Name = 'BMS - EMEA - BMS Employee'].Id;
    Id MasterJVPartnerEmployeeId = [Select  Id From RecordType where SobjectType = 'Master_File_Participant_BMS_EMEA__c' and Name = 'BMS - EMEA - JV Partner Employee'].Id;
    Id MasterSpeakerId = [Select  Id From RecordType where SobjectType = 'Master_File_Participant_BMS_EMEA__c' and Name = 'BMS - EMEA - Speaker'].Id;

    System.debug('DEBUG POINT: B');

    Id MeetingSponsoredId = [Select  Id From RecordType where SobjectType = 'Meeting_Planned_Participant_BMS_EMEA__c' and Name = 'BMS - EMEA - Sponsored'].Id;
    Id MeetingAudienceId = [Select  Id From RecordType where SobjectType = 'Meeting_Planned_Participant_BMS_EMEA__c' and Name = 'BMS - EMEA - Audience'].Id;
    Id MeetingBMSEmployeeId = [Select  Id From RecordType where SobjectType = 'Meeting_Planned_Participant_BMS_EMEA__c' and Name = 'BMS - EMEA - BMS Employee'].Id;
    Id MeetingJVPartnerEmployeeId = [Select  Id From RecordType where SobjectType = 'Meeting_Planned_Participant_BMS_EMEA__c' and Name = 'BMS - EMEA - JV Partner Employee'].Id;
    Id MeetingSpeakerId = [Select  Id From RecordType where SobjectType = 'Meeting_Planned_Participant_BMS_EMEA__c' and Name = 'BMS - EMEA - Speaker'].Id;

    System.debug('DEBUG POINT: C');

    masterFileParticipants = [select id, Number_per_Meeting_BMS_EMEA__c , TherArea_Expertise_Specialty_BMS_EMEA__c, RecordTypeId from Master_File_Participant_BMS_EMEA__c  where Master_File_BMS_EMEA__c = : masterFileId];

    System.debug('DEBUG POINT: D');


    if ( ! masterFileParticipants.isEmpty() ) {

        System.debug('DEBUG POINT: E');

        for (Master_File_Participant_BMS_EMEA__c masterFileParticipants2 : masterFileParticipants) {

            if (masterFileParticipants2.RecordTypeId == MasterSponsoredId) {
                insertRecordTypeId = MeetingSponsoredId;
            } else if (masterFileParticipants2.RecordTypeId == MasterAudienceId) {
                insertRecordTypeId = MeetingAudienceId;
            } else if (masterFileParticipants2.RecordTypeId == MasterBMSEmployeeId) {
                insertRecordTypeId = MeetingBMSEmployeeId;
            } else if (masterFileParticipants2.RecordTypeId == MasterJVPartnerEmployeeId) {
                insertRecordTypeId = MeetingJVPartnerEmployeeId;
            } else if (masterFileParticipants2.RecordTypeId == MasterSpeakerId) {
                insertRecordTypeId = MeetingSpeakerId;
            }
            System.debug('DEBUG POINT: F');


            Meeting_Planned_Participant_BMS_EMEA__c meetingPlannedParticipant = new Meeting_Planned_Participant_BMS_EMEA__c();
            meetingPlannedParticipant.Number_BMS_EMEA__c = masterFileParticipants2.Number_per_Meeting_BMS_EMEA__c;
            meetingPlannedParticipant.Function_TherArea_Specialty_BMS_EMEA__c = masterFileParticipants2.TherArea_Expertise_Specialty_BMS_EMEA__c;
            meetingPlannedParticipant.Company_BMS_EMEA__c = masterFileParticipants2.TherArea_Expertise_Specialty_BMS_EMEA__c;
            meetingPlannedParticipant.RecordTypeId = insertRecordTypeId;
            meetingPlannedParticipant.Meeting_BMS_EMEA__c = meetingId;
            insertMeetingPlannedParticipantsList.add(meetingPlannedParticipant);

            System.debug('DEBUG POINT: G');

        }
        System.debug('----------------------------------------------insertMeetingPlannedParticipantsList----------------------------------------------' + insertMeetingPlannedParticipantsList);
        insert insertMeetingPlannedParticipantsList;
    }



}