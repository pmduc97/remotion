## Setup commands

```bash
# Install dependencies (uses Bun)
bun install

# Build all packages
bunx turbo run make

# Run tests and linting
bunx turbo run lint test

# Clean build artifacts
bun run clean

# Build a specific package
bunx turbo run make --filter='<package-name>'
```

Use `bunx` (not `npx`) to run package binaries.

The current Remotion version can be found in `packages/core/src/version.ts`. The next version should increment the patch version by 1.

## Coding style

- Keep things in one function unless they are composable or reusable.
- Do not extract single-use helpers preemptively. Inline the logic at the call site unless the helper is reused, hides a genuinely complex boundary, or has a clear independent name that improves the caller.

## Internal API optionality

When adding or reviewing TypeScript parameters, React props, or type/interface members, make new internal inputs preferrably nullable (`T | null`), not optional (`?:`). Public exported APIs are exempt when requiring the input would be breaking.

## Key services

- **Remotion Studio** (dev testbed): `cd packages/example && bun run dev` — starts at `http://localhost:3000`. This is the main dev UI for previewing video compositions.
- **Player testbed**: `cd packages/player-example && bun run dev` — for testing `@remotion/player` changes.
- **Docs site**: `cd packages/docs && bun run start` — Docusaurus dev server.

## Rendering test videos

From `packages/example`:

- `bunx remotion compositions` — list available compositions.
- `bunx remotion render <comp-id> --output ../../out/video.mp4` — render a video.
- `bunx remotion still <comp-id> --output ../../out/still.png` — render a still image.

## Dự án Kể Bé Nghe (KeBeNghe) & Quản lý Git Private
Khi bắt đầu một session mới làm việc với Kể Bé Nghe, các agent (Claude, Gemini, OpenCode, v.v.) CẦN đọc file .agents/skills/kebenghe-readme/SKILL.md và chạy theo các hướng dẫn trong đó để nắm được bối cảnh, tiến độ roadmap và lịch đăng mới nhất.

### Đọc ảnh để review — LUÔN downscale trước, TUYỆT ĐỐI không Read PNG gốc
Ảnh smoke/review là PNG 1080×1920; mỗi lần Read tool nạp một part base64 ~4MB vào context (đo thật 2026-10-16: subagent đọc 30–56 ảnh/session làm context phình tới 20M+ token/request, cache gần như không tái dùng, compaction không theo kịp → đốt input khổng lồ). Vì vậy, với MỌI kênh (Kể Bé Nghe, Hát Bé Nghe, Cover Bài Hát, Shopee, **Review Phim**):

- **KHÔNG Read trực tiếp** `out/<slug>/smoke/*.png`, `out/<slug>/review/*.png`, `out/<slug>/thumbnail.png`. Tạo thumb rồi Read thumb:
  ```bash
  python scripts/kebenghe_make_thumbs.py out/<slug>/smoke --out out/<slug>/thumbs/smoke
  ```
  rồi Read `out/<slug>/thumbs/smoke/*.thumb.jpg` (~7–40KB/ảnh, đủ thấy bố cục + thẩm mỹ).
- **Kiểm pixel-level** (seam mép khung, viền tách nền/đốm ô cờ, khe hở vài chục px): KHÔNG Read cả khung full-res — crop + zoom ĐÚNG vùng nghi ngờ rồi Read ảnh crop nhỏ:
  ```bash
  python scripts/kebenghe_make_thumbs.py out/<slug>/review/<f>.png --crop X,Y,W,H --zoom 2 --out out/<slug>/thumbs/crops
  ```
  rồi Read `..._crop_x2.jpg`.
- **So nhận diện nhiều ảnh cùng nhân vật**: ghép thành MỘT lưới rồi Read 1 ảnh:
  ```bash
  python scripts/kebenghe_make_thumbs.py <a.png> <b.png> <c.png> --montage --out out/<slug>/thumbs/cmp
  ```
  rồi Read `out/<slug>/thumbs/cmp/montage.jpg`.
- **Contact sheet / montage của Review Phim** (`make_contact_sheet.py` → `montage.jpg`, `cand_*.jpg`): sinh ở cỡ gọn (`--cell 160`, `--cols 6`, cạnh dài ≤ ~1600px); nếu ảnh ra vẫn lớn thì downscale bằng `kebenghe_make_thumbs.py` rồi mới Read — 1 sheet 2.6MB ≈ 660K token.
- `out/<slug>/thumbs/` là thư mục tạm — dọn cùng `smoke/` và `review/` ở bước dọn cuối.



