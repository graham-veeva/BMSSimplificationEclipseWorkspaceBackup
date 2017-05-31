public with sharing class BMS_EMEA_Print_Attendee_Sheet_FR{
    private ApexPages.StandardController controller {get; set;}
    public Medical_Event_vod__c medicalEvent {get; set;}
    public List<Event_Attendee_vod__c> eventAttendees {get; set;}
    public List<Account> nullList;
    public List<Meeting_Speaker_BMS__c> meetingSpeaker {get; set;}
    public Id medicalEventID {get; set;}
    public User salesLineUser {get; set;}
    public String startHour {get; set;}
    public String endHour {get; set;}
    public String SpecialtyTA {get; set;}
    public String Institution {get; set;}
    public String Signature {get; set;}
    public String HCPDHG {get; set;}
    public String disclaimer{get; set;}
    public String attendeeHeader{get; set;}
    public String myContacts{get; set;}
    public String blankTableHeader{get; set;}
    
    public String Table3{get; set;}
    public String speakerHeader{get; set;} 
    public String printAttendee{get; set;}     
    public String printAttendee1{get; set;}  
    public String printAttendee2{get; set;}
    public String printAttendee3{get; set;}     
    public String printAttendee4{get; set;}  
    public String printAttendee5{get; set;}
    public String printAttendee6{get; set;}  
    public String printAttendee7{get; set;}
    public String Venue{get; set;}
    public String Speaker{get; set;}
    public String privacyStatement{get; set;}
    public Date myDate { get; set; }
    
    public String imageURL{get;set;}
    public List<Account> getnulllist() {

return [select id from account limit 10];

} 
   
    public BMS_EMEA_Print_Attendee_Sheet_FR(ApexPages.StandardController controller) {
    
            
     Schema.DescribeFieldResult dfr  = Medical_Event_vod__c.Privacy_Statement_BMS_EMEA_AT__c.getDescribe();
     printAttendee  = dfr.getDefaultValueFormula();
     System.debug('printAttendee --->' + dfr.getDefaultValueFormula() );
    
    
    imageURL='/servlet/servlet.FileDownload?file=';
    List< document > documentList=[select name from document where 
                                    Name='BMSLogo']; 
 
    if(documentList.size()>0)
    {
      imageURL=imageURL+documentList[0].id;
    }
        system.debug('JK - starting pdf');
        //initialize the stanrdard controller
        this.controller = controller;
        this.medicalEventId = ((Medical_Event_vod__c)controller.getRecord()).Id;
        
        eventAttendees = new List<Event_Attendee_vod__c>();
        meetingSpeaker = new List<Meeting_Speaker_BMS__c>();
        //displayEventAttendees = new List<DisplayAttendee>();
        
        //Get details about this medical event
        for (Medical_Event_vod__c me : [SELECT Name,Address_Line_1_BMS_IC__c,Approved_Agenda_Number__c,City_BMS__c,Country_BMS__c,FMAS_Meeting_ID_BMS_EMEA__c,
                                               Description_vod__c,End_Date_vod__c,End_Date_Time_BMS_IC__c,Event_Number_BMS__c,Event_Stage_BMS__c,
                                               Event_SubType_BMS_IC__c,Event_Type__c,Location__c,Postal_Code_BMS_IC__c ,
                                               Start_Date_vod__c,Start_Date_Time_BMS_IC__c,Privacy_Statement_BMS_EMEA_DE__c,Privacy_Statement_BMS_EMEA_ES__c,State_BMS__c,Status_BMS_CORE__c,Owner.name,OwnerId,Planned_Start_Date_BMS_EMEA__c,Location_City_BMS_EMEA__c,Name_of_Venue_BMS_EMEA__c,Venue_BMS_IC__c,FFM_Activity_Type_BMS_EMEA__c
                                        FROM Medical_Event_vod__c
                                        WHERE Id = :this.medicalEventId]) {
            salesLineUser = [SELECT Id,BMS_Territory_ID_BMS_SHARED__c FROM User WHERE id = :me.OwnerId LIMIT 1];
            this.medicalEvent = me;
            Venue = me.Location_City_BMS_EMEA__c + me.Name_of_Venue_BMS_EMEA__c ;
                    }
        
        //Event_Attendee_vod__c sea;
        //DisplayAttendee da;
        
        //get event attendees Specialty_1_vod__c
        for (Event_Attendee_vod__c ea : [SELECT Name, Account_vod__r.Name, Account_vod__r.FirstName, Account_vod__r.LastName ,Account_vod__r.Specialty_formula_BMS_EMEA__c ,Account_vod__r.Main_Institution_BMS_EMEA__r.Name,Account_vod__r.Local_ID_BMS_EMEA__c,Account_vod__r.ShippingAddress,Account_vod__r.ShippingStreet,Account_vod__r.ShippingCity,Account_vod__r.ShippingPostalCode,Attendee_vod__c, Attendee_Name_vod__c,Account_vod__r.Specialty_1_vod__c, Signature_vod__c 
                                         FROM Event_Attendee_vod__c
                                         WHERE Medical_Event_vod__c = :this.medicalEventId ORDER BY Account_vod__r.LastName ASC]) {
            system.debug('EA CONTAINS ---------------------->' + ea);
            
            eventAttendees.add(ea);
            
                     
        }
        for(integer i=0; i<5; i++){
        Event_Attendee_vod__c  ea = new Event_Attendee_vod__c();
        eventAttendees.add(ea);
        }
        /*
        Event_Attendee_vod__c  ea = new Event_Attendee_vod__c();
        eventAttendees.add(ea);
        Event_Attendee_vod__c  ea1 = new Event_Attendee_vod__c();
        eventAttendees.add(ea1);
        Event_Attendee_vod__c  ea2 = new Event_Attendee_vod__c();
        eventAttendees.add(ea2);
        Event_Attendee_vod__c  ea3= new Event_Attendee_vod__c();
        eventAttendees.add(ea3);
        Event_Attendee_vod__c  ea4 = new Event_Attendee_vod__c();
        eventAttendees.add(ea4);
       /* Event_Attendee_vod__c  ea5 = new Event_Attendee_vod__c();
        eventAttendees.add(ea5);
        Event_Attendee_vod__c  ea6 = new Event_Attendee_vod__c();
        eventAttendees.add(ea6);
        Event_Attendee_vod__c  ea7 = new Event_Attendee_vod__c();
        eventAttendees.add(ea7);
        Event_Attendee_vod__c  ea8= new Event_Attendee_vod__c();
        eventAttendees.add(ea8);
        Event_Attendee_vod__c  ea9 = new Event_Attendee_vod__c();
        eventAttendees.add(ea9);*/
       // system.debug('JK - eventAttendees: ' + displayEventAttendees);
   //meetingSpeaker = new List<Meeting_Speaker_BMS__c>();
          for (Meeting_Speaker_BMS__c msp : [SELECT Name,Account__r.Name, Account__r.FirstName, Account__r.LastName ,Account__r.Specialty_BMS_EMEA__c,Account__r.Specialty_formula_BMS_EMEA__c,Account__r.Specialty_2_BMS_EMEA__c,Account__r.ShippingCity,Account__r.Main_Institution_BMS_EMEA__r.Name,Account__r.Local_ID_BMS_EMEA__c
                                             FROM Meeting_Speaker_BMS__c
                                             WHERE Meeting__c = :this.medicalEventId ORDER BY Account__r.LastName ASC]) {
            system.debug('EA CONTAINS ---------------------->' + msp);
            
            meetingSpeaker.add(msp); 

            
             

    
    }
            Meeting_Speaker_BMS__c  msp = new Meeting_Speaker_BMS__c();
            meetingSpeaker.add(msp);
            Meeting_Speaker_BMS__c  msp1 = new Meeting_Speaker_BMS__c();
            meetingSpeaker.add(msp1);
            Meeting_Speaker_BMS__c  msp2 = new Meeting_Speaker_BMS__c();
            meetingSpeaker.add(msp2);
            Meeting_Speaker_BMS__c  msp3 = new Meeting_Speaker_BMS__c();
            meetingSpeaker.add(msp3);
            Meeting_Speaker_BMS__c  msp4 = new Meeting_Speaker_BMS__c();
            meetingSpeaker.add(msp4);
    }
    }