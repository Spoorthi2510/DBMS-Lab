CREATE TABLE IF NOT EXISTS customer (
    cust VARCHAR(10) NOT NULL PRIMARY KEY,
    cname VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
    oid INTEGER NOT NULL PRIMARY KEY,
    odate DATE NOT NULL,
    cust VARCHAR(10) NOT NULL,
    order_amt INTEGER NOT NULL,
    FOREIGN KEY(cust) REFERENCES customer(cust) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS warehouse (
    wid VARCHAR(10) NOT NULL PRIMARY KEY,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS item (
    itemid VARCHAR(10) NOT NULL PRIMARY KEY,
    unitprice INTEGER NOT NULL
);


CREATE TABLE IF NOT EXISTS order_item (
    oid INTEGER NOT NULL,
    itemid VARCHAR(10) NOT NULL,
    qty INTEGER NOT NULL,
    FOREIGN KEY(oid) REFERENCES orders(oid) ON DELETE CASCADE,
    FOREIGN KEY(itemid) REFERENCES item(itemid) ON DELETE CASCADE

);

CREATE TABLE IF NOT EXISTS shipment (
    oid INTEGER NOT NULL,
    wid VARCHAR(10) NOT NULL,
    ship_date DATE NOT NULL,
    FOREIGN KEY(oid) REFERENCES orders(oid) ON DELETE CASCADE,
    FOREIGN KEY(wid) REFERENCES warehouse(wid) ON DELETE CASCADE

);


INSERT INTO customer VALUES
("c1", "Kumar", "Mysuru"),
("c2", "Jahnavi", "Bengaluru"),
("c3", "Shanaya", "Mumbai"),
("c4", "Rahul", "Dehli"),
("c5", "Shoaib", "Bengaluru");

INSERT INTO orders VALUES
(001, "2020-01-14", "c1", 2000),
(002, "2021-04-13", "c1", 500),
(003, "2019-10-02", "c2", 2500),
(004, "2019-05-12", "c3", 1000),
(005, "2020-12-23", "c4", 1200),
(006,"2021-12-12","c2",5000),
(007,"2022-01-01","c4",800),
(008,"2022-01-01","c4",200),
(009,"2023-01-28","c3",3000);

INSERT INTO item VALUES
("i1", 400),
("i2", 300),
("i3", 1000),
("i4", 100),
("i5", 500);

INSERT INTO warehouse VALUES
("w1", "Mysuru"),
("w2", "Bengaluru"),
("w3", "Mumbai"),
("w4", "Delhi"),
("w5", "Chennai");

INSERT INTO order_item VALUES 
(001, "i1", 5),
(002, "i5", 1),
(003, "i5", 5),
(004, "i3", 1),
(005, "i2", 4),
(006,"i3",5),
(007,"i1",2),
(008,"i4",2),
(009,"i2",10);

INSERT INTO shipment VALUES
(001, "w2", "2020-01-16"),
(002, "w1", "2021-04-14"),
(003, "w2", "2019-10-07"),
(004, "w3", "2019-05-16"),
(005, "w5", "2020-12-23"),
(006,"w2","2021-12-12"),
(007,"w4","2022-01-05"),
(008,"w2","2022-01-04"),
(009,"w4","2023-01-28");

--Queries 
select oid,ship_date from shipment where wid="w2";
select * from shipment natural join warehouse where oid in (select oid from orders where cust in (select cust from customer where cname="Kumar"));
select  customer.cust,cname,count(customers.cust),avg(order_amt) from customer,orders where customer.cust=orders.cust group by customer.cust;
delete from orders where cust=(select cust from customer where cname="Kumar");     
select * from item where unitprice=(select max(unitprice) from item);
create view view1 as select oid,ship_date from shipment where wid="w2";
create view view2 as select wid from shipment where oid in (select oid from orders where cust in (select cust from customer where cname="Kumar"));

--Triggers
DELIMITER //
create trigger UpdateOrderAmt
after insert on order_item
for each row
BEGIN
	update orders set order_amt=(select (oi.qty*i.unitprice) from order_item oi,item i where oi.oid=new.oid) where orders.oid=new.oid;
END;//
DELIMITER ;
