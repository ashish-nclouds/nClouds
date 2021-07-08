# Author: Ashish Mathai 
import urllib3, json, jenkins, requests, re, time, boto3
from job_list import *
from datetime import datetime
from pytz import timezone
import pytz
import datetime as dt

# Jenkins URL
jenkins_url = "<JENKINS_URL>"

# Headers
headers = {
    "Accept": "application/vnd.pagerduty+json;version=2",
    "Authorization": "Token token={token}".format(token=api_key),
    "Content-type": "application/json",
    "From": Email
}

http = urllib3.PoolManager()
# Pagerduty URL
pagerduty_url = "<PD_API_URL>"
service_id = "<PD_SERVICE_ID>"
service_name = "<PD_SERVICE_NAME>"
# Webhook URL
webhook_url = "<WEBHOOK>"

# Get PST Time
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

    if current_time >= start_s1 and current_time <= end_s1:
        return True, "S1"
    elif current_time >= start_s3 and current_time <= end_s3:
        return True, "S3"
    else:
        return True, "S2"
# Fetching creds from Parameter Store for all 3 shifts
# SHIFT 1
def ssm_parameter_s1():
    ssm = boto3.client('ssm')
    parameter_email = ssm.get_parameter(Name='<SSM_PARAM_S1_EMAIL>', WithDecryption=True)
    parameter_api_key = ssm.get_parameter(Name='<SSM_PARAM_S1_API_KEY>', WithDecryption=True)
    parameter_j_username = ssm.get_parameter(Name='<SSM_PARAM_S1_USERNAME>', WithDecryption=True)
    parameter_j_password = ssm.get_parameter(Name='<SSM_PARAM_S1_PASSWORD>', WithDecryption=True)    
    Email = parameter_email["Parameter"]["Value"]
    api_key = parameter_api_key["Parameter"]["Value"]
    j_username = parameter_j_username["Parameter"]["Value"]
    j_password = parameter_j_password["Parameter"]["Value"]
    return Email, api_key, j_username, j_password
# SHIFT 2
def ssm_parameter_s2():
    ssm = boto3.client('ssm')
    parameter_email = ssm.get_parameter(Name='<SSM_PARAM_S2_EMAIL>', WithDecryption=True)
    parameter_api_key = ssm.get_parameter(Name='<SSM_PARAM_S2_API_KEY>', WithDecryption=True)
    parameter_j_username = ssm.get_parameter(Name='<SSM_PARAM_S2_USERNAME>', WithDecryption=True)
    parameter_j_password = ssm.get_parameter(Name='<SSM_PARAM_S2_PASSWORD>', WithDecryption=True)    
    Email = parameter_email["Parameter"]["Value"]
    api_key = parameter_api_key["Parameter"]["Value"]
    j_username = parameter_j_username["Parameter"]["Value"]
    j_password = parameter_j_password["Parameter"]["Value"]
    return Email, api_key, j_username, j_password
# SHIFT 3
def ssm_parameter_s3():
    ssm = boto3.client('ssm')
    parameter_email = ssm.get_parameter(Name='<SSM_PARAM_S3_EMAIL>', WithDecryption=True)
    parameter_api_key = ssm.get_parameter(Name='<SSM_PARAM_S3_API_KEY>', WithDecryption=True)
    parameter_j_username = ssm.get_parameter(Name='<SSM_PARAM_S3_USERNAME>', WithDecryption=True)
    parameter_j_password = ssm.get_parameter(Name='<SSM_PARAM_S3_PASSWORD>', WithDecryption=True)    
    Email = parameter_email["Parameter"]["Value"]
    api_key = parameter_api_key["Parameter"]["Value"]
    j_username = parameter_j_username["Parameter"]["Value"]
    j_password = parameter_j_password["Parameter"]["Value"]
    return Email, api_key, j_username, j_password

dt = get_pst_date()
date_format='%H:%M:%S'
dt1 = get_pst_time()
st_check = isNowInTimePeriod(dt1)
print(st_check[1])
if st_check[1] == "S1":
    param = ssm_parameter_s1()
    Email = param[0]
    api_key = param[1]
    j_username = param[2]
    j_password = param[3]
    
elif st_check[1] == "S2":
    param = ssm_parameter_s2()
    Email = param[0]
    api_key = param[1]
    j_username = param[2]
    j_password = param[3]

elif st_check[1] == "S3":
    param = ssm_parameter_s3()
    Email = param[0]
    api_key = param[1]
    j_username = param[2]
    j_password = param[3]

