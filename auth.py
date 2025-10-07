from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from werkzeug.security import generate_password_hash, check_password_hash
from flask_pymongo import PyMongo
from functools import wraps

# Create auth blueprint
auth = Blueprint('auth', __name__)

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('auth.login'))
        return f(*args, **kwargs)
    return decorated_function

def role_required(role):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if 'user_id' not in session:
                return redirect(url_for('auth.login'))
            if session.get('role') != role:
                flash(f'Access denied. {role.title()} access required.', 'error')
                return redirect(url_for('home'))
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@auth.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        user_type = request.form.get('user_type')  # 'teacher' or 'student'

        if not username or not password or not user_type:
            flash('Please fill in all fields', 'error')
            return render_template('login.html')

        # Get MongoDB connection from current app context
        from app import mongo

        # Find user in database
        user_collection = mongo.db.users
        user = user_collection.find_one({
            'username': username,
            'role': user_type
        })

        if user and check_password_hash(user['password'], password):
            session['user_id'] = str(user['_id'])
            session['username'] = user['username']
            session['role'] = user['role']
            flash(f'Welcome back, {username}!', 'success')

            if user_type == 'teacher':
                return redirect(url_for('upload'))
            else:
                return redirect(url_for('quiz'))
        else:
            flash('Invalid username, password, or user type', 'error')

    return render_template('login.html')

@auth.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        confirm_password = request.form.get('confirm_password')
        user_type = request.form.get('user_type')  # 'teacher' or 'student'

        if not username or not password or not confirm_password or not user_type:
            flash('Please fill in all fields', 'error')
            return render_template('signup.html')

        if password != confirm_password:
            flash('Passwords do not match', 'error')
            return render_template('signup.html')

        if len(password) < 6:
            flash('Password must be at least 6 characters long', 'error')
            return render_template('signup.html')

        # Get MongoDB connection from current app context
        from app import mongo

        # Check if username already exists
        user_collection = mongo.db.users
        existing_user = user_collection.find_one({'username': username})

        if existing_user:
            flash('Username already exists', 'error')
            return render_template('signup.html')

        # Create new user
        hashed_password = generate_password_hash(password)
        new_user = {
            'username': username,
            'password': hashed_password,
            'role': user_type
        }

        user_collection.insert_one(new_user)
        flash('Account created successfully! Please log in.', 'success')
        return redirect(url_for('auth.login'))

    return render_template('signup.html')

@auth.route('/logout')
@login_required
def logout():
    session.clear()
    flash('You have been logged out successfully', 'success')
    return redirect(url_for('home'))
