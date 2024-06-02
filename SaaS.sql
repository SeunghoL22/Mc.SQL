--업체 정보 테이블
CREATE TABLE Vendors (
    VendorID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    ContactNumber VARCHAR(255),
    Email VARCHAR(255) UNIQUE,
    Address VARCHAR(255)
);

-- Users 테이블 생성
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    VendorID INT, --업체 정보
    Name VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Admin BOOLEAN NOT NULL, -- 어드민 여부
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);

CREATE TABLE FeatureToggle ( --업체 기능 ON/OFF 여부
    ToggleID INT PRIMARY KEY AUTO_INCREMENT,
    VendorID INT, -- 업체 ID
    FeatureName VARCHAR(255), -- 기능 이름
    IsEnabled BOOLEAN DEFAULT FALSE, -- 기능 활성화 여부
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 마지막으로 업데이트된 날짜와 시간
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);


-- Orders 테이블 생성
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    VendorID INT, --업체 아이디
    UserID INT,
    OrderDate DATETIME,
    DeliveryAddressID INT,
    PaymentInfoID INT,
    DeliveryPersonID INT,
    NonContactDelivery BOOLEAN,
    CouponID INT DEFAULT NULL,
    PaymentStatus ENUM('pending', 'completed', 'canceled') DEFAULT 'pending',
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID), 
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (DeliveryAddressID) REFERENCES DeliveryAddresses(DeliveryAddressID),
    FOREIGN KEY (PaymentInfoID) REFERENCES PaymentInformation(PaymentInfoID),
    FOREIGN KEY (DeliveryPersonID) REFERENCES DeliveryPersons(DeliveryPersonID),
    FOREIGN KEY (CouponID) REFERENCES Coupons(CouponID)  
);

-- OrderDetails 테이블 생성
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    VendorID INT, -- 업체 아이디
    MenuItemID INT,
    Quantity INT,
    ItemDiscount DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

