/** BMS ACN - October 5th : Q3 GRM Release
    @ Created by Kowsar Shaik
    
    Rationale: System should provide end users the ability to delete meeting speakers in the planning and post execution phase.
    Trigger to Prevent users from deleting meeting speakers associated with meetings which are closed/locked/cancelled. 
    Trigger to Prevent deletion of meeting speakers with meeting of activity "Speaker Meeting"and with ONLY 1 meeting speaker and part of the approval process. 
    Trigger to Recalculate the Honorarium values upon deletion/undeletion.
    
*/

/** BMS ACN - September 2016 : Q3 GRM Release
    @ Updated by Ashok Vardhan Reddy
    
    Trigger updated to prevent deletion of meetings in Post Execustion (or) pending for approval.
    
*/

trigger Meeting_Speaker_Delete_BMS_EMEA on Meeting_Speaker_BMS__c (before delete,after delete,after undelete) 
{
List<Medical_Event_vod__c> MeetingIdToMeeting;
If(Trigger.isBefore && Trigger.isDelete)
  {
    Map<ID,RecordType> RecordTypeMap = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'Medical_Event_vod__c']);
        Set<Id> meetingIds =new Set<Id>(); 
        for (Meeting_Speaker_BMS__c ms : trigger.old) 
            {
                meetingIds.add(ms.Meeting__c);
                System.Debug('Meeting Is -->' + ms.Meeting__c);
                system.debug('enter the loop------->: ' + ms.Meeting__r.RecordTypeId);
            }
    Map<Id,Medical_Event_vod__c> MeetingIdToMeeting1  = new Map<Id,Medical_Event_vod__c>([SELECT Id,Status_BMS_CORE__c,RecordTypeID,Approved_Rejected_Once_BMS_EMEA__c ,Activity_Type_BMS_EMEA__c,FFM_Activity_Type_BMS_EMEA__c,Number_of_Speakers_BMS_EMEA__c
                                                                                        FROM Medical_Event_vod__c
                                                                                      WHERE Id IN : meetingIds]);
        for(Meeting_Speaker_BMS__c ms : trigger.old)
            { 
            if( MeetingIdToMeeting1.get(ms.Meeting__c).FFM_Activity_Type_BMS_EMEA__c == 'Speaker Meeting' && MeetingIdToMeeting1.get(ms.Meeting__c).Number_of_Speakers_BMS_EMEA__c == 1 && MeetingIdToMeeting1.get(ms.Meeting__c).Approved_Rejected_Once_BMS_EMEA__c == TRUE )
                {
                ms.addError(Label.BMS_EMEA_Meeting_Speaker_Delete);
                }     
            else if(RecordTypeMap.get(MeetingIdToMeeting1.get(ms.Meeting__c).RecordTypeID).name == 'BMS - EMEA - 2. Meeting Post-Execution' || (RecordTypeMap.get(MeetingIdToMeeting1.get(ms.Meeting__c).RecordTypeID).name == 'BMS - EMEA - 1. Meeting Plan' && MeetingIdToMeeting1.get(ms.Meeting__c).Status_BMS_CORE__c  == 'Submitted - Waiting Approval')|| RecordTypeMap.get(MeetingIdToMeeting1.get(ms.Meeting__c).RecordTypeID).name == 'BMS - EMEA - 3. Meeting Close Out'|| RecordTypeMap.get(MeetingIdToMeeting1.get(ms.Meeting__c).RecordTypeID).name =='BMS - EMEA - 4. Meeting Cancelled'||RecordTypeMap.get(MeetingIdToMeeting1.get(ms.Meeting__c).RecordTypeID).name == 'BMS - EMEA - Meeting FFM abbreviated Access'|| RecordTypeMap.get(MeetingIdToMeeting1.get(ms.Meeting__c).RecordTypeID).name =='BMS - EMEA - H2O Meeting - Locked'|| RecordTypeMap.get(MeetingIdToMeeting1.get(ms.Meeting__c).RecordTypeID).name =='BMS - EMEA - Meeting FFM abbreviated Closed')
              {
               system.debug('check the record type---->: ' + RecordTypeMap.get(MeetingIdToMeeting1.get(ms.Meeting__c).RecordTypeID).name);
               ms.addError(Label.BMS_EMEA_Meeting_Speaker_Delete_RT);
               }
            }                                                                          
   }
     
