<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Budget_Identifier_for_Simple_Need</fullName>
        <description>Updates Budget Id for simple needs to include WBS/CC number</description>
        <field>Budget_Identifier_vod__c</field>
        <formula>LEFT(&apos;ND-&apos; &amp; TEXT(YEAR( Start_Date_vod__c )) &amp; &apos;-&apos; &amp;  Company_Code_HCPTS__r.Plant_Code_HCPTS__r.Country_HCPTS__c &amp; &apos;-&apos; &amp; 
 IF(ISBLANK( WBS_Number_HCPTS__c ), Cost_Center_Code_HCPTS__r.Name ,WBS_Number_HCPTS__r.Name) 
&amp;
&apos;-&apos; &amp; Need_ID_HCPTS__c,80)</formula>
        <name>Update Budget Identifier for Simple Need</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Budget_Identifier_to_NEED_ID</fullName>
        <description>Updates the Budget ID field with Need ID..specific system generated format</description>
        <field>Budget_Identifier_vod__c</field>
        <formula>LEFT(&apos;ND-&apos; &amp; TEXT(YEAR( Start_Date_vod__c )) &amp; &apos;-&apos; &amp; Funding_Country_HCPTS__r.Alpha_2_Code_vod__c &amp; &apos;-&apos; &amp; Product_vod__r.Name &amp; &apos;-&apos; &amp;   TEXT(Activity_Type_HCPTS__c)   &amp; &apos;-&apos; &amp; Need_ID_HCPTS__c,80)</formula>
        <name>Update Budget Identifier to NEED ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Budget_Status_to_Expired</fullName>
        <description>Moves Active Budgets to Expired State  - req 534 - mnaidu- simplification</description>
        <field>Status_vod__c</field>
        <literalValue>Expired</literalValue>
        <name>Update Budget Status to Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Expire Simple Budget after End Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>EM_Budget_vod__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Budget</value>
        </criteriaItems>
        <criteriaItems>
            <field>EM_Budget_vod__c.Status_vod__c</field>
            <operation>equals</operation>
            <value>Available_For_Use_vod</value>
        </criteriaItems>
        <description>Moves Active Budgets to Expired State one day after End Date - req 534 - mnaidu- simplification</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Budget_Status_to_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>EM_Budget_vod__c.End_Date_vod__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Budget Identifier to NeedID Format</fullName>
        <actions>
            <name>Update_Budget_Identifier_to_NEED_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Budget Identifer field to a specific format using attribute values from Need object record</description>
        <formula>RecordType.DeveloperName  &lt;&gt; &apos;Budget_vod&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Budget Identifier to SIMPLE NeedID Format</fullName>
        <actions>
            <name>Update_Budget_Identifier_for_Simple_Need</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Budget Identifer field to a specific format using attribute values from Need object record FOR SIMPLE NEED</description>
        <formula>RecordType.DeveloperName = &apos;Budget_vod&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
