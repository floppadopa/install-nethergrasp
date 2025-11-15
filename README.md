# Nether-Grasp Installer

An automated installer for setting up Nether-Grasp in a new T3 App project.

## What is Nether-Grasp?

Nether-Grasp is a task management and prompt handling system that integrates with Next.js applications built with T3 Stack (TypeScript, Tailwind, Prisma).

## Installation Methods

### Method 1: Using the Batch File (Recommended - Easy!)

1. **Download or clone this repository**
2. **Double-click `Click-me.bat`** ✨
3. **Follow the prompts**:
   - Enter the full path where you want to create your project
   - Answer the T3 App setup questions
   - Provide environment variables when prompted

### Method 2: Using PowerShell Script

1. **Download or clone this repository**
2. **Open PowerShell in this directory**
3. **Run the launcher**:
   ```powershell
   .\installation-script-2.ps1
   ```
4. **Follow the prompts**

### Method 3: Advanced - Direct Script Execution

If you want to run the installer directly (without the launcher):

```powershell
# Navigate to where you want to create your project
cd C:\Users\YourName\Projects

# Run the installer script from the installer directory
C:\path\to\installer\installation-script.ps1
```

## What the Installer Does

1. **Creates a T3 App** with:
   - TypeScript
   - Tailwind CSS
   - Prisma (PostgreSQL)
   - App Router
   - ESLint/Prettier

2. **Installs Nether-Grasp** components:
   - Frontend components and UI
   - API routes
   - Bridge server for WebSocket communication
   - Prisma schema with Task model
   - Configuration files

3. **Configures your project**:
   - Updates package.json with necessary scripts
   - Sets up environment variables
   - Configures ESLint for compatibility
   - Updates tsconfig.json
   - Pushes to GitHub

4. **Installs dependencies**:
   - WebSocket libraries
   - Prisma client
   - Concurrently (for running multiple servers)

## Requirements

- **Windows** (PowerShell)
- **Node.js** (v18 or higher)
- **npm** (comes with Node.js)
- **Git** (for repository setup)
- **PostgreSQL database** (local or hosted)

## Environment Variables

The installer will prompt you for these values:

- `DATABASE_URL` - PostgreSQL connection string
- `CURSOR_API_KEY` - API key from Cursor settings
- `VERCEL_WEBHOOK_SECRET` - Random string for webhook security
- `VERCEL_API_TOKEN` - Token from Vercel settings

## After Installation

1. **Navigate to your project**:
   ```bash
   cd your-project-name
   ```

2. **Start the development servers**:
   ```bash
   npm run dev
   ```
   This runs both Next.js and the Nether-Bridge server concurrently.

3. **Open your browser**:
   ```
   http://localhost:3000/nether-grasp
   ```

## Troubleshooting

### Batch File Not Working

If `Click-me.bat` doesn't work:

1. **Use PowerShell directly**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\installation-script-2.ps1
   ```

2. **Check Windows Defender/Antivirus**:
   - Some antivirus software may block scripts
   - Add an exception for the installer folder

### "Cannot be loaded because running scripts is disabled"

Run this in PowerShell as Administrator:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Database connection issues

Make sure your `DATABASE_URL` in `.env` is correct and the database is running.

### Port already in use

If port 3000 or 3001 is already in use, stop other applications or modify the port in your configuration.

## Re-Installing Nether-Grasp

If you need to re-install Nether-Grasp into an existing project:

```powershell
cd your-existing-project
C:\path\to\installer\installation-script.ps1 -ReInstall
```

## Project Structure

```
install-nether-grasp/
├── Click-me.bat                      # ✨ Double-click to run installer
├── installation-script-2.ps1         # Launcher script (internal)
├── installation-script.ps1           # Main installer script (internal)
├── nether-bridge-server.js           # WebSocket bridge server
├── README.md                          # This file
├── src/                               # Nether-Grasp source files
│   ├── app/                           # Next.js app files
│   └── components/                    # React components
├── public/                            # Static assets
│   ├── fonts/                         # Custom fonts
│   └── *.png                          # Images
└── prisma/                            # Prisma schema
    └── schema.prisma                  # Database schema
```

## Support

For issues or questions:
- Open an issue on GitHub
- Check the documentation in the project

## License

[Add your license here]

## Credits

Built with:
- [T3 Stack](https://create.t3.gg/)
- [Next.js](https://nextjs.org/)
- [Prisma](https://www.prisma.io/)
- [Tailwind CSS](https://tailwindcss.com/)
