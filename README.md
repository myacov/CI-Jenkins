# CI-Jenkins
Continuous Integration with Jenkins Nexus Sonarqube and Slack

## Objective: 
Continuous Integration goals
* ⚡️ Fault isolation - quickly identify and isolate the root cause of a failures or bugs
* ⏱️ Short MTTR (Mean Time To Repair) - shorten feedback loops and test cycles
* ⏩ Fast integration to feature changes 
* ✅ Less disruptive releases - target issue resolution earlier in the development process.

## Architecture:
![Project diagram](./images/proj4.jpg)

## AWS Services
| Tools | USE | 
| ------------- | ------------- | 
|🖥️ AWS EC2 Instances  | for Jenkins, SonarQube, Nexus Servers |
|🤖 Jenkins | Continuous Integration Server|
|🐙 git & GitHub | version control and repository |
|🔍 Checkstyle | Code Analysis | 
|🔍 Sonarscanner | Code Analysis | 
|📊 SonarQube Server | Code Analysis Server | 
|🛠 Maven | Build tool  | 
|📦 Nexus Sonartype | Artifact Repostory |
|🔔 Slack | Notifications |


## Desired Learning outcomes
- Gain familiarity with various AWS services.
- Understand and implement autoscaling for optimal performance.

## Flow of Execution
1. **Create 3 Security Groups** for Jenkins, Nexus, and Sonarqube.
2. **Launch EC2 Instances** with user data.
3. **Post Installation** 
    1. Setup Jenkins user and plugins
    2. Setup Nexus and repository for maven dependecies and Artifact
    3. Sonarqube login test
4. **Build Job** create first job with Nexus integration (dependencies).
5. **Github Webhook** - create build triggers on commit
6. **Sonarqube server** integration - preform test.
7. **Nexus Artifact** uploadtest results.
8. **Slack** Notifications.

## Prerequisites:
- AWS Account


## Create Security Groups
1. Jenkins Security group (**jenkins-SG**):
    Description: Security group for Jenkins server
    - Inbound rules:
        - HTTP (Port 8080) from any IPv4 (github-Jenkins connection)
        - HTTP (Port 8080) from any IPv6 (github-Jenkins connection)
        - SSH (Port 22) from **MY IP**
            Description: Allow SSH
        - Custom TCP (Port 8080) from **sonar-SG**
            Description: Allow sonar to send report back to jenkins
2. Nexus Security group (**nexus-SG**):
    Description: Security group for Nexus 
    - Inbound rules:
        - SSH (Port 22) from **MY IP**
                Description: Allow SSH
        - Custom (Port 8081) from **MY IP**
                Description: Allow our access from the browser
        - Custom (Port 8081) from **jenkins-SG**
                Description: Allow access from Jenkins (for artifact upload)
3. Sonarqube Security group (**sonar-SG**):
    Description: Security group for backend services 
      - Inbound rules:
        - SSH (Port 22) from **MY IP**
                Description: Allow SSH
        - Custom TCP (Port 80) from **MY IP**
            Description: for nexus service
        - Custom TCP (Port 80) from **jenkins-SG**
            Description: Allow jenkins to upload test result


## Launch EC2 Instances (with userdata)
1. JenkinsServer Instance
    - Name: **`JenkinsServer`**
    - Project: `Jenkins CI`
    - AMI: `Ubuntu Server 20.04 LTS`
    - type: `t2.small`
    - Key pair: `jenkins-key`
    - Network settings: Security group: **jenkins-SG**
    - Advanced details: User data : Paste contents of jenkins-setup.sh
2. NexusServer Instance
    - Name: **`NexusServer`**
    - Project: `Jenkins CI`
    - AMI: `Amazon Linux 2`
    - type: `t2.medium`
    - Key pair: `nexus-key`
    - Network settings: Security group: **nexus-SG**
    - Advanced details: User data : Paste contents of nexus-setup.sh
3. SonarServer Instance
    - Name: **`SonarServer`**
    - Project: `Jenkins CI`
    - AMI: `Ubuntu Server 20.04 LTS`
    - type: `t2.medium`
    - Key pair: `sonar-key`
    - Network settings: Security group: **sonar-SG**
    - Advanced details: User data : Paste contents of sonar-setup.sh

## Post Installation 
1. Setup Jenkins user and install plugins:
    1. Maven Integration
    2. githun Integration
    3. Nexus Artifact Uploader
    4. SonarQube Scanner
    5. Slack Notification
    6. Build Timestamp

2. Setup Nexus and repository for maven dependecies and Artifact:
    1. sign in with initial password
    2. choose new password
    3. Disable anonymous access
    4. Create 4 repositories
        1. Maven2 (hosted)
            name: **`vprofile-release`**
        2. Maven2 (proxy)
            name: **`vpro-maven-central`**
            remote storage: `https://repo1.maven.org/maven2/`
        3. Maven2 (hosted)
            name: **`vpro-snapshot`**
            version policy: `snapshot`
        4. Maven2 (group)
            name: **`vpro-maven-group`**
            group previous repos
3. Sonarqube login test through the browser (using PUBLIC IP)

## Preparing Jenkins
* apt update and then install openjdk-8-jdk on JenkinsServer instance
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
     

### In Jenkins :
New Item / Create a job
- Name: `vprofile-ci-pipline`
- type
    - [ ] Freestyle project
    - [x] Pipline

- pipeline script from SCM
    - SCM: Git
    - Repository URL: git@github.com:myacov/CI-Jenkins.git
    - Add Jenkins Credential
        - Kind: `SSH Username with private key`
        - ID: githublogin
        - Description: github login
        - Username: git
        - private key : Enter directly - paste private key from `cat ~/.ssh/id_rsa`
    - Select credential: `git(githublogin)`

    - in order to fix error we need to ssh into JenkinsServer and store the github identity
    - swith to root user and then to jenkins user
    - run `git ls-remore -h git@github.com:myacov/CI-Jenkins.git HEAD`
    - identity will be stored at  `.ssh/known_hosts`

    ## Build Job
    ### In Jenkins :
        Build Now

    ## Github Webhook - create build triggers on commit
    ### Create webhook in repository
    repo settings > Webhooks > Add Webhook
        Payload URL: `http://<JenkinsServer IP>/github-webhook/`
        Content type: `application/json`
        trigger: `push event`
    ### Back in Jenkins
    `vprofile-ci-pipline` > Configure > Build Triggers
    - GitHub hook trigger for GITScm polling

## Sonarqube server integration - preform test
### Back in Jenkins
    manage jenkins > Tools 
        Add SonarQube Scanner
            Name: `sonarscanner`
            Version: `SonarQube Sacnner 4.7.0.2747`
    manage jenkins > Systen 
        Add SonarQube servers
            - [x] Environment Variables
            - Name: `sonarserver`
            - Server URL: `http://<SonarServer Private IP>/`
            - Server authentication token
### in SonarQube
#### we need jenkins to authenticate SonarQube server
Admin sign in > my account > Security 
    Generate a token
        Name: `jenkins`
        Add SonarQube Scanner
            Name: `sonarscanner`
        Get `TOKEN`
### Back in Jenkins (SonarQube Scanner section)
- Add Jenkins Credential
        - Kind: `Secret text`
        - Secret: `TOKEN`
        - Name: `sonartoken`
        - Description: `sonartoken`
- Select `sonartoken`

#### writing code for uploading reports to SonarQube Scanner
```

```

##### more info at: *https://plugins.jenkins.io/sonar/*

