#!/usr/bin/env python
__author__ = 'rrusk'
import sys
import httplib
import urllib
import json

def byteify(input):
    if isinstance(input, dict):
        return {byteify(key):byteify(value) for key,value in input.iteritems()}
    elif isinstance(input, list):
        return [byteify(element) for element in input]
    elif isinstance(input, unicode):
        return input.encode('utf-8')
    else:
        return input

if len(sys.argv) != 2:
    print "The batch job parameter file must be specified as the sole argument"
    print 'Usage: scheduled_job_post.py "job_params_file.json"'
    exit(1)
with open(sys.argv[1], "r") as params_file:
    params_json = json.load(params_file)
query_params = urllib.urlencode(byteify(params_json))
headers = {"Content-type": "application/x-www-form-urlencoded",
           "Accept": "text/plain"}
conn = httplib.HTTPSConnection("localhost", 3002)
conn.request("POST", "/scheduled_jobs/batch_query", query_params, headers)
response = conn.getresponse()
print response.status, response.reason
data = response.read()
print data
conn.close()

# import requests
# import json
# url = 'https://localhost:3002/scheduled_jobs/batch_query'
# payload = {"endpoint_names":["ep1","ep2"],"query_desc":["desc1","desc2"]}
# #r = requests.post(url, data=payload, verify=False)
# #r = requests.post(url, data=json.dumps(payload), verify=False)
# r = requests.post(url, params=payload, verify=False)
# print r.status_code
# print "encoding: " + str(r.encoding)
# print r.text
