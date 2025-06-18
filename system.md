訂單 / 進銷存系統
    需求說明:
        透過資料庫設計與 SQL 查詢，協助企業記錄產品庫存、管理供應商與客戶訂單，並提供即時分析功能，如月銷售、庫存安全量、客戶訂單分析。
        主要功能:
            客戶管理:建立與維護客戶基本資料，包括姓名、電話、Email 與地址。
            產品管理:建立產品資料，包含單價、庫存量與安全庫存值。
            供應商管理:記錄供應商資訊及其聯絡方式，用於後續進貨紀錄。
            訂單管理:客戶下訂單時建立訂單資料與訂單明細，包含訂購的產品、數量與價格。
            進貨與庫存管理:	建立進貨記錄，並透過 Inventory 表記錄商品進出，維護即時庫存變化。
            銷售報表查詢:提供每月總銷售金額與訂單筆數，支援時間序列分析與業績報告。
            安全庫存警示:比對產品庫存與安全庫存值，找出庫存不足商品，提醒補貨。
            客戶分析:分析各客戶累積訂單金額與筆數，協助企業辨識重要客戶並制訂行銷策略。
    資料表結構:
        Customer:存放客戶基本資料
        Product:存放產品名稱、價格與庫存資訊
        Supplier:存放供應商基本資料
        Purchase:紀錄每筆進貨內容
        Inventory:詳細記錄進貨或出貨的庫存變動
        Orders:訂單主檔，含客戶與日期
        OrderDetail:每筆訂單的商品與數量明細    
    主鍵設計:
        Customer	customer_id	每位顧客一個唯一編號。
        Product	    product_id	每項商品一個唯一編號。
        Supplier	supplier_id	每個供應商一個唯一編號。
        Orders	    order_id	每張訂單一個唯一編號。
        OrderDetail	detail_id	每筆訂單明細一個唯一編號。
        Purchase	purchase_id	每筆進貨一個唯一編號。
        Inventory	inventory_id每筆庫存紀錄一個唯一編號。    
    外鍵設計:  
        Orders.customer_id	    Customer.customer_id 一張訂單屬於一位顧客
        OrderDetail.order_id	Orders.order_id	     一筆訂單明細屬於某一張訂單
        OrderDetail.product_id	Product.product_id	 訂單明細中指向所訂購的產品
        Purchase.product_id	    Product.product_id	 進貨資料中指向所採購的產品
        Purchase.supplier_id	Supplier.supplier_id 每筆進貨來自一個供應商
        Inventory.product_id	Product.product_id	 每筆庫存異動對應一個產品（進貨或出貨）  