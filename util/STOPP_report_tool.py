__author__ = 'rrusk'

import datetime
import pymongo

class MongoDatabase(object):

    DEFAULT_DB_NAME = "query_composer_development"

    ENDPOINTS_COLLECTION = "endpoints"
    QUERIES_COLLECTION  = "queries"
    RESULTS_COLLECTION  = "results"

    def __init__(self, db_name=DEFAULT_DB_NAME, host="localhost", port=27017):
        self._client = pymongo.MongoClient("mongodb://{host}:{port}".format(host=host, port=port))
        self._db = self._client[db_name]

    def _get_endpoints_collection(self):
        return self._db[self.ENDPOINTS_COLLECTION]

    def _get_queries_collection(self):
        return self._db[self.QUERIES_COLLECTION]

    def _get_results_collection(self):
        return self._db[self.RESULTS_COLLECTION]

    def get_endpoints(self):
        find_query = {}
        return list(self._get_endpoints_collection().find(find_query))

    def get_queries(self):
        find_query = {}
        return list(self._get_queries_collection().find(find_query))

    def get_results(self):
        find_query = {}
        return list(self._get_results_collection().find(find_query))

    def get_query(self,queryid):
        find_query = {'_id': queryid}
        return (list(self._get_queries_collection().find(find_query)))[0]

def select_result(execution_id, endpoint_id, results):
    for result in results:
        if result['execution_id'] == execution_id:
            if result['endpoint_id'] == endpoint_id:
                return result

def main():
    db = MongoDatabase()
    endpoints= db.get_endpoints()
    queries = db.get_queries()
    results = db.get_results()

    querySet = {}
    for query in queries:
        if not query['description'].startswith("STOPP Rule "):
            continue
        querySet[query['description']] = query['_id']
    queryDesc = sorted(querySet)

    for desc in queryDesc:  # want queries sorted by description
        queryid = querySet[desc]
        query = db.get_query(queryid)
        desc = query['description'].split()[2]
        print desc, query['title']
        executions = query['executions']
        for execution in executions:
            jstime = execution['time']
            dt = datetime.datetime.fromtimestamp(jstime)
	    if dt < datetime.datetime(2015,2,19,12,0,0):
		#print "dt =", dt
		#print "date =", datetime.datetime(2015,2,19,12,0,0)
		continue
            execution_id = execution['_id']

            try:
                aggregate_result = execution['aggregate_result']
            except KeyError: continue
            if aggregate_result:
                    keys = []
                    reportline = "  "
                    reportline += str(dt)
                    reportline += " aggregate:"
                    for key in aggregate_result:
                        reportline += ' '+str(key)+' '+str(int(aggregate_result[key]))
                        keys.append(key)
                    print reportline

                    for endpoint in endpoints:
                        endpoint_id = endpoint['_id']
                        result = select_result(execution_id, endpoint_id, results)
                        if result:
                            reportline = '    '+str(endpoint['name'])
                            try:
                                value = result['value']
                            except KeyError: continue
                            for key in keys:
                                try:
                                    reportline += ' '+ str(key)+' '+str(int(value[key]))
                                except KeyError: continue
                            print reportline
        print
                    

if __name__ == '__main__':main()
