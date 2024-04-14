create table if not exists shows(
  id int not null primary key,
  name varchar(255),
  avg_duration int
);

create table if not exists users(
  id int not null primary key,
  name varchar(255)
);

create table if not exists usershows(
  id int not null primary key,
  user_id int,
  show_id int
);

create table if not exists schedule(
  id int not null primary key,
  user_id int
);

