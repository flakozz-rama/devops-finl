# DevOps Final Project - ToDo Application
**Author:** AbayK

---

## Содержание
1. [Описание проекта](#описание-проекта)
2. [Архитектура](#архитектура)
3. [Технологии](#технологии)
4. [Структура проекта](#структура-проекта)
5. [Быстрый старт](#быстрый-старт)
6. [Полная установка](#полная-установка)
7. [Docker](#docker)
8. [Kubernetes](#kubernetes)
9. [Jenkins CI/CD](#jenkins-cicd)
10. [Ansible](#ansible)
11. [API приложения](#api-приложения)
12. [Команды для демонстрации](#команды-для-демонстрации)
13. [Устранение неполадок](#устранение-неполадок)

---

## Описание проекта

Это DevOps проект, демонстрирующий полный цикл CI/CD для Spring Boot приложения ToDo List.

**Что делает приложение:**
- REST API для управления задачами (создание, чтение, обновление, удаление)
- Хранение данных в PostgreSQL
- Health check endpoint для мониторинга

**Что демонстрирует проект:**
- Контейнеризация с Docker
- Оркестрация с Kubernetes
- CI/CD пайплайн с Jenkins
- Автоматизация инфраструктуры с Ansible

---

## Архитектура

```
+------------------------------------------------------------------+
|                    DevOps Pipeline Architecture                    |
+------------------------------------------------------------------+
|                                                                    |
|   Developer -> Git -> Jenkins -> Docker -> Kubernetes              |
|                                                                    |
|   +--------+    +----------+    +--------+    +----------------+  |
|   |  Git   |--->| Jenkins  |--->| Docker |--->|  Kubernetes    |  |
|   | (SCM)  |    | (CI/CD)  |    | Image  |    | (Deployment)   |  |
|   +--------+    +----------+    +--------+    +----------------+  |
|                      |                               |             |
|                      v                               v             |
|               +------------+                 +-------------+       |
|               | 1.Checkout |                 | ToDo App    |       |
|               | 2.Build    |                 | (2 replicas)|       |
|               | 3.Test     |                 +-------------+       |
|               | 4.Docker   |                        |              |
|               | 5.Deploy   |                        v              |
|               +------------+                 +-------------+       |
|                                              | PostgreSQL  |       |
|                                              +-------------+       |
+------------------------------------------------------------------+
```

### Как это работает:

1. **Developer** пушит код в **Git**
2. **Jenkins** автоматически запускает пайплайн:
   - Клонирует репозиторий
   - Собирает приложение (Gradle)
   - Запускает тесты
   - Собирает Docker образ
   - Деплоит в Kubernetes
3. **Kubernetes** управляет контейнерами:
   - Поддерживает 2 реплики приложения
   - Автоматически перезапускает упавшие поды
   - Балансирует нагрузку между подами

---

## Технологии

| Компонент | Технология | Версия | Описание |
|-----------|------------|--------|----------|
| Приложение | Spring Boot | 3.2.x | Java REST API |
| База данных | PostgreSQL | 15 | Хранение данных |
| Контейнеризация | Docker | 29.x | Упаковка приложения |
| Оркестрация | Kubernetes | 1.34 | Управление контейнерами |
| K8s локально | Minikube | 1.37 | Локальный кластер |
| CI/CD | Jenkins | 2.528 | Автоматизация |
| IaC | Ansible | 9.x | Автоматизация инфраструктуры |
| VM | Ubuntu Server | 24.04 | Операционная система |
| Виртуализация | UTM | - | VM на Mac (ARM64) |

---

## Структура проекта

```
devops-final/
├── app/                              # Spring Boot приложение
│   ├── src/main/java/               # Исходный код
│   │   └── com/devops/todo/
│   │       ├── TodoApplication.java # Точка входа
│   │       ├── controller/          # REST контроллеры
│   │       ├── model/               # Модели данных
│   │       ├── repository/          # JPA репозитории
│   │       ├── service/             # Бизнес-логика
│   │       └── exception/           # Обработка ошибок
│   ├── src/main/resources/
│   │   └── application.yml          # Конфигурация
│   ├── build.gradle                 # Зависимости Gradle
│   └── gradlew                      # Gradle wrapper
│
├── docker/                           # Docker конфигурация
│   ├── Dockerfile_AbayK             # Multi-stage сборка
│   ├── docker-compose_AbayK.yml     # Compose для локального запуска
│   ├── .env                         # Переменные окружения
│   └── init-db.sql                  # Инициализация БД
│
├── k8s/                              # Kubernetes манифесты
│   ├── configmap_AbayK.yaml         # Конфигурация приложения
│   ├── secret_AbayK.yaml            # Секреты (пароли)
│   ├── pvc_AbayK.yaml               # Persistent Volume для БД
│   ├── deployment_AbayK.yaml        # Деплойменты (app + postgres)
│   ├── service_AbayK.yaml           # Сервисы (networking)
│   └── hpa_AbayK.yaml               # Автоскейлинг
│
├── ansible/                          # Ansible автоматизация
│   ├── inventory_AbayK.ini          # Список серверов
│   ├── playbook_AbayK.yml           # Главный плейбук
│   ├── deploy_k8s_AbayK.yml         # Деплой в K8s
│   └── roles/                       # Роли (docker, jenkins, k8s)
│
├── scripts/                          # Bash скрипты
│   ├── setup_vm_AbayK.sh            # Настройка VM
│   ├── install_docker_AbayK.sh      # Установка Docker
│   └── install_all_AbayK.sh         # Установка всего стека
│
├── Jenkinsfile_AbayK                 # Полный пайплайн
├── Jenkinsfile_Demo                  # Упрощённый пайплайн для демо
└── README.md                         # Этот файл
```

---

## Быстрый старт

### После перезапуска VM выполни:

```bash
# 1. Запустить Docker контейнеры
cd ~/opt/devops-project/docker
docker compose -f docker-compose_AbayK.yml up -d

# 2. Запустить Minikube
minikube start --driver=docker

# 3. Проверить Jenkins (запускается автоматически)
sudo systemctl status jenkins

# 4. Проверить всё
docker ps
kubectl get pods
kubectl get svc
```

### Доступ к сервисам:

| Сервис | URL | Логин/Пароль |
|--------|-----|--------------|
| Jenkins | http://<VM_IP>:8081 | admin / (см. ниже) |
| Todo App (Docker) | http://<VM_IP>:8080 | - |
| Todo App (K8s) | http://<VM_IP>:30080 | - |

**Получить IP VM:**
```bash
hostname -I | awk '{print $1}'
```

**Получить пароль Jenkins:**
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## Полная установка

### Шаг 1: Создание VM в UTM

1. Скачай Ubuntu Server 24.04 ARM64
2. В UTM создай новую VM:
   - **RAM:** 4096 MB (минимум 2GB)
   - **Disk:** 20 GB
   - **Network:** Bridged (для доступа с Mac)
3. Установи Ubuntu Server
4. Настрой SSH доступ

### Шаг 2: Клонирование проекта

```bash
# На VM
git clone https://github.com/flakozz-rama/devops-finl.git ~/opt/devops-project
cd ~/opt/devops-project
```

### Шаг 3: Установка всего стека

```bash
chmod +x scripts/*.sh
sudo ./scripts/install_all_AbayK.sh
```

**Скрипт установит:**
- Docker + Docker Compose
- Ansible
- Jenkins
- kubectl
- Minikube

### Шаг 4: Настройка Jenkins порта

Jenkins по умолчанию на порту 8080, но там уже Docker приложение:

```bash
sudo mkdir -p /etc/systemd/system/jenkins.service.d
echo -e '[Service]\nEnvironment="JENKINS_PORT=8081"' | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart jenkins
```

### Шаг 5: Настройка Firewall

```bash
sudo ufw allow ssh
sudo ufw allow 8080/tcp   # Todo App
sudo ufw allow 8081/tcp   # Jenkins
sudo ufw allow 30080/tcp  # K8s NodePort
sudo ufw enable
```

### Шаг 6: Добавление Jenkins в группу Docker

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

---

## Docker

### Что такое Docker?
Docker - это платформа для контейнеризации приложений. Контейнер содержит приложение и все его зависимости.

### Dockerfile (docker/Dockerfile_AbayK)

```dockerfile
# Этап 1: Сборка (builder)
FROM gradle:8.5-jdk17 AS builder
WORKDIR /app
COPY app/ .
RUN ./gradlew clean build -x test

# Этап 2: Runtime (минимальный образ)
FROM eclipse-temurin:17-jre
COPY --from=builder /app/build/libs/todo-app.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Почему multi-stage:**
- Финальный образ меньше (только JRE, без Gradle)
- Безопаснее (нет исходников и build tools)

### Команды Docker

```bash
# Сборка образа
docker build -t abayk/todo-app:1.0.0 -f docker/Dockerfile_AbayK .

# Запуск с Docker Compose
cd docker
docker compose -f docker-compose_AbayK.yml up -d

# Просмотр контейнеров
docker ps

# Логи
docker logs todo-app
docker logs todo-postgres

# Остановка
docker compose -f docker-compose_AbayK.yml down

# Очистка
docker system prune -af
```

### Docker Compose (docker/docker-compose_AbayK.yml)

```yaml
services:
  todo-app:
    build: ...
    ports:
      - "8080:8080"      # Маппинг портов host:container
    depends_on:
      - todo-postgres    # Ждать запуска БД
    environment:
      - SPRING_DATASOURCE_URL=jdbc:postgresql://todo-postgres:5432/tododb

  todo-postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=tododb
      - POSTGRES_USER=todouser
      - POSTGRES_PASSWORD=todopass
    volumes:
      - postgres-data:/var/lib/postgresql/data  # Persistent storage
```

---

## Kubernetes

### Что такое Kubernetes?
Kubernetes (K8s) - система оркестрации контейнеров. Автоматически управляет развёртыванием, масштабированием и восстановлением приложений.

### Основные концепции

| Концепция | Описание |
|-----------|----------|
| **Pod** | Минимальная единица, один или несколько контейнеров |
| **Deployment** | Управляет репликами подов, обновлениями |
| **Service** | Сетевой доступ к подам (load balancing) |
| **ConfigMap** | Конфигурация (не секретная) |
| **Secret** | Секреты (пароли, ключи) |
| **PVC** | Persistent Volume Claim - постоянное хранилище |
| **HPA** | Horizontal Pod Autoscaler - автомасштабирование |

### Kubernetes манифесты

**ConfigMap (k8s/configmap_AbayK.yaml):**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: todo-app-config
data:
  SPRING_PROFILES_ACTIVE: "kubernetes"
  SERVER_PORT: "8080"
```

**Deployment (k8s/deployment_AbayK.yaml):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-app
spec:
  replicas: 2                    # 2 копии приложения
  selector:
    matchLabels:
      app: todo-app
  template:
    spec:
      containers:
      - name: todo-app
        image: abayk/todo-app:1.0.0
        ports:
        - containerPort: 8080
        envFrom:
        - configMapRef:
            name: todo-app-config
```

**Service (k8s/service_AbayK.yaml):**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: todo-app-service
spec:
  type: NodePort              # Доступ извне кластера
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080           # Внешний порт
  selector:
    app: todo-app
```

### Команды Kubernetes

```bash
# Запуск Minikube
minikube start --driver=docker

# Загрузка образа в Minikube
minikube image load abayk/todo-app:1.0.0

# Применение манифестов
kubectl apply -f k8s/

# Просмотр ресурсов
kubectl get all
kubectl get pods
kubectl get svc
kubectl get deployments
kubectl get hpa

# Детальная информация
kubectl describe pod <pod-name>
kubectl describe deployment todo-app

# Логи
kubectl logs -l app=todo-app
kubectl logs <pod-name>

# Масштабирование
kubectl scale deployment/todo-app --replicas=3

# Rolling Update (обновление без downtime)
kubectl set image deployment/todo-app todo-app=abayk/todo-app:1.1.0
kubectl rollout status deployment/todo-app

# Откат
kubectl rollout undo deployment/todo-app
kubectl rollout history deployment/todo-app

# Доступ к приложению
kubectl port-forward --address 0.0.0.0 svc/todo-app-service 30080:8080

# Удаление
kubectl delete -f k8s/
```

---

## Jenkins CI/CD

### Что такое Jenkins?
Jenkins - сервер автоматизации для CI/CD (Continuous Integration / Continuous Deployment).

### Настройка Jenkins

1. **Открой:** http://<VM_IP>:8081

2. **Первый вход:**
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. **Установи плагины:**
   - Pipeline
   - Git
   - Docker Pipeline

4. **Создай Pipeline:**
   - New Item → `todo-app-demo` → Pipeline
   - Pipeline → Definition: `Pipeline script from SCM`
   - SCM: Git
   - URL: `https://github.com/flakozz-rama/devops-finl.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile_Demo`
   - Save → Build Now

### Jenkinsfile_Demo (упрощённый)

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                dir('app') {
                    sh './gradlew clean build -x test'
                }
            }
        }

        stage('Test') {
            steps {
                dir('app') {
                    sh './gradlew test'
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t abayk/todo-app:${BUILD_NUMBER} -f docker/Dockerfile_AbayK .'
            }
        }

        stage('Deploy to K8s') {
            steps {
                sh 'kubectl apply -f k8s/'
            }
        }
    }
}
```

### Этапы пайплайна

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│ Checkout │ → │  Build   │ → │   Test   │ → │  Docker  │ → │  Deploy  │
│   (Git)  │   │ (Gradle) │   │ (JUnit)  │   │  Build   │   │  (K8s)   │
└──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
```

---

## Ansible

### Что такое Ansible?
Ansible - инструмент автоматизации инфраструктуры. Позволяет автоматизировать настройку серверов.

### Inventory (ansible/inventory_AbayK.ini)

```ini
[local]
localhost ansible_connection=local

[devops_servers]
# server1 ansible_host=192.168.1.100 ansible_user=devops
```

### Playbook (ansible/playbook_AbayK.yml)

```yaml
- name: Setup DevOps Server
  hosts: local
  become: yes
  roles:
    - common      # Базовые пакеты
    - docker      # Docker installation
    - jenkins     # Jenkins installation
    - kubernetes  # Minikube + kubectl
```

### Команды Ansible

```bash
# Проверка синтаксиса
ansible-playbook ansible/playbook_AbayK.yml --syntax-check

# Dry run (без изменений)
ansible-playbook -i ansible/inventory_AbayK.ini ansible/playbook_AbayK.yml --check

# Запуск
ansible-playbook -i ansible/inventory_AbayK.ini ansible/playbook_AbayK.yml

# Деплой в K8s
ansible-playbook -i ansible/inventory_AbayK.ini ansible/deploy_k8s_AbayK.yml
```

---

## API приложения

### Endpoints

| Method | URL | Описание | Пример |
|--------|-----|----------|--------|
| GET | `/api/todos` | Получить все задачи | - |
| GET | `/api/todos/{id}` | Получить задачу по ID | `/api/todos/1` |
| POST | `/api/todos` | Создать задачу | JSON body |
| PUT | `/api/todos/{id}` | Обновить задачу | JSON body |
| DELETE | `/api/todos/{id}` | Удалить задачу | - |
| GET | `/actuator/health` | Health check | - |

### Примеры запросов

```bash
# Health check
curl http://localhost:8080/actuator/health

# Получить все задачи
curl http://localhost:8080/api/todos

# Создать задачу
curl -X POST http://localhost:8080/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Выполнить проект","completed":false}'

# Обновить задачу
curl -X PUT http://localhost:8080/api/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Выполнить проект","completed":true}'

# Удалить задачу
curl -X DELETE http://localhost:8080/api/todos/1
```

---

## Команды для демонстрации

### Полный сценарий демо

```bash
# 1. Показать VM
hostname -I
uname -a

# 2. Docker
docker ps
docker images
curl http://localhost:8080/actuator/health

# 3. Kubernetes
kubectl get nodes
kubectl get all
kubectl get pods -o wide

# 4. Создать задачу через API
curl -X POST http://localhost:8080/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Demo Task","completed":false}'

# 5. Масштабирование K8s
kubectl scale deployment/todo-app --replicas=3
kubectl get pods -w

# 6. Jenkins - показать в браузере
# http://<VM_IP>:8081

# 7. Rolling Update
kubectl set image deployment/todo-app todo-app=abayk/todo-app:1.1.0
kubectl rollout status deployment/todo-app

# 8. Rollback
kubectl rollout undo deployment/todo-app
```

---

## Устранение неполадок

### Jenkins не запускается

```bash
# Проверить статус
sudo systemctl status jenkins

# Посмотреть логи
sudo journalctl -xeu jenkins.service | tail -50

# Перезапустить
sudo systemctl reset-failed jenkins
sudo systemctl start jenkins
```

### Minikube не работает

```bash
# Проверить статус
minikube status

# Перезапустить
minikube stop
minikube start --driver=docker

# Полный сброс
minikube delete
minikube start --driver=docker
```

### Порт 8080 занят

```bash
# Проверить кто занял порт
sudo lsof -i :8080

# Jenkins перенести на 8081 (см. выше)
```

### Не хватает места на диске

```bash
# Проверить место
df -h

# Очистить Docker
docker system prune -af

# Очистить apt cache
sudo apt-get clean

# Расширить LVM раздел
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```

### kubectl не видит кластер

```bash
# "no route to host" - Minikube не запущен
minikube start --driver=docker

# Проверить контекст
kubectl config current-context
```

### Pods в статусе ImagePullBackOff

```bash
# Загрузить образ в Minikube
docker build -t abayk/todo-app:1.0.0 -f docker/Dockerfile_AbayK .
minikube image load abayk/todo-app:1.0.0

# Перезапустить поды
kubectl rollout restart deployment/todo-app
```

---

## Автор

**AbayK** - DevOps Final Project

**GitHub:** https://github.com/flakozz-rama/devops-finl
