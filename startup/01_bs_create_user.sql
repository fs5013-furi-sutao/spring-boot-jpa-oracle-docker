ALTER SESSION SET CONTAINER = ORCLPDB1;

--------------------------------------------------------------------
-- execute the following statements to create a user name BOOK_SHOP 
-- and grant priviledges
--------------------------------------------------------------------

-- create new user
CREATE USER BOOK_SHOP IDENTIFIED BY oracle;

-- grant priviledges
GRANT CONNECT, RESOURCE TO BOOK_SHOP;
ALTER USER BOOK_SHOP QUOTA UNLIMITED ON USERS;
exit;
