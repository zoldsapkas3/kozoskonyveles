CREATE OR REPLACE VIEW vx_kk_sidenav_header
AS
    SELECT 'https://raw.githubusercontent.com/zoldsapkas3/kozoskonyveles/master/pictures/profile_background_pic.jpg'    AS background_img
         , CASE
               WHEN p.username IS NOT NULL AND p.is_default = 1
               THEN
                   NULL
               ELSE
                   'https://raw.githubusercontent.com/zoldsapkas3/kozoskonyveles/master/pictures/placeholder_profile_pic.jpg'
           END                                                                                                          AS profile_img
         , u.username                                                                                                   AS username
         , '#'                                                                                                          AS profile_link
         ,    CASE WHEN title IS NOT NULL THEN title || ' ' ELSE NULL END
           || last_name
           || ' '
           || first_name                                                                                                AS text_line_1
         , mail                                                                                                         AS text_line_2
      FROM kreg_users  u
           LEFT JOIN kreg_user_pictures p ON p.username = u.username;