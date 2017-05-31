public with sharing class EventsManagementContract_BMS {
    private ApexPages.StandardController controller {get; set;}
    public Date Today { get { return Date.today(); }}
    public Medical_Event_vod__c medicalEvent {get; set;}
    public Account speaker {get; set;}
    public Address_vod__c speakerAddress {get; set;}
    public Id meetingSpeakerId {get; set;}
    public User owner {get; set;}
    public List<Id> territoryIds {get; set;}
    public String ownerTerritory {get; set;}
    public String renderAs {get;set;}
    public Meeting_Speaker_BMS__c meetingSpeaker {get;set;}
    public Boolean renderAsPdf {get;set;}
    public String render {get;set;}
    
    public String getRenderLanguage() {
        return ApexPages.currentPage().getParameters().get('rl');
    }
    
    public EventsManagementContract_BMS(ApexPages.StandardController controller) {
        system.debug('JK - starting honorarium pdf');
        this.renderAsPdf = false;
        this.medicalEvent = new Medical_Event_vod__c();
        this.speaker = new Account();
        this.speakerAddress = new Address_vod__c();
        this.owner = new User();
        this.territoryIds = new List<Id>();
        //initialize the stanrdard controller
        this.controller = controller;
        this.meetingSpeakerId = ((Meeting_Speaker_BMS__c)controller.getRecord()).Id;
        this.meetingSpeaker = [SELECT Account__c, CreatedById, CreatedDate, IsDeleted, IsLocked, LastActivityDate, Has_Rate_Card__c,
                                      LastModifiedById, LastModifiedDate, MayEdit, Meeting__c, Name, OwnerId, Rate_Card__c, 
                                      Id, SystemModstamp, Lock_Rate_Card__c, Planned_Expenses_BMS_IC__c, Rate_Card_Planned_Expenses__c   
                               FROM Meeting_Speaker_BMS__c
                               WHERE Id = :this.meetingSpeakerId];
        //Get details about this medical event
        for (Medical_Event_vod__c me : [SELECT Active_vod__c,Approved_Agenda_Number__c,Associated_Budget_BMS_CORE__c,Budget__c,City_BMS__c,Country_BMS__c,CreatedById,
                                                CreatedDate,Description_vod__c,End_Date_vod__c,Event_Stage_BMS__c, Event_Number_BMS__c,
                                                Event_Type__c,Expense_Amount_vod__c,Expense_Post_Status_vod__c,
                                                Expense_System_External_ID_vod__c,External_ID_BMS__c,Has_Rate_Card__c,Id,
                                                IsDeleted,IsLocked,LastActivityDate,LastModifiedById,LastModifiedDate,Location__c,
                                                MayEdit,Mobile_ID_vod__c,Name,OwnerId,Primary_Product__c,RecordTypeId,Secondary_Product__c,
                                                Speaker_BMS_CORE__c,Speaker_BMS__c,Start_Date_vod__c,State_BMS__c,Status_BMS_CORE__c,
                                                Status_BMS__c,Submit_Expense_vod__c,SystemModstamp,TA_BMS__c,
                                                Total_Expenses_BMS_CORE__c,Website__c 
                                        FROM Medical_Event_vod__c
                                        WHERE Id = :this.meetingSpeaker.Meeting__c]) { 
            this.medicalEvent = me;
        } 
        owner = [SELECT Name, Id
                 FROM User
                 WHERE Id =: this.medicalEvent.OwnerId];
                 
        
                 
        for (UserTerritory ut : [SELECT Id,TerritoryId,UserId FROM UserTerritory WHERE UserId =: this.medicalEvent.OwnerId]){
            this.territoryIds.add(ut.TerritoryId);
        }
        for (Territory t : [SELECT Name FROM Territory WHERE Id IN :this.territoryIds]){
            if(!String.IsEmpty(t.Name) && t.Name != 'null') {
                system.debug('Territory name: ' + t.Name);
                this.ownerTerritory += t.Name + ', ';
            }
        }
        if (this.ownerTerritory != null) {
            this.ownerTerritory = this.ownerTerritory.Substring(0,this.ownerTerritory.length()-2);  
        }        
                 
        speaker = [SELECT FirstName,LastName,Middle_vod__c,Name, IsPersonAccount
                   FROM Account
                   WHERE ID = :this.meetingSpeaker.Account__c LIMIT 1];
            
        speakerAddress = new Address_vod__c();
        for (Address_vod__c ad : [SELECT Address_line_2_vod__c,City_vod__c,Id,Mailing_vod__c,Name,Primary_vod__c,State_vod__c,Zip_vod__c 
                          FROM Address_vod__c 
                          WHERE Account_vod__c = :this.speaker.Id
                          ORDER BY Primary_vod__c DESC LIMIT 1] ) {
            speakerAddress = ad;                          
        
        }                         
        
    }
    
    public PageReference English() {
        system.debug('jk - firing as english');
        this.renderAs = 'pdf';
        this.renderAsPdf = true;
        if (this.medicalEvent.Event_Type__c == 'Corporate Support Event') {
            this.render = 'englishCorp';
        } else {
            this.render = 'englishHonorarium';
        }
        return ApexPages.currentPage();
    }
    public PageReference French() {
        system.debug('jk - firing as french');
        this.renderAs = 'pdf';
        this.renderAsPdf = true;
        if (this.medicalEvent.Event_Type__c == 'Corporate Support Event') {
            this.render = 'frenchCorp';
        } else {
            this.render = 'frenchHonorarium';
        }
        return ApexPages.currentPage();

    }
}