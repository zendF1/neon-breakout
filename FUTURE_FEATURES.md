# Kế hoạch phát triển Tính năng Tương lai (Future Features Roadmap)

Tài liệu này tổng hợp các ý tưởng đột phá đã được lên kế hoạch thiết kế cho các phiên bản tiếp theo của **Neon Breakout**.

---

## 1. Trận chiến Boss Đặc biệt (Epic Boss Fights)
Trận chiến Boss sẽ mang lại thử thách cực đại cho người chơi sau mỗi Tier hoặc mốc điểm nhất định.

### Chi tiết thiết kế:
- **Thời điểm xuất hiện:** Ở cuối mỗi Tier (Ví dụ: Level 10, Level 20) hoặc khi đạt điểm số chẵn trong Endless Mode (mỗi 1000 điểm).
- **Thành phần:** 
  - Boss là một thực thể Neon khổng lồ (`UfoBoss`) ngự trị phía trên đỉnh màn hình.
  - Có thanh máu (`HP Bar`) dài, hiển thị dạng dải sáng đỏ neon chạy dọc phía trên màn hình HUD.
  - Có các ụ súng phụ (`Sub-turrets`) bắn đạn tròn tỏa ra xung quanh.
- **Cơ chế chiến đấu:**
  - Boss được bao quanh bởi các lớp gạch bảo vệ đặc biệt (hoặc drone phụ). Người chơi cần đập vỡ lớp chắn này trước khi có thể chạm bóng vào Lõi năng lượng (`Boss Core`) để gây sát thương.
  - Boss sẽ có các đòn tấn công chủ động ép người chơi phải liên tục di chuyển để né tránh:
    - Bắn đạn laser gây stun.
    - Quét tia laser hồng ngoại ngang sân đấu.

---

## 2. Kỹ năng chủ động cho Paddle (Active Skill System)
Hệ thống năng lượng tích lũy cho phép người chơi kích hoạt kỹ năng đặc biệt trong tình huống khẩn cấp.

### Chi tiết thiết kế:
- **Tích lũy Năng lượng:** Mỗi khi bóng phá vỡ gạch hoặc nhặt xu, thanh năng lượng (Energy Bar) của Paddle sẽ tăng lên. Khi đầy 100%, người chơi có thể kích hoạt kỹ năng chủ động bằng cách nhấn nút trên màn hình.
- **Kỹ năng dự kiến:**
  1. **Khiên Năng lượng (Shield Bubble):**
     - Tạo một vòng tròn bảo vệ bao quanh Paddle trong 4 giây. Hấp thụ tất cả Hazards (Bom, Glitch) rơi xuống và chuyển hóa chúng thành **Coins (+5 Coins/quả)**.
  2. **Thời gian ngưng đọng (Time Dilation):**
     - Làm chậm tốc độ bay của bóng và tốc độ di chuyển của chướng ngại vật/quái vật xuống 80% trong 5 giây, cho phép người chơi dễ dàng phán đoán và phản xạ trong những tình huống nguy kịch.

---

## 3. Chế độ Chơi 2 Người Cục bộ (Local Multiplayer Mode)
Chế độ chơi trên cùng một thiết bị di động / máy tính bảng.

### Chi tiết thiết kế:
- **Chế độ Đồng đội (Co-op):**
  - Màn hình hiển thị 2 Paddle song song ở đáy hoặc 1 Paddle ở đáy màn hình và 1 Paddle ở đỉnh màn hình.
  - Hai người chơi cùng đỡ bóng để không bị lọt ra ngoài, phối hợp công phá các màn chơi siêu rộng.
- **Chế độ Đối đầu (Versus - Neon Pong):**
  - Giao diện gồm 2 người chơi ở 2 đầu màn hình (Top và Bottom).
  - Gạch năng lượng được bố trí ở khu vực trung tâm. Người chơi đập bóng phá gạch nhận điểm và tìm cách sút bóng vượt qua Paddle của đối thủ để ghi bàn thắng.

---

## 4. Nhiệm vụ Hàng ngày & Hệ thống Cấp độ (Quests & Leveling)
Hệ thống giữ chân người chơi lâu dài.

### Chi tiết thiết kế:
- **Hệ thống XP:** Nhận XP sau mỗi trận đấu dựa trên điểm số và combo đạt được. Lên cấp (Player Level) nhận phần thưởng Vàng lớn.
- **Daily Quests:**
  - *"Đạt combo x15 trong chế độ Endless"* -> Thưởng 100 Coins.
  - *"Bắn hạ 5 drone trong một màn chơi"* -> Thưởng 80 Coins.
  - *"Hoàn thành Level Campaign mà không mất mạng"* -> Thưởng 150 Coins.

---

## 5. Hiệu ứng Môi trường Nâng cao (Solar Flares)
- **Solar Flares (Bão Mặt trời):** Thi thoảng mặt trời neon ở hậu cảnh bùng nổ, tạo ra các luồng sóng nhiệt màu cam đẩy quả bóng bay nhanh hơn 30% và làm trượt các hàng gạch xuống nhanh hơn trong 5 giây.
