# Nhật ký nâng cấp Bản Lĩnh

## Bản nâng cấp từ mã Claude — 31/10/2026

- Giữ nguyên kho dữ liệu cục bộ `banlinh_app_v1` và các tính năng check-in, hộ thể, nhật ký, kế hoạch, SOS, PIN, thống kê, trò chơi tập trung và sao lưu.
- Đổi cảnh người que SVG thành ảnh nhân vật tu tiên bán hiện thực nền trong suốt; thay trang phục tại các mốc 0, 1, 3, 7, 14, 30 và 60 ngày.
- Tăng sáng, giảm bão hòa màu để y phục nhạt/trắng dần, tăng hào quang và mật độ hạt linh khí mỗi ngày.
- Cảnh nền đổi theo cảnh giới: thôn quê, rừng trúc, tiên môn và thiên cung.
- Thêm màn đột phá ở các mốc 3, 7, 14, 30, 60 và 90 ngày.
- Thêm tài khoản Supabase, hồ sơ công khai, avatar, tỉnh/thành và bảng xếp hạng toàn máy chủ.
- XP online chỉ gửi khi một phiên tập trung mới hoàn thành; không đồng bộ nhật ký, check-in, kế hoạch, SOS, PIN hay dữ liệu riêng tư.
- Sửa lỗi tải trang Cộng đồng, xử lý nút GPS tương thích Safari, làm sạch dữ liệu nhập và loại bỏ check-in trùng.
- Cập nhật SQL giới hạn XP theo ngày Việt Nam; thêm kiểm tra biệt danh tối thiểu.
- Tương thích SQL MVP cũ theo hướng không xóa lịch sử: giữ XP/hồ sơ/dữ liệu ngày cũ, nhưng thu hồi quyền Data API cũ; cung cấp file SQL dọn dữ liệu riêng nếu người dùng chủ động muốn xóa.

## Những giới hạn còn lại

- Chưa thể kiểm thử đăng ký/đăng nhập, RLS và RPC với project Supabase của người dùng vì chưa có URL/key dự án.
- Bảo vệ PIN chỉ ở mức khóa giao diện; `localStorage` không được mã hóa.
- Nhận diện khu vực qua Nominatim chỉ nên dùng thử nghiệm quy mô nhỏ; cần proxy/cache hoặc nhà cung cấp khác nếu lượng dùng tăng.
- XP được giới hạn phía máy chủ nhưng chưa chứng minh được người dùng thật sự tập trung trong toàn bộ phiên.
