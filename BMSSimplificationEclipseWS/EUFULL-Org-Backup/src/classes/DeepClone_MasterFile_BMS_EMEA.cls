public with sharing class DeepClone_MasterFile_BMS_EMEA {
    
    public Id masterFileID {get;set;}
    public Master_File_BMS_EMEA__c masterFile {get;set;}
    
    public list<Master_File_Material_BMS_EMEA__c> materials = new list<Master_File_Material_BMS_EMEA__c>();
    public list<Master_File_Participant_BMS_EMEA__c> participants = new list<Master_File_Participant_BMS_EMEA__c>();

    public DeepClone_MasterFile_BMS_EMEA(ApexPages.StandardController controller) {
        
        //Retrieve the masterfile 
        masterFileID = ApexPages.currentPage().getParameters().get('id');
        
        //masterFile = [Select of_Sponsored_Participants_BMS_EMEA__c,of_BMS_Employees_BMS_EMEA__c,of_Audience_Participants_BMS_EMEA__c,Venue_BMS_EMEA__c,Transportation_Budget_all_Event_BMS_EMEA__c,Transportation_Budget_Event_BMS_EMEA__c,Total_Working_Days__c,Total_Budget_per_Event_BMS_EMEA__c,Total_Budget_all_Events_BMS_EMEA__c,Therapeutic_Area_BMS_EMEA__c,Targeted_number_of_Meetings_BMS_EMEA__c,Status_BMS_EMEA__c,Start_Date_BMS_EMEA__c,Sponsorship_of_Event_Budget_BMS_EMEA__c,Sponsorship_of_Event_All_Budget_BMS_EMEA__c,Service_for_Sponsorship_Meeting_BMS_EMEA__c,Service_for_Contract_with_HCP_BMS_EMEA__c,RecordTypeId,Rationale_for_Business_Need_BMS_EMEA__c,Product_Compound_BMS_EMEA__c,P_L_Classification_BMS_EMEA__c,OwnerId,Other_Costs_Event_Budget_BMS_EMEA__c,Other_Costs_All_Events_Budget_BMS_EMEA__c,Objective_Total_BMS_EMEA__c,Name,Meetings_March_BMS_EMEA__c,Meetings_January_BMS_EMEA__c,Meetings_February_BMS_EMEA__c,Meetings_April_BMS_EMEA__c,Meeting_September_BMS_EMEA__c,Meeting_October_BMS_EMEA__c,Meeting_November_BMS_EMEA__c,Meeting_Name_guidance_BMS_EMEA__c,Meeting_May_BMS_EMEA__c,Meeting_June_BMS_EMEA__c,Meeting_July_BMS_EMEA__c,Meeting_Dec_BMS_EMEA__c,Meeting_August_BMS_EMEA__c,Meals_Event_Budget_BMS_EMEA__c,Meals_All_Events_Budget_BMS_EMEA__c,MayEdit,Master_File_Name_BMS_EMEA__c,Id,Hotel_Event_Budget_BMS_EMEA__c,Hotel_All_Events_Budget_BMS_EMEA__c,Honorarium_Event_Budget_BMS_EMEA__c,Honorarium_All_Events_Budget_BMS_EMEA__c,Has_All_Documents_BMS_EMEA__c,HCPs_registration_fees_Event_BMS_EMEA__c,HCPs_registration_All_Events_BMS_EMEA__c,Format_Remote_BMS_EMEA__c,Format_Face_to_Face_BMS_EMEA__c,FFM_Step_BMS_EMEA__c,External_ID_BMS_EMEA__c,End_Date_BMS_EMEA__c,Details_of_Meeting_BMS_EMEA__c,Currency_BMS_EMEA__c,Country_BMS_EMEA__c,Contracts_BMS_EMEA__c,Attachment_Validated_BMS_EMEA__c,Approval_Comment_Check_BMS_EMEA__c,Alignment_with_Strategy_BMS_EMEA__c,Activity_Type_BMS_EMEA__c From Master_File_BMS_EMEA__c where id=:masterFileID];
        
        /** MASTERFILE dynamic all fields query **/
        //Retrieves list of ALL fields for the masterfile
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Master_File_BMS_EMEA__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        
        String masterfileQueryFields = '';
        for(Schema.SObjectField s : fldObjMapValues)
        {
            String theName = s.getDescribe().getName();
            // Continue building your dynamic query string
            if(  theName != 'Status_BMS_EMEA__c' &&
                 theName != 'Name' &&
                 theName != 'External_ID_BMS_EMEA__c' &&
                 theName != 'Total_Planned_Cost_BMS_EMEA__c' &&
                 theName != 'Total_Actual_Cost_BMS_EMEA__c' &&
               !(theName.startsWith('RollUp_') && (theName.endsWith('_Planned_BMS_EMEA__c')|| theName.endsWith('_Completed_BMS_EMEA__c')))
              )
                    masterfileQueryFields += theName + ',';
            
        }
        
        //Remove the last comma
        masterfileQueryFields = masterfileQueryFields.subString(0, masterfileQueryFields.length() - 1);
        
        //Build Query String
        String masterfileQuery = 'SELECT '+ masterfileQueryFields +' FROM Master_File_BMS_EMEA__c WHERE id=:masterFileID';
        
        //Retrieve masterfile record
        masterFile = Database.query(masterfileQuery);
        
        
        
        //Retrieve the list of related child materials
        /** MATERIALS dynamic all fields query **/
        //Retrieves list of ALL fields for the Materials
        Map<String, Schema.SObjectField> fldObjMapMaterials = schema.SObjectType.Master_File_Material_BMS_EMEA__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapMaterialsValues = fldObjMapMaterials.values();
        
        String materialsQueryFields = '';
        for(Schema.SObjectField s : fldObjMapMaterialsValues)
        {
            String theName = s.getDescribe().getName();
            // Continue building your dynamic query string
            materialsQueryFields += theName + ',';
        }
        //Remove the last comma
        materialsQueryFields = materialsQueryFields.subString(0, materialsQueryFields.length() - 1);
        
        //Build Query String
        String materialsQuery = 'SELECT '+ materialsQueryFields +' FROM Master_File_Material_BMS_EMEA__c WHERE Master_File_BMS_EMEA__c=:masterFileID';
        
        //Retrieve related materials
        //materials = [select Status_BMS_EMEA__c,Ref_No_BMS_EMEA__c,RecordTypeId,Name,MayEdit,Material_BMS_EMEA__c,Master_File_BMS_EMEA__c,Id From Master_File_Material_BMS_EMEA__c where Master_File_BMS_EMEA__c=:masterFile.Id];  
        materials = Database.query(materialsQuery);
        
        
        
        /** PARTICIPANTS dynamic all fields query **/
        //Retrieves list of ALL fields for the Participants
        Map<String, Schema.SObjectField> fldObjMapParticipants = schema.SObjectType.Master_File_Participant_BMS_EMEA__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapParticipantsValues = fldObjMapParticipants.values(); 
        
        String participantsQueryFields = '';
        for(Schema.SObjectField s : fldObjMapParticipantsValues)
        {
            String theName = s.getDescribe().getName();
            // Continue building your dynamic query string
            participantsQueryFields += theName + ',';
        }
        //Remove the last comma
        participantsQueryFields = participantsQueryFields.subString(0, participantsQueryFields.length() - 1);
        //Build Query String
        String participantsQuery = 'SELECT '+ participantsQueryFields +' FROM Master_File_Participant_BMS_EMEA__c WHERE Master_File_BMS_EMEA__c=:masterFileID';
        
        participants = Database.query(participantsQuery);
    //  participants =[Select TherArea_Expertise_Specialty_BMS_EMEA__c,RecordTypeId,Number_per_Meeting_BMS_EMEA__c,Number_all_Meetings_BMS_EMEA__c,Name,MayEdit,Master_File_BMS_EMEA__c,MF_Planned_BMS_EMEA__c,Id,Fields_Planned_BMS_EMEA__c,Fields_Delivered_BMS_EMEA__c From Master_File_Participant_BMS_EMEA__c where Master_File_BMS_EMEA__c=:masterFile.Id];
        
        
    }
    
    

    public PageReference deepClone(){
        
        
        try{ 
            //Clone the masterfile
            Master_File_BMS_EMEA__c masterFileClone = masterFile.clone(false,true);
            
            system.debug('---CLONE---'+masterFileClone);
            
            //Reset the masterfile status
            //masterFileClone.Status_BMS_EMEA__c ='Draft';
            masterFileClone.Master_File_Name_BMS_EMEA__c = 'CLONE_'+masterFileClone.Master_File_Name_BMS_EMEA__c;
            
            if(masterFileClone.BMS_EMEA_Original_Record_Type__c != '' && masterFileClone.BMS_EMEA_Original_Record_Type__c != null)
                masterFileClone.RecordTypeId = masterFileClone.BMS_EMEA_Original_Record_Type__c;
            else{
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Your source object does not have RT set'));
               return null;
            }    
            
            
            insert masterFileClone;
            
            list<Master_File_Material_BMS_EMEA__c> clonedMaterials = new list <Master_File_Material_BMS_EMEA__c>();
            //Copy the related materials to the new clone
            if(materials.size() > 0){
                
                for(Master_File_Material_BMS_EMEA__c material : materials){
                    
                    //Create a clone
                    Master_File_Material_BMS_EMEA__c clone = material.clone(false,true);
                    
                    //Reset the reference to the cloned Masterfile
                    clone.Master_File_BMS_EMEA__c = masterFileClone.id;
                    
                    //Flag the name
                    //clone.Name = 'CLONE_'+clone.Name;
                    
                    //Reset the Status 
                    clone.Status_BMS_EMEA__c = 'To be approved';
                    
                    clonedMaterials.add(clone);
                }   
            }
            
            list<Master_File_Participant_BMS_EMEA__c> clonedParticipants = new list <Master_File_Participant_BMS_EMEA__c>();
            
            //Copy the related participants to the new clone
            if(participants.size() > 0){
                
                for(Master_File_Participant_BMS_EMEA__c participant : participants){
                    
                    //Create a clone
                    Master_File_Participant_BMS_EMEA__c clone = participant.clone(false,true);
                    
                    //Reset the reference to the cloned Masterfile
                    clone.Master_File_BMS_EMEA__c = masterFileClone.id;
                    
                    clonedParticipants.add(clone);
                }   
            }
            
            //Insert the participants and materials
            if(clonedParticipants.size() > 0){
                insert clonedParticipants;
            }
            if(clonedMaterials.size() > 0){
                insert clonedMaterials;
            }
            
            return new PageReference('/'+masterFileClone.id+'/e?retURL=%2F'+masterFileClone.id);
        
        }catch(System.Exception ex){
            String error = ''+ex;
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,error);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error));
            return null;
        }
        
    }

}