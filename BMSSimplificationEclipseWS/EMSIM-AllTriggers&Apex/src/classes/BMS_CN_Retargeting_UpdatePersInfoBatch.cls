/*
* Name: BMS_CN_Retargeting_UpdatePersInfoBatch
* Description: Update prescription info of Retargeting EOM batch 
* Author: Roy Zhang
* Created Date: 04/01/2013
* Last Modified Date: 07/10/2013
*/
global class BMS_CN_Retargeting_UpdatePersInfoBatch implements Database.Batchable<sObject>{
	global String strQuery;
	global Map<String, String> commSpecMap;
	global Map<String, String> perDoseMap;
	global Map<String, String> TaxolConvRatioMap;
	global Map<String, String> PrapConvRatioMap;
	
	global BMS_CN_Retargeting_UpdatePersInfoBatch() {		
		commSpecMap = new Map<String, String>();
		perDoseMap = new Map<String, String>();
		TaxolConvRatioMap = new Map<String, String>();
		PrapConvRatioMap = new Map<String, String>();
		
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
		strQuery = 'SELECT'
					+ '     Id,'
					+ '     Decision_of_Beds_Index_BMS_CN__c,'
					+ '     Weekly_Out_Patients_BMS_CN__c,'
					+ '     Weekly_HBV_Out_patients_BMS_CN__c,'
					+ '     L_Key_BMS_CN__c,'
					+ '     HBV_Beds_BMS_CN__c,'
					+ '     M3_Avg_ETV_ARV_BMS_CN__c,'
					+ '     M3_Avg_HP_ETV_BMS_CN__c,'
					+ '     M3_Avg_Lamivudine_ARV_BMS_CN__c,'
					+ '     Monthly_Taxol_Prescription_BMS_CN__c,'
					+ '     Monthly_Brand_Prescription_BMS_CN__c,'
					+ '     Is_GIPAP_TIPAP_Dr_BMS_CN__c,'
					+ '     CML_Patients_BMS_CN__c,'
					+ '     Type2_Diabetes_Patients_BMS_CN__c,'
					+ '     Monthly_Prescription_Amount_BMS_CN__c,'
					+ '     Monthly_Out_patients_BMS_CN__c,'
					+ '     Department_BMS_CN__c,'
					+ '     Technical_Title_BMS_CN__c,'
					+ '     Beds_BMS_CN__c,' 					
					+ '     Monthly_Operations_BMS_CN__c' 
					+ ' FROM'
					+ '     Account'
					+ ' WHERE'
					+ '     Id IN (SELECT'
					+ '               Doctor_BMS_CN__c'
					+ '           FROM'
					+ '               Retargeting_BMS_CN__c'
					+ '           WHERE'
					+ '               Action_Type_BMS_CN__c = \'EDIT\' AND'
					+ '               Status_BMS_CN__c = \'Approved\' AND'
					+ '               Active_BMS_CN__c = true)';
	}
	global Database.Querylocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(strQuery);
	}
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Account> actList = scope;
		Map<Id, String> targetHPUsageLvMap = new Map<Id, String>();
		Set<Id> actIdSet = new Set<Id>();
		for(Account acct : actList) {
			if(!actIdSet.contains(acct.Id)) {
				actIdSet.add(acct.Id);
			}
		}
		
		String strPeriod = getPeriod(-1);
		List<Patient_Tracker_BMS_CN__c> ptList = [SELECT
														Id,
														Name,
														Account__c,
														Cycle_Period_BMS_CN__c,
														ETV_ARV_BMS_CN__c,
														Baraclude_ETV_BMS_CN__c,
														Lamivudine_ARV_BMS_CN__c 
													FROM
														Patient_Tracker_BMS_CN__c
													WHERE														
														Account__c IN: actIdSet AND
														Cycle_Period_BMS_CN__c =: strPeriod
													];
		
		// Loop retareting
		for(Account act : actList) {
			AggregateResult[] retargetResult = [SELECT
													Doctor_BMS_CN__c,
													BU_BMS_CN__c,
													CV_Product_BMS_CN__c,
													MAX(IS_L_KEY_NUM_BMS_CN__c) IS_L_KEY,
													AVG(Decision_of_Beds_Index_BMS_CN__c) Decision_of_Beds_Index,
													AVG(Weekly_Out_patients_BMS_CN__c) Weekly_Out_patients,
													AVG(Beds_Eliquis_BMS_CN__c) Beds_Eliquis,
													AVG(Monthly_Operations_BMS_CN__c) Monthly_Operations,
													AVG(Weekly_HBV_Out_patients_BMS_CN__c) Weekly_HBV_Out_patients,
													AVG(HBV_Beds_BMS_CN__c) HBV_Beds,
													AVG(M3_Avg_ETV_ARV_BMS_CN__c) M3_Avg_ETV_ARV,
													AVG(M3_Avg_HP_ETV_BMS_CN__c) M3_Avg_HP_ETV,
													AVG(M3_Avg_Lamivudine_ARV_BMS_CN__c) M3_Avg_Lamivudine_ARV,
													AVG(Monthly_Taxol_Prescription_BMS_CN__c) Monthly_Taxol_Pers,
													AVG(Monthly_Brand_Prescription_BMS_CN__c) Monthly_Brand_Pres,
													AVG(Is_GIPAP_TIPAP_NUM_BMS_CN__c) Is_GIPAP_TIPAP,
													AVG(CML_Patients_BMS_CN__c) CML_Patients,
													AVG(NIDDM_Patients_BMS_CN__c) NIDDM_Patients,
													AVG(Monthly_Perscription_Amount_BMS_CN__c) Monthly_Pers_Amount,
													AVG(Monthly_Out_patients_BMS_CN__c) Monthly_Out_patients
												FROM
													Retargeting_BMS_CN__c
												WHERE
												    Action_Type_BMS_CN__c = 'EDIT' AND
												    Status_BMS_CN__c = 'Approved' AND
												    Active_BMS_CN__c = true AND
												    BU_BMS_CN__c <> 'ONCO-TAXOL' AND
												    Doctor_BMS_CN__c =: act.Id
												GROUP BY
													Doctor_BMS_CN__c,
													BU_BMS_CN__c,
													CV_Product_BMS_CN__c];
																					
			// Update perscripiton information except CV & Onco-Taxol 								
			for(AggregateResult aggrResult : retargetResult) {
				if(aggrResult.get('BU_BMS_CN__c') == 'CV') {
					if(aggrResult.get('CV_Product_BMS_CN__c') == 'Monopril') {
						act.Decision_of_Beds_Index_BMS_CN__c = Double.valueOf(aggrResult.get('Decision_of_Beds_Index'));
						act.Weekly_Out_Patients_BMS_CN__c = Double.valueOf(aggrResult.get('Weekly_Out_patients'));		
					} else if(aggrResult.get('CV_Product_BMS_CN__c') == 'Eliquis') {
						act.Beds_BMS_CN__c = Double.valueOf(aggrResult.get('Beds_Eliquis'));
						act.Monthly_Operations_BMS_CN__c = Double.valueOf(aggrResult.get('Monthly_Operations'));
					}								
				}else if(aggrResult.get('BU_BMS_CN__c') == 'HP') {
					act.Weekly_HBV_Out_patients_BMS_CN__c = Double.valueOf(aggrResult.get('Weekly_HBV_Out_patients'));
					act.HBV_Beds_BMS_CN__c = Double.valueOf(aggrResult.get('HBV_Beds'));
					
					for(Patient_Tracker_BMS_CN__c pt : ptList) {
						if(pt.Account__c == act.Id) {
							pt.ETV_ARV_BMS_CN__c = Double.valueOf(aggrResult.get('M3_Avg_ETV_ARV'));
							pt.Baraclude_ETV_BMS_CN__c = Double.valueOf(aggrResult.get('M3_Avg_HP_ETV'));
							pt.Lamivudine_ARV_BMS_CN__c = Double.valueOf(aggrResult.get('M3_Avg_Lamivudine_ARV'));
						}
					}														
				}else if(aggrResult.get('BU_BMS_CN__c') == 'ONCO-SPRYCEL') {
					if(Integer.valueOf(aggrResult.get('Is_GIPAP_TIPAP')) > 0) {
						act.Is_GIPAP_TIPAP_Dr_BMS_CN__c = 'Yes';					
					}else {
						act.Is_GIPAP_TIPAP_Dr_BMS_CN__c = 'No';
					}
					act.CML_Patients_BMS_CN__c = Double.valueOf(aggrResult.get('CML_Patients'));
				}else if(aggrResult.get('BU_BMS_CN__c') == 'DB') {
					act.Type2_Diabetes_Patients_BMS_CN__c = Double.valueOf(aggrResult.get('NIDDM_Patients'));			
				}else if(aggrResult.get('BU_BMS_CN__c') == 'OTC') {
					act.Monthly_Prescription_Amount_BMS_CN__c = Double.valueOf(aggrResult.get('Monthly_Pers_Amount'));
					act.Monthly_Out_patients_BMS_CN__c = Double.valueOf(aggrResult.get('Monthly_Out_patients'));
					if(Integer.valueOf(aggrResult.get('IS_L_KEY')) > 0) {
						act.L_Key_BMS_CN__c = true;
					}else {
						act.L_Key_BMS_CN__c = false;
					}					
				}			
			}
			// Update perscripiton information of ONCO-TAXOL
			List<Retargeting_BMS_CN__c> oncoTaxolList = [SELECT
															Doctor_BMS_CN__c,
															BU_BMS_CN__c,
															Is_KOL_BMS_CN__c,
															Onco_Taxol_Product_BMS_CN__c,
															Decision_Making_BMS_CN__c,
															Monthly_Anzatax_BMS_CN__c,
															Monthly_Carboplatin_Imitation_BMS_CN__c,
															Monthly_Cisplatin_BMS_CN__c,
															Monthly_Homemade_Docetaxel_BMS_CN__c,
															Monthly_Homemade_Paclitaxel_BMS_CN__c,
															Monthly_Liposome_BMS_CN__c,
															Monthly_Nedaplatin_BMS_CN__c,
															Monthly_Paclitaxel_BMS_CN__c,
															Monthly_Paraplatin_BMS_CN__c,
															Monthly_Taxol_Prescription_BMS_CN__c,
															Monthly_Taxotere_BMS_CN__c																														
														FROM
															Retargeting_BMS_CN__c
														WHERE
															Action_Type_BMS_CN__c = 'EDIT' AND
												    		Status_BMS_CN__c = 'Approved' AND
												    		Active_BMS_CN__c = true AND
												    		BU_BMS_CN__c = 'ONCO-TAXOL' AND
												    		Doctor_BMS_CN__c =: act.Id];
												    		
			Boolean isKOL = false;
			Double dWeight = 0.2;
			String sDecisionMaking = 'Subordinate';
			for(Retargeting_BMS_CN__c reg: oncoTaxolList) {
				//Get KOL
				if(reg.Is_KOL_BMS_CN__c == true) {
					isKOL = true;
				}
				//Get Decision-Making Weight
				if(reg.Decision_Making_BMS_CN__c == 'Decision Maker' && dWeight < 1){
					dWeight = 1.0;
					sDecisionMaking = 'Decision Maker';
				}else if (reg.Decision_Making_BMS_CN__c == 'Assistant' && dWeight < 0.5) {
					dWeight = 0.5;
					sDecisionMaking = 'Assistant';
				}
			}
			if(oncoTaxolList.size()>0) {
				act.Is_KOL_BMS_CN__c = isKOL;
				act.Decision_Making_BMS_CN__c = sDecisionMaking;
			}			
				
			for(Retargeting_BMS_CN__c retargetTAXLOL: oncoTaxolList){
				//Number of Taxol potential patients
				if(retargetTAXLOL.Onco_Taxol_Product_BMS_CN__c == 'Taxol' || retargetTAXLOL.Onco_Taxol_Product_BMS_CN__c == 'Taxol+Paraplatin'){
					act.Monthly_Taxol_Prescription_BMS_CN__c = retargetTAXLOL.Monthly_Taxol_Prescription_BMS_CN__c;
					act.Monthly_Paclitaxel_BMS_CN__c = retargetTAXLOL.Monthly_Paclitaxel_BMS_CN__c;
					act.Monthly_Liposome_BMS_CN__c = retargetTAXLOL.Monthly_Liposome_BMS_CN__c;
					act.Monthly_Anzatax_BMS_CN__c = retargetTAXLOL.Monthly_Anzatax_BMS_CN__c;
					act.Monthly_Homemade_Paclitaxel_BMS_CN__c = retargetTAXLOL.Monthly_Homemade_Paclitaxel_BMS_CN__c;
					act.Monthly_Taxotere_BMS_CN__c = retargetTAXLOL.Monthly_Taxotere_BMS_CN__c;
					act.Monthly_Homemade_Docetaxel_BMS_CN__c = retargetTAXLOL.Monthly_Homemade_Docetaxel_BMS_CN__c;
						
					act.Taxol_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Taxol', 'Taxol', Double.valueOf(retargetTAXLOL.Monthly_Taxol_Prescription_BMS_CN__c), dWeight);						
					act.Paclitaxel_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Taxol', 'Paclitaxel for Injection', Double.valueOf(retargetTAXLOL.Monthly_Paclitaxel_BMS_CN__c), dWeight);
					act.Liposome_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Taxol', 'Liposome', Double.valueOf(retargetTAXLOL.Monthly_Liposome_BMS_CN__c), dWeight);
					act.Anzatax_Potential_Patients__c = calcPotenitalPatients('Taxol', 'Anzatax', Double.valueOf(retargetTAXLOL.Monthly_Anzatax_BMS_CN__c), dWeight);
					act.Homemade_Paclitaxel_Poten_Patient_BMS_CN__c = calcPotenitalPatients('Taxol', 'Homemade Paclitaxel', Double.valueOf(retargetTAXLOL.Monthly_Homemade_Paclitaxel_BMS_CN__c), dWeight);
					act.Taxotere_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Taxol', 'Taxotere', Double.valueOf(retargetTAXLOL.Monthly_Taxotere_BMS_CN__c), dWeight);
					act.Homemade_Docetaxel_Poten_Patient_BMS_CN__c = calcPotenitalPatients('Taxol', 'Homemade Docetaxel', Double.valueOf(retargetTAXLOL.Monthly_Homemade_Docetaxel_BMS_CN__c), dWeight);
				}
				//Number of Paraplatin potential patients
				if(retargetTAXLOL.Onco_Taxol_Product_BMS_CN__c == 'Paraplatin' || retargetTAXLOL.Onco_Taxol_Product_BMS_CN__c == 'Taxol+Paraplatin'){
					act.Monthly_Paraplatin_Prescription_BMS_CN__c = retargetTAXLOL.Monthly_Paraplatin_BMS_CN__c;
					act.Monthly_Carboplatin_Imitation_BMS_CN__c = retargetTAXLOL.Monthly_Carboplatin_Imitation_BMS_CN__c;
					act.Monthly_Cisplatin_BMS_CN__c = retargetTAXLOL.Monthly_Cisplatin_BMS_CN__c;
					act.Monthly_Nedaplatin_BMS_CN__c = retargetTAXLOL.Monthly_Nedaplatin_BMS_CN__c;
					
					act.Paraplatin_Potential_Patients_BMS_CN__c= calcPotenitalPatients('Paraplatin', 'Paraplatin', Double.valueOf(retargetTAXLOL.Monthly_Paraplatin_BMS_CN__c), dWeight);
					act.Carboplatin_Imitation_Pote_Pat_BMS_CN__c = calcPotenitalPatients('Paraplatin', 'Carboplatin Imitation', Double.valueOf(retargetTAXLOL.Monthly_Carboplatin_Imitation_BMS_CN__c), dWeight);
					act.Cisplatin_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Paraplatin', 'Cisplatin', Double.valueOf(retargetTAXLOL.Monthly_Cisplatin_BMS_CN__c), dWeight);
					act.Nedaplatin_Potential_Patients_BMS_CN__c = calcPotenitalPatients('Paraplatin', 'Nedaplatin', Double.valueOf(retargetTAXLOL.Monthly_Nedaplatin_BMS_CN__c), dWeight);
				}			
			}						
		}
		update actList;	
		update ptList;
	}
	global void finish(Database.BatchableContext BC) {
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