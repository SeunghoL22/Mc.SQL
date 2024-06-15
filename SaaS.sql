--본사 정보(EX 맥도날드, 버거킹)
CREATE TABLE Corporations (
    CorporationID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Address VARCHAR(255),
    ContactNumber VARCHAR(255),
    Email VARCHAR(255) UNIQUE
);

-- 지점 정보 테이블
CREATE TABLE Branches (
    BranchID INT PRIMARY KEY AUTO_INCREMENT,
    CorporationID INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Address VARCHAR(255),
    ContactNumber VARCHAR(255),
    Email VARCHAR(255) UNIQUE,
    Latitude DECIMAL(10, 8), -- 위도 정보
    Longitude DECIMAL(11, 8), -- 경도 정보
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID)
);



--업체 정보 테이블(납품 업체 등)
CREATE TABLE Vendors (
    VendorID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    ContactNumber VARCHAR(255),
    Email VARCHAR(255) UNIQUE,
    Address VARCHAR(255)
);

-- User 정보 테이블
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    CorporationID INT NOT NULL, -- 모든 계정 유형이 속한 본사
    BranchID INT, -- 지점에 관련된 사용자의 경우 선택 사항
    Name VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    AccountType ENUM('HeadOffice', 'Branch', 'Admin', 'Consumer') NOT NULL, -- 계정 유형
    MembershipLevel ENUM('Bronze', 'Silver', 'Gold', 'Platinum') NOT NULL DEFAULT 'Bronze', -- 멤버십 등급
    LastVisitDate DATE, -- 최근 방문일
    TotalVisits INT DEFAULT 0, -- 총 방문 횟수
    LastPurchaseDate DATE, -- 최근 구매일
    TotalPurchases INT DEFAULT 0, -- 총 구매 횟수
    TotalPurchaseAmount DECIMAL(10, 2) DEFAULT 0.00, -- 총 구매 금액
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);

CREATE TABLE Admins (
    AdminID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL, -- Users 테이블과 연결
    AccountStatus ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active', -- 계정 상태
    LastPasswordChangeDate DATE, -- 마지막 비밀번호 변경일
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE AdminModificationLogs (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    AdminID INT NOT NULL, -- Admins 테이블과 연결
    ModificationDateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 수정 일시
    ModificationType VARCHAR(255) NOT NULL, -- 수정 유형 (예: "Password Change", "Status Update")
    ModificationDetails TEXT, -- 수정 상세 내용
    FOREIGN KEY (AdminID) REFERENCES Admins(AdminID)
);


CREATE TABLE FeatureToggle ( -- 본사 기능 ON/OFF 여부
    ToggleID INT PRIMARY KEY AUTO_INCREMENT,
    CorporationID INT, -- 본사 ID
    FeatureName VARCHAR(255), -- 기능 이름
    IsEnabled BOOLEAN DEFAULT FALSE, -- 기능 활성화 여부
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 마지막으로 업데이트된 날짜와 시간
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID)
);



-- Orders 테이블 생성
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    BranchID INT, -- 지점 아이디
    UserID INT,
    SafePhoneNumber VARCHAR(20), -- "안심번호"
    OrderDate DATETIME,
    DeliveryAddressID INT,
    PaymentInfoID INT,
    DeliveryPersonID INT,
    NonContactDelivery BOOLEAN,
    CouponID INT DEFAULT NULL,
    PaymentStatus ENUM('pending', 'completed', 'canceled') DEFAULT 'pending',
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID), 
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
    BranchID INT, -- 지점 아이디
    MenuItemID INT,
    Quantity INT,
    ItemDiscount DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

