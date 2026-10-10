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