# Get Incident information
def get_incident(event):
    message = event["messages"]
    for i in message:
        incident_id = i["log_entries"][0]["incident"]["id"]
        service_id = i["log_entries"][0]["service"]["id"]
        service_name = i["log_entries"][0]["service"]["summary"]
        return incident_id, service_id, service_name

# Incident status check
def incident_status_check(incident_id):
    url = "https://api.pagerduty.com/incidents/{id}".format(id=incident_id)
    res = requests.get(url, headers=headers)
    res_out = res.json()
    incident_status = res_out["incident"]["status"]
    return incident_status
    
# Get Service details
def service_filter(service_id, service_name):
    if service_id == automata_service_id and service_name == automata_service_name:
        check = "passed"
        return check
    else:
        check = "failed"    
        return check
        exit()

def alert_job_filter(api_incident_url, check):
    res = requests.get(api_incident_url, headers=headers)
    data = res.json()
    raw = data["incident"]["title"]
    if check == "passed" and "Build #" in raw:
        incident_title_contains = "build"
        return incident_title_contains
    elif check == "passed" and (raw == "Migration Status in Both Direction -TELUS" or raw == "Migration Status in Both Direction -TELUS Confirmation"):
        return raw
    else:
        exit()

def incident_acknowledge(api_incident_url, incident_id):
    status = "acknowledged"
    if status.lower() == "acknowledged":
        payload = {"incident": {"type": "incident", "status": status}}
        res = http.request("PUT", api_incident_url, headers=headers, body=json.dumps(payload))
        if res.status == 200:
            return True
        else:
            return False

def check_job(api_incident_url, incident_id, build_name, build_number):
    url = "https://api.pagerduty.com/incidents/{id}/notes".format(id=incident_id)
    server = jenkins.Jenkins(jenkins_url, username=j_username, password=j_password)
    if build_name in jobs_list:
        build_verify = server.get_job_name(build_name)
        if build_verify in jobs_list:
            build_content = server.get_build_console_output(build_verify, int(build_number))
            if "BUILD SUCCESSFUL" in build_content:
                incident_acknowledge(api_incident_url, incident_id)
                time.sleep(3)
                pattern_line1 = re.compile(r'BUILD SUCCESSFUL+\s+\w+\s+\d\w+\s+\d+\w', re.DOTALL)
                pattern_out_1 = pattern_line1.findall(build_content)
                required_build_out_1 = pattern_out_1[0]
                incident_note = build_name + " -- Build_No #" + str(build_number) + " Executed " + str(required_build_out_1)
                payload = {"note": {"content": incident_note}}
                res = requests.post(url, headers=headers, data=json.dumps(payload))
                if res.status_code == 201:
                    inc_resolve(api_incident_url)
                else:
                    print(False)  
                    exit()
            else:
                exit()
        else:
            exit()
    else:
        exit()

def special_condition(api_incident_url, incident_id, build_name, build_number, data):
    url = "https://api.pagerduty.com/incidents/{id}/notes".format(id=incident_id)
    server = jenkins.Jenkins(jenkins_url, username=j_username, password=j_password)
    build_content = server.get_build_console_output(build_name, int(build_number))
    failed_pattern = re.compile(r'BUILD FAILED', re.DOTALL)
    failed_out = failed_pattern.findall(build_content)
    required_build_out_1 = failed_out[0]
    special_condition_note = "This is expected failure and we are instructed to resolve the alert."
    payload = {"note": {"content": special_condition_note}}
    res = requests.post(url, headers=headers, data=json.dumps(payload))
    if res.status_code == 201:
        inc_resolve(api_incident_url)
    else:
        print(False)
        exit()

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
        time.sleep(3)
        required_build_out_1 = pattern_out_1[0]
        incident_note = build_name + " -- Build_No #" + str(build_number) + " Executed " + str(required_build_out_1)
        payload = {"note": {"content": incident_note}}
        res = requests.post(url, headers=headers, data=json.dumps(payload))
        if res.status_code == 201:
            inc_resolve(api_incident_url)
        else:
            print(False)
            exit()
    else:
        exit()

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
        time.sleep(3)
        required_build_out_1 = pattern_out_1[0]
        incident_note = build_name + " -- Build_No #" + str(build_number) + " Executed " + str(required_build_out_1)
        payload = {"note": {"content": incident_note}}
        res = requests.post(url, headers=headers, data=json.dumps(payload))
        if res.status_code == 201:
            inc_resolve(api_incident_url)
        else:
            print(False)
            exit()
    else:
        exit()

