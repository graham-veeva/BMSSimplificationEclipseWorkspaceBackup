<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EM_Activity_Rejected_Email</fullName>
        <description>EM Activity Rejected Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMS_HCPTS_EM_Templates/Activity_Rejected_Template</template>
    </alerts>
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
    <alerts>
        <fullName>Notify_PO_and_SC_Activity_Approved</fullName>
        <description>Notify PO and SC Activity Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Event_Creator_Email_HCPTS__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Processor_Email_HCPTS__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMS_HCPTS_EM_Templates/Activity_Template_to_Creator</template>
    </alerts>
    <alerts>
        <fullName>Notify_PO_and_SC_Activity_Rejected</fullName>
        <description>Notify PO and SC Activity Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>Event_Creator_Email_HCPTS__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Processor_Email_HCPTS__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMS_HCPTS_EM_Templates/Activity_Rejected_Template</template>
    </alerts>
    <rules>
        <fullName>Notify Approver of Activity</fullName>
        <actions>
            <name>Notify_Approver_of_Activity</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>E-mail alert to notify approver for an Approval request</description>
        <formula>AND( 
TEXT(Action_Type_vod__c) = &apos;Submit_for_Approval_vod&apos; 
, Event_vod__r.RecordType.DeveloperName &lt;&gt; &apos;Simple_Activity_HCPTS&apos; 

)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify PO and SC Activity Approved</fullName>
        <actions>
            <name>Notify_PO_and_SC_Activity_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Event_History_vod__c.Action_Type_vod__c</field>
            <operation>equals</operation>
            <value>Approve_vod</value>
        </criteriaItems>
        <description>Notify Project Owner and Service Coordinator that the Activity has been approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify PO and SC Activity Rejected</fullName>
        <actions>
            <name>Notify_PO_and_SC_Activity_Rejected</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Event_History_vod__c.Action_Type_vod__c</field>
            <operation>equals</operation>
            <value>Reject_vod</value>
        </criteriaItems>
        <description>Notify the Project Owner and Service Coordinator that an Activity has been rejected</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
