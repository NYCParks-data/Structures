import pandas as pd
import json
import urllib3
from urllib.parse import quote
from urllib.parse import quote_plus
import sys
sys.path.append('../')
from IPM_Shared_Code.Python.utils import get_config

urllib3.disable_warnings()
config = get_config('c:\Projects\config.ini')
geo_key = config['keys']['geosupport_key']
geo_ip = config['keys']['geosupport_ip']


# api_key = geo_key
grc_err = ['01/F', '20', '21', '22', '23']
out_keys = [
    'AddressRangeList', 'out_bbl', 'out_TPAD_bin', 'out_TPAD_bin_status',
    'out_TPAD_conflict_flag', 'out_error_message', 'out_grc',
    'out_sanborn_boro', 'in_bin', 'out_bbl_boro'
]


def funcbn(bn=None, out_keys=None, grc_err=None,api_key=None,ip=None):
    
    url = '{}/geoservice/geoservice.svc/Function_BIN?BIN={}&key={}'.format(ip, bn, geo_key)
    # print(url)
    #Encode the url, but allow the characters specified in the safe argument.
    url = quote(url, safe = ':/?&=')
    
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
        add_dict = [bin_dict]
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
        #return dicts

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

    for bn in in_bins:
        list_of_things.append(funcbn(bn, out_keys = out_keys, grc_err = grc_err, api_key = geo_key, ip = geo_ip))
    
    t = flat_list(list_of_things)
    
    strip_vals(t)
    add_ck(t)
    
    for dicts in t:
        if dicts['addressable'] == 'Addressable':
            new_dict = func1b(dicts['out_sanborn_boro'], dicts['high_address_number'], dicts['street_name'], geo_key, geo_ip)
            dicts.update(new_dict)
    
    strip_vals(t)        
    replace_na(t)
    
    return_df = pd.DataFrame(t)
    return return_df