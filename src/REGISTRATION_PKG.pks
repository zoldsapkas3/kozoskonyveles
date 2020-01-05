CREATE OR REPLACE PACKAGE KDOC.registration_pkg
AS
    PROCEDURE user_registration (
        p_username         IN kreg_users.username%TYPE
      , p_password         IN VARCHAR2
      , p_mail             IN kreg_users.mail%TYPE
      , p_first_name       IN kreg_users.first_name%TYPE
      , p_last_name        IN kreg_users.last_name%TYPE
      , p_title            IN kreg_users.title%TYPE
      , p_phone_cellular   IN kreg_users.phone_cellular%TYPE
      , p_phone_landline   IN kreg_users.phone_landline%TYPE);
END registration_pkg;
/