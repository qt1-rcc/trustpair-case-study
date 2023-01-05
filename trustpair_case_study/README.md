# Trustpair - Case Study Terraform + AWS

sourcer venv pour executer awslocal
$ source venv/bin/activate

exporter la région (nécessaire pour tflocal)
export AWS_DEFAULT_REGION="eu-west-1"

$ tflocal plan -out trustpair_casestudy
$ tflocal apply trustpair_casestudy
(tflocal destroy si besoin)

-> Modifier le ClientId en se basant sur celui donné par le output

Pour le curl -> bien utiliser l'url de l'api gateway pour notre lambda
$ curl --location --request POST 'http://localhost:4566/eu-west-1_e75d8d15edd14a95b15d29d03e936cfe' \
--header 'X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth' \
--header 'Content-Type: application/x-amz-json-1.1' \
--data-raw '{
   "AuthParameters" : {
      "USERNAME" : "example",
      "PASSWORD" : "123examPle"
   },
   "AuthFlow" : "USER_PASSWORD_AUTH",
   "ClientId" : "hrblgw5ehq4wu10mg8id0ny2ew"
}'

Avec access_token = OK
Sans access_token = KO