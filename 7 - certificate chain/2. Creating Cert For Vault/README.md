# learn-infrastructure

vault secrets enable pki

vault secrets tune -max-lease-ttl=8760h pki

vault write pki/root/generate/internal common_name=myvault.com ttl=87600h

vault write pki/config/urls issuing_certificates="https://localhost:8200/v1/pki/ca" crl_distribution_points="https://localhost:8200/v1/pki/crl"

vault write pki/roles/example-dot-com \
    allowed_domains=example.com \
    allow_subdomains=true max_ttl=72h

vault write pki/issue/example-dot-com \
    common_name=blah.example.com

#----------------------------------------------------------------
# Setting UP Intermediate CA
#----------------------------------------------------------------
vault secrets enable -path=pki_intermediate pki

vault secrets tune -max-lease-ttl=43800h pki_intermediate

vault write -format=json pki_intermediate/intermediate/generate/internal common_name="myvault.com Intermediate Authority" ttl=43800h >> pki_intermediate.output

cat pki_intermediate.output | jq -r ".data.csr" >> pki_intermediate.csr

vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr format=pem_bundle ttl=43800h >> signed_certificate.output

cat signed_certificate.output | jq -r ".data.certificate" >> signed_certificate.pem

vault write -format=json pki_intermediate/intermediate/set-signed certificate=@signed_certificate.pem >> signed_certificate.pem

vault write pki_intermediate/config/urls issuing_certificates="http://localhost:8200/v1/pki_intermediate/ca" crl_distribution_points="http://localhost:8200/v1/pki_intermediate/crl"

vault write pki_intermediate/roles/example-dot-com \
    allowed_domains=example.com \
    allow_subdomains=true max_ttl=72h

#----------------------------------------------------------------
# After the secrets engine is configured and a user/machine has a 
# Vault token with the proper 
# permission, it can generate credentials.
#----------------------------------------------------------------

vault write -format=json pki_intermediate/issue/example-dot-com common_name=blah.example.com >> certs.txt
cat certs.txt | jq -r ".data.certificate" >> cert.pem
cat certs.txt | jq -r ".data.ca_chain[0]" >> cacert.pem
cat certs.txt | jq -r ".data.issuing_ca" >> issuing_ca.pem
cat certs.txt | jq -r ".data.private_key" >> key.pem

vault auth enable cert

----------------------------------------------------------------
# You can use ngrok to obtain https for free and easy setup
----------------------------------------------------------------
# login with token should be ok,

vault login s.9e7H9kOF3kGnzXiXYd1AmXtO

---------------------------------------------------------------------------------------
vault login -tls-skip-verify -method=cert -ca-cert=cacert.pem -client-cert=cert.pem -client-key=key.pem name=blah.example.com

#------------------------------or------------------------------
curl --request POST --cacert cacert.pem --cert cert.pem --key key.pem --data '{"name": "www.my-website.com"}' https://localhost:8200/v1/auth/cert/login

----------------------------------------------------------------
# Important Terms
----------------------------------------------------------------
# CA : Certificate Authority
# CRL : Certificate Revocation List
# ----------------------------------------------------------------
# https://www.vaultproject.io/docs/secrets/pki

