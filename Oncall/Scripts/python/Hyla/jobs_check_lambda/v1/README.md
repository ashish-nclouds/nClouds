# Check Jenkins job alerts and automate the incident actions
[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)
### Author: Ashish Mathai
###### Code Version: V1
### Topic: 
We get alerts on daily basis and the jobs are successful and its getting     failed due to old Jenkins and plugin issue. Permanent fix, Upgrade Jenkins and plugin
### Setup 
- API Gateway (POST) integrated with Pagerduty
- Get events from PD on (λ) Lambda to process
- Filter services and check Shift time to process further

### Plugins
Instructions on how to use them in your own application are linked below.

| Plugin | README |
| ------ | ------ |
| Requests | [pip3 install reuqtests][l1] |
| Json | [pip3 installl json][l2] |
| Re | [pip3 install re][l3] |
| urllib3 | [pip3 install urllib3][l4] |
| Time | [pip3 install time][l5] |
| Jenkins | [pip3 install python-jenkins][l6] |


### License
**nClouds**

   [l1]: <https://pypi.org/project/requests/>
   [l2]: <https://pypi.org/project/jsons/>
   [l3]: <https://pypi.org/project/regex/>
   [l4]: <https://pypi.org/project/urllib3/>
   [l5]: <https://pypi.org/project/time/>
   [l6]: <https://pypi.org/project/python-jenkins/>
