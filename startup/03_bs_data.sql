ALTER SESSION SET CONTAINER = ORCLPDB1;
CONNECT HARDWARE_SHOP/oracle@ORCLPDB1

REM INSERTING into BOOK_SHOP.EVENTS
SET DEFINE OFF;
Insert into BOOK_SHOP.EVENTS (ID, DESCRIPTION, PUBLISHED, TITLE) values (1, 'Tut#1 Description', '0', 'Spring Boot Tut#1');
Insert into BOOK_SHOP.EVENTS (ID, DESCRIPTION, PUBLISHED, TITLE) values (2, 'Tut#2 Description', '0', 'Oracle Database Tut#2');
Insert into BOOK_SHOP.EVENTS (ID, DESCRIPTION, PUBLISHED, TITLE) values (3, 'Tut#3 Description', '0', 'Spring Hibernate Oracle Tut#3');
Insert into BOOK_SHOP.EVENTS (ID, DESCRIPTION, PUBLISHED, TITLE) values (4, 'Tut#4 Description', '0', 'Spring Data JPA Tut#4');
Insert into BOOK_SHOP.EVENTS (ID, DESCRIPTION, PUBLISHED, TITLE) values (5, 'Tut#5 Description', '0', 'Oracle Advanced Tut#5');

COMMIT;
exit;
