<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EM_7_Day_after_end_date_notification</fullName>
        <description>EM 7 Day after end date notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/EM_7_Days_Post_Event</template>
    </alerts>
    <alerts>
        <fullName>EM_Email_Creator_Activity_is_Closed</fullName>
        <description>EM - Email Creator Activity is Closed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMS_HCPTS_EM_Templates/Activity_Template_to_Creator_when_closed</template>
    </alerts>
    <alerts>
        <fullName>Em_Activity_Canceled_HCPTS</fullName>
        <description>Em Activity Canceled</description>
        <protected>false</protected>
        <recipients>
            <field>Processor_Email_HCPTS__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/EM_Activity_Canceled</template>
    </alerts>
    <alerts>
        <fullName>Notify_Activity_Approver_when_Budget_Exceeded_Estimates</fullName>
        <description>Notify Activity Approver when Budget Exceeded Estimates</description>
        <protected>false</protected>
        <recipients>
            <field>Approver_Email_HCPTS__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMS_HCPTS_EM_Templates/Actual_Budget_Exceeds_Estimated_Budget</template>
    </alerts>
    <alerts>
        <fullName>Notify_EM_User_of_Status_Change</fullName>
        <description>Notify EM User of Status Change</description>
        <protected>false</protected>
        <recipients>
            <field>Processor_Email_HCPTS__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Event_Status_Update</template>
    </alerts>
    <fieldUpdates>
        <fullName>Activity_Updated_Logistics_Support</fullName>
        <description>Updated Logistics Support Field = True</description>
        <field>Amex_Support_Needed_HCPTS__c</field>
        <literalValue>1</literalValue>
        <name>Activity: Updated Logistics Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Null_Approver_Email</fullName>
        <field>Approver_Email_HCPTS__c</field>
        <name>Null Approver Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Date_Put_In_Processor_Review</fullName>
        <field>Date_Put_In_Processor_Review__c</field>
        <formula>TODAY()</formula>
        <name>Populate Date Put In Processor Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateEventStatusPostEventApproval</fullName>
        <field>Status_vod__c</field>
        <literalValue>Post-Event-PostApproval</literalValue>
        <name>UpdateEventStatus-Post-EventApproval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Activity_ID</fullName>
        <field>Activity_ID_2_HCPTS__c</field>
        <formula>LEFT(&apos;AN-&apos; &amp; TEXT(YEAR( Start_Date_Formula_HCPTS__c )) &amp; &apos;-&apos; &amp; Country_vod__r.Alpha_2_Code_vod__c &amp; &apos;-&apos; &amp; Product_HCPTS__r.Name &amp; &apos;-&apos; &amp; Activity_Type_Formula_HCPTS__c &amp; &apos;-&apos; &amp; Activity_Id_HCPTS__c,80)</formula>
        <name>Update Activity ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Activity_Name</fullName>
        <description>Update Activity Name</description>
        <field>Name</field>
        <formula>LEFT(&apos;AN-&apos; &amp; TEXT(YEAR( Start_Date_Formula_HCPTS__c )) &amp; &apos;-&apos; &amp; Country_vod__r.Alpha_2_Code_vod__c &amp; &apos;-&apos; &amp; Product_HCPTS__r.Name &amp; &apos;-&apos; &amp; Activity_Type_Formula_HCPTS__c &amp; &apos;-&apos; &amp; Activity_Id_HCPTS__c,80)</formula>
        <name>Update Activity Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Event_to_Approved</fullName>
        <field>Status_vod__c</field>
        <literalValue>Approved_vod</literalValue>
        <name>Update Event to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Event_to_Pending_Approval</fullName>
        <field>Status_vod__c</field>
        <literalValue>Pending_Approval_vod</literalValue>
        <name>Update Event to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Event_to_Pre_Event</fullName>
        <field>Status_vod__c</field>
        <literalValue>Pre-Event</literalValue>
        <name>Update Event to Pre-Event</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_WasApproved_to_True</fullName>
        <field>WasApproved_HCPTS__c</field>
        <literalValue>1</literalValue>
        <name>Update WasApproved to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>EM Activity - Email to Creator on Close</fullName>
        <actions>
            <name>EM_Email_Creator_Activity_is_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Event_vod__c.Status_vod__c</field>
            <operation>equals</operation>
            <value>Closed_vod</value>
        </criteriaItems>
        <criteriaItems>
            <field>EM_Event_vod__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Simple Activity</value>
        </criteriaItems>
        <description>Workflow to fire when EM Activity Status = Archived to notify creator that the Activity has been closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EM Activity Canceled</fullName>
        <actions>
            <name>Em_Activity_Canceled_HCPTS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Event_vod__c.Status_vod__c</field>
            <operation>equals</operation>
            <value>Canceled_vod</value>
        </criteriaItems>
        <criteriaItems>
            <field>EM_Event_vod__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Simple Activity</value>
        </criteriaItems>
        <description>Em Activity Canceled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Approver if Actual Cost %3E Estimated Cost</fullName>
        <actions>
            <name>Notify_Activity_Approver_when_Budget_Exceeded_Estimates</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify Approver if Actual Cost &gt; Estimated Cost</description>
        <formula>AND(ISPICKVAL( Status_vod__c ,&apos;In Closeout&apos;), Actual_Cost_vod__c &gt; Estimated_Cost_vod__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify EM Owner and SC of Status Change</fullName>
        <actions>
            <name>Notify_EM_User_of_Status_Change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notification of EM Owner and Service Coordinator that a Simple Event has moved to aone of these statuses - Post-Event, Canceled, Archived</description>
        <formula>AND (
 RecordType.DeveloperName = &apos;Simple_Activity_HCPTS&apos;,

 ISCHANGED(Status_vod__c),
OR(
 TEXT(Status_vod__c) = &apos;Closed_vod&apos;,
 TEXT(Status_vod__c) = &apos;Canceled_vod&apos;,
  TEXT(Status_vod__c) = &apos;Post-Event&apos;
)

)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Owner 7 Days after Event</fullName>
        <active>true</active>
        <criteriaItems>
            <field>EM_Event_vod__c.Status_vod__c</field>
            <operation>equals</operation>
            <value>Pre-Event</value>
        </criteriaItems>
        <description>Notification to Activity Owner if the Event is still in &quot;Pre-Event&quot; status 7 days after the end date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EM_7_Day_after_end_date_notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>EM_Event_vod__c.End_Time_vod__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Activity ID</fullName>
        <actions>
            <name>Update_Activity_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Event_vod__c.Start_Time_vod__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Workflow to Update the Activity ID with the following format: AN-YEAR-COUNTRY-PRODUCT/TA-ABBREVIATEDACTIVITYTYPE-AUTONUMBER</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update PostEvent to PostEventPostApproval</fullName>
        <actions>
            <name>UpdateEventStatusPostEventApproval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Event_vod__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Simple Activity</value>
        </criteriaItems>
        <criteriaItems>
            <field>EM_Event_vod__c.Status_vod__c</field>
            <operation>equals</operation>
            <value>Post-Event</value>
        </criteriaItems>
        <criteriaItems>
            <field>EM_Event_vod__c.WasApproved_HCPTS__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
