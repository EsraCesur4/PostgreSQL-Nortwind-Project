--Level 1 #############################################

--Soru 1-----------------------------------------------
/* En Çok Satış Yapan Çalışanı Bulun 
   Her çalışanın (Employees) sattığı toplam ürün adedini hesaplayarak, 
   en çok satış yapan ilk 3 çalışanı listeleyen bir sorgu yazınız. */

SELECT 
    employees.first_name || ' ' || employees.last_name AS employee_name,  -- Çalışanın tam adı birleştirilerek alınır
    SUM(order_details.quantity) AS total_products_sold                    -- Çalışanın sattığı toplam ürün adedi hesaplanır
FROM employees                                                            -- employees tablosundan veriler alınır
JOIN orders ON employees.employee_id = orders.employee_id                 -- employee_id'ye göre employees ve orders tabloları birleştirilir
JOIN order_details ON orders.order_id = order_details.order_id            -- order_id'ye göre orders ve order_details tabloları birleştirilir
GROUP BY employees.employee_id, employees.first_name, employees.last_name -- Çalışan bazında gruplama yapılır
ORDER BY total_products_sold DESC                                         -- Elde edilen toplam satışlar azalan sırada sıralanır
LIMIT 3;                                                                  -- En çok satış yapan ilk 3 çalışan listelenir


--Soru 2-----------------------------------------------
/* Aylık Satış Trendlerini Bulun 
   Siparişlerin (Orders) hangi yıl ve ayda ne kadar toplam satış geliri oluşturduğunu hesaplayan 
   ve yıllara göre sıralayan bir sorgu yazınız. */

SELECT 
    EXTRACT(YEAR FROM orders.order_date) AS year,                                    -- Sipariş tarihinden (order_date) yıl bilgisi alınır
    EXTRACT(MONTH FROM orders.order_date) AS month,                                  -- Sipariş tarihinden ay bilgisi alınır
    SUM(order_details.unit_price * order_details.quantity) AS total_sales_revenue    -- Satır bazında (fiyat*miktar) hesaplanıp toplanarak toplam satış geliri bulunur
FROM orders                                                                          -- orders tablosundan veriler alınır
JOIN order_details ON orders.order_id = order_details.order_id                       -- order_id'ye göre orders ve order_details tabloları birleştirilir
GROUP BY year, month                                                                 -- Yıl ve ay bazında gruplanır
ORDER BY year, month;                                                                -- Yıl ve ay bazında sıralanır


--Soru 3-----------------------------------------------
/* En Karlı Ürün Kategorisini Bulun 
   Her ürün kategorisinin (Categories), o kategoriye ait ürünlerden (Products) yapılan satışlar sonucunda 
   elde ettiği toplam geliri hesaplayan bir sorgu yazınız. */

SELECT 
    categories.category_name,                                                   -- Kategori adı
    SUM(order_details.unit_price * order_details.quantity) AS total_revenue     -- Kategorideki ürünlerden elde edilen toplam gelir
FROM categories                                                                  -- categories tablosundan veriler alınır
JOIN products ON categories.category_id = products.category_id                  -- category_id'ye göre categories ve products tabloları birleştirilir
JOIN order_details ON products.product_id = order_details.product_id            -- product_id'ye göre products ve order_details tabloları birleştirilir
GROUP BY categories.category_name                                               -- Kategori ismine göre gruplama yapılır
ORDER BY total_revenue DESC;                                                    -- Toplam gelir azalan sırada sıralanır


--Soru 4-----------------------------------------------
/* Belli Bir Tarih Aralığında En Çok Sipariş Veren Müşterileri Bulun 
   1997 yılında en fazla sipariş veren ilk 5 müşteriyi listeleyen bir sorgu yazınız. */

SELECT 
    customers.company_name,                     -- Müşteri şirket adı
    COUNT(orders.order_id) AS total_orders      -- Her müşterinin toplam sipariş miktarı
FROM customers                                  -- customers tablosundan veriler alınır
JOIN orders ON customers.customer_id = orders.customer_id -- customer_id'ye göre customers ve orders tabloları birleştirilir
WHERE orders.order_date BETWEEN '1997-01-01' AND '1997-12-31' -- 1997 yılı içerisindeki siparişleri filtreler
GROUP BY customers.company_name                 -- Şirket ismine göre gruplama yapılır
ORDER BY total_orders DESC                      -- Toplam sipariş miktarı azalan sırada sıralanır
LIMIT 5;                                        -- En fazla sipariş veren ilk 5 müşteri listelenir


