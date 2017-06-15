<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Address_HCPTS</fullName>
        <field>Address_Line_1_HCTPS__c</field>
        <formula>Account_vod__r.ShippingStreet</formula>
        <name>Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Address_Update1</fullName>
        <description>Concat Address fields into Address_vod</description>
        <field>Address_vod__c</field>
        <formula>Address_Line_1_HCTPS__c  + &apos;,&apos; + City_HCPTS__c + &apos; &apos; +  Text(Country_Lookup_HCPTS__r.Country_Name_vod__c )</formula>
        <name>Address Update1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Address_Update2</fullName>
        <field>Address_vod__c</field>
        <formula>Address_Line_1_HCTPS__c + &apos;,&apos; + City_HCPTS__c + &apos; &apos; + Text(Country_Lookup_HCPTS__r.Country_Name_vod__c )</formula>
        <name>Address Update2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Address_vod_Update</fullName>
        <description>concatenates address fields to create a text string</description>
        <field>Address_vod__c</field>
        <formula>Address_Line_1_HCTPS__c &amp; &quot;,&quot; &amp; Address_Line_2_HCPTS__c &amp; City_HCPTS__c &amp; &quot;,&quot; &amp; State_Province_HCPTS__c &amp; &quot;,&quot; &amp; Zip_Code_HCPTS__c &amp; &quot;,&quot; &amp; Country_Lookup_HCPTS__r.Alpha_2_Code_vod__c</formula>
        <name>Address vod Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>City_HCPTS</fullName>
        <field>City_HCPTS__c</field>
        <formula>Account_vod__r.ShippingCity</formula>
        <name>City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Country_HCPTS</fullName>
        <field>Country_HCPTS__c</field>
        <formula>Account_vod__r.ShippingCountry</formula>
        <name>Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Email_HCPTS</fullName>
        <field>Email_HCPTS__c</field>
        <formula>Account_vod__r.Email_text_format_BMS_SHARED__c</formula>
        <name>Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fax</fullName>
        <field>Fax_HCPTS__c</field>
        <formula>Account_vod__r.Fax</formula>
        <name>Fax</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>First_Name_HCPTS</fullName>
        <field>First_Name_HCPTS__c</field>
        <formula>Account_vod__r.FirstName</formula>
        <name>First Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IsPersonAccount</fullName>
        <field>IsPersonAccount_HCPTS__c</field>
        <literalValue>0</literalValue>
        <name>IsPersonAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IsPersonAccount_HCPTS</fullName>
        <field>IsPersonAccount_HCPTS__c</field>
        <literalValue>1</literalValue>
        <name>IsPersonAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Last_Name_HCPTS</fullName>
        <field>Last_Name_HCPTS__c</field>
        <formula>Account_vod__r.LastName</formula>
        <name>Last Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Middle_HCPTS</fullName>
        <field>Middle_vod_HCPTS__c</field>
        <formula>Account_vod__r.Middle_vod__c</formula>
        <name>Middle</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mobile_HCPTS</fullName>
        <field>Mobile_HCPTS__c</field>
        <formula>Account_vod__r.PersonMobilePhone</formula>
        <name>Mobile</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Phone_HCPTS</fullName>
        <field>Phone_HCPTS__c</field>
        <formula>Account_vod__r.Phone</formula>
        <name>Phone HCPTS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Postal_Code</fullName>
        <field>Zip_Code_HCPTS__c</field>
        <formula>Account_vod__r.ShippingPostalCode</formula>
        <name>Postal Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Speaker_Update_Master_ID</fullName>
        <description>Update Master ID with Customer Master ID from Account</description>
        <field>BP_ID_BMS_CORE_HCPTS__c</field>
        <formula>Account_vod__r.BP_ID_BMS_CORE__c</formula>
        <name>Speaker: Update Master ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Speaker_Updated_Customer_ID</fullName>
        <description>Update Customer ID with Global Customer ID from Account if Account exists</description>
        <field>BP_ID_BMS_CORE_HCPTS__c</field>
        <formula>Customer_Master_ID_HCPTS__c</formula>
        <name>Speaker Updated Customer ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Specialty_HCPTS</fullName>
        <field>Specialty_1_vod_HCPTS__c</field>
        <formula>Account_vod__r.Specialty_BMS_EMEA__r.Name</formula>
        <name>Specialty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>State_HCPTS</fullName>
        <field>State_Province_HCPTS__c</field>
        <formula>Account_vod__r.ShippingState</formula>
        <name>State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Title_Field_on_Service_Provider</fullName>
        <description>Update Title Field on Service Provider</description>
        <field>Title_HCPTS__c</field>
        <formula>Account_vod__r.Title_BMS_EMEA__r.Name</formula>
        <name>Update Title Field on Service Provider</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account Info Copy HCPTS</fullName>
        <actions>
            <name>Address_HCPTS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>City_HCPTS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Country_HCPTS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Email_HCPTS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>First_Name_HCPTS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Last_Name_HCPTS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Phone_HCPTS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Specialty_HCPTS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>State_HCPTS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Title_Field_on_Service_Provider</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copy over Account information to the Speaker</description>
        <formula>AND(not(isblank((Account_vod__c))),  OR (ISNEW(), ISCHANGED(Account_vod__c))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Account Info Copy HCPTS2</fullName>
        <actions>
            <name>Postal_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copy over Account information to the Speaker</description>
        <formula>AND(not(isblank((Account_vod__c))),  OR (ISNEW(), ISCHANGED(Account_vod__c))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Service Provider Address Merge</fullName>
        <actions>
            <name>Address_Update1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Speaker_vod__c.Address_Line_1_HCTPS__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Service Provider Address Merge MANUAL</fullName>
        <actions>
            <name>Address_Update2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Adding an address manually updates the address field</description>
        <formula>isblank((Account_vod__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Speaker IsPerson Association</fullName>
        <actions>
            <name>IsPersonAccount_HCPTS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Account Record Type = Person Account, IsPersonAccount = True</description>
        <formula>Account_vod__r.RecordTypeId = &quot;012d0000000wwg8AAA&quot; ||  Account_vod__r.RecordTypeId = &quot;012d0000000XJVOAA4&quot; ||  Account_vod__r.RecordTypeId = &quot;012d0000000wwg9AAA&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Speaker Update Customer Master ID</fullName>
        <actions>
            <name>Speaker_Updated_Customer_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Speaker_vod__c.Customer_Master_ID_HCPTS__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If there is an Account(Customer) linked to the speaker, updated the Customer Master ID with the Customer Master ID on the account</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Speaker not IsPerson Association</fullName>
        <actions>
            <name>IsPersonAccount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Unchecks a box when an Account association doesn&apos;t exists with a speaker</description>
        <formula>ISBLANK( Account_vod__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Speaker%3A Update Address Field</fullName>
        <actions>
            <name>Address_vod_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5</booleanFilter>
        <criteriaItems>
            <field>EM_Speaker_vod__c.Address_Line_1_HCTPS__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>EM_Speaker_vod__c.Address_Line_2_HCPTS__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>EM_Speaker_vod__c.City_HCPTS__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>EM_Speaker_vod__c.State_Province_HCPTS__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>EM_Speaker_vod__c.Zip_Code_HCPTS__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Updates the Address field so that it will show when selecting a speaker</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Speaker%3A Update Master ID</fullName>
        <actions>
            <name>Speaker_Update_Master_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Master ID field if there is a Customer (Account) linked to the Speaker</description>
        <formula>NOT(ISBLANK(Account_vod__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
