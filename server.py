from flask import Flask
import sys
import subprocess
app = Flask(__name__)


@app.route('/')
def hello():
    # this returns the call status (0==finished or 1==working)
    return str(subprocess.call(['/run']))


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
