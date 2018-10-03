#!/bin/bash

# Generates certificates for local development. A single certificate, that
# is unique to you, is added to your browser

domains=( "theyvoteforyou.org.au.test" "test.theyvoteforyou.org.au.test"
          "planningalerts.org.au.test" "test.planningalerts.org.au.test"
          "openaustralia.org.au.test"  "test.openaustralia.org.au.test"
          "righttoknow.org.au.test"    "test.righttoknow.org.au.test"
          "oaf.org.au.test"
          "opengovernment.org.au.test"
          "electionleaflets.org.au.test" "test.electionleaflets.org.au.test"
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
  set -x
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
  set +x
done

# Move certificate into the right place
mv theyvoteforyou.org.au.test.key theyvoteforyou.org.au.test.pem test.theyvoteforyou.org.au.test.key test.theyvoteforyou.org.au.test.pem ../roles/internal/theyvoteforyou/files
mv planningalerts.org.au.test.key planningalerts.org.au.test.pem test.planningalerts.org.au.test.key test.planningalerts.org.au.test.pem ../roles/internal/planningalerts/files
mv openaustralia.org.au.test.key openaustralia.org.au.test.pem test.openaustralia.org.au.test.key test.openaustralia.org.au.test.pem ../roles/internal/openaustralia/files
mv righttoknow.org.au.test.key righttoknow.org.au.test.pem test.righttoknow.org.au.test.key test.righttoknow.org.au.test.pem ../roles/internal/righttoknow/files
mv oaf.org.au.test.key oaf.org.au.test.pem ../roles/internal/oaf/files
mv opengovernment.org.au.test.key opengovernment.org.au.test.pem ../roles/internal/opengovernment/files
mv electionleaflets.org.au.test.key electionleaflets.org.au.test.pem test.electionleaflets.org.au.test.key test.electionleaflets.org.au.test.pem ../roles/internal/electionleaflets/files
# Line below is a temporary measure to copy across a certificate generated here
# to be used in the morph repo for provisioning. This is only temporary until the
# morph provisioning is move to this repo
#mv dev.morph.io.key dev.morph.io.pem ../../morph/provisioning/roles/morph-app/files/ssl
