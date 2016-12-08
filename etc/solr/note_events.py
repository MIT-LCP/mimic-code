#######

### THIS FILE GIVES A USER A SMALL INTERFACE TO QUERY SOLR FROM
### PYTHON, GIVEN THAT THE SOLR CORE IS NAMED ‘mimicIII’

#######



import json
import urllib


base = "http://localhost:8983/solr/mimicIII/select?indent=off&q={query}&rows={rows}&start={start}&wt=json"
def search_notes(query='*:*', rows=10, start=0, verbose=False):
    query = urllib.quote(query)
    url = base.format(query=query, start=start, rows=rows)
    response = urllib.urlopen(url)
    data = json.load(response)
    total_num = data['response']['numFound']
    if verbose:
        print 'real total', total_num
    while start < total_num:
        for doc in data['response']['docs']:
            print 'new doc'
            yield doc
        start += rows
        # if verbose:
        #     print start, '/', total_num
        url = base.format(query=query, start=start, rows=rows)
        print url
        response = urllib.urlopen(url)
        data = json.load(response)

    print len(data['response']['docs'])


if __name__ == '__main__':
    q = '"Fentanyl drip" AND "Respiratory failure" AND "Blood transfusion"'
    sid = []
    for r in search_notes(query=q, rows=2, verbose=True):
        sid.append(r['SUBJECT_ID'][0])
    print sid


