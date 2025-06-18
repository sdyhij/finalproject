use company

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(200)
);
INSERT INTO Customer (name, phone, email, address) VALUES
('陳小明', '0912345678', 'ming@gmail.com', '台北市中山區南京東路100號'),
('林美麗', '0922333444', 'mei@outlook.com', '新北市板橋區中正路200號'),
('王大衛', '0933555666', 'david@icloud.com', '台中市西區公益路300號');

CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    unit_price DECIMAL(10,2),
    stock INT,
    safety_stock INT
);
INSERT INTO Product (name, unit_price, stock, safety_stock) VALUES
('原子筆', 15.00, 50, 20),
('筆記本', 40.00, 30, 10),
('資料夾', 25.00, 80, 15),
('膠水', 10.00, 5, 10),
('便利貼', 20.00, 18, 10);

CREATE TABLE Supplier (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    contact_phone VARCHAR(20)
);
INSERT INTO Supplier (name, contact_phone) VALUES
('文具批發商A', '0223456789'),
('好朋友文具行', '0234567890');

CREATE TABLE Purchase (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id INT,
    product_id INT,
    quantity INT,
    purchase_date DATE,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);
INSERT INTO Purchase (supplier_id, product_id, quantity, purchase_date) VALUES
(1, 1, 30, '2025-05-01'),
(2, 4, 20, '2025-05-03'),
(1, 5, 10, '2025-05-10');

CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    change_type ENUM('進貨', '出貨'),
    quantity INT,
    change_date DATE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);
INSERT INTO Inventory (product_id, change_type, quantity, change_date) VALUES
(1, '進貨', 30, '2025-05-01'),
(4, '進貨', 20, '2025-05-03'),
(1, '出貨', 10, '2025-06-01'),
(5, '進貨', 10, '2025-05-10');


CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);
INSERT INTO Orders (customer_id, order_date) VALUES
(1, '2025-06-01'),
(2, '2025-06-02'),
(3, '2025-06-03');

CREATE TABLE OrderDetail (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);
INSERT INTO OrderDetail (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 10, 15.00),
(1, 2, 2, 40.00),
(2, 3, 5, 25.00),
(2, 5, 3, 20.00),
(3, 4, 8, 10.00);







-- 客戶姓名加索引
CREATE INDEX idx_customer_name ON Customer(name);

-- 訂單日期加索引
CREATE INDEX idx_order_date ON Orders(order_date);

-- 產品名稱加索引
CREATE INDEX idx_product_name ON Product(name);



----月銷售報表（View + GROUP BY + Function）
CREATE VIEW MonthlySales AS
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(od.quantity * od.unit_price) AS total_sales,
    COUNT(DISTINCT o.order_id) AS order_count
FROM 
    Orders o
JOIN 
    OrderDetail od ON o.order_id = od.order_id
GROUP BY 
    month;
---查詢每月的總銷售金額與訂單數量。
SELECT * FROM MonthlySales;



----庫存安全量檢查（Trigger + 警示查詢）
DELIMITER $$

CREATE TRIGGER check_stock_after_order
AFTER INSERT ON OrderDetail
FOR EACH ROW
BEGIN
  UPDATE Product
  SET stock = stock - NEW.quantity
  WHERE product_id = NEW.product_id;
END$$

DELIMITER ;
--查詢安全庫存不足的商品：
SELECT product_id, name, stock, safety_stock
FROM Product
WHERE stock < safety_stock;




---客戶訂單分析（Function + View)
CREATE VIEW CustomerOrderAnalysis AS
SELECT 
  c.customer_id,
  c.name,
  COUNT(DISTINCT o.order_id) AS order_count,
  SUM(od.quantity * od.unit_price) AS total_spent
FROM 
  Customer c
JOIN 
  Orders o ON c.customer_id = o.customer_id
JOIN 
  OrderDetail od ON o.order_id = od.order_id
GROUP BY 
  c.customer_id, c.name;
---計算每位客戶的累積訂單金額、訂單次數，評估是否為「重要客戶」。
SELECT * FROM CustomerOrderAnalysis WHERE total_spent > 1000;




INSERT INTO Product (product_id, name, unit_price, stock)
VALUES 
(101, '無線滑鼠', 150, 100),
(102, '機械鍵盤', 300, 50),
(103, 'USB-C 傳輸線', 80, 200);


INSERT INTO Supplier ( name, contact_phone)
VALUES 
('台灣科技貿易公司', '0227883333');


INSERT INTO Purchase (supplier_id, product_id, quantity, purchase_date) VALUES
(3, 101, 20, '2025-05-01'),
(3, 102, 20, '2025-05-01'),
(3, 103, 30, '2025-05-05');

INSERT INTO Inventory (product_id, change_type, quantity, change_date)
VALUES 
(101, '進貨', 20, '2025-05-01'),
(102, '進貨', 20, '2025-05-01'),
(103, '進貨', 30, '2025-05-05');



---用交易（Transaction）來一次性插入
START TRANSACTION;

-- 新增第1位客戶
INSERT INTO Customer (name, phone, email)
VALUES ('黃大明', '0912345008', 'xiaoming@example.com');
SET @customer1 = LAST_INSERT_ID();

-- 王小明的訂單
INSERT INTO Orders (customer_id, order_date)
VALUES (@customer1, CURDATE());
SET @order1 = LAST_INSERT_ID();

INSERT INTO OrderDetail (order_id, product_id, quantity, unit_price)
VALUES 
(@order1, 101, 10, 150);

-- 新增第2位客戶
INSERT INTO Customer (name, phone, email)
VALUES ('鍾小華', '0922333771', 'xiaohua@example.com');
SET @customer2 = LAST_INSERT_ID();

-- 陳小華的訂單
INSERT INTO Orders (customer_id, order_date)
VALUES (@customer2, CURDATE());
SET @order2 = LAST_INSERT_ID();

INSERT INTO OrderDetail (order_id, product_id, quantity, unit_price)
VALUES 
(@order2, 102, 7, 300);