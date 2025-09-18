from flask import Flask, render_template, send_file
import requests

app = Flask(__name__)
BACKEND_HOST = '127.0.0.1'
BACKEND_PORT = 8888

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/style.css")
def style_css():
    return send_file("./res/style.css")

@app.route("/index.js")
def index_js():
    return send_file("./res/index.js")

def create_job():
    url = f'{BACKEND_HOST}:{BACKEND_PORT}/create_job/'
    requests.post(url)

if __name__ == "__main__":
    app.run()