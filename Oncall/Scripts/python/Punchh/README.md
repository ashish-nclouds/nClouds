# Email notifier for slack

Notify mails to Slack channel

## Dependencies

- Python3
- AWS Eventbridge

## Usage

```
- Use SSM to store user credentials for Gmail
- Need event rule to set on cron to trigger lambda evey 1.8 minute.
- Lambda checks for latest 3 mails which received within 120seconds
- Using webhook, the email content is notified on slack channel.
```
