EC2 Auto-Provisioning with CloudInit and CloudWatch Logging (AWS Free Tier)
This project demonstrates automated provisioning of a web server on AWS EC2 using CloudInit (User Data scripts), with integrated system and application log forwarding to CloudWatch Logs — all within AWS Free Tier limits.

Features
•	Launches an Amazon Linux 2023 EC2 instance using a free-tier t2.micro.
•	Automatically installs:
o	Apache HTTP Server
o	fail2ban (for basic intrusion protection)
o	Amazon CloudWatch Agent
•	Sends logs to CloudWatch including:
o	/var/log/messages (system logs)
o	/var/log/httpd/access_log (web server logs)
•	Uses an IAM role for secure CloudWatch access without hardcoded credentials.
•	CloudInit script handles all configuration at instance launch.

AWS Services Used
•	EC2: Hosting and provisioning
•	IAM: Role-based permissions for log publishing
•	CloudWatch Logs: Centralized log monitoring
•	CloudInit: Boot-time automation

Skills Demonstrated
•	Infrastructure as Code (CloudInit-style automation)
•	Secure, role-based permissions (IAM roles on EC2)
•	Linux system administration (web server setup, package management)
•	Cloud-native monitoring with CloudWatch

How to Reproduce
Create an IAM Role with `CloudWatchAgentServerPolicy`.
Launch a t2.micro EC2 instance using Amazon Linux 2023.
Paste `cloud-init.sh` into the User Data field.
Attach the IAM role and allow port 80 in the Security Group.
isit the EC2 public IP in your browser and check CloudWatch Logs.
