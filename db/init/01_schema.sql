CREATE TABLE tours (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  destination VARCHAR(100) NOT NULL,
  price NUMERIC(12,2) NOT NULL CHECK (price >= 0),
  duration_days INT NOT NULL,
  description TEXT
);
CREATE TABLE tour_itineraries (
  id SERIAL PRIMARY KEY,
  tour_id INT NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
  day_no INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  detail TEXT
);
CREATE TABLE tour_schedules (
  id SERIAL PRIMARY KEY,
  tour_id INT NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
  departure_date DATE NOT NULL,
  seats_total INT NOT NULL,
  seats_available INT NOT NULL CHECK (seats_available >= 0)
);
CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(20)
);
CREATE TABLE bookings (
  id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customers(id),
  schedule_id INT NOT NULL REFERENCES tour_schedules(id),
  num_people INT NOT NULL CHECK (num_people > 0),
  total_price NUMERIC(12,2) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO tours (name, destination, price, duration_days, description) VALUES
('Hạ Long - Kỳ quan thiên nhiên', 'Quảng Ninh', 3200000, 3, 'Du thuyền trên vịnh, chèo kayak, tham quan hang Sửng Sốt.'),
('Sa Pa - Săn mây Fansipan', 'Lào Cai', 2800000, 3, 'Chinh phục Fansipan, thăm bản Cát Cát, thưởng thức ẩm thực vùng cao.'),
('Đà Nẵng - Hội An - Bà Nà', 'Đà Nẵng', 4500000, 4, 'Cầu Vàng Bà Nà, phố cổ Hội An, biển Mỹ Khê.'),
('Phú Quốc - Đảo ngọc', 'Kiên Giang', 5900000, 4, 'Lặn ngắm san hô, cáp treo Hòn Thơm, chợ đêm Dinh Cậu.');

INSERT INTO tour_itineraries (tour_id, day_no, title, detail) VALUES
(1,1,'Hà Nội - Hạ Long','Xe đón khách, lên du thuyền, ăn trưa hải sản, ngắm hoàng hôn.'),
(1,2,'Khám phá vịnh','Chèo kayak, thăm hang Sửng Sốt, học nấu ăn trên tàu.'),
(1,3,'Hạ Long - Hà Nội','Tai chi buổi sáng, trả phòng, về Hà Nội.'),
(2,1,'Hà Nội - Sa Pa','Di chuyển lên Sa Pa, thăm bản Cát Cát.'),
(2,2,'Fansipan','Cáp treo chinh phục đỉnh Fansipan.'),
(2,3,'Sa Pa - Hà Nội','Chợ Sa Pa, mua đặc sản, về Hà Nội.'),
(3,1,'Đà Nẵng','Đón sân bay, biển Mỹ Khê, cầu Rồng.'),
(3,2,'Bà Nà Hills','Cầu Vàng, làng Pháp, Fantasy Park.'),
(3,3,'Hội An','Phố cổ, thả đèn hoa đăng sông Hoài.'),
(3,4,'Tự do - Tiễn sân bay','Mua sắm đặc sản, ra sân bay.'),
(4,1,'Đến Phú Quốc','Nhận phòng, tắm biển Bãi Sao.'),
(4,2,'Lặn ngắm san hô','Ca nô tham quan 4 đảo phía Nam.'),
(4,3,'Hòn Thơm','Cáp treo vượt biển dài nhất thế giới.'),
(4,4,'Chợ đêm - Tiễn sân bay','Mua nước mắm, tiêu, ra sân bay.');

INSERT INTO tour_schedules (tour_id, departure_date, seats_total, seats_available) VALUES
(1, CURRENT_DATE + 14, 20, 20), (1, CURRENT_DATE + 30, 20, 20),
(2, CURRENT_DATE + 10, 15, 15), (2, CURRENT_DATE + 25, 15, 15),
(3, CURRENT_DATE + 21, 25, 25), (3, CURRENT_DATE + 45, 25, 25),
(4, CURRENT_DATE + 18, 20, 20), (4, CURRENT_DATE + 40, 20, 20);
