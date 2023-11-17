from flask import Flask, request, jsonify, abort, session
from flask_session import Session
from functools import wraps
import sqlite3
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

# Session configuration
app.config['SECRET_KEY'] = 'DDIA2020'
app.config['SESSION_TYPE'] = 'filesystem'
Session(app)

# Initialize the SQLite database and create tables
def initialize_db():
    conn = sqlite3.connect('battleship.db', check_same_thread=False)
    cursor = conn.cursor()

    cursor.execute('''
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
    )
    ''')

    cursor.execute('''
    CREATE TABLE IF NOT EXISTS games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player1_id INTEGER,
        player2_id INTEGER,
        status TEXT,
        FOREIGN KEY (player1_id) REFERENCES users (id),
        FOREIGN KEY (player2_id) REFERENCES users (id)
    )
    ''')

    conn.commit()
    conn.close()

initialize_db()

# Decorator for requiring login
def login_required(func):
    @wraps(func)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            abort(401, description="Unauthorized access")
        return func(*args, **kwargs)
    return decorated_function

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data['username']
    password = generate_password_hash(data['password'])

    conn = sqlite3.connect('battleship.db')
    cursor = conn.cursor()

    try:
        cursor.execute('INSERT INTO users (username, password) VALUES (?, ?)', (username, password))
        conn.commit()
    except sqlite3.IntegrityError:
        conn.close()
        abort(409, description="Username already exists")

    conn.close()
    return jsonify({'message': 'User registered successfully'}), 200

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data['username']
    password = data['password']

    conn = sqlite3.connect('battleship.db')
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute('SELECT id, password FROM users WHERE username=?', (username,))
    user = cursor.fetchone()

    if user and check_password_hash(user['password'], password):
        session['user_id'] = user['id']
        return jsonify({'message': 'Login successful'})
    else:
        abort(401, description="Invalid username or password")

@app.route('/logout')
@login_required
def logout():
    session.pop('user_id', None)
    return jsonify({'message': 'Logout successful'})

# Add your game management endpoints here

# Error handlers
@app.errorhandler(401)
def unauthorized(error):
    return jsonify({'error': 'Unauthorized access'}), 401

@app.errorhandler(403)
def forbidden(error):
    return jsonify({'error': 'Forbidden'}), 403

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not Found'}), 404

@app.errorhandler(409)
def conflict(error):
    return jsonify({'error': 'Conflict'}), 409

if __name__ == '__main__':
    app.run(debug=True)
