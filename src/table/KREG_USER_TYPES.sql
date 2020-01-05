DROP TABLE kreg_user_types CASCADE CONSTRAINTS PURGE;

--
-- KREG_USER_TYPES  (Table)
--

CREATE TABLE kreg_user_types
(
    id           NUMBER DEFAULT kreg_user_types_seq.NEXTVAL
  , type_name    VARCHAR2 (20 CHAR) NOT NULL
  , active       NUMBER (1) DEFAULT 1 NOT NULL
);


--
-- KREG_USER_TYPES_NAME_UK  (Index)
--

CREATE UNIQUE INDEX kreg_user_types_name_uk
    ON kreg_user_types (type_name);

--
-- KREG_USER_TYPES_PK  (Index)
--

CREATE UNIQUE INDEX kreg_user_types_pk
    ON kreg_user_types (id);

--
-- Non Foreign Key Constraints for Table KREG_USER_TYPES
--

ALTER TABLE kreg_user_types
    ADD (
        CONSTRAINT kreg_users_chk_active CHECK
            (active IN (0, 1))
            ENABLE VALIDATE
      , CONSTRAINT kreg_user_types_pk PRIMARY KEY (id)
            USING INDEX kreg_user_types_pk ENABLE VALIDATE
      , CONSTRAINT kreg_user_types_name_uk UNIQUE (type_name)
            USING INDEX kreg_user_types_name_uk ENABLE VALIDATE);