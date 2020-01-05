CREATE OR REPLACE PACKAGE KDOC.migration_pkg
IS
    /************************************************************************
    | Purpose: Fetches the users from doc_users table and inserts into kdoc_users.
    | Passwords getting updated to new standards in the second step after insert
    | with an update. Full_name column is split before and after first comma
    | respectively to match the new table structure. user_type column has been
    | mapped by hand for now. Validations for mail and username column are in place,
    | invalid entries has been flagged.
    ************************************************************************/
    PROCEDURE doc_users_mig;
END migration_pkg;
/