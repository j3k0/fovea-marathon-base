#!/bin/sh
mkdir tmp
openssl genrsa -out tmp/server-key.pem 2048
openssl req -new -key tmp/server-key.pem -out tmp/server-csr.pem -subj /CN=*/
openssl x509 -req -in tmp/server-csr.pem -out tmp/server-cert.pem -signkey tmp/server-key.pem -days 3650
cat tmp/server-cert.pem tmp/server-key.pem > self-signed
rm -fr tmp
