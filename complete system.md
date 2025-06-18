---
title: '[People] Onboarding new recruits'
tags: [Templates, Book]

---

# 訂單系統sql

:::info
:bulb:本系統為訂單 / 進銷存系統。透過資料庫設計與 SQL 查詢，協助企業記錄產品庫存、管理供應商與客戶訂單，並提供即時分析功能，如月銷售、庫存安全量、客戶訂單分析。
:::

##  系統主要功能:

:::spoiler
 1.客戶管理:建立與維護客戶基本資料，包括姓名、電話、Email 與地址。
            2.產品管理:建立產品資料，包含單價、庫存量與安全庫存值。
            3.供應商管理:記錄供應商資訊及其聯絡方式，用於後續進貨紀錄。
            4.訂單管理:客戶下訂單時建立訂單資料與訂單明細，包含訂購的產品、數量與價格。
            5.進貨與庫存管理:	建立進貨記錄，並透過 Inventory 表記錄商品進出，維護即時庫存變化。
            6.銷售報表查詢:提供每月總銷售金額與訂單筆數，支援時間序列分析與業績報告。
            7.安全庫存警示:比對產品庫存與安全庫存值，找出庫存不足商品，提醒補貨。
            8.客戶分析:分析各客戶累積訂單金額與筆數，協助企業辨識重要客戶並制訂行銷策略。
:::

## ER圖
![ERdiagram](https://hackmd.io/_uploads/BkgSWVgVgx.png)

## 主鍵設計
:::spoiler
 Customer	customer_id	每位顧客一個唯一編號。
        Product	    product_id	每項商品一個唯一編號。
        Supplier	supplier_id	每個供應商一個唯一編號。
        Orders	    order_id	每張訂單一個唯一編號。
        OrderDetail	detail_id	每筆訂單明細一個唯一編號。
        Purchase	purchase_id	每筆進貨一個唯一編號。
        Inventory	inventory_id每筆庫存紀錄一個唯一編號。  
:::
## 外鍵設計
:::spoiler
Orders.customer_id	    Customer.customer_id 一張訂單屬於一位顧客
        OrderDetail.order_id	Orders.order_id	     一筆訂單明細屬於某一張訂單
        OrderDetail.product_id	Product.product_id	 訂單明細中指向所訂購的產品
        Purchase.product_id	    Product.product_id	 進貨資料中指向所採購的產品
        Purchase.supplier_id	Supplier.supplier_id 每筆進貨來自一個供應商
        Inventory.product_id	Product.product_id	 每筆庫存異動對應一個產品（進貨或出貨）  
:::
## 資料表結構設計和進階sql功能運用:
:::spoiler
Customer:存放客戶基本資料
        Product:存放產品名稱、價格與庫存資訊
        Supplier:存放供應商基本資料
        Purchase:紀錄每筆進貨內容
        Inventory:詳細記錄進貨或出貨的庫存變動
        Orders:訂單主檔，含客戶與日期
        OrderDetail:每筆訂單的商品與數量明細    
:::
### 創建TABLE並插入資料
```sql=CREATE TABLE Customer (
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

```
### 總月銷售報表（View + GROUP BY + Function）
```sql=
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

```
### 庫存安全量檢查（Trigger + 警示查詢）
```sql=
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

```

### 客戶訂單分析（Function + View)
```sql=
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
---計算每位客戶的累積訂單金額、訂單次數，評估是否為「重要客戶」，(例如:訂購金額是否超過1000)。
SELECT * FROM CustomerOrderAnalysis WHERE total_spent > 1000;

```
### 用交易（Transaction）一次性插入資料
```sql=
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

COMMIT;
```
## 功能測試

### 總月銷售
![螢幕擷取畫面 2025-06-18 205343](https://hackmd.io/_uploads/HkRBPVlExg.png)

### 庫存安全量警示
![螢幕擷取畫面 2025-06-18 205357](https://hackmd.io/_uploads/ry7_w4x4eg.png)

### 客戶訂單分析（購金額是否超過1000)
![螢幕擷取畫面 2025-06-18 205433](https://hackmd.io/_uploads/Sychv4lNxl.png)
