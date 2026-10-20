import logging
from contextlib import asynccontextmanager

from backend.app.api.endpoints import router as api_router
from backend.app.core.config import settings
from backend.app.core.database import Base, engine
from backend.app.seed import seed_database
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("autopulse")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan context manager that initializes DB tables and runs seed on startup."""
    logger.info("Initializing AutoPulse database schema...")
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        await seed_database()
        logger.info("AutoPulse backend ready.")
    except Exception as e:
        logger.warning(f"Database startup notice (e.g. if DB is starting up): {e}")
    yield
    logger.info("Shutting down AutoPulse API...")
    await engine.dispose()


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="AutoPulse Smart Automotive Health & AI Component Failure Forecasting Engine",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url=f"{settings.API_V1_STR}/docs",
    redoc_url=f"{settings.API_V1_STR}/redoc",
    lifespan=lifespan
)

# CORS configuration for Flutter Web, mobile, and dev clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register REST and WebSocket routers
app.include_router(api_router, prefix=settings.API_V1_STR)
app.include_router(api_router) # also at root for websocket /ws/...


@app.get("/health")
@app.get("/")
async def health_check():
    return {
        "status": "healthy",
        "service": "AutoPulse Automotive Intelligence API",
        "version": settings.VERSION,
        "docs": f"{settings.API_V1_STR}/docs"
    }
