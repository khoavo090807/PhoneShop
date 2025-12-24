USE master;
GO

IF DB_ID('DB_LTW') IS NOT NULL
BEGIN
    ALTER DATABASE DB_LTW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DB_LTW;
END
GO

CREATE DATABASE DB_LTW;
GO
USE DB_LTW;
GO

-- Users
CREATE TABLE dbo.Users (
    UserId      INT IDENTITY(1,1) PRIMARY KEY,
    Email       VARCHAR(120)  NOT NULL,
    Password    VARCHAR(256)  NOT NULL,
    FullName    NVARCHAR(120),
    Phone       VARCHAR(20),
    Role        VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER',
    IsActive    BIT DEFAULT 1,

    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT CK_Users_Role CHECK (Role IN ('ADMIN','CUSTOMER'))
);

-- CategoryGroups
CREATE TABLE dbo.CategoryGroups (
    GroupId     INT IDENTITY(1,1) PRIMARY KEY,
    GroupCode   VARCHAR(40) NOT NULL UNIQUE,
    GroupName   NVARCHAR(120) NOT NULL,
    SortOrder   INT DEFAULT 0,
    IsActive    BIT DEFAULT 1
);

-- Categories
CREATE TABLE dbo.Categories (
    CategoryId     INT IDENTITY(1,1) PRIMARY KEY,
    GroupId        INT NOT NULL,
    CatSlug        VARCHAR(120) NOT NULL UNIQUE,
    CategoryName   NVARCHAR(120) NOT NULL,
    Description    NVARCHAR(300),
    SortOrder      INT DEFAULT 0,
    IsActive       BIT DEFAULT 1,

    CONSTRAINT FK_Categories_CategoryGroups
        FOREIGN KEY (GroupId) REFERENCES dbo.CategoryGroups(GroupId)
);

-- Products
CREATE TABLE dbo.Products (
    ProductId       INT IDENTITY(1,1) PRIMARY KEY,
    SKU             VARCHAR(180) NOT NULL UNIQUE,
    ProductName     NVARCHAR(180) NOT NULL,
    Slug            VARCHAR(255) NOT NULL UNIQUE,
    MainImage       NVARCHAR(250),
    Summary         NVARCHAR(300),
    Price           DECIMAL(12,0) NOT NULL,
    Stock           INT DEFAULT 999,
    IsActive        BIT DEFAULT 1
);

-- CategoryDetails
CREATE TABLE dbo.CategoryDetails (
    CategoryId INT NOT NULL,
    ProductId  INT NOT NULL,

    CONSTRAINT PK_CategoryDetails PRIMARY KEY (CategoryId, ProductId),

    CONSTRAINT FK_CategoryDetails_Categories
        FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId),

    CONSTRAINT FK_CategoryDetails_Products
        FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId)
);

-- ProductImages
CREATE TABLE dbo.ProductImages (
    ImageId     INT IDENTITY(1,1) PRIMARY KEY,
    ProductId   INT NOT NULL,
    ImageUrl    NVARCHAR(260) NOT NULL,

    CONSTRAINT FK_ProductImages_Products
        FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId)
);

-- Orders
CREATE TABLE dbo.Orders (
    OrderId       INT IDENTITY(1,1) PRIMARY KEY,
    UserId        INT,
    CustomerName  NVARCHAR(120) NOT NULL,
    Phone         VARCHAR(20) NOT NULL,
    Address       NVARCHAR(220),
    Status        VARCHAR(20) DEFAULT 'PENDING',
    TotalAmount   DECIMAL(12,0) DEFAULT 0,

    CONSTRAINT FK_Orders_Users
        FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);

-- OrderItems
CREATE TABLE dbo.OrderItems (
    OrderItemId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId     INT NOT NULL,
    ProductId   INT NOT NULL,
    ProductName NVARCHAR(180) NOT NULL,
    Quantity    INT NOT NULL CHECK (Quantity > 0),
    UnitPrice   DECIMAL(12,0) NOT NULL,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId)
);
GO


--=== NHẬP DỮ LIỆU ===--

/* =========================
   INSERT User
========================= */
INSERT dbo.Users (Email, Password, FullName, Role)
VALUES 
('admin@gmail.com', '123456', N'Quản trị viên', 'ADMIN'),
('khachhang@gmail.com', '123456', N'Nguyễn Văn A', 'CUSTOMER');

/* =========================
   INSERT CategoryGroups
========================= */
INSERT INTO dbo.CategoryGroups (GroupCode, GroupName, SortOrder)
VALUES
('brand', N'Hãng', 1),
('usage', N'Nhu cầu', 2);


