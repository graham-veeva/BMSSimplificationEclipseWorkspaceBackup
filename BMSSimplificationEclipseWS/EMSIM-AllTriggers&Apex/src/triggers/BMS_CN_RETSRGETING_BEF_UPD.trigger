/* 
* Name: BMS_CN_RETSRGETING_BEF_UPD 
* Description: process before update record
* Author: Roy Zhang
* Created Date: 03/28/2013
* Last Modified Date: 07/09/2013
*/ 
trigger BMS_CN_RETSRGETING_BEF_UPD on Retargeting_BMS_CN__c (before update) {
    // Get all Record Type list
    Map<Id, String> recTypList = new Map<Id, String>();
    for(RecordType recTyp: [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Retargeting_BMS_CN__c']) {
        recTypList.put(recTyp.Id, recTyp.Name);
    }
    // Get all re-targeting hospital
    Map<Id,Retargeting_Hospital_BMS_CN__c> reTargetHosp = new Map<Id, Retargeting_Hospital_BMS_CN__c>();
    for(Retargeting_Hospital_BMS_CN__c hosp: [SELECT Id, Account_BMS_CN__c, Master_ID_BMS_CN__c FROM Retargeting_Hospital_BMS_CN__c WHERE Active_BMS_CN__c = true]) {
        reTargetHosp.put(hosp.Id, hosp);
    }
    
    // Get OTC Proudct Price
    List<OTC_Price_Matrix_BMS_CN__c> OTCPrcList = [SELECT
                                                        Id,
                                                        BC_BMS_CN__c,
                                                        BD_BMS_CN__c,
                                                        BL_BMS_CN__c,
                                                        BP_BMS_CN__c,
                                                        DN_BMS_CN__c,                                                       
                                                        TG100_BMS_CN__c,
                                                        TG30_BMS_CN__c,
                                                        TJC_BMS_CN__c,
                                                        VB_BMS_CN__c,
                                                        Spec_Code_BMS_CN__c,
                                                        Department_BMS_CN__c
                                                    FROM
                                                        OTC_Price_Matrix_BMS_CN__c];
    
    for(Retargeting_BMS_CN__c reTargetingNew : trigger.new) {
        
        bms_cn_setting__c cnSetting = bms_cn_setting__c.getInstance(UserInfo.getProfileId());
        if(cnSetting.Enable_Retargeting_BMS_CN__c <> true) {
            trigger.new[0].addError('请在目标调整期间进行目标医生调整');
        }
        
        String strRecordTypeOld = recTypList.get(reTargetingNew.recordTypeId);

        // Add new doctor
        if(reTargetingNew.Action_Type_BMS_CN__c == 'ADD') {
            // Saved
            if(reTargetingNew.Status_BMS_CN__c == 'Saved') {
                // Change hospital
                if(reTargetingNew.Retargeting_Hospital_BMS_CN__c <> reTargetingNew.Retargeting_Hospital_Original_BMS_CN__c) {
                    Retargeting_Hospital_BMS_CN__c tmpHosp = reTargetHosp.get(reTargetingNew.Retargeting_Hospital_BMS_CN__c);
                    reTargetingNew.Hospital_BMS_CN__c = tmpHosp.Account_BMS_CN__c;
                    reTargetingNew.Hospital_ID_BMS_CN__c = tmpHosp.Master_ID_BMS_CN__c;
                }
            }
            
            // Saved -> Submitted
            if(reTargetingNew.Status_BMS_CN__c == 'Submitted' && strRecordTypeOld == 'Add Retargeting') {
                if(reTargetingNew.Active_BMS_CN__c == false) {
                    trigger.new[0].addError('请在目标调整期间进行目标医生调整');
                }
                
                // Change hospital
                if(reTargetingNew.Retargeting_Hospital_BMS_CN__c <> reTargetingNew.Retargeting_Hospital_Original_BMS_CN__c) {
                    Retargeting_Hospital_BMS_CN__c tmpHosp = reTargetHosp.get(reTargetingNew.Retargeting_Hospital_BMS_CN__c);
                    reTargetingNew.Hospital_BMS_CN__c = tmpHosp.Account_BMS_CN__c;
                    reTargetingNew.Hospital_ID_BMS_CN__c = tmpHosp.Master_ID_BMS_CN__c;
                }
                
                // Change Record Type
                for(Id newRecTypId: recTypList.keySet()) {
                    if(recTypList.get(newRecTypId) == 'Add Retargeting - Submitted') {
                        reTargetingNew.RecordTypeId = newRecTypId;
                    }
                }
                
                // Copy doctor info inputted by user to 3th party verification part
                reTargetingNew.Administrative_Title_Verified_BMS_CN__c = reTargetingNew.Administrative_Title_BMS_CN__c;
                reTargetingNew.Department_Verified_BMS_CN__c = reTargetingNew.Department_BMS_CN__c;
                reTargetingNew.Doctor_Name_Verified_BMS_CN__c = reTargetingNew.Doctor_Name_BMS_CN__c;
                reTargetingNew.Gender_Verified_BMS_CN__c = reTargetingNew.Gender_BMS_CN__c;
                reTargetingNew.Hospital_Verified_BMS_CN__c = reTargetingNew.Hospital_BMS_CN__c;
                reTargetingNew.Hospital_ID_Verified_BMS_CN__c = reTargetingNew.Hospital_ID_BMS_CN__c;
                reTargetingNew.Technical_Title_Verified_BMS_CN__c = reTargetingNew.Technical_Title_BMS_CN__c;       
                
                if(reTargetingNew.BU_BMS_CN__c == 'CV') {
                    if(reTargetingNew.CV_Product_BMS_CN__c == 'Monopril') {
                        reTargetingNew.Beds_Eliquis_BMS_CN__c = 0;
                        reTargetingNew.Monthly_Operations_BMS_CN__c = 0;
                    }else if(reTargetingNew.CV_Product_BMS_CN__c == 'Eliquis') {
                        reTargetingNew.Beds_BMS_CN__c = 0;
                        reTargetingNew.Weekly_Out_patients_BMS_CN__c = 0;
                        reTargetingNew.Decision_Power_BMS_CN__c = 0;
                    }
                }                       
            }
            
            // Submitted -> Verified
            if(reTargetingNew.Status_BMS_CN__c == 'Verified' && strRecordTypeOld == 'Add Retargeting - Submitted') {
                // Change Hospital ID
                if(reTargetingNew.Hospital_Verified_BMS_CN__c <> reTargetingNew.Hospital_BMS_CN__c) {
                    reTargetingNew.Hospital_ID_Verified_BMS_CN__c = [SELECT Id,BP_ID_BMS_CORE__c FROM Account WHERE Id =: reTargetingNew.Hospital_Verified_BMS_CN__c].BP_ID_BMS_CORE__c;
                }           
                
                // Change Record Type
                for(Id newRecTypId: recTypList.keySet()) {
                    if(recTypList.get(newRecTypId) == 'Add Retargeting - Verified') {
                        reTargetingNew.RecordTypeId = newRecTypId;
                    }
                }
                
                // Copy doctor info verified by 3th party to final verification part
                reTargetingNew.Administrative_Title_Final_BMS_CN__c = reTargetingNew.Administrative_Title_Verified_BMS_CN__c;
                reTargetingNew.Department_Final_BMS_CN__c = reTargetingNew.Department_Verified_BMS_CN__c;
                reTargetingNew.Doctor_Name_Final_BMS_CN__c = reTargetingNew.Doctor_Name_Verified_BMS_CN__c;
                reTargetingNew.Gender_Final_BMS_CN__c = reTargetingNew.Gender_Verified_BMS_CN__c;
                reTargetingNew.Hospital_Final_BMS_CN__c = reTargetingNew.Hospital_Verified_BMS_CN__c;
                reTargetingNew.Hospital_ID_Final_BMS_CN__c = reTargetingNew.Hospital_ID_Verified_BMS_CN__c;
                reTargetingNew.Technical_Title_Final_BMS_CN__c = reTargetingNew.Technical_Title_Verified_BMS_CN__c;
            }
            
            // Submitted -> Approved/Rejected           
            if((reTargetingNew.Status_BMS_CN__c == 'Approved' || reTargetingNew.Status_BMS_CN__c == 'Rejected') && strRecordTypeOld == 'Add Retargeting - Submitted') {
                // Change Hospital ID
                if(reTargetingNew.Hospital_Verified_BMS_CN__c <> reTargetingNew.Hospital_BMS_CN__c) {
                    reTargetingNew.Hospital_ID_Verified_BMS_CN__c = [SELECT Id,BP_ID_BMS_CORE__c FROM Account WHERE Id =: reTargetingNew.Hospital_Verified_BMS_CN__c].BP_ID_BMS_CORE__c;
                }           
                
                // Change Record Type
                for(Id newRecTypId: recTypList.keySet()) {
                    if(recTypList.get(newRecTypId) == 'Add Retargeting - Locked') {
                        reTargetingNew.RecordTypeId = newRecTypId;
                    }
                }
                
                // Copy doctor info verified by 3th party to final verification part
                if(reTargetingNew.Status_BMS_CN__c == 'Approved') {
                    reTargetingNew.Administrative_Title_Final_BMS_CN__c = reTargetingNew.Administrative_Title_Verified_BMS_CN__c;
                    reTargetingNew.Department_Final_BMS_CN__c = reTargetingNew.Department_Verified_BMS_CN__c;
                    reTargetingNew.Doctor_Name_Final_BMS_CN__c = reTargetingNew.Doctor_Name_Verified_BMS_CN__c;
                    reTargetingNew.Gender_Final_BMS_CN__c = reTargetingNew.Gender_Verified_BMS_CN__c;
                    reTargetingNew.Hospital_Final_BMS_CN__c = reTargetingNew.Hospital_Verified_BMS_CN__c;
                    reTargetingNew.Hospital_ID_Final_BMS_CN__c = reTargetingNew.Hospital_ID_Verified_BMS_CN__c;
                    reTargetingNew.Technical_Title_Final_BMS_CN__c = reTargetingNew.Technical_Title_Verified_BMS_CN__c;
                    
                    //Check master code
                    if(reTargetingNew.Doctor_Code_BMS_CN__c == '' || reTargetingNew.Doctor_Code_BMS_CN__c == null) {
                        trigger.new[0].adderror('Master code was not assigned');
                    }                   
                }
                
                // Calculate OTC Monthly Perscription Amount
                if(reTargetingNew.BU_BMS_CN__c == 'OTC' && reTargetingNew.Status_BMS_CN__c == 'Approved') {
                    reTargetingNew.Monthly_Perscription_Amount_BMS_CN__c = 0;
                    for(OTC_Price_Matrix_BMS_CN__c prc : OTCPrcList) {
                        if(prc.Spec_Code_BMS_CN__c == reTargetingNew.Department_Final_BMS_CN__c) {
                            reTargetingNew.Monthly_Perscription_Amount_BMS_CN__c = reTargetingNew.TG30_BMS_CN__c * prc.TG30_BMS_CN__c +
                                                                                    reTargetingNew.TG100_BMS_CN__c * prc.TG100_BMS_CN__c +
                                                                                    reTargetingNew.TJC_BMS_CN__c * prc.TJC_BMS_CN__c +
                                                                                    reTargetingNew.VB_BMS_CN__c * prc.VB_BMS_CN__c +
                                                                                    reTargetingNew.DN_BMS_CN__c * prc.DN_BMS_CN__c +
                                                                                    reTargetingNew.BP_BMS_CN__c * prc.BP_BMS_CN__c +
                                                                                    reTargetingNew.BC_BMS_CN__c * prc.BC_BMS_CN__c +
                                                                                    reTargetingNew.BL_BMS_CN__c * prc.BL_BMS_CN__c +
                                                                                    reTargetingNew.BD_BMS_CN__c * prc.BD_BMS_CN__c;
                        }                       
                    }
                }
            }
            
            // Verified -> Approved/Rejected
            if((reTargetingNew.Status_BMS_CN__c == 'Approved' || reTargetingNew.Status_BMS_CN__c == 'Rejected') && strRecordTypeOld == 'Add Retargeting - Verified') {
                // Change Hospital ID
                if(reTargetingNew.Hospital_Final_BMS_CN__c <> reTargetingNew.Hospital_Verified_BMS_CN__c) {
                    reTargetingNew.Hospital_ID_Final_BMS_CN__c = [SELECT Id,BP_ID_BMS_CORE__c FROM Account WHERE Id =: reTargetingNew.Hospital_Verified_BMS_CN__c].BP_ID_BMS_CORE__c;
                }   
                
                // Change Record Type
                for(Id newRecTypId: recTypList.keySet()) {
                    if(recTypList.get(newRecTypId) == 'Add Retargeting - Locked') {
                        reTargetingNew.RecordTypeId = newRecTypId;
                    }
                }
                
                //Check master code
                if(reTargetingNew.Status_BMS_CN__c == 'Approved' && (reTargetingNew.Doctor_Code_BMS_CN__c == '' || reTargetingNew.Doctor_Code_BMS_CN__c == null)) {
                    trigger.new[0].adderror('Master code was not assigned');
                }               
                
                // Calculate OTC Monthly Perscription Amount
                if(reTargetingNew.BU_BMS_CN__c == 'OTC' && reTargetingNew.Status_BMS_CN__c == 'Approved') {
                    reTargetingNew.Monthly_Perscription_Amount_BMS_CN__c = 0;
                    for(OTC_Price_Matrix_BMS_CN__c prc : OTCPrcList) {
                        if(prc.Spec_Code_BMS_CN__c == reTargetingNew.Department_Final_BMS_CN__c) {
                            reTargetingNew.Monthly_Perscription_Amount_BMS_CN__c = reTargetingNew.TG30_BMS_CN__c * prc.TG30_BMS_CN__c +
                                                                                    reTargetingNew.TG100_BMS_CN__c * prc.TG100_BMS_CN__c +
                                                                                    reTargetingNew.TJC_BMS_CN__c * prc.TJC_BMS_CN__c +
                                                                                    reTargetingNew.VB_BMS_CN__c * prc.VB_BMS_CN__c +
                                                                                    reTargetingNew.DN_BMS_CN__c * prc.DN_BMS_CN__c +
                                                                                    reTargetingNew.BP_BMS_CN__c * prc.BP_BMS_CN__c +
                                                                                    reTargetingNew.BC_BMS_CN__c * prc.BC_BMS_CN__c +
                                                                                    reTargetingNew.BL_BMS_CN__c * prc.BL_BMS_CN__c +
                                                                                    reTargetingNew.BD_BMS_CN__c * prc.BD_BMS_CN__c;
                        }                       
                    }
                }
            }
        }
        
        // Edit a doctor
        if(reTargetingNew.Action_Type_BMS_CN__c == 'EDIT') {
            //Saved
            if(reTargetingNew.Status_BMS_CN__c == 'Saved') {
                // Change hospital
                if(reTargetingNew.Retargeting_Hospital_BMS_CN__c <> reTargetingNew.Retargeting_Hospital_Original_BMS_CN__c) {
                    Retargeting_Hospital_BMS_CN__c tmpHosp = reTargetHosp.get(reTargetingNew.Retargeting_Hospital_BMS_CN__c);
                    reTargetingNew.Hospital_BMS_CN__c = tmpHosp.Account_BMS_CN__c;
                    reTargetingNew.Hospital_ID_BMS_CN__c = tmpHosp.Master_ID_BMS_CN__c;
                }
            }
            
            // Saved -> Submitted
            if(reTargetingNew.Status_BMS_CN__c == 'Submitted' && strRecordTypeOld == 'Edit Retargeting') {
                if(reTargetingNew.Active_BMS_CN__c == false) {
                    trigger.new[0].addError('请在目标调整期间进行目标医生调整');
                }
                
                // Change hospital
                if(reTargetingNew.Retargeting_Hospital_BMS_CN__c <> reTargetingNew.Retargeting_Hospital_Original_BMS_CN__c) {
                    Retargeting_Hospital_BMS_CN__c tmpHosp = reTargetHosp.get(reTargetingNew.Retargeting_Hospital_BMS_CN__c);
                    reTargetingNew.Hospital_BMS_CN__c = tmpHosp.Account_BMS_CN__c;
                    reTargetingNew.Hospital_ID_BMS_CN__c = tmpHosp.Master_ID_BMS_CN__c;
                }
                
                // Change Record Type
                for(Id newRecTypId: recTypList.keySet()) {
                    if(recTypList.get(newRecTypId) == 'Edit Retargeting - Submitted') {
                        reTargetingNew.RecordTypeId = newRecTypId;
                    }
                }
                
                // Copy doctor info inputted by user to 3th party verification part
                reTargetingNew.Administrative_Title_Verified_BMS_CN__c = reTargetingNew.Administrative_Title_BMS_CN__c;
                reTargetingNew.Department_Verified_BMS_CN__c = reTargetingNew.Department_BMS_CN__c;
                reTargetingNew.Gender_Verified_BMS_CN__c = reTargetingNew.Gender_BMS_CN__c;
                reTargetingNew.Hospital_Verified_BMS_CN__c = reTargetingNew.Hospital_BMS_CN__c;
                reTargetingNew.Hospital_ID_Verified_BMS_CN__c = reTargetingNew.Hospital_ID_BMS_CN__c;
                reTargetingNew.Technical_Title_Verified_BMS_CN__c = reTargetingNew.Technical_Title_BMS_CN__c;       
                
                // Set InVentiv check flag
                if(reTargetingNew.Administrative_Title_BMS_CN__c <> reTargetingNew.Administrative_Title_Original_BMS_CN__c ||
                   reTargetingNew.Department_BMS_CN__c <> reTargetingNew.Department_Original_BMS_CN__c ||
                   reTargetingNew.Hospital_BMS_CN__c <> reTargetingNew.Hospital_Original_BMS_CN__c ||
                   reTargetingNew.Technical_Title_BMS_CN__c <> reTargetingNew.Technical_Title_Original_BMS_CN__c ||
                   reTargetingNew.Gender_BMS_CN__c <> reTargetingNew.Gender_Original_BMS_CN__c) {
                    reTargetingNew.Inventiv_Check_BMS_CN__c = true;
                }
                
                // Check InVentiv verification or not
                if(reTargetingNew.Inventiv_Check_BMS_CN__c == false) {
                    // Change Record Type
                    for(Id newRecTypId: recTypList.keySet()) {
                        if(recTypList.get(newRecTypId) == 'Edit Retargeting - Locked') {
                            reTargetingNew.RecordTypeId = newRecTypId;
                        }
                    }
                    
                    reTargetingNew.Status_BMS_CN__c = 'Approved';
                    
                    // Copy doctor info verified by 3th party to final verification part
                    reTargetingNew.Administrative_Title_Final_BMS_CN__c = reTargetingNew.Administrative_Title_Verified_BMS_CN__c;
                    reTargetingNew.Department_Final_BMS_CN__c = reTargetingNew.Department_Verified_BMS_CN__c;
                    reTargetingNew.Gender_Final_BMS_CN__c = reTargetingNew.Gender_Verified_BMS_CN__c;
                    reTargetingNew.Hospital_Final_BMS_CN__c = reTargetingNew.Hospital_Verified_BMS_CN__c;
                    reTargetingNew.Hospital_ID_Final_BMS_CN__c = reTargetingNew.Hospital_ID_Verified_BMS_CN__c;
                    reTargetingNew.Technical_Title_Final_BMS_CN__c = reTargetingNew.Technical_Title_Verified_BMS_CN__c;
                }
                
                if(reTargetingNew.BU_BMS_CN__c == 'CV') {
                    if(reTargetingNew.CV_Product_BMS_CN__c == 'Monopril') {
                        reTargetingNew.Beds_Eliquis_BMS_CN__c = 0;
                        reTargetingNew.Monthly_Operations_BMS_CN__c = 0;
                    }else if(reTargetingNew.CV_Product_BMS_CN__c == 'Eliquis') {
                        reTargetingNew.Beds_BMS_CN__c = 0;
                        reTargetingNew.Weekly_Out_patients_BMS_CN__c = 0;
                        reTargetingNew.Decision_Power_BMS_CN__c = 0;
                    }
                }   
            }
            
            // Submitted -> Verified
            if(reTargetingNew.Status_BMS_CN__c == 'Verified' && strRecordTypeOld == 'Edit Retargeting - Submitted') {
                // Change Hospital ID
                if(reTargetingNew.Hospital_Verified_BMS_CN__c <> reTargetingNew.Hospital_BMS_CN__c) {
                    reTargetingNew.Hospital_ID_Verified_BMS_CN__c = [SELECT Id,BP_ID_BMS_CORE__c FROM Account WHERE Id =: reTargetingNew.Hospital_Verified_BMS_CN__c].BP_ID_BMS_CORE__c;
                }
                
                // Change Record Type
                for(Id newRecTypId: recTypList.keySet()) {
                    if(recTypList.get(newRecTypId) == 'Edit Retargeting - Verified') {
                        reTargetingNew.RecordTypeId = newRecTypId;
                    }
                }
                
                // Copy doctor info verified by 3th party to final verification part
                reTargetingNew.Administrative_Title_Final_BMS_CN__c = reTargetingNew.Administrative_Title_Verified_BMS_CN__c;
                reTargetingNew.Department_Final_BMS_CN__c = reTargetingNew.Department_Verified_BMS_CN__c;
                reTargetingNew.Gender_Final_BMS_CN__c = reTargetingNew.Gender_Verified_BMS_CN__c;
                reTargetingNew.Hospital_Final_BMS_CN__c = reTargetingNew.Hospital_Verified_BMS_CN__c;
                reTargetingNew.Hospital_ID_Final_BMS_CN__c = reTargetingNew.Hospital_ID_Verified_BMS_CN__c;
                reTargetingNew.Technical_Title_Final_BMS_CN__c = reTargetingNew.Technical_Title_Verified_BMS_CN__c;             
            }
            
            // Submitted -> Approved/Rejected
            if((reTargetingNew.Status_BMS_CN__c == 'Approved' || reTargetingNew.Status_BMS_CN__c == 'Rejected') && strRecordTypeOld == 'Edit Retargeting - Submitted') {
                // Change Hospital ID
                if(reTargetingNew.Hospital_Verified_BMS_CN__c <> reTargetingNew.Hospital_BMS_CN__c) {
                    reTargetingNew.Hospital_ID_Verified_BMS_CN__c = [SELECT Id,BP_ID_BMS_CORE__c FROM Account WHERE Id =: reTargetingNew.Hospital_Verified_BMS_CN__c].BP_ID_BMS_CORE__c;
                }
                
                // Change Record Type
                for(Id newRecTypId: recTypList.keySet()) {
                    if(recTypList.get(newRecTypId) == 'Edit Retargeting - Locked') {
                        reTargetingNew.RecordTypeId = newRecTypId;
                    }
                }
                
                // Copy doctor info verified by 3th party to final verification part
                if(reTargetingNew.Status_BMS_CN__c == 'Approved') {
                    reTargetingNew.Administrative_Title_Final_BMS_CN__c = reTargetingNew.Administrative_Title_Verified_BMS_CN__c;
                    reTargetingNew.Department_Final_BMS_CN__c = reTargetingNew.Department_Verified_BMS_CN__c;
                    reTargetingNew.Gender_Final_BMS_CN__c = reTargetingNew.Gender_Verified_BMS_CN__c;
                    reTargetingNew.Hospital_Final_BMS_CN__c = reTargetingNew.Hospital_Verified_BMS_CN__c;
                    reTargetingNew.Hospital_ID_Final_BMS_CN__c = reTargetingNew.Hospital_ID_Verified_BMS_CN__c;
                    reTargetingNew.Technical_Title_Final_BMS_CN__c = reTargetingNew.Technical_Title_Verified_BMS_CN__c;
                }
                
                // Calculate OTC Monthly Perscription Amount
                if(reTargetingNew.BU_BMS_CN__c == 'OTC' && reTargetingNew.Status_BMS_CN__c == 'Approved') {
                    reTargetingNew.Monthly_Perscription_Amount_BMS_CN__c = 0;
                    for(OTC_Price_Matrix_BMS_CN__c prc : OTCPrcList) {
                        if(prc.Spec_Code_BMS_CN__c == reTargetingNew.Department_Final_BMS_CN__c) {
                            reTargetingNew.Monthly_Perscription_Amount_BMS_CN__c = reTargetingNew.TG30_BMS_CN__c * prc.TG30_BMS_CN__c +
                                                                                reTargetingNew.TG100_BMS_CN__c * prc.TG100_BMS_CN__c +
                                                                                reTargetingNew.TJC_BMS_CN__c * prc.TJC_BMS_CN__c +
                                                                                reTargetingNew.VB_BMS_CN__c * prc.VB_BMS_CN__c +
                                                                                reTargetingNew.DN_BMS_CN__c * prc.DN_BMS_CN__c +
                                                                                reTargetingNew.BP_BMS_CN__c * prc.BP_BMS_CN__c +
                                                                                reTargetingNew.BC_BMS_CN__c * prc.BC_BMS_CN__c +
                                                                                reTargetingNew.BL_BMS_CN__c * prc.BL_BMS_CN__c +
                                                                                reTargetingNew.BD_BMS_CN__c * prc.BD_BMS_CN__c;
                        }
                    }                       
                }
            }
            
            // Verified -> Approved/Rejected
            if((reTargetingNew.Status_BMS_CN__c == 'Approved' || reTargetingNew.Status_BMS_CN__c == 'Rejected') && strRecordTypeOld == 'Edit Retargeting - Verified') {
                // Change Hospital ID
                if(reTargetingNew.Hospital_Final_BMS_CN__c <> reTargetingNew.Hospital_Verified_BMS_CN__c) {
                    reTargetingNew.Hospital_ID_Final_BMS_CN__c = [SELECT Id,BP_ID_BMS_CORE__c FROM Account WHERE Id =: reTargetingNew.Hospital_Verified_BMS_CN__c].BP_ID_BMS_CORE__c;
                }
                
                // Change Record Type
                for(Id newRecTypId: recTypList.keySet()) {
                    if(recTypList.get(newRecTypId) == 'Edit Retargeting - Locked') {
                        reTargetingNew.RecordTypeId = newRecTypId;
                    }
                }
                // Calculate OTC Monthly Perscription Amount
                if(reTargetingNew.BU_BMS_CN__c == 'OTC' && reTargetingNew.Status_BMS_CN__c == 'Approved') {
                    reTargetingNew.Monthly_Perscription_Amount_BMS_CN__c = 0;
                    for(OTC_Price_Matrix_BMS_CN__c prc : OTCPrcList) {
                        if(prc.Spec_Code_BMS_CN__c == reTargetingNew.Department_Final_BMS_CN__c) {
                            reTargetingNew.Monthly_Perscription_Amount_BMS_CN__c = reTargetingNew.TG30_BMS_CN__c * prc.TG30_BMS_CN__c +
                                                                                reTargetingNew.TG100_BMS_CN__c * prc.TG100_BMS_CN__c +
                                                                                reTargetingNew.TJC_BMS_CN__c * prc.TJC_BMS_CN__c +
                                                                                reTargetingNew.VB_BMS_CN__c * prc.VB_BMS_CN__c +
                                                                                reTargetingNew.DN_BMS_CN__c * prc.DN_BMS_CN__c +
                                                                                reTargetingNew.BP_BMS_CN__c * prc.BP_BMS_CN__c +
                                                                                reTargetingNew.BC_BMS_CN__c * prc.BC_BMS_CN__c +
                                                                                reTargetingNew.BL_BMS_CN__c * prc.BL_BMS_CN__c +
                                                                                reTargetingNew.BD_BMS_CN__c * prc.BD_BMS_CN__c;
                        }
                    }                       
                }
            }
        }       
    }
}