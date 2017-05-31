trigger BMS_CN_Co_Investigators on Clinical_Trial_Co_Investigators_BMS_CN__c (before update, before insert) {

   Set<String> accountIds = new Set<String>();

    // assumption is we will only get one of the below values per record
    for (Integer i=0; i < Trigger.new.size(); i++) {
        if (Trigger.new[i].Account__c != null) {
            accountIds.add(Trigger.new[i].Account__c);
        }
    }
            
    Map<ID,Account> accounts = null;
    if (accountIds.size() > 0) {
        accounts = new Map<ID,Account>([Select Id,Name From Account Where Id In :accountIds]);
    }
            
    for (Integer i=0; i < Trigger.new.size(); i++) {
        String InvestigatorsName = '';
        if (Trigger.new[i].Account__c != null) {
            Account acct = accounts.get(Trigger.new[i].Account__c);
            if (acct != null)
                InvestigatorsName = acct.Name;
        }
        Trigger.new[i].Co_Investigator_BMS_CN__c = InvestigatorsName;
    }    
}