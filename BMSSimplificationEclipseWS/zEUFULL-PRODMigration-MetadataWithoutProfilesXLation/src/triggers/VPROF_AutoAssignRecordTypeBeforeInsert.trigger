/**
* Created: June 28th, 2015 By Murugesh Naidu, Sr. Technical Architect, Veeva Proofessional Services
* This trigger was created to:
1. Maps the Activity/Event Speaker rectype based on Activity type & Activity Subtype - Key lookup format is ==> "Activity_Rec_type_Dev_Name#Activity_Subtype_Picklistvalue"
//2. Also sets the Contract sub-type in some cases
*/

trigger VPROF_AutoAssignRecordTypeBeforeInsert on EM_Event_Speaker_vod__c (before insert) {

    
    Map<String, String> mapEventRecTypeToEventSpkr = new Map<String, String>{
                                                                            'Speaker_Training' => 'Services_Event_Speaker_HCPTS', 
                                                                            'Internal_Speaking' => 'Services_Event_Speaker_HCPTS', 
                                                                            'Advisory_Board' => 'Services_Event_Speaker_HCPTS', 
                                                                            'Other_Consulting' => 'Services_Event_Speaker_HCPTS', 
                                                                            'R_D_Committee' => 'Services_Event_Speaker_HCPTS', 
                                                                            'Speaker_Meeting' => 'Services_Event_Speaker_HCPTS', 
                                                                            'Cross_Org#Speaker Meeting' => 'Services_Event_Speaker_HCPTS', 
                                                                            'Cross_Org#Advisory Board' => 'Services_Event_Speaker_HCPTS', 
                                                                            'Cross_Org#Sponsorship' => 'Events_Event_Speaker_HCPTS', //updated 2/15/16 - mnaidu
                                                                            'Cross_Org#R&D Committee' => 'Services_Event_Speaker_HCPTS', 
                                                                            'Investigator_Meeting_vod' => 'Services_Event_Speaker_HCPTS', 
                                                                            'Exhibits_Booths_and_Displays' => 'Events_Event_Speaker_HCPTS',
                                                                            'HCP_Sponsorship' => 'Events_Event_Speaker_HCPTS',//updated 2/15/16 - mnaidu
                                                                            'Preceptorship' => 'Services_Event_Speaker_HCPTS',//updated 2/15/16 - mnaidu
                                                                            'Event_Purchase' => 'Event_Purchase_Speaker_HCPTS',
                                                                            'Simple_Activity_HCPTS' => 'Simplified_Event_Speaker_HCPTS',
                                                                            'Default' => 'Event_Speaker_vod'
                                                                            };
    Map<String, String> mapEventRecTypeToContractTyp = new Map<String, String>{
                                                                            'Speaker_Training' => 'Services', 
                                                                            'Internal_Speaking' => 'Services', 
                                                                            'Advisory_Board' => 'Services',
                                                                            'Other_Consulting' => 'Services',
                                                                            'R_D_Committee' => 'Services',
                                                                            'Speaker_Meeting' => 'Services',
                                                                            'Cross_Org#Speaker Meeting' => 'Services', 
                                                                            'Cross_Org#Advisory Board' => 'Services', 
                                                                            'Cross_Org#Sponsorship' => 'Events', 
                                                                            'Cross_Org#R&D Committee' => 'Services',                                                                            
                                                                            'Investigator_Meeting_vod' => 'Services',
                                                                            'Exhibits_Booths_and_Displays' => 'Events',
                                                                            'HCP_Sponsorship' => 'Events',//updated 2/15/16 - mnaidu
                                                                            'Preceptorship' => 'Services'//updated 2/15/16 - mnaidu
                                                                            };
    Map<String, String> mapEventRecTypeToContractSubTyp = new Map<String, String>{
                                                                            'Speaker_Training' => 'Speaker Training', 
                                                                            'Internal_Speaking' => 'Internal Presentation', 
                                                                            'Advisory_Board' => 'Advisory Board', 
                                                                            'Exhibits_Booths_and_Displays' => 'Exhibits, Booths and Displays', 
                                                                            'Cross_Org#Sponsorship' => 'Sponsorship to Congress',                                                                           
                                                                    //      'Other_Consulting' => '', 
                                                                    //      'R_D_Committee' => '', 
                                                                    //      'Speaker_Meeting' => '', 
                                                                    //      'Investigator_Meeting_vod' => '', 
                                                                    //      'Exhibits_Booths_and_Displays' => '',
                                                                    //      'HCP_Sponsorship' => 'Sponsorship to Congress',
                                                                            'Preceptorship' => 'Faculty for Preceptorship'
                                                                            };

    List<RecordType> recTypeLst = [SELECT Name, Id, DeveloperName, SobjectType FROM RecordType
                                                        where Sobjecttype in  ('EM_Event_Speaker_vod__c','EM_Event_vod__c' ) and IsActive = TRUE];
    Map<String, RecordType> mapESPRecDevNameToRectypes = new Map<String, RecordType>();
    Map<String, RecordType> mapEventRecDevNameToRectypes = new Map<String, RecordType>();
    List<ID> spkrIds = new List<ID>();
    List<ID> eventIds = new List<ID>();
    
    for(RecordType rec: recTypeLst){
        if(rec.Sobjecttype == 'EM_Event_Speaker_vod__c'){
            mapESPRecDevNameToRectypes.put(rec.DeveloperName, rec);
        }
        else{
            mapEventRecDevNameToRectypes.put(rec.DeveloperName, rec);           
        }
    }
    for(EM_Event_Speaker_vod__c esp: Trigger.new){
        eventIds.add(esp.Event_vod__c);
        spkrIds.add(esp.Speaker_vod__c);
    }
    
    Map<Id, EM_Event_vod__c> eventsMap = new Map<ID, EM_Event_vod__c> ([Select Id, Name, Subtype_HCPTS__c, RecordTypeId, RecordType.DeveloperName
                                                                    from EM_Event_vod__c 
                                                                    where Id in: eventIds ]);
    Map<Id, EM_Speaker_vod__c> spkrMap = new Map<ID, EM_Speaker_vod__c> ([Select Id, Name, Language_HCPTS__c, Provider_Type_HCPTS__c , Employer_Consent_Required_HCPTS__c 
                                                                            from EM_Speaker_vod__c
                                                                            where Id in: spkrIds]);

                    
    for(EM_Event_Speaker_vod__c esp: Trigger.new){
        String eventRecTypDevName = eventsMap.get(esp.Event_vod__c).RecordType.DeveloperName;
        String eventRecTypSubtype = eventsMap.get(esp.Event_vod__c).Subtype_HCPTS__c;
        
        if(eventRecTypSubtype!=null && eventRecTypSubtype.trim()!='' && eventRecTypDevName!='Simple_Activity_HCPTS'){
            eventRecTypSubtype = eventRecTypDevName + '#' + eventRecTypSubtype;
        }
        else{
            eventRecTypSubtype = eventRecTypDevName;
        }
        String espRecTypDevName = (mapEventRecTypeToEventSpkr.get(eventRecTypSubtype)!=null ) 
                                            ? mapEventRecTypeToEventSpkr.get(eventRecTypSubtype): mapEventRecTypeToEventSpkr.get('Default');
        
        
        RecordType espRecTypeToSet = mapESPRecDevNameToRectypes.get(espRecTypDevName);
        esp.RecordTypeId = espRecTypeToSet.Id;
        esp.Service_Type_HCPTS__c = mapEventRecTypeToContractTyp.get(eventRecTypSubtype);
        esp.Service_SubType_HCPTS__c = mapEventRecTypeToContractSubTyp.get(eventRecTypSubtype);
        esp.Contract_Language_HCPTS__c = spkrMap.get(esp.Speaker_vod__c).Language_HCPTS__c;
        esp.Employer_Consent_Required_HCPTS__c = spkrMap.get(esp.Speaker_vod__c).Employer_Consent_Required_HCPTS__c;
        if(esp.Service_Type_HCPTS__c == 'Services'){
            esp.Contract_Format_HCPTS__c = 'Long-term';
        }
    }
    
    

}