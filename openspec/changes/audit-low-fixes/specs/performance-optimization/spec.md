## ADDED Requirements

### Requirement: HTTP client MUST use HTTP/2 when available

Outbound HTTP calls SHALL use HTTP/2 protocol to enable multiplexing and reduce connection overhead.

#### Scenario: HTTP/2 enabled for outbound requests
- **WHEN** Laravel HTTP client makes outbound request
- **THEN** request uses HTTP/2 protocol if server supports it (configured via `'version' => '2.0'` in Guzzle options)
- **AND** falls back to HTTP/1.1 if server doesn't support HTTP/2

#### Scenario: Connection multiplexing works
- **WHEN** multiple requests are made to same host
- **THEN** requests share single TCP connection via HTTP/2 multiplexing
- **AND** do NOT create separate connections per request

---

### Requirement: HTTP client MUST enable connection pooling

TCP connections SHALL be kept alive and reused for subsequent requests to reduce connection establishment overhead.

#### Scenario: TCP keepalive enabled
- **WHEN** HTTP client establishes connection
- **THEN** TCP keepalive is enabled (CURLOPT_TCP_KEEPALIVE = 1)
- **AND** keepalive idle time is 120 seconds
- **AND** keepalive interval is 60 seconds

#### Scenario: Connections reused for same host
- **WHEN** multiple requests made to same host within keepalive window
- **THEN** existing connection is reused
- **AND** new TCP handshake is NOT required

#### Scenario: Connection pooling improves performance
- **WHEN** comparing request times with and without pooling
- **THEN** pooled requests are faster (no TCP handshake overhead)
- **AND** especially noticeable for HTTPS (no TLS negotiation)

---

### Requirement: HTTP/2 configuration MUST be transparent

Connection pooling and HTTP/2 SHALL be configured globally without requiring changes to existing HTTP call sites.

#### Scenario: Configuration applied globally
- **WHEN** HTTP client is initialized
- **THEN** HTTP/2 and connection pooling are enabled globally via `Http::globalRequest()` in AppServiceProvider
- **AND** layers with existing per-call config (apiRequest, coreApiRequest, CoreApiInternalClient)
- **AND** individual HTTP calls do NOT need modification

#### Scenario: Existing code continues working
- **WHEN** existing HTTP calls are made
- **THEN** calls work as before (same API, same responses)
- **AND** performance improvement is automatic
- **AND** no code changes required in controllers/services
