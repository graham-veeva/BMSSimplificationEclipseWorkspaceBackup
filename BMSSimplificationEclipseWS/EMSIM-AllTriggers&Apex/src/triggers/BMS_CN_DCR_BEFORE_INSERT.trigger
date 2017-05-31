/*
* Name: BMS_CN_DCR_BEFORE_INSERT 
* Description: process before insert record
* Author: Roy Zhang
* Created Date: 03/19/2013
* Last Modified Date: 03/19/2013
*/
trigger BMS_CN_DCR_BEFORE_INSERT on Data_Change_Request_BMS_CN__c (before insert) {
	
	for(integer i = 0; i < trigger.new.Size(); i++){
		Data_Change_Request_BMS_CN__c dcrNew = trigger.new[i];
		
		// Get old Record Type Name
        String strRecTypOld = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Id =: dcrNew.RecordTypeId].Name;
		
		// Add new doctor
        if(dcrNew.Action_Type_BMS_CN__c == 'ADD') {
        	
        	// Check duplicated doctor
        	integer iCnt = [SELECT
        						COUNT()
        					FROM
        						Account
        					WHERE
        						LastName =: dcrNew.Doctor_Name_BMS_CN__c AND
        						Department_BMS_CN__c =: dcrNew.Department_BMS_CN__c AND
        						Primary_Parent_vod__c =: dcrNew.Hospital_BMS_CN__c AND
        						Gender_vod__c =: dcrNew.Gender_BMS_CN__c AND
        						Administrative_Title_BMS_CN__c =: dcrNew.Administrative_Title_BMS_CN__c AND
        						Technical_Title_BMS_CN__c =: dcrNew.Technical_Title_BMS_CN__c];
        						
        	if(iCnt > 0) {
        		trigger.new[0].adderror('The doctor exist in system!');
        	}
        	
        	// Saved -> Submitted
        	if(dcrNew.Status_BMS_CN__c == 'Submitted' && strRecTypOld == 'Add Individual' ) {
        		// Change record type
        		dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Add Individual - Submitted'].Id;
        		
        		// Copy doctor info from user input to 3th party verification part
        		dcrNew.Doctor_Name_Verified_BMS_CN__c = dcrNew.Doctor_Name_BMS_CN__c;
        		dcrNew.Department_Verified_BMS_CN__c = dcrNew.Department_BMS_CN__c;
        		dcrNew.Hospital_Verified_BMS_CN__c = dcrNew.Hospital_BMS_CN__c;
        		dcrNew.Gender_Verified_BMS_CN__c = dcrNew.Gender_BMS_CN__c;
        		dcrNew.Technical_Title_Verified_BMS_CN__c = dcrNew.Technical_Title_BMS_CN__c;
        		dcrNew.Administrative_Title_Verified_BMS_CN__c = dcrNew.Administrative_Title_BMS_CN__c;
        		dcrNew.Social_Title_Verified_BMS_CN__c = dcrNew.Social_Title_BMS_CN__c;
        	}
        }
		
		// Edit doctor information
        if(dcrNew.Action_Type_BMS_CN__c == 'EDIT') {
        	// Saved -> Submitted
        	if(dcrNew.Status_BMS_CN__c == 'Submitted' && strRecTypOld == 'Edit Individual' ) {
        		// Change record type
        		dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Edit Individual - Submitted'].Id;
        		
        		// Copy doctor info from user input to 3th party verification part
        		dcrNew.Department_Verified_BMS_CN__c = dcrNew.Department_BMS_CN__c;
        		dcrNew.Hospital_Verified_BMS_CN__c = dcrNew.Hospital_BMS_CN__c;
        		dcrNew.Gender_Verified_BMS_CN__c = dcrNew.Gender_BMS_CN__c;
        		dcrNew.Technical_Title_Verified_BMS_CN__c = dcrNew.Technical_Title_BMS_CN__c;
        		dcrNew.Administrative_Title_Verified_BMS_CN__c = dcrNew.Administrative_Title_BMS_CN__c;
        		dcrNew.Social_Title_Verified_BMS_CN__c = dcrNew.Social_Title_BMS_CN__c;
        	}
        }
        
        // Delete doctor
        if(dcrNew.Action_Type_BMS_CN__c == 'DEL') {
        	// Saved -> Submitted
        	if(dcrNew.Status_BMS_CN__c == 'Submitted' && strRecTypOld == 'Del Individual' ) {
        		// Change record type
        		dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Del Individual - Submitted'].Id;
        	}
        }		
	}
}