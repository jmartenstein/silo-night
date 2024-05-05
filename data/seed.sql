insert or ignore into users(
  id, name)
values
  (1, "steph"),
  (2, "justin");

insert or ignore into shows(
  id, name, avg_duration)
values
  (1, "Equalizer", 44),
  (2, "Grey's Anatomy", 44),
  (3, "Slow Horses", 42);

insert or ignore into usershows(
  id, user_id, show_id)
values
  (1, 1, 1),
  (2, 1, 2),
  (3, 2, 3);
