create table if not exists shows(
  id integer primary key,
  name varchar(255) not null unique,
  runtime varchar(255)
);

create table if not exists users(
  id integer primary key,
  name varchar(255) not null unique
);

create table if not exists usershows(
  id integer primary key,
  user_id int not null,
  show_id int not null
);

create table if not exists schedule(
  id integer primary key,
  user_id int
);

