# How to Use the Nether-Grasp Installer

## 🎯 Quick Start

### For End Users:

1. **Download this repository** from GitHub:
   ```
   https://github.com/floppadopa/install-nethergrasp
   ```

2. **Double-click `Click-me.bat`** ✨

3. **Follow the prompts**:
   - Enter the full path where you want to create your project
   - Example: `C:\Users\YourName\Projects`
   - The installer will create a T3 App in that location

4. **Answer T3 App questions** (recommended settings):
   - Language: TypeScript
   - Styling: Tailwind CSS (Yes)
   - tRPC: No
   - Authentication: None
   - Database ORM: Prisma
   - App Router: Yes
   - Database: PostgreSQL
   - Git: Yes
   - npm install: Yes
   - Import alias: ~/

5. **Provide environment variables** when prompted

6. **Done!** Your project is ready with Nether-Grasp installed

## 📋 What You'll Need

Before running the installer, make sure you have:

- ✅ Windows operating system
- ✅ Node.js (v18 or higher) installed
- ✅ Git installed
- ✅ PostgreSQL database (local or hosted)
- ✅ GitHub account (for pushing code)

## 🔧 Installation Methods

### Method 1: Batch Launcher (Easiest)
Double-click `Click-me.bat` ✨

### Method 2: PowerShell Launcher
```powershell
.\installation-script-2.ps1
```

### Method 3: Direct Script
```powershell
cd C:\where\you\want\project
C:\path\to\installer\installation-script.ps1
```

## 🚀 After Installation

Navigate to your project and start the dev servers:

```bash
cd your-project-name
npm run dev
```

Then open: `http://localhost:3000/nether-grasp`

## 🔄 Re-Installing

To re-install Nether-Grasp into an existing project:

```powershell
cd your-existing-project
C:\path\to\installer\installation-script.ps1 -ReInstall
```

## 🛠️ Troubleshooting

### PowerShell Execution Policy Error

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Can't Find Click-me.bat

Make sure you've downloaded the entire repository, not just individual files.

### Target Directory Doesn't Exist

Create the directory first:
```powershell
mkdir C:\Users\YourName\Projects
```

## 📦 What Gets Installed

- ✅ Complete T3 App setup
- ✅ Nether-Grasp UI components
- ✅ API routes for task management
- ✅ WebSocket bridge server
- ✅ Prisma database schema
- ✅ Environment configuration
- ✅ Git repository with GitHub push

## 🔗 GitHub Repository

All code is now available at:
**https://github.com/floppadopa/install-nethergrasp**

You can:
- Clone it: `git clone https://github.com/floppadopa/install-nethergrasp.git`
- Download as ZIP from GitHub
- Share the link with others

## 💡 Tips

1. **Use absolute paths**: `C:\Users\YourName\Projects` not relative paths
2. **Have your database URL ready**: You'll be prompted for it
3. **Keep this installer folder**: You might need to re-install later
4. **Check README.md**: For detailed information

## 🎓 For Developers

If you want to modify the installer:

1. Edit `installation-script-2.ps1` (launcher) or `installation-script.ps1` (main installer)
2. Test your changes:
   ```powershell
   .\Click-me.bat
   ```
3. No compilation needed - it's all plain PowerShell!

## ❓ Need Help?

- Check the full **README.md** for detailed documentation
- Review the **installation-script.ps1** script
- Open an issue on GitHub

---

**Happy coding with Nether-Grasp! 🚀**

