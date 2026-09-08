# GarageSuite

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Deploying GarageSuite to Lightsail

`deployments/2for2tires` is the production deployment for 2for2tires only.
Use `deployments/template` as the starting point when creating a deployment for
a new customer.

Use `deployments/2for2tires/deploy-2for2tires` for the direct deployment path. It builds the
Dockerfile locally for `linux/amd64`, transfers the image over SSH, and runs it
on Lightsail. Docker Desktop must be installed locally and Docker must be
installed on the Amazon Linux instance.

Create `deployments/2for2tires/secrets.2for2tires` and fill in the Rails master key, Managed
Database `DATABASE_URL`, `FORCE_SSL=true`, `SES_SMTP_ENDPOINT`, and `SES_EVENTS_QUEUE_URL`.

For HTTPS, point the domain `2for2tires.ca` to the Lightsail static IP and
allow inbound TCP ports `80`, `443`, and `22`. The deploy script runs Caddy as
the TLS reverse proxy; Caddy obtains and renews the Let's Encrypt certificate
automatically. Deploy only after DNS resolves to the Lightsail IP:

```sh
deployments/2for2tires/deploy-2for2tires 15.222.63.120
```

Pass the Lightsail static IP directly to the deploy script:

```sh
deployments/2for2tires/deploy-2for2tires YOUR_LIGHTSAIL_STATIC_IP
```

You can also use `LIGHTSAIL_STATIC_IP=your-lightsail-static-ip` as an
environment variable.

Run `deployments/2for2tires/deploy-2for2tires` for each deploy. The app health endpoint is `/up`.
This direct approach briefly stops the old container during replacement;
future zero-downtime deployment can be added as a separate deployment strategy.

## Shared Email Service

The application exposes `POST /api/emails` for tenant-authenticated, asynchronous
email delivery. Send `X-API-Key` and a JSON body containing `template:
"notification"` plus `data.recipient`, `data.subject`, and `data.message`.

Production requires a verified SES sending domain for `noreply@yourservice.com`,
with SPF, DKIM, and DMARC DNS records. Store SES SMTP credentials in Rails
credentials under `ses.smtp_username` and `ses.smtp_password`; set
`SES_SMTP_ENDPOINT` when the SES region differs from `us-east-1`.

Create an SNS topic for SES Bounce and Complaint events, subscribe the
`ses-events-queue` SQS queue, and set `SES_EVENTS_QUEUE_URL` in the application
environment. The application role needs `sqs:ReceiveMessage`,
`sqs:DeleteMessage`, and `sqs:GetQueueAttributes` on that queue. The recurring
`SesEventsPollJob` marks matching user email addresses invalid after bounces or
complaints.

DNS ownership remains a deployment decision: confirm whether the sending domain
is hosted in Route 53 before automating record creation; otherwise create the
SES-provided records with the external registrar.


### To Do

- Change site name and header color
- Get DNS
- Make Price Optional
- Remove Date/Time picking for customers
- Update logo
- Banner at the bottom 
- Contact us page