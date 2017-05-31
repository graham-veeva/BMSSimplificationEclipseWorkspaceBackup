public with sharing class NewMeeting_BMS_EMEA {
        
        public id masterfileID {get;set;}
        public Master_File_BMS_EMEA__c masterFile{get; set;} 
        public RecordType meetingPlanRecId  {get;set;}
        public Medical_Event_vod__c meeting {get;set;}
        public String userName {get;set;}
        list<String> customFields = new list<String>();
        
        public boolean customSectionView{ 
            get{
                if(customFields.size()>0) return true;
                else return false;
            }
        }
        
        public NewMeeting_BMS_EMEA(ApexPages.StandardController controller) {
                
            masterfileID = ApexPages.currentPage().getParameters().get('id');
                    
                    //Get details about this master file
            masterFile = [SELECT  Id,Meeting_Name_guidance_BMS_EMEA__c,Other_Costs_Event_Budget_BMS_EMEA__c,Hotel_Event_Budget_BMS_EMEA__c,Meals_Event_Budget_BMS_EMEA__c,Transportation_Budget_Event_BMS_EMEA__c,Sponsorship_of_Event_Budget_BMS_EMEA__c,HCPs_registration_fees_Event_BMS_EMEA__c ,Honorarium_Event_Budget_BMS_EMEA__c,of_Sponsored_Participants_BMS_EMEA__c,of_Audience_Participants_BMS_EMEA__c,of_BMS_Employees_BMS_EMEA__c,Targeted_number_of_Meetings_BMS_EMEA__c,Objective_Total_BMS_EMEA__c,End_Date_BMS_EMEA__c,Start_Date_BMS_EMEA__c,Meetings_January_BMS_EMEA__c,Meetings_February_BMS_EMEA__c,Meetings_March_BMS_EMEA__c,Meetings_April_BMS_EMEA__c,Meeting_May_BMS_EMEA__c,
                                Meeting_June_BMS_EMEA__c,Meeting_July_BMS_EMEA__c,Meeting_August_BMS_EMEA__c,Meeting_September_BMS_EMEA__c,Meeting_October_BMS_EMEA__c,Meeting_November_BMS_EMEA__c,Meeting_Dec_BMS_EMEA__c
                          FROM Master_File_BMS_EMEA__c
                          WHERE Id = :this.MasterFileID];
            
            //Get Recordtype custom settings
            BMS_EMEA_Settings__c bmsEmea = BMS_EMEA_Settings__c.getInstance();
            
            String newMeetingRecordtype = bmsEmea.New_Meeting_button_Recordtype__c;
            
            system.debug('--- New Meeting RecordType ---'+newMeetingRecordtype);
                          
            meetingPlanRecId = [select SobjectType,Name,IsActive,Id,DeveloperName From RecordType where SobjectType='Medical_Event_vod__c' and DeveloperName=:newMeetingRecordtype];                               
            
            userName = UserInfo.getName();
            
            //Create new medical event
            meeting = new  Medical_Event_vod__c();
                     
            meeting.RecordTypeId = meetingPlanRecId.id;
            meeting.Master_File_BMS_EMEA__c = masterFile.Id;
            meeting.Name = masterfile.Meeting_Name_guidance_BMS_EMEA__c;
                     
            meeting.OwnerId = UserInfo.getUserId(); 
            
            string LineManagerid = [SELECT Id, ManagerId from User where Id =: meeting.OwnerId].ManagerId;
            meeting.Person_to_notify_BMS_EMEA__c =LineManagerid ;
            
        }
        
     //Custom fields section, added by Viktor 2014-03-20
     public Component.Apex.PageBlockSection getCustomFields(){
        BMS_EMEA_Settings__c bmsEmea = BMS_EMEA_Settings__c.getInstance();
        if(bmsEmea.New_Meeting_Custom_Fields__c!=null) customFields = bmsEmea.New_Meeting_Custom_Fields__c.split(';'); 
        
        Component.Apex.PageBlockSection section = new Component.Apex.PageBlockSection();
        section.Title = 'Additional Fields';
        section.collapsible = false;
        section.rendered = customSectionView;
        
        for(String fieldDevName : customFields){
            Component.Apex.InputField inFld = new Component.Apex.InputField();
            inFld.expressions.value = '{!meeting.' + fieldDevName + '}';
            section.childComponents.add( inFld );
        }
        
        return section;
     }
     
        
     public PageReference saveMeeting(){
                
         try{
            insert meeting;
         }catch(System.DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                if(e.getDmlFieldNames(i).size()==0)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(i) ));
            }
            return null;
         }     
        
         PageReference pageRef = new PageReference('/'+meeting.id);
            
         return pageRef;
         
    }
}