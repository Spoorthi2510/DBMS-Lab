CREATE TABLE IF NOT EXISTS person (
driver_id VARCHAR(10) NOT NULL PRIMARY KEY,
driver_name VARCHAR(20) NOT NULL,
address TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS car (
reg_no VARCHAR(25) NOT NULL PRIMARY KEY,
model TEXT NOT NULL,
c_year INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS accident (
report_no INTEGER NOT NULL PRIMARY KEY,
accident_date DATE,
location TEXT
);

CREATE TABLE IF NOT EXISTS owns (
driver_id VARCHAR(10) NOT NULL,
reg_no VARCHAR(25) NOT NULL,
FOREIGN KEY(driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY(reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS participated (
driver_id VARCHAR(10) NOT NULL,
reg_no VARCHAR(25) NOT NULL,
report_no INTEGER NOT NULL,
damage_amount INTEGER NOT NULL,
FOREIGN KEY(driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY(reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
FOREIGN KEY(report_no) REFERENCES accident(report_no) ON DELETE CASCADE
);

INSERT INTO person VALUES
("D111", "Smith", "Kuvempunagar, Mysuru"),
("D222", "Ravi", "Hebbal, Mysuru"),
("D333", "Mangala", "Udaygiri, Mysuru"),
("D444", "Basappa", "T K Layout, Mysuru"),
("D555", "Somayya", "Dattagalli, Mysuru");

INSERT INTO car VALUES
("KA20AB4223", "Mazda", 2020),
("KA20AB4224","Marazzo",2020),
("KA09MA1234", "Hector", 2021),
("KA21AC5473", "Aura", 2019),
("KA21BD4728", "Triber", 2019),
("KA19CA6374", "Tiago", 2018);

INSERT INTO accident VALUES
(1, "2022-04-05", "Nazarbad, Mysuru"),
(2, "2022-12-16", "Gokulam, Mysuru"),
(3, "2022-05-14", "Vijaynagar Stage 2, Mysuru"),
(4, "2021-08-30", "Kuvempunagar, Mysuru"),
(6,"2020-09-19","Bogadi,Mysuru"),
(5, "2021-01-21", "JSS Layout, Mysuru"),
(7,"2023-02-07","MG road,Mysuru"),
(8,"2022-05-14","Agrahara circle,Mysuru"),
(9,"2020-12-01","Irwin road,Mysuru");

INSERT INTO owns VALUES
("D111", "KA20AB4223"),
("D111","KA20AB4224"),
("D222", "KA09MA1234"),
("D333", "KA21AC5473"),
("D444", "KA21BD4728"),
("D555", "KA19CA6374");

INSERT INTO participated VALUES
("D111", "KA20AB4223", 1, 20000),
("D222", "KA09MA1234", 2, 10000),
("D333", "KA21AC5473", 3, 15000),
("D444", "KA21BD4728", 4, 5000),
("D111","KA20AB4224",6,10000),
("D333", "KA21AC5473", 5, 25000),
("D222","KA09MA1234",7,18000),
("D555","KA19CA6374",8,50000),
("D333","KA21AC5473",9,45000);

--Queries 
select count(person.driver_id) as number_of_ppl from person,owns,car,participated,accident where person.driver_id=owns.driver_id and person.driver_id=participated.driver_id and car.reg_no=owns.reg_no and accident.report_no=participated.report_no and car.reg_no=participated.reg_no and year(accident_date)="2021";
select count(*) from person p,owns o,car c,participated pa,accident a where p.driver_id=o.driver_id and c.reg_no=o.reg_no and a.report_no=pa.report_no and p.driver_id=pa.driver_id and c.reg_no=pa.reg_no and p.driver_name="Smith";
delete from owns where driver_id in (select driver_id from person where driver_name="Smith") and reg_no in (select reg_no from car where model="Mazda");
update participated set damage_amount=15000 where reg_no="KA09MA1234" and report_no=2;
create view view1 as select distinct model ,c_year from person,car,owns,participated,accident where  person.driver_id=owns.driver_id and person.driver_id=participated.driver_id and car.reg_no=owns.reg_no and accident.report_no=participated.report_no and car.reg_no=participated.reg_no ;
create view view2 as select driver_name from person where driver_id in (select driver_id from participated where report_no in (select report_no from accident where location="Irwin road,Mysuru"));
create view view3 as select driver_name,address from person,owns where person.driver_id=owns.driver_id;
 delimiter //
create trigger high_damage_drivers
before insert on owns
for each row
begin
    declare high int;
    select damage_amt into high
    from participated where
    (driver_id=new.driver_id)>50000;
    if(high>0) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT="Heavy driver not allowed";
    end if;
end //



-- A trigger that prevents a driver from participating in more than 2 accidents in a given year.

DELIMITER //
create trigger PreventParticipation
before insert on participated
for each row
BEGIN
	IF 2<=(select count(*) from participated where driver_id=new.driver_id) THEN
		signal sqlstate '45000' set message_text='Driver has already participated in 2 accidents';
	END IF;
END;//
DELIMITER ;

INSERT INTO participated VALUES
("D222", "KA09MA1234", 10, 20000); 
