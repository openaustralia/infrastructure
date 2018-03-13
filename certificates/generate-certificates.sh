#!/bin/bash

# Generates certificates for local development. A single certificate, that
# is unique to you, is added to your browser

domains=( "theyvoteforyou.org.au.dev" "test.theyvoteforyou.org.au.dev"
          "planningalerts.org.au.dev" "test.planningalerts.org.au.dev"
          "openaustralia.org.au.dev"  "test.openaustralia.org.au.dev"
          "righttoknow.org.au.dev"    "test.righttoknow.org.au.dev"
          "dev.morph.io")

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

for domain in "${domains[@]}"
do
  echo "Generating private key for $domain..."
  openssl genrsa -out $domain.key 2048

  # Generate a CSR (a request to the CA to sign a certificate)
  echo "Generating a request to sign certificate for $domain..."
  openssl req -new -key $domain.key -out $domain.csr \
    -subj "/C=AU/CN=$domain"

  echo "Generate certificate for $domain..."
  openssl x509 -req -in $domain.csr -CA myCA.pem -CAkey myCA.key \
    -CAcreateserial -out $domain.pem -days 1825 -sha256 \
    -extfile ext/$domain.ext -passin pass:abcd

  # Remove intermediate files
  rm $domain.csr myCA.srl
done

# Move certificate into the right place
mv theyvoteforyou.org.au.dev.key theyvoteforyou.org.au.dev.pem test.theyvoteforyou.org.au.dev.key test.theyvoteforyou.org.au.dev.pem ../roles/internal/theyvoteforyou/files
mv planningalerts.org.au.dev.key planningalerts.org.au.dev.pem test.planningalerts.org.au.dev.key test.planningalerts.org.au.dev.pem ../roles/internal/planningalerts/files
mv openaustralia.org.au.dev.key openaustralia.org.au.dev.pem test.openaustralia.org.au.dev.key test.openaustralia.org.au.dev.pem ../roles/internal/openaustralia/files
mv righttoknow.org.au.dev.key righttoknow.org.au.dev.pem test.righttoknow.org.au.dev.key test.righttoknow.org.au.dev.pem ../roles/internal/righttoknow/files
