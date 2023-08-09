# CI-Jenkins
## CI Pipeline with Jenkins, Nexus, Sonarqube and Slack

The CI pipeline aims to: 

* Quickly identify and resolve issues
* Shorten feedback and test cycles
* Integrate changes quickly and with less disruption

We achieve this by:
* Frequent code testing
* Early bug detection and fix
* Releasing integrated, tested code

## Architecture:
![Project diagram](./Images/proj4b.jpg)

## Tools and Services Used
| Tools | USE | 
| ------------- | ------------- | 
|🖥️ AWS EC2 | Host Jenkins, Nexus and SonarQube |
|🤖 Jenkins | Continous Integration tool |
| GitHub | Version control |
|🔍 Checkstyle | Code analysis plugin for Jenkins | 
|🔍 Sonarscanner | Analyzes projects and uploads results to SonarQube | 
|📊 SonarQube Server | Code Analysis Server | 
|🛠 Maven | Build tool  | 
|📦 Nexus Sonartype | Maven repository manager |
|🔔 Slack | Notification integration |


## Learning Objectives
- Gain familiarity with various AWS services.
- Understand and implement a working CI pipeline

## Implementation
1. **Security Groups Setup** for Jenkins, Nexus, and Sonarqube. Configure inbound rules for necessary communication
2. **Launch EC2 Instances** - Utilize user data scripts for initial setup.
3. **Post Installation Configuration** 
    * Set up Jenkins user and install essential plugins.
    * Configure Nexus and establish repositories for Maven dependencies and artifacts.
    * Test SonarQube login through the browser.
4. **Jenkins Setup** 
    * Install required tools such as OpenJDK 8 and Maven.
    * Set up Jenkins tools for JDK and Maven.
    * Save Nexus login credentials.
5. **Jenkins Job Creation** 
    * Create a Jenkins job for the CI pipeline using the provided Git repository.
    * Configure the GitHub webhook to trigger builds on commits.
6. **SonarQube Integration** 
    * Integrate **SonarQube** into the CI pipeline to perform code analysis.
    * Configure SonarQube server authentication in Jenkins.
7. **Create quality gates in SonarQube**
8. **Nexus Artifact Management** upload artifact to Nexus repositories.
9. **Slack Notifications** - Integrate Slack for notification purposes, ensuring authentication and appropriate channels.

## Prerequisites:
- active AWS account

## Detailed Steps
### 1.  Security Groups Setup
#### A. Jenkins Security group (**jenkins-SG**):

Inbound rules:
- HTTP (Port 8080) from any IPv4 (github-Jenkins connection)
- HTTP (Port 8080) from any IPv6 (github-Jenkins connection)
- SSH (Port 22) from **MY IP**
    Description: Allow SSH
- Custom TCP (Port 8080) from **sonar-SG**
    Description: Allow sonar to send report back to jenkins
#### B. Nexus Security group (**nexus-SG**): 
Inbound rules:
- SSH (Port 22) from **MY IP**
        Description: Allow SSH
- Custom (Port 8081) from **MY IP**
        Description: Allow our access from the browser
- Custom (Port 8081) from **jenkins-SG**
        Description: Allow access from Jenkins (for artifact upload)
#### C. Sonarqube Security group (**sonar-SG**):
Inbound rules:
- SSH (Port 22) from **MY IP**
        Description: Allow SSH
- Custom TCP (Port 80) from **MY IP**
    Description: for nexus service
- Custom TCP (Port 80) from **jenkins-SG**
    Description: Allow jenkins to upload test result


### 2. Launch EC2 Instances (with userdata)
#### A. JenkinsServer Instance
- Name: **`JenkinsServer`**
- Project: `Jenkins CI`
- AMI: `Ubuntu Server 20.04 LTS`
- type: `t2.small`
- Key pair: `jenkins-key`
- Network settings: Security group: **jenkins-SG**
- Advanced details: User data : use contents of `./userdata/jenkins-setup.sh`

#### B. NexusServer Instance
- Name: **`NexusServer`**
- Project: `Jenkins CI`
- AMI: `Amazon Linux 2`
- type: `t2.medium`
- Key pair: `nexus-key`
- Network settings: Security group: **nexus-SG**
- Advanced details: User data : use contents of `./userdata/nexus-setup.sh`

#### C. SonarServer Instance
- Name: **`SonarServer`**
- Project: `Jenkins CI`
- AMI: `Ubuntu Server 20.04 LTS`
- type: `t2.medium`
- Key pair: `sonar-key`
- Network settings: Security group: **sonar-SG**
- Advanced details: User data : use contents of `./userdata/sonar-setup.sh`

### 3. Post Installation 
1. Setup Jenkins user and install plugins:
    * `Maven Integration`
    * `Github Integration`
    * `Nexus Artifact Uploader`
    * `SonarQube Scanner`
    * `Slack Notification`
    * `Build Timestamp`

2. Configure Nexus with repositories for Maven dependencies and artifacts:
    1. sign in with initial password and choose new password
    2. Disable anonymous access
    3. Create 4 repositories:
        - Maven2 (hosted)
            name: **`vprofile-release`**
        - Maven2 (proxy)
            name: **`vpro-maven-central`**
            remote storage: `https://repo1.maven.org/maven2/`
        - Maven2 (hosted)
            name: **`vpro-snapshot`**
            version policy: `snapshot`
        - Maven2 (group)
            name: **`vpro-maven-group`**
            group previous repos
