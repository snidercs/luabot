import yaml

with open('util/parse.yaml') as stream:
    obj = yaml.safe_load (stream)
    print (obj)
