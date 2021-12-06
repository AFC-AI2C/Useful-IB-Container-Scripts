# Jenkins Pipeline Files

The Jenkins Pipeline is a suite of plugins which supports implementing and integrating continuous delivery pipelines into Jenkins. A continuous delivery pipeline is an automated expression of your process for getting software from version control right through to your users and customers.

The Jenkinsfiles contained herein were developed to expedite the remediation process of vulnerabilities that are addressed through updating packages. The DevSecOps CI/CD pipeline used to build, test, approve secure images, restricts access to only the default RedHat repository. The typical automated installation of 3rd party packages (Linux binaries, Python, R, etc) is locked down, with most of them being installed through a quasi-manual process.

## Usage:
- Jenkinsfile:<br/>
Each project name directory contains a Jenkinsfile that can be uploaded to a Jenkins server for automation.

![Alt text](https://github.com/AFC-AI2C/Useful-IB-Container-Scripts/blob/main/Jenkins Pipeline Files/screenshot.png)


