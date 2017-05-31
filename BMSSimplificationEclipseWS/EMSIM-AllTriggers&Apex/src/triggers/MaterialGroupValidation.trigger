trigger MaterialGroupValidation on Expense_Header_vod__c (before insert, before update) {
    
    /*
    ** Make sure that the Material Group on the EH is also a Material Group on the 
    ** Contract Party (either the primary or one of the secondary Material Groups)
    ** mnaidu - Feb 24, 2017 - Simplification Activities need to be escaped
    */
    
    set<id> contractPartyIDs = new set<Id>();
    
    Set<String> SIMPLE_ACTIVITIES = new Set<String> {'Simple_Activity_HCPTS'};
    
    for(Expense_Header_vod__c EH: Trigger.new){
        if(EH.Payee_Vendor_vod__c != null){
            contractPartyIDs.add(EH.Payee_Vendor_vod__c);
        }else{
            //EH.addError('A Contract Party is Required');
        }
        if(EH.Material_Group__c == null){
            //EH.addError('A Material Group is Required');
        }
    }
    
    Map<ID,EM_Vendor_vod__c> ContractPartyMap = new Map<Id,EM_Vendor_vod__c>([SELECT Id,Primary_Material_Group_HCPTS__c,Secondary_Material_Group_1_HCPTS__c,Secondary_Material_Group_2_HCPTS__c
            FROM EM_Vendor_vod__c WHERE ID IN :contractPartyIDs]);
            
    for(Expense_Header_vod__c EH: Trigger.new){
        if(EH.Event_Recordtype_Dev_Name_Simple_HCPTS__c!=null//mnaidu - Feb 24, 2017 - Simplification Activities need to be escaped
           && !SIMPLE_ACTIVITIES.contains(EH.Event_Recordtype_Dev_Name_Simple_HCPTS__c) 
           && EH.Payee_Vendor_vod__c != null 
           && EH.Material_Group__c != null){
            EM_Vendor_vod__c contractParty = ContractPartyMap.get(EH.Payee_Vendor_vod__c);
            String compare = contractParty.Primary_Material_Group_HCPTS__c + contractParty.Secondary_Material_Group_1_HCPTS__c + contractParty.Secondary_Material_Group_2_HCPTS__c;
            if(!compare.contains(EH.Material_Group__c)){
                EH.addError('The Material Group needs to also be selected as one of the material groups on the Contract Party');
            }
        }
    }    
}