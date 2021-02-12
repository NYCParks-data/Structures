import json
from urllib.parse import quote
import requests
import geopandas as gpd
from shapely.geometry import shape
import numpy as np


def print_url():
    parent_url = 'https://data.cityofnewyork.us/api/views/g6pj-hd8k'
    parent_response = requests.get(parent_url).json()
    child_id = parent_response['childViews'][0]
    print(child_id)

def get_address_point(bin, geom_col):
    failed = []
    add_pts = []
    parent_url = 'https://data.cityofnewyork.us/api/views/g6pj-hd8k'
    parent_response = requests.get(parent_url).json()
    child_id = parent_response['childViews'][0]

    #Add the provided bin to the api query.
    url ='http://data.cityofnewyork.us/resource/{}.json?bin={}'.format(child_id,bin)
    # url = 'http://data.cityofnewyork.us/resource/7xhx-ywii.json?bin={}'.format(bin)

    #Encode the url, but allow the characters specified in the safe argument.
    url = quote(url, safe = ':/?&=')

    try:
        #Send the get request to Socrata and return the results as a json
        response = json.loads(json.dumps(requests.get(url).json()))
        
        if len(response) > 0:
            #Iterate through the items in the response json
            for r in response:
                #Convert the geometry value to a shapely geometry
                r[geom_col] = shape(r[geom_col])
                #Append the response to the address points list
                add_pts.append(r)
        
        else:
            add_pts.append({'bin':bin, geom_col: np.nan})
            #pass

    except:
        #Append only the bin for records where the bins don't have a corresponding address point
        #add_pts.append([{'bin':bin}])
        failed.append(bin)

    return add_pts