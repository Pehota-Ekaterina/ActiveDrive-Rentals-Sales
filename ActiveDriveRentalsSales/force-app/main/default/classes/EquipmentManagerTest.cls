@IsTest
private class EquipmentManagerTest {

    @TestSetup
    static void makeData(){
        List<Equipment__c> equipmentsList = new List<Equipment__c>();
        for (Integer i = 0; i < 5; i++) {
            Equipment__c equipment = new Equipment__c(
            Name = 'Test' + i,
            Category__c = 'Bicycle',
            Status__c = 'Available',
            Daily_Rent_Price__c = 50.0
            );
            equipmentsList.add(equipment);
        }
        insert equipmentsList;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Test');
        insert contact;
    }

    @IsTest
    static void testGetEquipment() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/equipment/available';
    	request.httpMethod = 'GET';
        RestContext.request = request;
        
        List<Equipment__c> result = EquipmentManager.getEquipment();
        List<Equipment__c> resultSOQL= [SELECT Id FROM Equipment__c WHERE Status__c = 'Available'];
        System.assert(result != null);
        System.assertEquals(resultSOQL.size(), result.size());
    }

    @IsTest
    static void testDeleteEquipment() {
        RestRequest request = new RestRequest();
        Equipment__c eqDelete = [SELECT Id FROM Equipment__c LIMIT 1];
        request.requestURI = '/services/apexrest/equipment/' + eqDelete.Id;
    	request.httpMethod = 'Delete';
        RestContext.request = request;
        
        EquipmentManager.deleteEquipment();
        List<Equipment__c> resultSOQL= [SELECT Id FROM Equipment__c WHERE Id=:eqDelete.ID];
        Assert.isTrue(resultSOQL.size() == 0);
    }

    @IsTest
    static void testCreateRental() {
        Equipment__c equipment = [SELECT Id, Daily_Rent_Price__c FROM Equipment__c WHERE Status__c = 'Available' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('equipmentId', equipment.Id);
        requestBody.put('contactId', contact.Id);
        requestBody.put('startDate', Date.today());
        requestBody.put('endDate', Date.today().addDays(3));

        String jsonBody = JSON.serialize(requestBody);

        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/equipment/rent';
        request.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = request;

        Rental__c result = EquipmentManager.createRental();
        System.assert(result.Id != null);
        Rental__c resultSOQL= [SELECT Id, Equipment__c, Customer__c FROM Rental__c WHERE Id=:result.Id];
        System.assertEquals(equipment.Id, resultSOQL.Equipment__c);
        System.assertEquals(contact.Id, resultSOQL.Customer__c);
        System.assertEquals(equipment.Daily_Rent_Price__c * 4, result.Total_Amount__c);        
    }
}