import subprocess
import sys
import os

def update_requirements():
    """Update Python packages based on requirements.txt"""
    try:
        # Ensure we're using the virtual environment python
        venv_python = os.path.join('/opt/venv/bin/python')
        
        # Update pip first
        subprocess.run([venv_python, "-m", "pip", "install", "--upgrade", "pip"], check=True)
        
        # Install/upgrade packages from requirements.txt
        subprocess.run([venv_python, "-m", "pip", "install", "--upgrade", "-r", "/data/requirements.txt"], check=True)
        
        print("Successfully updated all dependencies!")
        
    except subprocess.CalledProcessError as e:
        print(f"Error updating dependencies: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    update_requirements() 