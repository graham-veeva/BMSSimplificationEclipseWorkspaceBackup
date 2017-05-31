public with sharing class Event_Management_Contract_Redirect {
    public Id meetingSpeakerId {get; set;}
    
    public Event_Management_Contract_Redirect(ApexPages.StandardController controller) {
        this.meetingSpeakerId = ((Meeting_Speaker_BMS__c)controller.getRecord()).Id;
    }
    
    public void English() {
        system.debug('jk - firing as english');


    }
    public void French() {


    }
}