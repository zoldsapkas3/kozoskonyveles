CREATE OR REPLACE PACKAGE BODY KDOC.registration_pkg
AS
    PROCEDURE user_registration (
        p_username         IN kreg_users.username%TYPE
      , p_password         IN VARCHAR2
      , p_mail             IN kreg_users.mail%TYPE
      , p_first_name       IN kreg_users.first_name%TYPE
      , p_last_name        IN kreg_users.last_name%TYPE
      , p_title            IN kreg_users.title%TYPE
      , p_phone_cellular   IN kreg_users.phone_cellular%TYPE
      , p_phone_landline   IN kreg_users.phone_landline%TYPE)
    IS
        l_salt   kreg_users.sslt%TYPE := security_pkg.gen_salt;
    BEGIN
        --user insert
        INSERT INTO kreg_users t (t.username
                                , t.password
                                , t.sslt
                                , t.active
                                , t.mail
                                , t.first_name
                                , t.last_name
                                , t.user_type
                                , t.title
                                , t.phone_cellular
                                , t.phone_landline
                                 )
                 VALUES (
                     LOWER (p_username)
                   , security_pkg.get_password (
                         UTL_RAW.cast_to_raw (p_password)
                       , l_salt)
                   , l_salt
                   , 1
                   , p_mail
                   , p_first_name
                   , p_last_name
                   , NULL
                   , p_title
                   , p_phone_cellular
                   , p_phone_landline);
    --TODO mail

    END user_registration;
END registration_pkg;
/