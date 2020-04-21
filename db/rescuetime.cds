namespace rescuetime;

using { cuid } from '@sap/cds/common';
using { managed } from '@sap/cds/common';
using { temporal } from '@sap/cds/common';

entity Slices : cuid, managed, temporal {
  account   : String;
  application   : String;
  document   : String;
}

@cds.persistence.exists
entity Slices_Duration {
  key ID : String(36); 
  Application : String(5000);
  Document : String(5000);
  SliceTime : DateTime;
  Duration : Integer;
}
