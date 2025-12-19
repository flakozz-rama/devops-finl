# DevOps Final Project - ToDo Application
**Author:** AbayK

## Architecture Diagram

```
+------------------------------------------------------------------+
|                    DevOps Pipeline Architecture                    |
+------------------------------------------------------------------+
|                                                                    |
|   +--------+    +----------+    +--------+    +----------------+  |
|   |  Git   |--->| Jenkins  |--->| Docker |--->|  Kubernetes    |  |
|   | (SCM)  |    | (CI/CD)  |    |Registry|    | (Deployment)   |  |
|   +--------+    +----------+    +--------+    +----------------+  |
|       |              |              |                |             |
|       v              v              |                v             |
|   +--------+    +----------+       |        +----------------+    |
|   | Source |    |  Build   |       |        |  +-----------+ |    |
|   |  Code  |    |  & Test  |       |        |  | ToDo App  | |    |
|   +--------+    +----------+       |        |  | (Pod x2)  | |    |
|                                    |        |  +-----------+ |    |
|                                    |        |       |        |    |
|                                    |        |       v        |    |
|                                    |        |  +-----------+ |    |
|                                    |        |  |PostgreSQL | |    |
|                                    |        |  |  (Pod)    | |    |
|                                    |        |  +-----------+ |    |
|                                    |        +----------------+    |
|                                                                    |
|   +--------------------------------------------------------------+|
|   |              Ansible (Infrastructure Automation)              ||
|   +--------------------------------------------------------------+|
+------------------------------------------------------------------+
```

## Quick Start (After VM Restart)

```bash
# Start all services
cd ~/opt/devops-project/docker && docker compose -f docker-compose_AbayK.yml up -d && minikube start --driver=docker && sleep 30 && kubectl get pods

# Check services
docker ps && kubectl get pods && kubectl get svc && sudo systemctl status jenkins
```

