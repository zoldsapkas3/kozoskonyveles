CREATE TABLE kreg_user_pictures
(
    id            NUMBER
                     DEFAULT kreg_user_pictures_seq.NEXTVAL
                     CONSTRAINT kreg_user_pictures_pk PRIMARY KEY
  , username      VARCHAR2 (50 BYTE) NOT NULL
  , is_default    NUMBER (1) DEFAULT 1 NOT NULL
  , CONSTRAINT kreg_user_pictures_chk_default CHECK (is_default IN (0, 1))
);