# Author: Ashish Mathai
import urllib3, json, jenkins, requests, re, time, os
from job_list import *
from datetime import datetime
from pytz import timezone
import pytz
import datetime as dt

# Pagerduty Email
Email = "<EMAIL>"
# Pagerduty API_KEY
api_key = "<API_KEY>"
# Jenkins  URL, Username, Password
jenkins_url = "<JENKINS_URL>"
j_username = "<JENKINS_USERNAME>"
j_password = "<JENKINS_PASSWORD>"

# Headers
headers = {
    "Accept": "application/vnd.pagerduty+json;version=2",
    "Authorization": "Token token={token}".format(token=api_key),
    "Content-type": "application/json",
    "From": Email
}

http = urllib3.PoolManager()
# API pagerduty url
pagerduty_url = "https://api.pagerduty.com/"
# PD service id,  service name
automata_service_id = "<PD_SERVICE_ID>"
automata_service_name = "<PD_SERVICE_NAME>"
# Webhook URL
webhook_url = "<WEBHOOK_URL>"

# Get PST time
def get_pst_time():
    date_format='%Y-%m-%d %H:%M:%S'
    date = datetime.now(tz=pytz.utc)
    date = date.astimezone(timezone('US/Pacific'))
    pstDateTime=date.strftime(date_format)
    return pstDateTime

# Get PST Date
def get_pst_date():
    date_format='%Y-%m-%d'
    date = datetime.now(tz=pytz.utc)
    date = date.astimezone(timezone('US/Pacific'))
    pstDate=date.strftime(date_format)
    return pstDate

# Fetching current time/date
def isNowInTimePeriod(current_time):
    dt = get_pst_date()
    date_format='%H:%M:%S'
    #Shift 1
    start_s1 = dt + " " + "09:00:00"
    end_s1 = dt + " " + "16:59:59"
    #Shift 2    
    start_s2 = dt + " " + "17:00:00"
    end_s2 = dt + " " + "00:59:59"
    #Shift 3    
    start_s3 = dt + " " + "01:00:00"
    end_s3 = dt + " " + "08:59:59"

    if current_time >= start_s1 and current_time <= end_s1:         # checking for Shift 1
        return False        
    elif current_time >= start_s3 and current_time <= end_s3:       # checking for Shift 3
        return False
    else:                                                           # checking for Shift 2
        return True    

# Get incident 
def get_incident(event):
    message = event["messages"]
    for i in message:
        incident_id = i["log_entries"][0]["incident"]["id"]
        service_id = i["log_entries"][0]["service"]["id"]
        service_name = i["log_entries"][0]["service"]["summary"]
        return incident_id, service_id, service_name

# Get incident status check
def incident_status_check(incident_id):
    url = "https://api.pagerduty.com/incidents/{id}".format(id=incident_id)
    res = requests.get(url, headers=headers)
    res_out = res.json()
    incident_status = res_out["incident"]["status"]
    return incident_status

# Get service id, service name
def service_filter(service_id, service_name):
    if service_id == automata_service_id and service_name == automata_service_name:
        check = "passed"
        return check
    else:
        check = "failed"    
        return check
        exit()

# Filtering alert
def alert_job_filter(api_incident_url, check):
    res = requests.get(api_incident_url, headers=headers)
    data = res.json()
    raw = data["incident"]["title"]
    if check == "passed" and "Build #" in raw:
        incident_title_contains = "build"
        return incident_title_contains
    else:
        exit()

# Ack incident
def incident_acknowledge(api_incident_url, incident_id):
    status = "acknowledged"
    if status.lower() == "acknowledged":
        payload = {"incident": {"type": "incident", "status": status}}
        res = http.request("PUT", api_incident_url, headers=headers, body=json.dumps(payload))
        if res.status == 200:
            return True
        else:
            return False

