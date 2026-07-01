# 📐 KHUNG ĐẶC TẢ THIẾT KẾ GAME CASUAL TỔNG QUÁT (FLUTTER)

Tài liệu này định nghĩa khung kiến trúc tiêu chuẩn (Standard Architecture Framework) và quy trình phát triển cho các tựa game Casual/Arcade viết bằng **Flutter**. 

Mục tiêu của tài liệu này là chuẩn hóa cách tổ chức code, xử lý vật lý, âm thanh và giao diện. Ở các dự án game tiếp theo, người chơi chỉ cần đưa ra ý tưởng gameplay (ví dụ: *"làm game bắn máy bay"*, *"làm game xếp hình"*), lập trình viên hoặc AI sẽ đọc tài liệu này để tự động triển khai toàn bộ cấu trúc dự án mà không cần bàn bạc lại về kiến trúc.

---

## I. KIẾN TRÚC MÔ HÌNH: MVC + CHANGENOTIFIER

Mọi game casual trong Flutter sẽ được tổ chức theo mô hình **MVC** kết hợp cơ chế State Management gốc nhằm tối ưu hiệu năng và độ mượt 60FPS:

```
               ┌───────────────────────────────────────┐
               │         GameManager (Controller)      │
               │ - Vòng lặp game chính (Game Loop)     │
               │ - Đếm ngược thời gian, trạng thái chơi│
               └──────────────────┬────────────────────┘
                                  │ Cập nhật tọa độ & trạng thái
                                  ▼
               ┌───────────────────────────────────────┐
               │            Models (Dữ liệu)           │
               │ Ball, Paddle, Player, Bullet, Enemy...│
               └──────────────────┬────────────────────┘
                                  │ Vẽ lại Canvas
                                  ▼
               ┌───────────────────────────────────────┐
               │          Views & UI (Hiển thị)        │
               │ - CustomPainter (Vẽ game play chính) │
               │ - Flutter Widgets (Màn hình đè HUD)   │
               └───────────────────────────────────────┘
```

### 1. Models (Lớp Dữ Liệu)
- Là các lớp chứa thông số trạng thái vật lý của thực thể: Tọa độ (`position`), Vận tốc/Hướng (`velocity`), Kích thước (`width`, `height`, `radius`), Màu sắc, Trạng thái (sống/chết, hoạt động/ngừng).
- Không chứa logic vẽ (Paint) hoặc logic va chạm phức tạp, chỉ chứa các hàm cập nhật cơ bản (`update(double deltaTime)`).

### 2. GameManager (Lớp Điều Khiển - Controller)
- Kế thừa từ `ChangeNotifier` để phát đi thông báo cập nhật UI khi trạng thái game thay đổi.
- **Game Loop (Vòng lặp chính):** Sử dụng `Ticker` của Flutter để chạy hàm cập nhật game đều đặn mỗi frame (tương đương 60FPS hoặc cao hơn).
- **Quản lý trạng thái chơi (Game States):**
  - `menu`: Màn hình khởi động, cấu hình, chọn nhân vật.
  - `playing`: Trạng thái chơi thực tế.
  - `paused`: Tạm dừng game.
  - `gameOver`: Thua cuộc (hiển thị điểm số, nút chơi lại).
  - `levelComplete`: Vượt màn (hiển thị điểm thưởng, nút qua màn tiếp theo).
- **Lưu trữ dữ liệu:** Lưu trữ điểm cao (`highScore`), tiền vàng (`coins`), màn chơi mở khóa qua `SharedPreferences`.

### 3. Views & UI (Lớp Hiển Thị)
- **Gameplay Canvas:** Sử dụng `CustomPaint` và `CustomPainter` để vẽ các Models chuyển động nhanh (bóng, đạn, quái vật, hiệu ứng hạt bụi) nhằm đạt hiệu năng tối đa.
- **HUD Overlays:** Sử dụng Flutter Widgets thông thường xếp chồng lên Canvas bằng `Stack` để hiển thị các màn hình tĩnh (nút Pause, bảng chọn Skin, Menu chính). Tránh vẽ văn bản hoặc nút bấm phức tạp bằng Canvas vì sẽ làm giảm hiệu năng vẽ.

---

## II. QUY TẮC THIẾT KẾ GAMEPLAY & TRẢI NGHIỆM (JUICINESS)

Để game casual có trải nghiệm cao cấp (Premium feeling) và cuốn hút, mọi thiết kế phải tuân thủ 5 nguyên lý sau:

