#!/bin/bash
yum update -y
yum install -y httpd fail2ban amazon-cloudwatch-agent

systemctl start httpd
systemctl enable httpd

echo "Hello from $(hostname -f)" > /var/www/html/index.html

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "EC2-System-Logs",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "Apache-Access-Logs",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