--Soru 5-----------------------------------------------
/* Ülkelere Göre Toplam Sipariş ve Ortalama Sipariş Tutarını Bulun 
   Müşterilerin bulunduğu ülkeye göre toplam sipariş sayısını ve ortalama sipariş tutarını hesaplayan 
   bir sorgu yazınız. Sonucu toplam sipariş sayısına göre büyükten küçüğe sıralayın. */

SELECT 
    customers.country,                                                         -- Müşterinin ülkesi
    COUNT(orders.order_id) AS total_orders,                                    -- Ülke bazında toplam sipariş sayısı
    AVG(order_details.unit_price * order_details.quantity) AS average_order_amount -- Ülke bazında ortalama sipariş tutarı
FROM customers                                                                 -- customers tablosundan veriler alınır
JOIN orders ON customers.customer_id = orders.customer_id                      -- customer_id'ye göre customers ve orders tabloları birleştirilir
JOIN order_details ON orders.order_id = order_details.order_id                 -- order_id'ye göre orders ve order_details tabloları birleştirilir
GROUP BY customers.country                                                     -- Ülke bazında gruplama yapılır
ORDER BY total_orders DESC;                                                    -- Toplam sipariş sayısına göre azalan sıralama yapılır


--Level 2 #################################################

--Soru 1--------------------------------------------------
/* Her Çalışanın En Çok Satış Yaptığı Ürünü Bulun 
   Her çalışanın (Employees) sattığı ürünler içinde en çok sattığı (toplam adet olarak) ürünü bulun 
   ve sonucu çalışana göre sıralayın. */

WITH ProductSales AS (                                                                      -- Geçici bir tablo (CTE) tanımlanır
    SELECT 
        employees.employee_id,                                                              -- Çalışanın ID'si
        employees.first_name || ' ' || employees.last_name AS employee_name,                -- Çalışanın tam adı
        products.product_name,                                                              -- Ürün adı
        SUM(order_details.quantity) AS total_quantity_sold                                  -- Toplam satılan miktar
    FROM employees                                                                          -- employees tablosu
    JOIN orders ON employees.employee_id = orders.employee_id                               -- employee_id üzerinden employees ve orders birleştirilir
    JOIN order_details ON orders.order_id = order_details.order_id                          -- order_id üzerinden orders ve order_details birleştirilir
    JOIN products ON order_details.product_id = products.product_id                         -- product_id üzerinden order_details ve products birleştirilir
    GROUP BY employees.employee_id, employees.first_name, employees.last_name, products.product_name -- Gruplama
)

SELECT 
    employee_name,               -- Çalışan adı
    product_name,                -- Ürün adı
    total_quantity_sold          -- Toplam satılan miktar
FROM (
    SELECT 
        employee_name, 
        product_name, 
        total_quantity_sold,
        ROW_NUMBER() OVER (PARTITION BY employee_name ORDER BY total_quantity_sold DESC) AS row_num
        -- Her çalışan için (employee_name bazında) satış miktarına göre sıralama ve satır numarası oluşturma
    FROM ProductSales
) AS ranked_sales
WHERE row_num = 1               -- En çok satılan (ilk sıradaki) ürünü seçer
ORDER BY employee_name;         -- Çalışana göre sıralar


--Soru 2-----------------------------------------------
/* Bir Ülkenin Müşterilerinin Satın Aldığı En Pahalı Ürünü Bulun 
   Belli bir ülkenin (örneğin "Germany") müşterilerinin verdiği siparişlerde satın aldığı 
   en pahalı ürünü (UnitPrice olarak) bulun ve hangi müşterinin aldığını listeleyin. */

WITH CustomerPurchases AS (
    SELECT 
        customers.customer_id,                 -- Müşteri ID'si
        customers.company_name AS customer_name, -- Müşteri şirket adı
        customers.country,                     -- Müşterinin bulunduğu ülke
        products.product_name,                 -- Ürün adı
        products.unit_price                    -- Ürünün birim fiyatı
    FROM customers                             -- customers tablosu
    JOIN orders ON customers.customer_id = orders.customer_id  -- customer_id'ye göre customers ve orders birleştirilir
    JOIN order_details ON orders.order_id = order_details.order_id  -- order_id'ye göre orders ve order_details birleştirilir
    JOIN products ON order_details.product_id = products.product_id -- product_id'ye göre order_details ve products birleştirilir
    WHERE customers.country = 'Germany'        -- Yalnızca "Germany" ülkesindeki müşteriler filtrelenir
)

