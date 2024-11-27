# Current Time API Service

A containerized Flask REST API that provides current time information across different time zones, deployed on Azure Kubernetes Service (AKS) using Infrastructure as Code principles.

## Get Started

```bash
# Clone the repository
git clone https://github.com/yourusername/currenttime-api.git
cd currenttime-api

# Build the Docker image
docker build --platform linux/amd64 -t siddiqitaha/currenttime-flask-api:latest .
docker push siddiqitaha/currenttime-flask-api:latest

# Deploy to AKS using Terraform
terraform init
terraform plan
terraform apply
```

## Technology Stack

- **Backend**: Python Flask
- **Container**: Docker
- **Cloud**: Microsoft Azure
- **Orchestration**: Kubernetes (AKS)
- **IaC**: Terraform

## Project Structure

```
.
├── app.py              # Main Flask application
├── timezone.py         # Timezone mappings
├── requirements.txt    # Python dependencies
├── Dockerfile         # Container configuration
├── deployment.yaml    # Kubernetes deployment
└── main.tf           # Terraform configuration
```

## API Endpoints

### Get Current Time
```http
GET /
```
#### Response
```json
{
    "message": "Automate All The Things",
    "current_time": "2024-11-27 16:30:45"
}
```

### Get Regional Time
```http
GET /<region>
```
#### Response
```json
{
    "message": "Automate All The Things: Current time in Asia",
    "current_time": "2024-11-28 05:30:45"
}
```

## Docker Configuration

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 80
CMD ["python", "app.py"]
```

Build for AMD64 (AKS compatibility):
```bash
docker build --platform linux/amd64 -t siddiqitaha/currenttime-flask-api:latest .
```

## Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: currenttime-flask-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: currenttime-flask-api
  template:
    metadata:
      labels:
        app: currenttime-flask-api
    spec:
      containers:
      - name: currenttime-flask-api
        image: siddiqitaha/currenttime-flask-api:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: currenttime-flask-api-service
spec:
  type: LoadBalancer
  selector:
    app: currenttime-flask-api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

## Infrastructure (Terraform)

Key components:
- Azure Resource Group
- AKS Cluster
- Node Pool Configuration
- Kubernetes Deployment
- LoadBalancer Service

Deploy infrastructure:
```bash
terraform init
terraform plan
terraform apply
```

## Dependencies

### Python Packages
```
Flask
pytz
```

### Tools
- Azure CLI
- Terraform
- kubectl
- Docker

## Deployment

1. **Build and Push Container**:
   ```bash
   docker build --platform linux/amd64 -t siddiqitaha/currenttime-flask-api:latest .
   docker push siddiqitaha/currenttime-flask-api:latest
   ```

2. **Deploy Infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Verify Deployment**:
   ```bash
   kubectl get pods
   kubectl get services
   ```

## Monitoring

Check deployment status:
```bash
kubectl get deployments
kubectl describe deployment currenttime-flask-api
```

View pod logs:
```bash
kubectl logs -l app=currenttime-flask-api
```

## Troubleshooting

Common issues and solutions:

1. **ImagePullBackOff Error**:
   ```bash
   # Check pod status
   kubectl describe pod <pod-name>
   # Rebuild image for correct architecture
   docker build --platform linux/amd64 -t siddiqitaha/currenttime-flask-api:latest .
   ```

2. **Service Not Accessible**:
   ```bash
   # Check service status
   kubectl get services
   # Check service endpoints
   kubectl describe service currenttime-flask-api-service
   ```

## Future Improvements

- Add API documentation (Swagger/OpenAPI)
- Implement authentication
- Add caching layer
- Set up monitoring and alerting
- Implement CI/CD pipeline
- Add health checks
- Implement rate limiting

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
