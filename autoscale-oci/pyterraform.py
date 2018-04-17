
proc = subprocess.Popen('terraform apply -auto-approve', shell=True,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
