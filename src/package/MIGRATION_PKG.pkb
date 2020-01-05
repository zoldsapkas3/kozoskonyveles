CREATE OR REPLACE PACKAGE BODY KDOC.migration_pkg
IS
    PROCEDURE update_user_password (p_username IN kreg_users.username%TYPE)
    IS
        l_salt   kreg_users.sslt%TYPE;
    BEGIN
        l_salt   := security_pkg.gen_salt;

        UPDATE kreg_users t
           SET t.password   = security_pkg.get_password (t.password, l_salt)
             , t.sslt       = l_salt
         WHERE t.username = p_username;
    END update_user_password;

    PROCEDURE doc_users_mig
    IS
    BEGIN
        --Merge is not a good option here, rather delete the same users and then reinsert (if exists)
        DELETE FROM kreg_users t
              WHERE t.username IN (SELECT x.user_name
                                     FROM doc_users x);

        DBMS_OUTPUT.put_line (
            'deleted users count: ' || TO_CHAR (SQL%ROWCOUNT));

        INSERT INTO kreg_users t (t.username
                                , t.password
                                , t.sslt
                                , t.active
                                , t.mail
                                , t.first_name
                                , t.last_name
                                , t.user_type
                                 )
            SELECT CASE
                       WHEN x.user_name LIKE '%@%' OR x.user_name LIKE '%.%'
                       THEN
                           LOWER (REGEXP_SUBSTR (x.user_name
                                               , '[^.@]+'
                                               , 1
                                               , 1
                                                )
                                 )
                       ELSE
                           LOWER (x.user_name)
                   END
                 , UTL_RAW.cast_to_raw (x.password)
                 , 'INVALIDSALT'
                 , CASE WHEN x.active = 'Y' THEN 1 ELSE 0 END
                 , CASE
                       WHEN NOT REGEXP_LIKE (
                                    x.email
                                  , '[A-Za-z0-9._%-]+@[A-Za-z0-9._%-]+\.[A-Za-z]{2,4}')
                       THEN
                              'inv_mail_'
                           || ROUND (DBMS_RANDOM.VALUE () * 1000000)
                           || '@invmail.com'
                       ELSE
                           x.email
                   END
                 , SUBSTR (full_name, INSTR (full_name, ' ') + 1)
                 , SUBSTR (full_name, 0, INSTR (full_name, ' ') - 1)
                 , CASE x.user_type
                       WHEN 'admin' THEN 1
                       WHEN 'book' THEN 2
                       WHEN 'manager' THEN 3
                       ELSE NULL
                   END
              FROM doc_users x;


        DBMS_OUTPUT.put_line (
            'inserted users count: ' || TO_CHAR (SQL%ROWCOUNT));

        FOR c1 IN (SELECT t.username
                     FROM kreg_users t
                    WHERE t.sslt = 'INVALIDSALT')
        LOOP
            DBMS_OUTPUT.put_line ('updating password for ' || c1.username);
            update_user_password (c1.username);
        END LOOP;
    END doc_users_mig;
END migration_pkg;
/