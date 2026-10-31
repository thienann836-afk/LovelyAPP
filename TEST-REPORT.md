# Kiểm tra bản nâng cấp

## Đã kiểm tra trong môi trường dựng mã
- `node --check` trên JavaScript nhúng: đạt.
- Phân tích HTML: đạt; không có ID trùng; 8 trang app và 6 nút điều hướng đều có đích tồn tại.
- Kiểm tra đường dẫn tài nguyên cục bộ: đủ 7 sprite nhân vật, 4 cảnh WebP, manifest, service worker, config và icon.
- Smoke test Node với DOM stub: khởi tạo app không lỗi; test cảnh giới/nhân vật từ ngày 0 đến 30; test hiệu ứng tăng theo ngày; test mở trang Cộng đồng: đạt.

## Chưa thể xác nhận tại đây
- Không kiểm thử giao diện thực tế bằng Safari/iPhone; trình duyệt headless trong môi trường dựng bị hệ thống chặn.
- Không thể xác nhận đăng ký email, gửi email xác minh, đăng nhập, RLS và bảng xếp hạng tới một project Supabase thật khi chưa có URL/key project của bạn.
- Vì vậy, đây là bản nâng cấp mã nguồn MVP, chưa phải bản production đã nghiệm thu.
