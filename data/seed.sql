insert into users( id, name )
  values (NULL, "steph"), (NULL, "justin");

insert into shows( id, name, runtime )
  values
    (NULL, "Equalizer", "43-44 minutes"),
    (NULL, "Grey's Anatomy", "43-53 minutes"),
    (NULL, "Slow Horses", "41-53 minutes"),
    (NULL, "Suits", "44 minutes");

insert into usershows( id, user_id, show_id )
  values (NULL, 1, 1),
         (NULL, 1, 2),
         (NULL, 2, 3),
         (NULL, 1, 4);
