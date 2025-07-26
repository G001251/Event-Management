.PHONY: help install test lint format clean build run docker-build docker-run docker-stop

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install Python dependencies
	pip install -r requirements.txt

install-dev: ## Install development dependencies
	pip install -r requirements.txt
	pip install flake8 black isort mypy pytest pytest-cov

test: ## Run tests
	pytest tests/ -v --cov=. --cov-report=html

test-unit: ## Run unit tests only
	pytest tests/test_generate.py -v

test-integration: ## Run integration tests only
	pytest tests/integration/ -v

lint: ## Run linting checks
	flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	flake8 . --count --exit-zero --max-complexity=10 --max-line-length=88 --statistics
	black --check --diff .
	isort --check-only --diff .

format: ## Format code
	black .
	isort .

clean: ## Clean up generated files
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	rm -rf htmlcov/
	rm -rf .coverage
	rm -rf .pytest_cache/

build: ## Build Docker image
	docker build -t eventvista:latest .

run: ## Run the application locally
	uvicorn generate:app --host 0.0.0.0 --port 8000 --reload

docker-run: ## Run with Docker Compose
	docker-compose up -d

docker-stop: ## Stop Docker Compose services
	docker-compose down

docker-logs: ## View Docker logs
	docker-compose logs -f

setup-env: ## Setup environment variables
	@echo "Creating .env file..."
	@echo "HF_TOKEN=your_huggingface_token_here" > .env
	@echo "ENVIRONMENT=development" >> .env
	@echo "Please update .env with your actual Hugging Face token"

security-scan: ## Run security scan
	bandit -r . -f json -o bandit-report.json

performance-test: ## Run performance tests
	artillery run performance-tests/load-test.yml

ci: ## Run CI checks locally
	make lint
	make test
	make security-scan

all: ## Run all checks and tests
	make install-dev
	make format
	make lint
	make test
	make security-scan 