#!/bin/bash

# GitHub Repository Setup Script for Fedora 43 Setup
# This script will create all necessary files and set up your GitHub repository

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

# Banner
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════╗
║     GitHub Repository Setup for Fedora 43 Script      ║
╚═══════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Installing..."
    sudo dnf install -y git
fi

# Get user information
print_status "Gathering Information"
echo ""
read -p "Enter your GitHub username: " GITHUB_USER
read -p "Enter your full name: " FULL_NAME
read -p "Enter your email: " EMAIL
read -p "Enter repository name (default: fedora-setup): " REPO_NAME
REPO_NAME=${REPO_NAME:-fedora-setup}
read -p "Enter your Twitter handle (optional, press Enter to skip): " TWITTER

# Create project directory
print_status "Creating project directory"
REPO_DIR="$HOME/$REPO_NAME"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

print_info "Working in: $REPO_DIR"

# Initialize git
print_status "Initializing Git repository"
git init
git config user.name "$FULL_NAME"
git config user.email "$EMAIL"

# Create setup.sh
print_status "Creating setup.sh"
cat > setup.sh << 'SETUPEOF'
#!/bin/bash

# Fedora 43 Laptop Setup Script
# Comprehensive setup for AI/ML development environment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_error "Please do not run this script as root"
    exit 1
fi

print_status "Starting Fedora 43 Setup..."

# Update System
print_status "Updating System"
sudo dnf update -y

# Install System Essentials
print_status "Installing System Essentials"
sudo dnf install -y git curl wget unzip zip gcc gcc-c++ make cmake autoconf automake libtool

# Install Terminal Tools
print_status "Installing Terminal Tools"
sudo dnf install -y zsh btop fastfetch neofetch htop

# Install VS Code
print_status "Installing VS Code (Native)"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install -y code

# Enable RPM Fusion (needed for some packages)
print_status "Enabling RPM Fusion"
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install FFmpeg (do this after RPM Fusion)
print_status "Installing FFmpeg"
sudo dnf install -y ffmpeg ffmpeg-devel

# Install Additional Codecs
print_status "Installing Additional Codecs"
sudo dnf install -y gstreamer1-plugins-bad-free gstreamer1-plugins-good gstreamer1-plugins-base gstreamer1-libav

# Install Flatpak Apps
print_status "Installing Flatpak Apps"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.videolan.VLC
flatpak install -y flathub org.gnome.Extensions
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub md.obsidian.Obsidian
flatpak install -y flathub com.usebottles.bottles

# Optional: Notion (sometimes has issues)
print_warning "Attempting to install Notion (may fail if not available)"
flatpak install -y flathub io.github.notion_enhancer.NotionEnhancer 2>/dev/null || print_warning "Notion install failed, skipping..."

# Install Oh My Zsh
print_status "Installing Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    print_warning "Oh My Zsh already installed, skipping..."
fi

# Install Miniconda
print_status "Installing Miniconda"
if [ ! -d "$HOME/miniconda" ]; then
    cd ~/Downloads
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda
    rm Miniconda3-latest-Linux-x86_64.sh
else
    print_warning "Miniconda already installed, skipping..."
fi

# Initialize Conda
print_status "Initializing Conda"
$HOME/miniconda/bin/conda init bash
$HOME/miniconda/bin/conda init zsh

# Source conda for current session
export PATH="$HOME/miniconda/bin:$PATH"
eval "$($HOME/miniconda/bin/conda shell.bash hook)"

# Create AI Environment
print_status "Creating AI Environment"
if ! conda env list | grep -q "^ai "; then
    conda create -n ai python=3.11 -y
else
    print_warning "AI environment already exists, skipping creation..."
fi

# Install Python AI/ML Libraries
print_status "Installing Python AI/ML Libraries (this may take a while...)"
$HOME/miniconda/envs/ai/bin/pip install --upgrade pip
$HOME/miniconda/envs/ai/bin/pip install \
    numpy pandas matplotlib seaborn scikit-learn \
    tensorflow torch torchvision torchaudio \
    opencv-python mediapipe dlib \
    transformers datasets \
    librosa pydub ffmpeg-python \
    jupyterlab notebook ipykernel \
    plotly pygame

# Install Whisper + Speech Tools
print_status "Installing Whisper + Speech Tools"
$HOME/miniconda/envs/ai/bin/pip install openai-whisper SpeechRecognition TTS edge-tts

