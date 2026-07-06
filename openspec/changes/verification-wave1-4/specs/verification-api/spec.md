## ADDED Requirements

### Requirement: New API endpoints functional
Sistem SHALL memverifikasi semua endpoint baru berfungsi dengan benar.

#### Scenario: Message edit endpoint works
- **WHEN** `PATCH /api/student/chat/rooms/{roomId}/messages/{messageId}` dengan body `{ content: "edited" }`
- **THEN** response 200 dengan updated message
- **AND** `edited_at` timestamp terisi

#### Scenario: Message delete endpoint works
- **WHEN** `DELETE /api/student/chat/rooms/{roomId}/messages/{messageId}`
- **THEN** response 200 dengan success
- **AND** message content replaced dengan "[Pesan telah dihapus]"

#### Scenario: Message search endpoint works
- **WHEN** `GET /api/student/chat/rooms/{roomId}/messages/search?q={query}`
- **THEN** response 200 dengan array of matching messages
- **AND** results include highlighted snippets

#### Scenario: Pin message endpoint works
- **WHEN** `POST /api/student/chat/rooms/{roomId}/messages/{messageId}/pin`
- **THEN** response 200 dengan success
- **AND** message terdaftar di pinned messages

#### Scenario: Unpin message endpoint works
- **WHEN** `DELETE /api/student/chat/rooms/{roomId}/messages/{messageId}/pin`
- **THEN** response 200 dengan success
- **AND** message dihapus dari pinned messages

#### Scenario: Profile avatar upload works
- **WHEN** `POST /api/student/profile/avatar` dengan file image
- **THEN** response 200 dengan avatar URLs
- **AND** file tersimpan di storage

#### Scenario: Profile preferences update works
- **WHEN** `PATCH /api/student/profile/preferences` dengan preferences data
- **THEN** response 200 dengan updated preferences
- **AND** preferences tersimpan di database

#### Scenario: Lecturer analytics export works
- **WHEN** `GET /api/lecturer/analytics/export?format=csv`
- **THEN** response 200 dengan CSV file
- **AND** Content-Type header adalah `text/csv`

#### Scenario: Lecturer session schedule works
- **WHEN** `POST /api/lecturer/sessions/{id}/schedule` dengan `{ scheduled_at: "..." }`
- **THEN** response 200 dengan success
- **AND** session scheduled_at terisi
