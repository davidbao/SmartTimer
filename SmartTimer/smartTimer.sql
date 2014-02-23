drop table if exists Plans;

drop table if exists Tasks;

/*==============================================================*/
/* Table: Plans                                                 */
/*==============================================================*/

create table Plans
(
   Id			integer				not null,
   Name			char(16)			not null,
   Interval		integer				not null,
   CurrentTime	datetime			not null,
   primary key (Id)
);
