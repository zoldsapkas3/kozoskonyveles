CREATE OR REPLACE PACKAGE KDOC.security_pkg
AS
    PROCEDURE log_invalid_login (p_username   IN kreg_users.username%TYPE
                               , p_msg        IN VARCHAR2
                                );

    FUNCTION is_user_active (p_username IN VARCHAR2, p_type NUMBER)
        RETURN BOOLEAN;

    FUNCTION authenticate_user (p_username VARCHAR2, p_password VARCHAR2)
        RETURN BOOLEAN;

    PROCEDURE process_login (p_username   VARCHAR2
                           , p_password   VARCHAR2
                           , p_app_id     NUMBER
                            );

    FUNCTION get_password (p_password   IN VARCHAR2
                         , p_salt       IN kreg_users.sslt%TYPE
                          )
        RETURN VARCHAR2;

    FUNCTION gen_salt
        RETURN VARCHAR2;
END security_pkg;
/