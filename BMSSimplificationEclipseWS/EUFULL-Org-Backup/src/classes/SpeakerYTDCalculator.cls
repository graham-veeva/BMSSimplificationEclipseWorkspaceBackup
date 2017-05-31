public class SpeakerYTDCalculator {
	
    public static void calculate(Set<Id> speakerIds) {
        if(System.isFuture() || System.isBatch()) {
        	calculateSync(speakerIds);  
        } else {
        	calculateFuture(speakerIds);  
        }
    }
    
    @future
    public static void calculateFuture(Set<Id> speakerIds) {
        calculateSync(speakerIds);
    }
    
    public static Set<String> getSpeakerStatuses() {   	
        List<String> speakerSetting = new List<String>();
        Set<String> speakerStatuses = new Set<String>();
        Events_Management_Settings_vod__c emSetting = Events_Management_Settings_vod__c.getInstance();
        if(emSetting != null && emSetting.SPEAKER_ROLLUP_STATUS_FILTER_vod__c != null) {
        	speakerSetting = emSetting.SPEAKER_ROLLUP_STATUS_FILTER_vod__c.split(';;');
            String name = speakerSetting.get(0);
            String category = speakerSetting.get(1);
            if(speakerSetting.size() == 2) {
                List<Message_vod__c> speakerStatusesMessage = [SELECT Text_vod__c 
                                                               FROM Message_vod__c
                                                               WHERE Active_vod__c = true
                                                               AND NAME = :name
                                                               AND Category_vod__c = :category
                                                               AND Language_vod__c = 'en_US'];
                if(speakerStatusesMessage.size() > 0 && speakerStatusesMessage.get(0).Text_vod__c != null) {
                    speakerStatuses = new Set<String>(speakerStatusesMessage.get(0).Text_vod__c.split(','));
                }
            }
        }
        
        if(speakerStatuses.isEmpty()) {
            speakerStatuses.add('Attended_vod');
            speakerStatuses.add('Signed_vod');
        }    
        return speakerStatuses;
    }
    
    public static void calculateSync(Set<Id> speakerIds) {
        boolean multiCurrency = MultiCurrencyUtil.isMultiCurrencyOrg();
        Map<Id, Account> accounts = new Map<Id, Account>();
        for(Account account: [SELECT Id, (SELECT Id FROM EM_Speaker_vod__r) FROM Account WHERE Id IN (SELECT Account_vod__c FROM EM_Speaker_vod__c WHERE Id IN :speakerIds)]) {
       		accounts.put(account.Id, account);
        }

        Map<Id,EM_Speaker_vod__c> speakersToUpdate = new Map<Id,EM_Speaker_vod__c>();

        Integer defaultDay = Integer.valueOf(EM_Speaker_vod__c.Year_To_Date_Reset_Day_vod__c.getDescribe().getDefaultValue());
        Integer defaultMonth = Integer.valueOf(EM_Speaker_vod__c.Year_To_Date_Reset_Month_vod__c.getDescribe().getDefaultValue());

		Set<String> speakerStatuses = getSpeakerStatuses();

        Map<Id, String> speakerIdToIsoCode = new Map<Id,String>();

        if(multiCurrency) {
        	List<EM_Speaker_vod__c> speakersWithIsoCode = Database.query('SELECT CurrencyIsoCode, Id FROM EM_Speaker_vod__c WHERE Id IN ' + MultiCurrencyUtil.toCommaSeperated(speakerIds));
            for(EM_Speaker_vod__c speaker: speakersWithIsoCode) {
                speakerIdtoIsoCode.put(speaker.Id, (String)speaker.get('CurrencyIsoCode'));
            }
        }


        for(Id speakerId: speakerIds) {
            EM_Speaker_vod__c speaker = new EM_Speaker_vod__c(Id=speakerId, Year_to_Date_Utilization_vod__c = 0, Year_to_Date_Spend_vod__c = 0);
            if(multiCurrency) {
            	speaker.put('CurrencyIsoCode', speakerIdtoIsoCode.get(speakerId));
            }
            speakersToUpdate.put(speakerId, speaker);
        }

        Set<Id> relevantEvents = new Set<Id>();

        Date minimumDate = Date.newInstance(System.Today().year()-1, 1, 1);
        Date maximumDate = Date.newInstance(System.Today().year()+1, 12, 31);

        List<EM_Event_Speaker_vod__c> eventSpeakers;

        if(multiCurrency) {
            Datetime minDatetime = datetime.newInstance(minimumDate.year(), minimumDate.month(),minimumDate.day());
			Datetime maxDatetime = datetime.newInstance(maximumDate.year(), maximumDate.month(),maximumDate.day());

            String datetimeFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';

            String formattedMin = minDateTime.formatGmt(datetimeFormat);
            String formattedMax = maxDatetime.formatGmt(datetimeFormat);

        	eventSpeakers = Database.query('SELECT Id, CurrencyIsoCode, Event_vod__c, Event_vod__r.Status_vod__c, Event_vod__r.Start_Time_vod__c, Status_vod__c, ' +
                                                       ' Speaker_vod__c, Speaker_vod__r.Year_To_Date_Reset_Day_vod__c, Speaker_vod__r.Year_To_Date_Reset_Month_vod__c' +
                                                       ' FROM EM_Event_Speaker_vod__c ' +
                                                       ' WHERE Speaker_vod__c IN ' + MultiCurrencyUtil.toCommaSeperated(speakerIds) +
                                                       ' AND Event_vod__r.Status_vod__c != \'Canceled_vod\'' +
                                                       ' AND Event_vod__r.Start_Time_vod__c >= ' + formattedMin +
                                                       ' AND Event_vod__r.Start_Time_vod__c <= ' + formattedMax);
        } else {
        	eventSpeakers = [SELECT Id, Event_vod__c, Event_vod__r.Status_vod__c, Event_vod__r.Start_Time_vod__c, Status_vod__c,
                                                       Speaker_vod__c, Speaker_vod__r.Year_To_Date_Reset_Day_vod__c, Speaker_vod__r.Year_To_Date_Reset_Month_vod__c
                                                       FROM EM_Event_Speaker_vod__c
                                                       WHERE Speaker_vod__c IN :speakerIds
                                                       AND Event_vod__r.Status_vod__c != 'Canceled_vod'
                                                       AND Event_vod__r.Start_Time_vod__c >= :minimumDate
                                                       AND Event_vod__r.Start_Time_vod__c <= :maximumDate];
        }


        for(EM_Event_Speaker_vod__c eventSpeaker: eventSpeakers) {

            EM_Speaker_vod__c speaker = speakersToUpdate.get(eventSpeaker.Speaker_vod__c);

            Integer day = eventSpeaker.Speaker_vod__r.Year_To_Date_Reset_Day_vod__c != null ? Integer.valueOf(eventSpeaker.Speaker_vod__r.Year_To_Date_Reset_Day_vod__c): defaultDay;
            Integer month = eventSpeaker.Speaker_vod__r.Year_To_Date_Reset_Month_vod__c != null ? Integer.valueOf(eventSpeaker.Speaker_vod__r.Year_To_Date_Reset_Month_vod__c): defaultMonth;
            Date currentResetDate = Date.newInstance(System.today().year(), month, day);
            Date startConstraint;
            Date endConstraint;

            if(System.today() < currentResetDate) {
            	startconstraint = Date.newInstance(currentResetDate.year()-1, month, day);
                endConstraint = currentResetDate;
            } else {
            	startconstraint = currentResetDate ;
                endConstraint = Date.newInstance(currentResetDate.year()+1, month, day);
            }

            if(eventSpeaker.Event_vod__r.Start_Time_vod__c >= startconstraint
               && eventSpeaker.Event_vod__r.Start_Time_vod__c < endConstraint) {
                   relevantEvents.add(eventSpeaker.Event_vod__c);
                   if(speakerStatuses.contains(eventSpeaker.Status_vod__c)) {
                   		speaker.Year_to_Date_Utilization_vod__c++;
                   }
            }
        }

        List<Expense_Line_vod__c> expenseLines;

        if(multiCurrency) {
            String query = 'SELECT CurrencyIsoCode, Actual_vod__c, Expense_Header_vod__r.Incurred_Expense_Speaker_vod__r.Speaker_vod__c,' +
                            ' Expense_Header_vod__r.Incurred_Expense_Account_vod__c, Expense_Header_vod__r.Incurred_Expense_Attendee_vod__r.Account_vod__c ' +
                            ' FROM Expense_Line_vod__c ' +
                            ' WHERE Event_vod__c IN ' + MultiCurrencyUtil.toCommaSeperated(relevantEvents) +
                            ' AND (';

                            if(!accounts.keySet().isEmpty()) {
                            	query += 'Expense_Header_vod__r.Incurred_Expense_Account_vod__c IN ' + MultiCurrencyUtil.toCommaSeperated(accounts.keySet());
                            } else {
                                query += 'Id != \'_______________\'';
                            }
            				query +=' OR ';

            				if(!accounts.keySet().isEmpty()) {
                            	query += 'Expense_Header_vod__r.Incurred_Expense_Speaker_vod__r.Speaker_vod__c IN ' + MultiCurrencyUtil.toCommaSeperated(speakerIds);
                            } else {
                                query += 'Id != \'_______________\'';
                            }
            				query +=' OR ';

            				if(!accounts.keySet().isEmpty()) {
                            	query += 'Expense_Header_vod__r.Incurred_Expense_Attendee_vod__r.Account_vod__c IN ' + MultiCurrencyUtil.toCommaSeperated(accounts.keySet());
                            } else {
                                query += 'Id != \'_______________\'';
                            }

                            query += ') AND Expense_Type_vod__r.Included_In_Speaker_Cap_vod__c = true';

            SYSTEM.debug('QUERY: ' + query);

        	expenseLines = Database.query(query);
        } else {
            expenseLines = [SELECT Actual_vod__c, Expense_Header_vod__r.Incurred_Expense_Speaker_vod__r.Speaker_vod__c,
                            Expense_Header_vod__r.Incurred_Expense_Account_vod__c, Expense_Header_vod__r.Incurred_Expense_Attendee_vod__r.Account_vod__c
                            FROM Expense_Line_vod__c
                            WHERE Event_vod__c IN :relevantEvents
                            AND (Expense_Header_vod__r.Incurred_Expense_Account_vod__c IN :accounts.keySet() OR
                                 Expense_Header_vod__r.Incurred_Expense_Speaker_vod__r.Speaker_vod__c IN :speakerIds OR
                                 Expense_Header_vod__r.Incurred_Expense_Attendee_vod__r.Account_vod__c IN :accounts.keySet())
                            AND Expense_Type_vod__r.Included_In_Speaker_Cap_vod__c = true];
        }

        for(Expense_Line_vod__c expense : expenseLines) {
            if(expense.Expense_Header_vod__r.Incurred_Expense_Speaker_vod__r.Speaker_vod__c != null) {
            	EM_Speaker_vod__c speaker = speakersToUpdate.get(expense.Expense_Header_vod__r.Incurred_Expense_Speaker_vod__r.Speaker_vod__c);

                addActual(speaker, expense, multiCurrency);
            } else if (expense.Expense_Header_vod__r.Incurred_Expense_Account_vod__c != null) {
                Account account = accounts.get(expense.Expense_Header_vod__r.Incurred_Expense_Account_vod__c);
                if(account.EM_Speaker_vod__r != null && !account.EM_Speaker_vod__r.isEmpty()) {
                    EM_Speaker_vod__c updateSpeaker = account.EM_Speaker_vod__r;
                    EM_Speaker_vod__c speaker = speakersToUpdate.get(updateSpeaker.Id);

            		addActual(speaker, expense, multiCurrency);
                }
            } else if (expense.Expense_Header_vod__r.Incurred_Expense_Attendee_vod__r.Account_vod__c != null) {
            	Account account = accounts.get(expense.Expense_Header_vod__r.Incurred_Expense_Attendee_vod__r.Account_vod__c);
                if(account.EM_Speaker_vod__r != null && !account.EM_Speaker_vod__r.isEmpty()) {
                    EM_Speaker_vod__c updateSpeaker = account.EM_Speaker_vod__r;
                    EM_Speaker_vod__c speaker = speakersToUpdate.get(updateSpeaker.Id);

            		addActual(speaker, expense, multiCurrency);
                }
            }
		}

        List<Expense_Attribution_vod__c> attributions = [SELECT Actual_vod__c, Incurred_Expense_Account_vod__c, Incurred_Expense_Speaker_vod__r.Speaker_vod__c, Incurred_Expense_Attendee_vod__r.Account_vod__c
                                                        FROM Expense_Attribution_vod__c
                                                        WHERE Expense_Line_vod__r.Event_vod__c IN :relevantEvents
                                                        AND Expense_Line_vod__r.Expense_Type_vod__r.Included_In_Speaker_Cap_vod__c = true
                                                        ANd Expense_Line_vod__r.Expense_Header_vod__r.Split_Lines_vod__c = 'Yes_vod'
                                                        AND (Incurred_Expense_Account_vod__c IN :accounts.keySet() OR
                                                             Incurred_Expense_Attendee_vod__r.Account_vod__c IN :accounts.keySet() OR
                                                             Incurred_Expense_Speaker_vod__r.Speaker_vod__c IN :speakerIds)];

        for(Expense_Attribution_vod__c attr: attributions) {
            if(attr.Incurred_Expense_Speaker_vod__r.Speaker_vod__c != null) {
            	EM_Speaker_vod__c speaker = speakersToUpdate.get(attr.Incurred_Expense_Speaker_vod__r.Speaker_vod__c);

                addActual(speaker, attr, multiCurrency);
            } else if (attr.Incurred_Expense_Account_vod__c != null) {
                Account account = accounts.get(attr.Incurred_Expense_Account_vod__c);
                if(account.EM_Speaker_vod__r != null && !account.EM_Speaker_vod__r.isEmpty()) {
                    EM_Speaker_vod__c updateSpeaker = account.EM_Speaker_vod__r;
                    EM_Speaker_vod__c speaker = speakersToUpdate.get(updateSpeaker.Id);

            		addActual(speaker, attr, multiCurrency);
                }
            } else if (attr.Incurred_Expense_Attendee_vod__r.Account_vod__c != null) {
            	Account account = accounts.get(attr.Incurred_Expense_Attendee_vod__r.Account_vod__c);
                if(account.EM_Speaker_vod__r != null && !account.EM_Speaker_vod__r.isEmpty()) {
                    EM_Speaker_vod__c updateSpeaker = account.EM_Speaker_vod__r;
                    EM_Speaker_vod__c speaker = speakersToUpdate.get(updateSpeaker.Id);

            		addActual(speaker, attr, multiCurrency);
                }
            }
        }

        if(speakersToUpdate.values().size() > 0) {
            update speakersToUpdate.values();
        }
    }

    private static void addActual(EM_Speaker_vod__c speaker, SObject expense, Boolean multiCurrency) {
        Decimal actual = (Decimal)expense.get('Actual_vod__c');

        if(multiCurrency) {
            actual = MultiCurrencyUtil.convertCurrency((String)expense.get('CurrencyIsoCode'), (String)speaker.get('CurrencyIsoCode'), actual);
        }

        speaker.Year_to_Date_Spend_vod__c += actual;
    }
}