# Check jenkins jobs        
def check_job(api_incident_url, incident_id, build_name, build_number):
    url = "https://api.pagerduty.com/incidents/{id}/notes".format(id=incident_id)
    server = jenkins.Jenkins(jenkins_url, username=j_username, password=j_password)
    if build_name in jobs_list:
        build_verify = server.get_job_name(build_name)
        if build_verify in jobs_list:
            build_content = server.get_build_console_output(build_verify, int(build_number))
            if "BUILD SUCCESSFUL" in build_content:
                incident_acknowledge(api_incident_url, incident_id)
                time.sleep(2)
                pattern_line1 = re.compile(r'BUILD SUCCESSFUL+\s+\w+\s+\d\w+\s+\d+\w', re.DOTALL)
                pattern_out_1 = pattern_line1.findall(build_content)
                required_build_out_1 = pattern_out_1[0]
                pattern_line2 = re.compile(r'\d+\s+actionable tasks:+\s+\d+\s+\w+', re.DOTALL)
                pattern_out_2 = pattern_line2.findall(build_content)
                required_build_out_2 = pattern_out_2[0]
                pattern_line3 = re.compile(r'Build step+\s+\W+\w+\s+\w+\s+\w+\W+\s+\w+\s+\w+\s+\w+\s+\w+\s+\w+', re.DOTALL)
                pattern_out_3 = pattern_line3.findall(build_content)
                required_build_out_3 = pattern_out_3[0]
                incident_note = build_name + " -- Build_No #" + str(build_number) + " Executed " + str(required_build_out_1) + " \n " + str(required_build_out_2) + " \n " + str(required_build_out_3) 
                payload = {"note": {"content": incident_note}}
                # Adding note
                res = requests.post(url, headers=headers, data=json.dumps(payload))
                if res.status_code == 201:
                    inc_resolve(api_incident_url)
                else:
                    print(False)                
            else:
                print("nothing")
                exit()
        else:
            exit()
    else:
        print("check whether the job exists")
        exit()

# Special condition Jobs expecting failed jobs
def special_condition(api_incident_url, incident_id, build_name, build_number, data):
    url = "https://api.pagerduty.com/incidents/{id}/notes".format(id=incident_id)
    server = jenkins.Jenkins(jenkins_url, username=j_username, password=j_password)
    build_content = server.get_build_console_output(build_name, int(build_number))
    failed_pattern = re.compile(r'BUILD FAILED', re.DOTALL)
    failed_out = failed_pattern.findall(build_content)
    required_build_out_1 = failed_out[0]
    special_condition_note = "This is expected failure and we are instructed to resolve the alert."
    payload = {"note": {"content": special_condition_note}}
    # Adding note
    res = requests.post(url, headers=headers, data=json.dumps(payload))
    if res.status_code == 201:
        inc_resolve(api_incident_url)
    else:
        print(False)

# Jobs which not getting verified in Jenkins
def check_s1(incident_id, api_incident_url, build_name, build_number):
    url = "https://api.pagerduty.com/incidents/{id}/notes".format(id=incident_id)
    s1_job_url = "https://build.erecyclingcorps.com/job/Prod%20-%20FIDO%20-%20Gradle%20-%20Job%20-%20%20Upload%20Promotion%20Esn/"
    curl_check = s1_job_url + build_number + "/console"
    res = requests.get(curl_check, auth=(j_username, j_password))
    data = res.text    
    pattern_line1 = re.compile(r'BUILD SUCCESSFUL+\s+\w+\s+\d\w+\s+\d+\w', re.DOTALL)
    pattern_out_1 = pattern_line1.findall(data)
    if "SUCCESSFUL" in data:
        incident_acknowledge(api_incident_url, incident_id)
        time.sleep(2)
        required_build_out_1 = pattern_out_1[0]
        pattern_line2 = re.compile(r'\d+\s+actionable tasks:+\s+\d+\s+\w+', re.DOTALL)
        pattern_out_2 = pattern_line2.findall(data)
        required_build_out_2 = pattern_out_2[0]
        pattern_line3 = re.compile(r'Build step+\s+\W+\w+\s+\w+\s+\w+\W+\s+\w+\s+\w+\s+\w+\s+\w+\s+\w+', re.DOTALL)
        pattern_out_3 = pattern_line3.findall(data)
        required_build_out_3 = pattern_out_3[0]
        incident_note = build_name + " -- Build_No #" + str(build_number) + " Executed " + str(required_build_out_1) + " \n " + str(required_build_out_2) + " \n " + str(required_build_out_3) 
        payload = {"note": {"content": incident_note}}
        # Adding note
        res = requests.post(url, headers=headers, data=json.dumps(payload))
        if res.status_code == 201:
            inc_resolve(api_incident_url)
        else:
            print(False)
    else:
        print("None")
        exit()