/* =========================
   INSERT Categories
   Brand: 1..5  | Usage: 6..9 (theo thứ tự insert)
========================= */
INSERT INTO dbo.Categories (GroupId, CatSlug, CategoryName, Description, SortOrder)
VALUES
-- ===== BRAND =====
(1, 'macbook',   N'MacBook',   NULL, 1),
(1, 'asus',      N'ASUS',      NULL, 2),
(1, 'dell',      N'Dell',      NULL, 3),
(1, 'gigabyte',  N'Gigabyte',  NULL, 4),
(1, 'samsung',   N'Samsung',   NULL, 5),

-- ===== USAGE =====
(2, 'office',     N'Văn phòng',     NULL, 1),
(2, 'gaming',     N'Gaming',     NULL, 2),
(2, 'student',    N'Sinh viên',    NULL, 3),
(2, 'laptop-ai',  N'Laptop AI',  NULL, 4);


/* =========================
   INSERT PRODUCTS
   Gán ProductId cố định 1..20
========================= */
SET IDENTITY_INSERT dbo.Products ON;

INSERT INTO dbo.Products
(ProductId, SKU, ProductName, Slug, MainImage, Summary, Price, Stock, IsActive)
VALUES
(1,  'MAC-M3-01',         N'MacBook Air M3 13 inch 8GB 256GB',        'macbook-air-m3-13',        'mac-air-m3.webp',        N'Chip M3 cực mạnh, màn hình Liquid Retina',            27990000, 50, 1),
(2,  'MAC-M2-02',         N'MacBook Air M2 13 inch 8GB 256GB',        'macbook-air-m2-13',        'mac-air-m2.webp',        N'Thiết kế mới, mỏng nhẹ, pin trâu',                     22490000, 30, 1),
(3,  'MAC-PRO-M3',        N'MacBook Pro 14 M3 8GB 512GB',             'macbook-pro-14-m3',        'mac-pro-m3.webp',        N'Màn hình 120Hz ProMotion, Chip M3 mạnh mẽ',            39990000, 20, 1),
(4,  'ASUS-TUF-F15',      N'Laptop ASUS TUF Gaming F15 FX507ZC4',     'asus-tuf-gaming-f15',      'asus-tuf-f15.webp',      N'RTX 3050, Core i5-12500H, 144Hz',                      18490000, 45, 1),
(5,  'ASUS-VIVO-15',      N'Laptop ASUS Vivobook 15 X1504ZA',         'asus-vivobook-15',         'asus-vivobook-15.webp',  N'Core i5-1235U, RAM 16GB, Màn OLED',                    14990000, 60, 1),
(6,  'ASUS-ROG-G16',      N'Laptop ASUS ROG Strix G16 G614JU',        'asus-rog-strix-g16',       'asus-rog-g16.webp',      N'RTX 4050, Core i7-13650HX, Cực ngầu',                  32990000, 15, 1),
(7,  'ASUS-ZEN-14',       N'Laptop ASUS Zenbook 14 OLED UX3405MA',    'asus-zenbook-14',          'asus-zen-14.webp',       N'Laptop AI Core Ultra 5, Màn 3K OLED',                  26990000, 25, 1),
(8,  'DELL-INS-3520',     N'Laptop Dell Inspiron 3520',               'dell-inspiron-3520',       'dell-ins-3520.webp',     N'Core i5-1235U, RAM 8GB, 120Hz',                        13490000, 40, 1),
(9,  'DELL-VOS-3430',     N'Laptop Dell Vostro 3430',                 'dell-vostro-3430',         'dell-vos-3430.webp',     N'Gọn nhẹ văn phòng, Core i5 gen 13',                    15990000, 35, 1),
(10, 'DELL-XPS-13-9315',  N'Laptop Dell XPS 13 9315',                 'dell-xps-13-9315',         'dell-xps-13.webp',       N'Siêu phẩm mỏng nhẹ, màn hình cực đẹp',                 24990000, 10, 1),
(11, 'GIG-G5-MF',         N'Laptop Gigabyte Gaming G5 MF5',           'gigabyte-gaming-g5',       'gig-g5.webp',            N'RTX 4050, i5-13500H',                                  19490000, 20, 1),
(12, 'GIG-AERO-14',       N'Laptop Gigabyte AERO 14 OLED',            'gigabyte-aero-14',         'gig-aero.webp',          N'Dành cho creator, màn OLED 2.8K',                       35000000,  8, 1),
(13, 'ASUS-ROG-ALLY-X',   N'Máy chơi game ASUS ROG Ally X',           'asus-rog-ally-x',          'rog-ally.webp',          N'Thiết bị chơi game cầm tay mạnh nhất',                 22990000, 15, 1),
(14, 'MAC-M3-MAX',        N'MacBook Pro 14 inch M3 Max 96GB',         'macbook-pro-14-m3-max',    'mac-pro-14.webp',        N'Đỉnh cao hiệu năng đồ họa',                             89990000,  5, 1),
(15, 'DELL-G15-5530',     N'Laptop Dell Gaming G15 5530',             'dell-gaming-g15',          'dell-g15.webp',          N'Hầm hố, tản nhiệt tốt, i7-13650HX',                     26490000, 18, 1),
(16, 'ASUS-TUF-A15',      N'Laptop ASUS TUF Gaming A15 FA506NC',      'asus-tuf-gaming-a15',      'asus-tuf-a15.webp',      N'AMD Ryzen 5-7535HS, RTX 3050',                          16990000, 22, 1),
(17, 'ALIENWARE-X14-R1',  N'Laptop Alienware X14 R1',                 'alienware-x14-r1',         'alienware-x14-r1.webp',  N'Đậm chất game thủ, hiệu suất siêu cao.',                19000000, 10, 1),
(18, 'MAC-AIR-M1',        N'Apple MacBook Air M1 256GB 2020',         'macbook-air-m1-2020',      'mac-air-m1.webp',        N'Mỏng, nhẹ, tiện lợi',                                   30990000, 25, 1),
(19, 'ASUS-VIVO-S14',     N'Laptop ASUS Vivobook S 14 OLED S5406MA',  'asus-vivobook-s14',        'asus-s14.webp',          N'Chip Intel Core Ultra tích hợp AI',                     25490000, 20, 1),
(20, 'DELL-INS-5440',     N'Laptop Dell Inspiron 5440 i5-1334U',      'dell-inspiron-5440',       'dell-ins-5440.webp',     N'Vỏ kim loại bền bỉ, sang trọng',                        17990000, 15, 1);

