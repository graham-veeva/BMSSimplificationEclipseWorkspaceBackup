public class VPROF_All_Activities_Controller {
	

	public String needID{get;set;}
	public List<EM_Event_vod__c> activities{get;set;}
	public boolean hasResults{get;set;}
	public Schema.FieldSet myFieldSet{get;set;}

	
	public List<Schema.FieldSetMember> getFields() {
        return Schema.SObjectType.EM_Event_vod__c.fieldSets.getMap().get('Need_Related_Activities').getFields();
    }


	public VPROF_All_Activities_Controller() {
		
		needID = ApexPages.currentPage().getParameters().get('ID');

		List<EM_Event_Budget_vod__c> actBudgets = [SELECT Id,Event_vod__c
					FROM EM_Event_Budget_vod__c WHERE Budget_vod__c = :needId];

		Set<Id> actIds = new Set<Id>();
		for(EM_Event_Budget_vod__c ab : actBudgets){
			actIds.add(ab.Event_vod__c);
		}

		String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM EM_Event_vod__c  WHERE Id IN :actIds';
        
        activities = Database.query(query);

		if(activities.size() > 0){
			hasResults = true;
		}else{
			hasResults = false;
		}



	}
}