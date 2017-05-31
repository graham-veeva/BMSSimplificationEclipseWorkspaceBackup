trigger VOD_EM_SPEAKER_BEFORE_INS_UPD on EM_Speaker_vod__c (before insert, before update) {
    Set<String> accountSet = new Set<String>();
    Map<String, Account> accountMap = new Map<String, Account>();

    for (EM_Speaker_vod__c speaker : Trigger.new) {
        String account = speaker.Account_vod__c;
        if (account != null) {
            accountSet.add(account);
        }
    }

    for (Account account : [SELECT Id, Formatted_Name_vod__c, FirstName, LastName, Credentials_vod__c, PersonTitle, Furigana_vod__c
                            FROM Account
                            WHERE Id IN :accountSet]) {
        accountMap.put(account.Id, account);
    }

    for (EM_Speaker_vod__c speaker : Trigger.new) {
        if (speaker.Account_vod__c != null) {
            Account account = accountMap.get(speaker.Account_vod__c);
            String name = account.Formatted_Name_vod__c;
            if(name != null && name.length() > 80) {
            	speaker.Name = name.subString(0,80);
            } else {
                speaker.Name = name;
            }
            speaker.First_Name_vod__c = account.FirstName;
            speaker.Last_Name_vod__c = account.LastName;
            speaker.Credentials_vod__c = account.Credentials_vod__c;
            speaker.Title_vod__c = account.PersonTitle;
            speaker.Furigana_vod__c = account.Furigana_vod__c;
        }
    }
}