**Access URLs (VM IP: 192.168.0.42):**
- Jenkins: http://192.168.0.42:8081
- Todo App (Docker): http://192.168.0.42:8080
- Todo App (K8s): http://192.168.0.42:30080

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
│   ├── Dockerfile_AbayK         # Multi-stage Dockerfile (ARM64)
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
│   └── roles/                   # Ansible roles
├── scripts/                      # Setup scripts
│   ├── setup_vm_AbayK.sh        # VM setup script
│   ├── install_docker_AbayK.sh  # Docker installation
│   └── install_all_AbayK.sh     # Complete stack installation
├── Jenkinsfile_AbayK            # Jenkins pipeline
└── README.md                    # This file
```

## Complete Setup Guide

### Part 0: VM Setup (UTM + Ubuntu Server)

1. **Create VM in UTM:**
   - Ubuntu Server 24.04 ARM64
   - RAM: 4096 MB (minimum 2GB)
   - Disk: 20 GB
   - Network: Bridged

2. **Clone project:**
   ```bash
   git clone https://github.com/flakozz-rama/devops-finl.git ~/opt/devops-project
   cd ~/opt/devops-project
   ```

3. **Run complete installation:**
   ```bash
   chmod +x scripts/*.sh
   sudo ./scripts/install_all_AbayK.sh
   ```

   This installs: Docker, Ansible, Jenkins, kubectl, Minikube

4. **Fix Jenkins port (if 8080 is occupied):**
   ```bash
   sudo mkdir -p /etc/systemd/system/jenkins.service.d
   echo -e '[Service]\nEnvironment="JENKINS_PORT=8081"' | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
   sudo systemctl daemon-reload
   sudo systemctl restart jenkins
   ```

5. **Configure firewall:**
   ```bash
   sudo ufw allow ssh
   sudo ufw allow 8080/tcp
   sudo ufw allow 8081/tcp
   sudo ufw allow 30080/tcp
   sudo ufw enable
   ```

### Part 1: Docker Setup

```bash
# Build image
cd ~/opt/devops-project
docker build -t abayk/todo-app:1.0.0 -f docker/Dockerfile_AbayK .

# Run with Docker Compose
cd docker
cp .env.example .env
docker compose -f docker-compose_AbayK.yml up -d

# Verify
docker ps
curl http://localhost:8080/actuator/health
curl http://localhost:8080/api/todos
```

### Part 2: Kubernetes Setup

```bash
# Start Minikube
minikube start --driver=docker

# Load image to Minikube
minikube image load abayk/todo-app:1.0.0

# Deploy application
cd ~/opt/devops-project
kubectl apply -f k8s/

# Verify
kubectl get pods
kubectl get svc
kubectl get deployments
kubectl get hpa

# Access application
kubectl port-forward --address 0.0.0.0 svc/todo-app-service 30080:8080
```

### Part 3: Jenkins Setup

1. **Access Jenkins:** http://192.168.0.42:8081

2. **Get initial password:**
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. **Install plugins:** Pipeline, Git, Docker Pipeline

4. **Create Pipeline:**
   - New Item → `todo-app-pipeline` → Pipeline
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: `https://github.com/flakozz-rama/devops-finl.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile_AbayK`

## Demo Commands

### Docker Demo
```bash
# Show containers
docker ps

# Show images
docker images

# Show logs
docker logs todo-app

# Test API
curl http://localhost:8080/api/todos
curl -X POST http://localhost:8080/api/todos -H "Content-Type: application/json" -d '{"title":"Test Task","completed":false}'
```

### Kubernetes Demo
```bash
# Show all resources
kubectl get all

# Show pods
kubectl get pods -o wide

# Show services
kubectl get svc

# Show deployments
kubectl get deployments

# Show HPA
kubectl get hpa

# Show logs
kubectl logs -l app=todo-app

# Describe pod
kubectl describe pod -l app=todo-app

# Scale deployment
kubectl scale deployment/todo-app --replicas=3
kubectl get pods -w

# Rolling update
kubectl set image deployment/todo-app todo-app=abayk/todo-app:1.1.0
kubectl rollout status deployment/todo-app

# Rollback
kubectl rollout undo deployment/todo-app
```

### Ansible Demo
```bash
# Check syntax
ansible-playbook ansible/playbook_AbayK.yml --syntax-check

# Dry run
ansible-playbook -i ansible/inventory_AbayK.ini ansible/playbook_AbayK.yml --check

# Run playbook
ansible-playbook -i ansible/inventory_AbayK.ini ansible/playbook_AbayK.yml
```

## CI/CD Pipeline Stages

```
Checkout -> Build -> Test -> Docker Build -> Docker Push -> Deploy (K8s)
```

1. **Checkout** - Clone from Git
2. **Build** - `./gradlew clean build`
3. **Test** - `./gradlew test`
4. **Docker Build** - Build image
5. **Docker Push** - Push to registry
6. **Deploy** - Deploy to Kubernetes

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/todos` | Get all todos |
| GET | `/api/todos/{id}` | Get todo by ID |
| POST | `/api/todos` | Create new todo |
| PUT | `/api/todos/{id}` | Update todo |
| DELETE | `/api/todos/{id}` | Delete todo |
| GET | `/actuator/health` | Health check |

## Troubleshooting

### Jenkins not starting
```bash
sudo journalctl -xeu jenkins.service | tail -50
sudo systemctl reset-failed jenkins
sudo systemctl start jenkins
```

### Port 8080 occupied
```bash
sudo lsof -i :8080
# Change Jenkins to port 8081 (see Part 0, step 4)
```

### Minikube not enough memory
```bash
minikube delete
minikube start --driver=docker --memory=1800mb
```

### Disk space issues
```bash
df -h
docker system prune -af
sudo apt-get clean
```

### Expand LVM partition
```bash
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```

## Author
**AbayK** - DevOps Final Project
