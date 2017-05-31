/*
* mnaidu - This trigger is to support the Before Insert trigger on EM_Attendee_vod in cases
* where the stub gets inserted first. To ensure values on the stub also get set from Account
* similar to how they get set on EM_Attendee_vod
*/
trigger VPROF_Event_Attendee_Set_Addr_Fields on Event_Attendee_vod__c (before insert) {

   	//////make sure this code does not run on Old Med Event model (see below)
   	Set<ID> medEventIds = new Set<ID>();
   	Map<ID, List<Event_Attendee_vod__c>> mapStubEventToStubAttendee = new Map<ID, List<Event_Attendee_vod__c>>();
   	List<Event_Attendee_vod__c> attendeeStubList = new List<Event_Attendee_vod__c>();
   	for(Event_Attendee_vod__c aStub: Trigger.new){
   		medEventIds.add(aStub.Medical_Event_vod__c);
   		if(mapStubEventToStubAttendee.get(aStub.Medical_Event_vod__c)!=null){
   			mapStubEventToStubAttendee.get(aStub.Medical_Event_vod__c).add(aStub);
   		}
   		else{
   			mapStubEventToStubAttendee.put(aStub.Medical_Event_vod__c, new List<Event_Attendee_vod__c>{aStub});   			
   		}
   	}
   	
   	List<Medical_Event_vod__c> medEventStubList = [Select Id, EM_Event_vod__c from Medical_Event_vod__c 
   																where Id in:medEventIds
   																and EM_Event_vod__c != NULL  ];
 
	for(Medical_Event_vod__c anEventStub: medEventStubList){
		attendeeStubList.addAll(mapStubEventToStubAttendee.get(anEventStub.Id));//this would have what Trigger.New has except curated to be only Stubs
	}   	
   	/////make sure this code does not run on Old Med Event model (see up)
   	
    List<Id> accountIds = new List<Id>();
    List<Id> userIds = new List<Id>();
    List<Id> contactIds = new List<Id>();
    for(Event_Attendee_vod__c stub: attendeeStubList){
        if(stub.Account_vod__c!=null){
            accountIds.add(stub.Account_vod__c);
        }
        if(stub.User_vod__c!=null){
            userIds.add(stub.User_vod__c);
        }
        if(stub.Contact_vod__c!=null){
            contactIds.add(stub.Contact_vod__c);
        }
    }
    Map<Id, Account> accounts;
    Map<Id, User> users ;
    Map<Id, Contact> contacts;
    
    if(accountIds.size() > 0){
           accounts = new Map<Id, Account>([SELECT Id, Formatted_Name_vod__c, FirstName, LastName, PersonTitle, 
               Credentials_vod__c, Name, Phone, Email_text_format_BMS_SHARED__c, 
                ShippingState, ShippingPostalCode, ShippingStreet, ShippingCountry,ShippingCity
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

    for(Event_Attendee_vod__c stub: attendeeStubList){ 
            if(stub.Account_vod__c!=null){
            	//only concerned with VOD fields to ensure Product triggers dont run them over
                Account theAcct = accounts.get(stub.Account_vod__c);
                stub.Address_Line_1_vod__c = theAcct.ShippingStreet;
                stub.City_vod__c = theAcct.ShippingCity;
                stub.Zip_vod__c = theAcct.ShippingPostalCode;
                stub.Phone_vod__c = theAcct.Phone;
                stub.Email_vod__c = theAcct.Email_text_format_BMS_SHARED__c;
            }
            else if(stub.Contact_vod__c!=null){
                Contact theContact = contacts.get(stub.Contact_vod__c);
                stub.Address_Line_1_vod__c = theContact.MailingStreet;
                stub.City_vod__c = theContact.MailingCity;
                stub.Zip_vod__c = theContact.MailingPostalCode;
                stub.Phone_vod__c = theContact.Phone;
                stub.Email_vod__c = theContact.Email;
            }
            else if(stub.User_vod__c!=null){
                User theUser = users.get(stub.User_vod__c);
                stub.Address_Line_1_vod__c = theUser.Street;
                stub.City_vod__c = theUser.City;
                stub.Zip_vod__c = theUser.PostalCode;
                stub.Phone_vod__c = theUser.Phone;
                stub.Email_vod__c = theUser.Email;
            }
            System.debug('Stub = ' + stub);
        }
    }