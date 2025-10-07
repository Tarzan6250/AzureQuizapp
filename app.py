import os
from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_pymongo import PyMongo
from bson.objectid import ObjectId
from auth import auth, login_required, role_required
from datetime import datetime

# Initialize Flask app
app = Flask(__name__)

# Load configuration from environment variables (recommended for Azure)
app.config["MONGO_URI"] = os.getenv("MONGO_URI", "mongodb+srv://quizuser:quizpassword123@cluster1.82givwa.mongodb.net/quizdb?retryWrites=true&w=majority")
app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "your-secret-key-change-this-in-production")

# Initialize MongoDB
mongo = PyMongo(app)
questions = mongo.db.questions
users = mongo.db.users

# Register auth blueprint
app.register_blueprint(auth)

@app.route('/')
def home():
    if 'user_id' in session:
        return render_template('index.html')
    return redirect(url_for('auth.login'))

@app.route('/upload', methods=['GET', 'POST'])
@login_required
@role_required('teacher')
def upload():
    if request.method == 'POST':
        q_data = {
            "question": request.form['question'],
            "option_a": request.form['a'],
            "option_b": request.form['b'],
            "option_c": request.form['c'],
            "option_d": request.form['d'],
            "correct": request.form['correct']
        }
        questions.insert_one(q_data)
        flash('Question uploaded successfully!', 'success')
        return redirect('/upload')
    return render_template('upload.html')

@app.route('/quiz', methods=['GET', 'POST'])
@login_required
@role_required('student')
def quiz():
    all_questions = list(questions.find())
    if request.method == 'POST':
        score = 0
        for q in all_questions:
            selected = request.form.get(str(q['_id']))
            if selected == q['correct']:
                score += 1
        return render_template('result.html', score=score, total=len(all_questions), now=datetime.now())
    return render_template('quiz.html', questions=all_questions)

if __name__ == '__main__':
    app.run(debug=True)
