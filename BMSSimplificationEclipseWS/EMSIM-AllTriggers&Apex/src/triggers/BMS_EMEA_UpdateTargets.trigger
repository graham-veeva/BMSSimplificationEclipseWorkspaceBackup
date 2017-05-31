/*
 * Date:   2014-11-12
 * Author: Raphael Krausz <raphael.krausz@veeva.com>
 * Description:
 *   Based upon the work of Emily Kranz on 4/11/2013
 *   When User submits a cycle plan, we must find all TSF records with  target = true, update them to false, and then
 *   Use the Cycle Plan Target list to set the new Targets.
 *   (Emily's notes)
 *
 *
 * Modified: 2014-11-13
 * Author: Raphael Krausz <raphael.krausz@veeva.com>
 * Description:
 *   Added functionality that when a Cycle Plan is inactivated the matching TSFs have their targets set to false.
 *
 *   So the steps are:
 *     1. Sort the cycle plans of the trigger into activations and deactivations
 *     2. Get all the cycle plan targets related to the cycle plan(s)
 *     3. Get all the TSFs that relate to those cycle plan targets
 *          - update the TSF.My_Target_vod__c to be false
 *          - for deactivations, this is all that needs to be done
 *     4. For activations, go through the cycle plans, and update their corresponding TSFs
 *          - set the TSF.My_Target_vod__c to be true for these cases
 *          - if there is no corresponding TSF create one
 *     5. Write the changes back to the database
 *
 *
 * Modified: 2014-11-14
 * Author: Raphael Krausz <raphael.krausz@veeva.com>
 * Description:
 *   Fixed bug where the inactivation wasn't working due to the wrong territories being read in the getTsfUpdateMap method
 *
 * 
 */

