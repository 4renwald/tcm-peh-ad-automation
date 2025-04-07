<div align="center">
  <img width="175px" src=".assets/img/PEH-Course-Logo-Transparent.png" />
  <h1>TCM PEH AD Automation</h1>
  <br/>
  <p><i>Automate the setup of TCM Security’s PEH (Practical Ethical Hacking) Active Directory lab.</i></p>
</div>

---

## Setup Process

Follow the steps below in order to configure your environment and run the script successfully.

---

## Step 1: Check Requirements

Before running the automation, ensure you have the following:

- **Three Virtual Machines (VMs)** created via **VMware** or **VirtualBox**:
  - 🖥️ **1x Server (Domain Controller)**
  - 💻 **2x Workstations**

---

## Step 2: VM Setup

### 2.1 Server (Domain Controller)

- **OS**: [Windows Server 2022](https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso)  

> [!IMPORTANT]  
> Choose the **Standard Edition with Desktop Experience** during installation.

### 2.2 Workstations

- **OS**: [Windows 10 Enterprise](https://www.microsoft.com/en-us/evalcenter/download-windows-10-enterprise)

**Local Administrator Accounts:**

- **Host 1:**
  - **Username**: `frankcastle`
  - **Password**: `Password1`
  
- **Host 2:**
  - **Username**: `peterparker`
  - **Password**: `Password1`
---

## Step 3: Enable WinRM for Ansible

For Ansible to communicate with the Windows VMs, you need to enable WinRM on each one.

> [!IMPORTANT]  
> Run the `Configure_WinRM.ps1` script on **each VM** to enable WinRM for Ansible.

---

## Step 4: Prepare Your Environment

### 4.1 Script Requirements

- This automation script runs on **Linux**.
- **Windows users:** Use **WSL (Windows Subsystem for Linux)** to run the script.
- **Network:** Ensure the **IP addresses of your VMs are reachable** from the host running the script.

### 4.2 Configure IP Addresses

Before executing the script, **edit the `ip_addresses.sh` file** and input the IP addresses of your VMs.

---

## Step 5: Run the Script

With the VMs configured and the IP addresses set, execute these commands to launch the configuration:

```
git clone https://github.com/4renwald/tcm-peh-ad-automation.git
cd tcm-peh-ad-automation
chmod +x setup.sh
./setup.sh
```
> [!NOTE] 
> The entire process typically takes 5 to 10 minutes, depending on your system.
