using { com.conciletime.rescuetime as rt } from '../db/schema';
service AdminService @(_requires:'authenticated-user') {
  entity Slices as projection on rt.Slices;
}:
