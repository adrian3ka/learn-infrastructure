# learn-infrastructure

vault secrets enable pki

vault secrets tune -max-lease-ttl=8760h pki

vault write pki/root/generate/internal \
    common_name=my-website.com \
    ttl=8760h

vault write pki/config/urls \
    issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
    crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"

vault write pki/roles/example-dot-com \
    allowed_domains=my-website.com \
    allow_subdomains=true \
    max_ttl=72h

----------------------------------------------------------------
After the secrets engine is configured and a user/machine has a 
Vault token with the proper 
permission, it can generate credentials.
----------------------------------------------------------------

vault write pki/issue/example-dot-com \
    common_name=www.my-website.com
----------------------------------------------------------------
For enabling cert authentication
----------------------------------------------------------------

vault auth enable cert

vault login -method=cert -ca-cert=issuing_ca.pem -client-cert=certificate.pem -client-key=private_key.pem -address=https://192.168.99.100:30333 name=www.my-website.com

----------------------------------------------------------------
Important Terms
----------------------------------------------------------------
CA : Certificate Authority
CRL : Certificate Revocation List


----------------------------------------------------------------
https://www.vaultproject.io/docs/secrets/pki
