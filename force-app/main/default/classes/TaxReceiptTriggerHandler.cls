/**
 * @description       : Trigger handler for Tax_Receipt__c
 * @author            : kevin@kevinwaites.com
 * @last modified on  : 09-27-2020
 * @last modified by  : kevin@kevinwaites.com
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   08-06-2020   kevin@kevinwaites.com                Initial Version
**/

public with sharing class TaxReceiptTriggerHandler {

    //public with sharing class TaxReceiptTriggerHandler {
        
        private boolean isExecuting = false;
        private integer batchSize = 0;
        public static boolean isFromBatchJob;
        public static boolean isFromUploadAPI = false;
    
        public TaxReceiptTriggerHandler(Boolean isExecuting, integer size) {
            isExecuting = isExecuting;
            BatchSize = size;
        }
    
        /**
        * @description      : Updates the fields on a new Tax_Receipt__c stamping them with 
        *                     related fields from Opportunity and Account
        * @author           : kevin@kevinwaites.com
        * @param            : newTaxReceipts 
        **/
        public void onBeforeInsert(List<Tax_Receipt__c> newTaxReceipts) {
    
            Set<Id> opportunityIds = new Set<Id>();
    
            for(Tax_Receipt__c thisTR:newTaxReceipts) {
                if(thisTR.Opportunity__c != null) {
                    opportunityIds.add(thisTR.Opportunity__c);
                }
            }
    
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT ID, Name, Amount, Eligible_Amount__c, Personal_Benefit_Amount__c, npsp__Primary_Contact__c, npsp__In_Kind_Description__c, Account.BillingCity, Account.BillingCountry, Account.BillingStreet, Account.BillingState, Account.BillingPostalCode, Account.Name  FROM Opportunity WHERE Id IN:opportunityIds]);
            List<Tax_Receipt_Number__c> trnList = new List<Tax_Receipt_Number__c>();
            List<Business_Receipt_Number__c> brnList = new List<Business_Receipt_Number__c>();
            for(Tax_Receipt__c tr:newTaxReceipts) {
                if(opportunityMap.containsKey(tr.Opportunity__c)) {
                    try {
                        Opportunity oppty = opportunityMap.get(tr.Opportunity__c);
                        tr.Amount__c = oppty.Amount;
                        tr.Name = oppty.Name + ' - Receipt';
                        tr.City__c = oppty.Account.BillingCity;
                        tr.Date_Issued__c = Date.today();
                        tr.Eligible_Amount__c = oppty.Eligible_Amount__c;
                        tr.Personal_Benefit_Amount__c = oppty.Personal_Benefit_Amount__c;
                        tr.Postal_Code__c = oppty.Account.BillingPostalCode;
                        tr.Province__c = oppty.Account.BillingState;
                        tr.Street__c = oppty.Account.BillingStreet;
                        tr.Receipt_Rationale_Gift_Description__c = oppty.npsp__In_Kind_Description__c;
                        
                        
                        if(oppty.npsp__Primary_Contact__c != Null){
                            tr.To__c = oppty.Npsp__Primary_Contact__c;
                        } else {
                            tr.To__c = oppty.Account.Name;
                        }
    
                        if(oppty.Eligible_Amount__c > 0) {
                            Tax_Receipt_Number__c trn = New Tax_Receipt_Number__c( Tax_Receipt__c = tr.Id);
                            tr.Receipt_Number__c = trn.Name;
                            trnList.add(trn);
                        } else {
                            Business_Receipt_Number__c brn = New Business_Receipt_Number__c( Tax_Receipt__c = tr.Id);
                            tr.Receipt_Number__c = brn.Name;
                            brnList.add(brn);
                        }
                        
                        // TODO: Add to Tax Receipt
                        // t.Number_of_Gifts = 
                        // t.Receipt_Number__c = 
                        // t.Receipt_Rationale_Gift_Description__c = 
                        // t.Tax_Year_Received__c = 
                        
                        
                    } catch (Exception e) {
                        System.debug('Error setting fields on this record:  ' + e.getMessage());
                        System.debug('On Line:  ' + e.getLineNumber());
                        tr.addError('Unable to update fields');
                    }
                }
            }
    
            if(!trnList.isEmpty()) {
                // Strip fields that are not creatable
                SObjectAccessDecision decision = Security.stripInaccessible(
                    AccessType.CREATABLE,
                    trnList);
                try{
                    insert decision.getRecords();
                } catch(NoAccessException e) {
                    system.debug(e.getMessage());
                }
                
                // Print removed fields
                System.debug(decision.getRemovedFields());
            }
            
            if(!brnList.isEmpty()) {
                // Strip fields that are not creatable
                SObjectAccessDecision decision = Security.stripInaccessible(
                    AccessType.CREATABLE,
                    brnList);
                try{
                    insert decision.getRecords();
                } catch(NoAccessException e) {
                    system.debug(e.getMessage());
                }
                
                // Print removed fields
                System.debug(decision.getRemovedFields());
            }
        }
    
        public void onAfterInsert(List<Tax_Receipt__c> newTaxReceipt) {
            system.debug('Tax Receipt Trigger on After Insert');
        }
    
        public void onAfterUpdate( List<Tax_Receipt__c> newTaxReceipt, List<Tax_Receipt__c> oldTaxReceipt, Map<ID, Tax_Receipt__c> newTaxReceiptMap, Map<ID, Tax_Receipt__c> oldTaxReceiptMap ) {
            system.debug('Tax Receipt Trigger On After Update');
        }
    
        public void onBeforeUpdate( List<Tax_Receipt__c> newTaxReceipt, List<Tax_Receipt__c> oldTaxReceipt, Map<ID, Tax_Receipt__c> newTaxReceiptMap, Map<ID, Tax_Receipt__c> oldTaxReceiptMap ) {
            system.debug('Tax Receipt Trigger On Before Update');
        }
    
        @future
        public static void onAfterUpdateAsync(Set<ID> newTaxReceiptIDs) {
    
        }
    
        public boolean isTriggerContext {
            get { return isExecuting; }
        }
    
        public boolean isVisualforcePageContext {
            get{ return !IsTriggerContext; }
        }
    
        public boolean isWebServiceContext {
            get{ return !IsTriggerContext; }
        }
    
        public boolean isExecuteAnonymousContext {
            get{ return !isTriggerContext; }
        }
    
        // TODO: upgrade the app to use Custom Metadata to manage the receipt numbers
        // These 2 methodsd don't work 
        // you can't use DML statments on Custom Metadata
        // private Decimal getNextTaxReceiptNumber() {
        //     Decimal nextNum = 0;
        //     try{
        //         Tax_Receipt_Number_meta__mdt myMeta = [SELECT Next_Number__c FROM Tax_Receipt_Number_meta__mdt WITH SECURITY_ENFORCED];
        //         nextNum = myMeta.Next_Number__c;
        //     } catch(System.QueryException qe) {
        //         System.debug(qe.getMessage());
        //     }
        //     return nextNum;
        // }
    
        // private void incrementTaxReceiptNumber() {
        //     try {
        //         Tax_Receipt_Number_meta__mdt myMeta = [SELECT Id, Next_Number__c FROM Tax_Receipt_Number_meta__mdt WITH SECURITY_ENFORCED];
        //         myMeta.Next_Number__c ++;
        //         // update myMeta;  
        //     } catch(System.QueryException qe) {
        //         System.debug(qe.getMessage());
        //     }
            
        // }
    }