# Jobs which not getting verified in Jenkins
def check_s2(incident_id, api_incident_url, build_name, build_number):
    url = "https://api.pagerduty.com/incidents/{id}/notes".format(id=incident_id)
    s1_job_url = "https://build.erecyclingcorps.com/job/Prod%20-%20TELUS%20-%20Gradle%20-%20Job%20-%20%20Upload%20Promotion%20Esn/"  
    curl_check = s1_job_url + build_number + "/console"
    res = requests.get(curl_check, auth=(j_username, j_password))
    data = res.text
    pattern_line1 = re.compile(r'BUILD SUCCESSFUL+\s+\w+\s+\d\w+\s+\d+\w', re.DOTALL)
    pattern_out_1 = pattern_line1.findall(data)
    if "SUCCESSFUL" in data:
        incident_acknowledge(api_incident_url, incident_id)
        time.sleep(2)
        required_build_out_1 = pattern_out_1[0]
        pattern_line2 = re.compile(r'\d+\s+actionable tasks:+\s+\d+\s+\w+', re.DOTALL)
        pattern_out_2 = pattern_line2.findall(data)
        required_build_out_2 = pattern_out_2[0]
        pattern_line3 = re.compile(r'Build step+\s+\W+\w+\s+\w+\s+\w+\W+\s+\w+\s+\w+\s+\w+\s+\w+\s+\w+', re.DOTALL)
        pattern_out_3 = pattern_line3.findall(data)
        required_build_out_3 = pattern_out_3[0]
        incident_note = build_name + " -- Build_No #" + str(build_number) + " Executed " + str(required_build_out_1) + " \n " + str(required_build_out_2) + " \n " + str(required_build_out_3) 
        payload = {"note": {"content": incident_note}}
        # Adding note
        res = requests.post(url, headers=headers, data=json.dumps(payload))
        if res.status_code == 201:
            inc_resolve(api_incident_url)
        else:
            print(False)
    else:
        exit()

# Resolve incident
def inc_resolve(api_incident_url):
    status = "resolved"
    if status == "resolved":
        payload = {"incident": {"type": "incident", "status": status}}
        res = http.request("PUT", api_incident_url, headers=headers, body=json.dumps(payload))
    else:
        exit()
        
# Main function        
def pdtest(event, context):
    print("version: V")
    dt = get_pst_date()
    date_format='%H:%M:%S'
    dt1 = get_pst_time()
    shift_check = isNowInTimePeriod(dt1)
    print(shift_check)
    if shift_check == True:
        incident_data = get_incident(event)
        incident_id = incident_data[0]
        service_id = incident_data[1]
        service_name = incident_data[2]
        incident_status_data = incident_status_check(incident_id)
        if incident_status_data == "triggered":
            service_filter_data = service_filter(service_id, service_name)
            check = service_filter_data
            api_incident_url = pagerduty_url + "incidents/" + incident_id
            incident_title_contains = alert_job_filter(api_incident_url, check)
            incident_status = incident_status_check(incident_id)
            if check == "passed" and incident_title_contains == "build":
                res = requests.get(api_incident_url, headers=headers)
                data = res.json()
                raw = data["incident"]["title"]
                raw_data1 = raw.split(" - Build # ")
                build_name = raw_data1[0]
                raw_data2 = raw_data1[1].split(" - ")
                build_number = raw_data2[0]
                if build_name in jobs_list:
                    incident_status = incident_status_check(incident_id)
                    if incident_status == "triggered":
                        '''
                        if build_name == "PROD - BBY Warehouse - Retry Failed BBY Failed Response Job":
                            special_condition(api_incident_url, incident_id, build_name, build_number, data)
                        '''    
                        if build_name == "Prod - FIDO - Gradle - Job - Upload Promotion Esn":
                            check_s1(incident_id, api_incident_url, build_name, build_number)
                        elif build_name == "Prod - TELUS - Gradle - Job - Upload Promotion Esn":
                            check_s2(incident_id, api_incident_url, build_name, build_number)
                        else:
                            check_job(api_incident_url, incident_id, build_name, build_number)       
                    else:
                        print("Do nothing")
                        exit()
                else:
                    print("Build name not in list")
                    exit()
            else:
                print("Either check or build condition failed")
                exit()
        elif incident_status_data == "acknowledged":
            print("Already acknowledged, check alert manually")
            exit()
        
        else:
            print("Please check manually")
            exit()
            
    else:
        print("This Lambda wont execcute for current shift")
        exit()
