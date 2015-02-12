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
    for query in queries:
        if not query['description'].startswith("STOPP Rule "):
            continue
        print
        desc = query['description'].split()[2]
        print desc, query['title']
        executions = query['executions']
        for execution in executions:
            jstime = execution['time']
            dt = datetime.datetime.fromtimestamp(jstime)
            #print dt
            execution_id = execution['_id']
            #print id
            keys = []
            try:
                aggregate_result = execution['aggregate_result']
                for key in aggregate_result:
                    keys.append(key)
            except KeyError: continue
            print "keys: ", keys
            #sortedkeys = keys.sort()
            #print "sortedkeys: ", sortedkeys
            try:
                aggregate_result = execution['aggregate_result']
                print dt,
                for key in keys:
                    print key, aggregate_result[key],
                print
            except KeyError: continue

            for endpoint in endpoints:
                endpoint_id = endpoint['_id']
                result = select_result(execution_id, endpoint_id, results)
                if result:
                    try:
                        print '  ', endpoint['name'],
                        value = result['value']
                        for key in value:
                            if key in keys:
                                print key, value[key],
                        print
                    except KeyError: continue


if __name__ == '__main__':main()
