/**
 * @description       : 
 * @author            : kevin@kevinwaites.com
 * @group             : 
 * @last modified on  : 09-26-2020
 * @last modified by  : kevin@kevinwaites.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   09-26-2020   kevin@kevinwaites.com   Initial Version
**/
trigger TaxReceiptTrigger on Tax_Receipt__c ( after insert, after update, before insert, before update) {
  TaxReceiptTriggerHandler handler = new TaxReceiptTriggerHandler(Trigger.isExecuting, Trigger.size);
    if( Trigger.isInsert ) {
      if(Trigger.isBefore) {
        handler.OnBeforeInsert(Trigger.New);
      } else {
        handler.OnAfterInsert(Trigger.New);
      }
    }
    else if ( Trigger.isUpdate ) {
      if(Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.New, Trigger.Old, Trigger.NewMap, Trigger.OldMap);
      }
      else {
        handler.OnAfterUpdate(Trigger.New, Trigger.Old, Trigger.NewMap, Trigger.OldMap);
      }
    }
}