# Install AI App UI Tools
print_status "Installing AI App UI Tools"
$HOME/miniconda/envs/ai/bin/pip install streamlit gradio flask fastapi uvicorn

# Install Web Tools
print_status "Installing Web Tools (Node.js and npm)"
sudo dnf install -y nodejs npm

# Install Next.js globally
print_status "Installing Next.js CLI"
sudo npm install -g create-next-app

# Create Project Structure
print_status "Creating Project Structure"
mkdir -p ~/Projects/{drowsiness-detection,speech-ai,ai-music-recommender,video-to-gif-ai,ml-practice}
mkdir -p ~/Projects/portfolio/utils

# Install Docker
print_status "Installing Docker"
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Performance Optimization
print_status "Applying Performance Optimizations"
if ! grep -q "vm.swappiness=10" /etc/sysctl.conf; then
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
fi

# Install additional useful tools
print_status "Installing Additional Useful Tools"
sudo dnf install -y vim nano tmux tree ripgrep fd-find bat

# Setup Git config (optional)
print_status "Git Configuration"
read -p "Would you like to configure Git? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    print_status "Git configured successfully!"
fi

# Final messages
print_status "Setup Completed Successfully! 🚀"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}IMPORTANT: Please complete the following steps:${NC}"
echo ""
echo "1. ${GREEN}Log out and log back in${NC} (or reboot) for Docker group to take effect"
echo "2. ${GREEN}Open a new terminal${NC} for Zsh and Conda to work properly"
echo "3. ${GREEN}Activate your AI environment${NC} with: ${YELLOW}conda activate ai${NC}"
echo "4. Your projects are in: ${YELLOW}~/Projects/${NC}"
echo "5. To change shell to Zsh: ${YELLOW}chsh -s $(which zsh)${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Happy coding! 🎉"
SETUPEOF

chmod +x setup.sh

# Create README.md
print_status "Creating README.md"
cat > README.md << READMEEOF
# Fedora 43 Laptop Setup Script

A comprehensive automated setup script for Fedora 43 workstations, optimized for AI/ML development and general productivity.

