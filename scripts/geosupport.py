import pandas as pd
import json
import urllib3
from urllib.parse import quote
from urllib.parse import quote_plus
import sys
sys.path.append('../')
from IPM_Shared_Code_public.Python.utils import get_config
from get_address_points import *

urllib3.disable_warnings()
config = get_config('c:\Projects\config.ini')
geo_key = config['keys']['geosupport_key']
geo_ip = config['keys']['geosupport_ip']


# api_key = geo_key
grc_err = ['01/F', '20', '21', '22', '23']
out_keys = [
    'AddressRangeList', 'out_bbl', 'out_TPAD_bin', 'out_TPAD_bin_status',
    'out_TPAD_conflict_flag', 'out_error_message', 'out_grc',
    'out_sanborn_boro', 'in_bin', 'out_boro_name1'
]


def funcbn(bn=None, out_keys=None, grc_err=None,api_key=None,ip=None):
    
    url = '{}/geoservice/geoservice.svc/Function_BIN?BIN={}&key={}'.format(ip, bn, geo_key)
    # print(url)
    #Encode the url, but allow the characters specified in the safe argument.
    url = quote(url, safe = ':/?&=')
    # print(url)
    geo_dict = {}
    obj_to_return = {}
    #Establish the connection
    http = urllib3.PoolManager()
    try:
        #Send the get request to the AWS API and retrieve the response
        response = http.request('GET', url)
        
        #Load the JSON that is returned keeping only the values in the display key
        raw_dict = json.loads(response.data).get('display')

        #Keep only the dictionary keys the function caller wants to retain
        geo_dict = {k: raw_dict[k] for k in out_keys}

        if geo_dict['out_grc'].strip() in grc_err:
            #bin_dict.update(geo_dict)
            obj_to_return['bin'] = bn
            del geo_dict['AddressRangeList']
            obj_to_return.update(geo_dict)
        else:
            geo_dict2 = geo_dict.copy()
            del geo_dict2['AddressRangeList']
            for i in geo_dict['AddressRangeList']:
                i.update(geo_dict2)
            obj_to_return = geo_dict['AddressRangeList']
        
    except:       
        print('exception!')
        #Set the output equal to the input BIN so that no information is lost
        add_dict = [bn]
    # returns either list or dict:
    return obj_to_return


def func1b(borough=None, addressno=None, streetname=None, api_key=None, ip=None):
    url = ('{}/geoservice/geoservice.svc/Function_1B?Borough={}&AddressNo={}&StreetName={}&key={}'.
           format(ip, borough, addressno, streetname, geo_key))
    #Encode the url, but allow the characters specified in the safe argument.
    url = quote(url, safe = ':/?&=')
    
    #print('Checking Addresses: {} {} {}'.format(borough, addressno, streetname))
    #Feed in the url with the BIN and the API Key and read the results
    http = urllib3.PoolManager()
    response = http.request('GET', url)

    #If any of these Return Codes are output then send the (includes all return codes for functions 1, 1A, 1B and 1E)
    #REFERENCE: https://nycplanning.github.io/Geosupport-UPG/appendices/appendix01/#function-1
    out_grc = ['01/E', '01/V', '01/P', '01/8', '01/A', '??/1', 
               '04', '07', '28', '29' '41', '42', '50', '56', 
               '69/B', '73', '75', '89', '90']

    #Create a tuple of the keys that need to be retained
    out_keys = ('out_zip_code', 'out_hurricane_zone', 'out_co', 'out_cd', 
                'out_sd','out_nta', 'out_ad', 'out_com_dist', 'out_fire_bat', 
                'out_fire_co', 'out_fire_co_str', 'out_fire_div', 'out_b10sc1',
                'out_police_patrol_boro', 'out_police_area', 'out_police_pct', 
                'out_san_sched', 'out_san_dist_section', 'out_san_recycle', 'out_san_reg', 'out_san_org_pick_up',
                'out_usps_city_name', 'out_preferred_lgc', 'out_sos_ind', 'out_physical_id')

    #Load the dictionary nested in the display dictionary
    raw_dict = json.loads(response.data).get('display')

    #Only keep the keys that are needed
    geo_dict = {k: raw_dict[k] for k in out_keys}

    return geo_dict

