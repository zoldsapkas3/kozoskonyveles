DROP TABLE kreg_users CASCADE CONSTRAINTS PURGE;

--
-- KREG_USERS  (Table)
--

CREATE TABLE kreg_users
(
    username          VARCHAR2 (50 BYTE)
  , password          RAW (100) NOT NULL
  , sslt              VARCHAR2 (80 BYTE) NOT NULL
  , active            NUMBER (1) NOT NULL
  , mail              VARCHAR2 (64 BYTE) NOT NULL
  , first_name        VARCHAR2 (50 BYTE) NOT NULL
  , last_name         VARCHAR2 (50 BYTE) NOT NULL
  , user_type         NUMBER
  , title             VARCHAR2 (20 BYTE)
  , phone_cellular    VARCHAR2 (50 BYTE)
  , phone_landline    VARCHAR2 (50 BYTE)
);


--
-- KREG_USERS_MAIL_UK  (Index)
--

CREATE UNIQUE INDEX kreg_users_mail_uk
    ON kreg_users (mail);

--
-- KREG_USERS_PK  (Index)
--

CREATE UNIQUE INDEX kreg_users_pk
    ON kreg_users (username);

--
-- Non Foreign Key Constraints for Table KREG_USERS
--

ALTER TABLE kreg_users
    ADD (
        CONSTRAINT kreg_users_chk_mail CHECK
            (REGEXP_LIKE (mail
                        , '[A-Za-z0-9._%-]+@[A-Za-z0-9._%-]+\.[A-Za-z]{2,4}'
                         ))
            ENABLE VALIDATE
      , CONSTRAINT kreg_users_chk_username_length CHECK
            (LENGTH (username) >= 3)
            ENABLE VALIDATE
      , CONSTRAINT kreg_users_chk_user_spec CHECK
            (NOT REGEXP_LIKE (username, '[^A-Za-z0-9.]'))
            ENABLE VALIDATE
      , CONSTRAINT kreg_users_pk PRIMARY KEY (username)
            USING INDEX kreg_users_pk ENABLE VALIDATE
      , CONSTRAINT kreg_users_mail_uk UNIQUE (mail)
            USING INDEX kreg_users_mail_uk ENABLE VALIDATE);

--
-- Foreign Key Constraints for Table KREG_USERS
--

ALTER TABLE kreg_users
    ADD (
        CONSTRAINT kreg_users_fk_user_type FOREIGN KEY (user_type)
            REFERENCES kreg_user_types (id)
            ENABLE VALIDATE);