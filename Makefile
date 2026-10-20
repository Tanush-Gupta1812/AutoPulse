.PHONY: help up down restart logs backend-dev seed test test-backend lint-backend app-run app-web app-test clean

help:
	@echo "AutoPulse - Smart Mobility & Automotive AI"
	@echo "-------------------------------------------"
	@echo "make up            : Build and start Postgres + FastAPI backend via Docker"
	@echo "make down          : Stop all Docker containers"
	@echo "make logs          : Tail logs from backend containers"
	@echo "make seed          : Seed demo vehicles and garages in database"
	@echo "make test          : Run backend pytest suite"
	@echo "make lint          : Lint backend Python code with ruff"
	@echo "make app-run       : Run Flutter mobile/desktop app"
	@echo "make app-web       : Run Flutter app in Chrome browser for demo"
	@echo "make app-test      : Run Flutter widget and unit tests"

up:
	docker compose up --build -d

down:
	docker compose down

restart:
	docker compose down && docker compose up --build -d

logs:
	docker compose logs -f api

backend-dev:
	uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000

seed:
	python -m backend.app.seed

test:
	python -m pytest backend/tests -v

test-backend: test

lint:
	ruff check backend simulator

app-run:
	cd app && flutter run

app-web:
	cd app && flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000

app-test:
	cd app && flutter test

clean:
	docker compose down -v