def sp_telus(api_incident_url, incident_id, build_name, raw):
    url = "https://api.pagerduty.com/incidents/{id}/notes".format(id=incident_id)
    ack_url = api_incident_url
    server = jenkins.Jenkins(jenkins_url, username=j_username, password=j_password)
    build_raw_data = server.get_job_info(build_name)
    build_no = build_raw_data['lastFailedBuild']['number']
    build_content = server.get_build_console_output(build_name, int(build_no))
    if "BUILD SUCCESSFUL" in build_content:
        incident_acknowledge(ack_url, incident_id)
        time.sleep(3)
        pattern_line1 = re.compile(r'BUILD SUCCESSFUL+\s+\w+\s+\d\w+\s+\d+\w', re.DOTALL)
        pattern_out_1 = pattern_line1.findall(build_content)
        required_build_out_1 = pattern_out_1[0]
        incident_note = "Build: " + build_name + " | " + pattern_out_1[0] + "|, resolving the Alert"
        payload = {"note": {"content": incident_note}}
        res = requests.post(url, headers=headers, data=json.dumps(payload))
        if res.status_code == 201:
            inc_resolve(api_incident_url)
        else:
            print(False)
            exit()
    else:
        exit()

def sp_telus2(api_incident_url, incident_id, build_name, build_number, raw):
    url = "https://api.pagerduty.com/incidents/{id}/notes".format(id=incident_id)
    ack_url = api_incident_url
    server = jenkins.Jenkins(jenkins_url, username=j_username, password=j_password)
    if build_name in jobs_list:
        build_verify = server.get_job_name(build_name)
        if build_verify in jobs_list:
            build_content = server.get_build_console_output(build_verify, int(build_number))
            if "Finished: FAILURE" in build_content:
                sp_build_name = "Prod - TELUS Warehouse - Gradle - Retry Failed Migration Job At Warehouse"
                if sp_build_name in build_content:
                    sp_build_raw_data = server.get_job_info(sp_build_name)
                    sp_build_no = sp_build_raw_data['lastFailedBuild']['number']
                    sp_build_content = server.get_build_console_output(sp_build_name, int(sp_build_no))
                    if "BUILD SUCCESSFUL" in sp_build_content:
                        incident_acknowledge(ack_url, incident_id)
                        time.sleep(3)
                        pattern_line1 = re.compile(r'BUILD SUCCESSFUL+\s+\w+\s+\d\w+\s+\d+\w', re.DOTALL)
                        pattern_out_1 = pattern_line1.findall(sp_build_content)
                        required_build_out_1 = pattern_out_1[0]
                        incident_note = "Build: " + build_name + " is Finished: Failure, but the dependent job finished Successfully, [Build Name: " + sp_build_name + " - Out - " + " | " + pattern_out_1[0] + "| ], resolving the Alert"
                        payload = {"note": {"content": incident_note}}
                        res = requests.post(url, headers=headers, data=json.dumps(payload))
                        if res.status_code == 201:
                            inc_resolve(api_incident_url)
                        else:
                            print(False)
                            exit()
                    else:
                        exit()
                else:
                    exit()
            else:
                exit()
        else:
            exit()
    else:
        exit()


