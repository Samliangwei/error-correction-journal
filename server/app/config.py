from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    app_name: str = "错题记录 API"
    debug: bool = False
    database_url: str = "sqlite+aiosqlite:///./error_journal.db"
    api_key: str = "dev-only-change-in-production"


settings = Settings()
