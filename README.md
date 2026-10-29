# Bản Lĩnh — Web app miễn phí

## Chạy thử trên máy tính
Mở `index.html` bằng trình duyệt. Dữ liệu lưu trong localStorage của trình duyệt đó.

## Đưa lên mạng miễn phí bằng GitHub Pages
1. Đăng nhập hoặc tạo tài khoản tại https://github.com (miễn phí).
2. Tạo repository mới, ví dụ `ban-linh-app`; chọn Public.
3. Tải lên 4 tệp ở thư mục này: `index.html`, `manifest.webmanifest`, `sw.js`, `icon-192.png`, `icon-512.png`.
4. Trong repository, vào Settings → Pages.
5. Ở phần Build and deployment, chọn Deploy from a branch; chọn branch `main`, folder `/ (root)`, rồi Save.
6. Chờ GitHub cung cấp URL dạng `https://TEN-TAI-KHOAN.github.io/ban-linh-app/`.

## Thêm vào màn hình chính iPhone
1. Mở URL GitHub Pages bằng Safari (không phải trình duyệt bên trong ứng dụng khác).
2. Nhấn nút Chia sẻ.
3. Chọn “Thêm vào MH chính” / “Add to Home Screen”.
4. Nhấn Thêm. Mở ứng dụng từ biểu tượng mới.

## Dữ liệu và giới hạn
- Bản này lưu dữ liệu cục bộ trên thiết bị/trình duyệt; không có tài khoản hay đồng bộ giữa thiết bị.
- Xuất bản sao JSON định kỳ trong mục Cài đặt để tránh mất nhật ký.
- Xóa dữ liệu website hoặc trình duyệt có thể làm mất dữ liệu.
- Service worker giúp lưu bộ khung trang để dùng lại khi ngoại tuyến sau lần truy cập thành công đầu tiên; lần cài đầu cần mạng.
- Giờ nhắc cuối ngày hiện được lưu như một lời nhắc trong ứng dụng. Web tĩnh không thể bảo đảm gửi thông báo đúng giờ khi Safari đã đóng; cần cơ chế thông báo/push riêng nếu muốn làm tính năng đó đáng tin cậy.
- Không cần App Store, tên miền trả phí, API AI trả phí hoặc máy chủ riêng cho bản cơ bản.

## Tệp
- `index.html`: giao diện và logic ứng dụng.
- `manifest.webmanifest`: cấu hình cài đặt web app.
- `sw.js`: cache tài nguyên cơ bản.
- `icon-192.png`, `icon-512.png`: biểu tượng ứng dụng.
