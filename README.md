# AWS Multi-Tier Web Application

Automated Terraform infrastructure for a highly available, auto-scaling web application on AWS. Perfect for learning cloud architecture! Note: This project is for educational purposes and may incur AWS costs. Remember to use cloud9 or set up your AWS CLI with appropriate credentials.

## ⚡ 3 Steps to Deploy

### Step 1: Setup (First Time Only)

```bash
./scripts/setup.sh
```

**What it does:**

- 🔍 Checks for existing configuration in `terraform.tfvars`
- 🔑 If found, asks if you want to keep it (quick re-run!)
- 🗂️ Otherwise, scans `~/.ssh/` for existing SSH keys
- ⚙️ Auto-creates secure `terraform.tfvars` with your selections
- 🔐 Shows current password, optional to change it

### 🔒 Security (Automatic!)

**The `setup.sh` script automatically creates a secure `terraform.tfvars` file:**

```hcl
# This file is auto-created by setup.sh and is in .gitignore
ssh_public_key = "your-selected-key"
db_password = "YourSecurePassword123!"  # Or your custom password
```

**Why this is secure:**

- ✅ `terraform.tfvars` is in `.gitignore` - never committed to git
- ✅ Passwords and keys stay on your machine only
- ✅ Values override defaults in `variables.tf`
- ✅ No manual file editing required!

**Smart features:**

- 📋 Re-running `setup.sh`? It shows your current config and asks if you want to keep it
- 🔐 Current password displayed - change only if needed
- 🔑 Auto-detects SSH keys from both config and `~/.ssh/`

> 💡 **Tip:** Just run `./scripts/setup.sh` and answer the prompts - it handles all security best practices automatically!

### Step 2: Deploy

```bash
./scripts/deploy.sh
```

**What happens:**

- 🏗️ Creates VPC, subnets, load balancer, auto-scaling group
- 💾 Launches RDS MySQL database
- 🖥️ Starts 2 web servers automatically
- ✅ Instances become healthy automatically
- 🌐 Shows you the website URL

**Deploy time:** ~10 minutes

### Step 3: Open Your Website

```bash
./scripts/info.sh
```

Copy the `load_balancer_url` and open it in your browser!

**Refresh the page** → See different server IDs (load balancing in action!)

## 🎓 What You'll Learn

This project demonstrates:

- ✅ **Multi-tier architecture** (web, app, database layers)
- ✅ **High availability** (2 availability zones)
- ✅ **Auto scaling** (2-6 instances based on CPU)
- ✅ **Load balancing** (distributes traffic)
- ✅ **Network security** (public/private subnets, security groups)
- ✅ **Infrastructure as Code** (Terraform)

## 📋 What Gets Created

```
Internet
    ↓
Application Load Balancer (public)
    ↓
Auto Scaling Group (private subnets)
├── Web Server 1 (AZ-A)
├── Web Server 2 (AZ-B)
└── ... up to 6 servers
    ↓
RDS MySQL Database (private subnets)
```

**Components:**

- 1 VPC with 6 subnets across 2 availability zones
- 1 Internet Gateway + 2 NAT Gateways
- 1 Application Load Balancer
- 2-6 EC2 instances (auto-scaling)
- 1 RDS MySQL database
- 1 Bastion host for SSH access
- Security groups with proper chaining

## 🧪 Test It Out

### Test 1: Load Balancing

Refresh your browser multiple times → different `Instance ID` appears each time

### Test 2: Database

Add users through the web form → data saved to MySQL → visible from all servers

### Test 3: Auto Scaling

```bash
# SSH to any instance
ssh -i ~/.ssh/your-key ec2-user@instance-ip

# Run CPU stress test
while true; do true; done
```

Watch in AWS Console: Instances scale from 2 → 6!

### Test 4: High Availability

Terminate all instances in AWS Console → Auto Scaling Group automatically launches 2 new ones!

## 🗂️ Project Structure

```
cloudfinal/
├── scripts/
│   ├── setup.sh ........... One-time setup (SSH key)
│   ├── deploy.sh .......... Deploy everything
│   ├── info.sh ............ Show URLs and IPs
│   └── destroy.sh ......... Clean up all resources
├── network/ ............... VPC, subnets, gateways
├── security/ .............. Security groups
├── alb/ ................... Load balancer
├── web/ ................... EC2 launch template
├── asg/ ................... Auto scaling configuration
└── database/ .............. RDS MySQL
```

## 🧹 Clean Up

```bash
./scripts/destroy.sh
```

Removes all AWS resources to avoid charges.

## 📚 Additional Resources

- `QUICKSTART.md` - Simplified step-by-step guide
- AWS Console - See all resources visually

## ❓ Troubleshooting

**Problem:** Target group shows unhealthy
**Solution:** Wait 2-3 minutes for database table creation

**Problem:** Can't connect to instances
**Solution:** Use bastion host: `ssh -i ~/.ssh/your-key ec2-user@bastion-ip`

**Problem:** Website not loading
**Solution:** Check security groups allow HTTP (port 80)

## 💡 Pro Tips

- **First deployment?** Takes ~10 minutes
- **Subsequent deploys?** Use `./scripts/deploy.sh` anytime
- **Cost saving:** Run `./scripts/destroy.sh` when not using it
- **SSH key:** Setup script auto-detects existing keys
- **Database:** Table created automatically, no manual steps!

## 📚 Additional Documentation

- `QUICKSTART.md` - Simplified deployment guide
