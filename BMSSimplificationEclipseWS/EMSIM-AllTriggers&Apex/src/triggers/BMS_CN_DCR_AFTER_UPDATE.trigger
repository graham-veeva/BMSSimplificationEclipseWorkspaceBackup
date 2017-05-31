/*
* Name: BMS_CN_DCR_AFTER_UPDATE 
* Description: process after update record
* Author: Roy Zhang
* Created Date: 02/22/2013
* Last Modified Date: 07/10/2013
*/
trigger BMS_CN_DCR_AFTER_UPDATE on Data_Change_Request_BMS_CN__c (after update) {
    Map<String,String> depMap = New Map<String,String>();
    List<Master_Parameter_BMS_CN__c> depList = [SELECT
													Type1_BMS_CN__c,
													Type2_BMS_CN__c,
													Parameter_BMS_CN__c,
													Value_BMS_CN__c
												FROM
													Master_Parameter_BMS_CN__c
												WHERE
													Country_Code_BMS_CN__c = 'CN' AND
													Module_BMS_CN__c = 'Department' AND
													Type1_BMS_CN__c = 'zh-CN'];
	for(Master_Parameter_BMS_CN__c dep: depList) {
		depMap.put(dep.Parameter_BMS_CN__c, dep.Value_BMS_CN__c);
	}    
    
    Map<String,String> mapState = New Map<String,String>();
    mapState.put('SHH','上海');
    mapState.put('BEJ','北京');
    mapState.put('HEB','河北');
    mapState.put('TAJ','天津');
    mapState.put('SHX','山西');
    mapState.put('NMG','内蒙古');
    mapState.put('LIA','辽宁');
    mapState.put('SHD','山东');
    mapState.put('JIL','吉林');
    mapState.put('HLJ','黑龙江');
    mapState.put('JSU','江苏');
    mapState.put('ZHJ','浙江');
    mapState.put('ANH','安徽');
    mapState.put('HEN','河南');
    mapState.put('JXI','江西');
    mapState.put('HAI','海南');
    mapState.put('GUD','广东');
    mapState.put('GXI','广西');
    mapState.put('FUJ','福建');
    mapState.put('GUI','贵州');
    mapState.put('HUN','湖南');
    mapState.put('HUB','湖北');
    mapState.put('XIN','新疆');
    mapState.put('GAN','甘肃');
    mapState.put('SHA','陕西');
    mapState.put('YUN','云南');
    mapState.put('NXA','宁夏');
    mapState.put('QIH','青海');
    mapState.put('TIB','西藏');
    mapState.put('SCH','四川');
    mapState.put('CHQ','重庆');   
    
    for(integer i = 0; i < trigger.new.size(); i++) {
        Data_Change_Request_BMS_CN__c dcrNew = trigger.new[i];
        
        // Add new doctor
        if(dcrNew.Status_BMS_CN__c == 'Approved' && dcrNew.Action_Type_BMS_CN__c == 'ADD') {
            
            // Get hosptial address
            Address_vod__c hospAdd = [SELECT
                                        Id,
                                        Name,
                                        Account_vod__r.Name,
                                        City_vod__c,
                                        State_vod__c,
                                        Zip_vod__c,
                                        ADDRESS_SOURCE_COUNTRY_BMS_CORE__C
                                    FROM
                                        Address_vod__c
                                    WHERE
                                        Account_vod__r.Id =: dcrNew.Hospital_Final_BMS_CN__c AND
                                        Primary_vod__c = true
                                        LIMIT 1];
                                        
            string strAddress = '';
            if(hospAdd.State_vod__c <> null) {
                strAddress = strAddress + mapState.get(hospAdd.State_vod__c) + ' ';
            }
            if(hospAdd.City_vod__c <> null) {
                strAddress = strAddress + hospAdd.City_vod__c + ' ';
            }
            strAddress = strAddress + hospAdd.Name + ' ';
            if(hospAdd.Zip_vod__c <> null) {
                strAddress = strAddress + hospAdd.Zip_vod__c;
            }
            
            // Insert Account
            Account newDoc = new Account();
            newDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'BMS - Individual'].Id;
            newDoc.Account_Type__c = 'NRPS';
            newDoc.LastName = dcrNew.Doctor_Name_Final_BMS_CN__c;
            newDoc.BP_ID_BMS_CORE__c = dcrNew.Doctor_Code_BMS_CN__c;
            newDoc.Department_BMS_CN__c = dcrNew.Department_Final_BMS_CN__c;
            newDoc.Primary_Parent_vod__c = dcrNew.Hospital_Final_BMS_CN__c;
            newDoc.Gender_vod__c = dcrNew.Gender_Final_BMS_CN__c;
            newDoc.Administrative_Title_BMS_CN__c = dcrNew.Administrative_Title_Final_BMS_CN__c;
            newDoc.Technical_Title_BMS_CN__c = dcrNew.Technical_Title_Final_BMS_CN__c;
            newDoc.Social_Title_BMS_CN__c = dcrNew.Social_Title_Final_BMS_CN__c;
            newDoc.Account_Source_Country_BMS_CORE__c = 'CN';
            newDoc.Address_BMS_CN__c = strAddress.trim();         
            insert newDoc;
                        
            // Insert Address
            Address_vod__c newAdd = new Address_vod__c();
            newAdd.Account_vod__c = newDoc.Id;
            newAdd.Lock_vod__c = false;
            newAdd.Address_Source_Country_BMS_CORE__c = 'CN';
            newAdd.Name = hospAdd.Account_vod__r.Name + ' ' + depMap.get(dcrNew.Department_Final_BMS_CN__c);
            newAdd.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Address_vod__c' AND Name = 'BMS Address'].Id;
            newAdd.Primary_vod__c = true;           
            insert newAdd;
            
            //Insert ATL
            Account_Territory_Loader_vod__c atl = new Account_Territory_Loader_vod__c();
            atl.External_ID_vod__c = dcrNew.Doctor_Code_BMS_CN__c;
            atl.Account_vod__c = newDoc.Id;
            atl.Territory_vod__c = ';' + [SELECT Name FROM Territory WHERE Id IN (SELECT TerritoryId FROM UserTerritory WHERE UserId =: dcrNew.OwnerId)].Name + ';';
            insert atl;
            
            
            List<Patient_Tracker_BMS_CN__c> ptList = new List<Patient_Tracker_BMS_CN__c>();
            
            Integer[] shift = new Integer[]{-1,-2,-3};
            for(Integer j : shift) {
            	Patient_Tracker_BMS_CN__c pt = new Patient_Tracker_BMS_CN__c();
            	pt.Account__c = newDoc.Id;
            	pt.ETV_ARV_BMS_CN__c = 0;
            	pt.Baraclude_ETV_BMS_CN__c = 0;
            	pt.Lamivudine_ARV_BMS_CN__c = 0;
            	
            	Date nextMonth = Date.Today().addMonths(j);
	    		String s=String.ValueOf(nextMonth);
	    		String[] ymd = s.split('-', -1);
	    		pt.Cycle_Period_BMS_CN__c = ymd[0]+'/'+ymd[1];
	    		
	    		ptList.add(pt);
            }
            
            insert ptList;
            
        }
        
        // Update doctor information
        if(dcrNew.Status_BMS_CN__c == 'Approved' && dcrNew.Action_Type_BMS_CN__c == 'EDIT') {
                        
            Account acct = [SELECT
                                Id,                             
                                Gender_vod__c,
                                Department_BMS_CN__c,
                                Administrative_Title_BMS_CN__c,
                                Technical_Title_BMS_CN__c,
                                Social_Title_BMS_CN__c,
                                Primary_Parent_vod__c,
                                Address_BMS_CN__c
                            FROM
                                Account
                            WHERE
                                Id =: dcrNew.Doctor_BMS_CN__c];
            acct.Gender_vod__c = dcrNew.Gender_Final_BMS_CN__c;
            acct.Department_BMS_CN__c = dcrNew.Department_Final_BMS_CN__c;          
            acct.Administrative_Title_BMS_CN__c = dcrNew.Administrative_Title_Final_BMS_CN__c;
            acct.Technical_Title_BMS_CN__c = dcrNew.Technical_Title_Final_BMS_CN__c;
            if(dcrNew.Social_Title_Final_BMS_CN__c <> null) {
                acct.Social_Title_BMS_CN__c = dcrNew.Social_Title_Final_BMS_CN__c;
            }                       
            
            // Update address info
            if(acct.Primary_Parent_vod__c <> dcrNew.Hospital_Final_BMS_CN__c && dcrNew.Hospital_Final_BMS_CN__c <> null) {
                acct.Primary_Parent_vod__c = dcrNew.Hospital_Final_BMS_CN__c;
                // Get hosptial address
                Address_vod__c hospAdd = [SELECT
                                            Id,
                                            Name,
                                            Account_vod__r.Name,
                                            City_vod__c,
                                            State_vod__c,
                                            Zip_vod__c
                                        FROM
                                            Address_vod__c
                                        WHERE
                                            Account_vod__r.Id =: dcrNew.Hospital_Final_BMS_CN__c AND
                                            Primary_vod__c = true
                                            LIMIT 1];
                string strAddress = '';
                if(hospAdd.State_vod__c <> null) {
                    strAddress = strAddress + mapState.get(hospAdd.State_vod__c) + ' ';
                }
                if(hospAdd.City_vod__c <> null) {
                    strAddress = strAddress + hospAdd.City_vod__c + ' ';
                }
                strAddress = strAddress + hospAdd.Name + ' ';
                if(hospAdd.Zip_vod__c <> null) {
                    strAddress = strAddress + hospAdd.Zip_vod__c;
                }
                
                acct.Address_BMS_CN__c = strAddress.trim();                         
            }                   
            update acct;
            
            // Delete child account
            List<Child_Account_vod__c> memberOf = [SELECT Id FROM Child_Account_vod__c WHERE Child_Account_vod__c =:dcrNew.Doctor_BMS_CN__c AND Primary_vod__c = 'No'];
            delete memberOf;

            // Update address object
            Address_vod__c docAdd = [SELECT 
                                        Id, 
                                        Name, 
                                        Account_vod__r.Primary_Parent_vod__r.name 
                                    FROM
                                        Address_vod__c 
                                    WHERE 
                                        Account_vod__c =: acct.Id AND
                                        Primary_vod__c = true
                                    LIMIT 1];
            docAdd.Lock_vod__c = false;
            docAdd.Name = docAdd.Account_vod__r.Primary_Parent_vod__r.name + ' ' + depMap.get(acct.Department_BMS_CN__c);
            update docAdd;  
        }
        
        // Delete doctor
        if(dcrNew.Status_BMS_CN__c == 'Approved' && dcrNew.Action_Type_BMS_CN__c == 'DEL') {
            
            // Remove doctor from all territories
            List<Account_Territory_Loader_vod__c> atlList = [SELECT 
                                                                Id,
                                                                Account_vod__c,
                                                                Territory_vod__c,
                                                                Territory_to_Drop_vod__c
                                                            FROM 
                                                                Account_Territory_Loader_vod__c 
                                                            WHERE
                                                                Account_vod__c =: dcrNew.Doctor_BMS_CN__c];
            for(Account_Territory_Loader_vod__c atl : atlList) {
                atl.Territory_to_Drop_vod__c = atl.Territory_vod__c;
            }
            update atlList;
            
            Account delAct = [SELECT Id,IsActive_BMS_CN__c FROM Account WHERE Id =: dcrNew.Doctor_BMS_CN__c];
            delAct.IsActive_BMS_CN__c = false;
            update delAct;
        }
    }
}