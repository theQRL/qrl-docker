from docker import Client
import os

hostname = os.environ['HOSTNAME']

cli = Client(base_url='unix://var/run/docker.sock')
data = cli.containers()

for d in data:
    id = d['Id'][:12]
    names = d['Names']
    if id == hostname:
        print(names[0])
        quit()

print(hostname)