def funcap(borough=None, addressno=None, streetname=None, api_key=None, ip=None):
    url = ('{}/geoservice/geoservice.svc/Function_AP?Borough={}&AddressNo={}&StreetName={}&key={}'.
           format(ip, borough, addressno, streetname, api_key))
    #Encode the url, but allow the characters specified in the safe argument.
    url = quote(url, safe = ':/?&=')
    
    #print('Checking Addresses: {} {} {}'.format(borough, addressno, streetname))
    #Feed in the url with the BIN and the API Key and read the results
    http = urllib3.PoolManager()
    response = http.request('GET', url)

    #If any of these Return Codes are output then send the (includes all return codes for functions 1, 1A, 1B and 1E)
    #REFERENCE: https://nycplanning.github.io/Geosupport-UPG/appendices/appendix01/#function-1
    out_grc = ['42', '50', '75']

    #Create a tuple of the keys that need to be retained
    out_keys = ('out_ap_id',)

    #Load the dictionary nested in the display dictionary
    raw_dict = json.loads(response.data).get('display')
    
    #Only keep the keys that are needed
    geo_dict = {k: raw_dict[k] for k in out_keys}

    return geo_dict

def func1n(borough=None, streetname=None, api_key=None, ip=None):
    #Normalize the street names
    url = ('{}/geoservice/geoservice.svc/Function_1N?Borough={}&StreetName={}&key={}'.
           format(ip, borough, streetname, geo_key))
    #Encode the url, but allow the characters specified in the safe argument.
    url = quote(url, safe = ':/?&=')
    
 
    #Feed in the url with the BIN and the API Key and read the results
    http = urllib3.PoolManager()
    response = http.request('GET', url)

    #Create a tuple of the keys that need to be retained
    out_keys = ('out_boro_name1', 'out_grc', 'out_stname1')

    #Load the dictionary nested in the display dictionary
    raw_dict = json.loads(response.data).get('display')

    #Only keep the keys that are needed
    geo_dict = {k: raw_dict[k] for k in out_keys}

    return geo_dict

def flat_list(in_list=None):
    
    #This function will take the return from Geosupport Function BN aka BIN and make the return all of the same type.
    #The raw return could produce a mixed list that contains a list of length 1 with 1 dictionary, a list of length 
    #1+n with 1+n dictionaries or simply a dictionary (if a GRC code is encountered).
    
    #Initialize the new list
    new_list = []
    
    #Iterate through the input list elements
    for i in in_list:
        #If the element is a list instance/type then check the length.
        if isinstance(i, list):
            #If the list contains more than one element (length > 1) then extract each element and append as a
            #type list element to the new list.
            if len(i) > 1:
                for j in i:
                    new_list.append([j])
            else:
            #Otherwise append the single type list element to the new list.
                new_list.append(i)
        #If the element is not a list instance/type (it will be a dict) then append as a type list element to the new
        #list.
        else:
            new_list.append([i])
    #new_list is now a list of lists with each inner list containing a single dictionary.
    
    #Flatten the list of list so that the return is a list of dictionaries and the inner list is removed.
    #Extract all inner list elements (dictionaries) from the outer list element.
    return_list = [inner_el for outer_el in new_list for inner_el in outer_el]
    
    #Return the flattened list.
    return return_list

#Define a function that strips the leading and trailing spaces from the returned values of the dictionaries
def strip_vals(in_list):
    for dicts in in_list:
        dicts.update((k, v.strip()) for k, v in dicts.items() if isinstance(v, str) )
        # return dicts

def replace_na(in_list):
    for dicts in in_list:
        dicts.update((k, None) for k, v in dicts.items() if v == 'N/A' or (isinstance(v, str) and v == ''))
        #return dicts

def add_ck(in_list):
    for dicts in in_list:
        if dicts['out_grc'].strip('00') == '':
            
            #Check for equality and validity of low and high house number. The low and high house numbers need cannot be blank and
            #must be equal to use as input into function 1.
            if (dicts['high_address_number'].strip() == dicts['low_address_number'].strip() and 
               (dicts['high_address_number'].strip() != '' and dicts['low_address_number'].strip() != '')):          
                add_val = {'addressable': 'Addressable'}
                
            #If the low and high range are not equal then the record should not be input into function 1.
            else:
                add_val = {'addressable': 'Non-Addressable, Range'}
                
        
        else:
            add_val = {'addressable':'Non-Addressable: {}'.format(dicts['out_error_message'].strip())}
            
        dicts.update(add_val)
    #return dicts

