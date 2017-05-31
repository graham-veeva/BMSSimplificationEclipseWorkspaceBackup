/*
 * BMS_EMEA_MasterFile_Rollup
 *
 * Author: Raphael Krausz <raphael.krausz@veeva.com>
 * Date: 2014-12-15
 * Description:
 *
 *      When a call is planned or saved:
 *          - The master file's Total_Planned_Cost_BMS_EMEA__c has the call's total cost
 *          added to it
 *          - The month's total planned rollup has 1 added to it
 *
 *      Once a call is submitted:
 *          - The master file's Total_Actual_Cost_BMS_EMEA__c has the call's total cost
 *          added to it
 *          - The month's total completed rollup has 1 added to it
 *
 *      When a call is no longer planned/saved (e.g. deleted or submitted)
 *          - The master file's Total_Planned_Cost_BMS_EMEA__c has the call's total cost
 *          subtracted from it
 *          - The month's total planned rollup has 1 subtracted from it
 *
 *      When a call is no longer submitted (e.g. deleted or downgraded to planned or saved)
 *          - The master file's Total_Actual_Cost_BMS_EMEA__c has the call's total cost
 *          subtracted from it
 *          - The month's total completed rollup has 1 subtracted from it
 *
 *
 *      N.B. Interactions/Calls are to be counted, this is not represented by a Call2_vod__c
 *      row, but each row represents a call attendee. The row without a Parent_call_vod__c
 *      represents a single meeting to be counted.
 *
 *
 *      This is done in a batch context due to the expenses line being written after the call
 *      is written. (This was originally a trigger on the Call2_vod__c object)
 *
 *      As such each master file has it's totals calculated all together.
 *
 */
