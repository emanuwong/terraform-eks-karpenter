# 🚀 EKS + Karpenter: Spot & Graviton Autoscaling (Terraform)

This project automates the provisioning of a Kubernetes infrastructure on AWS using:

- **Amazon EKS** (latest version supported)
- **Karpenter** for dynamic autoscaling
- **Graviton (arm64)** and **x86 (amd64)** instance support
- **Spot instances** for optimized cost
- **Terraform** as the Infrastructure as Code tool

## 📁 Project Structure

- `main.tf` – Root Terraform configuration.
- `variables.tf` – Input variable definitions.
- `outputs.tf` – Output values from the deployment.
- `provider.tf` – AWS, Helm, Kubernetes, and Kubectl providers.
- `data.tf` – Data sources like EKS auth, ECR token, account identity.
- `environments/dev.tfvars` – Development environment configuration.
- `manifests/deployments/` – Example workloads:
  - `busybox-arm64.yaml`
  - `busybox-x86.yaml`
- `manifests/karpenter/` – Karpenter resource definitions:
  - `ec2-nodeclass.yaml` (x86)
  - `ec2-nodeclass-arm64.yaml`
  - `nodepool-x86.yaml`
  - `nodepool-arm64.yaml`
- `README.md` – Project documentation.

## 🧩 Features

- Dedicated **VPC** across 3 Availability Zones
- **EKS 1.33** with managed node group for bootstrapping
- **Karpenter** deployed via Helm with OIDC IAM integration
- **Two NodePools**:
  - `spot-arm64` → Graviton-based nodes
  - `spot-x86` → AL2023-only nodes
- Workload examples targeting each architecture
- Terraform environment separation (e.g. `dev.tfvars`)

## ⚙️ Requirements

- Terraform >= 1.5
- AWS credentials configured (via `aws configure` or environment variables)
- `kubectl`, `helm`, and AWS CLI installed
- `KUBECONFIG` is handled automatically by Terraform providers

## 🚀 Usage

Follow these steps to deploy the infrastructure using Terraform.

---

### 1. Initialize Terraform

Initialize the working directory and download the required providers and modules:

``` bash

terraform init

```

---

### 2. Configure Your Environment

This project uses `.tfvars` files to define the environment configuration.  
By default, you'll find a sample file at:

environments/dev.tfvars

You can edit it to adjust:

- Cluster name and version
- VPC CIDR and subnets
- Availability Zones
- Managed node groups
- Access entries, etc.

---

### 3. Apply Terraform

To deploy the infrastructure using the `dev` configuration:

``` bash
terraform apply -var-file="environments/dev.tfvars"

```

Terraform will provision:

- VPC
- EKS cluster
- IAM roles
- Karpenter via Helm
- NodeClasses and NodePools

---

### 4. Optional: Manage Multiple Environments

You can create new environment files like:

environments/staging.tfvars  
environments/prod.tfvars

And combine them with Terraform workspaces for better separation:

``` bash

terraform workspace new staging  
terraform workspace select staging  
terraform apply -var-file="environments/staging.tfvars"

```

This keeps the infrastructure state isolated between environments like `dev`, `staging`, and `prod`.


### 5. ✅ Validate the Deployment

After Terraform finishes, verify that the infrastructure is working:

---

1.**Configure `kubectl` to connect to the EKS cluster**

Run the following command (replace with your region and cluster name):

``` bash

aws eks update-kubeconfig --region us-east-1 --name eks-karpenter-demo

```

---

2.**Check that the cluster is up**

``` bash

kubectl get nodes  
kubectl get pods -A

```

---

3.**Verify Karpenter is installed**

``` bash
kubectl get pods -n karpenter  
kubectl get deployments -n karpenter

```

## 👨‍💻 Developer Guide: Deploying to x86 or ARM (Graviton) Nodes

Once the infrastructure is ready, as a developer you can deploy your applications to the Kubernetes cluster using standard Kubernetes YAML manifests.

If your application needs to run on a specific processor architecture—like **x86** or **Graviton (ARM64)**—you must include a few lines in your YAML file to tell the cluster **what kind of machine it should run on**.

This guide will show you **how to do that** using real examples.

---

### 🧲 Example: Deploying a Sample App on ARM64 (Graviton)

If you want your app to run on a Graviton-based Spot instance, you can use a sample like this:

File: `manifests/deployments/busybox-arm64.yaml`

This deployment uses:

- **An ARM-compatible container image**: `arm64v8/busybox`
- A `nodeSelector` to target ARM nodes

To deploy it:

kubectl apply -f manifests/deployments/busybox-arm64.yaml

---

### 🧲 Example: Deploying a Sample App on x86

If you want your app to run on traditional x86 machines:

File: `manifests/deployments/busybox-x86.yaml`

This deployment uses:

- A standard `busybox` image (x86)
- A `nodeSelector` to ensure it runs only on x86 machines

To deploy:

kubectl apply -f manifests/deployments/busybox-x86.yaml

---

### 🛠 How to Control Where Your Pod Runs

Kubernetes schedules your application ("pod") on a worker node in the cluster.  
To control **which kind of node** it runs on (x86 vs ARM), you need to **edit the YAML file** of your deployment and add **node selection rules** under the `spec:` section.

There are several ways to do this:

---

#### ✅ 1. nodeSelector (Simple and Recommended)

This is the easiest way to say “run this app only on ARM or x86”.

To run on ARM:

nodeSelector:  
    kubernetes.io/arch: arm64

To run on x86:

nodeSelector:  
    kubernetes.io/arch: amd64

Add this inside the `spec.template.spec` block in your `Deployment` YAML.

---

#### 🎯 2. nodeAffinity (Advanced Matching)

Use this if you need **more advanced logic** (e.g., multiple instance types or Spot-only).

Example:

affinity:  
    nodeAffinity:  
        requiredDuringSchedulingIgnoredDuringExecution:  
            nodeSelectorTerms:  
                - matchExpressions:  
                    - key: karpenter.k8s.aws/instance-category  
                      operator: In  
                      values: ["t", "c", "m"]

---

#### 🛡 3. tolerations (for nodes with taints)

This is used when a node is "tainted" and will **only accept pods** with a matching `toleration`.

tolerations:  
    - key: "dedicated"  
      operator: "Equal"  
      value: "arm64"  
      effect: "NoSchedule"

> 💡 This must match taints that are defined in the cluster when Karpenter creates certain node groups.

---

### 🔍 How to Check Where Your Pod Landed

After deploying your app, you can see on which node it’s running:

kubectl get pods -n apps -o wide

To get detailed information about the node:

kubectl describe node <node-name>

Look for:

- The architecture (`amd64` or `arm64`)  
- Instance type and capacity type (Spot, etc.)  
- Any labels that were used to schedule the pod

---

### 📚 Want to Learn More?

Kubernetes Docs — Assigning Pods to Nodes:  
<https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/>
