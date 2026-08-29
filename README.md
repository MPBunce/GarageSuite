# README

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

## Deploying 2for2tires to Lightsail

Use `deployments/2for2tires/deploy-2for2tires` for the direct deployment path. It builds the
Dockerfile locally for `linux/amd64`, transfers the image over SSH, and runs it
on Lightsail. Docker Desktop must be installed locally and Docker must be
installed on the Amazon Linux instance.

Create `deployments/2for2tires/secrets.2for2tires` and fill in the Rails master key, Managed
Database `DATABASE_URL`, and `FORCE_SSL=true`.

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


### To Do

- Change site name and header color
- Get DNS
- Make Price Optional
- Remove Date/Time picking for customers
- Update logo
- Banner at the bottom 
- Contact us page