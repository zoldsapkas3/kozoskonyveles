CREATE OR REPLACE PACKAGE BODY KDOC.security_pkg
IS
    PROCEDURE log_invalid_login (p_username   IN kreg_users.username%TYPE
                               , p_msg        IN VARCHAR2
                                )
    IS
    BEGIN
        INSERT INTO invalid_logins t (t.msg, t.who)
             VALUES (p_msg, p_username);
    END log_invalid_login;

    FUNCTION is_user_active (p_username IN VARCHAR2, p_type IN NUMBER)
        RETURN BOOLEAN
    IS
        l_active   kreg_users.active%TYPE;
    BEGIN
        IF p_type = 1
        THEN
            SELECT t.active
              INTO l_active
              FROM kreg_users t
             WHERE t.username = p_username;
        ELSE
            SELECT t.active
              INTO l_active
              FROM kreg_users t
             WHERE t.mail = p_username;
        END IF;

        RETURN CASE WHEN l_active = 1 THEN TRUE ELSE FALSE END;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            security_pkg.log_invalid_login (p_username
                                          , 'username/e-mail not found'
                                           );
            RETURN FALSE;
    END is_user_active;

    FUNCTION authenticate_user (p_username VARCHAR2, p_password VARCHAR2)
        RETURN BOOLEAN
    AS
        l_password           kreg_users.password%TYPE;
        l_salt               kreg_users.sslt%TYPE;
        l_email              kreg_users.mail%TYPE;
        incorrect_password   EXCEPTION;
        user_is_locked       EXCEPTION;
    BEGIN
        --Check if the entered username is mail address or not
        IF NOT REGEXP_LIKE (p_username
                          , '[[:alnum:]]+@[[:alnum:]]+\.[[:alnum:]]'
                           )
        THEN
            IF security_pkg.is_user_active (LOWER (p_username), 1)
            THEN
                SELECT ku.password, ku.sslt
                  INTO l_password, l_salt
                  FROM kreg_users ku
                 WHERE ku.username = LOWER (p_username);

                IF l_password =
                   pbkdf2_pkg.get_password (UTL_RAW.cast_to_raw (p_password)
                                          , l_salt
                                           )
                THEN
                    INSERT INTO logs t (t.msg)
                         VALUES ('good pw');

                    RETURN TRUE;
                ELSE
                    INSERT INTO logs t (t.msg)
                         VALUES ('incorrect pw');

                    RAISE incorrect_password;
                END IF;
            ELSE
                RAISE user_is_locked;
            END IF;
        ELSE
            --e-mail password validations
            IF security_pkg.is_user_active (LOWER (p_username), 2)
            THEN
                SELECT ku.password, ku.sslt
                  INTO l_password, l_salt
                  FROM kreg_users ku
                 WHERE ku.mail = LOWER (p_username);

                IF l_password = pbkdf2_pkg.get_password (p_password, l_salt)
                THEN
                    RETURN TRUE;
                ELSE
                    RAISE incorrect_password;
                END IF;
            ELSE
                RAISE user_is_locked;
            END IF;
        END IF;
    --Application will provide error message
    EXCEPTION
        WHEN user_is_locked
        THEN
            security_pkg.log_invalid_login (
                p_username
              , 'User is locked or user not found');
            RETURN FALSE;
        WHEN incorrect_password
        THEN
            security_pkg.log_invalid_login (p_username, 'Incorrect password');
            RETURN FALSE;
    END authenticate_user;

    --------------------------------------

    PROCEDURE process_login (p_username   VARCHAR2
                           , p_password   VARCHAR2
                           , p_app_id     NUMBER
                            )
    AS
        l_result   BOOLEAN := FALSE;
    BEGIN
        l_result   := authenticate_user (p_username, p_password);

        IF l_result = TRUE
        THEN
            -- Redirect to Page 1 (Home Page).
            wwv_flow_custom_auth_std.post_login (p_username      -- p_username
                                               , p_password      -- p_Password
                                               , v ('APP_SESSION') -- p_Session_Id
                                               , p_app_id || ':1' -- p_Flow_page
                                                );
        ELSE
            -- Login Failure, redirect to page 101 (Login Page).
            OWA_UTIL.redirect_url ('f?p=:101:12345678');
        END IF;
    END process_login;

    FUNCTION get_password (p_password   IN VARCHAR2
                         , p_salt       IN kreg_users.sslt%TYPE
                          )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN pbkdf2_pkg.get_password (p_password, p_salt);
    END get_password;

    FUNCTION gen_salt
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN pbkdf2_pkg.gen_salt;
    END gen_salt;
END security_pkg;
/