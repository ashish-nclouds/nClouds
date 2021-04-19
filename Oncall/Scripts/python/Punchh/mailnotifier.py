import json, imaplib, email, urllib3, boto3
from email.header import decode_header
from datetime import datetime, timedelta
import requests
urllib3.disable_warnings()

def ssm_parameter():
    ssm = boto3.client('ssm')
    myparameter = ssm.get_parameter(Name='<SSM-NAME>', WithDecryption=True)
    return myparameter["Parameter"]["Value"]
    
def convert(date_time):
    format = "%a, %d %b %Y %H:%M:%S %z"
    datetime_str = datetime.strptime(date_time, format)
    return datetime_str

def lambda_handler(event, context):
    systimenow = str(datetime.now())[:-7]
    now = datetime.utcnow()
    username = "<USERNAME>"
    password = ssm_parameter()
    imap = imaplib.IMAP4_SSL("imap.gmail.com")
    imap.login(username, password)
    status, messages = imap.select("<LABEL>")
    N = 3
    messages = int(messages[0])
    for i in reversed(range(messages,  messages-N, -1)):  
        print("DEBUG: printing i: ", i)
        res, msg = imap.fetch(str(i), "(RFC822)")
        RAW_MAIL = msg[0][1].decode("utf-8")
        EMAIL_MSG = email.message_from_string(RAW_MAIL)
        DATE_FROM_MAIL = EMAIL_MSG['Date']
        for response in msg:        # not needed
            if isinstance(response, tuple):
                msg = email.message_from_bytes(response[1])
                subject = decode_header(msg["Subject"])[0][0]
                if isinstance(subject, bytes):
                    subject = subject.decode()
                from_ = msg.get("From")
                GDATE = msg['Date']
                CONVERTED_GDATE = convert(msg['Date'])
                DATE_NOW = datetime.utcnow()
                SYS_TIME = DATE_NOW - timedelta(seconds=120)
                CURRENT_DATE_TIME = str(SYS_TIME)[:-10]
                TRIM_MAIL_DATE = str(CONVERTED_GDATE)[:-9]
                if TRIM_MAIL_DATE > CURRENT_DATE_TIME:
                    print("DEBUG:the Mail to print----------")
                    msg['Body'] = ''
                    for part in msg.walk():
                        content_type = part.get_content_type()
                        content_disposition = str(part.get("Content-Disposition"))
                        try:
                            body = part.get_payload(decode=True).decode()
                        except:
                            pass

                        if content_type == "text/plain":
                            data = json.dumps({"text": str(subject),
                                               "attachments": [
                                                   {
                                                       "color": "#32CD32",
                                                       "text": str(body)
                                                   },
                                                   {
                                                       "color": "#2f52a4",
                                                       "text": "UTC Time-"+str(GDATE)+" Check Campagins in 13mins",
                                                       "footer": "Slack API | created by <NAME>"
                                                   },                                                   
                                               ]
                                               })
                            print(data)
                            headers = {
                                'Content-type': 'application/json',
                            }
                            #Slack - gmail
                            response = requests.post('https://hooks.slack.com/services/BML3KPPMZ/B01UQijmMr1O6U10lSBEXAMPLE122', headers=headers, data=data)
                            print("DEBUG:", response)
                            print("DEBUG:", response.status_code, response.content)
                        elif content_type == "text/plain" and "attachment" not in content_disposition:
                            print(body)
                        else:
                            print("Job Failed")                       
                else:
                    print("No latest email to notify")
                    print("DEBUG: Pass")
    imap.close()
    imap.logout()
