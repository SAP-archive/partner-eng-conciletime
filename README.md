# ConcileTime

Welcome to ConcileTime. 

## Blog Posts

[00 Naïve Sherpa : Meet The Naïve Sherpa](https://blogs.sap.com/2019/07/22/00-naive-sherpa-meet-the-naive-sherpa/)

[01 Naïve Sherpa : The Journey](https://blogs.sap.com/2019/08/02/01-naive-sherpa-the-journey/)

[02 Naïve Sherpa : Project ConcileTime](https://blogs.sap.com/2019/08/07/02-naive-sherpa-project-conciletime/)

[03 Naïve Sherpa : Tasking Your Minion](https://blogs.sap.com/2019/08/14/03-naive-sherpa-tasking-your-minion/)

[04 Naïve Sherpa : Gathering Data](https://blogs.sap.com/2019/09/09/04-naive-sherpa-gathering-data/)

## Project Structure

File / Folder | Purpose
---------|----------
`.pipleline/` | Piper configuration
`app/` | main application code
`chat/` | chat client for WebSocket connections
`db/` | database content
`domain/` | custom domain artifacts
`files/` | docs and the like
`jupyter/` | Python Jupyter notebook development
`srv/` | models and code
`phantom/` | PhantomJS scripted automation test
`tools/` | command line tools
`util/` | multitenant subscribe/unsubscribe code
`web/` | front-end UI(lame) and static content
`package.json` | project metadata and configuration
`mta_to_cf-xxx.mtaext` | MTA Extension file template
`mta.yaml` | Multi-Target Application Development Description
`README.md` | this README
`registry-config-xxx.json` | template for Multitenant uniquely named app
`xs-seurity-xxx.json` | template for UAA unique named app


## More...

Find more in the [help.sap.com](https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/00823f91779d4d42aa29a498e0535cdf.html)

## Commands...

cf create-service conciletime-uaa

## CI/CD

In HANA2 SP04 XSA Node.js 10.15.3 for Linux x86-64    
In CF v1.6.49 node	10.15.3	cflinuxfs3           4


[Build Job in Jenkins](http://jenkins.sap-a-team.com:8080/job/ConcileTime/)

## Git Tags
```
git tag -a post00 -m "Naïve Sherpa : Meet The Naïve Sherpa"
git tag -a post01 -m "Naïve Sherpa : The Journey"
git tag -a post02 -m "Naïve Sherpa : The Project"
git tag -a post03 -m "Naïve Sherpa : Tasking Your Minion"
git tag -a post04 -m "Naïve Sherpa : Gathering Data"

git push origin --tags
```

## Fix Jenkinsfile
[dockerExecute](https://sap.github.io/jenkins-library/steps/dockerExecute/)


## Set up ConcileTime for Subscriptions
Determine the Internal app name.
```
cf t -s (dev/prod)
cf env concile_utl_v0 | grep -A 30 '"xsuaa":' | grep xsappname
```
Adjust the registry-config.json file.
```
vi registry-config.json
```
Create the saas-registry service instance and bind the module that serves the /callback/v1.0/tenants endpoint to it. 
```
cf create-service saas-registry application CONCILE_REG -c registry-config-prod.json
cf bind-service concile_utl_v0 CONCILE_REG
cf restage concile_utl_v0

// Manually Deleting Subscriptions...Using Postman!  See snippets.txt
// Follow Philip's excellent video for all the details
[SAP HANA Academy - SAP CP MT: 06. RESTful API](https://www.youtube.com/watch?v=RjSKrDsnew0&list=PLkzo92owKnVx3Sh0nemX8GoSNzJGfsWJM&index=6)
 
cf env concile_utl_v0

POST https://conciletime.authentication.us10.hana.ondemand.com/oauth/token?grant_type=client_credentials&response_type=token

GET https://tenant-onboarding.cfapps.us10.hana.ondemand.com/api/v2.0/subscription

DELETE https://tenant-onboarding.cfapps.us10.hana.ondemand.com/api/v2.0/subscription/tenants/e3b47f06-fd71-4167-b4a2-6fb89e60d0d5?jobUuid=a57a5dca-9f96-4b48-93e7-b67a6f9268b3

cf unbind-service concile_utl_v0 CONCILE_REG
cf delete-service CONCILE_REG -f
cf update-service CONCILE_REG -c registry-config-(dev/prod).json
```
Note, once you have subscribers, you won't be able to undeploy the app with --delete-services.
Make sure to unsubscribe all subscribers before undeploying.


You can however undeploy without deleting services and the UAA and HDI will remain.
```
cf undeploy conciletime -f
```

However, if the subsciber tries to go the the application, it will give this error.
404 Not Found: Requested route ('ct-sub0.conciletime.com') does not exist.

```
cf push concile_db_v0 -k 256M -m 256M -u none -n conciletime-db -d conciletime.com -p db ; sleep 30 ; cf stop concile_db_v0
cf push concile_jpy_v0 -k 1024M -m 1024M -u none -n jupyter -d conciletime.com -p jupyter
```

Current CF Python version found here.
https://github.com/cloudfoundry/python-buildpack/releases/tag/v1.6.34

Jupyter Config Docs:
https://jupyter-notebook.readthedocs.io/en/stable/config.html
https://www.kubeflow.org/docs/notebooks/custom-notebook/


```
cf push concile_cht_v0 -k 512M -m 128M -u none -n chat-dev -d conciletime.com -p chat
```
```
mta --build-target=CF --mtar=target/concile_CF.mtar -e mta_to_cf-dev.mtaext build
cf deploy target/concile_CF.mtar -f -e mta_to_cf-dev.mtaext
cf map-route concile_web_v0 conciletime.com --hostname '*' ; cf bs concile_utl_v0 CONCILE_REG ; cf restage concile_utl_v0
```
Work out INA module.
```
cf push conciletime-ina -k 1024M -m 2048M -u none -n ina-dev -d conciletime.com -b sap_java_buildpack --no-start -p ina
cf bind-service conciletime-ina CONCILE_UAA
cf bind-service conciletime-ina CONCILE_HDB
cf restage conciletime-ina
```
Other DB modules
```
cf push concile_com_v0 -k 256M -m 256M -u none -n concile-com -d conciletime.com -p db_com
cf push concile_sub_v0 -k 256M -m 256M -u none -n concile-sub -d conciletime.com -p db_sub
```

Using MBT Build
```
mbt build -p=cf -t=target --mtar=concile_CF-mbt.mtar

cf deploy target/concile_CF-mbt.mtar -f -e mta_to_cf-dev.mtaext
cf deploy target/concile_CF-mbt.mtar -f -m conciletime-utl -e mta_to_cf-dev.mtaext
```

Fixing mtar so docker based modules deploy properly
cf push mbtci -k 2G -m 1G -u none -n build -d conciletime.com --docker-image devxci/mbtci:latest

cf enable-ssh mbtci
cf restart mbtci

cf ssh mbtci