CREATE TABLE CanceledOrders (
    CanceledOrderID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    UserID INT,
    CancellationReason TEXT, --취소이유
    CanceledAt DATETIME DEFAULT CURRENT_TIMESTAMP, --취소시
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


CREATE TABLE Refunds (
    RefundID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    RefundDate DATETIME,
    RefundAmount DECIMAL(10,2),
    RefundReason TEXT,
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


CREATE TABLE Reservations ( --예약 주문 자체
    ReservationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    ReservationDate DATETIME, -- 예약 날짜와 시간
    Status ENUM('pending', 'confirmed', 'canceled') DEFAULT 'pending', -- 예약 상태
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP, -- 예약이 생성된 날짜와 시간
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 예약이 업데이트된 날짜와 시간
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE ReservationItems ( --예약 주문에 속한 메뉴
    ReservationItemID INT PRIMARY KEY AUTO_INCREMENT,
    ReservationID INT, --어떤 예약에 속했는
    MenuItemID INT, --메뉴
    Quantity INT NOT NULL DEFAULT 1, --수량
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

CREATE TABLE CanceledReservations (
    CanceledReservationID INT PRIMARY KEY AUTO_INCREMENT,
    ReservationID INT,
    UserID INT,
    CancellationReason TEXT, -- 취소 이유
    CanceledAt DATETIME DEFAULT CURRENT_TIMESTAMP, -- 취소된 날짜와 시간
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


-- MenuItems 테이블 생성
CREATE TABLE MenuItems (
    MenuItemID INT PRIMARY KEY AUTO_INCREMENT,
    VendorID INT, --업체 아이디
    Name VARCHAR(255),
    Description TEXT, -- 메뉴 항목의 상세 설명
    ImageURL VARCHAR(255), -- 메뉴 항목의 이미지 URL
    Category VARCHAR(255), -- 메뉴 항목의 카테고리 (예: 샐러드, 음료, 디저트 등)
    Price DECIMAL(10,2),
    StockLevel INT DEFAULT 0, --재고 수준 알려줌 0일경우 품절
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);

-- Coupons 테이블 생성
CREATE TABLE Coupons (
    CouponID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Code VARCHAR(255),
    DiscountAmount DECIMAL(10,2), --할인금액
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- DeliveryAddresses 테이블 생성
CREATE TABLE DeliveryAddresses (
    DeliveryAddressID INT PRIMARY KEY AUTO_INCREMENT,
    VendorID INT,
    UserID INT,
    Address VARCHAR(255),
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- PaymentInformation 테이블 생성
CREATE TABLE PaymentInformation (
    PaymentInfoID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    VendorID INT, --업체 아이디
    CardNumber VARCHAR(16),
    ExpiryDate DATE,
    CVV INT,
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- DeliveryPersons 테이블 생성
CREATE TABLE DeliveryPersons (
    DeliveryPersonID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255),
    ContactNumber VARCHAR(15),
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);

CREATE TABLE DeliveryStatusMonitoring ( --배달 상태 모니터링
    MonitoringID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    DeliveryStatus ENUM('pending', 'out_for_delivery', 'delivered', 'failed') DEFAULT 'pending',
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


-- IngredientChanges 테이블 생성
CREATE TABLE IngredientChanges (
    IngredientChangeID INT PRIMARY KEY AUTO_INCREMENT,
    OrderDetailID INT,
    IngredientID INT,
    ChangeType VARCHAR(255),
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (OrderDetailID) REFERENCES OrderDetails(OrderDetailID),
    FOREIGN KEY (IngredientID) REFERENCES Ingredients(IngredientID)
);

-- Ingredients 테이블 생성
CREATE TABLE Ingredients (
    IngredientID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255),
    StockLevel INT DEFAULT 0, -- 재고 수준을 나타냅니다. 0일 경우 품절.
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);

-- Favorites  (메뉴 즐겨찾기)
CREATE TABLE Favorites (
    FavoriteID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    VendorID INT,
    MenuItemID INT,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

-- Cart 테이블 생성
CREATE TABLE Cart (
    CartID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- CartItems 테이블 생성
CREATE TABLE CartItems (
    CartItemID INT PRIMARY KEY AUTO_INCREMENT,
    CartID INT,
    MenuItemID INT,
    Quantity INT,
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (CartID) REFERENCES Cart(CartID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

-- OrderRatings 테이블 생성 (별점 시스템)
CREATE TABLE OrderRatings (
    OrderRatingID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    DeliveryPersonID INT, -- 배달원 아이디 추가 
    Rating INT CHECK (Rating >= 1 AND Rating <= 5), -- 1에서 5 사이의 정수 값
    DeliveryPersonRating INT CHECK (DeliveryPersonRating >= 1 AND DeliveryPersonRating <= 5), -- 배달원에 대한 별점
    RatingDate DATETIME DEFAULT CURRENT_TIMESTAMP, -- 평가가 기록된 날짜와 시간
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (DeliveryPersonID) REFERENCES DeliveryPersons(DeliveryPersonID)
);


--고객센터 테이블 생성
CREATE TABLE customer_support_tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    subject VARCHAR(255) NOT NULL, --문의 제목
    description TEXT NOT NULL, --문의 내용
    status VARCHAR(50) NOT NULL DEFAULT 'open', --문의 상태
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, --문의 작성시간
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, --문의 수정시간
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

--실시간 채팅상담 테이블
CREATE TABLE live_chat_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL, --고객 아이디
    agent_id INT NOT NULL, --상담원 아이디
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, --시작시간
    end_time TIMESTAMP NULL, --종료시간
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (user_id) REFERENCES Users(UserID),
    FOREIGN KEY (agent_id) REFERENCES Users(UserID) 
);

CREATE TABLE live_chat_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL, --채팅 세션 아이디
    sender_id INT NOT NULL, --보내는사람 id
    message TEXT NOT NULL, --메세지 내용
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (session_id) REFERENCES live_chat_sessions(id),
    FOREIGN KEY (sender_id) REFERENCES Users(UserID)
);


-- 챗봇 대화 테이블
CREATE TABLE chatbot_conversations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    session_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- 챗봇 메시지 테이블
CREATE TABLE chatbot_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT NOT NULL,
    sender VARCHAR(50) NOT NULL,
    sender_type ENUM('customer', 'admin', 'bot') NOT NULL, -- 발신자 유형 추가 ADMIN 구분가능
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    VendorID INT, -- 업체 아이디
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (conversation_id) REFERENCES chatbot_conversations(id)
);


--재고관리 테이블 시작--

--납품업체 정보
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    VendorID INT,
    Name VARCHAR(255) NOT NULL,
    ContactNumber VARCHAR(255),
    Email VARCHAR(255) UNIQUE,
    Address VARCHAR(255),
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);

--재고 항목 정보
CREATE TABLE StockItems (
    StockItemID INT PRIMARY KEY AUTO_INCREMENT,
    VendorID INT,
    Name VARCHAR(255) NOT NULL,
    Description TEXT,
    Category VARCHAR(255),
    CurrentStock INT DEFAULT 0,
    MinimumStockLevel INT DEFAULT 0,
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);

--발주 요청 정보
CREATE TABLE PurchaseOrders (
    PurchaseOrderID INT PRIMARY KEY AUTO_INCREMENT,
    VendorID INT,
    SupplierID INT,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('pending', 'confirmed', 'delivered', 'canceled') DEFAULT 'pending',
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);


--발주 요청한 제품
CREATE TABLE PurchaseOrderItems (
    PurchaseOrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    PurchaseOrderID INT,
    StockItemID INT,
    Quantity INT,
    Price DECIMAL(10, 2),
    FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrders(PurchaseOrderID),
    FOREIGN KEY (StockItemID) REFERENCES StockItems(StockItemID)
);

--납품 진행 상태 정보
CREATE TABLE Deliveries (
    DeliveryID INT PRIMARY KEY AUTO_INCREMENT,
    VendorID INT,
    PurchaseOrderID INT,
    DeliveryDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    DeliveryStatus ENUM('pending', 'received', 'rejected') DEFAULT 'pending',
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrders(PurchaseOrderID)
);

--납품 완료된 제품들 정보
CREATE TABLE DeliveryItems (
    DeliveryItemID INT PRIMARY KEY AUTO_INCREMENT,
    DeliveryID INT,
    StockItemID INT,
    QuantityReceived INT,
    FOREIGN KEY (DeliveryID) REFERENCES Deliveries(DeliveryID),
    FOREIGN KEY (StockItemID) REFERENCES StockItems(StockItemID)
);

--재고 조정 정보
CREATE TABLE InventoryAdjustments (
    AdjustmentID INT PRIMARY KEY AUTO_INCREMENT, --조정 아이디
    VendorID INT, --업체 아이디
    StockItemID INT, --어떤 제품
    AdjustmentDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    QuantityAdjusted INT, --수정된 재고 량
    Reason TEXT, --이유
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID),
    FOREIGN KEY (StockItemID) REFERENCES StockItems(StockItemID)
);

--AI 분석 관리 테이블 시작

CREATE TABLE AnalysisResults ( --AI 분석 결과 저장
    AnalysisResultID INT PRIMARY KEY AUTO_INCREMENT,
    VendorID INT, -- 업체 아이디
    AnalysisType VARCHAR(255), -- 분석 유형을 식별하는 열
    AnalysisDate DATETIME, -- 분석을 수행한 날짜 및 시간
    ResultData TEXT, -- 분석 결과 데이터를 저장하는 열
    AdditionalInfo TEXT, -- 업체에게 제공할 요약된 추천 정보를 저장하는 열
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);

CREATE TABLE StrategyAcceptance ( --AI의 전략 추천을 업체가 거절/수락했는지 여부
    AcceptanceID INT PRIMARY KEY AUTO_INCREMENT,
    StrategyID INT, -- 추천된 전략의 ID
    VendorID INT, -- 업체 ID
    AcceptanceStatus ENUM('accepted', 'rejected') DEFAULT NULL, -- 수락 또는 거절 상태
    AcceptanceDate DATETIME DEFAULT CURRENT_TIMESTAMP, -- 수락 또는 거절한 날짜와 시간
    FOREIGN KEY (StrategyID) REFERENCES AnalysisResults(AnalysisResultID),
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);

