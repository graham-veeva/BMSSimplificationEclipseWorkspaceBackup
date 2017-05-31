<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Approver_of_Activity</fullName>
        <description>Notify Approver of Activity</description>
        <protected>false</protected>
        <recipients>
            <field>Next_Approver_vod__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMS_HCPTS_EM_Templates/Activity_Approval_Template</template>
    </alerts>
    <rules>
        <fullName>Notify Approver of Activity</fullName>
        <actions>
            <name>Notify_Approver_of_Activity</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>E-mail alert to notify approver for an Approval request</description>
        <formula>AND(TEXT(Action_Type_vod__c) = &apos;Submit_for_Approval_vod&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
