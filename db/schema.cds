using { cuid, managed, temporal } from '@sap/cds/common';
namespace com.conciletime.rescuetime;

entity Slices : cuid, managed, temporal {
  account       : String;
  application   : String;
  document      : String;
}

