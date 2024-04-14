insert or ignore into users(
  id, name)
values
  (1, "Stephanie"),
  (2, "Justin");

insert or ignore into shows(
  id, name, avg_duration)
values
  (1, "Equalizer", 44),
  (2, "Grey's Anatomy", 44);

insert or ignore into showlist(
  id, user_id, show_id)
values
  (1, 1, 1),
  (2, 1, 2);
