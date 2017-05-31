trigger VPROF_Create_Sharing_Reasons on EM_Catalog_vod__c (after insert, after update) {

	Set<EM_Catalog_vod__c> topics = new Set<EM_Catalog_vod__c>();
	// make a new list of things we actually need to work with
	if(Trigger.isInsert){
		// we need all of these
		for(EM_Catalog_vod__c topic: Trigger.new){
			topics.add(topic);
		}
	}else if(Trigger.isUpdate){
		// we need these if the owner country changed
		for(EM_Catalog_vod__c topic: Trigger.new){
			if(topic.Owner_Source_Country_HCPTS__c != Trigger.oldMap.get(topic.Id).Owner_Source_Country_HCPTS__c){
				topics.add(topic);
			}
		}
	}

	// if there are no topics in the set, then stop
	if(topics.size() == 0){return;}

	// list of Apex Sharing Reasons to insert later
	List<EM_Catalog_vod__Share> topicSharesToInsert = new List<EM_Catalog_vod__Share>();
	// list of Apex Sharing Reasons to delete (if the owner changes, then delete the existing shares and make new ones)
	List<EM_Catalog_vod__Share> topicSharesToDelete;

	if(Trigger.isUpdate){
		// find any existing records and delete them
		topicSharesToDelete = [SELECT Id FROM EM_Catalog_vod__Share WHERE ParentId IN :topics AND RowCause = 'Manual'];
	}

	// Make the apex sharing reasons records
	for(EM_Catalog_vod__c topic: topics){

		// find the custom setting for the country of the owners
		try{

			if(topic.Owner_Source_Country_HCPTS__c == null){break;}

			VPROF_Topic_Sharing__c cs = VPROF_Topic_Sharing__c.getValues(topic.Owner_Source_Country_HCPTS__c);
			
			if(cs == null){
				// there was not a custom setting for this country
				System.debug('There was not a custom setting record for this country');
				break;
			}

			// turn the custom setting data into a list of Ids. Need to create a new Topic Share for each Id
			String mappingIds = '';
	        if(cs.User_And_Group_Ids_1__c!=null && cs.User_And_Group_Ids_1__c.trim()!=''){
	            mappingIds += cs.User_And_Group_Ids_1__c;
	        }
	        if(cs.User_And_Group_Ids_2__c!=null && cs.User_And_Group_Ids_2__c.trim()!=''){
	            mappingIds += ',' + cs.User_And_Group_Ids_2__c;
	        }
	        if(cs.User_And_Group_Ids_3__c!=null && cs.User_And_Group_Ids_3__c.trim()!=''){
	            mappingIds += ',' + cs.User_And_Group_Ids_3__c;
	        }
	        String[] UserAndGroupIds;
	        if(mappingIds != null && mappingIds.trim() != ''){
	            UserAndGroupIds = mappingIds.split(',');
	        }

	        System.debug('UserAndGroupIds: ' + UserAndGroupIds);

			// create sharing reasons
			for(String myId: UserAndGroupIds){
				EM_Catalog_vod__Share newShare = new EM_Catalog_vod__Share();
				newShare.ParentId = topic.Id;
				newShare.AccessLevel = 'Read';
				newShare.UserOrGroupId = myId;
				newShare.RowCause = 'Manual';
				topicSharesToInsert.add(newShare);
			}

		}Catch(Exception e){
			// there was an error, not adding any sharing records
			System.debug('Catch block in VPROF_Create_Sharing_Reasons on EM_Catalog_vod__c: ' + e);
		}
	}

	// Do the DML
	try{
		if(topicSharesToDelete != null && topicSharesToDelete.size() != 0){
			System.debug('topicSharesToDelete: ' + topicSharesToDelete);
			delete topicSharesToDelete;
		}
		if(topicSharesToInsert != null && topicSharesToInsert.size() != 0){
			System.debug('topicSharesToInsert: ' + topicSharesToInsert);
			insert topicSharesToInsert;
		}
	}Catch(Exception e){
		System.debug('DML exception while deleting/inserting Topic Shares: ' + e);
	}
}