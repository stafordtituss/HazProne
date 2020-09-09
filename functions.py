import subprocess

def gen_whitelist():
    get_ip = subprocess.Popen(["curl", "ifconfig.me"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    get_ip.wait()
    return get_ip.stdout.read().decode("utf-8").strip()