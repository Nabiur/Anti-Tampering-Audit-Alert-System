CREATE TABLE ORDERS (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    CUSTOMER_ID INT,
    STATUS VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 
);

INSERT INTO ORDERS (CUSTOMER_ID, STATUS)
VALUES
(101, 'Pending');


INSERT INTO ORDERS (CUSTOMER_ID, STATUS)
VALUES
(101, 'Pending'),
(102, 'Processing'),
(103, 'Shipped'),
(104, 'Delivered'),
(105, 'Cancelled'),
(101, 'Delivered'),
(102, 'Pending'),
(103, 'Processing'),
(104, 'Shipped'),
(105, 'Delivered');

SELECT * FROM ORDERS;


CREATE TABLE CUSTOMERS(
	ID INT PRIMARY KEY, 
    FULL_NAME VARCHAR(100),
    LAST_ORDER_DATE DATETIME
);


INSERT INTO CUSTOMERS (id, FULL_NAME) values 
(101, 'Sajib'),
(102, 'Akash'),
(103, 'Mahi');

INSERT INTO CUSTOMERS (id, FULL_NAME) values 
(104, 'Rafi'),
(105, 'Adnan'),
(106, 'Sakib');


DROP TABLE CUSTOMERS;

SELECT * FROM CUSTOMERS;

SELECT CUSTOMER_ID, MAX(CREATED_AT) AS LAST_ORDER_DATE
FROM ORDERS
GROUP BY 1;

-- BACKFILLING CUSTOMERS TABLE
select * from orders;

UPDATE CUSTOMERS C
SET LAST_ORDER_DATE = (
		SELECT MAX(O.CREATED_AT)
        FROM ORDERS O
        WHERE O.CUSTOMER_ID = C.ID

);

INSERT INTO ORDERS (CUSTOMER_ID, STATUS)
VALUES
(106, 'Pending');


DELIMITER $$

CREATE TRIGGER LAST_ORDER_DAY_AUTOMATOR
AFTER INSERT
ON ORDERS
FOR EACH ROW
BEGIN
	UPDATE CUSTOMERS 
	SET LAST_ORDER_DATE = NEW.CREATED_AT
    WHERE ID = NEW.CUSTOMER_ID;
    
END$$ 
DELIMITER ;

SELECT * FROM ORDERS;
SELECT * FROM CUSTOMERS;


INSERT INTO ORDERS (CUSTOMER_ID, STATUS)
VALUES
(103, 'Processing');

------------------------------- Most Advanced Part----------------------
-- Audit Log

-- STEPS: 
-- SETP1: CREATE THE LOG TABLE 

CREATE TABLE activity_logs(
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    action_type VARCHAR(50),      -- specify a length
    changed_data JSON,            -- old vs new for updates, full row for insert/delete
    user_id INT,                  -- CURRENT_USER() or session variable
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SET @CURRENT_USER_ID = 999;

DELIMITER //

CREATE TRIGGER orders_after_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (
        order_id,
        action_type,
        changed_data,
        user_id,
        action_date
    )
    VALUES (
        NEW.id,
        'INSERT',
        JSON_OBJECT(
            'new', JSON_OBJECT(
                'customer_id', NEW.customer_id,
                'status', NEW.status,
                'created_at', NEW.created_at,
                'updated_at', NEW.updated_at
            )
        ),
        IFNULL(@current_user_id, 0), -- fallback to 0 if session variable not set
        NOW()
    );
END //

DELIMITER ;

DROP TRIGGER orders_after_insert;
16	101	Delivered	2025-10-11 21:15:42	2025-10-11 21:15:42

SELECT * FROM ACTIVITY_LOGS;
SELECT * FROM ORDERS;


SET @CURRENT_USER_ID = 111;

INSERT INTO ORDERS (CUSTOMER_ID, STATUS)
VALUES
(102, 'Delivered');



drop trigger orders_after_update;

DELIMITER //

CREATE TRIGGER orders_after_update
AFTER UPDATE ON ORDERS
FOR EACH ROW
BEGIN
    -- Check if CUSTOMER_ID or STATUS actually changed
    IF NOT (
        OLD.CUSTOMER_ID <=> NEW.CUSTOMER_ID AND 
        OLD.STATUS <=> NEW.STATUS
    )
    THEN
        INSERT INTO activity_logs (
            order_id,
            action_type,
            changed_data,
            user_id,
            action_date
        )
        VALUES (
            NEW.ID,
            'UPDATE',
            JSON_OBJECT(
                'old', JSON_OBJECT(
                    'CUSTOMER_ID', OLD.CUSTOMER_ID,
                    'STATUS', OLD.STATUS
                ),
                'new', JSON_OBJECT(
                    'CUSTOMER_ID', NEW.CUSTOMER_ID,
                    'STATUS', NEW.STATUS
                )
            ),
            IFNULL(@current_user_id, 0),
            NOW()
        );
    END IF;
END//

DELIMITER ;


UPDATE ORDERS 
SET STATUS = 'Return'
where id = 1;


SELECT * FROM ACTIVITY_LOGS;
SELECT * FROM ORDERS;


SET @CURRENT_USER_ID = 111;

INSERT INTO ORDERS (CUSTOMER_ID, STATUS)
VALUES
(102, 'Delivered');


select * 
from activity_logs
where order_id = 1;

delete orders 
where 



DELIMITER //

CREATE TRIGGER orders_after_delete
AFTER DELETE ON ORDERS
FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (
        order_id,
        action_type,
        changed_data,
        user_id,
        action_date
    )
    VALUES (
        OLD.ID,
        'DELETE',
        JSON_OBJECT(
            'old', JSON_OBJECT(
                'CUSTOMER_ID', OLD.CUSTOMER_ID,
                'STATUS', OLD.STATUS,
                'created_at', OLD.created_at
            )
        ),
        IFNULL(@current_user_id, 0),
        NOW()
    );
END//

DELIMITER ;  

delete from orders 
where id = 3;

select * from activity_logs;
select * from orders;