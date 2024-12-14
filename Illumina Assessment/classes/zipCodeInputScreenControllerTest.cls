@isTest
public class zipCodeInputScreenControllerTest {

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"country":"United States","post code":"10001","places":[{"place name":"New York","state":"NY"}]}');
            return res;
        }
    }

    @isTest
    public static void testGetLocationData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String zipCode = '10001';
        String baseUrl = 'https://mock-api.com';
        
        Test.startTest();
        zipCodeInputScreenController.LocationData locationData = zipCodeInputScreenController.getLocationData(zipCode, baseUrl);
        Test.stopTest();
        System.assertEquals('New York', locationData.city);
        System.assertEquals('United States', locationData.country);
        System.assertEquals('10001', locationData.zipcode);
        System.assertEquals('NY', locationData.state);
    }

    @isTest
    public static void testSaveNonUSData() {
        zipCodeInputScreenController.LocationData locationData = new zipCodeInputScreenController.LocationData();
        locationData.city = 'Los Angeles';
        locationData.country = 'United States';
        locationData.state = 'CA';
        locationData.zipcode = '90001';

        Test.startTest();
        
        zipCodeInputScreenController.saveNonUSData(locationData);
        
        Test.stopTest();
        
        List<ZipCodeData__c> records = [SELECT Zipcode__c, Country__c, Place__c, State__c FROM ZipCodeData__c WHERE Zipcode__c = '90001'];
        System.assertEquals(1, records.size());
        System.assertEquals('United States', records[0].Country__c);
        System.assertEquals('Los Angeles', records[0].Place__c);
        System.assertEquals('CA', records[0].State__c);
        System.assertEquals('90001', records[0].Zipcode__c);
    }
}