### Cơ chế 2 Repository (Public vs Private)
Dự án vận hành theo mô hình 2 Git repository song song trong cùng một thư mục làm việc:
- 🌐 **Public Repo (`.git`)** → Trỏ tới `git@github.com:pmduc97/remotion.git`: Quản lý mã nguồn core Remotion công khai. Sử dụng lệnh `git` thông thường.
- 🔒 **Private Repo (`.git-private`)** → Trỏ tới `git@github.com:pmduc97/remotion_private.git`: Quản lý toàn bộ tài nguyên bản quyền (Kể Bé Nghe, Hát Bé Nghe, Shopee Affiliate, VieNeu-TTS, các scripts quản trị...). Các thư mục này đều bị `.gitignore` của Public repo bỏ qua để tránh rò rỉ dữ liệu lên mạng.

### Sử dụng lệnh `git-private`:
- **Trên Linux:** Đã có công cụ 1-chạm `git-private` trong PATH (symlink `/home/pmduc97/.local/bin/git-private` → `scripts/git-private.sh`).
- **Trên Windows:** Dùng script `.\scripts\git-private.ps1` hoặc `git --git-dir=.git-private --work-tree=.`.
- **Quy trình thao tác:**
  ```bash
  # 1. Kiểm tra các file private đã thay đổi hoặc mới tạo:
  git-private status
  # 2. Thêm file vào staging (chỉ định path tường minh, không dùng 'git-private add .'):
  git-private add packages/example/src/kebenghe/
  git-private add scripts/dashboard-kebenghe/
  # 3. Commit:
  git-private commit -m "feat(kebenghe): hoàn thiện truyện mới"
  # 4. Push trực tiếp lên repo Private trên GitHub:
  git-private push
  ```
- **Nguyên tắc an toàn:** Lệnh `git` thông thường dành cho repo Public Remotion, còn lệnh `git-private` dành riêng cho toàn bộ tài sản Kể Bé Nghe / Shopee / Hát Bé Nghe. Cả hai hoạt động độc lập, không được commit lẫn lộn sang nhau.

### Tự động hóa đăng bài (YouTube Auto-Upload & Scheduler)
Hệ thống tự động hóa lên lịch phát sóng YouTube Shorts từ file thành phẩm trong out/<slug>/:
- **Thư mục công cụ:** scripts/youtube-upload/ (tài liệu chi tiết: scripts/youtube-upload/README.md).
- **Lệnh thực thi nhanh:**
  - `bun run yt:upload <slug>` — Tự động bóc tách tiêu đề/mô tả/tag từ DANG-BAI.md, đọc giờ hẹn trong out/posting-schedule.json, đặt selfDeclaredMadeForKids = False, upload kèm thumbnail và lưu trạng thái vào out/publish-status.json.
  - `bun run yt:upload <slug> --now` — Đăng công khai ngay lập tức.
  - `bun run yt:auth` — Kiểm tra hoặc xác thực OAuth Google.

### Tự động hóa đăng bài Facebook Reels (Meta Reels API)
Hệ thống tự động hóa lên lịch phát sóng Facebook Reels từ file thành phẩm trong out/<slug>/:
- **Thư mục công cụ:** scripts/facebook-upload/ (tài liệu chi tiết: scripts/facebook-upload/README.md).
- **Lệnh thực thi nhanh:**
  - `bun run fb:upload <slug>` — Tự động bóc tách caption/hashtags từ DANG-BAI.md, đọc giờ hẹn trong out/posting-schedule.json, upload lên Reels và lưu trạng thái vào out/publish-status.json.
  - `bun run fb:upload <slug> --now` — Xuất bản Reel công khai ngay lập tức.
  - `bun run fb:status` — Kiểm tra kết nối Fanpage và trạng thái token.

### Tự động hóa đăng bài TikTok (TikTok Studio Automation & AI Supervisor)
Hệ thống tự động hóa lên lịch phát sóng TikTok từ file thành phẩm trong out/<slug>/:
- **Thư mục công cụ:** scripts/tiktok-upload/ (tài liệu chi tiết: scripts/tiktok-upload/README.md).
- **Đặc điểm:** Tích hợp **AI Supervisor** (`deepseek-v4.1-auto` qua 9router) thị giác máy tính tự giải phóng modal/popup lạ và thẩm định toàn diện ảnh bìa + lịch hẹn trước khi lên lịch; thông báo Telegram realtime 2 tin nhắn (Bắt đầu 🚀 & Hoàn tất 🎉) dạng text súc tích.
- **Lệnh thực thi nhanh:**
  - `bun run tiktok:upload <slug>` — Đọc DANG-BAI.md, tải video, tải ảnh bìa gốc có tiêu đề, lên lịch theo out/posting-schedule.json (tối đa 10 ngày) và lưu trạng thái vào out/publish-status.json.
  - `bun run tiktok:upload <slug> --dry-run` — Chế độ chạy thử nghiệm an toàn, kiểm tra toàn bộ luồng mà không bấm nút đăng thật.
  - `bun run tiktok:upload <slug> --now` — Đăng công khai ngay lập tức.
  - `bun run tiktok:auth` — Đăng nhập tài khoản bằng mã QR quét gửi qua Telegram.
  - `bun run tiktok:status` — Kiểm tra phiên đăng nhập TikTok Studio còn hiệu lực.

