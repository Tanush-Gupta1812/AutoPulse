import os

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "AutoPulse API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api"

    # PostgreSQL async connection URL (default to localhost or Docker service name 'db')
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql+asyncpg://autopulse:autopulse123@localhost:5432/autopulse"
    )

    # Allowed CORS Origins for Flutter Web & Mobile
    CORS_ORIGINS: list[str] = [
        "http://localhost",
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:5000",
        "*"
    ]

    JWT_SECRET: str = "autopulse_prototype_secret_key_demo_only"
    TELEMETRY_RETENTION_DAYS: int = 7
    DOWNSAMPLING_INTERVAL_SEC: int = 60

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )


settings = Settings()
