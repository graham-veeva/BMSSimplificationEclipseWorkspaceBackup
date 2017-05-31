trigger VOD_EM_EVENT_SPEAKER_BEFORE_INS_UPD on EM_Event_Speaker_vod__c (before delete, before insert, before update) {
    Set<String> associatedEvents = new Set<String>();
    Set<String> lockedEvents = new Set<String>();
    
    List<EM_Event_Speaker_vod__c> speakers;

    if (Trigger.isInsert || Trigger.isUpdate) {
        speakers = Trigger.new;
    } else {
        speakers = Trigger.old;
    }

    for(EM_Event_Speaker_vod__c speaker: speakers) {
        if(speaker.Event_vod__c != null) {
            associatedEvents.add(speaker.Event_vod__c);
        }
    }
    
    for (EM_Event_vod__c event : [ SELECT Id, Override_Lock_vod__c, Lock_vod__c
                                   FROM EM_Event_vod__c
                                   WHERE Id IN :associatedEvents ]) {
        if (VOD_Utils.isEventLocked(event)) {
            lockedEvents.add(event.Id);
        }
    }

    for (EM_Event_Speaker_vod__c speaker : speakers) {
        if (speaker.Event_vod__c != null && lockedEvents.contains(speaker.Event_vod__c)) {
            speaker.addError('Event is locked');
        }
    }    
}