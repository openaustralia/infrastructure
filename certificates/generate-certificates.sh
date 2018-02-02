#!/bin/bash

# Generates certificates for local development. A single certificate, that
# is unique to you, is added to your browser

# Generates a private key with passphrase "abcd"
echo "Generating private key for root certificate..."
openssl genrsa -des3 -passout pass:abcd -out myCA.key 2048

# Generate the root certificate (which you need to trust)
echo "Generating root certificate..."
openssl req \
  -x509 -new -nodes -key myCA.key -sha256 -days 1825 -out myCA.pem \
  -passin pass:abcd -subj '/C=AU/CN=OAF Root CA'

echo "Generating private key for theyvoteforyou.org.au.dev..."
openssl genrsa -out theyvoteforyou.org.au.dev.key 2048

# Generate a CSR (a request to the CA to sign a certificate)
echo "Generating a request to sign certificate for theyvoteforyou.org.au.dev..."
openssl req -new -key theyvoteforyou.org.au.dev.key -out theyvoteforyou.org.au.dev.csr \
  -subj '/C=AU/CN=theyvoteforyou.org.au.dev'

echo "Generate certificate for theyvoteforyou.org.au.dev..."
openssl x509 -req -in theyvoteforyou.org.au.dev.csr -CA myCA.pem -CAkey myCA.key \
  -CAcreateserial -out theyvoteforyou.org.au.dev.pem -days 1825 -sha256 \
  -extfile theyvoteforyou.org.au.dev.ext -passin pass:abcd

# Remove intermediate files
rm theyvoteforyou.org.au.dev.csr myCA.srl

# Move certificate into the right place
mv theyvoteforyou.org.au.dev.key theyvoteforyou.org.au.dev.pem ../roles/internal/theyvoteforyou/files
