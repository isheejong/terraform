#
# hee-jong.lee @ oracle korea
# 2017.11.29
# this py is for autoscaling in oracle cloud infrastucture
#

import sys
import subprocess
import psutil
import time
import logging
import threading
from logging.handlers import TimedRotatingFileHandler

# handler = TimedRotatingFileHandler('c:/Dev/terraform/', when="m", interval=1, backupCount=5)
# logging.addHandler(handler)
logging.basicConfig(level=logging.DEBUG,
                    format='[%(asctime)s] | %(levelname)s |  %(message)s',
                    filename='myapp.log',
                    filemode='w')

# create tf file and apply
def autoscale(adname, subnet, prefix, count):

    # read header file about provider and variable
    header = ''
    with open('header.txt', 'r') as hfile:
        for line in hfile.readlines():
            header += line

    # read instance template to create oci instance
    instance = ''
    with open('instance.txt', 'r') as ifile:
        for line in ifile.readlines():
            instance += line

    # read backend template to create backed set
    backend = ''
    with open('backend.txt', 'r') as bfile:
        for line in bfile.readlines():
            backend += line

    intances = ''
    backeds  = ''
    for index in range (1, count):
        # replace the intance name each by scale out for count
        intances += instance.replace('#{name}', prefix + '-' + str(index)).replace('#{adname}', adname ).replace('#{subnet}', subnet )
        backeds  += backend.replace ('#{name}', prefix + '-' + str(index))


    # create the tf file for applying the cloud for tf
    with open('oci.tf', 'w') as wfile:
        wfile.write(header + intances + backeds)

    # execute tf command
    # proc = subprocess.Popen('terraform apply -auto-approve', shell=True,
                        # stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    # gethering from stdout about terrform
    # result = ''
    # for line in proc.stdout.readlines():
    #     result += line.decode('utf-8')
    # logging.info(result)

# watching avg cpu usage and scale ou or in
def run(adname, subnet, prefix):
    status = 'NORMAL'

    #
    #
    # configurations for autoscaling
    scale    = 0   # current scale
    duration = 5   # duration for avg
    maxScaleOut = 5   # max scale out size
    minScaleIn  = 0   # min scale in size
    scaleInCondi  = 40  # cpu usage per for scale out
    sacleOutCondi = 60  # cpu usage per for scale in
    #
    #
    #

    count = 0
    sumOfCpuPer = 0
    currAvgOfCpuPer = 0
    prevAvgOfCpuPer = 0
    while True :
        sumOfCpuPer +=  psutil.cpu_percent()

        if ( count == duration ):
            currAvgOfCpuPer = round(sumOfCpuPer / duration, 2)
            count = 0
            sumOfCpuPer = 0
            print(' > current scale : ' + str(scale) +
                            ' | avg cpu usage : '    + str(currAvgOfCpuPer) )

        if  count == 0 and currAvgOfCpuPer > sacleOutCondi and scale <= maxScaleOut :
            print(' > current scale : ' + str(scale) +
                            ' | avg cpu usage : '     + str(currAvgOfCpuPer) + " greater than " + str(sacleOutCondi) )
            # logging.info(' > current scale : ' + str(scale) +
            #                 ' | avg cpu usage : '     + str(currAvgOfCpuPer) + " greater than " + str(sacleOutCondi)  + " and sacle out")
            status = 'SCALE_OUT'
            scale += 1

            autoscale(adname, subnet, prefix, scale)

            print(' > current scale : ' + str(scale) +
                            ' | avg cpu usage : '    + str(currAvgOfCpuPer) + " complete scale out")
            # logging.info(' > current scale : ' + str(scale) +
            #                 ' | avg cpu usage : '    + str(currAvgOfCpuPer) + " complete scale out")

        elif count == 0 and currAvgOfCpuPer < scaleInCondi and scale > minScaleIn :
            # logging.info(' > current scale : ' + str(scale) +
                            # ' | cpu usage : '    + str(currAvgOfCpuPer) + " less than " + str(scaleInCondi)  + " and scale in")
            print(' > current scale : ' + str(scale) +
                            ' | avg cpu usage : '    + str(currAvgOfCpuPer) + " less than " + str(scaleInCondi))

            status = 'SCALE_IN'
            scale -= 1
            autoscale(adname, subnet, prefix, scale)

            print(' > current scale : ' + str(scale) +
                            ' | avg cpu usage : '    + str(currAvgOfCpuPer) + " complete scale in")
            # logging.info(' > current scale : ' + str(scale) +
            #                 ' | avg cpu usage : '    + str(currAvgOfCpuPer) + " complete scale in")

        else:
            status = 'NORMAL'

        count += 1
        time.sleep(1) # per sec

def main():
    if len(sys.argv) < 4 :
        print(' ERROR > please input the parmeters for availability and prefix for instance')
        print(' Guide ')
        print('\t 1st : availability_domain1, availability_domain2, availability_domain3')
        print('\t 2st : subnet1 or subnet2 or subnet3')
        print('\t 3st : ad1-instance or ad2-instance or ad3-instance')
        return

    adnames = ['availability_domain1', 'availability_domain2', 'availability_domain3']
    subnets = ['subnet1', 'subnet2', 'subnet3']

    adname = sys.argv[1] # availability_domain1, availability_domain2, availability_domain3
    subnet = sys.argv[2] # subnet1 or subnet2 or subnet3
    prefix = sys.argv[3] # ad1-instance or ad2-instance or ad3-instance

    if( adname not in (adnames) ):
        print(' ERROR > please input the correct availability_domain')
        return

    elif( subnet not in (subnets) ):
        print(' ERROR > please input the correct subnet')
        return

    else:
        # start autoscaling
        run(adname, subnet, prefix)

if  __name__ =='__main__':
    main()
