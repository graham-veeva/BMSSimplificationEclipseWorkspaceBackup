public class ErbituxDropController {

    private ApexPages.StandardController controller;
    
    public ErbituxDropController(ApexPages.StandardController controller) {
        this.controller = controller;
    }

    public PageReference erbituxdropsave() {
        
         controller.save();
         PageReference erbituxdropPage = Page.Erbitux_Drop_Acknowledgement_Save;
         erbituxdropPage.setRedirect(true);
         return erbituxdropPage;
    }
}