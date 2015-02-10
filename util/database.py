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

def main():
    db = MongoDatabase()
    print "ENDPOINTS:"
    endpoints= db.get_endpoints()
    print endpoints
    print "\nQUERIES:"
    queries = db.get_queries()
    for query in queries:
        print
        print query['description'], query['title']
        executions = query['executions']
        for execution in executions:
            jstime = execution['time']
            dt = datetime.datetime.fromtimestamp(jstime)
            print dt
            try:
                aggregate_result = execution['aggregate_result']
                print aggregate_result
            except KeyError: continue
    print "\nRESULTS:"
    results = db.get_results()
    for result in results:
        print
        print result['status'], result['created_at'], result['updated_at']
        print result['endpoint_id'], result['execution_id']
        #print result['value']
    #print results


if __name__ == '__main__':main()