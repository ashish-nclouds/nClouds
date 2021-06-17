import urllib3, json, jenkins, requests, re, time
from flatten_json import flatten

# Pagerduty user email and API key
Email = "<EMAIL>"
api_key = "<API-KEY>"

# Jenkins Credentials
j_user = "<JENKINS_USER>"
j_password = "<JENKINS_PASSWORD>"

# Jenkins URL
jenkins_url = "<JENKINS_URL>"

headers = {
    "Accept": "application/vnd.pagerduty+json;version=2",
    "Authorization": "Token token={token}".format(token=api_key),
    "Content-type": "application/json",
    "From": Email
}

http = urllib3.PoolManager()
pagerduty_url = "https://api.pagerduty.com/"

def build_details(event):
    message = event["body"]["messages"]
    for i in message:
        INCIDENT_ID = i["log_entries"][0]["incident"]["id"]
        print (INCIDENT_ID)
        SUMMARY = i["log_entries"][0]["incident"]["summary"]
        print (SUMMARY)
        D0 = SUMMARY.split('] ')
        D1 = D0[1].split(' - Build ')
        JOB_NAME = D1[0]
        D2 = re.findall(r'\d+', D1[1])
        BUILD_NUMBER = D2[0]
        SERVICE = i["log_entries"][0]["service"]["id"]
        print ("Jenkins job Name: ", JOB_NAME)
        print ("Build Number: ",  BUILD_NUMBER)
        return JOB_NAME, BUILD_NUMBER, SERVICE, INCIDENT_ID


def get_incident_status(incident_id):
    url = "https://api.pagerduty.com/incidents/{id}".format(id=incident_id)
    headers = {
        "Accept": "application/vnd.pagerduty+json;version=2",
        "Authorization": "Token token={token}".format(token=api_key),
    }
    res = requests.get(url, headers=headers)
    print('Status Code: {code}'.format(code=res.status_code))
    res_out = res.json()
    flat_json_out = flatten(res_out)
    incident_status = flat_json_out["incident_status"]
    return incident_status


def incident_ack(post_url, Incident_Status):
    print("Executing inc_ack function")
    status = "acknowledged"
    print(Incident_Status)
    if Incident_Status == "triggered":
        if status.lower() == "acknowledged":
            print("Executing if alert == triggered")
            payload = {"incident": {"type": "incident", "status": status}}
            res = http.request("PUT", post_url, headers=headers, body=json.dumps(payload))
            print("incident_ack Status: {res_status}".format(res_status=res.status))
            get_incident_status()
    elif Incident_Status == "acknowledged":
        print("Incident_note function will add note")

def incident_note(Incident_Status_before_note, incident_id, build_name, build_number):
    print("Executing incident_note function")
    if Incident_Status_before_note == "acknowledged":
        status = "acknowledged"
        if status.lower() == "acknowledged":
            url = "https://api.pagerduty.com/incidents/{id}/notes".format(id=incident_id)
            server = jenkins.Jenkins(jenkins_url, username=j_user, password=j_password)
            build_content = server.get_build_console_output(build_name, int(build_number))
            pattern_line1 = re.compile(r'BUILD SUCCESSFUL+\s+\w+\s+\d\w+\s+\d+\w', re.DOTALL)
            pattern_out_1 = pattern_line1.findall(build_content)
            required_build_out_1 = pattern_out_1[0]
            pattern_line2 = re.compile(r'\d+\s+actionable tasks:+\s+\d+\s+\w+', re.DOTALL)
            pattern_out_2 = pattern_line2.findall(build_content)
            required_build_out_2 = pattern_out_2[0]
            pattern_line3 = re.compile(r'Build step+\s+\W+\w+\s+\w+\s+\w+\W+\s+\w+\s+\w+\s+\w+\s+\w+\s+\w+', re.DOTALL)
            pattern_out_3 = pattern_line3.findall(build_content)
            required_build_out_3 = pattern_out_3[0]
            incident_note = build_name + " -- Build_No #" + str(build_number) + " Executed " + str(
                required_build_out_1) + " \n " + str(required_build_out_2) + " \n " + str(required_build_out_3)
            print("printing required build out: " + incident_note)
            payload = {"note": {"content": incident_note}}
            res = requests.post(url, headers=headers, data=json.dumps(payload))
            print("incident_note Status: {out_code} ".format(out_code=res.status_code))
        else:
            print("Check job and add note manually")

def incident_resolve(post_url, Incident_Status):
    print("Executing incident_resolve function")
    status = "resolved"
    if status == "resolved":
        payload = {"incident": {"type": "incident", "status": status}}
        res = http.request("PUT", post_url, headers=headers, body=json.dumps(payload))
        print("incident_resolve Status: {code}".format(code=res.status))
    else:
        print("Resolve alert manually")

def pdtest(event, context):
    DATA = build_details(event)
    build_name = DATA[0]
    build_no = DATA[1]
    service = DATA[2]
    Incident_ID = DATA[3]
    post_url = pagerduty_url + "incidents/" + Incident_ID
    print(post_url)
    Incident_Status_before_note = get_incident_status(Incident_ID)
    Incident_Status = get_incident_status(Incident_ID)
    if service == PD_SERVICE_ID:
        print (Incident_Status)
        if Incident_Status == "triggered":
            incident_ack(post_url, Incident_Status)
            incident_note(Incident_Status_before_note, Incident_ID, build_name, build_no)
            incident_resolve(post_url, Incident_Status)
        elif Incident_Status == "acknowledged":
            incident_note(Incident_Status_before_note, Incident_ID, build_name, build_no)
            incident_resolve(post_url, Incident_Status)
        else:
            print ("Check Function again")
