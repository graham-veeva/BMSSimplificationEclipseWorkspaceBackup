/*
* Name: BMS_CN_Retargeting_CreateDoctorBatch
* Description: Insert account for new doctor of Retargeting EOM batch 
* Author: Roy Zhang
* Created Date: 04/01/2013
* Last Modified Date: 07/10/2013
*/
global class BMS_CN_Retargeting_CreateDoctorBatch implements Database.Batchable<sObject>{
	global String strQuery;
	global Id actRecTypeId;
	global Id addRecTypeId;
	global Map<String, String> mapState;
	global List<Product_vod__c> prdlist;
	global Map<String, String> commSpecMap;
	global Map<String, String> perDoseMap;
	global Map<String, String> TaxolConvRatioMap;
	global Map<String, String> PrapConvRatioMap;
	global Map<String,String> depMap;
	
	global BMS_CN_Retargeting_CreateDoctorBatch() {
		actRecTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'BMS - Individual'].Id;		
		addRecTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Address_vod__c' AND Name = 'BMS Address'].Id;
		
		commSpecMap = new Map<String, String>();
		perDoseMap = new Map<String, String>();
		TaxolConvRatioMap = new Map<String, String>();
		PrapConvRatioMap = new Map<String, String>();
		depMap = new Map<String,String>();
		
		List<Master_Parameter_BMS_CN__c> paraList = [SELECT
														Type1_BMS_CN__c,
														Type2_BMS_CN__c,
														Parameter_BMS_CN__c,
														Value_BMS_CN__c
													FROM
														Master_Parameter_BMS_CN__c
													WHERE
														Country_Code_BMS_CN__c = 'CN' AND
														Module_BMS_CN__c = 'Retargeting' AND
														Type1_BMS_CN__c = 'ONCO-TAXOL'];

		for(Master_Parameter_BMS_CN__c para : paraList) {
			if(para.Type2_BMS_CN__c == 'Common Specifications') {
				commSpecMap.put(para.Parameter_BMS_CN__c, para.Value_BMS_CN__c);
			}else if(para.Type2_BMS_CN__c == 'Periodic Dose') {
				perDoseMap.put(para.Parameter_BMS_CN__c, para.Value_BMS_CN__c);
			}else if(para.Type2_BMS_CN__c == 'Taxol Convertible Ratio') {
				TaxolConvRatioMap.put(para.Parameter_BMS_CN__c, para.Value_BMS_CN__c);
			}else if(para.Type2_BMS_CN__c == 'Paraplatin Convertible Ratio') {
				PrapConvRatioMap.put(para.Parameter_BMS_CN__c, para.Value_BMS_CN__c);
			}
		}
		List<Master_Parameter_BMS_CN__c> depList = [SELECT
														Type1_BMS_CN__c,
														Type2_BMS_CN__c,
														Parameter_BMS_CN__c,
														Value_BMS_CN__c
													FROM
														Master_Parameter_BMS_CN__c
													WHERE
														Country_Code_BMS_CN__c = 'CN' AND
														Module_BMS_CN__c = 'Department' AND
														Type1_BMS_CN__c = 'zh-CN'];
		for(Master_Parameter_BMS_CN__c dep: depList) {
			depMap.put(dep.Parameter_BMS_CN__c, dep.Value_BMS_CN__c);
		}
		
		prdlist = [SELECT
						Id,
						Name
					FROM
						Product_vod__c
					WHERE  
						BU_BMS_CN__c IN ('CV','HP','DB','ONCO-SPRYCEL','ONCO-TAXOL','OTC') AND
						Company_Product_vod__c = true AND
						Product_Type_vod__c = 'Detail'];

		strQuery = 'SELECT'
                    + '     Id,'
                    + '     Doctor_BMS_CN__c,'
                    + '     Action_Type_BMS_CN__c,'
                    + '     BU_BMS_CN__c,'
                    + '     Doctor_Name_Final_BMS_CN__c,'
                    + '     Doctor_Code_BMS_CN__c,' 
                    + '     Department_Final_BMS_CN__c,'
                    + '     Hospital_Final_BMS_CN__c,'             
                    + '     Gender_Final_BMS_CN__c,'
                    + '     Administrative_Title_Final_BMS_CN__c,'
                    + '     Technical_Title_Final_BMS_CN__c,'
                    + '     Territory_BMS_CN__c,'
                    + '     Decision_of_Beds_Index_BMS_CN__c,'
                    + '     Weekly_Out_patients_BMS_CN__c,'
                    + '     Weekly_HBV_Out_patients_BMS_CN__c,'
                    + '     HBV_Beds_BMS_CN__c,'
                    + '     M3_Avg_ETV_ARV_BMS_CN__c,'
                    + '     M3_Avg_HP_ETV_BMS_CN__c,'
                    + '     M3_Avg_Lamivudine_ARV_BMS_CN__c,'
                    + '     Monthly_Brand_Prescription_BMS_CN__c,'
                    + '     Is_GIPAP_TIPAP_BMS_CN__c,'
                    + '     CML_Patients_BMS_CN__c,'
                    + '     NIDDM_Patients_BMS_CN__c,'
                    + '     Monthly_Perscription_Amount_BMS_CN__c,'
                    + '     Monthly_Out_patients_BMS_CN__c,'
                    + '     CV_Product_BMS_CN__c,'
                    + '     Beds_Eliquis_BMS_CN__c,' 
                    + '     Monthly_Operations_BMS_CN__c,'
                    + '     Is_L_KEY_BMS_CN__c,'                    
                    + '     Is_KOL_BMS_CN__c,'
                    + '     Onco_Taxol_Product_BMS_CN__c,'
                    + '     Decision_Making_BMS_CN__c,'
					+ '     Monthly_Taxol_Prescription_BMS_CN__c,'
                    + '     Monthly_Paclitaxel_BMS_CN__c,'
					+ '     Monthly_Liposome_BMS_CN__c,'
					+ '     Monthly_Anzatax_BMS_CN__c,'
					+ '     Monthly_Homemade_Paclitaxel_BMS_CN__c,'
					+ '     Monthly_Taxotere_BMS_CN__c,'
					+ '     Monthly_Homemade_Docetaxel_BMS_CN__c,'
					+ '     Monthly_Paraplatin_BMS_CN__c,'
					+ '     Monthly_Carboplatin_Imitation_BMS_CN__c,'
					+ '     Monthly_Cisplatin_BMS_CN__c,'
					+ '     Monthly_Nedaplatin_BMS_CN__c'
                    + ' FROM'   
                    + '     Retargeting_BMS_CN__c'
                    + ' WHERE'
                    + '     Status_BMS_CN__c = \'Approved\' AND'
                    + '     (Action_Type_BMS_CN__c = \'ADD\' OR Action_Type_BMS_CN__c = \'EDIT\') AND'
                    + '     Active_BMS_CN__c = true AND'
                    + '     Inventiv_Check_BMS_CN__c = true'
                    + ' ORDER BY Name DESC';            
	}
	global Database.Querylocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(strQuery);
	}
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		
		mapState = New Map<String,String>();
		mapState.put('SHH','上海');
		mapState.put('BEJ','北京');
		mapState.put('HEB','河北');
		mapState.put('TAJ','天津');
		mapState.put('SHX','山西');
		mapState.put('NMG','内蒙古');
		mapState.put('LIA','辽宁');
		mapState.put('SHD','山东');
		mapState.put('JIL','吉林');
		mapState.put('HLJ','黑龙江');
		mapState.put('JSU','江苏');
		mapState.put('ZHJ','浙江');
		mapState.put('ANH','安徽');
		mapState.put('HEN','河南');
		mapState.put('JXI','江西');
		mapState.put('HAI','海南');
		mapState.put('GUD','广东');
		mapState.put('GXI','广西');
		mapState.put('FUJ','福建');
		mapState.put('GUI','贵州');
		mapState.put('HUN','湖南');
		mapState.put('HUB','湖北');
		mapState.put('XIN','新疆');
		mapState.put('GAN','甘肃');
		mapState.put('SHA','陕西');
		mapState.put('YUN','云南');
		mapState.put('NXA','宁夏');
		mapState.put('QIH','青海');
		mapState.put('TIB','西藏');
		mapState.put('SCH','四川');
		mapState.put('CHQ','重庆');		
		
		List<Retargeting_BMS_CN__c> retargetList= scope;
		// Account Id list
		Set<Id> hospIdSet = new Set<Id>();
		Set<Id> docIdSet = new Set<Id>();
		// Account list of new doctor				
		List<Account> newDoctorList = new List<Account>();
		List<Address_vod__c> newAddressList = new List<Address_vod__c>();

		for(Retargeting_BMS_CN__c target: retargetList) {
			if(!hospIdSet.contains(target.Hospital_Final_BMS_CN__c)) {
				hospIdSet.add(target.Hospital_Final_BMS_CN__c);
			}
			if(target.Action_Type_BMS_CN__c == 'EDIT' && !(docIdSet.contains(target.Doctor_BMS_CN__c))) {
				docIdSet.add(target.Doctor_BMS_CN__c);
			}
		}
		
		// Target hospital address list
		List<Address_vod__c> hospAddList = [SELECT
            									Id,
            									Name,
            									Account_vod__c,
            									Account_vod__r.Name,
            									City_vod__c,
            									State_vod__c,
            									Zip_vod__c
            								FROM
            									Address_vod__c
            								WHERE
            									Account_vod__r.Id IN : hospIdSet AND
            									Primary_vod__c = true];
        List<Address_vod__c> editDocAddList = [SELECT
            									Id,
            									Name,
            									Account_vod__c,
            									Account_vod__r.lastname,
            									City_vod__c,
            									State_vod__c,
            									Zip_vod__c
            								FROM
            									Address_vod__c
            								WHERE
            									Account_vod__r.Id IN : docIdSet AND
            									Primary_vod__c = true];
            									
		List<Account> editDoctorList = [SELECT
											Id,
											Department_BMS_CN__c,
											Gender_vod__c,
											Administrative_Title_BMS_CN__c,
											Technical_Title_BMS_CN__c,
											Primary_Parent_vod__c,
											Address_BMS_CN__c
										FROM
											Account
										WHERE
											Id IN : docIdSet];

		// Map of target doctor									
		Map<Id,Account> editDoctorMap = new Map<Id, Account>();
		for(Account act : editDoctorList) {
			editDoctorMap.put(act.Id, act);
		}
		// Map of doctor address
		Map<Id, Address_vod__c> editDocAddMap = new Map<Id, Address_vod__c>();
		for(Address_vod__c add : editDocAddList) {
			editDocAddMap.put(add.Account_vod__c, add);
		}
					
		List<Patient_Tracker_BMS_CN__c> newPTList = new List<Patient_Tracker_BMS_CN__c>();
		List<Product_Metrics_vod__c> pmList = new List<Product_Metrics_vod__c>();
		
		// Loop new doctor
		for(Retargeting_BMS_CN__c target: retargetList) {
			// Add new doctor
			if(target.Action_Type_BMS_CN__c == 'ADD') {
				Account act = new Account();
				
				// Basic Info				
				act.RecordTypeId = actRecTypeId;
				act.Account_Type__c = 'NRPS';
				act.Account_Source_Country_BMS_CORE__c = 'CN';
				act.LastName = target.Doctor_Name_Final_BMS_CN__c;
				act.BP_ID_BMS_CORE__c = target.Doctor_Code_BMS_CN__c;
				act.Department_BMS_CN__c = target.Department_Final_BMS_CN__c;
				act.Primary_Parent_vod__c = target.Hospital_Final_BMS_CN__c;
				act.Gender_vod__c = target.Gender_Final_BMS_CN__c;
				act.Administrative_Title_BMS_CN__c = target.Administrative_Title_Final_BMS_CN__c;
				act.Technical_Title_BMS_CN__c = target.Technical_Title_Final_BMS_CN__c;
				act.Address_BMS_CN__c = getHospitalAddress(target.Hospital_Final_BMS_CN__c, hospAddList);
				
				// Perscription Info
				if(target.BU_BMS_CN__c == 'CV') {
					// CV
					if(target.CV_Product_BMS_CN__c == 'Monopril') {
						act.Decision_of_Beds_Index_BMS_CN__c = target.Decision_of_Beds_Index_BMS_CN__c;
						act.Weekly_Out_Patients_BMS_CN__c = target.Weekly_Out_patients_BMS_CN__c;
					}else if(target.CV_Product_BMS_CN__c == 'Eliquis') {
						act.Beds_BMS_CN__c = target.Beds_Eliquis_BMS_CN__c;
						act.Monthly_Operations_BMS_CN__c = target.Monthly_Operations_BMS_CN__c;
					}
				}
				if(target.BU_BMS_CN__c == 'HP') {
					// HP
					act.Weekly_HBV_Out_patients_BMS_CN__c = target.Weekly_HBV_Out_patients_BMS_CN__c;
					act.HBV_Beds_BMS_CN__c = target.HBV_Beds_BMS_CN__c;
					act.M3_Avg_ETV_ARV_BMS_CN__c = target.M3_Avg_ETV_ARV_BMS_CN__c;
					act.M3_Avg_HP_ETV_BMS_CN__c = target.M3_Avg_HP_ETV_BMS_CN__c;
					act.M3_Avg_Lamivudine_ARV_BMS_CN__c = target.M3_Avg_Lamivudine_ARV_BMS_CN__c;
					
				}
				if(target.BU_BMS_CN__c == 'ONCO-TAXOL') {
					// ONCO-TAXOL
					act.Is_KOL_BMS_CN__c = target.Is_KOL_BMS_CN__c;
					act.Decision_Making_BMS_CN__c = target.Decision_Making_BMS_CN__c;
										
					//Decision making weight
					Double dWeight;
					if(target.Decision_Making_BMS_CN__c == 'Decision Maker') {
						dWeight = 1.0;
					}else if(target.Decision_Making_BMS_CN__c == 'Assistant') {
						dWeight = 0.5;
					}else {
						dWeight = 0.2;
					}	
					if(target.Onco_Taxol_Product_BMS_CN__c == 'Taxol' || target.Onco_Taxol_Product_BMS_CN__c == 'Taxol+Paraplatin'){
						act.Monthly_Taxol_Prescription_BMS_CN__c = target.Monthly_Taxol_Prescription_BMS_CN__c;
						act.Monthly_Paclitaxel_BMS_CN__c = target.Monthly_Paclitaxel_BMS_CN__c;
						act.Monthly_Liposome_BMS_CN__c = target.Monthly_Liposome_BMS_CN__c;
						act.Monthly_Anzatax_BMS_CN__c = target.Monthly_Anzatax_BMS_CN__c;
						act.Monthly_Homemade_Paclitaxel_BMS_CN__c = target.Monthly_Homemade_Paclitaxel_BMS_CN__c;
						act.Monthly_Taxotere_BMS_CN__c = target.Monthly_Taxotere_BMS_CN__c;
						act.Monthly_Homemade_Docetaxel_BMS_CN__c = target.Monthly_Homemade_Docetaxel_BMS_CN__c;
						
						act.Taxol_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Taxol', 'Taxol', Double.valueOf(target.Monthly_Taxol_Prescription_BMS_CN__c), dWeight);						
						act.Paclitaxel_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Taxol', 'Paclitaxel for Injection', Double.valueOf(target.Monthly_Paclitaxel_BMS_CN__c), dWeight);
						act.Liposome_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Taxol', 'Liposome', Double.valueOf(target.Monthly_Liposome_BMS_CN__c), dWeight);
						act.Anzatax_Potential_Patients__c = calcPotenitalPatients('Taxol', 'Anzatax', Double.valueOf(target.Monthly_Anzatax_BMS_CN__c), dWeight);
						act.Homemade_Paclitaxel_Poten_Patient_BMS_CN__c = calcPotenitalPatients('Taxol', 'Homemade Paclitaxel', Double.valueOf(target.Monthly_Homemade_Paclitaxel_BMS_CN__c), dWeight);
						act.Taxotere_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Taxol', 'Taxotere', Double.valueOf(target.Monthly_Taxotere_BMS_CN__c), dWeight);
						act.Homemade_Docetaxel_Poten_Patient_BMS_CN__c = calcPotenitalPatients('Taxol', 'Homemade Docetaxel', Double.valueOf(target.Monthly_Homemade_Docetaxel_BMS_CN__c), dWeight);
					}
					//Number of Paraplatin potential patients
					if(target.Onco_Taxol_Product_BMS_CN__c == 'Paraplatin' || target.Onco_Taxol_Product_BMS_CN__c == 'Taxol+Paraplatin'){
						act.Monthly_Paraplatin_Prescription_BMS_CN__c = target.Monthly_Paraplatin_BMS_CN__c;
						act.Monthly_Carboplatin_Imitation_BMS_CN__c = target.Monthly_Carboplatin_Imitation_BMS_CN__c;
						act.Monthly_Cisplatin_BMS_CN__c = target.Monthly_Cisplatin_BMS_CN__c;
						act.Monthly_Nedaplatin_BMS_CN__c = target.Monthly_Nedaplatin_BMS_CN__c;
						
						act.Paraplatin_Potential_Patients_BMS_CN__c= calcPotenitalPatients('Paraplatin', 'Paraplatin', Double.valueOf(target.Monthly_Paraplatin_BMS_CN__c), dWeight);
						act.Carboplatin_Imitation_Pote_Pat_BMS_CN__c = calcPotenitalPatients('Paraplatin', 'Carboplatin Imitation', Double.valueOf(target.Monthly_Carboplatin_Imitation_BMS_CN__c), dWeight);
						act.Cisplatin_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Paraplatin', 'Cisplatin', Double.valueOf(target.Monthly_Cisplatin_BMS_CN__c), dWeight);
						act.Nedaplatin_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Paraplatin', 'Nedaplatin', Double.valueOf(target.Monthly_Nedaplatin_BMS_CN__c), dWeight);
					}			
				}
				if(target.BU_BMS_CN__c == 'ONCO-SPRYCEL') {
					// ONCO-SPRYCEL
					act.Is_GIPAP_TIPAP_Dr_BMS_CN__c = target.Is_GIPAP_TIPAP_BMS_CN__c;
					act.CML_Patients_BMS_CN__c = target.CML_Patients_BMS_CN__c;
				}
				if(target.BU_BMS_CN__c == 'DB') {
					// DB
					act.Type2_Diabetes_Patients_BMS_CN__c = target.NIDDM_Patients_BMS_CN__c;
				}
				if(target.BU_BMS_CN__c == 'OTC') {
					// OTC
					act.Monthly_Prescription_Amount_BMS_CN__c = target.Monthly_Perscription_Amount_BMS_CN__c;
					act.Monthly_Out_patients_BMS_CN__c = target.Monthly_Out_patients_BMS_CN__c;
					if(target.Is_L_KEY_BMS_CN__c == 'Yes') {
						act.L_Key_BMS_CN__c = true;					
					}else {
						act.L_Key_BMS_CN__c = false;
					}
				}
				
				newDoctorList.add(act);
			}
			// Edit doctor basic info
			else {
				Account editAct = editDoctorMap.get(target.Doctor_BMS_CN__c);
				Boolean bAddFlg = false;

				if(target.Gender_Final_BMS_CN__c <> null && editAct.Gender_vod__c <> target.Gender_Final_BMS_CN__c) {
					editAct.Gender_vod__c = target.Gender_Final_BMS_CN__c;
				}
				if(target.Department_Final_BMS_CN__c <> null && editAct.Department_BMS_CN__c <> target.Department_Final_BMS_CN__c) {
					editAct.Department_BMS_CN__c = target.Department_Final_BMS_CN__c;
					bAddFlg = true;
				}
				if(target.Administrative_Title_Final_BMS_CN__c <> null && editAct.Administrative_Title_BMS_CN__c <> target.Administrative_Title_Final_BMS_CN__c) {
					editAct.Administrative_Title_BMS_CN__c = target.Administrative_Title_Final_BMS_CN__c;
				}
				if(target.Technical_Title_Final_BMS_CN__c <> null && editAct.Technical_Title_BMS_CN__c <> target.Technical_Title_Final_BMS_CN__c) {
					editAct.Technical_Title_BMS_CN__c = target.Technical_Title_Final_BMS_CN__c;
				}
				if(target.Hospital_Final_BMS_CN__c <> null && editAct.Primary_Parent_vod__c <> target.Hospital_Final_BMS_CN__c) {
					editAct.Primary_Parent_vod__c = target.Hospital_Final_BMS_CN__c;				
					editAct.Address_BMS_CN__c = getHospitalAddress(target.Hospital_Final_BMS_CN__c, hospAddList);
					bAddFlg = true;
				}
				if(bAddFlg == true) {										
					Address_vod__c  editDocAdd = editDocAddMap.get(editAct.Id);
					editDocAdd.Lock_vod__c = false;
					editDocAdd.Name = getHospitalName(editAct.Primary_Parent_vod__c, hospAddList) + ' ' + depMap.get(target.Department_Final_BMS_CN__c);
				}
			}
		}		
		// Insert Account of new doctor
		insert newDoctorList;
		
		// Insert Address, Product Metrics & Patinet Tracker of new doctor
		for(Account act : newDoctorList) {
			Address_vod__c newAddress = new Address_vod__c();
			newAddress.Account_vod__c = act.Id;
			newAddress.ADDRESS_SOURCE_COUNTRY_BMS_CORE__C = 'CN';
            newAddress.Name = getHospitalName(act.Primary_Parent_vod__c, hospAddList) + ' ' + depMap.get(act.Department_BMS_CN__c);
            newAddress.RecordTypeId = addRecTypeId;
            newAddress.Lock_vod__c = false;
            newAddress.Primary_vod__c = true;           
			newAddressList.add(newAddress);
			
			for(Product_vod__c prd : prdlist) {
				Product_Metrics_vod__c pm = new Product_Metrics_vod__c();
				pm.Account_vod__c = act.Id;
				pm.Products_vod__c = prd.Id;
				pmList.add(pm);
			}
			
			Patient_Tracker_BMS_CN__c pt1M = new Patient_Tracker_BMS_CN__c();
			Patient_Tracker_BMS_CN__c pt2M = new Patient_Tracker_BMS_CN__c();
			Patient_Tracker_BMS_CN__c pt3M = new Patient_Tracker_BMS_CN__c();
			
			// Set Account
			pt1M.Account__c = act.Id;
			pt2M.Account__c = act.Id;
			pt3M.Account__c = act.Id;
			
			// Set Period
			pt1M.Cycle_Period_BMS_CN__c = getPeriod(-1);
			pt2M.Cycle_Period_BMS_CN__c = getPeriod(-2);
			pt3M.Cycle_Period_BMS_CN__c = getPeriod(-3);
			
			if(act.M3_Avg_ETV_ARV_BMS_CN__c == null) {
				pt1M.ETV_ARV_BMS_CN__c = 0;
				pt2M.ETV_ARV_BMS_CN__c = 0;
				pt3M.ETV_ARV_BMS_CN__c = 0;
			} else {
				pt1M.ETV_ARV_BMS_CN__c = act.M3_Avg_ETV_ARV_BMS_CN__c;
				pt2M.ETV_ARV_BMS_CN__c = act.M3_Avg_ETV_ARV_BMS_CN__c;
				pt3M.ETV_ARV_BMS_CN__c = act.M3_Avg_ETV_ARV_BMS_CN__c;
			}
			
			if(act.M3_Avg_HP_ETV_BMS_CN__c == null) {
				pt1M.Baraclude_ETV_BMS_CN__c = 0;
				pt2M.Baraclude_ETV_BMS_CN__c = 0;
				pt3M.Baraclude_ETV_BMS_CN__c = 0;
			} else {
				pt1M.Baraclude_ETV_BMS_CN__c = act.M3_Avg_HP_ETV_BMS_CN__c;
				pt2M.Baraclude_ETV_BMS_CN__c = act.M3_Avg_HP_ETV_BMS_CN__c;
				pt3M.Baraclude_ETV_BMS_CN__c = act.M3_Avg_HP_ETV_BMS_CN__c;
			}
			
			if(act.M3_Avg_Lamivudine_ARV_BMS_CN__c == null) {
				pt1M.Lamivudine_ARV_BMS_CN__c = 0;
				pt2M.Lamivudine_ARV_BMS_CN__c = 0;
				pt3M.Lamivudine_ARV_BMS_CN__c = 0;
			} else {
				pt1M.Lamivudine_ARV_BMS_CN__c = act.M3_Avg_Lamivudine_ARV_BMS_CN__c;
				pt2M.Lamivudine_ARV_BMS_CN__c = act.M3_Avg_Lamivudine_ARV_BMS_CN__c;
				pt3M.Lamivudine_ARV_BMS_CN__c = act.M3_Avg_Lamivudine_ARV_BMS_CN__c;
			}
			newPTList.add(pt1M);
			newPTList.add(pt2M);
			newPTList.add(pt3M);
			
		}
		insert newAddressList;
		insert pmList;
		insert newPTList;
		
		// Update basic info of doctor
		Update editDoctorMap.values();
		Update editDocAddMap.values();
		
		
	    // Remove child account
	    List<Child_Account_vod__c> memberOf = [SELECT Id FROM Child_Account_vod__c WHERE Child_Account_vod__c =: docIdSet AND Primary_vod__c = 'No'];
	    delete memberOf;
	}
	global void finish(Database.BatchableContext BC) {
		
	}
	
	// Get address of hospital
	public String getHospitalAddress(Id hospId, List<Address_vod__c> addList) {
		String strAdd = '';
		for(Address_vod__c add: addList) {
			if(add.Account_vod__c == hospId) {
				if(add.State_vod__c <> null) {
            		strAdd = strAdd + mapState.get(add.State_vod__c) + ' ';
            	}
            	if(add.City_vod__c <> null) {
            		strAdd = strAdd + add.City_vod__c + ' ';
            	}
            	strAdd = strAdd + add.Name + ' ';
            	if(add.Zip_vod__c <> null) {
            		strAdd = strAdd + add.Zip_vod__c;
            	}
			}
		}
		return strAdd;
	}
	// Get name of hospital
	public String getHospitalName(Id hospId, List<Address_vod__c> addList) {
		String hospName = '';
		for(Address_vod__c add: addList) {
			if(add.Account_vod__c == hospId) {
				hospName = add.Account_vod__r.Name;
			}			
		}
		return hospName;
	}
	
	//Get period
	public String getPeriod(Integer shift) {
		Date nextMonth = Date.Today().addMonths(shift);
	    String s=String.ValueOf(nextMonth);
	    String[] ymd = s.split('-', -1);
	    return (ymd[0]+'/'+ymd[1]);
	}
	
	//Calculate number of potential patients
	public Decimal calcPotenitalPatients(String type,String prod,Double iVol, Double weight) {
		Double commSpec = Double.valueOf(commSpecMap.get(prod));
		Double perDose = Double.valueOf(perDoseMap.get(prod));
		
		//Conversion ratio
		Double ratio;
		if(type == 'Taxol'){			
			ratio = Double.valueOf(TaxolConvRatioMap.get(prod));
		}else {
			ratio = Double.valueOf(PrapConvRatioMap.get(prod));
		}
		Double potienalPatients = iVol * commSpec / perDose * ratio * weight;
		return potienalPatients;
	}	
}