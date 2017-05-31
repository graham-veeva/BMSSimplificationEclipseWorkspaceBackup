/**
 * Trigger: BMS_EMEA_Account_Tactic_name_trigger
 * Object:  Account_Tactic_vod__c
 * Author:  Raphael Krausz <raphael.krausz@veeva.com>
 * Date:    2014-05-09
 *
 * Description:
 *
 *    A trigger is needed to revert the Account Tactic Name when modified by not the CreatedBy.User
 *    Only for EMEA
 *    Need to bypass this rule for Administrators
 *
 */

trigger BMS_EMEA_Account_Tactic_revert_Name on Account_Tactic_vod__c (before update) {

  String profileId = UserInfo.getProfileId();
  Profile userProfile = [ SELECT Id, PermissionsModifyAllData FROM Profile WHERE Id = :profileId ];

  if ( userProfile != null && userProfile.PermissionsModifyAllData == true ) {
    // We allow administrators to make the changes they want
    return;
  }

  String userId = UserInfo.getUserId();

  // We need to know the RecordType names for each of the account tactics
  // This is a trigger, so make sure we limit our database interactions
  Set<Id> recordTypeIdSet = new Set<Id>();
  for (Account_Tactic_vod__c accountTactic : trigger.new) {
    recordTypeIdSet.add(accountTactic.RecordTypeId);
  }

  List<RecordType> recordTypeList = [ SELECT Id, DeveloperName FROM RecordType WHERE Id IN :recordTypeIdSet ];
  Map<Id, String> recordTypeIdToDeveloperNameMap = new Map<Id, String>();
  for (RecordType theRecordType : recordTypeList) {
    recordTypeIdToDeveloperNameMap.put(theRecordType.Id, theRecordType.DeveloperName);
  }


  // Now to go through each account tactic, and ensure the name is reset
  // if the requirements are fulfilled
  for (Account_Tactic_vod__c accountTactic : trigger.new) {

    String developerName = recordTypeIdToDeveloperNameMap.get(accountTactic.RecordTypeId);
    Boolean isEMEA = developerName.contains('EMEA_') || developerName.contains('_EMEA');
    if ( ! isEMEA ) {
      // We don't care about records that don't belong to EMEA
      continue;
    }

    if ( accountTactic.CreatedById == userId ) {
      // We allow the user who created the record to modify the Name
      continue;
    }

    // Otherwise reset the Name to what it previously was
    Account_Tactic_vod__c oldAccountTactic = trigger.oldMap.get(accountTactic.Id);
    accountTactic.Name = oldAccountTactic.Name;

  }

}