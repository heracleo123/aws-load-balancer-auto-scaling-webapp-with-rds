# Quick Start Guide

**Complete deployment in 3 commands!**

## Step 1: Setup (First Time)

```bash
./scripts/setup.sh
```

**Smart setup flow:**

1. ✅ Already configured? Shows current SSH key → keep or change
2. 🔑 If new: Scans `~/.ssh/` → select existing or create new
3. 🔐 Shows current password → change if needed
4. 📝 Auto-creates secure `terraform.tfvars` (not committed to git)

**Duration:** 30 seconds (even faster if re-running!)

---

## Step 2: Deploy

```bash
./scripts/deploy.sh
```

**What happens automatically:**

- ✅ Creates VPC with 6 subnets
- ✅ Launches Application Load Balancer
- ✅ Starts Auto Scaling Group (2 instances)
- ✅ Creates RDS MySQL database
- ✅ Sets up security groups
- ✅ Creates database table
- ✅ Instances become healthy

**Duration:** ~10 minutes

---

## Step 3: Access

```bash
./scripts/info.sh
```

Copy the `load_balancer_url` and open in browser!

---

## 🎉 You're Done!

**Try these:**

- Refresh page → see different Instance IDs (load balancing!)
- Add data via form → saved to MySQL
- Check AWS Console → see all resources

## 🧹 Clean Up

```bash
./scripts/destroy.sh
```

Removes everything from AWS.

---

## 📊 Architecture

```
Internet → Load Balancer → [Web Server 1, Web Server 2] → Database
          ↑ Public      ↑ Private App Subnets    ↑ Private DB
```

- **2 Availability Zones** for high availability
- **Auto Scaling:** 2-6 instances based on CPU
- **Secure:** Private subnets, security group chaining
- **Bastion host** for SSH access

## 💡 Tips

- **Re-running setup?** It remembers your config - just confirm to keep it!
- First deployment takes ~10 minutes
- Setup script auto-detects SSH keys from config and `~/.ssh/`
- Database table created automatically
- All instances become healthy automatically
- `terraform.tfvars` keeps your secrets safe (excluded from git)
- See README.md for testing procedures

## ❓ Need Help?

**Instances unhealthy?**
→ Wait 2-3 minutes for initialization

**Can't SSH?**
→ Use bastion host from `info.sh` output

**Want to redeploy?**
→ Just run `deploy.sh` again!
