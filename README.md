# mas_code
This is a code modules that can be used to test SAS' *Micro Analytic Service* (MAS). Some contain SAS DS2 code, some contain both DS2 and Python code. 
# what is MAS?
MAS is a real-time in-memory single record prediction and decision service which is presented through a tomcat server and can be clusterered for high availability and scalability.
# what languages can MAS use?
MAS can take in SAS DS2 code or Python code. Additionally, SAS Model Manager can convert regular SAS code into DS2 as it publishes a model in to a MAS instance.
# what language is this wrapped in?
These files are wrapped in JSON since MAS presents a REST API for publishing and managing models.
# how do I publish one of these JSON documents to MAS?
Find your MAS API end point, authenticate, and POST the document:
```
$ curl -X POST -d @<input json doc> -H "Content-Type: application/json" http://sasbap.demo.sas.com/SASMicroAnalyticService/rest/modules?ticket=<your ticket>
```
