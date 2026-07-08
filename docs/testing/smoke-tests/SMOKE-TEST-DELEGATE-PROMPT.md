# Smoke Test Prompt — Delegate ke Agent Lain

Copy prompt di bawah ini dan kirim ke agent lain. Agent akan menjalankan smoke test via Playwright browser automation.

---

## PROMPT

```
You are a QA tester. Run comprehensive smoke tests on the Kolabri web application using Playwright browser automation.

## Environment
- Base URL: http://localhost:8000 (Laravel frontend)
- App name: Kolabri — AI-Powered Collaborative Learning Platform
- Servers are already running. DO NOT restart or start any servers.

## Credentials

### Dosen (Lecturer)
- budi.santoso@univ.ac.id / password123
- siti.rahayu@univ.ac.id / password123

### Mahasiswa (Student)
- andi.pratama@student.ac.id / password123
- dewi.kusuma@student.ac.id / password123
- (all students use password123)

### Join Codes for courses
JOIN-IF201, JOIN-IF202, JOIN-IF203, JOIN-IF204, JOIN-IF205, JOIN-IF206, JOIN-IF207, JOIN-IF208, JOIN-IF209, JOIN-IF210, JOIN-IF211, JOIN-IF212

### Group Codes pattern
GRP-IF{code}-{number} e.g. GRP-IF211-1, GRP-IF212-1

## Instructions

For EVERY test case below:
1. Use `browser_navigate` to go to the page
2. Use `browser_snapshot` to inspect the page state
3. Use `browser_type` to fill form fields
4. Use `browser_click` to click buttons/links
5. Use `browser_take_screenshot` to capture visual evidence
6. Use `browser_console_messages` with level="error" to check for JS errors
7. Save all screenshots to .playwright-mcp/ folder

IMPORTANT: After clicking, always take a snapshot to verify what happened. After each test case, note PASS/FAIL with evidence.

## Test 1: Lecturer Login & Analytics Flow
1. Navigate to http://localhost:8000/login
2. Fill email: budi.santoso@univ.ac.id
3. Fill password: password123
4. Click "Masuk" button
5. Verify: redirect to /lecturer/courses (page title should contain "Kelas")
6. Take screenshot: test-1-lecturer-courses.png
7. Click "Analytics" in sidebar
8. Verify: page shows analytics overview with course cards
9. Take screenshot: test-2-analytics-overview.png
10. Click one of the course cards
11. Verify: page shows analytics detail with metrics (quality score, HOT%, etc.)
12. Take screenshot: test-3-analytics-detail.png
13. Check console errors: should be only WebSocket errors (expected), no JS errors

## Test 2: Student Chat Room Flow
1. Navigate to http://localhost:8000/login
2. Login as andi.pratama@student.ac.id / password123
3. Verify: redirect to /student/courses
4. Click one of the course cards
5. Click "Sesi Diskusi" in sidebar submenu (or navigate to the chat-spaces page)
6. Verify: page shows chat sessions list
7. Click "Diskusi Utama" or "Masuk Diskusi"
8. Verify: chat room loads with message list, input field, and send button
9. Take screenshot: test-4-chat-room.png
10. Type "Smoke test pesan" in the chat input
11. Click "Kirim" button
12. Take screenshot: test-5-chat-sent.png

## Test 3: Logout & Re-login (CSRF Test)
1. Click "Keluar" (logout) button in sidebar
2. Verify: redirect to /login page
3. Take screenshot: test-6-after-logout.png
4. Login again: andi.pratama@student.ac.id / password123
5. Verify: redirect to /student/courses WITHOUT "Page Expired" error
6. Take screenshot: test-7-re-login-success.png

## Test 4: Student Reflections
1. (Logged in as student)
2. Click "Refleksi" in sidebar
3. Verify: page shows "Refleksi Saya" with reflection list
4. Take screenshot: test-8-reflections.png

## Test 5: Student AI Chat
1. Click "Chat dengan AI" in sidebar
2. Verify: page shows AI chat interface with input and category buttons
3. Take screenshot: test-9-ai-chat.png

## Test 6: Join Course Modal
1. Navigate to /student/courses
2. Click "Gabung Mata Kuliah" button
3. Verify: modal appears with join code input field
4. Take screenshot: test-10-join-modal.png
5. Close the modal

## Test 7: Dark Mode Toggle
1. Click "Mode gelap" (dark mode) button in sidebar
2. Verify: document.documentElement.className contains "dark"
3. Take screenshot: test-11-dark-mode.png

## Test 8: Student Groups Page
1. Navigate to a course detail, then click "Cari atau Buat Grup"
2. Verify: groups page shows group status (joined or available groups)
3. Take screenshot: test-12-groups.png

## Final Report
After all tests, compile a report in this format:

| # | Test | Status | Evidence |
|---|------|--------|----------|
| 1 | Lecturer Login & Analytics | ✅/❌ | screenshot path |
| 2 | Student Chat Room | ✅/❌ | screenshot path |
| 3 | Logout & Re-login CSRF | ✅/❌ | screenshot path |
| 4 | Student Reflections | ✅/❌ | screenshot path |
| 5 | Student AI Chat | ✅/❌ | screenshot path |
| 6 | Join Course Modal | ✅/❌ | screenshot path |
| 7 | Dark Mode | ✅/❌ | screenshot path |
| 8 | Student Groups | ✅/❌ | screenshot path |

List any bugs found with:
- What went wrong
- Expected behavior
- Screenshot evidence
- Console error output

## Notes
- WebSocket connection errors to ws://localhost:3000 are EXPECTED and NOT bugs
- If you see "Page Expired" (419) during login, refresh the page first then try again
- If a modal blocks clicks, close it via the X button before clicking other elements
- Do NOT restart any servers
- Close browser when all tests are done
```