SELECT 
    customer_name,         -- Müşteri adı
    product_name,          -- Ürün adı
    unit_price             -- Ürünün birim fiyatı
FROM (
    SELECT 
        customer_name, 
        product_name, 
        unit_price, 
        ROW_NUMBER() OVER (ORDER BY unit_price DESC) AS row_num
        -- Birim fiyata göre azalan sıralama yapıp satır numarası oluşturulur
    FROM CustomerPurchases
) AS ranked_products
WHERE row_num = 1;          -- En pahalı (ilk sıradaki) ürünü seçer


--Soru 3-----------------------------------------------
/* Her Kategoride (Categories) En Çok Satış Geliri Elde Eden Ürünü Bulun 
   Her kategori için toplam satış geliri en yüksek olan ürünü bulun ve listeleyin. */

WITH ProductRevenue AS (
    SELECT 
        categories.category_name,   -- Kategori adı
        products.product_name,      -- Ürün adı
        SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS total_revenue
        -- Ürünün satış geliri (fiyat * miktar * indirim sonrası) toplanır
    FROM categories                 -- categories tablosu
    JOIN products ON categories.category_id = products.category_id       -- category_id üzerinden birleştirme
    JOIN order_details ON products.product_id = order_details.product_id -- product_id üzerinden birleştirme
    GROUP BY categories.category_name, products.product_name             -- Kategori ve ürün adına göre gruplama
)

SELECT 
    category_name,    -- Kategori adı
    product_name,     -- Ürün adı
    total_revenue     -- Toplam satış geliri
FROM (
    SELECT 
        category_name, 
        product_name, 
        total_revenue,
        ROW_NUMBER() OVER (PARTITION BY category_name ORDER BY total_revenue DESC) AS row_num
        -- Her kategori içinde satış geliri en yüksek ürünü bulmak için sıralama
    FROM ProductRevenue
) AS ranked_revenue
WHERE row_num = 1;     -- En yüksek gelire sahip ürünü seçer


--Soru 4-----------------------------------------------
/* Arka Arkaya En Fazla Sipariş Veren Müşteriyi Bulun 
   Sipariş tarihleri (OrderDate) baz alınarak arka arkaya en fazla sipariş veren müşteriyi bulun. 
   (Örneğin, bir müşteri ardışık günlerde kaç sipariş vermiş?) */

WITH ConsecutiveOrders AS (
    SELECT 
        customer_id,                                                  -- Müşteri ID'si
        order_date,                                                   -- Sipariş tarihi
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date
        -- Her müşteri için önceki sipariş tarihini (önceki satır) bulabilmek adına LAG fonksiyonu kullanılır
    FROM orders                                                       -- orders tablosu
)

SELECT 
    customer_id,         -- Müşteri ID'si
    COUNT(*) AS consecutive_days -- Ardışık gün sayısı
FROM ConsecutiveOrders
WHERE prev_order_date IS NOT NULL 
  AND order_date = prev_order_date + INTERVAL '1 day'
  -- Bir önceki sipariş tarihinden 1 gün sonra verilen siparişleri yakalar
GROUP BY customer_id           -- Müşteri bazında gruplama
ORDER BY consecutive_days DESC  -- Ardışık sipariş gün sayısına göre azalan sıralama
LIMIT 1;                        -- En çok ardışık sipariş veren ilk müşteri


--Soru 5-----------------------------------------------
/* Çalışanların Sipariş Sayısına Göre Kendi Departmanındaki Ortalamanın Üzerinde Olup Olmadığını Belirleyin 
   Her çalışanın aldığı sipariş sayısını hesaplayın ve kendi departmanındaki çalışanların 
   ortalama sipariş sayısıyla karşılaştırın. 
   Ortalama sipariş sayısının üstünde veya altında olduğunu belirten bir sütun ekleyin. */

