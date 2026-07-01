# 🎮 Neon Breakout - Retro Cyberpunk Brick Breaker

**Neon Breakout** là một tựa game casual Brick Breaker (bắn bóng phá gạch) được xây dựng bằng **Flutter**. Game mang đậm phong cách thiết kế Cyberpunk/Neon rực rỡ, kết hợp cùng hiệu ứng hạt phát sáng sinh động, nhạc nền EDM lôi cuốn và bộ âm thanh chiptune 8-bit tự động tổng hợp độc đáo.

---

## 🕹️ Tính Năng Game Play (Gameplay Mechanics)

### 1. Cách Điều Khiển (Controls)
- **Kéo/Vuốt:** Chạm vào màn hình và kéo sang trái/phải để điều khiển thanh chắn (Paddle) đón bóng.
- **Phản xạ góc nảy:** Bóng sẽ đổi hướng nảy dựa vào điểm tiếp xúc trên thanh trượt (chạm rìa ngoài nảy chéo hơn, chạm trung tâm nảy thẳng đứng lên).

### 2. Hệ Thống 20 Bản Đồ & Độ Khó (Tiers)
Game có 20 màn chơi thiết kế thủ công chia làm 4 Tiers độ khó:
- **Tier 1 (Lv 1 - 5): Basics:** Màn chơi cơ bản không khiên chắn hay chướng ngại vật để người chơi quen tay.
- **Tier 2 (Lv 6 - 10): Shields:** Giới thiệu các bức tường khiên chắn **Unbreakable (Không thể phá hủy)**. Người chơi cần bắn dội góc lách qua các khe hở rộng tối thiểu 2 ô gạch.
- **Tier 3 (Lv 11 - 15): Hazards:** Bắt đầu xuất hiện các cạm bẫy rơi xuống khi phá gạch.
- **Tier 4 (Lv 16 - 20): Chaos:** Các màn chơi kết hợp khiên chắn phức tạp, bom rơi dày đặc và tốc độ bóng cực nhanh.

### 3. Các Vật Phẩm Rơi (Drops & Collectibles)
Khi phá vỡ gạch thường, gạch nổ (Explosive) hoặc gạch bọc thép (Armored), các vật phẩm có thể rơi xuống:
- **👛 Coin (Tiền vàng):** Dùng để mua sắm vật phẩm trang trí trong shop.
- **⚡ Power-ups (Hiệu ứng có lợi):**
  - `Multi-ball` (Xanh lá): Nhân 3 số lượng bóng trên màn hình.
  - `Wide Paddle` (Xanh dương): Kéo dài thanh trượt trong 8 giây.
  - `Slow Motion` (Xanh lục bảo): Làm chậm tốc độ bóng trong 8 giây giúp đón bóng dễ hơn.
- **⚠️ Hazards (Chướng ngại vật - Chỉ xuất hiện từ Level 11+):**
  - **Bom nổ (Spiked Bomb - Quả cầu gai đỏ):** Trúng thanh trượt sẽ **trừ 1 mạng**, gây rung lắc màn hình và ngắt điểm combo.
  - **Cầu lệch góc (Glitch Cross - Chữ X tím):** Trúng thanh trượt sẽ kích hoạt **hiệu ứng bẻ cong đường bóng trong 7 giây** (mọi va chạm sẽ làm lệch góc phản xạ ngẫu nhiên ±15 độ).

### 4. Cosmetic Shop (Cửa hàng thời trang)
Tích lũy coin nhận được từ quá trình chơi và thắng màn để mở khóa:
- **Skins Bóng:** Plasma Cyan, Fiery Orange (mỗi loại có hiệu ứng vệt đuôi hạt riêng).
- **Skins Thanh trượt:** Neo Green, Gold Sparkle (tỏa sao lấp lánh khi di chuyển).

---

## 🛠️ Hướng Dẫn Cài Đặt Môi Trường (Setup Environment)

Để chạy dự án này trên máy tính của bạn, hãy đảm bảo bạn đã cài đặt Flutter SDK.

### Bước 1: Clone dự án hoặc truy cập thư mục dự án
```bash
cd neon-breakout
```

### Bước 2: Cài đặt Flutter SDK
Nếu chưa cài đặt Flutter, hãy làm theo hướng dẫn tại [Trang chủ Flutter](https://docs.flutter.dev/get-started/install).

### Bước 3: Tải các gói phụ thuộc (Dependencies)
Khởi tạo và tải các thư viện cần thiết (như `audioplayers`, `shared_preferences`...):
```bash
flutter pub get
```

---

## 🚀 Chạy Ứng Dụng (Run Game)

Chạy game trên thiết bị giả lập, thiết bị thật hoặc trình duyệt Web:

```bash
# Chạy ở chế độ Debug thông thường (tự chọn thiết bị khả dụng)
flutter run

# Hoặc ép chạy trên trình duyệt Chrome (Web)
flutter run -d chrome
```

---

## 🧪 Kiểm Thử & Phân Tích Code (Test & Analyze)

Game được viết sạch sẽ, tuân thủ nghiêm ngặt chuẩn lint của Flutter.

```bash
# Phân tích tĩnh cú pháp code (đảm bảo sạch lỗi cảnh báo)
flutter analyze

# Chạy toàn bộ các ca Unit Test và Widget Test
flutter test
```

---

## 📦 Biên Dịch & Triển Khai (Build & Deploy)

### 1. Build phiên bản Web (Khuyên Dùng cho Game Casual)
Biên dịch dự án thành mã nguồn HTML/JS/WASM tối ưu hóa để đưa lên hosting (GitHub Pages, Netlify, Vercel...):
```bash
flutter build web --release
```
Thư mục đầu ra sẽ nằm tại `build/web/`. Chỉ cần upload toàn bộ thư mục này lên server là game có thể chạy online.

### 2. Build bản cài đặt Android (APK)
```bash
flutter build apk --release
```
Tệp tin APK cài đặt sẽ nằm ở `build/app/outputs/flutter-apk/app-release.apk`.

### 3. Build bản cài đặt iOS
```bash
flutter build ios --release
```

---

## ⚙️ Cấu Hình Chế Độ Nhà Phát Triển (Dev Mode)

Trong file [game_manager.dart](file:///Users/inspius/Desktop/Porojet/github.com/neon-breakout/lib/game/game_manager.dart), bạn có thể cấu hình thuộc tính:

```dart
static const bool isDevMode = true;
```

- **`isDevMode = true` (Mặc định khi code):** Tất cả 20 màn chơi trong Menu Map đều được mở khóa ngay lập tức để bạn dễ dàng test và duyệt màn.
- **`isDevMode = false` (Khi xuất bản game):** Người chơi sẽ phải vượt qua từng màn để mở khóa màn tiếp theo. Tiến trình được lưu tự động trên thiết bị.
