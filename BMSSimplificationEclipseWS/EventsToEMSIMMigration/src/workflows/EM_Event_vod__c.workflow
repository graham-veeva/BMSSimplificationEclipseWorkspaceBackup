<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_Activity_Owner_to_move_Activity_to_Post_Event</fullName>
        <description>Alert Activity Owner to move Activity to Post Event</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>iaops_eu_notifications@bms.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMS_HCPTS_EM_Templates/Activity_Template_to_Creator</template>
    </alerts>
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
    <rules>
        <fullName>Alert Activity Owner close to Event End Date</fullName>
        <active>false</active>
        <criteriaItems>
            <field>EM_Event_vod__c.End_Time_vod__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Inserts a time based e-mail alert to fire based on Activity End date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>EM_Event_vod__c.End_Time_vod__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
