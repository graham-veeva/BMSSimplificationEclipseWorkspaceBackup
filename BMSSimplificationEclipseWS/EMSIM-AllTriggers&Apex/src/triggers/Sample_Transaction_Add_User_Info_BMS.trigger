/*
 * Trigger: Sample_Transaction_Add_User_Info_BMS
 * Date: 3/4/2013
 * Author: Jeff Kelso, Veeva Systems
 * Description: 
 *   When a Sample Transaction is created or updated, write user info to the record                         
 *              
 * History:
 *  JK - 3/4/2013 - Initial Creation
 */
trigger Sample_Transaction_Add_User_Info_BMS on Sample_Transaction_vod__c (before insert) {
    //Get Record Types for Sample Transaction
    Map<Id,RecordType> sampleTransactionRTs = new Map<Id,RecordType>([SELECT DeveloperName,Id,Name,SobjectType 
                                                                      FROM RecordType 
                                                                      WHERE SobjectType = 'Sample_Transaction_vod__c']);
    //Depending on the Record Type, get the correct user
    Map<Id,Id> sampleTransactionIdToUserId = new Map<Id,Id>();
    for (Sample_Transaction_vod__c st : trigger.new) {
        RecordType rt = new RecordType();
        String userId = null;
        rt = sampleTransactionRTs.get(st.RecordTypeId);
        if (rt == null) { continue; }
        if (rt.DeveloperName == 'Adjustment_vod') {
            system.debug('JK - adding adjustment user st.Adjust_For_vod__c: ' + st.Adjust_For_vod__c);
            sampleTransactionIdToUserId.put(st.Id,st.Adjust_For_vod__c);
            userId = st.Adjust_For_vod__c;
        } else if (rt.DeveloperName == 'Disbursement_vod' || 
                   rt.DeveloperName == 'Receipt_vod' || 
                   rt.DeveloperName == 'Return_vod') {
            system.debug('JK - adding other user st.CreatedById: ' + st.CreatedById);
            sampleTransactionIdToUserId.put(st.Id,st.CreatedById);
            userId = st.CreatedById;
        } else if (rt.DeveloperName == 'Transfer_vod') {
            //sampleTransactionIdToUserId.put(st.Id,st.Transferred_From_vod__c);
            system.debug('JK - adding Transfer user st.CreatedById: ' + st.CreatedById);
            sampleTransactionIdToUserId.put(st.Id,st.CreatedById);
            userId = st.CreatedById;
        }
        if (userId == null) {
            system.debug('JK - adding current user ID: ' + UserInfo.getUserId());
            sampleTransactionIdToUserId.put(st.Id,UserInfo.getUserId());
        }
    }
    system.debug('JK - sampleTransactionToUserId: ' + sampleTransactionIdToUserId);

    //Get user details
    Map<Id,User> userIdToUser = new Map<Id,User>([SELECT BMS_Code_ID_BMS_SHARED__c,
                                                         Sales_Force_Name_BMS_SHARED__c,
                                                         Territory_Business_Code_BMS_SHARED__c,
                                                         Territory_Region_Code_BMS_SHARED__c,
                                                         Territory_Type_BMS_SHARED__c,
                                                         Region_ID_BMS_SHARED__c,
                                                         BMS_Territory_ID_BMS_SHARED__c,
                                                         Sales_Force_ID_BMS_SHARED__c,
                                                         Territory_Function_Code_BMS_SHARED__c,
                                                         Territory_Sales_Area_Code_BMS_SHARED__c,
                                                         Territory_Intelligent_ID_BMS_SHARED__c,
                                                         District_ID_BMS_SHARED__c 
                                                  FROM User
                                                  WHERE Id IN :sampleTransactionIdToUserId.values()]);
    
    system.debug('JK - userIdToUser: ' + userIdToUser);
    
    //For each sample transaction find the user and write new user detials
    for (Sample_Transaction_vod__c st : trigger.new) {
        //get user Id
        Id uid = sampleTransactionIdToUserId.get(st.Id);
        system.debug('JK - uid: ' + uid);
        //get user
        User u = userIdToUser.get(uid);
        system.debug('JK - user: ' +  u);
        //update values on sample transaction with user's info
        st.BMS_Code_ID_BMS_SHARED__c = u.BMS_Code_ID_BMS_SHARED__c;
        st.Sales_Force_Name_BMS_SHARED__c = u.Sales_Force_Name_BMS_SHARED__c;
        st.Territory_Business_Code_BMS_SHARED__c = u.Territory_Business_Code_BMS_SHARED__c;
        st.Territory_Region_Code_BMS_SHARED__c = u.Territory_Region_Code_BMS_SHARED__c;
        st.Territory_Type_BMS_SHARED__c = u.Territory_Type_BMS_SHARED__c;
        st.Region_ID_BMS_SHARED__c = u.Region_ID_BMS_SHARED__c;
        st.BMS_Territory_ID_BMS_SHARED__c = u.BMS_Territory_ID_BMS_SHARED__c;
        st.Sales_Force_ID_BMS_SHARED__c = u.Sales_Force_ID_BMS_SHARED__c;
        st.Territory_Function_Code_BMS_SHARED__c = u.Territory_Function_Code_BMS_SHARED__c; 
        st.Territory_Sales_Area_Code_BMS_SHARED__c = u.Territory_Sales_Area_Code_BMS_SHARED__c;
        st.Territory_Intelligent_ID_BMS_SHARED__c = u.Territory_Intelligent_ID_BMS_SHARED__c;
        st.District_ID_BMS_SHARED__c = u.District_ID_BMS_SHARED__c;
    }
}