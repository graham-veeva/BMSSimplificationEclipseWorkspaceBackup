/**
 * @Author - Murugesh Naidu, Veeva Professional Services
 * @created - Jan13, 2016
 * Primary original purpose was to assign a RecordTypeID to the EM_Attendee_vod record
 * based on Event Record type Developer Name. Per design, please ensure each EM_Event_vod
 * Recordtype has a corresponding matching Recordtype (DeveloperNames should match) for EM_Attendee_vod
 **/
trigger VPROF_EMAttendeeBeforeInsert on EM_Attendee_vod__c (before insert, before update) {
    
    public static final String AUD_TYPE_HCP = 'HCP';
    // Added by Huron Consulting Group 1-21-2016
    // make the language field the value of the language of the current user
    Id currentUserId = UserInfo.getUserId();
    User currentUser = [SELECT Id,LanguageLocaleKey FROM User WHERE Id = :currentUserId LIMIT 1];    
    
    
    ////////////////////////////////////////////////////////////////////////
    /////////MNAIDU - START CHANGE FOR SIMPLIFICATION - FEB 10TH, 2017/////////
    ////CHANGE ALSO REPLACES USE OF TRIGGER.NEW WITH "TriggerNewListWithoutSimpleEvents" SO THAT
    //ONLY NON-SIMPLIFIED EVENTS USE THIS TRIGGER FOR PROCESSING
    ////////////////////////////////////////////////////////////////////////

    public static final String SIMPLE_ACTIVITY_RECTYPE_DEVNAME = 'Simple_Activity_HCPTS';    
    List<EM_Attendee_vod__c> TriggerNewListWithoutSimpleEvents = new List<EM_Attendee_vod__c>();
    Map<ID, List<EM_Attendee_vod__c>> eventToAttendeesMap = new Map<ID, List<EM_Attendee_vod__c>>();
    Set<ID> allEventsIDs = new Set<ID>();
    Set<ID> simpleEventsIDs = new Set<ID>();
    
    for(EM_Attendee_vod__c att: Trigger.New){
        if(eventToAttendeesMap.get(att.Event_vod__c)==null){
            eventToAttendeesMap.put(att.Event_vod__c, new List<EM_Attendee_vod__c> {att});
        }
        else{
            eventToAttendeesMap.get(att.Event_vod__c).add(att);            
        }
        allEventsIDs.add(att.Event_vod__c);
    }
    for(EM_Event_vod__c anEvent: [Select Id, Recordtype.DeveloperName from EM_Event_vod__c where Id in: allEventsIDs]){
        if(anEvent.Recordtype.DeveloperName != SIMPLE_ACTIVITY_RECTYPE_DEVNAME){ //if it is not a simple event, we want to process using this trigger
			TriggerNewListWithoutSimpleEvents.addAll(eventToAttendeesMap.get(anEvent.Id));
        }
    }
    
    if(TriggerNewListWithoutSimpleEvents.size() == 0){
        return;//no need to process further if this is a simplied Activity
    }
    ////////////////////////////////////////////////////////////////////////
    /////////MNAIDU - END CHANGE FOR SIMPLIFICATION - FEB 10TH, 2017/////////
    ////////////////////////////////////////////////////////////////////////
    if(currentUser != null){
        for(EM_Attendee_vod__c attendee: TriggerNewListWithoutSimpleEvents){
            attendee.Language__c = currentUser.LanguageLocaleKey;
        }
    }
    
    Map<String, Country_vod__c> countryAlphaCodeMap =       new Map<String, Country_vod__c> ();
    Map<String, Country_vod__c> countryTranslatedCodeMap =      new Map<String, Country_vod__c> ();
    for(Country_vod__c c: [Select Id, Name, Alpha_2_Code_vod__c, toLabel(Country_Name_vod__c)
                                                                        from Country_vod__c ])  {
                                                                            
        countryAlphaCodeMap.put(c.Alpha_2_Code_vod__c, c);
        countryTranslatedCodeMap.put(c.Country_Name_vod__c, c);
    }                           
        
    Schema.DescribeSObjectResult d = EM_Attendee_vod__c.SObjectType.getDescribe();
    Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();


    List<RecordType> rectypeList = [Select Id, name, developername 
                                    from  Recordtype
                                    where sObjectType = 'EM_Attendee_vod__c'];
    Map<Id, String> eventRecypsMap = new Map<Id, String>();
    List<Id> eventIds = new List<Id>();
    List<Id> accountIds = new List<Id>();
    List<Id> userIds = new List<Id>();
    List<Id> contactIds = new List<Id>();
    Map<String, Recordtype> attendeeRecTypDevNameMap = new Map<String, Recordtype>();
    for(Recordtype r: rectypeList){
        attendeeRecTypDevNameMap.put(r.DeveloperName, r);
    }
    for(EM_Attendee_vod__c attendee: TriggerNewListWithoutSimpleEvents){
        eventIds.add(attendee.Event_vod__c);
        if(attendee.Account_vod__c!=null){
            accountIds.add(attendee.Account_vod__c);
        }
        if(attendee.User_vod__c!=null){
            userIds.add(attendee.User_vod__c);
        }
        if(attendee.Contact_vod__c!=null){
            contactIds.add(attendee.Contact_vod__c);
        }
    }
    Map<Id, Account> accounts;
    Map<Id, User> users ;
    Map<Id, Contact> contacts;
    
    if(accountIds.size() > 0){
           accounts = new Map<Id, Account>([SELECT Id, Formatted_Name_vod__c, FirstName, LastName, PersonTitle, 
               Credentials_vod__c, Name, Phone, Email_text_format_BMS_SHARED__c, 
                ShippingState, ShippingPostalCode, ShippingStreet, ShippingCountry,ShippingCity
                                            , DHG_BMS_EMEA__c 
          FROM Account WHERE Id in :accountIds]);
        
    }
    if(userIds.size() > 0){
           users = new Map<Id, User>([SELECT Street, Name, Country, City, BMS_Employee_ID__c, State, PostalCode, Username, UserType, Email, Phone 
                                            FROM User
                                                WHERE Id in :userIds]);
        
    }
    if(contactIds.size() > 0){
           contacts = new Map<Id, Contact>([SELECT Name, Email, Phone, MailingStreet, MailingCountry, MailingCity,  MailingState, MailingPostalCode, Contact_Type_HCPTS__c
                                            FROM Contact
                                                WHERE Id in :contactIds]);
        
    }

    for(EM_Event_vod__c e: 
        [Select Id, RecordType.DeveloperName from EM_Event_vod__c where Id in: eventIds]){
        eventRecypsMap.put(e.Id, e.RecordType.DeveloperName);
    }
    for(EM_Attendee_vod__c attendee: TriggerNewListWithoutSimpleEvents){
        if(eventRecypsMap.get(attendee.Event_vod__c)!=null){
          String tempRecTypDevName = eventRecypsMap.get(attendee.Event_vod__c);
          String activityType = tempRecTypDevName;
          ID attendeeRecTypeId, attendeeMasterRecTypeId = null;
           //Derive the Attendee rectype using the Event rectypeDeveloperName
           //create an exception for HCP Sponsorship & Preceptorship
            if(tempRecTypDevName == 'HCP_Sponsorship' 
               || tempRecTypDevName == 'Preceptorship' ){
                   if(attendee.User_vod__c!=null){
                       tempRecTypDevName = 'SponsoredUser';
                        attendee.Audience_Type_HCPTS__c = 'BMS Employee';
                   }
                   else if(attendee.Contact_vod__c!=null){
                       tempRecTypDevName = 'SponsoredContact';
                        attendee.Audience_Type_HCPTS__c = contacts.get(attendee.Contact_vod__c).Contact_Type_HCPTS__c;
                   }
                   else //if (attendee.Account_vod__c!=null)//default assignment
                   {
                       tempRecTypDevName = 'SponsoredAccount';
                        attendee.Audience_Type_HCPTS__c = AUD_TYPE_HCP;
                   }
            }
            else{
                tempRecTypDevName = 'Attendee_vod';//default
                 attendee.Audience_Type_HCPTS__c = AUD_TYPE_HCP;
                 System.debug('attendee in before insert at the point of set = ' + attendee);
            }
          RecordType attendeeRecType = attendeeRecTypDevNameMap.get(tempRecTypDevName) ;
            if(attendeeRecType!=null){
                attendeeRecTypeId = attendeeRecType.Id;
            }
/*            else{
                for(RecordTypeInfo rtInfo: rtMapByName.values()){
                    if(rtInfo.isDefaultRecordTypeMapping()){
                        attendeeRecTypeId = rtInfo.getRecordTypeId();
                    }
                    if(rtInfo.isMaster()){
                        attendeeMasterRecTypeId = rtInfo.getRecordTypeId();
                    }
                }
                if(attendeeRecTypeId == null){
                    attendeeRecTypeId = attendeeMasterRecTypeId;
                }
            }
            */
            attendee.RecordTypeId = attendeeRecTypeId;
          //  attendee.Activity_Type_HCPTS__C = activityType;
          String countryStr = '';
            if(attendee.Account_vod__c!=null){
                Account theAcct = accounts.get(attendee.Account_vod__c);
                attendee.Contract_Party_Name_HCPTS__c = theAcct.Name;
                attendee.Address_Line_1_vod__c = theAcct.ShippingStreet;
                attendee.City_vod__c = theAcct.ShippingCity;
                attendee.State_HCPTS__c = theAcct.ShippingState;
                countryStr = theAcct.ShippingCountry;
                attendee.Zip_vod__c = theAcct.ShippingPostalCode;
                attendee.Phone_vod__c = theAcct.Phone;
                attendee.Email_vod__c = theAcct.Email_text_format_BMS_SHARED__c;
                attendee.Employer_Consent_Required_HCPTS__c = theAcct.DHG_BMS_EMEA__c;
            }
            else if(attendee.Contact_vod__c!=null){
                Contact theContact = contacts.get(attendee.Contact_vod__c);
                attendee.Contract_Party_Name_HCPTS__c = theContact.Name;
                attendee.Address_Line_1_vod__c = theContact.MailingStreet;
                attendee.City_vod__c = theContact.MailingCity;
                attendee.State_HCPTS__c = theContact.MailingState;
                countryStr = theContact.MailingCountry;
                attendee.Zip_vod__c = theContact.MailingPostalCode;
                attendee.Phone_vod__c = theContact.Phone;
                attendee.Email_vod__c = theContact.Email;
            }
            else if(attendee.User_vod__c!=null){
                User theUser = users.get(attendee.User_vod__c);
                attendee.Contract_Party_Name_HCPTS__c = theUser.Name;
                attendee.Address_Line_1_vod__c = theUser.Street;
                attendee.City_vod__c = theUser.City;
                attendee.State_HCPTS__c = theUser.State;
                countryStr = theUser.Country;
                attendee.Zip_vod__c = theUser.PostalCode;
                attendee.Phone_vod__c = theUser.Phone;
                attendee.Email_vod__c = theUser.Email;
            }
            if(countryStr !=null &&  countryStr.trim()!=''){
                if(countryAlphaCodeMap.get(countryStr)!=null){
                    attendee.Country_ref_HCPTS__c = countryAlphaCodeMap.get(countryStr).Id;
                }
                else if(countryTranslatedCodeMap.get(countryStr)!=null){
                    attendee.Country_ref_HCPTS__c = countryTranslatedCodeMap.get(countryStr).Id;                    
                }
            }
            
            if(activityType == 'HCP_Sponsorship' ||  activityType == 'Preceptorship'){
                    attendee.Contract_Type_HCPTS__c = 'Sponsorship';
                if(activityType == 'HCP_Sponsorship' ){
                    attendee.Contract_Subtype_HCPTS__c = 'Sponsorship to Congress';
                }
                if(activityType == 'Preceptorship' ){
                    attendee.Contract_Subtype_HCPTS__c = 'Attendee for Preceptorship';
                }
            }
        }
        
     System.debug('attendee in before insert after processing = ' + attendee);
        
        
    }
    
}