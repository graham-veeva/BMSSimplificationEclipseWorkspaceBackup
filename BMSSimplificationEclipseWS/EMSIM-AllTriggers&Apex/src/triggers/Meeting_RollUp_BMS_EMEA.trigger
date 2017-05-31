trigger Meeting_RollUp_BMS_EMEA on Medical_Event_vod__c (after insert, after update, after delete) {

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
   
    //Set of Masterfile ids
    Set<Id> masterFilesIds = new set<Id>();


    List<Medical_Event_vod__c> meetingsList;
    if ( trigger.isDelete ) {
        meetingsList = Trigger.old;
    } else {
        meetingsList = Trigger.new;
    }

    // We only want those meetings which are FFM
    // Modified by: <raphael.krausz@veeva.com>
    // Modified date: 2014-12-15
    for (Medical_Event_vod__c meeting : meetingsList) {
        if ( meeting.Master_File_BMS_EMEA__c != null ) {
            masterFilesIds.add(meeting.Master_File_BMS_EMEA__c);
        }
    }


    system.debug('');

    //list of masterfiles
    list<Master_File_BMS_EMEA__c> relatedMasterfiles = [select id, Total_Planned_Cost_BMS_EMEA__c, Total_Actual_Cost_BMS_EMEA__c, Total_number_of_Meetings_BMS_EMEA__c, Total_number_of_Meeting_PostExc_BMS_EMEA__c, Total_number_of_Meeting_Plans_BMS_EMEA__c  from Master_File_BMS_EMEA__c where id in:masterFilesIds];

    //get list of all related meetings
    list<Medical_Event_vod__c> relatedMeetings = [select id, Recordtype.Name, Planned_End_Date_BMS_EMEA__c, End_Date_vod__c, Master_File_BMS_EMEA__c, FFM_Step_BMS_EMEA__c, Status_BMS_CORE__c, Total_Planned_BMS_EMEA__c, Total_Actual_BMS_EMEA__c from Medical_Event_vod__c where Master_File_BMS_EMEA__c in:masterFilesIds];

    //Map each masterfile with its list of meetings
    map<id, list<Medical_Event_vod__c>> masterFileToMeetingsList = new map<id, list<Medical_Event_vod__c>>();

    for (id masterfile : masterFilesIds) {

        list<Medical_Event_vod__c> meetings = new list<Medical_Event_vod__c>();

        for (Medical_Event_vod__c meeting : relatedMeetings) {

            if (meeting.Master_File_BMS_EMEA__c == masterfile) {

                meetings.add(meeting);
            }
        }

        masterFileToMeetingsList.put(masterfile, meetings);
    }

    //Roll Up Process for each masterfile

    for (Master_File_BMS_EMEA__c masterfile : relatedMasterfiles) {

        masterfile.Total_number_of_Meetings_BMS_EMEA__c = masterFileToMeetingsList.get(masterfile.id).size();

        integer countPlanned = 0;
        integer countPost = 0;

        double plannedCost = 0;
        double actualCost = 0;

        double JanPlanned = 0;
        double FebPlanned = 0;
        double MarPlanned = 0;
        double AprPlanned = 0;
        double MayPlanned = 0;
        double JunPlanned = 0;
        double JulPlanned = 0;
        double AugPlanned = 0;
        double SepPlanned = 0;
        double OctPlanned = 0;
        double NovPlanned = 0;
        double DecPlanned = 0;

        double JanCompleted = 0;
        double FebCompleted = 0;
        double MarCompleted = 0;
        double AprCompleted = 0;
        double MayCompleted = 0;
        double JunCompleted = 0;
        double JulCompleted = 0;
        double AugCompleted = 0;
        double SepCompleted = 0;
        double OctCompleted = 0;
        double NovCompleted = 0;
        double DecCompleted = 0;

        //Roll up Meeting list
        for (Medical_Event_vod__c meeting : masterFileToMeetingsList.get(masterfile.id)) {

            if ((meeting.FFM_Step_BMS_EMEA__c == 'Meeting Planning' && (meeting.Status_BMS_CORE__c == 'Saved' ||
                    meeting.Status_BMS_CORE__c == 'Submitted - Waiting Approval')) ||
                    (meeting.FFM_Step_BMS_EMEA__c == 'Meeting Post-Execution' && meeting.Status_BMS_CORE__c == 'Approved')) {

                /*Moved to new logic
                countPlanned++;
                plannedCost += meeting.Total_Planned_BMS_EMEA__c;*/

                //Roll up monthly data
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 1) {

                    JanPlanned ++;
                }
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 2) {

                    FebPlanned ++;
                }
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 3) {

                    MarPlanned ++;
                }
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 4) {

                    AprPlanned ++;
                }
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 5) {

                    MayPlanned ++;
                }
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 6) {

                    JunPlanned ++;
                }
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 7) {

                    JulPlanned ++;
                }
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 8) {

                    AugPlanned ++;
                }
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 9) {

                    SepPlanned ++;
                }
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 10) {

                    OctPlanned ++;
                }
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 11) {

                    NovPlanned ++;
                }
                if (meeting.Planned_End_Date_BMS_EMEA__c.month() == 12) {

                    DecPlanned ++;
                }

                system.debug('ERIK PLANNED JUNE: ' + JunPlanned + ' MEETING TYPE: ' + meeting.FFM_Step_BMS_EMEA__c + ' STATUS: ' + meeting.Status_BMS_CORE__c);

            }

            if (meeting.FFM_Step_BMS_EMEA__c == 'Meeting Post-Execution' && (meeting.Status_BMS_CORE__c == 'Completed' ||
                    meeting.Status_BMS_CORE__c == 'Closed' )) {
                //if(meeting.FFM_Step_BMS_EMEA__c == 'Meeting Planning' && meeting.Status_BMS_CORE__c == 'Completed'){

                /*Moved to new logic
                countPost++;
                actualCost += meeting.Total_Actual_BMS_EMEA__c;*/

                //Roll up monthly data
                if (meeting.End_Date_vod__c.month() == 1) {

                    JanCompleted ++;
                }
                if (meeting.End_Date_vod__c.month() == 2) {

                    FebCompleted ++;
                }
                if (meeting.End_Date_vod__c.month() == 3) {

                    MarCompleted ++;
                }
                if (meeting.End_Date_vod__c.month() == 4) {

                    AprCompleted ++;
                }
                if (meeting.End_Date_vod__c.month() == 5) {

                    MayCompleted ++;
                }
                if (meeting.End_Date_vod__c.month() == 6) {

                    JunCompleted ++;
                }
                if (meeting.End_Date_vod__c.month() == 7) {

                    JulCompleted ++;
                }
                if (meeting.End_Date_vod__c.month() == 8) {

                    AugCompleted ++;
                }
                if (meeting.End_Date_vod__c.month() == 9) {

                    SepCompleted ++;
                }
                if (meeting.End_Date_vod__c.month() == 10) {

                    OctCompleted ++;
                }
                if (meeting.End_Date_vod__c.month() == 11) {

                    NovCompleted ++;
                }
                if (meeting.End_Date_vod__c.month() == 12) {

                    DecCompleted ++;
                }

                system.debug('ERIK COMPLETED JUNE: ' + JunCompleted + ' MEETING TYPE: ' + meeting.FFM_Step_BMS_EMEA__c + ' STATUS: ' + meeting.Status_BMS_CORE__c);


            }

            //New rollup logic defined by Tristan, done by Viktor 2014-03-21
            if (meeting.FFM_Step_BMS_EMEA__c == 'Meeting Planning' && meeting.Status_BMS_CORE__c <> 'Rejected') { //1A
                //Meeting Count and Total_Planned_BMS_EMEA__c rolls up into the MF.Planned Meetings and MF.Planned Number
                countPlanned++;
                plannedCost += meeting.Total_Planned_BMS_EMEA__c;
            } else if (meeting.FFM_Step_BMS_EMEA__c == 'Meeting Planning' && meeting.Status_BMS_CORE__c <> 'Rejected') { //1B
                //No roll-up
            } else if (meeting.FFM_Step_BMS_EMEA__c == 'Meeting Post-Execution' && meeting.Status_BMS_CORE__c <> 'Completed' && meeting.Status_BMS_CORE__c <> 'Closed') { //2A
                //Meeting Count and Total_Planned_BMS_EMEA__c rolls up into the MF.Planned Meetings and MF.Planned Number
                countPost++;
                plannedCost += meeting.Total_Planned_BMS_EMEA__c;
            } else if (meeting.FFM_Step_BMS_EMEA__c == 'Meeting Post-Execution' && meeting.Status_BMS_CORE__c == 'Completed') { //2B
                //Meeting Count and Total_Actual_BMS_EMEA__c rolls up into the MF.Completed Meetings and MF.Completed Number
                countPost++;
                actualCost += meeting.Total_Actual_BMS_EMEA__c;
            } else if (meeting.FFM_Step_BMS_EMEA__c == 'Meeting Post-Execution' && meeting.Status_BMS_CORE__c == 'Closed') { //3
                //Meeting Count and Total_Actual_BMS_EMEA__c rolls up into the MF.Completed Meetings and MF.Completed Number (whatever the Meeting Status is).
                countPost++;
                actualCost += meeting.Total_Actual_BMS_EMEA__c;
            } if (meeting.Status_BMS_CORE__c == 'Cancelled') {
                actualCost -= meeting.Total_Planned_BMS_EMEA__c;

           }
            


        }

        masterfile.Total_number_of_Meeting_Plans_BMS_EMEA__c = countPlanned;
        masterfile.Total_Planned_Cost_BMS_EMEA__c = plannedCost;

        masterfile.RollUp_Jan_Planned_BMS_EMEA__c = JanPlanned;
        masterfile.RollUp_Feb_Planned_BMS_EMEA__c = FebPlanned;
        masterfile.RollUp_Mar_Planned_BMS_EMEA__c = MarPlanned;
        masterfile.RollUp_Apr_Planned_BMS_EMEA__c = AprPlanned;
        masterfile.RollUp_May_Planned_BMS_EMEA__c = MayPlanned;
        masterfile.RollUp_Jun_Planned_BMS_EMEA__c = JunPlanned;
        masterfile.RollUp_Jul_Planned_BMS_EMEA__c = JulPlanned;
        masterfile.RollUp_Aug_Planned_BMS_EMEA__c = AugPlanned;
        masterfile.RollUp_Sep_Planned_BMS_EMEA__c = SepPlanned;
        masterfile.RollUp_Oct_Planned_BMS_EMEA__c = OctPlanned;
        masterfile.RollUp_Nov_Planned_BMS_EMEA__c = NovPlanned;
        masterfile.RollUp_Dec_Planned_BMS_EMEA__c = DecPlanned;

        masterfile.Total_number_of_Meeting_PostExc_BMS_EMEA__c = countPost;
        masterfile.Total_Actual_Cost_BMS_EMEA__c  = actualCost;

        masterfile.RollUp_Jan_Completed_BMS_EMEA__c = JanCompleted;
        masterfile.RollUp_Feb_Completed_BMS_EMEA__c = FebCompleted;
        masterfile.RollUp_Mar_Completed_BMS_EMEA__c = MarCompleted;
        masterfile.RollUp_Apr_Completed_BMS_EMEA__c = AprCompleted;
        masterfile.RollUp_May_Completed_BMS_EMEA__c = MayCompleted;
        masterfile.RollUp_Jun_Completed_BMS_EMEA__c = JunCompleted;
        masterfile.RollUp_Jul_Completed_BMS_EMEA__c = JulCompleted;
        masterfile.RollUp_Aug_Completed_BMS_EMEA__c = AugCompleted;
        masterfile.RollUp_Sep_Completed_BMS_EMEA__c = SepCompleted;
        masterfile.RollUp_Oct_Completed_BMS_EMEA__c = OctCompleted;
        masterfile.RollUp_Nov_Completed_BMS_EMEA__c = NovCompleted;
        masterfile.RollUp_Dec_Completed_BMS_EMEA__c = DecCompleted;

    }

    //Update the masterfiles

    update relatedMasterfiles;

}