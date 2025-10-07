import os
import sys

# Add current directory to Python path for imports
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

# Set environment variables for production
os.environ.setdefault('FLASK_ENV', 'production')

# Import the Flask application
from app import app

# This is used by wfastcgi for IIS deployment
if __name__ == '__main__':
    app.run()
