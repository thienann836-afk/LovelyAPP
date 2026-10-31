# BẢN LĨNH — BẢN NÂNG CẤP TỪ MÃ CLAUDE

## Những gì đã được nâng cấp
- Giữ lại các tính năng cũ của Claude: chuỗi ngày, hộ thể, cảnh giới, lịch 35 ngày, nhật ký, kế hoạch, ghi nhận ngày gián đoạn, SOS, PIN, trò chơi tập trung, sao lưu/khôi phục.
- Giữ nguyên khóa dữ liệu cục bộ `banlinh_app_v1` để khi triển khai trên đúng URL/nguồn gốc trình duyệt cũ, dữ liệu đang có tiếp tục được đọc.
- Thay cảnh SVG người que bằng 7 sprite nhân vật tu tiên bán hiện thực; trang phục thay theo các mốc ngày 0, 1, 3, 7, 14, 30, 60. Giữa các mốc, độ sáng, sắc trắng của y phục, hào quang, vòng linh khí và số hạt sáng tiếp tục tăng từng ngày; ngày 90 có thể đạt hiệu ứng tối đa.
- Bối cảnh thay đổi theo cảnh giới: thôn quê, trúc cốc, tiên môn giữa núi và thiên cung.
- Hoạt cảnh đột phá ở mốc cảnh giới hiện tại (3, 7, 14, 30, 60, 90 ngày).
- Thêm trang Cộng đồng: đăng ký/đăng nhập email, hồ sơ công khai, avatar, khu vực, bảng xếp hạng toàn máy chủ.
- XP chỉ được gửi lên khi một phiên tập trung vừa hoàn thành. Không gửi lịch sử số phút cũ, nội dung nhật ký, check-in, kế hoạch, SOS hay PIN.
- Kiểm tra và làm sạch dữ liệu JSON nhập vào; loại bỏ check-in trùng và các giá trị không hợp lệ.

## Quan trọng về dữ liệu hiện tại
Ứng dụng dùng cùng khóa localStorage `banlinh_app_v1`. Nếu bạn cập nhật `index.html` và assets trên đúng GitHub Pages URL đang dùng, trên cùng thiết bị/trình duyệt, dữ liệu cục bộ cũ sẽ được giữ. Không chuyển URL/domain trước khi sao lưu.

**Trước khi cập nhật:** vào Cài đặt → Sao lưu → Xuất bản sao (.json). Không xóa `localStorage`, không bấm Xóa toàn bộ dữ liệu.

## Cài đặt Supabase
1. Tạo project Supabase tại https://supabase.com/.
2. Mở **SQL Editor → New query**, dán toàn bộ `supabase-schema.sql`, rồi Run. Script có xử lý tương thích nếu bạn đã chạy gói SQL MVP trước đó: giữ XP, hồ sơ, bảng thống kê ngày và cột focus_blocks cũ; gỡ RPC cũ và thu hồi quyền Data API đối với dữ liệu cũ không còn sử dụng. Dữ liệu lịch sử không bị xóa tự động.
3. Mở **Connect** trong Dashboard hoặc **Settings → API Keys**, sao chép **Project URL** và **Publishable key** (thường bắt đầu bằng `sb_publishable_`). Dự án cũ có thể chỉ có key `anon` — key này vẫn dùng được, nhưng nên ưu tiên publishable key mới.
4. Mở `bl-config.js`, thay:
   - `https://YOUR-PROJECT.supabase.co` bằng Project URL.
   - `YOUR_SUPABASE_PUBLISHABLE_KEY` bằng publishable key (hoặc legacy anon key).
5. Tuyệt đối không dùng `service_role` hoặc `secret` key trong file này. Đây là mã chạy công khai trên trình duyệt.
6. Trong **API Settings → Exposed schemas**, giữ schema `private` ở trạng thái không được expose (chỉ `public` cần dùng cho API của ứng dụng). Sau đó trong **Authentication → URL Configuration**, đặt Site URL và Redirect URLs thành URL GitHub Pages chính xác của ứng dụng, ví dụ `https://TEN-GITHUB.github.io/TEN-REPO/`.
7. Trong **Authentication → Providers → Email**, bật email/password. Bật email confirmation nếu muốn xác minh tài khoản; khi đăng ký, ứng dụng sẽ hướng dẫn kiểm tra email.
8. Đưa toàn bộ nội dung trong thư mục này lên repo GitHub Pages, giữ nguyên đường dẫn/thư mục.
9. Mở trang → Cộng đồng → tạo tài khoản → xác nhận email (nếu bật) → đăng nhập → chọn biệt danh/avatar/khu vực → Lưu hồ sơ.

