public class AbilifyDropController {

    private ApexPages.StandardController controller;
    
    public AbilifyDropController(ApexPages.StandardController controller) {
        this.controller = controller;
    }

    public PageReference abilifydropsave() {
        
         controller.save();
         PageReference abilifydropPage = Page.Abilify_Drop_Acknowledgement_Save;
         abilifydropPage.setRedirect(true);
         return abilifydropPage;
    }
}