### 1. Vật lý & Giải quyết Va chạm Tuyệt đối (Collision Resolution)
- **Position Snapping (Bù tọa độ đẩy ra ngoài):** Khi xảy ra va chạm giữa hình tròn (bóng, đạn) và hình chữ nhật (tường, gạch, thanh chắn), **bắt buộc** phải gán lại tọa độ của thực thể chuyển động nằm chính xác ở rìa ngoài của thực thể tĩnh trước khi đổi hướng vận tốc. Điều này loại bỏ hoàn toàn lỗi kẹt va chạm lặp vô hạn (vết xước vật lý).
- **Directional Guard (Bảo vệ hướng):** Chỉ kích hoạt va chạm khi vectơ vận tốc của thực thể di chuyển hướng thẳng vào mặt va chạm của thực thể tĩnh. Nếu nó đang di chuyển ra xa, bỏ qua va chạm.

### 2. Game Juice (Độ đã mắt)
- **Hệ thống hạt bụi (Particle System):** Bất kỳ va chạm hoặc vụ nổ nào cũng phải sinh ra một lượng hạt bụi sáng tỏa ra xung quanh, nhạt dần và biến mất sau một khoảng thời gian ngắn (từ 0.2s - 0.5s).
- **Rung lắc màn hình (Screen Shake):** Khi người chơi bị mất mạng, trúng bom, hoặc có vụ nổ lớn, phải áp dụng độ lệch ngẫu nhiên (Offset) vào tọa độ vẽ Canvas với biên độ giảm dần theo thời gian.
- **Văn bản nổi (Floating Texts):** Cộng điểm, combo, hoặc nhặt được buff phải tạo ra văn bản bay nhẹ lên trên và mờ dần.

### 3. Tiền tệ & Hệ thống Cửa hàng (Cosmetics & Shop)
- Game phải có một loại tiền tệ chính (Coins/Gems) rơi ra trong màn chơi hoặc thưởng khi qua màn.
- Tiền tệ dùng để mua sắm skins trong Shop (thay đổi màu sắc, mô hình và đặc biệt là **hiệu ứng vệt hạt bụi phát sáng riêng** cho từng skin).

### 4. Thiết kế Màn chơi & Độ khó (Level Design)
- Thiết kế màn chơi chia theo **Tiers độ khó tăng dần**.
- **Chế độ Dev Mode (`isDevMode`):** Luôn có một biến cờ `isDevMode` tĩnh. Khi bật `true`, toàn bộ các level trong game sẽ tự động mở khóa để phục vụ kiểm thử nhanh. Khi tắt `false`, người chơi phải chơi tuần tự.

---

## III. QUẢN LÝ THƯ VIỆN ÂM THANH (AUDIO MANAGEMENT)

- **Nhạc nền (BGM):** Tạo danh sách nhạc ngẫu nhiên thay vì chỉ phát 1 bài lặp đi lặp lại.
- **Hiệu ứng âm thanh (SFX):**
  - Tránh tải các file âm thanh từ bên thứ ba trên internet để loại bỏ hoàn toàn lỗi mạng và lỗi giải mã trình duyệt (CORS).
  - Khuyến khích **tự tổng hợp âm thanh bằng toán học (Sound Synthesis)**: Tạo một script sinh dữ liệu sóng PCM (Square, Triangle, Sine hoặc Noise) và ghi ra file `.wav` để lưu trữ trực tiếp trong assets của dự án. 
  - Điều này đảm bảo game hoạt động mượt mà offline 100% trên cả Android, iOS và trình duyệt Web (HTML5/WebAudio).

---

## IV. QUY TRÌNH PHÁT TRIỂN CHUẨN (DEVELOPMENT WORKFLOW)

Khi nhận được ý tưởng gameplay mới, lập trình viên/AI sẽ đi qua 7 bước chuẩn hóa sau:

1. **Bước 1: Đặc tả Gameplay (Blueprint):** Chuyển ý tưởng của người chơi thành sơ đồ các thực thể di chuyển (Models) và hành vi va chạm.
2. **Bước 2: Viết Models:** Khởi tạo các file chứa dữ liệu thuộc tính của bóng, nhân vật, đạn, chướng ngại vật trong thư mục `lib/game/models/`.
3. **Bước 3: Viết Động cơ Vật lý (`physics.dart`):** Viết logic va chạm biên, va chạm giữa nhân vật và chướng ngại vật/quái vật, tích hợp Position Snapping.
4. **Bước 4: Viết Động cơ Vẽ (`game_painter.dart`):** Cấu hình CustomPainter để vẽ các Models lên màn hình theo phong cách nghệ thuật được thống nhất.
5. **Bước 5: Viết GameManager:** Tích hợp vòng lặp `Ticker`, xử lý sự kiện kéo thả từ người chơi, phân bổ logic sinh vật phẩm, lưu trữ dữ liệu qua `SharedPreferences`.
6. **Bước 6: Thiết kế Level (`level_manager.dart`):** Tạo danh sách màn chơi dựa trên ma trận lưới hoặc thuật toán sinh ngẫu nhiên.
7. **Bước 7: Thiết kế Overlays & Âm thanh:** Xây dựng màn hình Menu, Shop, Pause, GameOver bằng Flutter Widgets và cấu hình nhạc nền/âm thanh hiệu ứng.