if(trigger.isAfter && Trigger.isdelete)
 {
        Map<ID,RecordType> RecordTypeMap = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'Medical_Event_vod__c']);
        Set<Id> meetingIds =new Set<Id>();
        Map<Id,Set<ID>> MeetingIdsMSIdSet = new Map<Id,Set<ID>>();
        Map<ID,ID> MSMeetingIDMap = new Map<id,id>();
        for(Meeting_Speaker_BMS__c ms : trigger.old)
            {
                meetingIds.add(ms.Meeting__c);
                MSMeetingIDMap.put(ms.ID,ms.Meeting__c);
            if(MeetingIdsMSIdSet.containskey(ms.Meeting__c))
                {
                    MeetingIdsMSIdSet.get(ms.Meeting__c).add(ms.ID);
                }
            else
                {
                    MeetingIdsMSIdSet.put(ms.Meeting__c,new Set<ID>{ms.ID});
                }
            }
        Map<Id,Medical_Event_vod__c> meetingMap = new Map<Id,Medical_Event_vod__c>([SELECT Id,Honorarium_Planned_BMS_EMEA__c,Honorarium_Actual_BMS_EMEA__c,RecordTypeId FROM Medical_Event_vod__c WHERE Id IN :meetingIds]);
        List<Medical_Event_vod__c> UpdatedMeeetingList = new List<Medical_Event_vod__c>();        
        for(ID MeetingMapId : meetingMap.Keyset())
            {
                Medical_Event_vod__c meeting =  meetingMap.get(MeetingMapId);
                Set<ID> DelMeetingSpeakerIds =  MeetingIdsMSIdSet.get(MeetingMapId);
                System.debug('MeetingSpeakerIds'+DelMeetingSpeakerIds);
                Decimal TotalFromDeletedMS = 0;
                for(ID MeetingSpeakerId : DelMeetingSpeakerIds) 
                    {
                        Meeting_Speaker_BMS__c MSD = trigger.oldmap.get(MeetingSpeakerId);
                        TotalFromDeletedMS = TotalFromDeletedMS + MSD.Total_BMS_EMEA__c;
                        System.debug('TotalFrom'+TotalFromDeletedMS);
                    }   
                for (Meeting_Speaker_BMS__c ms : trigger.old)
                    {
                    if(TotalFromDeletedMS>0 &&  RecordTypeMap.get(meeting.RecordTypeId).Name == 'BMS - EMEA - 1. Meeting Plan')
                        {
           
                            meeting.Honorarium_Planned_BMS_EMEA__c = meeting.Honorarium_Planned_BMS_EMEA__c - TotalFromDeletedMS;
                            UpdatedMeeetingList.add(meeting);
                        }
                else if(TotalFromDeletedMS>0 && RecordTypeMap.get(meeting.RecordTypeId).Name == 'BMS - EMEA - 2. Meeting Post-Execution')
                        {
                            meeting.Honorarium_Actual_BMS_EMEA__c = meeting.Honorarium_Actual_BMS_EMEA__c - TotalFromDeletedMS;
                            meeting.Honorarium_Planned_BMS_EMEA__c = meeting.Honorarium_Planned_BMS_EMEA__c - TotalFromDeletedMS;
                            UpdatedMeeetingList.add(meeting);
                    }
        
                    }
        
            }
     
     Update UpdatedMeeetingList;       


}
if(trigger.isAfter && Trigger.isUndelete)
{
Map<ID,RecordType> RecordTypeMap = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'Medical_Event_vod__c']);
  Set<Id> meetingIds =new Set<Id>();
  Map<Id,Set<ID>> MeetingIdsMSIdSet = new Map<Id,Set<ID>>();
  Map<ID,ID> MSMeetingIDMap = new Map<id,id>();
   for(Meeting_Speaker_BMS__c ms : trigger.new)
    {
        meetingIds.add(ms.Meeting__c);
        MSMeetingIDMap.put(ms.ID,ms.Meeting__c);
        if(MeetingIdsMSIdSet.containskey(ms.Meeting__c))
          {
              MeetingIdsMSIdSet.get(ms.Meeting__c).add(ms.ID);
          }
        else
          {
              MeetingIdsMSIdSet.put(ms.Meeting__c,new Set<ID>{ms.ID});
          }
     }
      
   Map<Id,Medical_Event_vod__c> meetingMap = new Map<Id,Medical_Event_vod__c>([SELECT Id,Honorarium_Planned_BMS_EMEA__c,Honorarium_Actual_BMS_EMEA__c,RecordTypeId FROM Medical_Event_vod__c WHERE Id IN :meetingIds]);
   List<Medical_Event_vod__c> UpdatedMeeetingList = new List<Medical_Event_vod__c>();        
   for(ID MeetingMapId : meetingMap.Keyset())
    {
        Medical_Event_vod__c meeting =  meetingMap.get(MeetingMapId);
        Set<ID> DelMeetingSpeakerIds =  MeetingIdsMSIdSet.get(MeetingMapId);
        System.debug('MeetingSpeakerIds-------------->'+DelMeetingSpeakerIds);
        Decimal TotalFromDeletedMS = 0;
        for(ID MeetingSpeakerId : DelMeetingSpeakerIds) 
        {
        System.debug('DelMeetings-------------->'+MeetingSpeakerId );
        
          Meeting_Speaker_BMS__c MSD = trigger.newmap.get(MeetingSpeakerId);
          TotalFromDeletedMS = TotalFromDeletedMS + MSD.Total_BMS_EMEA__c;
          System.debug('TotalFrom'+TotalFromDeletedMS);
        }
        for (Meeting_Speaker_BMS__c ms : trigger.new)
        {
        System.debug('TotalFromdelted->'+ms.Id);
        if(TotalFromDeletedMS>0 &&  RecordTypeMap.get(meeting.RecordTypeId).Name == 'BMS - EMEA - 1. Meeting Plan')
        {
        System.debug('TotalFromdeltedIF--->->'+RecordTypeMap.get(meeting.RecordTypeId).Name);
           
          meeting.Honorarium_Planned_BMS_EMEA__c +=  TotalFromDeletedMS;
          UpdatedMeeetingList.add(meeting);
        }
        else if(TotalFromDeletedMS>0 && RecordTypeMap.get(meeting.RecordTypeId).Name == 'BMS - EMEA - 2. Meeting Post-Execution')
        {
          meeting.Honorarium_Actual_BMS_EMEA__c +=  TotalFromDeletedMS;
          meeting.Honorarium_Planned_BMS_EMEA__c +=  TotalFromDeletedMS;
          UpdatedMeeetingList.add(meeting);
        }
        
        }
        
     }
     
    Update UpdatedMeeetingList; 

}

}