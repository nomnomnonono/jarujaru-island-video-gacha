.PHONY: lint format run

UV ?= uv
HOST ?= 127.0.0.1
PORT ?= 8000

lint:
	$(UV) run ruff check .
	$(UV) run mypy backend

format:
	$(UV) run ruff format .
	$(UV) run ruff check . --fix

run:
	cd backend && $(UV) run uvicorn api.main:app --reload --host $(HOST) --port $(PORT)

