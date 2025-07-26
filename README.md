# EventVista - AI-Powered Event Venue Design

EventVista is an innovative web application that uses AI to generate custom event venue designs based on user specifications. The application combines a modern frontend with a powerful AI backend to create stunning visualizations of event spaces.

## 🚀 Features

- **Interactive Design Process**: Multi-step form for event type, dimensions, and style selection
- **AI-Powered Generation**: Uses Stable Diffusion to create photorealistic venue designs
- **Multiple Event Types**: Support for weddings, birthdays, conferences, and custom events
- **Customizable Dimensions**: Specify hall area, stage dimensions, and additional features
- **Style Variety**: Choose from elegant, royal, modern, rustic, bohemian, and futuristic styles
- **Real-time Generation**: Instant AI-powered image generation with loading states
- **Responsive Design**: Works seamlessly on desktop and mobile devices

## 🏗️ Architecture

### Frontend
- **HTML5**: Semantic markup with modern structure
- **CSS3**: Custom styling with CSS variables and animations
- **JavaScript**: Vanilla JS for interactivity and API communication
- **Font Awesome**: Icons for enhanced UI

### Backend
- **FastAPI**: High-performance Python web framework
- **Stable Diffusion**: AI model for image generation
- **PyTorch**: Deep learning framework
- **Uvicorn**: ASGI server for production deployment

## 📋 Prerequisites

- Python 3.11+
- Docker and Docker Compose
- Hugging Face account and token
- Git

## 🛠️ Installation

### Option 1: Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Event-Management
   ```

2. **Set up environment variables**
   ```bash
   make setup-env
   # Edit .env file with your Hugging Face token
   ```

3. **Install dependencies**
   ```bash
   make install-dev
   ```

4. **Run the application**
   ```bash
   make run
   ```

### Option 2: Docker Deployment

1. **Build and run with Docker Compose**
   ```bash
   docker-compose up -d
   ```

2. **Access the application**
   - Frontend: http://localhost
   - Backend API: http://localhost:8000

## 🧪 Testing

### Run all tests
```bash
make test
```

### Run specific test types
```bash
make test-unit          # Unit tests only
make test-integration   # Integration tests only
```

### Run performance tests
```bash
make performance-test
```

## 🔧 Development

### Code Quality
```bash
make lint              # Run linting checks
make format            # Format code
make security-scan     # Run security scan
```

### Local Development
```bash
make run               # Run with hot reload
make docker-run        # Run with Docker Compose
make docker-logs       # View Docker logs
```

### CI/CD Pipeline
The project includes a comprehensive GitHub Actions pipeline with:
- Code linting and formatting
- Security scanning
- Unit and integration tests
- Docker image building
- Performance testing
- Automated deployment

## 📁 Project Structure

```
Event-Management/
├── .github/workflows/     # CI/CD pipeline
├── tests/                 # Test suite
│   ├── test_generate.py   # Unit tests
│   └── integration/       # Integration tests
├── performance-tests/     # Load testing
├── generate.py           # FastAPI backend
├── index.html            # Main frontend
├── script.js             # Frontend logic
├── style.css             # Styling
├── requirements.txt      # Python dependencies
├── Dockerfile            # Container configuration
├── docker-compose.yml    # Multi-service setup
├── nginx.conf           # Web server configuration
├── Makefile             # Development commands
└── README.md            # This file
```

## 🔌 API Endpoints

### Health Check
- `GET /health` - Application health status

### Root
- `GET /` - Application information

### Image Generation
- `POST /generate` - Generate AI image
  - Body: `{"prompt": "description"}`
  - Returns: `{"image": "base64_encoded_image"}`

## 🚀 Deployment

### Production Deployment

1. **Set up environment variables**
   ```bash
   export HF_TOKEN=your_huggingface_token
   export ENVIRONMENT=production
   ```

2. **Build and deploy**
   ```bash
   make build
   docker-compose -f docker-compose.prod.yml up -d
   ```

### Cloud Deployment

The application can be deployed to various cloud platforms:

- **AWS**: Use ECS or EKS with Application Load Balancer
- **Google Cloud**: Deploy to Cloud Run or GKE
- **Azure**: Use Azure Container Instances or AKS
- **Heroku**: Deploy using container registry

## 📊 Monitoring

### Health Checks
- Application health: `/health`
- Docker health checks configured
- Kubernetes liveness/readiness probes

### Logging
- Structured logging with FastAPI
- Nginx access and error logs
- Docker container logs

### Performance
- Artillery load testing
- Response time monitoring
- Resource usage tracking

## 🔒 Security

- CORS configuration for frontend-backend communication
- Input validation with Pydantic
- Security headers in Nginx
- Non-root Docker containers
- Regular security scanning with Bandit

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow PEP 8 for Python code
- Use meaningful commit messages
- Add tests for new features
- Update documentation as needed

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the documentation
- Review the troubleshooting guide

## 🔄 Version History

- **v1.0.0**: Initial release with basic AI image generation
- **v1.1.0**: Added multiple event types and styles
- **v1.2.0**: Enhanced UI/UX and performance optimizations

---

**EventVista** - Transforming event planning with AI-powered design visualization. 