SHELL := /bin/bash

.DEFAULT_GOAL := help

.PHONY: help setup backend-setup mobile-setup api web ios android macos test lint format docker

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: backend-setup mobile-setup ## Install backend and mobile dependencies

backend-setup: ## Create the Python venv and install API dependencies
	cd backend && uv sync

mobile-setup: ## Fetch Flutter packages
	cd mobile && flutter pub get

api: ## Run FastAPI with auto-reload on http://localhost:8000
	cd backend && uv run fastapi dev app/main.py --host 0.0.0.0 --port 8000

web: ## Run the Flutter web app on http://localhost:5173
	cd mobile && flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:8000

ios: ## Run on the iOS simulator or a connected device
	cd mobile && flutter run -d ios

android: ## Run on an Android emulator or a connected device
	cd mobile && flutter run -d android

macos: ## Run the macOS desktop app
	cd mobile && flutter run -d macos

test: ## Run backend and Flutter test suites
	cd backend && uv run pytest
	cd mobile && flutter test

lint: ## Lint/format-check both projects
	cd backend && uv run ruff check . && uv run ruff format --check .
	cd mobile && flutter analyze

format: ## Auto-format both projects
	cd backend && uv run ruff format . && uv run ruff check . --fix
	cd mobile && dart format lib test

docker: ## Build and run the API in Docker on port 8000
	docker compose up --build
