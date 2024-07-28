# DESCRIBE SYSTEM CONFIG
CONFIGURE INSTANCE SET session_idle_transaction_timeout := <std::duration>'PT10S';

# DESCRIBE ROLES
ALTER ROLE edgedb { SET password_hash := 'SCRAM-SHA-256$4096:uW/qwJYN670oH0drUrqR+g==$75aALunV2+1FahpEUh74VDSTys4mauysRRd/uafN7gE=:kCGhj9XQIWjla4CjzWPscgoyuyMOwD0RLHJSkXowhU0=';};
