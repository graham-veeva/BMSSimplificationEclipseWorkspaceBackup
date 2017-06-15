public with sharing class EventsManagementSpeaker_BMS {
    private ApexPages.StandardController controller {get; set;}
    public Meeting_Speaker_BMS__c speaker {get; set;}
    public Id meetingSpeakerId {get; set;}
    public Medical_Event_vod__c medicalEvent {get;set;}
    public Meeting_Speaker_BMS__c meetingSpeaker {get;set;}
    public Address_vod__c SpeakerSummary {get;set;}
    public decimal totalCostSum {get;set;}    
    public List<DisplayRateCard> displayRateCards {get; set;}
    public List<SelectOption> rateCardNames {get; set;}
    public List<FixedDisplayRateCard> fixedDisplayRateCards {get; set;} 
    public String eventStage {get; set;}    
    public String approvalStatus {get;set;}
    public String speakerSpecialty {get;set;}
    public decimal RateCardPlannedExpenses {get;set;}
    

    
    public EventsManagementSpeaker_BMS(ApexPages.StandardController controller) {
        //initialize the stanrdard controller
        this.controller = controller;
        this.meetingSpeakerId = ((Meeting_Speaker_BMS__c)controller.getRecord()).Id;
        
        this.meetingSpeaker = [SELECT Account__c, CreatedById, CreatedDate, IsDeleted, IsLocked, LastActivityDate, Has_Rate_Card__c,
                                      LastModifiedById, LastModifiedDate, MayEdit, Meeting__c, Name, OwnerId, Rate_Card__c, 
                                      Id, SystemModstamp, Lock_Rate_Card__c, Planned_Expenses_BMS_IC__c, Rate_Card_Planned_Expenses__c  
                               FROM Meeting_Speaker_BMS__c
                               WHERE Id = :this.meetingSpeakerId];
        
        this.medicalEvent = [SELECT Active_vod__c, Address_Line_1_BMS_IC__c, Approved_Agenda_Number__c, Associated_Budget_BMS_CORE__c, 
                                    Budget__c, City_BMS__c, Country_BMS__c, CreatedById, CreatedDate, IsDeleted, Description_vod__c, 
                                    End_Date_vod__c, Name, Event_Number_BMS__c, Event_Stage_BMS__c, Event_SubType_BMS_IC__c, 
                                    Event_Type__c, External_ID_BMS__c, Finance_Code_BMS_IC__c, IsLocked, LastActivityDate, 
                                    LastModifiedById, LastModifiedDate, Learning_Objectives_BMS_IC__c, Location__c, MayEdit, 
                                    Mobile_ID_vod__c, OwnerId, Phone_BMS_IC__c, Planned_Expense_Amount__c, Primary_Product__c, Id, 
                                    RecordTypeId, Secondary_Product__c, Speaker_BMS__c, Speaker_BMS_CORE__c, Start_Date_vod__c, 
                                    State_BMS__c, Status_BMS_CORE__c, Status_BMS__c, SystemModstamp, TA_BMS__c, Total_Expenses_BMS_CORE__c, 
                                    Venue_BMS_IC__c, Website__c 
                              FROM Medical_Event_vod__c
                              WHERE ID = :this.meetingSpeaker.Meeting__c];
                              
        this.speakerSpecialty = [SELECT Specialty_1_vod__c FROM Account WHERE ID =:this.meetingSpeaker.Account__c].Specialty_1_vod__c;                      
                        
        
        //find medical event record types
        Map<Id,RecordType> recordTypeToName = new Map<Id,RecordType>([SELECT Id, DeveloperName, Name
                                                              FROM RecordType 
                                                              WHERE SobjectType = 'Medical_Event_vod__c']);
        //find what stage we are in
        if (recordTypeToName.get(this.medicalEvent.RecordTypeId) == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Record Type Not Found'));
            return;
        }
        

        this.eventStage = recordTypeToName.get(this.medicalEvent.RecordTypeId).DeveloperName;
        system.debug('JK - eventStage: ' + this.eventStage);                              
   
        if (this.eventStage != 'Planning') { this.eventStage = 'Planning_2'; }
        /*
        //override stage if in approval
        //getApprovalStatus();
        if (this.approvalStatus == 'Pending') {
            this.eventStage = 'Planning_2';
        }
   
        if (this.meetingSpeaker.Lock_Rate_Card__c) {
            this.eventStage = 'Planning_2';
        } else {
            this.eventStage = 'Planning';
        }
      */  
        if (this.eventStage == 'Planning') {

                populateRateCard();
                populateSpeakerSummary();

        } else if (this.eventStage == 'Planning_2') {
            populateRateCard();
            populateSpeakerSummary();
        }
    }
    
    public void populateSpeakerSummary() {
        //get speaker info
        this.speakerSummary = new Address_vod__c();
        for(Address_vod__c ad : [SELECT Address_line_2_vod__c,City_vod__c,Name,Primary_vod__c,State_vod__c,Zip_vod__c, 
                                               Account_vod__r.Credentials_vod__c,Account_vod__r.PersonEmail,Account_vod__r.Phone,
                                               Account_vod__r.Specialty_1_vod__c,Account_vod__r.ONYX_Contract_Number_BMS__c,
                                               Account_vod__r.IsPersonAccount, Account_vod__r.SAP_Vendor_ID_BMS_IC__c 
                                 FROM Address_vod__c 
                                 WHERE Account_vod__r.Id =:this.meetingSpeaker.Account__c AND
                                       Primary_vod__c = true]){
            this.speakerSummary = ad;
            system.debug('jk - speaker summary; ' + this.speakerSummary);                           
        }       
    }
    
     public void populateRateCard() {
        DisplayRateCard drc;
        FixedDisplayRateCard fdrc;
        this.displayRateCards = new List<DisplayRateCard>();
        this.fixedDisplayRateCards = new List<FixedDisplayRateCard>();
        totalCostSum = 0;
        this.rateCardNames = new List<SelectOption>();

 
        if (this.meetingSpeaker.Has_Rate_Card__c) {
            for (Rate_Card__c rc : [SELECT Hourly_Rate__c,Hours__c,Id,Medical_Event__c,Name,Type__c, Is_Hourly__c 
                                    FROM Rate_Card__c
                                    WHERE Medical_Event__c = :this.medicalEvent.Id AND
                                          Meeting_Speaker__c = :this.meetingSpeakerId]) {
                
                if (rc.Is_Hourly__c) {
                    drc = new DisplayRateCard();
                    drc.HourlyRate = rc.Hourly_Rate__c;
                    drc.Hours = rc.Hours__c;
                    drc.isTemplate = false;
                    drc.Name = rc.Name;
                    drc.Type = rc.Type__c;
                    drc.Id = rc.Id;
                    drc.Total = rc.Hours__c * rc.Hourly_Rate__c;
                    this.displayRateCards.add(drc);
                    totalCostSum += (rc.Hours__c * rc.Hourly_Rate__c); 
                } else {
                    fdrc = new FixedDisplayRateCard(this.medicalEvent.Event_Type__c);
                    fdrc.Total = rc.Hourly_Rate__c;
                    fdrc.SelectedName = rc.Name;
                    this.fixedDisplayRateCards.add(fdrc);
                    totalCostSum += rc.Hourly_Rate__c; 
                }                                       
            }           
        } else {
            List<Rate_Card_Template__c> rateCards = new List<Rate_Card_Template__c>();
            rateCards = [SELECT Hourly_Rate__c,Hours__c,Id,Name,Type__c, Specialty__c 
                         FROM Rate_Card_Template__c
                         WHERE Specialty__c = :this.speakerSpecialty AND
                               Specialty__c != null]; 
            system.debug('jk - speaker specialty: ' + this.speakerSpecialty);
            if (rateCards.isEmpty()) {
                //no rate cards with this specialty. use default
                rateCards = [SELECT Hourly_Rate__c,Hours__c,Id,Name,Type__c, Specialty__c 
                             FROM Rate_Card_Template__c
                             WHERE Specialty__c = 'Default'];
            }
            system.debug('jk - rate card templates: ' + rateCards);
        
            for (Rate_Card_Template__c rct : rateCards) {
                drc = new DisplayRateCard();
                
                drc.HourlyRate = rct.Hourly_Rate__c;
                drc.Hours = rct.Hours__c;
                drc.isTemplate = true;
                drc.Name = rct.Name;
                drc.Type = rct.Type__c;
                drc.Id = rct.Id;
                drc.Total = rct.Hours__c * rct.Hourly_Rate__c;
                this.displayRateCards.add(drc);
                totalCostSum += (rct.Hours__c * rct.Hourly_Rate__c);                    
            }
            
        }
        if (this.eventStage == 'Planning') {
            for (Integer i = 0; i < 6; i++) {
                fdrc = new FixedDisplayRateCard(this.medicalEvent.Event_Type__c);
                fdrc.SelectedName = '';
                fdrc.Total = 0;
                this.fixedDisplayRateCards.add(fdrc);
            }
        }                
        system.debug('JK - displayRateCards: ' + displayRateCards);
    }
    
   
 public void saveRateCard() {
        if (this.meetingSpeaker.Has_Rate_Card__c) {
            delete [SELECT Id FROM Rate_Card__c 
                    WHERE Medical_Event__c = :this.medicalEvent.Id AND 
                          Meeting_Speaker__c = :this.meetingSpeakerId];
        } 
        Decimal plannedExpenses = 0;
        this.RateCardPlannedExpenses = 0;

        Rate_Card__c rc;
        Decimal amount = 0;
        List<Rate_Card__c> rateCards = new List<Rate_Card__c>();
        for (DisplayRateCard drc : this.displayRateCards) {
            
                rc = new Rate_Card__c();
                rc.Is_Hourly__c = true;
                if (drc.Hours > 0) {
                    rc.Hours__c = drc.Hours;
                } else {
                    rc.Hours__c = 0;
                }
                rc.Medical_Event__c = this.medicalEvent.Id;
                rc.Meeting_Speaker__c = this.meetingSpeakerId;
                rc.Name = drc.Name;
                rc.Type__c = drc.Type;
                rc.Hourly_Rate__c = drc.HourlyRate;
                rc.Amount__c = (rc.Hours__c * rc.Hourly_Rate__c);
                this.RateCardPlannedExpenses += rc.Amount__c;
                plannedExpenses += rc.Amount__c;
                rateCards.add(rc);
                amount += (rc.Hours__c * rc.Hourly_Rate__c);   
                system.debug('jk - rate card: ' + rc);
            
        }
        for (FixedDisplayRateCard fdrc : this.fixedDisplayRateCards) {
            system.debug('jk - fixed rate card: ' + rc);
            if (fdrc.Total > 0) {
                rc = new Rate_Card__c();
                rc.Is_Hourly__c = false;
                rc.Hours__c = 1;
                rc.Medical_Event__c = this.medicalEvent.Id;
                rc.Meeting_Speaker__c = this.meetingSpeakerId;
                rc.Name = fdrc.SelectedName;
                rc.Hourly_Rate__c = fdrc.Total;
                rc.Amount__c = fdrc.Total;
                plannedExpenses += rc.Amount__c;
                rateCards.add(rc);
                amount += fdrc.Total;
                system.debug('jk - adding fixed rate card: ' + rc);
            }
        }
        system.debug('jk - rate cards to save: ' + rateCards);
        insert rateCards;
        this.meetingSpeaker.Has_Rate_Card__c = true;
        this.meetingSpeaker.Planned_Expenses_BMS_IC__c = plannedExpenses;
        this.meetingSpeaker.Rate_Card_Planned_Expenses__c = this.RateCardPlannedExpenses;
        this.MedicalEvent.Planned_Expense_Amount__c = getRateCardsAmount();
        update this.meetingSpeaker;
        update this.medicalEvent;
        populateRateCard();

    
    }    
    
    public Decimal getRateCardsAmount() {
        Decimal total = 0;
        AggregateResult[] results = [SELECT SUM(Amount__c) total
                                     FROM Rate_Card__c
                                     WHERE Medical_Event__c = :this.medicalEvent.Id AND
                                           Amount__c != null];
        for (AggregateResult ar : results) {
            total += (Decimal)ar.get('total');
        }                                            
        system.debug('jk - total rate card: ' + total);        
        return total;        
    }
    
    public void getApprovalStatus() {
       
        for (ProcessInstance pi : [SELECT Status FROM ProcessInstance WHERE TargetObjectId = :this.medicalEvent.Id]) {
            this.approvalStatus = pi.Status;
        }
    }
    public class DisplayRateCard {
        public boolean isTemplate {get;set;}
        public string Name {get;set;}
        public decimal Hours {get;set;}
        public string Type {get;set;}
        public decimal HourlyRate {get;set;}
        public Id Id {get;set;}
        public decimal Total {get;set;}
        
        
        public DisplayRateCard() {
            
        }
    }  
    public class FixedDisplayRateCard {
        public string SelectedName {get;set;}
        public string eventType {get;set;}
        public List<SelectOption> getNames() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Accreditation Fees','Accreditation Fees'));
            if (this.eventType == 'Corporate Support Event') {
                options.add(new SelectOption('Corporate Support','Corporate Support'));
            }            
            options.add(new SelectOption('Lodging','Lodging'));
            options.add(new SelectOption('Meal','Meal'));
            options.add(new SelectOption('Other','Other'));
            options.add(new SelectOption('Travel','Travel'));

            return options;
        }
        public decimal Total {get;set;}
        
        public FixedDisplayRateCard(String et) {
            this.eventType = et;
        }   
    }   
    
    
}