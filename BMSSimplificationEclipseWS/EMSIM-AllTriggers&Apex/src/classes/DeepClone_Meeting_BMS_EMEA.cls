public with sharing class DeepClone_Meeting_BMS_EMEA {
	
	public Id meetingID {get;set;}
	public Medical_Event_vod__c meeting {get;set;}
	
	public list<Meeting_Material_BMS_EMEA__c> materials = new list<Meeting_Material_BMS_EMEA__c>();
	public list<Meeting_Planned_Participant_BMS_EMEA__c> plannedParticipants = new list<Meeting_Planned_Participant_BMS_EMEA__c>();
	public list<Meeting_Speaker_BMS__c> speakers = new list<Meeting_Speaker_BMS__c>();
	public list<Meeting_Contract_BMS_EMEA__c > contracts = new list<Meeting_Contract_BMS_EMEA__c >();
	
	public DeepClone_Meeting_BMS_EMEA(ApexPages.StandardController controller) {
		
		
		//Retrieve the meeting
		meetingID = ApexPages.currentPage().getParameters().get('id');
		
		/*
		meeting = [Select m.of_Attendees_BMS_CA__c, m.Website__c, m.WBS_Element_BMS_IC__c, m.Venue_BMS_IC__c, m.User_Source_Country_BMS_CORE__c, m.Transportation_Planned_BMS_EMEA__c, 
		           m.Transportation_Budgeted_BMS_EMEA__c, m.Transportation_Actual_BMS_EMEA__c, m.Total_Planned_BMS_EMEA__c, m.Total_Expenses_BMS_CORE__c, m.Total_Expected_BMS_IC__c, 
		           m.Total_Budgeted_BMS_EMEA__c, m.Total_Actual_BMS_EMEA__c, m.Target_Attendees_BMS_EMEA__c, m.TA_BMS__c, m.SystemModstamp, m.Submit_Expense_vod__c, m.Status_BMS__c, 
		           m.Status_BMS_CORE__c, m.State_BMS__c, m.Start_Time_BMS_IC__c, m.Start_Date_vod__c, m.Start_Date_Time_BMS_IC__c, m.Sponsorship_of_Event_Planned_BMS_EMEA__c, 
		           m.Sponsorship_of_Event_Budgeted_BMS_EMEA__c, m.Sponsorship_of_Event_Actual_BMS_EMEA__c, m.Specialists_BMS_IC__c, m.Speaker_Location_BMS_EMEA__c, 
		           m.Speaker_Honorarium_Exclusion_BMS_IC__c, m.Speaker_BMS__c, m.Speaker_BMS_CORE__c, m.Secondary_Product__c, m.Related_Event_ID_BMS_IC__c, m.RecordTypeId,
		           m.Product_BMS_EMEA__c, m.Primary_Product__c, m.Postal_Code_BMS_IC__c, m.Planned_Start_Date_BMS_EMEA__c, m.Planned_Expense_Amount__c, m.Planned_End_Date_BMS_EMEA__c,
		           m.Planned_Duration_BMS_EMEA__c, m.Phone_BMS_IC__c, m.Pharmacists_BMS_IC__c, m.P_L_Classification_MasterFile_BMS_EMEA__c, m.Owner_Lookup_BMS_CORE__c,
		           m.OwnerId, m.Other_Costs_Planned_BMS_EMEA__c, m.Other_Costs_Budgeted_BMS_EMEA__c, m.Other_Costs_Actual_BMS_EMEA__c, m.Nurses_Others_BMS_IC__c, m.Name,
		           m.Mobile_ID_vod__c, m.Meeting_Delivered_BMS_EMEA__c, m.MeetingRecordTypeDelete_BMS_EMEA__c, m.Meals_Planned_BMS_EMEA__c, m.Meals_Budgeted_BMS_EMEA__c,
		           m.Meals_Actual_BMS_EMEA__c, m.MayEdit, m.Max_of_Attendees_BMS_EMEA__c, m.Master_File_BMS_EMEA__c, m.MF_Therapeutic_Area_BMS_EMEA__c,
		           m.MF_Product_Compound_BMS_EMEA__c, m.Location__c, m.Learning_Objectives_BMS_IC__c, m.LastModifiedDate,
		           m.Interns_Residents_BMS_IC__c, m.Id, m.Hotel_Planned_BMS_EMEA__c, m.Hotel_Budgeted_BMS_EMEA__c,
		           m.Hotel_Actual_BMS_EMEA__c, m.Honorarium_Planned_BMS_EMEA__c, m.Honorarium_Budgeted_BMS_EMEA__c, m.Honorarium_Actual_BMS_EMEA__c, m.Has_Rate_Card__c,
		           m.Has_All_Documents_BMS__c, m.HCPs_registration_fees_Planned_BMS_EMEA__c, m.HCPs_registration_fees_Budgeted_BMS_EMEA__c, m.HCPs_registration_fees_Actual_BMS_EMEA__c,
		           m.GP_FMs_BMS_IC__c, m.Finance_Code_BMS_IC__c, m.FFM_Step_BMS_EMEA__c, m.FFM_Activity_Type_BMS_EMEA__c, m.External_ID_BMS__c, m.Expense_System_External_ID_vod__c,
		           m.Expense_Post_Status_vod__c, m.Expense_Amount_vod__c, m.Event_Type__c, m.Event_SubType_BMS_IC__c, m.Event_Stage_BMS__c, m.Event_Number_BMS__c,
		           m.End_Time_BMS_IC__c, m.End_Date_vod__c, m.End_Date_Time_BMS_IC__c, m.Duration_BMS_EMEA__c, m.Description_vod__c, m.Currency_BMS_EMEA__c,
		           m.Country_MasterFile_BMS_EMEA__c, m.Country_BMS__c, m.Contact_BMS_EMEA__c, m.Comments_for_Costs_BMS_EMEA__c,
		           m.City_BMS__c, m.Budget__c, m.Broadcast_Location_BMS_EMEA__c, m.Auto_Approve_LnL__c, m.Audience_Location_BMS_EMEA__c, m.Attachment_Validated_BMS_EMEA__c,
		           m.Associated_Budget_BMS_CORE__c, m.Approved_Agenda_Number__c, m.Approval_Comment_Meeting_Check_BMS_EMEA__c, m.Address_vod__c, m.Address_Line_1_BMS_IC__c,
		           m.Activity_Type_BMS_EMEA__c, m.Active_vod__c, m.Account_vod__c From Medical_Event_vod__c m where m.id=:meetingID];
		
		*/
		
		/** Meeting dynamic all fields query **/
		//Retrieves list of ALL fields for the masterfile
		Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Medical_Event_vod__c.fields.getMap();
		List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
		
		String meetingQueryFields = '';
		for(Schema.SObjectField s : fldObjMapValues)
		{
		   	String theName = s.getDescribe().getName();
   			// Continue building your dynamic query string
   			meetingQueryFields += theName + ',';
		}
		
		//Remove the last comma
		meetingQueryFields = meetingQueryFields.subString(0, meetingQueryFields.length() - 1);
		
		//Build Query String
		String meetingQuery = 'SELECT '+ meetingQueryFields +' FROM Medical_Event_vod__c WHERE id=:meetingID';
		
		//Retrieve masterfile record
		meeting = Database.query(meetingQuery);
		
		

       /** Meeting Materials  dynamic all fields query **/
		//Retrieves list of ALL fields for the Materials
		Map<String, Schema.SObjectField> fldObjMapMaterials = schema.SObjectType.Meeting_Material_BMS_EMEA__c.fields.getMap();
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
		String materialsQuery = 'SELECT '+ materialsQueryFields +' FROM Meeting_Material_BMS_EMEA__c WHERE Meeting_BMS_EMEA__c=:meetingID';
		
		//Get related meeting materials
		//	materials = [Select m.Used_BMS_EMEA__c, m.Status_BMS_EMEA__c, m.Ref_No_BMS_EMEA__c, m.RecordTypeId, m.Name, m.Meeting_BMS_EMEA__c, m.MayEdit, m.Material_BMS_EMEA__c, m.Id From Meeting_Material_BMS_EMEA__c m where m.Meeting_BMS_EMEA__c=:meeting.id ];

		//Retrieve related materials
		materials = Database.query(materialsQuery);
			
		
		/**Planned Participants **/
		Map<String, Schema.SObjectField> fldObjMapParticipants = schema.SObjectType.Meeting_Planned_Participant_BMS_EMEA__c.fields.getMap();
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
		String participantsQuery = 'SELECT '+ participantsQueryFields +' FROM Meeting_Planned_Participant_BMS_EMEA__c WHERE Meeting_BMS_EMEA__c=:meetingID';
		
		//Get the related planned participants
		//plannedParticipants = [Select m.Sponsored_Participant_BMS_EMEA__c, m.RecordTypeId, m.Number_BMS_EMEA__c, m.Name, m.Meeting_BMS_EMEA__c, m.MayEdit, m.Id, m.Function_TherArea_Specialty_BMS_EMEA__c, m.DHG_is_required_BMS_EMEA__c, m.Company_BMS_EMEA__c From Meeting_Planned_Participant_BMS_EMEA__c m where m.Meeting_BMS_EMEA__c =:meeting.id];		
		plannedParticipants = Database.query(participantsQuery);

		//get the meeting speakers
		/** Meeting Speakers  dynamic all fields query **/
		//Retrieves list of ALL fields for the Speaker 	
		Map<String, Schema.SObjectField> fldObjMapSpeakers = schema.SObjectType.Meeting_Speaker_BMS__c.fields.getMap();
		List<Schema.SObjectField> fldObjMapSpeakersValues = fldObjMapSpeakers.values();
		
		String speakersQueryFields = '';
		for(Schema.SObjectField s : fldObjMapSpeakersValues)
		{
		   	String theName = s.getDescribe().getName();
   			// Continue building your dynamic query string
   			speakersQueryFields += theName + ',';
		}
		
		//Remove the last comma
		speakersQueryFields = speakersQueryFields.subString(0, speakersQueryFields.length() - 1);
		//Build Query String
		String speakersQuery = 'SELECT '+ speakersQueryFields +' FROM Meeting_Speaker_BMS__c WHERE Meeting__c=:meetingID';
		
		//Retrieve Speakers records
		speakers = Database.query(speakersQuery);
		/*
		speakers = [Select m.Total_BMS_EMEA__c, m.SystemModstamp, m.Speaker_Specialty__c, m.Send_Checque_To_BMS_IC__c, m.Role_BMS_CA__c, m.RecordTypeId, m.Rate_Card__c, m.Rate_Card_Planned_Expenses__c, m.Province_BMS_IC__c, m.Postal_Code_BMS_IC__c,
		            m.Planned_Expenses_BMS_IC__c, m.Payable_To_BMS_IC__c, m.PO_code_BMS_EMEA__c, m.Other_Fees_BMS_EMEA__c, m.Number_of_hours_BMS_EMEA__c, m.Name, m.Mobile_ID_vod__c, m.Meeting__c, m.MayEdit, m.Lock_Rate_Card__c,
		             m.Id, m.Hourly_Rate_BMS_EMEA__c, m.Has_Rate_Card__c, m.DHG_is_required_BMS_EMEA__c, m.DHG_Document_BMS_EMEA__c, m.DHG_Comment_BMS_EMEA__c, 
		             m.Comments_BMS_IC__c, m.City_BMS_IC__c, m.Address_Line_1_BMS_IC__c, m.Account__c From Meeting_Speaker_BMS__c m where m.Meeting__c=:meeting.id];
		*/             
		 
		 
		 
		 
		/** Contracts  dynamic all fields query **/
		//Retrieves list of ALL fields for the Speaker 	
		Map<String, Schema.SObjectField> fldObjMapContracts = schema.SObjectType.Meeting_Contract_BMS_EMEA__c.fields.getMap();
		List<Schema.SObjectField> fldObjMapContractsValues = fldObjMapContracts.values();
		
		String contractsQueryFields = '';
		for(Schema.SObjectField s : fldObjMapContractsValues)
		{
		   	String theName = s.getDescribe().getName();
   			// Continue building your dynamic query string
   			contractsQueryFields += theName + ',';
		} 
		//Remove the last comma
		contractsQueryFields = contractsQueryFields.subString(0, contractsQueryFields.length() - 1);
		//Build Query String
		String contractsQuery = 'SELECT '+ contractsQueryFields +' FROM Meeting_Contract_BMS_EMEA__c WHERE Meeting_BMS_EMEA__c=:meetingID';
		
		//Retrieve Speakers records
		contracts = Database.query(contractsQuery);
		            
	//	contracts = [Select m.Ref_No_BMS_EMEA__c, m.Name, m.Meeting_BMS_EMEA__c, m.MayEdit, m.Id, m.Contract_BMS_EMEA__c From Meeting_Contract_BMS_EMEA__c m where m.Meeting_BMS_EMEA__c=:meeting.id];           
		             
		             
	}
	
	public PageReference deepClone(){
		
		try{
			
			//Clone the meeting
			Medical_Event_vod__c meetingClone = meeting.clone(false,true);
			
			system.debug('---CLONE---'+meetingClone);
			
			//flag the name
			meetingClone.Name ='CLONE_'+meetingClone.Name;
			
			//Reset meeting Status
			meetingClone.Status_BMS_CORE__c ='Saved';
			
			insert meetingClone;
			
			//Copy the related materials to the new clone
			list<Meeting_Material_BMS_EMEA__c> clonedMaterials = new list <Meeting_Material_BMS_EMEA__c>();
			
			if(materials.size() > 0){
				
				for(Meeting_Material_BMS_EMEA__c material : materials){
					
					//Create a clone
					Meeting_Material_BMS_EMEA__c clone = material.clone(false,true);
					
					//Reset the reference to the cloned Meeting
					clone.Meeting_BMS_EMEA__c = meetingClone.id;
					
					//Reset the meeting material
					clone.Status_BMS_EMEA__c ='To be approved';
					
					clonedMaterials.add(clone);
				}	
			}
		
			//Copy the related planned participants to the new clone
			list<Meeting_Planned_Participant_BMS_EMEA__c> clonedParticipants = new list <Meeting_Planned_Participant_BMS_EMEA__c>();
			
			if(plannedParticipants.size() > 0){
				
				for(Meeting_Planned_Participant_BMS_EMEA__c participant : plannedParticipants){
					
					//Create a clone
					Meeting_Planned_Participant_BMS_EMEA__c clone = participant.clone(false,true);
					
					//Reset the reference to the cloned Meeting
					clone.Meeting_BMS_EMEA__c = meetingClone.id;
					
					clonedParticipants.add(clone);
				}	
			}
		
			//Copy the related speakers to the new clone
			list<Meeting_Speaker_BMS__c> clonedSpeakers = new list <Meeting_Speaker_BMS__c>();
			
			if(speakers.size() > 0){
				
				for(Meeting_Speaker_BMS__c speaker : speakers){
					
					//Create a clone
					Meeting_Speaker_BMS__c clone = speaker.clone(false,true);
					
					//Reset the reference to the cloned Meeting
					clone.Meeting__c = meetingClone.id;
					
					clonedSpeakers.add(clone);
				}	
			}
		
			//Copy the related contracts to the new clone
			list<Meeting_Contract_BMS_EMEA__c> clonedContracts = new list <Meeting_Contract_BMS_EMEA__c>();
			
			if(contracts.size() > 0){
				
				for(Meeting_Contract_BMS_EMEA__c contract : contracts){
					
					//Create a clone
					Meeting_Contract_BMS_EMEA__c clone = contract.clone(false,true);
					
					//Reset the reference to the cloned Meeting
					clone.Meeting_BMS_EMEA__c = meetingClone.id;
					
					clonedContracts.add(clone);
				}	
			}
			
			//Insert the participants and materials
			if(clonedMaterials.size() > 0){
				insert clonedMaterials;
			}
			if(clonedParticipants.size() > 0){
			//	insert clonedParticipants;
			}
			if(clonedSpeakers.size() > 0){
				insert clonedSpeakers;
			}
			if(clonedContracts.size() > 0){
			//insert clonedContracts;
			}
			
			return new PageReference('/'+meetingClone.id+'/e?retURL=%2F'+meetingClone.id);
			
		}catch(System.Exception ex){
			String error = ''+ex;
			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error));
			return null;
		}
		
		
	}
	
	
	
}