"""Configuración central de la aplicación (Pydantic Settings)."""

from __future__ import annotations

from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Variables de entorno de la app. Se cargan de `.env` o del entorno."""

    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", extra="ignore"
    )

    # --- Base de datos ---
    database_url: str = Field(default="sqlite:///./xanee_dev.db", alias="DATABASE_URL")

    # --- Supabase ---
    supabase_url: str = Field(default="", alias="SUPABASE_URL")
    supabase_anon_key: str = Field(default="", alias="SUPABASE_ANON_KEY")
    supabase_service_role_key: str = Field(
        default="", alias="SUPABASE_SERVICE_ROLE_KEY"
    )
    supabase_jwt_secret: str = Field(default="dev-insecure-secret", alias="SUPABASE_JWT_SECRET")
    supabase_storage_bucket: str = Field(default="scores", alias="SUPABASE_STORAGE_BUCKET")

    # --- App ---
    cors_origins: str = Field(default="http://localhost:8080", alias="CORS_ORIGINS")
    environment: str = Field(default="development", alias="ENVIRONMENT")

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def is_test(self) -> bool:
        return self.environment == "test"


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
