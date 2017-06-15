public with sharing class VOD_Documentation_Controller {
    /**
     * Determines the appropriate URL for documentation redirect.
     * Bases decision on org's base Veeva server URL. If the org is
     * Directed at the production servers, then documentation is retrieved from there as well.
     */
    public String getDocUrl() {
        String baseUrl = VOD_Common.VOD_SERVER_URL;
        
        if (Pattern.matches('https://(vs|na)\\d+[.]vod309[.]com', baseUrl)) {
            baseUrl = 'https://crmhelp.veeva.com';
        } else if ('https://qa.vod309.com'.equals(baseUrl)) {
            baseUrl = 'https://crmhelp-qa.veeva.com';
        }
        return baseUrl + '/doc/';           
    }
}