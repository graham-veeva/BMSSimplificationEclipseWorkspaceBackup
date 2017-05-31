/**************************************************************************************************************/
/**************************************ICBWORKS****************************************************************/
/**************************************************************************************************************/

//This trigger calculates the phasing distribution when a master file is created or when the fields Start date, End date and Targeted number of meetings are changed

trigger Phasing_Distribution_Calculation_BMS_EMEA on Master_File_BMS_EMEA__c (before insert, before update) {

   map<Id,Master_File_BMS_EMEA__c> mapoldmf = trigger.OldMap; 
   Integer numOfMonths = 0;
   Integer averMeet = 0;
   Integer remainmod = 0;

   for(Master_File_BMS_EMEA__c mf:trigger.new){
       if(trigger.IsInsert || (trigger.IsBefore && (mf.Start_Date_BMS_EMEA__c != mapoldmf.get(mf.Id).Start_Date_BMS_EMEA__c || mf.End_Date_BMS_EMEA__c != mapoldmf.get(mf.Id).End_Date_BMS_EMEA__c || mf.Targeted_number_of_Meetings_BMS_EMEA__c != mapoldmf.get(mf.Id).Targeted_number_of_Meetings_BMS_EMEA__c))){
           
           	if(Integer.valueOf(mf.End_Date_BMS_EMEA__c) > Integer.valueOf(mf.Start_Date_BMS_EMEA__c)){
	            // get number of months 
	            numOfMonths = (Integer.valueOf(mf.End_Date_BMS_EMEA__c) - Integer.valueOf(mf.Start_Date_BMS_EMEA__c)) + 1;
	            
	            //get average number of meetings per month + convert to integer
	            averMeet = Integer.ValueOf(mf.Targeted_number_of_Meetings_BMS_EMEA__c / numOfMonths);
	            
	            //get modulus; i.e remainder
	            remainmod = math.mod(Integer.valueOf(mf.Targeted_number_of_Meetings_BMS_EMEA__c), numOfMonths);
	            
	            //reset all month values and Objective Total
	            mf.Meetings_January_BMS_EMEA__c = null;
	            mf.Meetings_February_BMS_EMEA__c = null;
	            mf.Meetings_March_BMS_EMEA__c = null;
	            mf.Meetings_April_BMS_EMEA__c = null;
	            mf.Meeting_May_BMS_EMEA__c = null;
	            mf.Meeting_June_BMS_EMEA__c = null;
	            mf.Meeting_July_BMS_EMEA__c = null;
	            mf.Meeting_August_BMS_EMEA__c = null;
	            mf.Meeting_September_BMS_EMEA__c = null;
	            mf.Meeting_October_BMS_EMEA__c = null;
	            mf.Meeting_November_BMS_EMEA__c = null;
	            mf.Meeting_Dec_BMS_EMEA__c = null;
	            mf.Objective_Total_BMS_EMEA__c = 0;
	            
	            //calculate value for each month if the month is present with start and end date
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=12 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=12){
	                mf.Meeting_Dec_BMS_EMEA__c = averMeet;
	                //if there is a remainder, then add 1 to this month and decrement the remainder
	                if(remainmod > 0){
	                    mf.Meeting_Dec_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                //calculate total
	                mf.Objective_Total_BMS_EMEA__c += mf.Meeting_Dec_BMS_EMEA__c;
	            }
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=11 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=11){
	                mf.Meeting_November_BMS_EMEA__c = averMeet;
	                if(remainmod > 0){
	                    mf.Meeting_November_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                mf.Objective_Total_BMS_EMEA__c += mf.Meeting_November_BMS_EMEA__c;
	            }
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=10 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=10){
	                mf.Meeting_October_BMS_EMEA__c = averMeet;
	                if(remainmod > 0){
	                    mf.Meeting_October_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                mf.Objective_Total_BMS_EMEA__c += mf.Meeting_October_BMS_EMEA__c;
	            }
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=9 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=9){
	                mf.Meeting_September_BMS_EMEA__c = averMeet;
	                if(remainmod > 0){
	                    mf.Meeting_September_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                mf.Objective_Total_BMS_EMEA__c += mf.Meeting_September_BMS_EMEA__c;
	            }
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=8 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=8){
	                mf.Meeting_August_BMS_EMEA__c = averMeet;
	                if(remainmod > 0){
	                    mf.Meeting_August_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                mf.Objective_Total_BMS_EMEA__c += mf.Meeting_August_BMS_EMEA__c;
	            }
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=7 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=7){
	                mf.Meeting_July_BMS_EMEA__c = averMeet;
	                if(remainmod > 0){
	                    mf.Meeting_July_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                mf.Objective_Total_BMS_EMEA__c += mf.Meeting_July_BMS_EMEA__c;
	            }
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=6 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=6){
	                mf.Meeting_June_BMS_EMEA__c = averMeet;
	                if(remainmod > 0){
	                    mf.Meeting_June_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                mf.Objective_Total_BMS_EMEA__c += mf.Meeting_June_BMS_EMEA__c;
	            }
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=5 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=5){
	                mf.Meeting_May_BMS_EMEA__c = averMeet;
	                if(remainmod > 0){
	                    mf.Meeting_May_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                mf.Objective_Total_BMS_EMEA__c += mf.Meeting_May_BMS_EMEA__c;
	            }
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=4 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=4){
	                mf.Meetings_April_BMS_EMEA__c = averMeet;
	                if(remainmod > 0){
	                    mf.Meetings_April_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                mf.Objective_Total_BMS_EMEA__c += mf.Meetings_April_BMS_EMEA__c;
	            }
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=3 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=3){
	                mf.Meetings_March_BMS_EMEA__c = averMeet;
	                if(remainmod > 0){
	                    mf.Meetings_March_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                mf.Objective_Total_BMS_EMEA__c += mf.Meetings_March_BMS_EMEA__c;
	            }
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=2 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=2){
	                mf.Meetings_February_BMS_EMEA__c = averMeet;
	                if(remainmod > 0){
	                    mf.Meetings_February_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                mf.Objective_Total_BMS_EMEA__c += mf.Meetings_February_BMS_EMEA__c;
	            }
	            if(Integer.valueOf(mf.Start_Date_BMS_EMEA__c) <=1 && Integer.valueOf(mf.End_Date_BMS_EMEA__c) >=1){
	                mf.Meetings_January_BMS_EMEA__c = averMeet;
	                if(remainmod > 0){
	                    mf.Meetings_January_BMS_EMEA__c += 1;
	                    remainmod -= 1;
	                }
	                mf.Objective_Total_BMS_EMEA__c += mf.Meetings_January_BMS_EMEA__c;
	            }
       
           	}
       }
   }

}