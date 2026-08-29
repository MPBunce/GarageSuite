# Customer Deployment Template

Create a customer deployment folder and copy the template script:

```sh
mkdir -p deployments/CLIENT_SLUG
cp deployments/template/deploy-client deployments/CLIENT_SLUG/deploy-client
chmod +x deployments/CLIENT_SLUG/deploy-client
```

Create `deployments/CLIENT_SLUG/secrets.CLIENT_SLUG` locally. Do not commit it.
It must contain:

```dotenv
RAILS_MASTER_KEY=your-rails-master-key
DATABASE_URL=your-managed-database-url
FORCE_SSL=true
```

Add `/deployments/CLIENT_SLUG/secrets.CLIENT_SLUG` to `.gitignore`.

Create `config/CLIENT_SLUG.Caddyfile` with the customer's real domain and the
same container name:

```caddyfile
customer.example, www.customer.example {
	reverse_proxy CLIENT_SLUG:3000
}
```

Deploy from the repository root after DNS points at the Lightsail static IP:

```sh
CLIENT_SLUG=CLIENT_SLUG deployments/CLIENT_SLUG/deploy-client LIGHTSAIL_STATIC_IP
```

The script defaults to `$HOME/.ssh/lightsail-CLIENT_SLUG.pem`. Override it with
`LIGHTSAIL_SSH_KEY`, and optionally set `LIGHTSAIL_SSH_USER`, `DEPLOY_TAG`,
`DEPLOY_SECRETS_FILE`, or `CADDYFILE` when needed.