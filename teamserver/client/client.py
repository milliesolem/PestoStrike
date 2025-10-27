from flask import Flask, render_template, send_file
import requests
import re

app = Flask(__name__)
BACKEND_HOST = '127.0.0.1'
BACKEND_PORT = 8787

def fetch_json(path):
    return requests.get(f"http://{BACKEND_HOST}:{BACKEND_PORT}{path}").json()

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/job_form")
def job_form():
    return render_template("job_form.html")

@app.route("/machine_row/<agent_id>")
def machine_row(agent_id):
    agent = fetch_json(f"/agents/{agent_id.upper()}")
    os_img = f'<img src="/res/{re.findall(r"[a-z]+", agent["os"].lower())[0]}.png">'
    return render_template("machine_row.html", os_img=os_img, machine_name=agent["machine_name"])

@app.route("/agents")
def agents():
    agents = fetch_json("/agents")

@app.route("/style.css")
def style_css():
    return send_file("./res/style.css")

@app.route("/index.js")
def index_js():
    return send_file("./res/index.js")

def create_job():
    url = f'{BACKEND_HOST}:{BACKEND_PORT}/create_job/'
    requests.post(url)

# dummy function
def dummy_get_machines():
    return {
        "machine_name":"Shamir":
        "os": "Debian GNU/Linux 12",
        
    }


if __name__ == "__main__":
    app.run()