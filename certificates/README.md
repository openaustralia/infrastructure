
These are currently made "by hand" and checked into the repo.

To generate the CA private key
```
cd certificates
openssl genrsa -des3 -out myCA.key 2048
```
Matthew has stored the passphrase in his password manager

Generate the root certificate:
```
$ openssl req -x509 -new -nodes -key myCA.key -sha256 -days 1825 -out myCA.pem
Enter pass phrase for myCA.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:AU
State or Province Name (full name) []:
Locality Name (eg, city) []:
Organization Name (eg, company) []:OpenAustralia Foundation
Organizational Unit Name (eg, section) []:
Common Name (eg, fully qualified host name) []:OAF Root CA
Email Address []:contact@oaf.org.au
```

Now you want to make your browser trust certificates signed with this root certificate.
For instructions on how to do this on Mac OS see the section "Installing your root certificate" on https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/.

### Generate certificate for theyvoteforyou.org.au.dev

The file `roles/internal/theyvoteforyou/files/theyvoteforyou.org.au.dev.key` should already be
in a file in called `certificates/theyvoteforyou.org.au.dev.key`.

Generate a CSR:
```
$ cd certificates
$ openssl req -new -key theyvoteforyou.org.au.dev.key -out theyvoteforyou.org.au.dev.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:AU
State or Province Name (full name) []:
Locality Name (eg, city) []:
Organization Name (eg, company) []:OpenAustralia Foundation
Organizational Unit Name (eg, section) []:
Common Name (eg, fully qualified host name) []:theyvoteforyou.org.au.dev
Email Address []:contact@oaf.org.au

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
```

Create a configuration file in your local directory `theyvoteforyou.org.au.dev.ext` with
```
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = theyvoteforyou.org.au.dev
DNS.2 = www.theyvoteforyou.org.au.dev
```

Then:
```
openssl x509 -req -in theyvoteforyou.org.au.dev.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out theyvoteforyou.org.au.dev.crt -days 1825 -sha256 -extfile theyvoteforyou.org.au.dev.ext
cp cp theyvoteforyou.org.au.dev.crt roles/theyvoteforyou/files/theyvoteforyou.org.au.dev.pem
```
