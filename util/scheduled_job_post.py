__author__ = 'rrusk'
import httplib, urllib

params = urllib.urlencode({'@number': 12524, '@type': 'issue', '@action': 'show'})
params = urllib.urlencode({"endpoint_names":["ep1","ep2", "ep3"],"query_descriptions":["desc1","desc2"]})
headers = {"Content-type": "application/x-www-form-urlencoded",
           "Accept": "text/plain"}
conn = httplib.HTTPSConnection("localhost", 3002)
conn.request("POST", "/scheduled_jobs/batch_query", params, headers)
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