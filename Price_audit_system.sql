DROP TABLE if exists product;
DROP TABLE if exists history;
drop table if exists alert;

CREATE TABLE Product(
    ProductID INT PRIMARY KEY AUTO_INCREMENT,   
    ProductName VARCHAR(255) NOT NULL,          
    CategoryID INT,                            
    Price DECIMAL(10, 2) NOT NULL,             
    StockQuantity INT DEFAULT 0,                
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP, 
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 
);
SELECT * FROM PRODUCT;

CREATE TABLE ALERT(
ALERT_ID INT PRIMARY KEY AUTO_INCREMENT,
PRODUCT_ID INT,
CHANGES JSON,
USER_ID varchar(20),
REASON VARCHAR(50),
time datetime default current_timestamp
);

CREATE  TABLE HISTORY(

HISTORY_ID INT PRIMARY KEY AUTO_INCREMENT,
PRODUCT_ID INT,
CHANGES JSON,
USER_ID varchar(20),
ACTION VARCHAR(50),
time datetime default current_timestamp
);



DELIMITER //
CREATE  TRIGGER BeforeProductUpdate
BEFORE UPDATE ON Product  
FOR EACH ROW
BEGIN
    DECLARE price_change_percentage DECIMAL(10, 2);
    DECLARE stock_change_percentage DECIMAL(10, 2);

    
    SET price_change_percentage = ABS(NEW.Price - OLD.Price) / OLD.Price * 100;
    SET stock_change_percentage = ABS(NEW.StockQuantity - OLD.StockQuantity) / OLD.StockQuantity * 100;

   
    IF price_change_percentage > 50 THEN
       
        INSERT INTO Alert (product_id, changes,	user_id, reason)
        VALUES (OLD.ProductID, 
                JSON_OBJECT('old', JSON_OBJECT('price', OLD.Price, 'stock', OLD.StockQuantity), 
                            'new', JSON_OBJECT('price', NEW.Price, 'stock', NEW.StockQuantity)), user(),
                'High price change');


 
    ELSEIF stock_change_percentage > 50 THEN
        INSERT INTO Alert (product_id, changes,user_id, reason)
        VALUES (OLD.ProductID, 
                JSON_OBJECT('old', JSON_OBJECT('price', OLD.Price, 'stock', OLD.StockQuantity), 
                            'new', JSON_OBJECT('price', NEW.Price, 'stock', NEW.StockQuantity)),user(),
                'High stock change');
		
	
            
    END IF;
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER AfterProductUpdate
AFTER UPDATE ON Product
FOR EACH ROW
BEGIN
     INSERT INTO history (product_id, changes,user_id,action)
        VALUE (OLD.ProductID, 
                JSON_OBJECT('old', JSON_OBJECT('price', OLD.Price, 'stock', OLD.StockQuantity), 
                            'new', JSON_OBJECT('price', NEW.Price, 'stock', NEW.StockQuantity)), user(),
                'update');
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER AfterProductInsert
AFTER insert ON Product
FOR EACH ROW
BEGIN
     INSERT INTO history (product_id, changes,user_id,action)
        VALUE (new.ProductID, 
                JSON_OBJECT('new', JSON_OBJECT('price', NEW.Price, 'stock', NEW.StockQuantity)), user(),
                'update');
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER AfterProductDelete
AFTER Delete ON Product
FOR EACH ROW
BEGIN
     INSERT INTO history (product_id, changes,user_id,action)
        VALUE (OLD.ProductID, 
                JSON_OBJECT('old', JSON_OBJECT('price', OLD.Price, 'stock', OLD.StockQuantity)), user(),
                'delete');
END;
//
DELIMITER ;







drop trigger BeforeProductUpdate;
drop trigger AfterProductUpdate;

select * from product;
SELECT * from alert;
select * from history;

show triggers like 'product';


update product 
set price=1000
where productid=5;


update product 
set StockQuantity=600
where productid=1;

delete from product
where productid=1;