![Fedora](https://img.shields.io/badge/Fedora-43-51A2DA?style=flat&logo=fedora&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)
![Shell](https://img.shields.io/badge/shell-bash-4EAA25?style=flat&logo=gnu-bash&logoColor=white)

## 🚀 Features

This setup script automates the installation and configuration of:

### System Essentials
- System updates and essential build tools
- Git, curl, wget, and compression utilities
- GCC, G++, Make, CMake, and development tools

### Terminal Environment
- **Zsh** with Oh My Zsh
- **btop** - Resource monitor
- **fastfetch** - System information tool
- Additional utilities: vim, tmux, tree, ripgrep, bat

### Development Tools
- **VS Code** - Native RPM installation
- **Docker** with Docker Compose
- **Node.js & npm** with Next.js CLI
- **Miniconda** for Python environment management

### AI/ML Stack
Complete Python 3.11 environment with:
- **Core Libraries**: NumPy, Pandas, Matplotlib, Seaborn
- **ML Frameworks**: Scikit-learn, TensorFlow, PyTorch
- **Computer Vision**: OpenCV, MediaPipe, dlib
- **NLP**: Transformers, Datasets
- **Audio Processing**: Librosa, PyDub, FFmpeg
- **Speech AI**: OpenAI Whisper, SpeechRecognition, TTS
- **Development**: JupyterLab, Streamlit, Gradio, FastAPI

### Desktop Applications (Flatpak)
- VLC Media Player
- GNOME Extensions Manager
- Discord
- Obsidian
- Bottles

### Multimedia Support
- FFmpeg with full codec support
- GStreamer plugins
- RPM Fusion repositories (free & non-free)

### Project Structure
Pre-configured directories for:
- Drowsiness Detection
- Speech AI
- AI Music Recommender
- Video to GIF AI
- ML Practice
- Portfolio Projects

## 📋 Prerequisites

- Fresh installation of Fedora 43 (Workstation Edition)
- Active internet connection
- Sudo privileges
- At least 10GB of free disk space

## 🔧 Installation

### Quick Start

\`\`\`bash
# Clone the repository
git clone https://github.com/${GITHUB_USER}/${REPO_NAME}.git
cd ${REPO_NAME}

# Make the script executable
chmod +x setup.sh

# Run the setup
./setup.sh
\`\`\`

### Manual Installation

If you prefer to download just the script:

\`\`\`bash
wget https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/main/setup.sh
chmod +x setup.sh
./setup.sh
\`\`\`

## 📖 Usage

The script will automatically:
1. Update your system packages
2. Install all required software
3. Configure development environments
4. Create project directories
5. Optimize system performance

During execution, you'll be prompted to:
- Configure Git (optional)

### Post-Installation Steps

After the script completes:

1. **Reboot or log out/in** to apply Docker group changes
2. **Open a new terminal** for shell changes to take effect
3. **Activate the AI environment**:
   \`\`\`bash
   conda activate ai
   \`\`\`
4. **Change default shell to Zsh** (optional):
   \`\`\`bash
   chsh -s \$(which zsh)
   \`\`\`

## 🗂️ Project Structure

After installation, your projects will be organized in:

\`\`\`
~/Projects/
├── drowsiness-detection/
├── speech-ai/
├── ai-music-recommender/
├── video-to-gif-ai/
├── ml-practice/
└── portfolio/
    └── utils/
\`\`\`

## 🐍 Python Environment

The script creates a conda environment named \`ai\` with Python 3.11. To use it:

\`\`\`bash
# Activate environment
conda activate ai

# Verify installation
python --version
pip list

# Launch Jupyter Lab
jupyter lab

# Run Streamlit app
streamlit run app.py
\`\`\`

## 🐳 Docker

Docker is installed and configured to run without sudo (after reboot):

\`\`\`bash
# Test Docker installation
docker --version
docker compose version

# Run a test container
docker run hello-world
\`\`\`

## ⚙️ Customization

### Modify Installed Packages

Edit the script to add or remove packages from any section:

\`\`\`bash
# Example: Add PostgreSQL
sudo dnf install -y postgresql postgresql-server
\`\`\`

### Change Python Version

Modify the conda environment creation line:

\`\`\`bash
conda create -n ai python=3.12 -y  # Use Python 3.12 instead
\`\`\`

### Add More Flatpak Apps

\`\`\`bash
flatpak install -y flathub com.spotify.Client
\`\`\`

## 🔍 What Gets Installed

<details>
<summary>Click to expand full package list</summary>

### System Packages (DNF)
- git, curl, wget, unzip, zip
- gcc, gcc-c++, make, cmake
- zsh, btop, fastfetch
- nodejs, npm
- docker-ce, docker-ce-cli, containerd.io
- ffmpeg, ffmpeg-devel
- vim, nano, tmux, tree, ripgrep, bat

### Flatpak Applications
- org.videolan.VLC
- org.gnome.Extensions
- com.discordapp.Discord
- md.obsidian.Obsidian
- com.usebottles.bottles

### Python Packages (Conda/Pip)
- numpy, pandas, matplotlib, seaborn
- scikit-learn, tensorflow, torch
- opencv-python, mediapipe, dlib
- transformers, datasets
- librosa, pydub, ffmpeg-python
- openai-whisper, SpeechRecognition, TTS
- jupyterlab, streamlit, gradio, fastapi

</details>

## 🛠️ Troubleshooting

### Docker Permission Denied

If you get permission errors with Docker:
\`\`\`bash
# Ensure you're in the docker group
groups

# If not listed, re-add yourself
sudo usermod -aG docker \$USER

# Log out and back in
\`\`\`

### Conda Command Not Found

\`\`\`bash
# Reinitialize conda
~/miniconda/bin/conda init bash
~/miniconda/bin/conda init zsh

# Restart terminal
\`\`\`

### Flatpak Installation Fails

\`\`\`bash
# Add Flathub repository manually
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Retry installation
\`\`\`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes:

1. Fork the repository
2. Create your feature branch (\`git checkout -b feature/AmazingFeature\`)
3. Commit your changes (\`git commit -m 'Add some AmazingFeature'\`)
4. Push to the branch (\`git push origin feature/AmazingFeature\`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Fedora Project for the amazing Linux distribution
- All the open-source projects included in this setup
- The AI/ML community for the fantastic tools and libraries

## 📧 Contact

${FULL_NAME} - ${EMAIL}
READMEEOF

# Add Twitter if provided
if [ -n "$TWITTER" ]; then
    echo "Twitter: [@${TWITTER}](https://twitter.com/${TWITTER})" >> README.md
fi

cat >> README.md << READMEEOF2

Project Link: [https://github.com/${GITHUB_USER}/${REPO_NAME}](https://github.com/${GITHUB_USER}/${REPO_NAME})

---

⭐ If this script helped you, please consider giving it a star!

## 🗓️ Changelog

### v1.0.0 ($(date +%Y-%m-%d))
- Initial release
- Complete AI/ML development environment
- Docker and container support
- Comprehensive multimedia codec support
- Project structure automation
READMEEOF2

# Create LICENSE
print_status "Creating LICENSE (MIT)"
cat > LICENSE << LICENSEEOF
MIT License

Copyright (c) $(date +%Y) ${FULL_NAME}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSEEOF

# Create .gitignore
print_status "Creating .gitignore"
cat > .gitignore << GITIGNOREEOF
# Backup files
*.bak
*~
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db
Desktop.ini

# Editor directories
.vscode/
.idea/
*.sublime-*

# Logs
*.log

# Temporary files
tmp/
temp/
GITIGNOREEOF

# Create CONTRIBUTING.md
print_status "Creating CONTRIBUTING.md"
cat > CONTRIBUTING.md << CONTRIBUTINGEOF
# Contributing to Fedora 43 Setup Script

First off, thank you for considering contributing to this project! 🎉

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed and what you expected**
- **Include system information** (Fedora version, hardware specs)
- **Include relevant logs or error messages**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Explain why this enhancement would be useful**
- **List some examples of how it would be used**

### Pull Requests

1. Fork the repo and create your branch from \`main\`
2. Make your changes
3. Test your changes thoroughly
4. Update the README.md if needed
5. Update the CHANGELOG section in README.md
6. Issue the pull request!

## Style Guidelines

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests after the first line

Example:
\`\`\`
Add PostgreSQL installation option

- Add dnf installation for PostgreSQL
- Include basic configuration
- Update README with PostgreSQL info

Fixes #123
\`\`\`

### Bash Scripting Style

- Use 4 spaces for indentation (no tabs)
- Add comments for complex logic
- Use meaningful variable names
- Include error checking where appropriate
- Test on a fresh Fedora 43 installation before submitting

### Documentation

- Keep README.md up to date
- Document new features
- Include usage examples
- Update troubleshooting section if needed

## Testing

Before submitting a PR:

1. Test the script on a fresh Fedora 43 installation (VM recommended)
2. Verify all packages install correctly
3. Check for any errors or warnings
4. Ensure the script is idempotent (can be run multiple times safely)

## Questions?

Feel free to open an issue with your question or contact ${FULL_NAME} at ${EMAIL}.

Thank you for contributing! 🚀
CONTRIBUTINGEOF

# Git operations
print_status "Setting up Git"
git add .
git commit -m "Initial commit: Fedora 43 setup script with comprehensive documentation"

# Display next steps
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Repository files created successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
print_info "Directory: $(pwd)"
echo ""
print_status "Files created:"
echo "  ✓ setup.sh"
echo "  ✓ README.md"
echo "  ✓ LICENSE (MIT)"
echo "  ✓ CONTRIBUTING.md"
echo "  ✓ .gitignore"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Create a new repository on GitHub:"
echo -e "   ${BLUE}https://github.com/new${NC}"
echo "   - Repository name: ${YELLOW}${REPO_NAME}${NC}"
echo "   - Description: ${YELLOW}Automated setup script for Fedora 43 with AI/ML development environment${NC}"
echo "   - Make it ${YELLOW}Public${NC}"
echo "   - ${RED}DO NOT${NC} initialize with README, .gitignore, or license"
echo ""
echo "2. Push to GitHub:"
echo -e "   ${BLUE}git remote add origin https://github.com/${GITHUB_USER}/${REPO_NAME}.git${NC}"
echo -e "   ${BLUE}git branch -M main${NC}"
echo -e "   ${BLUE}git push -u origin main${NC}"
echo ""
echo "3. Or use GitHub CLI (if installed):"
echo -e "   ${BLUE}gh repo create ${REPO_NAME} --public --source=. --remote=origin --push${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
print_status "Your repository is ready to be pushed to GitHub! 🚀"
echo ""