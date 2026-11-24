"""Settings parsing tests."""

from app.core.config import Settings


def test_cors_origins_accepts_csv(monkeypatch) -> None:
    monkeypatch.setenv("SE_CORS_ORIGINS", "http://a.example, http://b.example")

    settings = Settings()

    assert settings.cors_origins == ["http://a.example", "http://b.example"]


def test_cors_origins_default_and_regex() -> None:
    settings = Settings()

    assert "http://localhost:5173" in settings.cors_origins
    assert settings.cors_origin_regex is not None