def sp_telus_confirmation(api_incident_url, incident_id, raw):
    url = "https://api.pagerduty.com/incidents/{id}/notes".format(id=incident_id)
    server = jenkins.Jenkins(jenkins_url, username=j_username, password=j_password)
    # Build 1
    build1_name = "Prod - Telus - Gradle - Retry CEW to CE Migration"
    build1_raw_data = server.get_job_info(build1_name)
    build1_number = build1_raw_data['lastFailedBuild']['number']
    build1_raw_data = server.get_job_info(build1_name)
    build1_number = build1_raw_data['lastFailedBuild']['number']
    build1_content = server.get_build_console_output(build1_name, int(build1_number))
    if "BUILD SUCCESSFUL" in build1_content:
        check1 = "success"
        pattern1_line1 = re.compile(r'BUILD SUCCESSFUL+\s+\w+\s+\d\w+\s+\d+\w', re.DOTALL)
        pattern1_out_1 = pattern1_line1.findall(build1_content)
        required1_build_out_1 = pattern1_out_1[0]
    else:
        check1 = "failed"
    # Build 2
    build2_name = "Prod - FIDO - Gradle - Retry CEW to CE Migration"
    build2_raw_data = server.get_job_info(build2_name)
    build2_number = build2_raw_data['lastFailedBuild']['number']
    build2_raw_data = server.get_job_info(build2_name)
    build2_number = build2_raw_data['lastFailedBuild']['number']
    build2_content = server.get_build_console_output(build2_name, int(build2_number))
    if "BUILD SUCCESSFUL" in build2_content:
        check2 = "success"
        pattern2_line1 = re.compile(r'BUILD SUCCESSFUL+\s+\w+\s+\d\w+\s+\d+\w', re.DOTALL)
        pattern2_out_1 = pattern2_line1.findall(build2_content)
        required2_build_out_1 = pattern2_out_1[0]
    else:
        check2 = "failed"
    if check1 == "success" and check2 == "success":
        ack_url = api_incident_url
        incident_acknowledge(ack_url, incident_id)
        time.sleep(3)
        sp_telus_confirmation_note = "Both builds " + build1_name + "|" + str(build1_number) + "|" + " and " + build2_name + "|" + str(build2_number) + "|" + " are successful"
        payload = {"note": {"content": sp_telus_confirmation_note}}
        res = requests.post(url, headers=headers, data=json.dumps(payload))
        if res.status_code == 201:
            inc_resolve(api_incident_url)
        else:
            print(False)        
    else:
        print(False)
        exit()

def inc_resolve(api_incident_url):
    status = "resolved"
    if status == "resolved":
        payload = {"incident": {"type": "incident", "status": status}}
        res = http.request("PUT", api_incident_url, headers=headers, body=json.dumps(payload))
    else:
        print("Resolve alert manually")
        exit()
        
# Main function        
def pdtest(event, context):
    incident_data = get_incident(event)
    incident_id = incident_data[0]
    service_id = incident_data[1]
    service_name = incident_data[2]
    api_incident_url = pagerduty_url + "incidents/" + incident_id
    check = service_filter(service_id, service_name)
    incident_title_contains = alert_job_filter(api_incident_url, check)
    if check == "passed" and (incident_title_contains == "build" or incident_title_contains == "Migration Status in Both Direction -TELUS" or incident_title_contains == "Migration Status in Both Direction -TELUS Confirmation"):
        dt = get_pst_date()
        date_format='%H:%M:%S'
        dt1 = get_pst_time()
        shift_check = isNowInTimePeriod(dt1)
        print(shift_check)
        if shift_check[0] == True:
            incident_status_data = incident_status_check(incident_id)
            if incident_status_data == "triggered":
                res = requests.get(api_incident_url, headers=headers)
                data = res.json()
                raw = data["incident"]["title"]
                raw_data1 = raw.split(" - Build # ")
                if "Build" in raw:
                    if raw_data1[0] == "TELUSWH Prod - TELUS Warehouse - Item Migration - from Artifiact":
                        sp1_raw_data = raw_data1[0].split("TELUSWH ")
                        build_name = sp1_raw_data[1]
                        raw_data2 = raw_data1[1].split(" - ")
                        build_number = raw_data2[0]
                    else:
                        build_name = raw_data1[0]
                        raw_data2 = raw_data1[1].split(" - ")
                        build_number = raw_data2[0]
                else:
                    print("Not jenkins build alert, checking for Migration TELUS alert")

                if raw == "Migration Status in Both Direction -TELUS":
                    build_name = "Prod - TELUS Warehouse - Gradle - Retry Failed Migration Job At Warehouse"
                    sp_telus(api_incident_url, incident_id, build_name, raw)
                elif raw == "Migration Status in Both Direction -TELUS Confirmation":
                    sp_telus_confirmation(api_incident_url, incident_id, raw)
                elif build_name == "Prod - TELUS Warehouse - Item Migration - from Artifiact":
                    sp_telus2(api_incident_url, incident_id, build_name, build_number, raw)
                elif build_name in jobs_list:
                    check_job(api_incident_url, incident_id, build_name, build_number)
                elif build_name == "Prod - FIDO - Gradle - Job - Upload Promotion Esn":
                    check_s1(incident_id, api_incident_url, build_name, build_number)
                elif build_name == "Prod - TELUS - Gradle - Job - Upload Promotion Esn":
                    check_s2(incident_id, api_incident_url, build_name, build_number)
                else:
                    exit()
            else:
                exit()
        else:
            exit()
    else:
        exit()
