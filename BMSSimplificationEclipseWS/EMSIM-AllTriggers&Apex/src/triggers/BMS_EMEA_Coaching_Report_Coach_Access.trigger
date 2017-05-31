/**
 * Trigger: BMS_EMEA_Coaching_Report_Coach_Access
 * Object:  Coaching_Report_vod__c
 * Author:  Raphael Krausz <raphael.krausz@veeva.com>
 * Date:    2014-05-14
 *
 * Description:
 *
 * Grant the Coach access to the record by creating a CoachingReport.Share record. Used in the event the
 * Coach does not sit necessarily above the Employee in the Role hierarchy: since the OOTB trigger
 * VOD_COACHING_REPORT_BEFORE_INSUPD_TRIGGER will set the Employee as the record Owner there is a risk the Coach
 * could not see the record any longer.
 *
 *  - It is recommended to handle the Coach information through a lookup (Coach will be stamped in here)
 *    rather than taking out the CreatedBy.User
 *
 *  - Need to fire the trigger for EMEA users only
 *
 *  N.B. This trigger is based off Wayne Abbott's Coaching_Report_After_UPSERT trigger
 *
 */

trigger BMS_EMEA_Coaching_Report_Coach_Access  on Coaching_Report_vod__c (after insert, after update) {

    // We need to know the RecordType names for each of the coaching reports
    // We limit our database interactions
    Set<Id> recordTypeIdSet = new Set<Id>();
    for (Coaching_Report_vod__c coachingReport : trigger.new) {
        recordTypeIdSet.add(coachingReport.RecordTypeId);
    }

    List<RecordType> recordTypeList = [ SELECT Id, DeveloperName FROM RecordType WHERE Id IN :recordTypeIdSet ];
    Map<Id, String> recordTypeIdToDeveloperNameMap = new Map<Id, String>();
    for (RecordType theRecordType : recordTypeList) {
        recordTypeIdToDeveloperNameMap.put(theRecordType.Id, theRecordType.DeveloperName);
    }

    List<Coaching_Report_vod__Share> sharesToAdd    = new List<Coaching_Report_vod__Share>();
    List<Coaching_Report_vod__Share> sharesToDelete = new List<Coaching_Report_vod__Share>();

    for (Coaching_Report_vod__c coachingReport : trigger.new) {

        // We don't care about records that don't belong to EMEA
        String recordTypeDeveloperName = recordTypeIdToDeveloperNameMap.get(coachingReport.RecordTypeId);
        Boolean isEMEA = recordTypeDeveloperName.contains('EMEA_') || recordTypeDeveloperName.contains('_EMEA');
        if ( ! isEMEA ) {
            continue;
        }

        // Insert triggers get a new share
        // Updated triggers have the shares changed appropriately, which
        // means we need to delete the old and add the new one
        // However, we need to check that if it's an update that the manager actually changed

        // NOTE: addShare and deleteShare methods create the appropriate share
        // and add it to the sharesToAdd or sharesToDelete list

        if ( Trigger.isInsert ) {
            addShare(coachingReport);
        } else {

            // Trigger.isUpdate must be true

            Coaching_Report_vod__c oldCoachingReport = Trigger.oldMap.get(coachingReport.Id);

            // If the Manager_vod__c hasn't changed, then there isn't anything to do
            if (coachingReport.Manager_vod__c != oldCoachingReport.Manager_vod__c) {
                addShare(coachingReport);
                deleteShare(oldCoachingReport);
            }
        }
    }


    // Check if there are shares to add, and if so add them
    if ( ! sharesToAdd.isEmpty() ) {
        insert sharesToAdd; //runs on error if creator is manager
    }

    // Check if there are shares to delete, and if so delete them
    if ( ! sharesToDelete.isEmpty() ) {

        // We need to grab all the IDs for the shares to delete them from the database
        // First we will build a query string and retrieve all the matching records
        // After that we will then cast all the records to Coaching_Report_vod__Share and delete them
        String soql = 'SELECT Id FROM Coaching_Report_vod__Share WHERE ';
        String whereClause = '';
        for (Coaching_Report_vod__Share share : sharesToDelete) {
            whereClause +=
                ' OR ('
                + 'parentId = \'' + share.ParentId + '\''
                + ' AND AccessLevel = \'' + share.AccessLevel + '\''
                + ' AND UserOrGroupId = \'' + share.UserOrGroupId + '\''
                + ')'
                ;
        }
        whereClause = whereClause.replaceFirst(' OR ', '');
        soql += whereClause;

        List<sObject> results = Database.query(soql);
        sharesToDelete = (List<Coaching_Report_vod__Share>) results;

        // sharesToDelete is now populated with records containing their ID
        // So let's go ahead and delete them
        // N.B. It's possible that there are now no shares to delete, so we will
        // check it again - just to be sure
        if ( ! sharesToDelete.isEmpty() ) {
            delete sharesToDelete;
        }
    }
    
    // Creates a share record and adds it to the list of shares to add to the database
    private void addShare(Coaching_Report_vod__c coachingReport) {
        Coaching_Report_vod__Share newShare = createNewShare(coachingReport);
        sharesToAdd.add(newShare);
    }

    // Creates a share record and adds it to the list of shares to delete from the database
    private void deleteShare(Coaching_Report_vod__c coachingReport) {
        Coaching_Report_vod__Share shareToDelete = createNewShare(coachingReport);
        sharesToDelete.add(shareToDelete);
    }

    // Creates a share record from a Coaching_Report_vod__c record
    private Coaching_Report_vod__Share createNewShare(Coaching_Report_vod__c coachingReport) {
        Coaching_Report_vod__Share crs = new Coaching_Report_vod__Share();
        
        crs.ParentId = coachingReport.Id;
        
        
        if(coachingReport.createdById == coachingReport.Manager_vod__c){
            crs.UserOrGroupId = coachingReport.Employee_vod__c;
            crs.AccessLevel = 'Read';
        }else{
            crs.UserOrGroupId = coachingReport.Manager_vod__c;
            crs.AccessLevel = 'Edit';           
        }
        return crs;        
    }
}