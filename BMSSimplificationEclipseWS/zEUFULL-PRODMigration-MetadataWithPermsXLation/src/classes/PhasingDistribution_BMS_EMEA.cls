public with sharing class PhasingDistribution_BMS_EMEA {
    
    public Id MasterFileID{get; set;}
    public List<Master_File_BMS_EMEA__c> MasterFile{get; set;}    
    public Decimal NoOfDays = 0;
    public String currentId{get;set;}  
                 
    public PhasingDistribution_BMS_EMEA(ApexPages.StandardController controller) {   
      
        currentId = '';
        this.MasterFileID= ((Master_File_BMS_EMEA__c)controller.getRecord()).Id;
        MasterFile = new List<Master_File_BMS_EMEA__c>();

        //Get details about this master file
        MasterFile = [SELECT  Id,Total_Planned_Cost_BMS_EMEA__c,Total_Actual_Cost_BMS_EMEA__c ,RollUp_Jan_Planned_BMS_EMEA__c,RollUp_Feb_Planned_BMS_EMEA__c,RollUp_Mar_Planned_BMS_EMEA__c,RollUp_Apr_Planned_BMS_EMEA__c,RollUp_May_Planned_BMS_EMEA__c,RollUp_Jun_Planned_BMS_EMEA__c,RollUp_Jul_Planned_BMS_EMEA__c,RollUp_Aug_Planned_BMS_EMEA__c,RollUp_Sep_Planned_BMS_EMEA__c,RollUp_Oct_Planned_BMS_EMEA__c,RollUp_Nov_Planned_BMS_EMEA__c,RollUp_Dec_Planned_BMS_EMEA__c,
                                                RollUp_Apr_Completed_BMS_EMEA__c,RollUp_Aug_Completed_BMS_EMEA__c,RollUp_Dec_Completed_BMS_EMEA__c,RollUp_Feb_Completed_BMS_EMEA__c,RollUp_Jan_Completed_BMS_EMEA__c,RollUp_Jul_Completed_BMS_EMEA__c,RollUp_Jun_Completed_BMS_EMEA__c,RollUp_Mar_Completed_BMS_EMEA__c,RollUp_May_Completed_BMS_EMEA__c,RollUp_Nov_Completed_BMS_EMEA__c,RollUp_Oct_Completed_BMS_EMEA__c,RollUp_Sep_Completed_BMS_EMEA__c,
                                                of_Sponsored_Participants_BMS_EMEA__c,of_Audience_Participants_BMS_EMEA__c,of_BMS_Employees_BMS_EMEA__c,Targeted_number_of_Meetings_BMS_EMEA__c,Objective_Total_BMS_EMEA__c,End_Date_BMS_EMEA__c,Start_Date_BMS_EMEA__c,Meetings_January_BMS_EMEA__c,Meetings_February_BMS_EMEA__c,Meetings_March_BMS_EMEA__c,Meetings_April_BMS_EMEA__c,Meeting_May_BMS_EMEA__c,
                            Meeting_June_BMS_EMEA__c,Meeting_July_BMS_EMEA__c,Meeting_August_BMS_EMEA__c,Meeting_September_BMS_EMEA__c,Meeting_October_BMS_EMEA__c,Meeting_November_BMS_EMEA__c,Meeting_Dec_BMS_EMEA__c,Total_Budget_all_Events_BMS_EMEA__c,Total_number_of_Meeting_PostExc_BMS_EMEA__c,Total_number_of_Meeting_Plans_BMS_EMEA__c
                      FROM Master_File_BMS_EMEA__c
                      WHERE Id = :this.MasterFileID];    
              
    }
    //Cancel command link
    public void cancelBMS(){
                MasterFile = [SELECT  Id,Total_Planned_Cost_BMS_EMEA__c,Total_Actual_Cost_BMS_EMEA__c ,RollUp_Jan_Planned_BMS_EMEA__c,RollUp_Feb_Planned_BMS_EMEA__c,RollUp_Mar_Planned_BMS_EMEA__c,RollUp_Apr_Planned_BMS_EMEA__c,RollUp_May_Planned_BMS_EMEA__c,RollUp_Jun_Planned_BMS_EMEA__c,RollUp_Jul_Planned_BMS_EMEA__c,RollUp_Aug_Planned_BMS_EMEA__c,RollUp_Sep_Planned_BMS_EMEA__c,RollUp_Oct_Planned_BMS_EMEA__c,RollUp_Nov_Planned_BMS_EMEA__c,RollUp_Dec_Planned_BMS_EMEA__c,
                                        RollUp_Apr_Completed_BMS_EMEA__c,RollUp_Aug_Completed_BMS_EMEA__c,RollUp_Dec_Completed_BMS_EMEA__c,RollUp_Feb_Completed_BMS_EMEA__c,RollUp_Jan_Completed_BMS_EMEA__c,RollUp_Jul_Completed_BMS_EMEA__c,RollUp_Jun_Completed_BMS_EMEA__c,RollUp_Mar_Completed_BMS_EMEA__c,RollUp_May_Completed_BMS_EMEA__c,RollUp_Nov_Completed_BMS_EMEA__c,RollUp_Oct_Completed_BMS_EMEA__c,RollUp_Sep_Completed_BMS_EMEA__c,
                                        of_Sponsored_Participants_BMS_EMEA__c,of_Audience_Participants_BMS_EMEA__c,of_BMS_Employees_BMS_EMEA__c,Targeted_number_of_Meetings_BMS_EMEA__c,Objective_Total_BMS_EMEA__c,End_Date_BMS_EMEA__c,Start_Date_BMS_EMEA__c,Meetings_January_BMS_EMEA__c,Meetings_February_BMS_EMEA__c,Meetings_March_BMS_EMEA__c,Meetings_April_BMS_EMEA__c,Meeting_May_BMS_EMEA__c,
                            Meeting_June_BMS_EMEA__c,Meeting_July_BMS_EMEA__c,Meeting_August_BMS_EMEA__c,Meeting_September_BMS_EMEA__c,Meeting_October_BMS_EMEA__c,Meeting_November_BMS_EMEA__c,Meeting_Dec_BMS_EMEA__c,Total_Budget_all_Events_BMS_EMEA__c,Total_number_of_Meeting_PostExc_BMS_EMEA__c,Total_number_of_Meeting_Plans_BMS_EMEA__c
                      FROM Master_File_BMS_EMEA__c
                      WHERE Id = :this.MasterFileID];   
                      
            currentId = '';
    }
    
     //Save    
    public void SaveBMS() {
        MasterFile[0].Objective_Total_BMS_EMEA__c = 0;      
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meetings_January_BMS_EMEA__c == null)?0:MasterFile[0].Meetings_January_BMS_EMEA__c;
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meetings_February_BMS_EMEA__c == null)?0:MasterFile[0].Meetings_February_BMS_EMEA__c;
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meetings_March_BMS_EMEA__c == null)?0:MasterFile[0].Meetings_March_BMS_EMEA__c;
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meetings_April_BMS_EMEA__c == null)?0:MasterFile[0].Meetings_April_BMS_EMEA__c;
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meeting_May_BMS_EMEA__c == null)?0:MasterFile[0].Meeting_May_BMS_EMEA__c;
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meeting_June_BMS_EMEA__c == null)?0:MasterFile[0].Meeting_June_BMS_EMEA__c;
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meeting_July_BMS_EMEA__c == null)?0:MasterFile[0].Meeting_July_BMS_EMEA__c;
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meeting_August_BMS_EMEA__c == null)?0:MasterFile[0].Meeting_August_BMS_EMEA__c;
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meeting_September_BMS_EMEA__c == null)?0:MasterFile[0].Meeting_September_BMS_EMEA__c;
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meeting_October_BMS_EMEA__c == null)?0:MasterFile[0].Meeting_October_BMS_EMEA__c;
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meeting_November_BMS_EMEA__c == null)?0:MasterFile[0].Meeting_November_BMS_EMEA__c;
        MasterFile[0].Objective_Total_BMS_EMEA__c += (MasterFile[0].Meeting_Dec_BMS_EMEA__c == null)?0:MasterFile[0].Meeting_Dec_BMS_EMEA__c;
        
        if(MasterFile[0].Objective_Total_BMS_EMEA__c != MasterFile[0].Targeted_number_of_Meetings_BMS_EMEA__c){
            MasterFile[0].Objective_Total_BMS_EMEA__c = MasterFile[0].Targeted_number_of_Meetings_BMS_EMEA__c;
            MasterFile[0].addError('The Objective Total must be equal to ' + MasterFile[0].Targeted_number_of_Meetings_BMS_EMEA__c);
        }
        else{
            update MasterFile;
            currentId = '';
        }
    }  
    
    
    
}