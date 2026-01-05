Here’s a refreshed, student-friendly version of the instructions with the requested additions and a clearer, more guided flow.

---

# 🚀 AWS Multi-Tier Web App with Terraform & RDS

A complete, automated infrastructure project that deploys a **scalable, highly available web application** on AWS using Terraform.  
Perfect for learning real-world cloud architecture, infrastructure as code, and AWS services in action.

> ⚠️ **Note:** This is for educational purposes. AWS resources may incur costs—remember to clean up when done!

---

## ✅ **Before You Begin**

1. **Install Terraform** – Download from [terraform.io](https://www.terraform.io/downloads) and install.
2. **Set Up AWS CLI** – If you haven’t already, configure it with:
   ```bash
   aws configure
   ```
   You’ll need your **AWS Access Key ID**, **Secret Access Key**, and preferred region.
3. **Clone or download** this project to your computer.

---

## 🧭 **Quick Start – Only 3 Steps!**

### **Step 1: One-Time Setup**
Run this once to set up your SSH key and database password securely:
```bash
./scripts/setup.sh
```
**What it does:**
- Scans for existing SSH keys in `~/.ssh/`
- Prompts you to pick or create one
- Generates a secure password for the database (you can change it if you want)
- Creates a **terraform.tfvars** file with your settings (this file is never uploaded to GitHub)

---

### **Step 2: Deploy Everything**
This will build the entire AWS infrastructure—VPC, subnets, load balancer, auto-scaling web servers, and an RDS database.
```bash
./scripts/deploy.sh
```
**Takes about 10 minutes.** Grab a coffee ☕ and watch Terraform do the magic!

---

### **Step 3: Open Your Website**
Once deployment finishes, get your website URL:
```bash
./scripts/info.sh
```
Copy the **load_balancer_url** and open it in your browser.  
**Refresh the page** to see it balance traffic between different servers!

---

## 🛡️ **Security Built-In**
- Your `terraform.tfvars` file is **automatically added to .gitignore**.
- Passwords and keys stay only on your machine.
- The setup script remembers your settings if you run it again.

---

## 🧠 **What You'll Learn & Build**
This project creates a **production-like multi-tier architecture**:

```
Internet → Load Balancer → Auto-Scaling Web Servers → MySQL Database
```

**Concepts covered:**
- Infrastructure as Code with Terraform
- Multi-AZ high availability
- Auto-scaling and load balancing
- Public/private subnets and security groups
- RDS managed database

---

## 🧪 **Test What You Built**
Try these after deployment:

1. **Load Balancing Test** – Refresh your browser → see different server IDs.
2. **Database Test** – Submit the web form → data saves to MySQL.
3. **Auto-Scaling Test** – SSH into a server and stress the CPU; watch new instances launch.
4. **High Availability Test** – Terminate an instance in AWS Console → Auto Scaling replaces it automatically.

---

## 🗑️ **Clean Up (IMPORTANT!)**
To avoid AWS charges, destroy all resources when you’re done:
```bash
./scripts/destroy.sh
```

---

## 📂 **Project Structure**
```
scripts/          # One-command scripts for setup, deploy, info, destroy
network/          # VPC, subnets, NAT gateways
security/         # Security groups
alb/              # Load balancer
web/              # EC2 launch template & user data
asg/              # Auto Scaling configuration
database/         # RDS MySQL setup
```

---

## ❓ **Need Help?**
- **Website not loading?** Wait 2–3 minutes for the database setup to complete.
- **Can’t SSH?** Use the Bastion host IP shown by `./scripts/info.sh`.
- **First deployment taking long?** That’s normal—Terraform is provisioning many resources.

---

## 📘 **Learn More**
Check out `QUICKSTART.md` for an even simpler walkthrough, or explore the `.tf` files to understand how each component is built.

---

**Happy building!** 👩‍💻👨‍💻  
*Once deployed, you’ll have a real, scalable web app running on AWS—great for your portfolio and cloud learning journey.*
