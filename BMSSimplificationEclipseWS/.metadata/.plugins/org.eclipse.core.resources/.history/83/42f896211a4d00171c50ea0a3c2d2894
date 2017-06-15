public with sharing class EventsManagementPdfSignIn_BMS {
    private ApexPages.StandardController controller {get; set;}
    public Medical_Event_vod__c medicalEvent {get; set;}
    //public List<Event_Attendee_vod__c> eventAttendees {get; set;}
    public List<DisplayAttendee> displayEventAttendees {get; set;}
    public Id medicalEventID {get; set;}
    
    
    public EventsManagementPdfSignIn_BMS(ApexPages.StandardController controller) {
        system.debug('JK - starting pdf');
        //initialize the stanrdard controller
        this.controller = controller;
        this.medicalEventId = ((Medical_Event_vod__c)controller.getRecord()).Id;
        
        //eventAttendees = new List<DisplayAttendee>();
        displayEventAttendees = new List<DisplayAttendee>();
        
        //Get details about this medical event
        for (Medical_Event_vod__c me : [SELECT Address_Line_1_BMS_IC__c,Approved_Agenda_Number__c,City_BMS__c,Country_BMS__c,
                                               Description_vod__c,End_Date_vod__c,End_Date_Time_BMS_IC__c,Event_Number_BMS__c,Event_Stage_BMS__c,
                                               Event_SubType_BMS_IC__c,Event_Type__c,Location__c,Name,Postal_Code_BMS_IC__c ,
                                               Start_Date_vod__c,Start_Date_Time_BMS_IC__c,State_BMS__c,Status_BMS_CORE__c,Venue_BMS_IC__c 
                                        FROM Medical_Event_vod__c
                                        WHERE Id = :this.medicalEventId]) {
            this.medicalEvent = me;
        }
        
        //Event_Attendee_vod__c sea;
        DisplayAttendee da;
        for (Meeting_Speaker_BMS__c ms : [SELECT Account__r.Name, Account__c,Meeting__c, Account__r.Specialty_1_vod__c
                                          FROM Meeting_Speaker_BMS__c
                                          WHERE Meeting__c = :this.medicalEventId]) {
            //sea = new Event_Attendee_vod__c();
            //sea.Attendee_vod__c = ms.Account__r.Name;
            da = new DisplayAttendee();
            da.Name = ms.Account__r.Name;
            da.Specialty = ms.Account__r.Specialty_1_vod__c;
            //eventAttendees.add(sea);
            displayEventAttendees.add(da);
        }                                          
        
        //get event attendees Specialty_1_vod__c
        for (Event_Attendee_vod__c ea : [SELECT Attendee_vod__c, Attendee_Name_vod__c,Account_vod__r.Specialty_1_vod__c 
                                         FROM Event_Attendee_vod__c
                                         WHERE Medical_Event_vod__c = :this.medicalEventId]) {
            //eventAttendees.add(ea);
            da = new DisplayAttendee();
            da.Name = ea.Attendee_vod__c;
            da.Specialty = ea.Account_vod__r.Specialty_1_vod__c;
            displayEventAttendees.add(da);
        }
        system.debug('JK - eventAttendees: ' + displayEventAttendees);
        
        for (Integer i = 0; i < 16; i++) {
            da = new DisplayAttendee();
            da.Name ='__________________________';
            da.Specialty = '__________________________';
            displayEventAttendees.add(da);
            
        } 

    }
    public class DisplayAttendee{
        public string Name {get;set;}
        public string Specialty {get;set;}

         public DisplayAttendee() {
            
        }
    }

}