WITH EmployeeOrders AS (
    SELECT 
        employees.employee_id,                                           -- Çalışan ID'si
        employees.first_name || ' ' || employees.last_name AS employee_name, -- Çalışanın tam adı
        COUNT(orders.order_id) AS total_orders                           -- Her çalışanın aldığı toplam sipariş sayısı
    FROM employees                                                       -- employees tablosu
    JOIN orders ON employees.employee_id = orders.employee_id            -- employees ve orders birleştirilir
    GROUP BY employees.employee_id                                       -- Çalışan bazında gruplama
),
DepartmentAverage AS (
    SELECT 
        AVG(total_orders) AS avg_orders    -- Bütün çalışanların ortalama sipariş sayısı (burada tüm departman gibi düşünülmüş)
    FROM EmployeeOrders
)

SELECT 
    employee_name, 
    total_orders, 
    avg_orders,
    CASE 
        WHEN total_orders >= avg_orders THEN 'Above Average' -- Ortalamanın üzerinde
        ELSE 'Below Average'                                 -- Ortalamanın altında
    END AS performance
FROM EmployeeOrders, DepartmentAverage;                      -- İki CTE birlikte sorgulanır


--Level 3 #####################################################

--Soru 1-----------------------------------------------
/* Her Müşteri İçin En Son 3 Siparişi ve Toplam Harcamalarını Listeleyin 
   Her müşterinin en son 3 siparişini (OrderDate’e göre en güncel 3 sipariş) 
   ve bu siparişlerde harcadığı toplam tutarı gösteren bir sorgu yazın. 
   Sonuç müşteri bazında sıralanmalı ve her müşterinin sadece en son 3 siparişi görünmelidir. */

SELECT 
    customers.company_name AS customer_name,  -- Müşteri şirket adı
    orders.order_id,                          -- Sipariş ID'si
    orders.order_date,                        -- Sipariş tarihi
    order_totals.order_total,                 -- Bu siparişin toplam tutarı
    (
        SELECT SUM(top_orders.order_total)
        FROM (
            SELECT 
                orders_inner.order_id, 
                SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS order_total
                -- İlgili siparişin toplam tutarı (indirim uygulanarak)
            FROM orders orders_inner
            JOIN order_details ON orders_inner.order_id = order_details.order_id
            WHERE orders_inner.customer_id = customers.customer_id
            GROUP BY orders_inner.order_id
            ORDER BY orders_inner.order_date DESC
            LIMIT 3
        ) AS top_orders
    ) AS total_spent_for_top_3_orders          -- En son 3 siparişin toplam harcaması
FROM customers                                 -- customers tablosu
JOIN orders ON customers.customer_id = orders.customer_id
JOIN (
    SELECT 
        order_id, 
        SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS order_total
        -- Her order_id için siparişin toplam tutarı
    FROM order_details
    GROUP BY order_id
) AS order_totals ON orders.order_id = order_totals.order_id
WHERE orders.order_id IN (
    SELECT order_id 
    FROM orders o 
    WHERE o.customer_id = customers.customer_id 
    ORDER BY o.order_date DESC 
    LIMIT 3
)
ORDER BY customer_name, orders.order_date DESC; -- Müşteri adı ve sipariş tarihi bazında sıralama yapılır


--Soru 2-----------------------------------------------
/* Aynı Ürünü 3 veya Daha Fazla Kez Satın Alan Müşterileri Bulun 
   Bir müşteri eğer aynı ürünü (ProductID) 3 veya daha fazla sipariş verdiyse, 
   bu müşteriyi ve ürünleri listeleyen bir sorgu yazın.
   Aynı ürün bir siparişte değil, farklı siparişlerde tekrar tekrar alınmış olabilir. */

SELECT 
    customers.company_name AS customer_name,  -- Müşteri şirket adı
    products.product_name,                    -- Ürün adı
    COUNT(orders.order_id) AS purchase_count  -- Farklı siparişlerde kaç kez bu ürün alınmış
FROM customers                                -- customers tablosu
JOIN orders ON customers.customer_id = orders.customer_id     -- customers ve orders birleştirilir
JOIN order_details ON orders.order_id = order_details.order_id -- orders ve order_details birleştirilir
JOIN products ON order_details.product_id = products.product_id -- order_details ve products birleştirilir
GROUP BY customers.company_name, products.product_name
HAVING COUNT(orders.order_id) >= 3           -- Aynı ürünü en az 3 defa sipariş veren müşteriler
ORDER BY customer_name, product_name;        -- Müşteri ve ürün adına göre sıralama


