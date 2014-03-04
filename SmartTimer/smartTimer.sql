drop table if exists Plans;

drop table if exists Tasks;

drop table if exists TaskTimes;

/*==============================================================*/
/* Table: Plans                                                 */
/*==============================================================*/

create table Plans
(
   Id			integer				not null,
   Name			char(16),
   Interval		integer				not null,
   CurrentTime	datetime			not null,
   primary key (Id)
);

/*==============================================================*/
/* Table: Tasks                                                 */
/*==============================================================*/

create table Tasks
(
   Id			integer				not null,
   PlanId       integer             not null,
   StartTime	datetime			not null,
   primary key (Id)
);

create table TaskTimes
(
   Id			integer				not null,
   TaskId		integer				not null,
   Interval     integer				not null,
   primary key (Id)
);