trigger BMS_EMEA_UpdateTargets on Cycle_Plan_vod__c (after update) {

    System.debug('BMS_EMEA_UpdateTargets - number of records for this trigger: ' + Trigger.new.size());

    // global key (account + territory) -> TSF map of TSFs to be updated
    Map<String, TSF_vod__c> tsfUpdateMap;


    /* ****  Helper functions **** */
    private List<Cycle_Plan_Target_vod__c> getCyclePlanTargetList(Set<Id> cyclePlanIdSet, Boolean withPlannedCalls) {

        Integer plannedCalls = ( withPlannedCalls ) ? 0 : -1;

        // N.B. the minimum number stored in Planned_Calls_vod__c is 0, hence a -1 gives all Cycle plans
        // regardless of the number of Planned Calls


        List<Cycle_Plan_Target_vod__c> cyclePlanTargets =
            [
                SELECT Id, Cycle_Plan_Account_vod__c, Territory_BMS_EMEA__c
                FROM Cycle_Plan_Target_vod__c
                WHERE Cycle_Plan_vod__c IN :cyclePlanIdSet AND Planned_Calls_vod__c > :plannedCalls
            ];


        return cyclePlanTargets;
    }

    private Map<String, TSF_vod__c> getTsfUpdateMap(Set<Cycle_Plan_Target_vod__c> cyclePlanTargets, Set<String> territories) {

        // N.B. This method also goes through each TSF and sets its target to false before it returns the map


        System.debug('In getTsfUpdateMap, there are ' + cyclePlanTargets.size() + ' cyclePlanTargets');

        Set<Id> cyclePlanTargetAccountIds  = new Set<Id>();
        Set<Id> cyclePlanTargetTerritories = new Set<Id>();
        for (Cycle_Plan_Target_vod__c target : cyclePlanTargets) {
            cyclePlanTargetAccountIds.add(target.Cycle_Plan_Account_vod__c);
        }

        //Get all TSF records that are either on Cycle Plan Target list or Target = True for territories in Submitted Cycle Plans
        List<TSF_vod__c> tsfList =
            [
                SELECT Territory_vod__c, Id, My_Target_vod__c, Account_vod__c
                FROM TSF_vod__c
                WHERE Territory_vod__c IN :territories
                AND (
                    My_Target_vod__c = true
                                       OR Account_vod__c IN :cyclePlanTargetAccountIds
                )
            ];

        System.debug('In getTsfUpdateMap, tsfList.size(): ' + tsfList.size());

        Map<String, TSF_vod__c> tsfMap = new Map<String, TSF_vod__c>();

        //Loop through list of TSF records and set all KAM Target flags to false
        for (TSF_vod__c tsf : tsfList) {
            tsf.My_target_vod__c = false;
            String key = makeKeyFromTsf(tsf);
            tsfMap.put(key, tsf);
        }

        System.debug('In getTsfUpdateMap, tsfMap.size(): ' + tsfMap.size());

        return tsfMap;
    }

    private String makeKey(String account, String territory) {
        return account + '::' + territory;
    }

    private String makeKeyFromTsf(TSF_vod__c tsf) {
        return makeKey(tsf.Account_vod__c, tsf.Territory_vod__c);
    }

    private String makeKeyFromCyclePlanTarget(Cycle_Plan_Target_vod__c target) {
        return makeKey(target.Cycle_Plan_Account_vod__c, target.Territory_BMS_EMEA__c);
    }


    // Goes through Cycle Plan Targets, finds the matching TSF and sets the TSF's Target = true
    // If there isn't an existing TSF, create one.
    private void processActivations(List<Cycle_Plan_Target_vod__c> activatedCyclePlanTargets) {

        // This is step 4. For activations, go through the cycle plans, and update their corresponding TSFs
        //      - set the TSF.My_Target_vod__c to be true for these cases
        //      - if there is no corresponding TSF create one

        List<TSF_vod__c> tsfInsertList = new List<TSF_vod__c>();

        for (Cycle_Plan_Target_vod__c target : activatedCyclePlanTargets) {

            Boolean tsfFound = false;

            String key = makeKeyFromCyclePlanTarget(target);

            if ( tsfUpdateMap.containsKey(key) ) {

                TSF_vod__c tsf = tsfUpdateMap.get(key);
                tsf.My_Target_vod__c = true;

            } else {

                TSF_vod__c newTSF = new TSF_vod__c(
                    Name = target.Territory_BMS_EMEA__c,
                    My_Target_vod__c = true,
                    Account_vod__c = target.Cycle_Plan_Account_vod__c,
                    Territory_vod__c = target.Territory_BMS_EMEA__c
                );
                tsfInsertList.add(newTSF);
            }

        }

        System.debug('Inserting ' + tsfInsertList.size() + ' new TSF records');

        // N.B. we insert here - as this method is only called once. (Part of step 5)
        if (tsfInsertList.size() > 0) {
            insert(tsfInsertList);
        }
    }

    /* **** end of helper functions **** */

    // 1. Sort the cycle plans of the trigger into activations and deactivations
    // 2. Get all the cycle plan targets related to the cycle plan(s)
    // 3. Get all the TSFs that relate to those cycle plan targets
    //      - update the TSF.My_Target_vod__c to be false
    //      - for deactivations, this is all that needs to be done
    // 4. For activations, go through the cycle plans, and update their corresponding TSFs
    //      - set the TSF.My_Target_vod__c to be true for these cases
    //      - if there is no corresponding TSF create one
    // 5. Write the changes back to the database

    // Cycle Plan and Territory IDs for Cycle Plans which are active and being submitted
    Set<Id> activatedCylePlanIdSet = new Set<Id>();
    Set<String> activatedTerritorySet = new Set<String>();


    // Cycle Plan and Territory IDs for Cycle Plans which are being deactivated
    Set<Id> deactivatedCylePlanIdSet = new Set<Id>();
    Set<String> deactivatedTerritorySet = new Set<String>();


    Set<String> allTerritorySet = new Set<String>();

    // Step 1 sort cycle plans
    for (Cycle_Plan_vod__c plan : trigger.new) {

        if (plan.Status_vod__c == 'Submitted_vod' && plan.Active_vod__c == true) {

            activatedCylePlanIdSet.add(plan.Id);
            activatedTerritorySet.add(plan.Territory_vod__c);
            allTerritorySet.add(plan.Territory_vod__c);

        } else {

            /*
            Cycle_Plan_vod__c oldPlan = Trigger.oldMap.get(plan.Id);
            if (
                oldPlan.Active_vod__c == true
                && ( plan.Status_vod__c != 'Submitted_vod' || plan.Active_vod__c == false )
            ) {
            */
            if ( plan.Active_vod__c == false ) {
                deactivatedCylePlanIdSet.add(plan.Id);
                deactivatedTerritorySet.add(plan.Territory_vod__c);
                allTerritorySet.add(plan.Territory_vod__c);

            }

        }
    }




    System.debug('Number of active cycle plans: ' + activatedCylePlanIdSet.size());
    System.debug('Number of inactive cycle plans: ' + deactivatedCylePlanIdSet.size());



    Boolean activatedCyclePlansExist   = activatedCylePlanIdSet.size()   > 0;
    Boolean deactivatedCyclePlansExist = deactivatedCylePlanIdSet.size() > 0;

    // If there is nothing to do, then quit.
    if (  ! (activatedCyclePlansExist || deactivatedCyclePlansExist) ) {
        return;
    }

    System.debug('Continuing...');


    // Step 2 Gather the cycle plan targets
    Set<Cycle_Plan_Target_vod__c> allCyclePlanTargetList = new Set<Cycle_Plan_Target_vod__c>();
    List<Cycle_Plan_Target_vod__c> activatedCyclePlanTargetList;
    List<Cycle_Plan_Target_vod__c> deactivatedCyclePlanTargetList;

    if ( activatedCyclePlansExist ) {
        activatedCyclePlanTargetList = getCyclePlanTargetList(activatedCylePlanIdSet, true);
        allCyclePlanTargetList.addAll(activatedCyclePlanTargetList);
    }

    if ( deactivatedCyclePlansExist ) {
        deactivatedCyclePlanTargetList = getCyclePlanTargetList(deactivatedCylePlanIdSet, false);
        allCyclePlanTargetList.addAll(deactivatedCyclePlanTargetList);
    }

    System.debug('Total number of cycle plan target list: ' + allCyclePlanTargetList.size());


    // Step 3. Get all the TSFs that relate to those cycle plan targets - update TSF.My_Target_vod__c to false
    tsfUpdateMap = getTsfUpdateMap(allCyclePlanTargetList, allTerritorySet);

    System.debug('Just got tsfUpdateMap - tsfUpdateMap.size(): ' + tsfUpdateMap.size());


    // Step 4. For activations, go through the cycle plans, and update their corresponding TSFs
    //      - set the TSF.My_Target_vod__c to be true for these cases
    //      - if there is no corresponding TSF create one
    if ( activatedCyclePlansExist ) {
        System.debug('Processing active cycle plan target list');
        processActivations(activatedCyclePlanTargetList);
    } else {
        System.debug('No active cycle plan target list to process');
    }


    System.debug('Updating ' + tsfUpdateMap.size() + ' TSF records');


    // Step 5. Write the changes back to the database
    update( tsfUpdateMap.values() );

}