SET IDENTITY_INSERT dbo.Products OFF;
GO


/* =========================
   INSERT CATEGORYDETAILS
   Brand + Usage (2 dòng / sản phẩm)
   Brand: 1..5 | Usage: 6..9
========================= */
INSERT INTO dbo.CategoryDetails (CategoryId, ProductId)
VALUES
-- MAC-M3-01 (Brand Macbook=1, Usage Laptop AI=9)
(1, 1), (9, 1),

-- MAC-M2-02 (Brand=1, Usage Student=8)
(1, 2), (8, 2),

-- MAC-PRO-M3 (Brand=1, Usage Laptop AI=9)
(1, 3), (9, 3),

-- ASUS-TUF-F15 (Brand Asus=2, Usage Gaming=7)
(2, 4), (7, 4),

-- ASUS-VIVO-15 (Brand=2, Usage Office=6)
(2, 5), (6, 5),

-- ASUS-ROG-G16 (Brand=2, Usage Gaming=7)
(2, 6), (7, 6),

-- ASUS-ZEN-14 (Brand=2, Usage Laptop AI=9)
(2, 7), (9, 7),

-- DELL-INS-3520 (Brand Dell=3, Usage Student=8)
(3, 8), (8, 8),

-- DELL-VOS-3430 (Brand=3, Usage Office=6)
(3, 9), (6, 9),

-- DELL-XPS-13-9315 (Brand=3, Usage Office=6)
(3, 10), (6, 10),

-- GIG-G5-MF (Brand Gigabyte=4, Usage Gaming=7)
(4, 11), (7, 11),

-- GIG-AERO-14 (Brand=4, Usage Laptop AI=9)
(4, 12), (9, 12),

-- ASUS-ROG-ALLY-X (Brand=2, Usage Gaming=7)
(2, 13), (7, 13),

-- MAC-M3-MAX (Brand=1, Usage Laptop AI=9)
(1, 14), (9, 14),

-- DELL-G15-5530 (Brand=3, Usage Gaming=7)
(3, 15), (7, 15),

-- ASUS-TUF-A15 (Brand=2, Usage Gaming=7)
(2, 16), (7, 16),

-- ALIENWARE-X14-R1 (giữ y như data cũ của bạn: Brand=5(samsung), Usage=6(office))
(5, 17), (6, 17),

-- MAC-AIR-M1 (Brand=1, Usage Student=8)
(1, 18), (8, 18),

-- ASUS-VIVO-S14 (Brand=2, Usage Laptop AI=9)
(2, 19), (9, 19),

-- DELL-INS-5440 (Brand=3, Usage Student=8)
(3, 20), (8, 20);
GO


/* =========================
   INSERT PRODUCTIMAGES
========================= */
INSERT INTO dbo.ProductImages (ProductId, ImageUrl)
VALUES
-- 1. MAC-M3-01
(1, 'mac-air-m3-1.webp'), (1, 'mac-air-m3-2.webp'), (1, 'mac-air-m3-3.webp'),

-- 2. MAC-M2-02
(2, 'mac-air-m2-1.webp'), (2, 'mac-air-m2-2.webp'), (2, 'mac-air-m2-3.webp'),

-- 3. MAC-PRO-M3
(3, 'mac-pro-m3-1.webp'), (3, 'mac-pro-m3-2.webp'), (3, 'mac-pro-m3-3.webp'),

