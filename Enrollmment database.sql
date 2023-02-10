create database enrollment;
use enrollment;
CREATE TABLE IF NOT EXISTS student (
    regno VARCHAR(20) NOT NULL PRIMARY KEY,
    sname VARCHAR(50) NOT NULL,
    major VARCHAR(50) NOT NULL,
    bdate DATE
);

CREATE TABLE IF NOT EXISTS course (
    c_id INTEGER NOT NULL PRIMARY KEY,
    cname VARCHAR(50) NOT NULL,
    dept VARCHAR(25) NOT NULL
);
CREATE TABLE IF NOT EXISTS textbook (
    bookISBN INTEGER NOT NULL PRIMARY KEY,
    book_title VARCHAR(50) NOT NULL,
    publisher VARCHAR(50) NOT NULL,
    author VARCHAR(50) NOT NULL
);
CREATE TABLE IF NOT EXISTS enroll (
    reg VARCHAR(20) ,
    c_id INTEGER ,
    sem INTEGER ,
    marks INTEGER NOT NULL,
    FOREIGN KEY (reg) REFERENCES student(regno) ON DELETE SET NULL ,
    FOREIGN KEY (c_id) REFEReNCES course(c_id) ON DELETE set NULL
);

CREATE TABLE IF NOT EXISTS book_adoption (
    c_id INTEGER NOT NULL,
    sem INTEGER ,
    bookISBN INTEGER NOT NULL,
    FOREIGN KEY(bookISBN) REFERENCES textbook(bookISBN)
    ON DELETE CASCADE,
    FOREIGN KEY(c_id) REFERENCES course(c_id) ON DELETE CASCADE
);
insert into course values
(001,"DBMS","CS"),
(002,"TOC","CS"),
(003,"Math modeling","MA"),
(004,"Sensors and actuators","EC"),
(005,"DSA","IS"),
(006,"SOM","ME"),
(007,"envi","EV");


insert into student values 
("CS01","Rajat","computers","2002-05-08"),
("CS02","Ram","computers","2002-08-08"),
("EC01","Bharat","Electronics","2002-05-18"),
("EV01","Aamina","Env","2002-12-10"),
("ME01","Rudra" , "Mech" , "2002-01-24"),
("IS01","Anand","Info","2002-04-06");

insert into textbook values 
(11,"Book1","pub1","auth1"),
(22,"Book2","pub1","auth2"),
(33,"Book3","pub2","auth3"),
(44,"Book4","pub3","auth4"),
(55,"Book5","pub4","auth5"),
(66,"Book6","pub5","auth6");

insert into enroll values 
("CS01",1,5,70),
("CS01",1,4,90),
("CS02",2,5,80),
("CS02",2,4,70),
("EC01",4,4,60),
("CS01",4,5,76),
("ME01",6,6,60),
("EV01",7,7,57),
("IS01",5,3,90);

insert into book_Adoption VALUES
(1,5,11),
(1,5,22),
(2,4,11),
(2,4,22),
(3,5,33),
(4,4,44),
(5,3,55),
(6,6,66),
(7,7,66);

--1
SELECT c.c_id,t.bookISBN,t.book_title
     FROM course c,book_adoption ba,textbook t
     WHERE c.c_id=ba.c_id
     AND ba.bookISBN=t.bookISBN
     AND c.dept='CS'
     ORDER BY t.book_title;
--2
select distinct dept from course where c_id in (select c_id from book_adoption where bookISBN in (select bookISBN from textbook where publisher="pub1"));
--3
select s.sname from student s,enroll e,course c
    -> where s.regno=e.reg and e.c_id=c.c_id and e.marks in
    -> (select max(marks) from enroll where enroll.c_id in (select c_id from course where cname="DBMS"));
--4 View
create view view1 as
select c.cname, e.marks from course c, enroll e
where e.c_id=c.c_id and e.reg="CS01";

--trigger
DELIMITER //
create trigger PreventEnrollment
before insert on enroll
for each row
BEGIN
	IF (new.marks<40) THEN
		signal sqlstate '45000' set message_text='Marks below threshold';
	END IF;
END;
//

DELIMITER ;

