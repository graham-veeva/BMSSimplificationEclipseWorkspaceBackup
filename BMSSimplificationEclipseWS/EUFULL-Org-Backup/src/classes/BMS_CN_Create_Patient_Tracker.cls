/*
* Name: BMS_CN_Create_Patient_Tracker
* Description: Monthly create patient tracker for HCP
* Author: Roy Zhang
* Created Date: 06/19/2013
* Last Modified Date: 06/19/2013
*/
global class BMS_CN_Create_Patient_Tracker implements Database.Batchable<sObject>{
	global String strQuery;
	global String strPeriod;
	
	global BMS_CN_Create_Patient_Tracker() {
		strPeriod = getPeriod(-1);
		strQuery = 'SELECT'
					+ '     Id,'
					+ '     Cycle_Period_BMS_CN__c ,'
					+ '     Account__c,'
					+ '     Baraclude_ETV_BMS_CN__c,'
					+ '     ETV_ARV_BMS_CN__c,'
					+ '     Lamivudine_ARV_BMS_CN__c,'
					+ '     Taxol_Actual_BC_Patients_BMS_CN__c,'
					+ '     Taxol_Actual_LC_Patients_BMS_CN__c,'
					+ '     Taxol_Actual_OC_Patients_BMS_CN__c,'
					+ '     Taxol_Actual_Other_Patients_BMS_CN__c,'
					+ '     Taxol_Planned_BC_Patients_BMS_CN__c,'
					+ '     Taxol_Planned_LC_Patients_BMS_CN__c,'
					+ '     Taxol_Planned_OC_Patients_BMS_CN__c,'
					+ '     Taxol_Planned_Other_Patients_BMS_CN__c,'
					+ '     Paraplatin_Actual_Other_Patients_BMS_CN__c,'
					+ '     Paraplatin_Planned_Other_Patients_BMS_CN__c,'
					+ '     Paraplatin_Actual_LC_Patients_BMS_CN__c,'
					+ '     Paraplatin_Actual_OC_Patients_BMS_CN__c,'
					+ '     Paraplatin_Planned_LC_Patients_BMS_CN__c,'
					+ '     Paraplatin_Planned_OC_Patients_BMS_CN__c'					
					+ ' FROM'
					+ '     Patient_Tracker_BMS_CN__c'
					+ ' WHERE'
					+ '     Cycle_Period_BMS_CN__c = \'' + strPeriod + '\'';
					
	}
	global Database.Querylocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(strQuery);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Patient_Tracker_BMS_CN__c> ptList = scope;
		String newPeriod = getPeriod(0);
		
		List<Patient_Tracker_BMS_CN__c> newPTList = new List<Patient_Tracker_BMS_CN__c>();
		
		for(Patient_Tracker_BMS_CN__c pt : ptList){
			Patient_Tracker_BMS_CN__c ptNew = new Patient_Tracker_BMS_CN__c();
			ptNew.Cycle_Period_BMS_CN__c = newPeriod;
			ptNew.Account__c = pt.Account__c;
			ptNew.Baraclude_ETV_BMS_CN__c = pt.Baraclude_ETV_BMS_CN__c;
			ptNew.ETV_ARV_BMS_CN__c = pt.ETV_ARV_BMS_CN__c;
			ptNew.Lamivudine_ARV_BMS_CN__c = pt.Lamivudine_ARV_BMS_CN__c;
			ptNew.Paraplatin_Actual_LC_Patients_BMS_CN__c = pt.Paraplatin_Actual_LC_Patients_BMS_CN__c;
			ptNew.Paraplatin_Actual_OC_Patients_BMS_CN__c = pt.Paraplatin_Actual_OC_Patients_BMS_CN__c;
			ptNew.Paraplatin_Planned_LC_Patients_BMS_CN__c = pt.Paraplatin_Planned_LC_Patients_BMS_CN__c;
			ptNew.Paraplatin_Planned_OC_Patients_BMS_CN__c = pt.Paraplatin_Planned_OC_Patients_BMS_CN__c;
			ptNew.Taxol_Actual_BC_Patients_BMS_CN__c = pt.Taxol_Actual_BC_Patients_BMS_CN__c;
			ptNew.Taxol_Actual_LC_Patients_BMS_CN__c = pt.Taxol_Actual_LC_Patients_BMS_CN__c;
			ptNew.Taxol_Actual_OC_Patients_BMS_CN__c = pt.Taxol_Actual_OC_Patients_BMS_CN__c;
			ptNew.Taxol_Actual_Other_Patients_BMS_CN__c = pt.Taxol_Actual_Other_Patients_BMS_CN__c;
			ptNew.Taxol_Planned_BC_Patients_BMS_CN__c = pt.Taxol_Planned_BC_Patients_BMS_CN__c;
			ptNew.Taxol_Planned_LC_Patients_BMS_CN__c = pt.Taxol_Planned_LC_Patients_BMS_CN__c;
			ptNew.Taxol_Planned_OC_Patients_BMS_CN__c = pt.Taxol_Planned_OC_Patients_BMS_CN__c;
			ptNew.Taxol_Planned_Other_Patients_BMS_CN__c = pt.Taxol_Planned_Other_Patients_BMS_CN__c;
			ptNew.Paraplatin_Actual_Other_Patients_BMS_CN__c = pt.Paraplatin_Actual_Other_Patients_BMS_CN__c;
			ptNew.Paraplatin_Planned_Other_Patients_BMS_CN__c = pt.Paraplatin_Planned_Other_Patients_BMS_CN__c;
				
			newPTList.add(ptNew);			
		}
		
		insert newPTList;
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
}