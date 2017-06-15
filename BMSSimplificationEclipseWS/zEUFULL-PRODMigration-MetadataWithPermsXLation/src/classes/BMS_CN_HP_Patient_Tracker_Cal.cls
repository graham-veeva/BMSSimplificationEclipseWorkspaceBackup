/*
* Name: BMS_CN_HP_Patient_Tracker_Cal
* Description: Calculate past 3 months average value of HP patient tracker
* Author: Roy Zhang
* Created Date: 06/19/2013
* Last Modified Date: 06/19/2013
*/
global class BMS_CN_HP_Patient_Tracker_Cal implements Database.Batchable<sObject>{
	global String strQuery;
	
	global BMS_CN_HP_Patient_Tracker_Cal() {
		strQuery = 'SELECT'
					+ '     Id,'
					+ '     Department_BMS_CN__c ,'
					+ '     Technical_Title_BMS_CN__c  ,'
					+ '     M3_Avg_ETV_ARV_BMS_CN__c,'
					+ '     M3_Avg_HP_ETV_BMS_CN__c,'
					+ '     M3_Avg_Lamivudine_ARV_BMS_CN__c,'
					+ '     HP_Usage_Level_BMS_CN__c' 
					+ ' FROM'
					+ '     Account'
					+ ' WHERE'
					+ '     IsPersonAccount = true AND' 	
					+ '     Account_Source_Country_BMS_CORE__c = \'CN\'';				
	}
	
	global Database.Querylocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(strQuery);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
			
		List<Account> actList = scope;
		Map<Id,Account> actMap = new Map<Id,Account>(actList);
		Set<Id> actIdSet = actMap.keySet();
		
		List<String> periodList = new List<String>();
		periodList.add(getPeriod(-1));
		periodList.add(getPeriod(-2));
		periodList.add(getPeriod(-3));

		List<AggregateResult> ptAggrRlt = [SELECT
											Account__c,
											AVG(Baraclude_ETV_BMS_CN__c) Baraclude_ETV,
											AVG(ETV_ARV_BMS_CN__c) ETV_ARV,
											AVG(Lamivudine_ARV_BMS_CN__c) Lamivudine_ARV
										FROM
											Patient_Tracker_BMS_CN__c
										WHERE
											Account__c IN: actIdSet AND
											Cycle_Period_BMS_CN__c IN: periodList
										GROUP BY
											Account__c];
											
		Map<String,AggregateResult> ptAggrMap = new Map<String,AggregateResult>();
		for(AggregateResult agg: ptAggrRlt) {
			ptAggrMap.put(String.valueOf(agg.get('Account__c')),agg);
		}
		
		List<Product_Metrics_vod__c> pmList = [SELECT
													Id,
													Account_vod__c,
													HP_Usage_Level_BMS_CN__c
												FROM
													Product_Metrics_vod__c
												WHERE
													Account_vod__c IN: actIdSet AND
													Products_vod__r.BU_BMS_CN__c = 'HP'];
											
		for(Account act: actList){
			if(ptAggrMap.containsKey(act.Id)){
				AggregateResult aggResult = ptAggrMap.get(act.Id);
				act.M3_Avg_ETV_ARV_BMS_CN__c = Double.valueOf(aggResult.get('ETV_ARV'));
				act.M3_Avg_HP_ETV_BMS_CN__c = Double.valueOf(aggResult.get('Baraclude_ETV'));
				act.M3_Avg_Lamivudine_ARV_BMS_CN__c = Double.valueOf(aggResult.get('Lamivudine_ARV'));
				
				String HPUasgeLv = '';
				if(act.Department_BMS_CN__c == 'PHA' || act.Technical_Title_BMS_CN__c == 'E015'){
					HPUasgeLv = 'No-MD';
				} else if(act.M3_Avg_ETV_ARV_BMS_CN__c >= 30 && act.M3_Avg_HP_ETV_BMS_CN__c >= 50) {
            		HPUasgeLv = 'Baraclude Loyalist';
          		}else if(act.M3_Avg_ETV_ARV_BMS_CN__c >= 30 && act.M3_Avg_HP_ETV_BMS_CN__c < 50) {
            		HPUasgeLv = 'G-ETV Loyalist';
          		}else if(act.M3_Avg_ETV_ARV_BMS_CN__c < 30 && act.M3_Avg_Lamivudine_ARV_BMS_CN__c >= 25) {
            		HPUasgeLv = 'Lamivudine Trialist';
          		}else if(act.M3_Avg_ETV_ARV_BMS_CN__c == 0) {
            		HPUasgeLv = 'Non-Trialist';
          		}else if(act.M3_Avg_ETV_ARV_BMS_CN__c < 30 && act.M3_Avg_Lamivudine_ARV_BMS_CN__c < 25) {
            		HPUasgeLv = 'Others';
          		}
          		
          		act.HP_Usage_Level_BMS_CN__c = HPUasgeLv;
          		
 				for(Product_Metrics_vod__c pm: pmList) {
 					if(pm.Account_vod__c == act.id){
 						pm.HP_Usage_Level_BMS_CN__c = HPUasgeLv;
 					}
 				} 
			}
		}
		
		update actList;
		update pmList;		
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