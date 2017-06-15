public class WebCalloutController {

private final String certName = '';


public string getValue(){

    
    String body = '';
    

    Http h = new Http();

    HttpRequest req = new HttpRequest();

    req.setEndpoint('https://gate-test.bms.com/uscm/HelloWorld');
    req.setClientCertificateName('BMS_Gateway_X');
    //req.setHeader('Username', 'usveeva');
    //req.setHeader('Password', 'usi82muchveeva');
    req.setBody('<sayHello>Hello</sayHello>');
    req.setMethod('POST');

    
    
     

    // Send the request, and return a response  
    
    HttpResponse res = h.send(req);
    return res.getBody();
}  
    
}