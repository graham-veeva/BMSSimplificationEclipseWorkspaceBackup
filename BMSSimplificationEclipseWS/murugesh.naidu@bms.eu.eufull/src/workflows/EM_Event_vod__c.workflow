<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EM_7_Day_after_end_date_notification</fullName>
        <ccEmails>sarah.young@veeva.com</ccEmails>
        <description>EM 7 Day after end date notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/EM_7_Days_Post_Event</template>
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
        <fullName>Notify_User_of_EM</fullName>
        <description>Notify EM User of Post Event Status</description>
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
        <fullName>UpdateEventStatusPostEventApproval</fullName>
        <field>Status_vod__c</field>
        <literalValue>Post-Event-PostApproval</literalValue>
        <name>UpdateEventStatus-Post-EventApproval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
        <fullName>Alert Activity Owner close to Event End Date</fullName>
        <active>true</active>
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
            <operation>equals</operation>
            <value>Simple Activity</value>
        </criteriaItems>
        <description>Em Activity Canceled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify EM Owner and SC of Post Event</fullName>
        <actions>
            <name>Notify_User_of_EM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Event_vod__c.Status_vod__c</field>
            <operation>equals</operation>
            <value>Post-Event</value>
        </criteriaItems>
        <description>Notification of EM Owner and Service Coordinator that the Event has moved to a Post-Event status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
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
