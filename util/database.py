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

def select_endpoint(endpoint_id, endpoints):
    for endpoint in endpoints:
        if endpoint['_id'] == endpoint_id:
            return endpoint

def select_endpoint_id_by_name(name, endpoints):
    for endpoint in endpoints:
        if endpoint['name'] == name:
            return endpoint['_id']

def select_query_id_by_desc(desc, queries):
    for query in queries:
        if query['description'] == desc:
            return query['_id']

def select_execution(execution_id, executions):
    for execution in executions:
        if execution['_id'] == execution_id:
            return execution

def select_results(query_id, endpoint_id, queries, results):
    selections = []
    execution_ids = []
    for query in queries:
        if query['_id'] == query_id:
            executions = query['executions']
            for execution in executions:
                execution_ids.append(execution['_id'])
            
    for result in results:
        if result['endpoint_id'] == endpoint_id:
            if result['execution_id'] in execution_ids:
                selections.append(result)
    return selections

def select_result(execution_id, endpoint_id, results):
    for result in results:
        if result['execution_id'] == execution_id:
            if result['endpoint_id'] == endpoint_id:
                return result

def main():
    db = MongoDatabase()
    print "ENDPOINTS:"
    endpoints= db.get_endpoints()
    for endpoint in endpoints:
        print
        print endpoint['_id'], endpoint['name']
    print "\nQUERIES:"
    queries = db.get_queries()
    results = db.get_results()
    for query in queries:
        print
        print query['description']
        executions = query['executions']
        for execution in executions:
            jstime = execution['time']
            dt = datetime.datetime.fromtimestamp(jstime)
            print dt
            execution_id = execution['_id']
            #print id
            try:
                aggregate_result = execution['aggregate_result']
                print aggregate_result
            except KeyError: continue
            for endpoint in endpoints:
                endpoint_id = endpoint['_id']
                result = select_result(execution_id, endpoint_id, results)
                if result:
                    try:
                        print result['created_at'], result['value']
                    except KeyError: continue
    print "\nRESULTS:"
    for result in results:
        #print
        #print result['status'], result['created_at'], result['updated_at']
        #print result['endpoint_id'], result['execution_id']
        endpoint = select_endpoint(result['endpoint_id'], endpoints)
        #print endpoint['name']
        execution = select_execution(result['execution_id'], endpoints)
        #print execution['aggregate_result']
        #print result['query_url']
        #print "RESULT:", result

    print "Selected result"
    queryid = select_query_id_by_desc('PDC-009', queries)
    print "queryid: ",queryid
    endpoint = select_endpoint_id_by_name('Bayswater-02',endpoints)
    print "endpoint: ",endpoint
    selected = select_results(queryid, endpoint, queries, results)
    for item in selected:
        try:
            print item['created_at'], item['value']['numerator'], item['value']['denominator']
        except KeyError: print "missing key"

if __name__ == '__main__':main()
