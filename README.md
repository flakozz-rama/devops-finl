# DevOps Final Project - ToDo Application
**Author:** AbayK

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DevOps Pipeline Architecture                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────────────┐  │
│   │   Git    │───▶│ Jenkins  │───▶│  Docker  │───▶│   Kubernetes     │  │
│   │  (SCM)   │    │  (CI/CD) │    │ Registry │    │   (Deployment)   │  │
│   └──────────┘    └──────────┘    └──────────┘    └──────────────────┘  │
│        │               │               │                    │            │
│        │               │               │                    ▼            │
│        │               │               │          ┌──────────────────┐  │
│        │               │               │          │   ┌──────────┐   │  │
│        ▼               ▼               │          │   │ ToDo App │   │  │
│   ┌──────────┐    ┌──────────┐        │          │   │ (Pod x2) │   │  │
│   │  Source  │    │  Build   │        │          │   └──────────┘   │  │
│   │   Code   │    │  & Test  │        │          │        │         │  │
│   └──────────┘    └──────────┘        │          │        ▼         │  │
│                                        │          │   ┌──────────┐   │  │
│                                        │          │   │PostgreSQL│   │  │
│                                        │          │   │  (Pod)   │   │  │
│                                        │          │   └──────────┘   │  │
│                                        │          └──────────────────┘  │
│                                                                          │
│   ┌──────────────────────────────────────────────────────────────────┐  │
│   │                    Ansible (Infrastructure Automation)            │  │
│   └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
devops-final/
├── app/                          # Spring Boot Application
│   ├── src/main/java/           # Java source code
│   ├── src/main/resources/      # Application configuration
│   ├── src/test/                # Test files
│   ├── build.gradle             # Gradle build configuration
│   └── gradlew                  # Gradle wrapper
├── docker/                       # Docker Configuration
│   ├── Dockerfile_AbayK         # Multi-stage Dockerfile
│   ├── docker-compose_AbayK.yml # Docker Compose configuration
│   └── .env.example             # Environment variables template
├── k8s/                          # Kubernetes Manifests
│   ├── deployment_AbayK.yaml    # Deployment configuration
│   ├── service_AbayK.yaml       # Service definitions
│   ├── configmap_AbayK.yaml     # ConfigMap
│   ├── secret_AbayK.yaml        # Secrets (Base64 encoded)
│   ├── hpa_AbayK.yaml           # Horizontal Pod Autoscaler
│   └── pvc_AbayK.yaml           # Persistent Volume Claim
├── ansible/                      # Ansible Automation
│   ├── inventory_AbayK.ini      # Inventory file
│   ├── playbook_AbayK.yml       # Main playbook
│   ├── deploy_k8s_AbayK.yml     # K8s deployment playbook
│   ├── vault_secrets.yml        # Ansible Vault template
│   ├── group_vars/              # Group variables
│   └── roles/                   # Ansible roles
├── scripts/                      # Setup scripts
│   ├── setup_vm_AbayK.sh        # VM setup script
│   └── install_docker_AbayK.sh  # Docker installation
├── Jenkinsfile_AbayK            # Jenkins pipeline
├── .gitignore                   # Git ignore rules
└── README.md                    # This file
```

## Step-by-Step Setup Instructions

### Part 0: Linux VM Setup

1. **Create Ubuntu VM** (20.04+ or 22.04+)
   ```bash
   # After VM creation, run the setup script
   sudo ./scripts/setup_vm_AbayK.sh
   ```

2. **Configure SSH Keys**
   ```bash
   # Generate SSH key
   ssh-keygen -t ed25519 -C "your_email@example.com"

   # Copy public key to authorized_keys
   cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
   ```

3. **Verify Firewall**
   ```bash
   sudo ufw status verbose
   ```

### Part 1: Docker Setup

1. **Install Docker**
   ```bash
   sudo ./scripts/install_docker_AbayK.sh
   ```

2. **Build Docker Image**
   ```bash
   cd /path/to/devops-final
   docker build -t abayk/todo-app:1.0.0 -f docker/Dockerfile_AbayK .
   ```

3. **Run with Docker Compose**
   ```bash
   cd docker
   cp .env.example .env
   docker-compose -f docker-compose_AbayK.yml up -d
   ```

4. **Verify Application**
   ```bash
   curl http://localhost:8080/actuator/health
   curl http://localhost:8080/api/todos
   ```

### Part 2: Jenkins Setup

1. **Install Jenkins on VM**
   ```bash
   ansible-playbook -i ansible/inventory_AbayK.ini ansible/playbook_AbayK.yml --tags jenkins
   ```

2. **Access Jenkins**
   - URL: `http://<VM_IP>:8080`
   - Get initial password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

3. **Configure Jenkins**
   - Install recommended plugins
   - Install additional plugins: Pipeline, Git, Docker
   - Create admin user
   - Add credentials (Docker Hub, Git)