CREATE TABLE CanceledOrders (
    CanceledOrderID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    UserID INT,
    CancellationReason TEXT, -- 취소 이유
    CanceledAt DATETIME DEFAULT CURRENT_TIMESTAMP, -- 취소 시간
    BranchID INT, -- 지점 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE Refunds (
    RefundID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    RefundDate DATETIME,
    RefundAmount DECIMAL(10,2),
    RefundReason TEXT,
    BranchID INT, -- 지점 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

CREATE TABLE Reservations (
    ReservationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    ReservationDate DATETIME, -- 예약 날짜와 시간
    Status ENUM('pending', 'confirmed', 'canceled') DEFAULT 'pending', -- 예약 상태
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP, -- 예약 생성 날짜와 시간
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 예약 업데이트 날짜와 시간
    BranchID INT, -- 지점 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE ReservationItems (
    ReservationItemID INT PRIMARY KEY AUTO_INCREMENT,
    ReservationID INT,
    MenuItemID INT, -- 메뉴
    Quantity INT NOT NULL DEFAULT 1, -- 수량
    BranchID INT, -- 지점 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

CREATE TABLE CanceledReservations (
    CanceledReservationID INT PRIMARY KEY AUTO_INCREMENT,
    ReservationID INT,
    UserID INT,
    CancellationReason TEXT, -- 취소 이유
    CanceledAt DATETIME DEFAULT CURRENT_TIMESTAMP, -- 취소된 날짜와 시간
    BranchID INT, -- 지점 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- MenuItems 테이블 생성
CREATE TABLE MenuItems (
    MenuItemID INT PRIMARY KEY AUTO_INCREMENT,
    CorporationID INT, -- 기업 아이디
    Name VARCHAR(255),
    Description TEXT, -- 메뉴 상세 설명
    ImageURL VARCHAR(255), -- 메뉴 이미지 URL
    Category VARCHAR(255), -- 메뉴 카테고리 (예: 샐러드, 음료, 디저트 등)
    Price DECIMAL(10,2),
    StockLevel INT DEFAULT 0, -- 재고 수준
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID) -- Branches에서 Corporations로 변경
);

-- Coupons 테이블 생성
CREATE TABLE Coupons (
    CouponID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Code VARCHAR(255),
    DiscountAmount DECIMAL(10,2), -- 할인 금액
    CorporationID INT, -- 기업 아이디
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID), -- Branches에서 Corporations로 변경
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


-- DeliveryAddresses 테이블 생성
CREATE TABLE DeliveryAddresses (
    DeliveryAddressID INT PRIMARY KEY AUTO_INCREMENT,
    BranchID INT,
    UserID INT,
    Address VARCHAR(255),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- PaymentInformation 테이블 생성
CREATE TABLE PaymentInformation (
    PaymentInfoID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    BranchID INT, -- 지점 아이디
    CardNumber VARCHAR(16),
    ExpiryDate DATE,
    CVV INT,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


-- DeliveryPersons 테이블 생성
CREATE TABLE DeliveryPersons (
    DeliveryPersonID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255),
    ContactNumber VARCHAR(15),
    BranchID INT, -- 지점 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID) -- Vendors를 Branches로 가정합니다.
);

--배달원 실시간 위치 저장
CREATE TABLE DeliveryPersonLocations ( 
    LocationID INT AUTO_INCREMENT PRIMARY KEY,
    DeliveryPersonID INT NOT NULL,
    Latitude DECIMAL(10, 8) NOT NULL,
    Longitude DECIMAL(11, 8) NOT NULL,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (DeliveryPersonID) REFERENCES DeliveryPersons(DeliveryPersonID)
);

CREATE TABLE DeliveryStatusMonitoring ( --배달 상태 모니터링
    MonitoringID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    DeliveryStatus ENUM('pending', 'out_for_delivery', 'delivered', 'failed') DEFAULT 'pending',
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    BranchID INT, -- 지점 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- IngredientChanges 테이블 생성
CREATE TABLE IngredientChanges (
    IngredientChangeID INT PRIMARY KEY AUTO_INCREMENT,
    OrderDetailID INT,
    IngredientID INT,
    ChangeType VARCHAR(255),
    BranchID INT, -- 지점 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (OrderDetailID) REFERENCES OrderDetails(OrderDetailID),
    FOREIGN KEY (IngredientID) REFERENCES Ingredients(IngredientID)
);

-- Ingredients 테이블 생성
CREATE TABLE Ingredients (
    IngredientID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255),
    StockLevel INT DEFAULT 0, -- 재고 수준을 나타냅니다. 0일 경우 품절.
    CorporationID INT, -- 회사 아이디
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID) -- Vendors를 Corporations로 가정합니다.
);

-- Favorites 테이블 생성 (메뉴 즐겨찾기)
CREATE TABLE Favorites (
    FavoriteID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    CorporationID INT,
    MenuItemID INT,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

-- Cart 테이블 생성
CREATE TABLE Cart (
    CartID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    BranchID INT, -- 지점 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- CartItems 테이블 생성
CREATE TABLE CartItems (
    CartItemID INT PRIMARY KEY AUTO_INCREMENT,
    CartID INT,
    MenuItemID INT,
    Quantity INT,
    BranchID INT, -- 지점 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CartID) REFERENCES Cart(CartID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

-- OrderRatings 테이블 생성 (별점 시스템에 코멘트 추가)
CREATE TABLE OrderRatings (
    OrderRatingID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    DeliveryPersonID INT, -- 배달원 아이디 추가
    Rating INT CHECK (Rating >= 1 AND Rating <= 5), -- 1에서 5 사이의 정수 값
    DeliveryPersonRating INT CHECK (DeliveryPersonRating >= 1 AND DeliveryPersonRating <= 5), -- 배달원에 대한 별점
    Comment TEXT, -- 사용자 코멘트
    RatingDate DATETIME DEFAULT CURRENT_TIMESTAMP, -- 평가가 기록된 날짜와 시간
    BranchID INT, -- 지점 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (DeliveryPersonID) REFERENCES DeliveryPersons(DeliveryPersonID)
);




--고객센터 테이블 생성
CREATE TABLE CustomerSupportTickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    subject VARCHAR(255) NOT NULL, --문의 제목
    description TEXT NOT NULL, --문의 내용
    status VARCHAR(50) NOT NULL DEFAULT 'open', --문의 상태
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, --문의 작성시간
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, --문의 수정시간
    BranchID INT, -- 지점 아이디
    CorporationID INT, -- 회사 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

--실시간 채팅상담 테이블
CREATE TABLE LiveChatSessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL, --고객 아이디
    agent_id INT NOT NULL, --상담원 아이디
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, --시작시간
    end_time TIMESTAMP NULL, --종료시간
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    BranchID INT, -- 지점 아이디
    CorporationID INT, -- 회사 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID),
    FOREIGN KEY (user_id) REFERENCES Users(UserID),
    FOREIGN KEY (agent_id) REFERENCES Users(UserID) 
);

CREATE TABLE LiveChatMessages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL, --채팅 세션 아이디
    sender_id INT NOT NULL, --보내는사람 id
    message TEXT NOT NULL, --메세지 내용
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    BranchID INT, -- 지점 아이디
    CorporationID INT, -- 회사 아이디
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID),
    FOREIGN KEY (session_id) REFERENCES LiveChatSessions(id),
    FOREIGN KEY (sender_id) REFERENCES Users(UserID)
);


-- 챗봇 대화 테이블
CREATE TABLE ChatbotConversations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    session_id VARCHAR(255) NOT NULL,
    bot_type ENUM('customer', 'branch_manager', 'headquarters') NOT NULL, -- '본사 관리자용' 챗봇 유형 추가
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CorporationID INT NOT NULL, -- 'CorporationID'로 변경
    BranchID INT,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- 챗봇 메시지 테이블
CREATE TABLE ChatbotMessages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT NOT NULL,
    sender VARCHAR(50) NOT NULL,
    sender_type ENUM('customer', 'admin', 'bot', 'branch_manager', 'headquarters') NOT NULL, -- 발신자 유형에 추가 옵션 포함
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CorporationID INT, -- 'CorporationID'로 변경
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID),
    FOREIGN KEY (conversation_id) REFERENCES ChatbotConversations(id)
);