-- 4. ASUS-TUF-F15
(4, 'asus-tuf-f15-1.webp'), (4, 'asus-tuf-f15-2.webp'), (4, 'asus-tuf-f15-3.webp'),

-- 5. ASUS-VIVO-15
(5, 'asus-vivo-15-1.webp'), (5, 'asus-vivo-15-2.webp'), (5, 'asus-vivo-15-3.webp'),

-- 6. ASUS-ROG-G16
(6, 'asus-rog-g16-1.webp'), (6, 'asus-rog-g16-2.webp'), (6, 'asus-rog-g16-3.webp'),

-- 7. ASUS-ZEN-14
(7, 'asus-zen-14-1.webp'), (7, 'asus-zen-14-2.webp'), (7, 'asus-zen-14-3.webp'),

-- 8. DELL-INS-3520
(8, 'dell-ins-3520-1.webp'), (8, 'dell-ins-3520-2.webp'), (8, 'dell-ins-3520-3.webp'),

-- 9. DELL-VOS-3430
(9, 'dell-vos-3430-1.webp'), (9, 'dell-vos-3430-2.webp'), (9, 'dell-vos-3430-3.webp'),

-- 10. DELL-XPS-13-9315
(10, 'dell-xps-13-1.webp'), (10, 'dell-xps-13-2.webp'), (10, 'dell-xps-13-3.webp'),

-- 11. GIG-G5-MF
(11, 'gig-g5-1.webp'), (11, 'gig-g5-2.webp'), (11, 'gig-g5-3.webp'),

-- 12. GIG-AERO-14
(12, 'gig-aero-14-1.webp'), (12, 'gig-aero-14-2.webp'), (12, 'gig-aero-14-3.webp'),

-- 13. ASUS-ROG-ALLY-X
(13, 'rog-ally-1.webp'), (13, 'rog-ally-2.webp'), (13, 'rog-ally-3.webp'),

-- 14. MAC-M3-MAX
(14, 'macbook-pro-14-1.webp'), (14, 'macbook-pro-14-2.webp'), (14, 'macbook-pro-14-3.webp'),

-- 15. DELL-G15-5530
(15, 'dell-g15-1.webp'), (15, 'dell-g15-2.webp'), (15, 'dell-g15-3.webp'),

-- 16. ASUS-TUF-A15
(16, 'asus-tuf-a15-1.webp'), (16, 'asus-tuf-a15-2.webp'), (16, 'asus-tuf-a15-3.webp'),

-- 17. ALIENWARE-X14-R1
(17, 'alienware-x14-r1-1.webp'), (17, 'alienware-x14-r1-2.webp'), (17, 'alienware-x14-r1-3.webp'),

-- 18. MAC-AIR-M1
(18, 'mac-air-m1-1.webp'), (18, 'mac-air-m1-2.webp'), (18, 'mac-air-m1-3.webp'),

-- 19. ASUS-VIVO-S14
(19, 'asus-s14-1.webp'), (19, 'asus-s14-2.webp'), (19, 'asus-s14-3.webp'),

-- 20. DELL-INS-5440
(20, 'dell-ins-5440-1.webp'), (20, 'dell-ins-5440-2.webp'), (20, 'dell-ins-5440-3.webp');
GO



/* =========================
   INSERT ORDERS + ORDERITEMS
   (dựa trên ProductId vừa insert từ bảng @P ở trên)
========================= */

INSERT INTO dbo.Orders (UserId, CustomerName, Phone, Address, Status, TotalAmount)
VALUES
(2, N'Nguyễn Văn A', '0900000001', N'Quận 1, TP.HCM',  'PENDING', 57970000),
(2, N'Nguyễn Văn A', '0900000001', N'Quận 7, TP.HCM',  'PAID',    55970000),
(2, N'Nguyễn Văn A', '0900000001', N'Thủ Đức, TP.HCM','SHIPPED',  57480000);

INSERT INTO dbo.OrderItems
(OrderId, ProductId, ProductName, Quantity, UnitPrice)
VALUES
-- ===== ORDER 1 =====
(1, 1,  N'MacBook Air M3 13 inch 8GB 256GB',        1, 27990000),
(1, 5,  N'Laptop ASUS Vivobook 15 X1504ZA',        2, 14990000),

-- ===== ORDER 2 =====
(2, 8,  N'Laptop Dell Inspiron 3520',              1, 13490000),
(2, 13, N'Máy chơi game ASUS ROG Ally X',           1, 22990000),
(2, 11, N'Laptop Gigabyte Gaming G5 MF5',           1, 19490000),

-- ===== ORDER 3 =====
(3, 18, N'Apple MacBook Air M1 256GB 2020',         1, 30990000),
(3, 15, N'Laptop Dell Gaming G15 5530',             1, 26490000);
