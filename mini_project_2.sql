DROP DATABASE IF EXISTS db_miniproject2;
CREATE DATABASE db_miniproject2;
USE db_miniproject2;

CREATE TABLE Customers (
	customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    customer_mail VARCHAR(50) UNIQUE NOT NULL,
    customer_gender ENUM("M", "F"),
    birthday DATE
);

CREATE TABLE Categories (
	category_id INT PRIMARY KEY AUTO_INCREMENT,
	category_name VARCHAR(100) NOT NULL
);

CREATE TABLE Products (
	product_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
	product_name VARCHAR(100) NOT NULL,
    product_price DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Categories (category_id)
);

CREATE TABLE Orders (
	order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE Order_Detail(
	order_id INT,
    product_id INT,
    order_quantity INT NOT NULL CHECK(order_quantity > 0),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
INSERT INTO Categories (category_name) VALUES 
('Điện tử'), ('Thời trang'), ('Gia dụng'), ('Sách'), ('Thực phẩm');

-- 2. Customers
INSERT INTO Customers (customer_name, customer_mail, customer_gender, birthday) VALUES
('Nguyễn Văn An', 'an.nguyen@gmail.com', 'M', '1995-05-10'),
('Trần Thị Bình', 'binh.tran@gmail.com', 'F', '2000-08-20'),
('Lê Hoàng Nam', 'nam.le@gmail.com', 'M', '1988-12-15'),
('Phạm Minh Anh', 'anh.pham@gmail.com', 'F', '2005-02-25'),
('Vũ Đức Huy', 'huy.vu@gmail.com', 'M', '1992-07-30');

-- 3. Products
INSERT INTO Products (category_id, product_name, product_price) VALUES
(1, 'iPhone 15', 25000000),
(1, 'Laptop Dell', 18000000),
(2, 'Áo sơ mi', 350000),
(3, 'Nồi cơm điện', 1200000),
(3, 'Tủ lạnh Samsung', 12000000),
(4, 'Sách Đắc Nhân Tâm', 150000);

-- 4. Orders
INSERT INTO Orders (customer_id, order_date, total_amount) VALUES
(1, '2023-10-01', 25350000),
(2, '2023-10-05', 150000),
(1, '2023-11-10', 1200000),
(3, '2023-12-01', 18000000),
(5, '2023-12-15', 12000000);

-- 5. Order_Detail
INSERT INTO Order_Detail (order_id, product_id, order_quantity) VALUES
(1, 1, 1),
(1, 3, 1),
(2, 6, 1),
(3, 4, 1),
(4, 2, 1),
(5, 5, 1);

-- Cập nhật
UPDATE Products
SET product_price = 2222222
WHERE product_id = 3;

UPDATE Customers
SET customer_mail = "abc@gmail.com"
WHERE customer_id = 1;

-- Xóa dữ liệu
DELETE FROM Order_Detail
WHERE order_id = 1 AND product_id = 2; 

-- Truy vấn
-- 1.	Lấy danh sách khách hàng gồm họ tên, email và sử dụng câu lệnh CASE để hiển thị giới tính dưới dạng văn bản ('Nam' hoặc 'Nữ')
SELECT customer_name, customer_mail,
	CASE
		WHEN customer_gender = 'M' THEN 'Nam'
        WHEN customer_gender = 'F' THEN 'Nữ'
	END AS gender
FROM Customers;
-- 2.	Lấy thông tin 3 khách hàng trẻ tuổi nhất: Sử dụng hàm YEAR() và NOW() để tính tuổi, kết hợp mệnh đề ORDER BY và LIMIT.
SELECT customer_name, birthday, (YEAR(NOW()) - YEAR(birthday)) AS AGE FROM Customers
ORDER BY birthday DESC
LIMIT 3;
-- 3.	Hiển thị danh sách tất cả các đơn hàng kèm theo tên khách hàng tương ứng (Sử dụng INNER JOIN).
SELECT o.order_id, o.order_date, c.customer_name 
FROM Orders AS o
INNER JOIN Customers AS c
ON o.customer_id = c.customer_id;
-- 4.	Đếm số lượng sản phẩm theo từng danh mục. Sử dụng GROUP BY và HAVING để chỉ hiển thị các danh mục có từ 2 sản phẩm trở lên.
SELECT cat.category_name, COUNT(p.product_id) AS total_product
FROM Categories AS cat
INNER JOIN Products AS p
ON cat.category_id = p.category_id
GROUP BY cat.category_name
HAVING total_product >= 2;
-- 5. Lấy danh sách các sản phẩm có giá lớn hơn giá trị trung bình (AVG) của tất cả các sản phẩm trong cửa hàng.
SELECT * FROM Products
WHERE product_price > (SELECT AVG(product_price) FROM Products);
-- 6. Lấy danh sách thông tin các khách hàng chưa từng đặt bất kỳ đơn hàng nào (Sử dụng toán tử NOT IN kết hợp truy vấn lồng).
SELECT * FROM Customers
WHERE customer_id NOT IN (SELECT customer_id FROM Orders);
-- 7. Tìm các phòng ban/danh mục có tổng doanh thu lớn hơn 120% doanh thu trung bình của toàn bộ cửa hàng.
SELECT cat.category_name, SUM(od.order_quantity * p.product_price) AS total_revenue
FROM Categories AS cat
INNER JOIN Products AS p
ON cat.category_id = p.category_id
INNER JOIN Order_Detail AS od
ON p.product_id = od.product_id
GROUP BY cat.category_name
HAVING total_revenue > (
	SELECT AVG(revenue_table.total) * 1.2
    FROM (
		SELECT SUM(od2.order_quantity * p2.product_price) AS total
        FROM Order_Detail AS od2
        INNER JOIN Products AS p2
        ON od2.product_id = p2.product_id
        GROUP BY p2.category_id
    ) AS revenue_table
);

-- 8. Lấy danh sách các sản phẩm có giá đắt nhất trong từng danh mục (Truy vấn con tham chiếu đến outer query).
SELECT product_name, product_price
FROM Products AS p
WHERE product_price = (
	SELECT MAX(p2.product_price)
	FROM Products AS p2
    WHERE p2.category_id = p.category_id
);
-- 9. Tìm họ tên của các khách hàng VIP đã từng mua sản phẩm thuộc danh mục 'Điện tử' (Sử dụng truy vấn lồng từ 3 cấp trở lên thông qua các bảng Customer, Order, Order_Detail, Product, Category).
SELECT customer_name 
FROM Customers 
WHERE customer_id IN (
    SELECT customer_id FROM Orders 
    WHERE order_id IN (
        SELECT order_id FROM Order_Detail 
        WHERE product_id IN (
            SELECT product_id FROM Products 
            WHERE category_id = (
                SELECT category_id FROM Categories 
                WHERE category_name = 'Điện tử'
            )
        )
    )
);