--재고관리 테이블 시작--

--납품업체 정보
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    VendorID INT, --업체 아이디
    Name VARCHAR(255) NOT NULL,
    ContactNumber VARCHAR(255),
    Email VARCHAR(255) UNIQUE,
    Address VARCHAR(255),
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);

--재고 항목 정보(현재 해당 아이템의 재고 상황)
CREATE TABLE StockItems (
    StockItemID INT PRIMARY KEY AUTO_INCREMENT,
    BranchID INT,
    Name VARCHAR(255) NOT NULL,
    Description TEXT,
    Category VARCHAR(255),
    CurrentStock INT DEFAULT 0,
    MinimumStockLevel INT DEFAULT 0,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
);

--발주 요청 정보 (발주한 내역)
CREATE TABLE PurchaseOrders (
    PurchaseOrderID INT PRIMARY KEY AUTO_INCREMENT,
    BranchID INT, --지점 아이디
    SupplierID INT, --공급업체 아이디
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('pending', 'confirmed', 'delivered', 'canceled') DEFAULT 'pending',
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);


--발주 요청한 제품 (무슨 아이템을 발주했는지)
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
    BranchID INT, -- VendorID를 BranchID로 변경
    PurchaseOrderID INT,
    DeliveryDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    DeliveryStatus ENUM('pending', 'received', 'rejected') DEFAULT 'pending',
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrders(PurchaseOrderID)
);


--개별 상품의 납품 상태 저장
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
    BranchID INT, --지점 아이디
    StockItemID INT, --어떤 제품
    AdjustmentDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    QuantityAdjusted INT, --수정된 재고 량
    Reason TEXT, --이유
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (StockItemID) REFERENCES StockItems(StockItemID)
);

--AI 분석 관리 테이블 시작

-- AI 분석 결과 테이블
CREATE TABLE AnalysisResults (
    AnalysisResultID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT, -- 사용자 ID
    CorporationID INT, -- 본사 ID
    BranchID INT, -- 지점 ID, 본사 전체에 대한 분석인 경우 NULL
    AnalysisType VARCHAR(255) NOT NULL, -- 분석 유형
    AnalysisDate DATETIME NOT NULL, -- 분석 날짜 및 시간
    ResultData TEXT NOT NULL, -- 분석 결과 데이터
    AdditionalInfo TEXT, -- 추가 정보 또는 추천 사항
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);


-- 전략 수용 여부 테이블
CREATE TABLE StrategyAcceptances (
    AcceptanceID INT PRIMARY KEY AUTO_INCREMENT,
    AnalysisResultID INT NOT NULL, -- 분석 결과 ID
    Accepted BOOLEAN NOT NULL, -- 수용 여부
    AcceptanceDate DATETIME NOT NULL, -- 수용 또는 거부 날짜
    Comments TEXT, -- 의견 또는 설명
    FOREIGN KEY (AnalysisResultID) REFERENCES AnalysisResults(AnalysisResultID)
);

--인기메뉴
CREATE TABLE CompanyPopularMenuItems (
    PopularMenuItemID INT PRIMARY KEY AUTO_INCREMENT,
    MenuItemID INT, -- 메뉴 아이템 ID
    CorporationID INT, -- 기업 ID
    SalesCount INT DEFAULT 0, -- 판매량
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID),
    FOREIGN KEY (CorporationID) REFERENCES Corporations(CorporationID)
);