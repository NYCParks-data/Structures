import json
from urllib.parse import quote
import requests
import geopandas as gpd
from shapely.geometry import shape
import numpy as np

def get_address_point(bins, geom_col):
    failed = []
    add_pts = []

    for b in bins:
        url = 'http://data.cityofnewyork.us/resource/5r2a-fpey.json?bin={}'.format(b)
        # url = 'http://data.cityofnewyork.us/resource/n86c-vq2h?bin={}'.format(b)
        #Encode the url, but allow the characters specified in the safe argument.
        url = quote(url, safe = ':/?&=')

        try:
            #Send the get request to Socrata and return the results as a json
            response = json.loads(json.dumps(requests.get(url).json()))[0]
            # print(response)
            response['the_geom'] = shape(response['the_geom'])
            #Append the response to the address points list
            add_pts.append(response)

        except:
            #Append the bins without records to the failed list
            failed.append(b)
            
    add_pts_df = (gpd.GeoDataFrame(add_pts, crs = 'epsg:4326')
                  .set_geometry(geom_col)
                  .fillna(np.nan))

    add_pts_df = add_pts_df.to_crs('epsg:2263')

    return add_pts_df, failed

def get_address_point2(bin, geom_col):
    failed = []
    add_pts = []

    #Add the provided bin to the api query.
    url = 'http://data.cityofnewyork.us/resource/5r2a-fpey.json?bin={}'.format(bin)

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