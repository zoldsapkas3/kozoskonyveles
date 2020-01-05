CREATE OR REPLACE PACKAGE KDOC.pbkdf2_pkg
AS
    FUNCTION get_password (p_password   IN VARCHAR2
                         , p_salt       IN kreg_users.sslt%TYPE
                          )
        RETURN VARCHAR2;

    FUNCTION gen_salt
        RETURN VARCHAR2;

    FUNCTION get_user_salt (p_username IN kreg_users.username%TYPE)
        RETURN VARCHAR2;

    -- Implementation of algorithm described in section 5.2 of RFC2898
    -- https://tools.ietf.org/html/rfc2898

    -- dk_length refers to number of octets returned for the desired key
    -- regardless of whether the result is raw/blob or hex characters in varchar2/clob
    --   So, a 20-octet key returned by get_raw, would be a 40 character hex string
    --   returned by get_hex.  The dk_length parameter would be 20 in both cases.

    -- The following HMAC algorithms are supported
    --   DBMS_CRYPTO.HMAC_SH1    = 2
    --   DBMS_CRYPTO.HMAC_SH256  = 3
    --   DBMS_CRYPTO.HMAC_SH384  = 4
    --   DBMS_CRYPTO.HMAC_SH512  = 5

    -- Test vectors
    --   https://tools.ietf.org/html/rfc6070

    --  select pbkdf2.get_hex('password',utl_raw.cast_to_raw('salt'),1,20,2) from dual;
    --      0C60C80F961F0E71F3A9B524AF6012062FE037A6
    --  select pbkdf2.get_hex('password',utl_raw.cast_to_raw('salt'),2,20,2) from dual;
    --      EA6C014DC72D6F8CCD1ED92ACE1D41F0D8DE8957
    --  select pbkdf2.get_hex('password',utl_raw.cast_to_raw('salt'),4096,20,2) from dual;
    --      4B007901B765489ABEAD49D926F721D065A429C1
    --  select pbkdf2.get_hex('passwordPASSWORDpassword',utl_raw.cast_to_raw('saltSALTsaltSALTsaltSALTsaltSALTsalt'),4096,25,2) from dual;
    --      3D2EEC4FE41C849B80C8D83662C0E44A8B291A964CF2F07038

    FUNCTION get_raw (
        p_password     IN VARCHAR2
      , p_salt         IN RAW
      , p_iterations   IN PLS_INTEGER
      , p_dk_length    IN PLS_INTEGER
      , p_hmac         IN PLS_INTEGER DEFAULT DBMS_CRYPTO.hmac_sh512)
        RETURN RAW
        DETERMINISTIC;
END pbkdf2_pkg;
/