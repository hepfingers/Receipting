/**
 * @description       : 
 * @author            : kevin@kevinwaites.com
 * @group             : 
 * @last modified on  : 09-26-2020
 * @last modified by  : kevin@kevinwaites.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   08-11-2020   kevin@kevinwaites.com   Initial Version
**/
@isTest
private class TestTaxReceiptCreation {
    @isTest static void testTaxReceiptCreationWithOpportunity() {
        // Test data setup
        // Create an account with an opportunity, and then try to make a Tax Receipt
        Account acct = new Account(Name='Test Account',
                                BillingStreet='123 here st.',
                                BillingCity='Calgary',
                                BillingState='Alberta',
                                BillingPostalCode='T3E 2E3',
                                BIllingCountry='Canada');
        insert acct;
        Opportunity opp = new Opportunity(  Name = acct.Name + ' Opportunity',
                                            StageName = 'Closed Won',
                                            CloseDate = System.today(),
                                            AccountId = acct.Id,
                                            Amount = 100,
                                            Personal_Benefit_Amount__c = 5,
                                            npsp__In_Kind_Description__c = 'Apex Test Pattern');
        insert opp;

        Tax_Receipt__c myTR = new Tax_Receipt__c (  Opportunity__c = opp.Id,
                                                    Name = 'a',
                                                    Amount__c = 5.00);
        // Perform test
        Test.startTest();
        
        insert myTR;
        Test.stopTest();        

        // Verify
        // Get the newly added Tax_Receipt__c
        Tax_Receipt__c newTR = [ SELECT Id, Name, Amount__c, City__c, Date_Issued__c, Eligible_Amount__c, Personal_Benefit_Amount__c, Postal_Code__c, Province__c, Street__c, Receipt_Rationale_Gift_Description__c FROM Tax_Receipt__c WHERE Id = :myTR.Id LIMIT 1];
        
        // veryify that the Tax Receipt was creted with the right fields from the Opportunity and the Account
        // System.assertEquals( 1, newTR.size(), 'should have found new Tax_Receipt__c' );
        System.assertEquals(opp.Amount, newTR.Amount__c, 'incorrect Amount');
        System.assertEquals(opp.Name + ' - Receipt', newTR.Name, 'incorrect name');
        System.assertEquals(acct.BillingCity, newTR.City__c, 'incorrect City');
        System.assertEquals(System.today(), newTR.Date_Issued__c, 'incorrect Date issued');
        System.assertEquals(opp.Amount - opp.Personal_Benefit_Amount__c, newTR.Eligible_Amount__c, 'incorrect eligible amount');
        System.assertEquals(opp.Personal_Benefit_Amount__c, newTR.Personal_Benefit_Amount__c, 'incorrect personal benefit amount');
        System.assertEquals(acct.BillingPostalCode, newTR.Postal_Code__c, 'incorrect Postal Code');
        System.assertEquals(acct.BillingState, newTR.Province__c, 'incorrect province');
        System.assertEquals(acct.BillingStreet, newTR.Street__c, 'incorrect street');
        System.assertEquals(opp.npsp__In_Kind_Description__c, newTR.Receipt_Rationale_Gift_Description__c, 'incorrect description');
        }
}
