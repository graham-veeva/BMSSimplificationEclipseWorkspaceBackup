public class BMSMSLTLEvaluation {
//Updated by Durga for the 2013 thought leader Calculation change
    //Jason Wigg 2013.06.11 - This method is used for NA org - new method added for InterCon Org
   public static void calculateThoughtLeaderType(Account[] accs){

      for (Account a:accs){
          // Get the answers to the X questions into usable variables
          // Convert picklist values to numerical (integer) values
 
//National Calculation 
         String nq1 = a.NationalQ1_BMS__c;
          Integer nq1int = 0;
          Integer answers = 0;
          If (nq1 == 'Yes') {nq1int = 1;}
          If (nq1 == 'Yes') {answers = answers + 1;}
          If (nq1 == 'No') {answers = answers + 1;}

          String nq2 = a.NationalQ2_BMS__c;
          Integer nq2int = 0;
          If (nq2 == 'Yes') {nq2int = 1;}
          If (nq2 == 'Yes') {answers = answers + 1;}
          If (nq2 == 'No') {answers = answers + 1;}

          String nq3 = a.NationalQ3_BMS__c;
          Integer nq3int = 0;
          If (nq3 == 'Yes') {nq3int = 1;}
          If (nq3 == 'Yes') {answers = answers + 1;}
          If (nq3 == 'No') {answers = answers + 1;}

          String nq4 = a.NationalQ4_BMS__c;
          Integer nq4int = 0;
          If (nq4 == 'Yes') {nq4int = 1;}
          If (nq4 == 'Yes') {answers = answers + 1;}
          If (nq4 == 'No') {answers = answers + 1;}

          String nq5 = a.NationalQ5_BMS__c;
          Integer nq5int = 0;
          If (nq5 == 'Yes') {nq5int = 1;}
          If (nq5 == 'Yes') {answers = answers + 1;}
          If (nq5 == 'No') {answers = answers + 1;}

          String nq6 = a.NationalQ6_BMS__c;
          Integer nq6int = 0;
          If (nq6 == 'Yes') {nq6int = 1;}
          If (nq6 == 'Yes') {answers = answers + 1;}
          If (nq6 == 'No') {answers = answers + 1;}

          String nq7 = a.NationalQ7_BMS__c;
          Integer nq7int = 0;
          If (nq7 == 'Yes') {nq7int = 1;}
          If (nq7 == 'Yes') {answers = answers + 1;}
          If (nq7 == 'No') {answers = answers + 1;}
    
          String nq8 = a.RegionalQ6_BMS__c;
          Integer nq8int = 0;
          If (nq8 == 'Yes') {nq8int = 1;}
          If (nq8 == 'Yes') {answers = answers + 1;}
          If (nq8 == 'No') {answers = answers + 1;} 
          
// Regional calculation  


          String rq2 = a.RegionalQ2_BMS__c;
          Integer rq2int = 0;
          If (rq2 == 'Yes') {rq2int = 1;}
          If (rq2 == 'Yes') {answers = answers + 1;}
          If (rq2 == 'No') {answers = answers + 1;}

          String rq3 = a.RegionalQ3_BMS__c;
          Integer rq3int = 0;
          If (rq3 == 'Yes') {rq3int = 1;}
          If (rq3 == 'Yes') {answers = answers + 1;}
          If (rq3 == 'No') {answers = answers + 1;}

          String rq4 = a.RegionalQ4_BMS__c;
          Integer rq4int = 0;
          If (rq4 == 'Yes') {rq4int = 1;}
          If (rq4 == 'Yes') {answers = answers + 1;}
          If (rq4 == 'No') {answers = answers + 1;}

          String rq5 = a.RegionalQ5_BMS__c;
          Integer rq5int = 0;
          If (rq5 == 'Yes') {rq5int = 1;}
          If (rq5 == 'Yes') {answers = answers + 1;}
          If (rq5 == 'No') {answers = answers + 1;}


          String rq7 = a.RegionalQ7_BMS__c;
          Integer rq7int = 0;
          If (rq7 == 'Yes') {rq7int = 1;}
          If (rq7 == 'Yes') {answers = answers + 1;}
          If (rq7 == 'No') {answers = answers + 1;}

          String rq8 = a.RegionalQ8_BMS__c;
          Integer rq8int = 0;
          If (rq8 == 'Yes') {rq8int = 1;}
          If (rq8 == 'Yes') {answers = answers + 1;}
          If (rq8 == 'No') {answers = answers + 1;}

// HCP calculation
          String HCPq1 = a.HCPQ1_BMS__c;
          Integer HCPq1int = 0;
          If (HCPq1 == 'Yes') {HCPq1int = 1;}
          If (HCPq1 == 'Yes') {answers = answers + 1;}
          If (HCPq1 == 'No') {answers = answers + 1;}
          
          String HCPq2 = a.HCPQ2_BMS__c;
          Integer HCPq2int = 0;
          If (HCPq2 == 'Yes') {HCPq2int = 1;}
          If (HCPq2 == 'Yes') {answers = answers + 1;}
          If (HCPq2 == 'No') {answers = answers + 1;}
          
          String HCPq3 = a.HCPQ3_BMS__c;
          Integer HCPq3int = 0;
          If (HCPq3 == 'Yes') {HCPq3int = 1;}
          If (HCPq3 == 'Yes') {answers = answers + 1;}
          If (HCPq3 == 'No') {answers = answers + 1;}
          
          // Perform the initial calculations based on the answers to the 17 questions
                
          Decimal National_TL_Calc_BMS = 0;
          Decimal Regional_TL_Calc_BMS = 0;
          Decimal HCP_Calc_BMS = 0;
            
          National_TL_Calc_BMS = nq1int + nq2int + nq3int + nq4int + nq5int + nq6int + nq7int + nq8int;
          Regional_TL_Calc_BMS = nq1int + nq2int + nq3int + nq4int + nq5int + nq6int + nq7int + nq8int + rq2int + rq3int + rq4int + rq5int +  rq7int + rq8int ;
          HCP_Calc_BMS = nq1int + nq2int + nq3int + nq4int + nq5int + nq6int + nq7int + nq8int + rq2int + rq3int + rq4int + rq5int +  rq7int + rq8int + HCPq1int + HCPq2int + HCPq3int;
     

          // Calculate Thought Leader Type
          String finalTLtype = NULL;

          if (HCP_Calc_BMS > 0) {
                finalTLtype = 'HCP';
          }

          if (Regional_TL_Calc_BMS > 1) {
                finalTLtype = 'Regional Thought Leader';
          }

          if (National_TL_Calc_BMS > 3) {
                finalTLtype = 'National Thought Leader';
          }


          // Set the BMS Overall Sphere of Influence to the final Thought Leader classification
          a.Overall_Sphere_of_Influence_BMS__c = finalTLtype;
          a.SOI_Questions_Answered_BMS__c = String.valueOf(answers) + ' / 17';
      }
   }
   
   //Jason Wigg 2013.06.11 - This method created as an edited version of the original method. For use by InterCon Org.
       //Method written by Colin McRavey 2013.06.03
   public static void calculateThoughtLeaderTypeIC(Account[] accs){

      for (Account a:accs){
          // Get the answers to the X questions into usable variables
          // Convert picklist values to numerical (integer) values
 
          // *** National Calculations ***
          String nq1 = a.NationalQ1_BMS__c;
          Integer nq1int = 0;
          Integer answers = 0;
          If (nq1 == 'Yes') {nq1int = 1;}
          If (nq1 == 'Yes') {answers = answers + 1;}
          If (nq1 == 'No') {answers = answers + 1;}

          String nq2 = a.NationalQ2_BMS__c;
          Integer nq2int = 0;
          If (nq2 == 'Yes') {nq2int = 1;}
          If (nq2 == 'Yes') {answers = answers + 1;}
          If (nq2 == 'No') {answers = answers + 1;}

          String nq3 = a.NationalQ3_BMS__c;
          Integer nq3int = 0;
          If (nq3 == 'Yes') {nq3int = 1;}
          If (nq3 == 'Yes') {answers = answers + 1;}
          If (nq3 == 'No') {answers = answers + 1;}

          String nq4 = a.NationalQ4_BMS__c;
          Integer nq4int = 0;
          If (nq4 == 'Yes') {nq4int = 1;}
          If (nq4 == 'Yes') {answers = answers + 1;}
          If (nq4 == 'No') {answers = answers + 1;}

          String nq5 = a.NationalQ5_BMS__c;
          Integer nq5int = 0;
          If (nq5 == 'Yes') {nq5int = 1;}
          If (nq5 == 'Yes') {answers = answers + 1;}
          If (nq5 == 'No') {answers = answers + 1;}

          String nq6 = a.NationalQ6_BMS__c;
          Integer nq6int = 0;
          If (nq6 == 'Yes') {nq6int = 1;}
          If (nq6 == 'Yes') {answers = answers + 1;}
          If (nq6 == 'No') {answers = answers + 1;}

          String nq7 = a.NationalQ7_BMS__c;
          Integer nq7int = 0;
          If (nq7 == 'Yes') {nq7int = 1;}
          If (nq7 == 'Yes') {answers = answers + 1;}
          If (nq7 == 'No') {answers = answers + 1;}
          

          // *** Regional Salculations ***
          String rq2 = a.RegionalQ2_BMS__c;
          Integer rq2int = 0;
          If (rq2 == 'Yes') {rq2int = 1;}
          If (rq2 == 'Yes') {answers = answers + 1;}
          If (rq2 == 'No') {answers = answers + 1;}

          String rq3 = a.RegionalQ3_BMS__c;
          Integer rq3int = 0;
          If (rq3 == 'Yes') {rq3int = 1;}
          If (rq3 == 'Yes') {answers = answers + 1;}
          If (rq3 == 'No') {answers = answers + 1;}

          String rq4 = a.RegionalQ4_BMS__c;
          Integer rq4int = 0;
          If (rq4 == 'Yes') {rq4int = 1;}
          If (rq4 == 'Yes') {answers = answers + 1;}
          If (rq4 == 'No') {answers = answers + 1;}

          String rq5 = a.RegionalQ5_BMS__c;
          Integer rq5int = 0;
          If (rq5 == 'Yes') {rq5int = 1;}
          If (rq5 == 'Yes') {answers = answers + 1;}
          If (rq5 == 'No') {answers = answers + 1;}
          
          String rq6 = a.RegionalQ6_BMS__c;
          Integer rq6int = 0;
          If (rq5 == 'Yes') {rq5int = 1;}
          If (rq5 == 'Yes') {answers = answers + 1;}
          If (rq5 == 'No') {answers = answers + 1;}

          String rq7 = a.RegionalQ7_BMS__c;
          Integer rq7int = 0;
          If (rq7 == 'Yes') {rq7int = 1;}
          If (rq7 == 'Yes') {answers = answers + 1;}
          If (rq7 == 'No') {answers = answers + 1;}

          String rq8 = a.RegionalQ8_BMS__c;
          Integer rq8int = 0;
          If (rq8 == 'Yes') {rq8int = 1;}
          If (rq8 == 'Yes') {answers = answers + 1;}
          If (rq8 == 'No') {answers = answers + 1;}


          // *** International Calculations ***
          String INTq1 = a.InternationalQ1_BMS_CA__c;
          Integer INTq1int = 0;
          If (INTq1 == 'Yes') {INTq1int = 1;}
          If (INTq1 == 'Yes') {answers = answers + 1;}
          If (INTq1 == 'No') {answers = answers + 1;}
          
          String INTq2 = a.InternationalQ2_BMS_CA__c;
          Integer INTq2int = 0;
          If (INTq2 == 'Yes') {INTq2int = 1;}
          If (INTq2 == 'Yes') {answers = answers + 1;}
          If (INTq2 == 'No') {answers = answers + 1;}
          
          String INTq3 = a.InternationalQ3_BMS_CA__c;
          Integer INTq3int = 0;
          If (INTq3 == 'Yes') {INTq3int = 1;}
          If (INTq3 == 'Yes') {answers = answers + 1;}
          If (INTq3 == 'No') {answers = answers + 1;}
          
          String INTq4 = a.InternationalQ4_BMS_CA__c;
          Integer INTq4int = 0;
          If (INTq4 == 'Yes') {INTq4int = 1;}
          If (INTq4 == 'Yes') {answers = answers + 1;}
          If (INTq4 == 'No') {answers = answers + 1;}
          
          String INTq5 = a.InternationalQ5_BMS_CA__c;
          Integer INTq5int = 0;
          If (INTq5 == 'Yes') {INTq5int = 1;}
          If (INTq5 == 'Yes') {answers = answers + 1;}
          If (INTq5 == 'No') {answers = answers + 1;}
          
          String INTq6 = a.InternationalQ6_BMS_CA__c;
          Integer INTq6int = 0;
          If (INTq6 == 'Yes') {INTq6int = 1;}
          If (INTq6 == 'Yes') {answers = answers + 1;}
          If (INTq6 == 'No') {answers = answers + 1;}
          
          String INTq7 = a.InternationalQ7_BMS_CA__c;
          Integer INTq7int = 0;
          If (INTq7 == 'Yes') {INTq7int = 1;}
          If (INTq7 == 'Yes') {answers = answers + 1;}
          If (INTq7 == 'No') {answers = answers + 1;}
          
          String INTq8 = a.InternationalQ8_BMS_CA__c;
          Integer INTq8int = 0;
          If (INTq8 == 'Yes') {INTq8int = 1;}
          If (INTq8 == 'Yes') {answers = answers + 1;}
          If (INTq8 == 'No') {answers = answers + 1;}
          
          
          // Perform the initial calculations based on the answers to the 22 questions
          Decimal National_TL_Calc_BMS = 0;
          Decimal Regional_TL_Calc_BMS = 0;
          Decimal International_TL_Calc_BMS = 0;
            
          National_TL_Calc_BMS = nq1int + nq2int + nq3int + nq4int + nq5int + nq6int + nq7int;
          Regional_TL_Calc_BMS = rq2int + rq3int + rq4int + rq5int + nq6int + rq7int + rq8int;
          International_TL_Calc_BMS = INTq1int + INTq2int + INTq3int + INTq4int + INTq5int + INTq6int + INTq7int + INTq8int;
     

          // Calculate Thought Leader Type
          String finalTLtype = NULL;

          if (Regional_TL_Calc_BMS > 1) {
                finalTLtype = 'Regional Thought Leader';
          }

          if (National_TL_Calc_BMS > 3) {
                finalTLtype = 'National Thought Leader';
          }
          
          if (International_TL_Calc_BMS > 2) {
                finalTLtype = 'National Thought Leader';
          }

          if (International_TL_Calc_BMS > 3) {
                finalTLtype = 'International Thought Leader';
          }


          // Set the BMS Overall Sphere of Influence to the final Thought Leader classification
          a.Overall_Sphere_of_Influence_BMS__c = finalTLtype;
          a.SOI_Questions_Answered_BMS__c = String.valueOf(answers) + ' / 22';
      }
   }
   
   
}