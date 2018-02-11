#!/bin/bash

# Generates certificates for local development. A single certificate, that
# is unique to you, is added to your browser

# Generates a private key with passphrase "abcd" (but only if it doesn't already exist)
if [ ! -f myCA.key ]; then
  echo "Generating private key for root certificate..."
  openssl genrsa -des3 -passout pass:abcd -out myCA.key 2048
fi

# Generate the root certificate (which you need to trust)
# If you want to regenerate the root certificate then just delete it. You'll need
# to reload the certificate to trust the new one.
if [ ! -f myCA.pem ]; then
  echo "Generating root certificate..."
  openssl req \
    -x509 -new -nodes -key myCA.key -sha256 -days 1825 -out myCA.pem \
    -passin pass:abcd -subj '/C=AU/CN=OAF Root CA'
  echo "**********************************************************************************************"
  echo "Now you want to make your browser trust certificates signed with the root certificate myCA.pem"
  echo "For instructions on how to do this on Mac OS see the section 'Installing your root certificate'"
  echo "on https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/."
  echo "**********************************************************************************************"
fi

echo "Generating private key for theyvoteforyou.org.au.dev..."
openssl genrsa -out theyvoteforyou.org.au.dev.key 2048

echo "Generating private key for test.theyvoteforyou.org.au.dev..."
openssl genrsa -out test.theyvoteforyou.org.au.dev.key 2048

# Generate a CSR (a request to the CA to sign a certificate)
echo "Generating a request to sign certificate for theyvoteforyou.org.au.dev..."
openssl req -new -key theyvoteforyou.org.au.dev.key -out theyvoteforyou.org.au.dev.csr \
  -subj '/C=AU/CN=theyvoteforyou.org.au.dev'

# Generate a CSR (a request to the CA to sign a certificate)
echo "Generating a request to sign certificate for test.theyvoteforyou.org.au.dev..."
openssl req -new -key test.theyvoteforyou.org.au.dev.key -out test.theyvoteforyou.org.au.dev.csr \
  -subj '/C=AU/CN=test.theyvoteforyou.org.au.dev'

echo "Generate certificate for theyvoteforyou.org.au.dev..."
openssl x509 -req -in theyvoteforyou.org.au.dev.csr -CA myCA.pem -CAkey myCA.key \
  -CAcreateserial -out theyvoteforyou.org.au.dev.pem -days 1825 -sha256 \
  -extfile theyvoteforyou.org.au.dev.ext -passin pass:abcd

echo "Generate certificate for test.theyvoteforyou.org.au.dev..."
openssl x509 -req -in test.theyvoteforyou.org.au.dev.csr -CA myCA.pem -CAkey myCA.key \
  -CAcreateserial -out test.theyvoteforyou.org.au.dev.pem -days 1825 -sha256 \
  -extfile test.theyvoteforyou.org.au.dev.ext -passin pass:abcd

# Remove intermediate files
rm theyvoteforyou.org.au.dev.csr test.theyvoteforyou.org.au.dev.csr myCA.srl

# Move certificate into the right place
mv theyvoteforyou.org.au.dev.key theyvoteforyou.org.au.dev.pem ../roles/internal/theyvoteforyou/files
mv test.theyvoteforyou.org.au.dev.key test.theyvoteforyou.org.au.dev.pem ../roles/internal/theyvoteforyou/files
