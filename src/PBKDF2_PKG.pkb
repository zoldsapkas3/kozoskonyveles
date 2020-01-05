CREATE OR REPLACE PACKAGE BODY KDOC.pbkdf2_pkg
IS
    c_max_raw_length   CONSTANT PLS_INTEGER := 32767;
    c_max_hex_length   CONSTANT PLS_INTEGER := 32767;

    SUBTYPE t_maxraw IS RAW (32767);

    SUBTYPE t_maxhex IS VARCHAR2 (32767);

    SUBTYPE t_hmac_result IS RAW (64);

    FUNCTION get_password (p_password   IN VARCHAR2
                         , p_salt       IN kreg_users.sslt%TYPE
                          )
        RETURN VARCHAR2
    IS
        l_password   kreg_users.password%TYPE;
    BEGIN
        SELECT pbkdf2_pkg.get_raw (p_password
                                 , UTL_RAW.cast_to_raw (p_salt)
                                 , 8172
                                 , 50
                                 , 5
                                  )
          INTO l_password
          FROM DUAL;

        RETURN l_password;
    END get_password;

    FUNCTION gen_salt
        RETURN VARCHAR2
    IS
        l_salt   VARCHAR2 (80);
    BEGIN
        SELECT DBMS_CRYPTO.randombytes (40) INTO l_salt FROM DUAL;

        RETURN l_salt;
    END gen_salt;

    FUNCTION get_user_salt (p_username IN kreg_users.username%TYPE)
        RETURN VARCHAR2
    IS
        l_salt   VARCHAR2 (40);
    BEGIN
        SELECT sslt
          INTO l_salt
          FROM kreg_users t
         WHERE t.username = p_username;

        RETURN l_salt;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            security_pkg.log_invalid_login (p_username
                                          , 'username did not have salt'
                                           );
            RETURN NULL;
    END get_user_salt;



    FUNCTION iterate_hmac_xor (p_salt             IN RAW
                             , p_iterations       IN PLS_INTEGER
                             , p_hmac             IN PLS_INTEGER
                             , p_block_iterator   IN PLS_INTEGER
                             , p_raw_password     IN RAW
                              )
        RETURN t_hmac_result
    IS
        v_u           t_maxraw;
        v_f_xor_sum   t_hmac_result;
    BEGIN
        v_u           :=
            UTL_RAW.CONCAT (
                p_salt
              , UTL_RAW.cast_from_binary_integer (p_block_iterator
                                                , UTL_RAW.big_endian
                                                 ));

        v_u           :=
            DBMS_CRYPTO.mac (src => v_u, typ => p_hmac, key => p_raw_password);

        v_f_xor_sum   := v_u;

        FOR c IN 2 .. p_iterations
        LOOP
            v_u           :=
                DBMS_CRYPTO.mac (src   => v_u
                               , typ   => p_hmac
                               , key   => p_raw_password
                                );

            v_f_xor_sum   := UTL_RAW.bit_xor (v_f_xor_sum, v_u);
        END LOOP;

        RETURN v_f_xor_sum;
    END iterate_hmac_xor;

    FUNCTION get_raw (
        p_password     IN VARCHAR2
      , p_salt         IN RAW
      , p_iterations   IN PLS_INTEGER
      , p_dk_length    IN PLS_INTEGER
      , p_hmac         IN PLS_INTEGER DEFAULT DBMS_CRYPTO.hmac_sh512)
        RETURN RAW
        DETERMINISTIC
    IS
        c_hlen           CONSTANT PLS_INTEGER
            := CASE p_hmac
                   WHEN DBMS_CRYPTO.hmac_sh1 THEN 20
                   WHEN DBMS_CRYPTO.hmac_sh256 THEN 32
                   WHEN DBMS_CRYPTO.hmac_sh384 THEN 48
                   WHEN DBMS_CRYPTO.hmac_sh512 THEN 64
               END ;
        c_octet_blocks   CONSTANT PLS_INTEGER := CEIL (p_dk_length / c_hlen);
        v_t_concat                t_maxraw := NULL;
        v_block_iterator          PLS_INTEGER := 1;
    BEGIN
        IF p_dk_length > (POWER (2, 32) - 1) * c_hlen
        THEN
            raise_application_error (-20001, 'derived key too long');
        ELSIF p_dk_length > c_max_raw_length
        THEN
            raise_application_error (
                -20001
              , 'raw output must be less than to 32K bytes');
        END IF;

        IF p_iterations < 1
        THEN
            raise_application_error (-20001, 'must iterate at least once');
        END IF;



        WHILE     v_block_iterator <= c_octet_blocks
              AND (   v_t_concat IS NULL
                   OR UTL_RAW.LENGTH (v_t_concat) < p_dk_length)
        LOOP
            v_t_concat         :=
                UTL_RAW.CONCAT (
                    v_t_concat
                  , iterate_hmac_xor (p_salt
                                    , p_iterations
                                    , p_hmac
                                    , v_block_iterator
                                    , UTL_RAW.cast_to_raw (p_password)
                                     ));

            v_block_iterator   := v_block_iterator + 1;
        END LOOP;

        RETURN UTL_RAW.SUBSTR (v_t_concat, 1, p_dk_length);
    END get_raw;
END pbkdf2_pkg;
/