def master_geosupport_func(in_bins):
    list_of_things = []
    
    #Add address point Open Data Function Call

    #Add function call for 1N to normalize addresses and strip_vals to remove white space

    #In 1N we want to keep out_boro_name1 out_st_name1

    for bn in in_bins:
        list_of_things.append(funcbn(bn, out_keys = out_keys, grc_err = grc_err, api_key = geo_key, ip = geo_ip))
    
    t = flat_list(list_of_things)
    
    strip_vals(t)
    
    ##Combine output of 1N and BN and deduplicate those records based on Borough, High House Number, Low House Number, Street Name and Hyphen Type
    
    add_ck(t)
    
    for dicts in t:
        if dicts['addressable'] == 'Addressable':
            new_dict = func1b(dicts['out_boro_name1'], dicts['high_address_number'], dicts['street_name'], geo_key, geo_ip)
            dicts.update(new_dict)
            new_dict = funcap(dicts['out_boro_name1'], dicts['high_address_number'], dicts['street_name'], geo_key, geo_ip)
            dicts.update(new_dict)
    
    
    strip_vals(t)        
    replace_na(t)
    
    return_df = pd.DataFrame(t)
    return return_df


def master_geosupport_func2(structs_df):
    # list_of_things = []
    # list_of_things2 = []
    
    #Add address point Open Data Function Call
    funcap_outputs = structs_df.apply(lambda row: get_address_point2(row['bin'],
              geom_col = 'the_geom'),axis =1)
    aps_gdf = gpd.GeoDataFrame(flat_list(funcap_outputs), geometry = 'the_geom',crs = 'epsg:4326').fillna(np.nan)
    aps = aps_gdf[~pd.isnull(aps_gdf['the_geom'])].to_crs('epsg:2263').copy()

    # aps, failed_bins = get_address_point(in_bins, geom_col = 'the_geom')
    # bins_w_aps = aps.bin.values
    
    #Add function call for 1N to normalize addresses and strip_vals to remove white space


    #In 1N we want to keep out_boro_name1 out_st_name1
    func1N_outputs = aps.apply(lambda row: func1n(borough=row['borocode'],
                             streetname=row['full_stree'],
                             api_key=geo_key,
                             ip=geo_ip),axis =1)
    list_1N = flat_list(func1N_outputs)
    strip_vals(list_1N)
    func1N_out_df = pd.DataFrame(list_1N)
    aps_1N_df = aps.join(func1N_out_df)


    # function BN:
    funcBN_outputs = structs_df.apply(lambda row: funcbn(row['bin'],
              out_keys=out_keys,
              grc_err=grc_err,
              api_key=geo_key,
              ip=geo_ip),axis =1)
    t = flat_list(funcBN_outputs)
    strip_vals(t)
    BN_out_df = pd.DataFrame(t)
    # for bn in in_bins:
    #     list_of_things.append(funcbn(bn, out_keys = out_keys, grc_err = grc_err, api_key = geo_key, ip = geo_ip))
    
    # t = flat_list(list_of_things)
    
    ##Combine output of 1N and BN and deduplicate those records based on Borough, High House Number, Low House Number, Street Name and Hyphen Type
    aps_1N_df['high_address_number'] = aps_1N_df['h_no']
    aps_1N_df['low_address_number'] = aps_1N_df['h_no']
    aps_1N_df.rename(columns = {'out_stname1':'street_name'},inplace = True)
    cols_to_match = ['bin','high_address_number','low_address_number','street_name','out_boro_name1']
    df1 = aps_1N_df[cols_to_match+['address_id']]
    df2 = BN_out_df
    combined_deduped = pd.concat([df1,df2]).drop_duplicates(cols_to_match,keep='last')
    combined = pd.concat([df1,df2])
    df_w_ap_ids = pd.concat(g for _, 
        g in combined.groupby(cols_to_match) if len(g) > 1).drop_duplicates(cols_to_match,keep='first')
    df_new = combined_deduped.merge(df_w_ap_ids,how = 'left',suffixes=('', '_y'), 
                       left_on = cols_to_match, right_on=cols_to_match)
    df_new.address_id.fillna(df_new.address_id_y, inplace=True)
    df_new.drop(df_new.filter(regex='_y$').columns.tolist(),axis=1, inplace=True)


    # add_ck(t)
    
    # for dicts in t:
    #     if dicts['addressable'] == 'Addressable':
    #         new_dict = func1b(dicts['out_boro_name1'], dicts['high_address_number'], dicts['street_name'], geo_key, geo_ip)
    #         dicts.update(new_dict)
    #         new_dict = funcap(dicts['out_boro_name1'], dicts['high_address_number'], dicts['street_name'], geo_key, geo_ip)
    #         dicts.update(new_dict)
    
    
    # strip_vals(t)        
    # replace_na(t)
    
    return_df = df_new #pd.DataFrame(t)
    return return_df