## Đưa lên GitHub Pages
- Giải nén ZIP.
- Tải toàn bộ file/thư mục bên trong lên repo hiện tại, không chỉ tải riêng `index.html`.
- Giữ nguyên thư mục `assets/`, `manifest.webmanifest`, `sw.js`, `icon-192.png`, `icon-512.png`, `bl-config.js`.
- Commit/push và mở lại URL app.
- Service worker có cache phiên bản `ban-linh-v2-2026-10b`. Nếu iPhone vẫn hiển thị bản cũ, đóng hẳn Safari, mở lại; hoặc trong Safari xóa dữ liệu website sau khi đã xuất sao lưu (việc này xóa local data nếu chưa có backup).

## Quyền riêng tư và giới hạn
- Nhật ký, check-in, kế hoạch, ghi nhận SOS, PIN vẫn ở localStorage của thiết bị. Chúng không được gửi lên Supabase. PIN chỉ khóa giao diện, không mã hóa dữ liệu localStorage.
- Supabase lưu email (Auth), nickname, avatar, tên tỉnh/thành, tổng XP, tổng phút/phiên tập trung và thời lượng/thời điểm các phiên tập trung để giới hạn XP. Bảng phiên chỉ cho chính chủ tài khoản đọc.
- Nút tự xác định khu vực yêu cầu quyền GPS. Tọa độ hiện thời chỉ được gửi đến Nominatim/OpenStreetMap sau khi người dùng bấm nút để lấy tên khu vực; chỉ tên khu vực được đưa vào hồ sơ. Có thể nhập thủ công thay thế. Nominatim công cộng giới hạn tối đa 1 request/giây cho toàn ứng dụng và yêu cầu ghi nguồn; phù hợp thử nghiệm quy mô nhỏ, không nên dùng cho cộng đồng lớn nếu chưa chuyển sang dịch vụ/proxy có cache.
- Bảng xếp hạng là toàn máy chủ, hiển thị hồ sơ công khai. Chưa có bộ lọc riêng theo tỉnh/thành.
- Chống gian lận ở mức cơ bản: mỗi tài khoản tối đa 6 phiên/ngày, giới hạn XP 50/ngày theo ngày Việt Nam, thời lượng chỉ nhận 2/5/10 phút, mã phiên không được lặp, và có khoảng cách tối thiểu giữa các phiên. Máy chủ không thể xác minh chắc chắn người dùng đã tập trung thật trong toàn bộ thời lượng. Đây không phải chống gian lận tuyệt đối.
- Cấu hình online chưa thể hoạt động cho tới khi bạn tạo project, chạy SQL và điền `bl-config.js`. Ứng dụng dùng `@supabase/supabase-js` v2 từ CDN jsDelivr; khi mở online cần truy cập được CDN này. Bộ mã chưa được kiểm thử với project Supabase thực tế của bạn. Nếu đã chạy SQL MVP cũ, script giữ lại XP, hồ sơ, bảng `activity_daily` và cột `focus_blocks`; đồng thời thu hồi quyền truy cập Data API vào dữ liệu cũ, bỏ RPC cũ nên không phát sinh bản ghi mới. `focus_blocks` không được quy đổi thành phút vì không phản ánh thời lượng thực. Có file `supabase-cleanup-legacy.sql` riêng để xóa vĩnh viễn hai phần dữ liệu cũ khi bạn chủ động muốn xóa; không chạy file đó nếu muốn giữ lịch sử. Khóa PIN chỉ khóa giao diện; dữ liệu localStorage không được mã hóa.
- Nếu muốn phát hành cho nhiều người dùng thật, cần bổ sung kiểm thử bảo mật, giới hạn tần suất, xác minh tài khoản, giám sát chi phí và kiểm tra tương thích chính sách Nominatim.

## Kiến trúc
- Frontend: HTML/CSS/JS thuần, GitHub Pages.
- Online: Supabase Auth + Postgres + RLS + RPC.
- Local data: localStorage `banlinh_app_v1`.
- Art: WebP assets được tạo riêng cho Bản Lĩnh (7 nhân vật, 4 cảnh).
