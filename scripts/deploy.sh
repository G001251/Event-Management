#!/bin/bash

# EventVista Deployment Script
# This script automates the deployment process for the EventVista application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-production}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-ghcr.io}
IMAGE_NAME=${IMAGE_NAME:-eventvista}
TAG=${TAG:-latest}

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    fi
    
    # Check if required environment variables are set
    if [ -z "$HF_TOKEN" ]; then
        log_error "HF_TOKEN environment variable is not set"
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

backup_current_deployment() {
    log_info "Creating backup of current deployment..."
    
    if [ -d "backup" ]; then
        rm -rf backup
    fi
    
    mkdir -p backup
    cp -r . backup/
    
    log_info "Backup created in ./backup/"
}

pull_latest_changes() {
    log_info "Pulling latest changes from repository..."
    
    if [ -d ".git" ]; then
        git pull origin main
        log_info "Latest changes pulled successfully"
    else
        log_warn "Not a git repository, skipping git pull"
    fi
}

build_and_push_image() {
    log_info "Building Docker image..."
    
    docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG} .
    
    if [ "$ENVIRONMENT" = "production" ]; then
        log_info "Pushing image to registry..."
        docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG}
    fi
    
    log_info "Image build completed"
}

deploy_application() {
    log_info "Deploying application to $ENVIRONMENT environment..."
    
    # Stop existing containers
    log_info "Stopping existing containers..."
    docker-compose -f docker-compose.${ENVIRONMENT}.yml down || true
    
    # Start new containers
    log_info "Starting new containers..."
    docker-compose -f docker-compose.${ENVIRONMENT}.yml up -d
    
    log_info "Application deployment completed"
}

wait_for_health_check() {
    log_info "Waiting for application to be healthy..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:8000/health > /dev/null 2>&1; then
            log_info "Application is healthy!"
            return 0
        fi
        
        log_info "Health check attempt $attempt/$max_attempts failed, retrying in 10 seconds..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    log_error "Application failed to become healthy after $max_attempts attempts"
    return 1
}

run_tests() {
    log_info "Running post-deployment tests..."
    
    # Run basic health checks
    if ! curl -f http://localhost:8000/health > /dev/null 2>&1; then
        log_error "Health check failed"
        return 1
    fi
    
    # Run API tests
    if ! curl -f http://localhost:8000/ > /dev/null 2>&1; then
        log_error "API root endpoint test failed"
        return 1
    fi
    
    log_info "Post-deployment tests passed"
}

cleanup_old_images() {
    log_info "Cleaning up old Docker images..."
    
    # Remove dangling images
    docker image prune -f
    
    # Remove images older than 7 days
    docker image prune -a --filter "until=168h" -f
    
    log_info "Cleanup completed"
}

rollback() {
    log_error "Deployment failed, rolling back..."
    
    if [ -d "backup" ]; then
        log_info "Restoring from backup..."
        cp -r backup/* .
        docker-compose -f docker-compose.${ENVIRONMENT}.yml up -d
        log_info "Rollback completed"
    else
        log_error "No backup available for rollback"
    fi
}

# Main deployment process
main() {
    log_info "Starting EventVista deployment to $ENVIRONMENT environment"
    
    # Check prerequisites
    check_prerequisites
    
    # Create backup
    backup_current_deployment
    
    # Pull latest changes
    pull_latest_changes
    
    # Build and push image
    build_and_push_image
    
    # Deploy application
    deploy_application
    
    # Wait for health check
    if ! wait_for_health_check; then
        rollback
        exit 1
    fi
    
    # Run post-deployment tests
    if ! run_tests; then
        rollback
        exit 1
    fi
    
    # Cleanup
    cleanup_old_images
    
    log_info "Deployment completed successfully!"
}

# Handle script arguments
case "$1" in
    "production"|"staging"|"development")
        main
        ;;
    "rollback")
        rollback
        ;;
    "health")
        wait_for_health_check
        ;;
    *)
        echo "Usage: $0 {production|staging|development|rollback|health}"
        echo "  production  - Deploy to production environment"
        echo "  staging     - Deploy to staging environment"
        echo "  development - Deploy to development environment"
        echo "  rollback    - Rollback to previous deployment"
        echo "  health      - Check application health"
        exit 1
        ;;
esac 