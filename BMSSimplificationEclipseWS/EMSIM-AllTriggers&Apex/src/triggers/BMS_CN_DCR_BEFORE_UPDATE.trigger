/*
* Name: BMS_CN_DCR_BEFORE_UPDATE
* Description: process before update
* Author: Roy Zhang
* Created Date: 02/21/2013
* Last Modified Date: 03/19/2013
*/
trigger BMS_CN_DCR_BEFORE_UPDATE on Data_Change_Request_BMS_CN__c (before update) {
    
    for(integer i = 0; i < trigger.new.Size(); i++){        
        Data_Change_Request_BMS_CN__c dcrNew = trigger.new[i];
        
        // Get old Record Type Name
        String strRecTypOld = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Id =: dcrNew.RecordTypeId].Name;
      
        // Add new doctor
        if(dcrNew.Action_Type_BMS_CN__c == 'ADD') {        
            
            // Saved -> Submitted
            if(dcrNew.Status_BMS_CN__c == 'Submitted' && strRecTypOld == 'Add Individual' ) {
                // Change record type
                dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Add Individual - Submitted'].Id;
                
                // Copy doctor info inputted by user to 3th party verification part
                dcrNew.Doctor_Name_Verified_BMS_CN__c = dcrNew.Doctor_Name_BMS_CN__c;
                dcrNew.Department_Verified_BMS_CN__c = dcrNew.Department_BMS_CN__c;
                dcrNew.Hospital_Verified_BMS_CN__c = dcrNew.Hospital_BMS_CN__c;
                dcrNew.Gender_Verified_BMS_CN__c = dcrNew.Gender_BMS_CN__c;
                dcrNew.Technical_Title_Verified_BMS_CN__c = dcrNew.Technical_Title_BMS_CN__c;
                dcrNew.Administrative_Title_Verified_BMS_CN__c = dcrNew.Administrative_Title_BMS_CN__c;
                dcrNew.Social_Title_Verified_BMS_CN__c = dcrNew.Social_Title_BMS_CN__c;
            }
            
            // Submitted -> Verified
            if(dcrNew.Status_BMS_CN__c == 'Verified' && strRecTypOld == 'Add Individual - Submitted' ) {
                // Change record type
                dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Add Individual - Verified'].Id;
                
                // Copy doctor info verified by 3th party to final verification part
                dcrNew.Doctor_Name_Final_BMS_CN__c = dcrNew.Doctor_Name_Verified_BMS_CN__c;
                dcrNew.Department_Final_BMS_CN__c = dcrNew.Department_Verified_BMS_CN__c;
                dcrNew.Hospital_Final_BMS_CN__c = dcrNew.Hospital_Verified_BMS_CN__c;
                dcrNew.Gender_Final_BMS_CN__c = dcrNew.Gender_Verified_BMS_CN__c;
                dcrNew.Technical_Title_Final_BMS_CN__c = dcrNew.Technical_Title_Verified_BMS_CN__c;
                dcrNew.Administrative_Title_Final_BMS_CN__c = dcrNew.Administrative_Title_Verified_BMS_CN__c;
                dcrNew.Social_Title_Final_BMS_CN__c = dcrNew.Social_Title_Verified_BMS_CN__c;
                
                if(dcrNew.Status_BMS_CN__c == 'Verified' && (dcrNew.Doctor_Code_BMS_CN__c == '' ||dcrNew.Doctor_Code_BMS_CN__c == null)) {
                    trigger.new[0].addError('Master Code is required');
                }
            }
            
            // Submitted -> Approved/Rejected
            if((dcrNew.Status_BMS_CN__c == 'Approved' || dcrNew.Status_BMS_CN__c == 'Rejected') && strRecTypOld == 'Add Individual - Submitted' ) {
                // Change record type
                dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Add Individual - Locked'].Id;
                
                // Status is Approved
                if(dcrNew.Status_BMS_CN__c == 'Approved') {
                    // Copy doctor info verified by 3th party to final verification part
                    dcrNew.Doctor_Name_Final_BMS_CN__c = dcrNew.Doctor_Name_Verified_BMS_CN__c;
                    dcrNew.Department_Final_BMS_CN__c = dcrNew.Department_Verified_BMS_CN__c;
                    dcrNew.Hospital_Final_BMS_CN__c = dcrNew.Hospital_Verified_BMS_CN__c;
                    dcrNew.Gender_Final_BMS_CN__c = dcrNew.Gender_Verified_BMS_CN__c;
                    dcrNew.Technical_Title_Final_BMS_CN__c = dcrNew.Technical_Title_Verified_BMS_CN__c;
                    dcrNew.Administrative_Title_Final_BMS_CN__c = dcrNew.Administrative_Title_Verified_BMS_CN__c;
                    dcrNew.Social_Title_Final_BMS_CN__c = dcrNew.Social_Title_Verified_BMS_CN__c; 
                    
                    if(dcrNew.Status_BMS_CN__c == 'Approved' && (dcrNew.Doctor_Code_BMS_CN__c == '' ||dcrNew.Doctor_Code_BMS_CN__c == null)) {
                        trigger.new[0].addError('Master Code is required');
                    } 
                }           
            }
            
            // Verified -> Approved/Rejected
            if((dcrNew.Status_BMS_CN__c == 'Approved' || dcrNew.Status_BMS_CN__c == 'Rejected') && strRecTypOld == 'Add Individual - Verified' ) {
                // Change record type
                dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Add Individual - Locked'].Id;             
            }
        }
        
        // Edit doctor info
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
            
            // Submitted -> Verified
            if(dcrNew.Status_BMS_CN__c == 'Verified' && strRecTypOld == 'Edit Individual - Submitted' ) {
                // Change record type
                dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Edit Individual - Verified'].Id;
                
                // Copy doctor info verified by 3th party to final verification part
                dcrNew.Department_Final_BMS_CN__c = dcrNew.Department_Verified_BMS_CN__c;
                dcrNew.Hospital_Final_BMS_CN__c = dcrNew.Hospital_Verified_BMS_CN__c;
                dcrNew.Gender_Final_BMS_CN__c = dcrNew.Gender_Verified_BMS_CN__c;
                dcrNew.Technical_Title_Final_BMS_CN__c = dcrNew.Gender_Verified_BMS_CN__c;
                dcrNew.Administrative_Title_Final_BMS_CN__c = dcrNew.Administrative_Title_Verified_BMS_CN__c;
                dcrNew.Social_Title_Final_BMS_CN__c = dcrNew.Administrative_Title_Verified_BMS_CN__c;               
            }
            
            // Submitted -> Approved/Rejected
            if((dcrNew.Status_BMS_CN__c == 'Approved' || dcrNew.Status_BMS_CN__c == 'Rejected') && strRecTypOld == 'Edit Individual - Submitted') {
                // Change record type
                dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Edit Individual - Locked'].Id;
                
                // Status is locked
                if(dcrNew.Status_BMS_CN__c == 'Approved') {
                    // Copy doctor info verified by 3th party to final verification part
                    dcrNew.Department_Final_BMS_CN__c = dcrNew.Department_Verified_BMS_CN__c;
                    dcrNew.Hospital_Final_BMS_CN__c = dcrNew.Hospital_Verified_BMS_CN__c;
                    dcrNew.Gender_Final_BMS_CN__c = dcrNew.Gender_Verified_BMS_CN__c;
                    dcrNew.Technical_Title_Final_BMS_CN__c = dcrNew.Gender_Verified_BMS_CN__c;
                    dcrNew.Administrative_Title_Final_BMS_CN__c = dcrNew.Administrative_Title_Verified_BMS_CN__c;
                    dcrNew.Social_Title_Final_BMS_CN__c = dcrNew.Administrative_Title_Verified_BMS_CN__c;   
                }
                
                // Verified -> Approved/Rejected
                if((dcrNew.Status_BMS_CN__c == 'Approved' || dcrNew.Status_BMS_CN__c == 'Rejected') && strRecTypOld == 'Edit Individual - Verified') {
                    // Change record type
                    dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Edit Individual - Locked'].Id;
                }
            }
        }
        
        // Delete doctor
        if(dcrNew.Action_Type_BMS_CN__c == 'DEL') {
            // Saved -> Submitted
            if(dcrNew.Status_BMS_CN__c == 'Submitted' && strRecTypOld == 'Del Individual' ) {
                // Change record type
                dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Del Individual - Submitted'].Id;
            }
            
            // Submitted -> Verified
            if(dcrNew.Status_BMS_CN__c == 'Verified' && strRecTypOld == 'Del Individual - Submitted' ) {
                // Change record type
                dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Del Individual - Verified'].Id;
            }
            
            // Submitted -> Approved/Rejected
            if((dcrNew.Status_BMS_CN__c == 'Approved' || dcrNew.Status_BMS_CN__c == 'Rejected') && strRecTypOld == 'Del Individual - Submitted' ) {
                // Change record type
                dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Del Individual - Locked'].Id;             
            }
            
            // Verified -> Approved/Rejected
            if((dcrNew.Status_BMS_CN__c == 'Approved' || dcrNew.Status_BMS_CN__c == 'Rejected') && strRecTypOld == 'Del Individual - Verified' ) {
                // Change record type
                dcrNew.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Data_Change_Request_BMS_CN__c' AND Name = 'Del Individual - Locked'].Id;             
            }            
            
        }
    }
}