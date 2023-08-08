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
4. **Git**
    1. Creat github repo and migrate code
    2. Integrate github repo with VSCode and test it
5. **Build Job** create first job with Nexus integration (dependencies).
6. **Github Webhook** - create build triggers on commit
7. **Sonarqube server** integration - preform test.
8. **Nexus Artifact** uploadtest results.
9. **Slack** Notifications.

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

## **Git**
1. Create github repo 
2. Create ssh key with `ssh-keygen.exe`
3. Enter public-key in github
4. test: `ssh -T git@github.com`
5. `git rmote set-url origin https://github.com/myacov/CI-Jenkins.git`
6. 
7. Integrate github repo with VSCode and test it

