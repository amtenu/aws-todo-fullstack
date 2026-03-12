# AWS Full-Stack Todo Application

A production-grade full-stack todo application built with modern technologies and deployed on AWS infrastructure. This project demonstrates cloud-native architecture, containerization, DevOps best practices, and Test-Driven Development.

##  Project Overview

This project showcases enterprise-level development practices by building a scalable todo application with user management, deployed on AWS with full observability and CI/CD pipeline.


### Key  Objectives
- Modern frontend development with React & Redux
- RESTful API design with Express & TypeScript
- Test-Driven Development (TDD)
- Database design with TypeORM
- AWS cloud architecture
- Container orchestration with ECS
- Infrastructure as Code with Terraform
- CI/CD pipelines
- Observability and monitoring

##  Tech Stack

### Frontend
- **React 18** with TypeScript
- **Redux Toolkit** for state management
- **React Router** for navigation
- **Tailwind CSS** for styling
- **Vite** for build tooling
- **Axios** for API communication

### Backend
- **Node.js** with Express
- **TypeScript** for type safety
- **TypeORM** as database ORM
- **MySQL** database
- **JWT** for authentication
- **Jest & Supertest** for testing (TDD approach)

### AWS Infrastructure
- **API Gateway** - API management and throttling
- **AWS Cognito** - Authentication and authorization
- **ECS/Fargate** - Container orchestration
- **Application Load Balancer** - Load balancing and SSL
- **RDS MySQL** - Managed database (Multi-AZ)
- **VPC** with public/private subnets
- **CloudWatch & X-Ray** - Logging and tracing
- **S3** - Static asset storage
- **ECR** - Container registry

### DevOps & Monitoring
- **Docker** & **Docker Compose** - Containerization
- **Terraform** - Infrastructure as Code
- **Prometheus** & **Grafana** - Metrics and dashboards
- **GitHub Actions** - CI/CD pipeline
- **Jest** - Unit and integration testing


## Development Phases

- [x] **Phase 1: Project Setup** ✅
  - Git repository with branching strategy
  - Project structure
  - Professional README

- [x] **Phase 2: Frontend Development** ✅
  - React app with TypeScript✅
  - Redux state management✅
  - Authentication UI (Login/Register)✅
  - Todo CRUD UI✅
  - Responsive design with Tailwind✅
  - Protected routes✅

- [x] **Phase 3: Backend API Development** ✅ (In Progress)
  - Express server with TypeScript
  - Jest testing infrastructure ✅
  - Tests for existing endpoints ✅
  - Database setup with TypeORM (Next)✅
  - Authentication endpoints (JWT)✅
  - Todos CRUD endpoints
  - Input validation and error handling

- [x] **Phase 4: Local Development & Integration**
  - Docker Compose setup✅
  - MySQL container✅
  - Frontend + Backend integration ✅
  - End-to-end testing ✅

- [x] **Phase 5: AWS Infrastructure (Terraform)**
  - VPC with subnets and security groups
  - RDS MySQL (Multi-AZ)
  - ECS/Fargate cluster
  - Application Load Balancer
  - API Gateway
  - AWS Cognito
  - CloudWatch logging

- [ ] **Phase 6: Monitoring & Observability**
  - Prometheus metrics
  - Grafana dashboards
  - CloudWatch integration
  - Health checks and alerting

- [ ] **Phase 7: CI/CD Pipeline**
  - GitHub Actions workflows
  - Automated testing
  - Docker image building
  - Deployment automation

## Getting Started

### Prerequisites

- Node.js 18+
- MySQL 8+
- Docker & Docker Compose (optional)
- AWS CLI (for deployment)
- Terraform (for infrastructure)

### Local Development

#### Frontend
```bash
cd frontend
npm install
npm run dev
# App runs on http://localhost:3000
```

#### Backend
```bash
cd backend
npm install

# Copy .env.example to .env and configure
cp .env.example .env

# Run tests
npm test

# Start development server
npm run dev
# API runs on http://localhost:8008
```

##  Testing

This project follows Test-Driven Development (TDD) practices.

### Backend Tests
```bash
cd backend

# Run all tests
npm test

# Watch mode (runs tests on file changes)
npm run test:watch

# Coverage report
npm run test:coverage
```

**Current Test Coverage:**
- Health check endpoint ✅
- API root endpoint ✅
- 404 handler ✅
- Auth endpoints 
- Todos endpoints 

## API Documentation

### Health Check
```
GET /health
Response: { status: "OK", message: "Server is running", timestamp: "..." }
```

### Authentication (Coming Soon)
```
POST /api/auth/register - Register new user
POST /api/auth/login - Login user
POST /api/auth/logout - Logout user
GET /api/auth/me - Get current user
```

### Todos (Coming Soon)
```
GET /api/todos - Get all todos
POST /api/todos - Create todo
PUT /api/todos/:id - Update todo
DELETE /api/todos/:id - Delete todo
```

## Environment Variables

### Frontend (.env)
```env
VITE_API_URL=http://localhost:8008/api
```

### Backend (.env)
```env
PORT=8008
NODE_ENV=development
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=your_password
DB_DATABASE=todoapp
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=7d
FRONTEND_URL=http://localhost:3000
```

## Features

### Frontend Features
- ✅ User authentication (Login/Register)
- ✅ Protected routes
- ✅ Todo list with filters (All/Active/Completed)
- ✅ Create, edit, delete todos
- ✅ Toggle todo completion
- ✅ Responsive design
- ✅ Loading states and error handling
- ✅ Beautiful UI with animations

### Backend Features (In Progress)
- ✅ RESTful API with Express
- ✅ TypeScript for type safety
- ✅ Jest testing infrastructure
- ✅ Health check endpoint
- 🔄 JWT authentication
- 🔄 User registration and login
- 🔄 Todos CRUD operations
- 🔄 Input validation
- 🔄 Error handling middleware

### Infrastructure Features (Planned)
- 📋 Auto-scaling with ECS
- 📋 High availability (Multi-AZ)
- 📋 Load balancing
- 📋 SSL/TLS encryption
- 📋 CloudWatch monitoring
- 📋 Automated backups
- 📋 CI/CD pipeline

##  Contributing

This is a personal portfolio project. Feel free to fork and experiment!

## License

MIT





