import sys
import subprocess

if len(sys.argv) != 2:
    print("Usage: lpass.py <site>")
    sys.exit(1)

site = sys.argv[1]
command = f'lpass show --password "{site}"'
password = subprocess.getoutput(command)
print(password)