global class BMS_EMEA_MasterFile_Rollup
    implements Database.Batchable<Master_File_BMS_EMEA__c> {

    private static final String SUBMITTED = 'Submitted_vod';
    private static final String PLANNED   = 'Planned_vod';
    private static final String SAVED     = 'Saved_vod';

    global Iterable<Master_File_BMS_EMEA__c> start(Database.BatchableContext BC) {

        // We first find all interactions and related expenses that have changed
        // in the last two days - including any deletions.

        // N.B. An expense may have changed or been deleted but not the interaction
        // or vice versa

        // The ALL ROWS option in SOQL includes deleted records.

        // First find all the expenses that have changed in the last two days.
        List<Call2_Expense_vod__c> modifiedExpenses =
            [
                SELECT Call2_vod__c
                FROM Call2_Expense_vod__c
                WHERE (
                    LastModifiedDate = LAST_N_DAYS:2
                            AND Call2_vod__r.Master_File_BMS_EMEA__c != null
                )
                ALL ROWS
            ];

        Set<Id> interactonIdSetFromExpenses = new Set<Id>();
        for (Call2_Expense_vod__c expense : modifiedExpenses) {
            interactonIdSetFromExpenses.add(expense.Call2_vod__c);
        }

        // Find all interactions which have a master file, and were eiher:
        //      a) modified in the last two days; or
        //      b) have a related expense which was modified in the last two days
        List<Call2_vod__c> modifiedInteractions =
            [
                SELECT
                Id,
                Master_File_BMS_EMEA__c
                FROM Call2_vod__c
                WHERE Master_File_BMS_EMEA__c != null
                AND (
                    LastModifiedDate = LAST_N_DAYS:2
                                       OR Id IN :interactonIdSetFromExpenses
                )
                ALL ROWS
            ];

        Set<Id> masterFileIdSet = new Set<Id>();
        for (Call2_vod__c interaction : modifiedInteractions) {
            Id masterFileId = interaction.Master_File_BMS_EMEA__c;
            masterFileIdSet.add(masterFileId);
        }

        // Grab those master files and return them for processing by the execute method
        List<Master_File_BMS_EMEA__c> masterFiles =
            [
                SELECT
                Id,

                Total_Planned_Cost_BMS_EMEA__c,
                Total_Actual_Cost_BMS_EMEA__c,

                RollUp_Jan_Planned_BMS_EMEA__c,
                RollUp_Feb_Planned_BMS_EMEA__c,
                RollUp_Mar_Planned_BMS_EMEA__c,
                RollUp_Apr_Planned_BMS_EMEA__c,
                RollUp_May_Planned_BMS_EMEA__c,
                RollUp_Jun_Planned_BMS_EMEA__c,
                RollUp_Jul_Planned_BMS_EMEA__c,
                RollUp_Aug_Planned_BMS_EMEA__c,
                RollUp_Sep_Planned_BMS_EMEA__c,
                RollUp_Oct_Planned_BMS_EMEA__c,
                RollUp_Nov_Planned_BMS_EMEA__c,
                RollUp_Dec_Planned_BMS_EMEA__c,

                RollUp_Jan_Completed_BMS_EMEA__c,
                RollUp_Feb_Completed_BMS_EMEA__c,
                RollUp_Mar_Completed_BMS_EMEA__c,
                RollUp_Apr_Completed_BMS_EMEA__c,
                RollUp_May_Completed_BMS_EMEA__c,
                RollUp_Jun_Completed_BMS_EMEA__c,
                RollUp_Jul_Completed_BMS_EMEA__c,
                RollUp_Aug_Completed_BMS_EMEA__c,
                RollUp_Sep_Completed_BMS_EMEA__c,
                RollUp_Oct_Completed_BMS_EMEA__c,
                RollUp_Nov_Completed_BMS_EMEA__c,
                RollUp_Dec_Completed_BMS_EMEA__c

                FROM Master_File_BMS_EMEA__c
                WHERE Id in :masterFileIdSet
            ];

        return masterFiles;

    }

    global void execute(
        Database.BatchableContext BC, List<Master_File_BMS_EMEA__c> masterFileList
    ) {
        // List<Call2_vod__c> interactionList) {

        // Here's what we are going to do:
        // 1. Get all the interactions and related expenses
        // 2. Map all master File ids to interactions
        // 3. For each master file calculate (for each month)
        //      a) the number of planned calls
        //      b) the number of completed calls
        //      c) the planned expenses
        //      d) the actual expenses
        // 4. Write those calculations back to the master file

        // 1. Get all the interactions and related expenses
        // 2. Map all master File ids to interactions
        Map<Id, Set<Call2_vod__c>>  masterFileIdToInteractionSetMap =
            getMasterFileIdToInteractionSetMap(masterFileList);


        // 3. For each master file calculate (for each month)
        //      a) the number of planned calls
        //      b) the number of completed calls
        //      c) the planned expenses
        //      d) the actual expenses
        List<Master_File_BMS_EMEA__c> masterFilesToUpdate =
            calculateMasterFiles(masterFileList, masterFileIdToInteractionSetMap);

        // 4. Write those calculations back to the master file
        if (masterFilesToUpdate.size() > 0) {
            update masterFilesToUpdate;
        }

    }

    private Map<Id, Set<Call2_vod__c>> getMasterFileIdToInteractionSetMap(
        List<Master_File_BMS_EMEA__c> masterFileList
    ) {
        Map<Id, Set<Call2_vod__c>>  masterFileIdToInteractionSetMap =
            new Map<Id, Set<Call2_vod__c>>();

        for (Master_File_BMS_EMEA__c masterFile : masterFileList) {
            Id masterFileId = masterFile.Id;
            masterFileIdToInteractionSetMap.put(masterFileId, new Set<Call2_vod__c>());
        }

        Set<Id> masterFileIdSet = masterFileIdToInteractionSetMap.keySet();

        List<Call2_vod__c> interactionList =
            [
                SELECT
                Id,
                Status_vod__c,
                Master_File_BMS_EMEA__c,
                Call_Date_vod__c,
                Parent_Call_vod__c,
                (
                    SELECT
                    Id,
                    Call2_vod__c,
                    Amount_vod__c
                    FROM Call2_Expense_vod__r
                )
                FROM Call2_vod__c
                WHERE Master_File_BMS_EMEA__c IN :masterFileIdSet
            ];

        for (Call2_vod__c interaction : interactionList) {
            Id masterFileId = interaction.Master_File_BMS_EMEA__c;
            Set<Call2_vod__c> interactionSet =
                masterFileIdToInteractionSetMap.get(masterFileId);

            interactionSet.add(interaction);
        }


        return masterFileIdToInteractionSetMap;
    }


    private void resetMasterFile(Master_File_BMS_EMEA__c masterFile) {
        masterFile.Total_Planned_Cost_BMS_EMEA__c = 0.0;
        masterFile.Total_Actual_Cost_BMS_EMEA__c  = 0.0;

        masterFile.RollUp_Jan_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_Jan_Completed_BMS_EMEA__c = 0;

        masterFile.RollUp_Feb_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_Feb_Completed_BMS_EMEA__c = 0;

        masterFile.RollUp_Mar_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_Mar_Completed_BMS_EMEA__c = 0;

        masterFile.RollUp_Apr_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_Apr_Completed_BMS_EMEA__c = 0;

        masterFile.RollUp_May_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_May_Completed_BMS_EMEA__c = 0;

        masterFile.RollUp_Jun_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_Jun_Completed_BMS_EMEA__c = 0;

        masterFile.RollUp_Jul_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_Jul_Completed_BMS_EMEA__c = 0;

        masterFile.RollUp_Aug_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_Aug_Completed_BMS_EMEA__c = 0;

        masterFile.RollUp_Sep_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_Sep_Completed_BMS_EMEA__c = 0;

        masterFile.RollUp_Oct_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_Oct_Completed_BMS_EMEA__c = 0;

        masterFile.RollUp_Nov_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_Nov_Completed_BMS_EMEA__c = 0;

        masterFile.RollUp_Dec_Planned_BMS_EMEA__c   = 0;
        masterFile.RollUp_Dec_Completed_BMS_EMEA__c = 0;
    }



    private List<Master_File_BMS_EMEA__c> calculateMasterFiles(
        List<Master_File_BMS_EMEA__c> masterFileList,
        Map<Id, Set<Call2_vod__c>> masterFileIdToInteractionSetMap
    ) {


        for (Master_File_BMS_EMEA__c masterFile : masterFileList) {
            resetMasterFile(masterFile);

            Set<Call2_vod__c> interactionSet =
                masterFileIdToInteractionSetMap.get(masterFile.Id);


            for (Call2_vod__c interaction : interactionSet) {
                String status = interaction.Status_vod__c;

                Boolean isPlanned =
                    status.equalsIgnoreCase(PLANNED) || status.equalsIgnoreCase(SAVED);
                Boolean isCompleted = status.equalsIgnoreCase(SUBMITTED);

                if ( ! ( isPlanned || isCompleted ) ) {
                    continue;
                }

                Integer month = interaction.Call_Date_vod__c.month();
                // 1 - January, 12 - December

                Decimal newCost = getInteractionCost(interaction);

                Boolean isParentCall = interaction.Parent_Call_vod__c == null;

                if ( isPlanned ) {

                    if ( isParentCall ) {
                        Integer currentPlanned = getMonthlyPlannedNumber(masterFile, month);
                        Integer newTotalPlanned = currentPlanned + 1;
                        setMonthlyPlannedNumber(masterFile, month, newTotalPlanned);
                    }

                    Decimal currentCost = masterFile.Total_Planned_Cost_BMS_EMEA__c;
                    Decimal newTotalCost = currentCost + newCost;
                    masterFile.Total_Planned_Cost_BMS_EMEA__c = newTotalCost;

                } else {
                    // isCompleted is true

                    if ( isParentCall ) {
                        Integer currentCompleted =
                            getMonthlyCompletedNumber(masterFile, month);
                        Integer newTotalCompleted = currentCompleted + 1;
                        setMonthlyCompletedNumber(masterFile, month, newTotalCompleted);
                    }

                    Decimal currentCost = masterFile.Total_Actual_Cost_BMS_EMEA__c;
                    Decimal newTotalCost = currentCost + newCost;
                    masterFile.Total_Actual_Cost_BMS_EMEA__c = newTotalCost;

                }

            }

        }


        return masterFileList;
    }

    Decimal getInteractionCost(Call2_vod__c interaction) {
        Decimal totalCost = 0.0;

        for (Call2_Expense_vod__c expense : interaction.Call2_Expense_vod__r) {
            Decimal newCost = expense.Amount_vod__c;
            totalCost += newCost;
        }

        return totalCost;
    }

    Integer getMonthlyPlannedNumber(Master_File_BMS_EMEA__c masterFile, Integer month) {

        Integer returnValue;

        if (month == 1) {
            returnValue = (Integer) masterFile.RollUp_Jan_Planned_BMS_EMEA__c;
        } else if (month == 2) {
            returnValue = (Integer) masterFile.RollUp_Feb_Planned_BMS_EMEA__c;
        } else if (month == 3) {
            returnValue = (Integer) masterFile.RollUp_Mar_Planned_BMS_EMEA__c;
        } else if (month == 4) {
            returnValue = (Integer) masterFile.RollUp_Apr_Planned_BMS_EMEA__c;
        } else if (month == 5) {
            returnValue = (Integer) masterFile.RollUp_May_Planned_BMS_EMEA__c;
        } else if (month == 6) {
            returnValue = (Integer) masterFile.RollUp_Jun_Planned_BMS_EMEA__c;
        } else if (month == 7) {
            returnValue = (Integer) masterFile.RollUp_Jul_Planned_BMS_EMEA__c;
        } else if (month == 8) {
            returnValue = (Integer) masterFile.RollUp_Aug_Planned_BMS_EMEA__c;
        } else if (month == 9) {
            returnValue = (Integer) masterFile.RollUp_Sep_Planned_BMS_EMEA__c;
        } else if (month == 10) {
            returnValue = (Integer) masterFile.RollUp_Oct_Planned_BMS_EMEA__c;
        } else if (month == 11) {
            returnValue = (Integer) masterFile.RollUp_Nov_Planned_BMS_EMEA__c;
        } else if (month == 12) {
            returnValue = (Integer) masterFile.RollUp_Dec_Planned_BMS_EMEA__c;
        }

        if (returnValue == null) {
            returnValue = 0;
        }

        return returnValue;
    }

    void setMonthlyPlannedNumber(
        Master_File_BMS_EMEA__c masterFile, Integer month, Integer theNumber) {

        if (month == 1) {
            masterFile.RollUp_Jan_Planned_BMS_EMEA__c = theNumber;
        } else if (month == 2) {
            masterFile.RollUp_Feb_Planned_BMS_EMEA__c = theNumber;
        } else if (month == 3) {
            masterFile.RollUp_Mar_Planned_BMS_EMEA__c = theNumber;
        } else if (month == 4) {
            masterFile.RollUp_Apr_Planned_BMS_EMEA__c = theNumber;
        } else if (month == 5) {
            masterFile.RollUp_May_Planned_BMS_EMEA__c = theNumber;
        } else if (month == 6) {
            masterFile.RollUp_Jun_Planned_BMS_EMEA__c = theNumber;
        } else if (month == 7) {
            masterFile.RollUp_Jul_Planned_BMS_EMEA__c = theNumber;
        } else if (month == 8) {
            masterFile.RollUp_Aug_Planned_BMS_EMEA__c = theNumber;
        } else if (month == 9) {
            masterFile.RollUp_Sep_Planned_BMS_EMEA__c = theNumber;
        } else if (month == 10) {
            masterFile.RollUp_Oct_Planned_BMS_EMEA__c = theNumber;
        } else if (month == 11) {
            masterFile.RollUp_Nov_Planned_BMS_EMEA__c = theNumber;
        } else if (month == 12) {
            masterFile.RollUp_Dec_Planned_BMS_EMEA__c = theNumber;
        }

    }

    Integer getMonthlyCompletedNumber(Master_File_BMS_EMEA__c masterFile, Integer month) {

        Integer returnValue;

        if (month == 1) {
            returnValue = (Integer) masterFile.RollUp_Jan_Completed_BMS_EMEA__c;
        } else if (month == 2) {
            returnValue = (Integer) masterFile.RollUp_Feb_Completed_BMS_EMEA__c;
        } else if (month == 3) {
            returnValue = (Integer) masterFile.RollUp_Mar_Completed_BMS_EMEA__c;
        } else if (month == 4) {
            returnValue = (Integer) masterFile.RollUp_Apr_Completed_BMS_EMEA__c;
        } else if (month == 5) {
            returnValue = (Integer) masterFile.RollUp_May_Completed_BMS_EMEA__c;
        } else if (month == 6) {
            returnValue = (Integer) masterFile.RollUp_Jun_Completed_BMS_EMEA__c;
        } else if (month == 7) {
            returnValue = (Integer) masterFile.RollUp_Jul_Completed_BMS_EMEA__c;
        } else if (month == 8) {
            returnValue = (Integer) masterFile.RollUp_Aug_Completed_BMS_EMEA__c;
        } else if (month == 9) {
            returnValue = (Integer) masterFile.RollUp_Sep_Completed_BMS_EMEA__c;
        } else if (month == 10) {
            returnValue = (Integer) masterFile.RollUp_Oct_Completed_BMS_EMEA__c;
        } else if (month == 11) {
            returnValue = (Integer) masterFile.RollUp_Nov_Completed_BMS_EMEA__c;
        } else if (month == 12) {
            returnValue = (Integer) masterFile.RollUp_Dec_Completed_BMS_EMEA__c;
        }

        if (returnValue == null) {
            returnValue = 0;
        }

        return returnValue;
    }

    void setMonthlyCompletedNumber(
        Master_File_BMS_EMEA__c masterFile, Integer month, Integer theNumber
    ) {
        if (month == 1) {
            masterFile.RollUp_Jan_Completed_BMS_EMEA__c = theNumber;
        } else if (month == 2) {
            masterFile.RollUp_Feb_Completed_BMS_EMEA__c = theNumber;
        } else if (month == 3) {
            masterFile.RollUp_Mar_Completed_BMS_EMEA__c = theNumber;
        } else if (month == 4) {
            masterFile.RollUp_Apr_Completed_BMS_EMEA__c = theNumber;
        } else if (month == 5) {
            masterFile.RollUp_May_Completed_BMS_EMEA__c = theNumber;
        } else if (month == 6) {
            masterFile.RollUp_Jun_Completed_BMS_EMEA__c = theNumber;
        } else if (month == 7) {
            masterFile.RollUp_Jul_Completed_BMS_EMEA__c = theNumber;
        } else if (month == 8) {
            masterFile.RollUp_Aug_Completed_BMS_EMEA__c = theNumber;
        } else if (month == 9) {
            masterFile.RollUp_Sep_Completed_BMS_EMEA__c = theNumber;
        } else if (month == 10) {
            masterFile.RollUp_Oct_Completed_BMS_EMEA__c = theNumber;
        } else if (month == 11) {
            masterFile.RollUp_Nov_Completed_BMS_EMEA__c = theNumber;
        } else if (month == 12) {
            masterFile.RollUp_Dec_Completed_BMS_EMEA__c = theNumber;
        }
    }

    global void finish(Database.BatchableContext BC) {
    }

}