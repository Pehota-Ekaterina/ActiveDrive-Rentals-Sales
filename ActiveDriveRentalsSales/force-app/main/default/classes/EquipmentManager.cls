@RestResource(urlMapping = '/equipment/*')
global with sharing class EquipmentManager {
    @HttpGet
    global static List<SObject> getEquipment() {
        RestRequest request = RestContext.request;
        String equipmentParam = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);

        List<SObject> resultList = new List<SObject>();
        //urlMapping = '/equipment/*' OR urlMapping = '/equipment/*/history'
        if (equipmentParam.equals('history')) {
            String equipmentId = request.requestURI.substringBetween('equipment/', '/history');
            List<Rental__c> rentalsList = [SELECT Id FROM Rental__c WHERE Equipment__c = :equipmentId];
            List<Sale__c> salesList = [SELECT Id FROM Sale__c WHERE Equipment__c = :equipmentId];
            resultList.addAll(rentalsList);
            resultList.addAll(salesList);
        } else {
            List<Equipment__c> EquipmentList = [SELECT Id, Name, Category__c, Daily_Rent_Price__c FROM Equipment__c WHERE Status__c = :equipmentParam];
            resultList.addAll(EquipmentList);
        }
        return resultList;
    }

    @HttpPost
    global static Rental__c createRental() {
        RestRequest request = RestContext.request;
        Id equipmentId;
        Id contactId;
        Date startDate;
        Date endDate;
        Id newRentalId;
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());
        String paramURI = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        if (paramURI.equals('rent')) {
            equipmentId = Id.valueOf(String.valueOf(params.get('equipmentId')));
            contactId = Id.valueOf(String.valueOf(params.get('contactId')));
            startDate = Date.valueOf(String.valueOf(params.get('startDate')));
            endDate = Date.valueOf(String.valueOf(params.get('endDate')));
            newRentalId = RentalService.createRental(equipmentId, contactId, startDate, endDate);
        }  else {
            throw new ApiException('POST is supported only /equipment/rent');
        }

        try {
            Rental__c newRental = [SELECT Id, Total_Amount__c FROM Rental__c WHERE Id = :newRentalId];
            return newRental;
        } catch (Exception e) {
            throw new ApiException('Rental is not created' + e.getMessage());
        }
    }

    @HttpDelete
    global static void deleteEquipment() {
        RestRequest request = RestContext.request;
        String equipmentId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        Equipment__c thisEquipment = [SELECT Id FROM Equipment__c WHERE Id = :equipmentId];
        delete thisEquipment;
    }



    public class ApiException extends Exception {}
}