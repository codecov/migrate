from flask import Flask
import sys
import subprocess
app = Flask(__name__)


@app.route('/')
def hello():
    return str(subprocess.call(['/run']))


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
