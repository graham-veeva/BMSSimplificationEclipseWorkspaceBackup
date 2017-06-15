global class BMS_EMAE_SCHEDULE_CYCLE_PLAN implements Schedulable{ global void execute(SchedulableContext sc) {
	/* Perform any pre-processing for your organization then call the two functions below*/
	BMS_EMEA_BATCH_CYCLE_PLAN_CALC b = new BMS_EMEA_BATCH_CYCLE_PLAN_CALC(); 
	database.executebatch(b,100);
	
	BMS_EMEA_BATCH_CYCLE_PLAN_CALC_CALLS c = new BMS_EMEA_BATCH_CYCLE_PLAN_CALC_CALLS (); 
	database.executebatch(c,100);
	}
}