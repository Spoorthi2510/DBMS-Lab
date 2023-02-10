/* Creating a sailor database with three tables */
CREATE DATABASE IF NOT EXISTS sailors_157;
USE sailors_157;
CREATE TABLE IF NOT EXISTS sailors (
sid varchar(25) NOT NULL PRIMARY KEY,
sname TEXT NOT NULL,
rating INTEGER NOT NULL,
age INTEGER
);

CREATE TABLE IF NOT EXISTS boat (
bid varchar(25) NOT NULL PRIMARY KEY,
bname TEXT NOT NULL,
color TEXT
);

CREATE TABLE IF NOT EXISTS rservers (
sid varchar(25) NOT NULL,
bid varchar(25) NOT NULL,
s_date DATE,
FOREIGN KEY(sid) REFERENCES sailors(sid) ON DELETE CASCADE,
FOREIGN KEY(bid) REFERENCES boat(bid) ON DELETE CASCADE
);

INSERT INTO sailors VALUES
("S111", "Albert", 5, 45),
("S222", "Tom", 6, 39),
("S333", "Bob", 8, 36),
("S444", "Jack", 10, 28),
("S555", "Michael", 10, 42);
("S666","John",3,44);

INSERT INTO boat VALUES
("B111", "BillyStorm", "Black"),
("B222", "Pilly", "Red"),
("B333", "TrillyStorm", "Green"),
("B444", "Willy", "White"),
("B555", "Lilly", "Blue");

INSERT INTO rservers VALUES
("S111", "B444", "2020-04-05"),
("S222", "B222", "2019-12-16"),
("S333", "B111", "2020-05-14"),
("S444", "B333", "2019-08-30"),
("S555", "B555", "2021-01-01"),
("S333","B222","2022-09-23"),
("S111","B555","2022-01-04"),
("S333","B555","2022-08-17"),
("S222","B444","2021-12-12"),
("S333","B333","2022-02-27"),
("S444","B111","2022-03-09"),
("S333","B444","2022-04-21"),
("S111","B222","2022-03-19"),
("S222","B555","2023-01-29"),
("S444","B555","2022-12-30"),
("S111","B333","2020-11-11"),
("S666","B111","2021-10-25"),
("S555","B444","2022-10-25"),
("S666","B333","2020-05-09"),
("S666","B222","2023-02-03"),
("S666","B111","2020-10-10"),
("S666","B555","2020-10-18");

SELECT * FROM sailors;
SELECT * FROM boat;
SELECT * FROM rservers;

--Queries 
--1
select color from boat where bid in (select bid from rservers where sid in (select sid from sailors where sname="Albert"));
--2
select distinct  sailors.sid from sailors,rservers where rating>=8 or (sailors.sid=rservers.sid and bid="B333");
--or
(select sid from sailors where rating>8) union (select sid from rservers where bid="B333");
--3
select sname from sailors where sid not in (select distinct sid from rservers where bid in (select bid from boat where bname like "%Storm%"))order by sname;
--or
 select sname from sailors where sid in(select sid from rservers where bid in(select bid from boat where bname like "%Storm")) order by sname;
--4
select sname from sailors where not exists ((select bid from boat) except (select bid from rservers where rservers.sid=sailors.sid)); 
--or
select sailors.sname from sailors join rservers where sailors.sid=rservers.sid group by sailors.sname,sailors.sid having count(rservers.bid)=(select count(*) from boat);
--5
select sname,age from sailors where (select max(age) from sailors)=age;
--6
select boat.bid, AVG(age) from boat,sailors,rservers where sailors.age>=40 and boat.bid=rservers.bid and sailors.sid=rservers.sid group by bid having count(distinct sailors.sid)>=5;
create view view1 as select sname,rating from sailors order by rating; select * from view1;
create view view2 as select sname from sailors where sid in(select sid from rservers where s_date="2020-11-11");
create view view3 as select sname,color from sailors,boat,rservers where sailors.sid=rservers.sid and boat.bid=rservers.bid and rating=10;

--Trigger that prevents boats from being deleted If they have active reservations
Delimiter //
CREATE TRIGGER trigger1
BEFORE DELETE ON Boat
FOR EACH ROW
BEGIN
    IF (select count(*) from rservers where rservers.bid=old.bid)>0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Cannot delete a reserved boat';
    END IF;
END //
Delimiter ;



--Trigger that dosent allow reservation to a boat if sailor rating<3
delimiter //
create trigger trigger2
before insert on rservers
for each row
begin
      declare rat int;
      select rating into rat
      from sailors
      where sailors.sid=new.sid;
      if rat<3 then
              SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT='cannot reserve a boat to sailor who has less than 3 rating';
      end if;
    end //
 delimiter ;
insert into sailors values ("S777","Walter",2,22);
insert into rservers values ("S777","B444","2023-01-27");




--Trigger that deletes all expired reservations
DELIMITER //
CREATE TRIGGER delete_expired_reservations
AFTER INSERT ON Rservers
FOR EACH ROW
BEGIN
    DELETE FROM Rservers
    WHERE date < NOW() AND sid = NEW.sid AND bid = NEW.bid;
END //
DELIMITER ;


