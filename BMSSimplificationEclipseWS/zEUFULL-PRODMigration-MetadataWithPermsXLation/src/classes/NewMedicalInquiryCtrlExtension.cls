/*
* NewMedicalInquiryCtrlExtension
* Author: Mark Boyer, Veeva Systems
* Date: 2013-03-19
* Summary:
*  This controller extension supports a custom Medical Inquiries splash page on a per country/region basis.
*
* Updated by: Mark Boyer
* Date: 2013-03-19
* Summary: Added comments.
*
* Updated by:
* Date:  
* Summary: 
*
*/

public class NewMedicalInquiryCtrlExtension {
    public NewMedicalInquiryCtrlExtension(ApexPages.StandardSetController controller) {
    }
    public PageReference Accept(){
        String sAccountId = ApexPages.currentPage().getParameters().get('id');
        PageReference redirect = new PageReference('/a0t');
        return redirect;
    }
}