@isTest(seeAllData=true)
public class Test_BMS_CN_Cycle_Plan_Seg_Freq_Calc 
{
	static testMethod void test()
	{		
		BMS_CN_Cycle_Plan_Seg_Freq_Calc cp = new BMS_CN_Cycle_Plan_Seg_Freq_Calc();
		Test.startTest();
		Database.executeBatch(cp,50);		
		Test.stopTest();
	}
}