3. Test SonarQube login to verify successful installation through the browser (using PUBLIC IP)

### 4. Jenkins Setup
* Update and then install openjdk-8-jdk on `JenkinsServer` instance
* in Jenkins:
1. manage jenkins tools
    * Add JDK
        * Name: `OracleJDK8`
        * JAVA_HOME: `/usr/lib/jvm/java-1.8.0-openjdk-amd64`
    * Add MAVEN
        * Name: `MAVEN3`
        * Version: `3.9.4`
2. Save Nexus log in Credentials   Manage [Jenkins > Credentials > System > Global credentials > Add credentials] 
     * Kind: `Username with password`
     * Scope: `Global`
     * Username: `admin`
     * Password: `$NexusPassword`
     * ID: `nexuslogin`
     
### 5. Jenkins Job Creation :
#### Create a Jenkins job
New Item / Create a job
- Name: `vprofile-ci-pipline`
- type:
    - [x] Pipline
    - [x] pipeline script from SCM
    - SCM: Git
    - Repository URL: `git@github.com:myacov/CI-Jenkins.git`
    - Add Jenkins Credential
        - Kind: `SSH Username with private key`
        - ID: `githublogin`
        - Description: github login
        - Username: `git`
        - private key : Enter directly - paste private key from `cat ~/.ssh/id_rsa`
    - Select credential: `git(githublogin)`

    - in order to fix error we need to ssh into JenkinsServer and store the github identity. switch to root user and then to jenkins user and run: `git ls-remote -h git@github.com:myacov/CI-Jenkins.git HEAD`
    - identity will be stored at  `.ssh/known_hosts`

#### GitHub Webhook - Creating Build Triggers
##### **in GitHub:**
- Create webhook in GitHub: [repo settings > Webhooks > Add Webhook]
    
    - Payload URL: `http://<JenkinsServer IP>/github-webhook/`
    - Content type: `application/json`
    - trigger: `push event`
##### **in Jenkins:**
``` 
[`vprofile-ci-pipline` JOB > Configure > Build Triggers]
```
choose:
- [x] GitHub hook trigger for GITScm polling

### 6. SonarQube Scanner Integration
we need jenkins to authenticate SonarQube server, we generate a token:

##### **in SonarQube Dashboard:**
```
[Admin > my account > Security > Generate a token > Name: jenkins] 
```
- Get `TOKEN`

##### **in Jenkins:**
```
[manage jenkins > Tools > SonarQube Scanner] 
```
- Add SonarQube Scanner
    - Name: `sonarscanner`
    - Version: `SonarQube Sacnner 4.7.0.2747`

```
[manage jenkins > System > SonarQube servers] 
```
manage jenkins > System
- Add SonarQube servers
    - [x] Environment Variables
    - Name: `sonarserver`
    - Server URL: `http://<SonarServer Private IP>/`
    - Server authentication token: + Add 
    - Add Jenkins Credential
        - Kind: `Secret text`
        - Secret: enter the `TOKEN`
        - Name: `sonartoken`
        - Description: `sonartoken`
    - Select `sonartoken`


### 7. Creating SonarQube quality gates
#### in SonarQube:
##### create Quality gate:
Quality Gates > Create >
- Name: `vprofile QG`  
- Add condition:
    - [x] on overall code
    - quality gate fails when: `bugs` are greater than `25`
- Attach quality gate:       
    - project > Project settings > Quality Gate > Select: `vprofile QG`

##### add webhook:
project > Project settings > Webhooks > Create >
- Name: `jenkinswebhook`
- URL: `http://<Jenkins_private_IP>:8080/sonarqube-webhook`



##### Nexus Artifact - upload artifact to Nexus repository:
- in Jenkins:
manage jenkins > System > Build Timestamp
Pattern: `yy-MM-dd_HH:mm`

### 8. Nexus Artifact Management
#### Documentation: `https://github.com/jenkinsci/nexus-artifact-uploader-plugin` (Jenkins pipeline example)
#### Here we will add a stage:

 ```groovy
    nexusArtifactUploader(
        nexusVersion: 'nexus3',
        protocol: 'http',
        nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
        groupId: 'QA',
        version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
        repository: "${RELEASE_REPO}",
        credentialsId: "${NEXUS_LOGIN}",
        artifacts: [
            [artifactId: 'vproapp',
                classifier: '',
                file: 'target/vprofile-v2.war',
                type: 'war']
            ]
    )
```

### 9. Slack Notifications
#### we need jenkins to authenticate Slack server
- Add Slack app: `Jenkins CI`
- Admin sign in > my account > Security 
    - Choose channel: `jenkinscicd`
    - Add Jenkins CI integration
    - Get `TOKEN` created (from step 3)
#### Back in Jenkins - enter token
manage jenkins > System 
    Slack:
        Workspace: `vprofilecicd`
        - Add Jenkins Credential
        - Kind: `Secret text`
        - Secret: `TOKEN`
        - Name: `slacktoken`
        - Description: `slacktoken`
- Select `slacktoken`
- Default channel: `#jenkinscicd`