import psutil
import time

while True:
    sumOfCpuPer =  psutil.cpu_percent()
    print(sumOfCpuPer)
    time.sleep(1)
