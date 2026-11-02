# 3. package:http for networking, minimal dependency set

Status: accepted

## Context
A template should not force heavy or opinionated libraries on derived apps.

## Decision
`network` wraps `package:http` in `ApiClient` (base URL from `AppConfig`, JSON decoding,
timeouts, `http.BaseClient` decorators for logging and auth, injectable `http.Client`,
every failure mapped to a typed `Failure`). Dio, Retrofit, injectable, dartz/fpdart,
envied and flutter_dotenv are intentionally not used.

## Consequences
Tests use `MockClient`. Teams can swap in heavier libraries behind the same `ApiClient` seam.
