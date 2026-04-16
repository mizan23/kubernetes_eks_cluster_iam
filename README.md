# 🚀 AWS EKS 3-Tier Application with Terraform, Helm & Monitoring

## 📌 Overview
This project provisions a **production-style Kubernetes (EKS) cluster on AWS** using Terraform and deploys a **3-tier application** with:

- Frontend (React)
- Backend (Node.js)
- Database (PostgreSQL)
- Monitoring (Prometheus + Grafana)
- Logging (Loki)
- Load Balancer (AWS ALB)
- Auto Scaling (Cluster Autoscaler)

---

## 🏗️ Architecture

```
User → ALB (Ingress) → Frontend → Backend → PostgreSQL
                          ↓
                   Monitoring Stack
```

---

## ⚙️ Technologies Used

- AWS EKS
- Terraform
- Helm
- Kubernetes
- Docker
- Prometheus & Grafana
- Loki
- AWS ALB Controller

---

## 🚀 Features

- ✅ Fully automated EKS cluster setup
- ✅ Infrastructure as Code (Terraform)
- ✅ Helm-based application deployment
- ✅ AWS Load Balancer integration
- ✅ Monitoring with Prometheus & Grafana
- ✅ Logging with Loki
- ✅ Cluster Autoscaling
- ✅ Role-Based Access Control (RBAC)

---

## 📂 Project Structure

```
.
├── 0-locals.tf
├── 1-providers.tf
├── 2-kubernetes-provider.tf
├── 3-igw.tf
├── 4-subnets.tf
├── 5-nat.tf
├── 6-routers.tf
├── 7-eks.tf
├── 9-nodes.tf
├── 12-helm-provider.tf
├── 15-alb-controller.tf
├── 16-app.tf
├── 17-monitoring.tf
├── 18-logging.tf
├── 19-cluster-autoscaler.tf
├── terraform.tfvars
```

---

## 🛠️ Setup Instructions

### 1️⃣ Clone Repository
```bash
git clone <your-repo-url>
cd kubernetes_eks_cluster_iam
```

---

### 2️⃣ Configure AWS CLI
```bash
aws configure
```

---

### 3️⃣ Create S3 Backend (for Terraform state)
```bash
aws s3api create-bucket \
  --bucket mizan-eks-tfstate-bucket \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```

---

### 4️⃣ Initialize Terraform
```bash
terraform init
```

---

### 5️⃣ Deploy Infrastructure
```bash
terraform apply
```

---

### 6️⃣ Configure kubectl
```bash
aws eks update-kubeconfig --region us-east-1 --name dev-eks-cluster
```

---

## 🔍 Verification

### Check Nodes
```bash
kubectl get nodes
```

### Check Pods
```bash
kubectl get pods -A
```

### Check Services
```bash
kubectl get svc
```

### Check Ingress
```bash
kubectl get ingress
```

---

## 🌐 Access Application

Open browser:

```
http://<ALB-DNS>
```

---

## 📊 Monitoring Access (Grafana)

```bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
```

Open:
```
http://localhost:3000
```

Default login:
```
admin / prom-operator
```

---

## 📈 Scaling Test

```bash
kubectl scale deployment frontend --replicas=5
```

---

## 🧹 Cleanup

```bash
terraform destroy
```

---

## ⚠️ Notes

- Ensure Docker images exist in Docker Hub
- Update `terraform.tfvars` for image tags
- Avoid deleting S3 backend before destroy

---

## 👨‍💻 Author

**Mizanur Rahman**

---

## ⭐ If you like this project

Give it a ⭐ on GitHub!