4. **Create Pipeline Job**
   - New Item → Pipeline
   - Configure SCM: Git repository URL
   - Script Path: `Jenkinsfile_AbayK`

### Part 3: Kubernetes Setup

1. **Start Minikube**
   ```bash
   minikube start --driver=docker
   ```

2. **Deploy Application**
   ```bash
   kubectl apply -f k8s/configmap_AbayK.yaml
   kubectl apply -f k8s/secret_AbayK.yaml
   kubectl apply -f k8s/pvc_AbayK.yaml
   kubectl apply -f k8s/deployment_AbayK.yaml
   kubectl apply -f k8s/service_AbayK.yaml
   kubectl apply -f k8s/hpa_AbayK.yaml
   ```

3. **Verify Deployment**
   ```bash
   kubectl get pods
   kubectl get services
   kubectl rollout status deployment/todo-app
   ```

4. **Access Application**
   ```bash
   minikube service todo-app-service --url
   ```

5. **Rolling Update & Rollback**
   ```bash
   # Update
   kubectl set image deployment/todo-app todo-app=abayk/todo-app:1.1.0
   kubectl rollout status deployment/todo-app

   # Rollback
   kubectl rollout undo deployment/todo-app
   ```

### Part 4: Ansible Automation

1. **Run Complete Setup**
   ```bash
   ansible-playbook -i ansible/inventory_AbayK.ini ansible/playbook_AbayK.yml
   ```

2. **Deploy to Kubernetes with Ansible**
   ```bash
   ansible-playbook -i ansible/inventory_AbayK.ini ansible/deploy_k8s_AbayK.yml
   ```

3. **Using Ansible Vault**
   ```bash
   # Encrypt secrets
   ansible-vault encrypt ansible/vault_secrets.yml

   # Run with vault
   ansible-playbook playbook_AbayK.yml --ask-vault-pass
   ```

## CI/CD Pipeline Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Checkout   │───▶│    Build    │───▶│    Test     │───▶│   Analyze   │
│   (Git)     │    │  (Gradle)   │    │  (JUnit)    │    │ (Optional)  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                │
                                                                ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Deploy    │◀───│    Push     │◀───│   Build     │◀───│  Artifact   │
│   (K8s)     │    │  (Registry) │    │  (Docker)   │    │  Archive    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Pipeline Stages:

1. **Checkout** - Clone repository from Git
2. **Build** - Compile with `./gradlew clean build`
3. **Test** - Run tests with `./gradlew test`
4. **Code Analysis** - Static analysis (Checkstyle)
5. **Docker Build** - Build image with dynamic tag
6. **Docker Push** - Push to registry (main/develop only)
7. **Deploy** - Deploy to Kubernetes (main only)

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/todos` | Get all todos |
| GET | `/api/todos/{id}` | Get todo by ID |
| POST | `/api/todos` | Create new todo |
| PUT | `/api/todos/{id}` | Update todo |
| DELETE | `/api/todos/{id}` | Delete todo |
| GET | `/api/todos/status/{completed}` | Get todos by status |
| GET | `/api/todos/search?title=` | Search todos |
| GET | `/actuator/health` | Health check |

## Useful Commands

### Docker
```bash
# Build image
docker build -t abayk/todo-app:1.0.0 -f docker/Dockerfile_AbayK .

# View image layers
docker history abayk/todo-app:1.0.0

# Start services
docker-compose -f docker/docker-compose_AbayK.yml up -d

# View logs
docker-compose -f docker/docker-compose_AbayK.yml logs -f

# Stop services
docker-compose -f docker/docker-compose_AbayK.yml down
```

### Kubernetes
```bash
# Deploy
kubectl apply -f k8s/

# Get resources
kubectl get pods,svc,deploy

# Describe pod
kubectl describe pod <pod-name>

# View logs
kubectl logs -f deployment/todo-app

# Scale
kubectl scale deployment todo-app --replicas=3

# Rollback
kubectl rollout undo deployment/todo-app

# Delete resources
kubectl delete -f k8s/
```

### Ansible
```bash
# Syntax check
ansible-playbook playbook_AbayK.yml --syntax-check

# Dry run
ansible-playbook playbook_AbayK.yml --check

# Run on specific group
ansible-playbook -i inventory_AbayK.ini playbook_AbayK.yml -l jenkins_servers
```

## Verification Evidence

After deployment, verify:

1. **Jenkins Pipeline**
   - Screenshot of successful pipeline execution
   - All stages passed (green)

2. **Kubernetes Pods**
   ```bash
   kubectl get pods -o wide
   kubectl get hpa
   ```

3. **Application Response**
   ```bash
   curl http://<SERVICE_IP>:8080/api/todos
   curl http://<SERVICE_IP>:8080/actuator/health
   ```

## Author
**AbayK** - DevOps Final Project
