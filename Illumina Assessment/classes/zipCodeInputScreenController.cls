public with sharing class zipCodeInputScreenController {

    @AuraEnabled
    public static LocationData getLocationData(String zipCode, String baseUrl) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(baseUrl);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);

        LocationData locationData = new LocationData();

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> places = (List<Object>) responseMap.get('places');
            Map<String, Object> placeDetails = (Map<String, Object>) places[0];
            locationData.city = (String) placeDetails.get('place name');
            locationData.country = (String) responseMap.get('country');
            locationData.zipcode = (String) responseMap.get('post code');
            locationData.state = (String) placeDetails.get('state');
        } else {
            throw new AuraHandledException('Error fetching data');
        }

        return locationData;
    }

    public class LocationData {
        @AuraEnabled public String city {get;set;}
        @AuraEnabled public String country  {get;set;}
        @AuraEnabled public String state  {get;set;}
        @AuraEnabled public String zipcode  {get;set;}
    }
    @AuraEnabled
    public static void saveNonUSData(LocationData data) {
        List<ZipCodeData__c> recordsToInsert = new List<ZipCodeData__c>();
        ZipCodeData__c record = new ZipCodeData__c();
        record.Zipcode__c = data.zipcode;
        record.Country__c = data.country;
        record.Place__c = data.city;
        record.State__c = data.state;
        recordsToInsert.add(record);
        insert recordsToInsert;
    }
}