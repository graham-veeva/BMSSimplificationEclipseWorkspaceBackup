/*
Req 761: The system must provide the ability to populate the Honororia costs from a Meeting Plan with the sum of the honororia costs of each Speaker.
Notes TT: I need Meeting Speaker information to roll up in Meetings (lookup relantionship only):
- Sum of Speakers costs (Speaker.Total_BMS_EMEA__c) to roll up. There are 2 Number fields in Meeting already (Honorarium_Planned_BMS_EMEA__c & Honorarium_Actual_BMS_EMEA__c).
Information should roll-up to the Planned Honorarium when the FFM Step of the Meeting is ‘Meeting Planning’.
When ‘Meeting Post-Execution’, it should roll-up to the Actual Costs.
- Number of speakers: count of Speaker records.
You will need to create a field in the Meeting object.
Field not exposed in layouts.
*/
//recalculate the rollup for all the meetings affected
trigger Meeting_Speaker_Rollup_BMS_EMEA on Meeting_Speaker_BMS__c (after insert, after update) {

    Set<Id> meetingIds = new Set<Id>();

    // Collect all the meetings affected
    for (Meeting_Speaker_BMS__c MS : trigger.new) {
        meetingIds.add(MS.Meeting__c);
    }

    // BUT we only want those meetings which are FFM
    // Modified by: <raphael.krausz@veeva.com>
    // Modified date: 2014-12-15
    {
        List<Medical_Event_vod__c> ffmMeetingList =
            [
                SELECT Id
                FROM Medical_Event_vod__c
                WHERE Id IN :meetingIds
                AND FFM_Step_BMS_EMEA__c != null
            ];

        meetingIds.clear();

        for (Medical_Event_vod__c meeting : ffmMeetingList) {
            meetingIds.add(meeting.Id);
        }
    }



    System.debug('meetingIds.size(): ' + meetingIds.size());


    map<Id, Decimal> honPlanned = new map<Id, Decimal>();
    map<Id, Decimal> honActual = new map<Id, Decimal>();
    map<Id, Integer> speakersMap = new map<Id, Integer>();


    System.debug('Meeting_Speaker_Rollup - Point A');

    //query the required data and go through it
    for (AggregateResult AR :
            [
                SELECT count(id) countSpeaker,
                sum(Total_BMS_EMEA__c) totalHon,
                Meeting__r.FFM_Step_BMS_EMEA__c step,
                sum(Meeting__r.Honorarium_Actual_BMS_EMEA__c), //CSABA
                sum(Meeting__r.Honorarium_Planned_BMS_EMEA__c),//CSABA
                Meeting__c metId
                FROM  Meeting_Speaker_BMS__c
                WHERE Meeting__c in :meetingIds
                AND Meeting__r.FFM_Step_BMS_EMEA__c != null
                GROUP BY  Meeting__r.FFM_Step_BMS_EMEA__c, Meeting__c
            ]
        ) {

        Decimal totalHon = (Decimal) AR.get('totalHon');
        String step =  String.valueof(AR.get('step'));
        Id metId = (Id) (AR.get('metId'));

        Integer countSpeaker = 0;
        if (speakersMap.containsKey(metId)) countSpeaker += speakersMap.get(metId);
        countSpeaker += Integer.valueOf(AR.get('countSpeaker'));
        speakersMap.put(metId, countSpeaker);

        if (step == 'Meeting Planning') {
            Decimal hon = 0;
            if (honPlanned.containsKey(metId)) hon += honPlanned.get(metId);
            hon += totalHon;
            honPlanned.put(metId, hon);
        } else if (step == 'Meeting Post-Execution') {
            Decimal hon = 0;
            if (honActual.containsKey(metId)) hon += honActual.get(metId);
            hon += totalHon;
            honActual.put(metId, hon);
        }
    }

    System.debug('Meeting_Speaker_Rollup - Point B');

    list<Medical_Event_vod__c> MEs = new list<Medical_Event_vod__c>();

    //update the meetings
    for (Id mID : meetingIds) {
        Medical_Event_vod__c ME = new Medical_Event_vod__c();
        ME.Id = mID;

        System.debug('subpoint 1');

        if (speakersMap.containsKey(mID))
            ME.Number_of_Speakers_BMS_EMEA__c = speakersMap.get(mID);

        System.debug('subpoint 2');

        if (honPlanned.containsKey(mID))
            ME.Honorarium_Planned_BMS_EMEA__c = honPlanned.get(mID);

        System.debug('subpoint 3');
        System.debug('honActual: ' + honActual);
        System.debug('honPlanned: ' + honPlanned);


        // RAPHAEL FIXED
        /* WAS:
        if (honActual.containsKey(mID))
            ME.Honorarium_Actual_BMS_EMEA__c = honActual.get(mID) + honPlanned.get(mID);
        */

        if ( honActual.containsKey(mID) && honPlanned.containsKey(mID) )
            ME.Honorarium_Actual_BMS_EMEA__c = honActual.get(mID) + honPlanned.get(mID);

        if ( honActual.containsKey(mID) && ( ! honPlanned.containsKey(mID) ) )
            ME.Honorarium_Actual_BMS_EMEA__c = honActual.get(mID);

        System.debug('subpoint 4');

        MEs.add(ME);
    }

    System.debug('Meeting_Speaker_Rollup - Point C');

    Integer numberOfRecordsToUpdate = MEs.size();
    System.debug('numberOfRecordsToUpdate (MEs): ' + numberOfRecordsToUpdate);

    if ( numberOfRecordsToUpdate > 0 ) {
        update MEs;
    }
}