--Soru 3-----------------------------------------------
/* Bir Çalışanın 30 Gün İçinde Verdiği Siparişlerin Bir Önceki 30 Güne Göre Artış/ Azalışını Hesaplayın 
   Her çalışanın (Employees), sipariş sayısının son 30 gün içinde bir önceki 30 güne kıyasla nasıl değiştiğini 
   hesaplayan bir sorgu yazın. Çalışan bazında sipariş sayısı artış/azalış yüzdesi hesaplanmalı. */

WITH EmployeeOrders AS (
    SELECT 
        employees.employee_id,    -- Çalışanın ID'si
        employees.first_name || ' ' || employees.last_name AS employee_name, -- Çalışan adı
        COUNT(orders.order_id) FILTER (WHERE orders.order_date >= CURRENT_DATE - INTERVAL '30 days')
            AS orders_last_30_days, 
            -- Son 30 gündeki sipariş sayısı
        COUNT(orders.order_id) FILTER (
            WHERE orders.order_date >= CURRENT_DATE - INTERVAL '60 days' 
              AND orders.order_date < CURRENT_DATE - INTERVAL '30 days'
        ) AS orders_previous_30_days
            -- Önceki 30 gündeki (son 30-60 gün arası) sipariş sayısı
    FROM employees                         -- employees tablosu
    LEFT JOIN orders ON employees.employee_id = orders.employee_id
    GROUP BY employees.employee_id, employees.first_name, employees.last_name
)

SELECT 
    employee_name,          -- Çalışan adı
    orders_last_30_days,    -- Son 30 gün sipariş sayısı
    orders_previous_30_days, -- Önceki 30 gün sipariş sayısı
    CASE 
        WHEN orders_previous_30_days = 0 THEN 'N/A' 
            -- Önceki 30 günde sipariş yoksa yüzdelik hesaplama mümkün değil
        ELSE ROUND((orders_last_30_days - orders_previous_30_days) * 100.0 / orders_previous_30_days, 2) || '%'
            -- Artış/Azalış yüzdesi hesaplanıp, yüzde formatında yazılır
    END AS percentage_change
FROM EmployeeOrders;         -- CTE'den gelen tabloyu sorgula


--Soru 4-----------------------------------------------
/* Her Müşterinin Siparişlerinde Kullanılan İndirim Oranının Zaman İçinde Nasıl Değiştiğini Bulun 
   Müşterilerin siparişlerinde uygulanan indirim oranlarının zaman içindeki trendini hesaplayan bir sorgu yazın.
   Müşteri bazında hareketli ortalama indirim oranlarını hesaplayın ve sipariş tarihine göre artış/azalış eğilimi belirleyin. */

WITH DiscountTrends AS (
    SELECT 
        customers.customer_id,   -- Müşteri ID'si
        customers.company_name AS customer_name, -- Müşteri şirket adı
        orders.order_date,       -- Sipariş tarihi
        AVG(order_details.discount) AS average_discount, 
            -- Bu siparişte kullanılan ortalama indirim
        AVG(AVG(order_details.discount)) OVER (
            PARTITION BY customers.customer_id 
            ORDER BY orders.order_date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS moving_avg_discount
            -- Hareketli ortalama (önceki 2 satır + mevcut satır) şeklinde indirim ortalaması
    FROM customers                 -- customers tablosu
    JOIN orders ON customers.customer_id = orders.customer_id 
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY customers.customer_id, customers.company_name, orders.order_date
)

SELECT 
    customer_name,         -- Müşteri adı
    order_date,            -- Sipariş tarihi
    average_discount,      -- Bu siparişteki ortalama indirim
    moving_avg_discount,   -- Hareketli ortalama indirim
    CASE 
        WHEN moving_avg_discount IS NULL THEN 'N/A'      -- Yeterli veri olmadığında
        WHEN average_discount > moving_avg_discount THEN 'Upward Trend'   -- Artış eğilimi
        WHEN average_discount < moving_avg_discount THEN 'Downward Trend' -- Azalış eğilimi
        ELSE 'Stable'                                    -- Değişim yok (ortalama ile aynı)
    END AS trend
FROM DiscountTrends
ORDER BY customer_name, order_date; -- Müşteri ve sipariş tarihi bazında sıralama
