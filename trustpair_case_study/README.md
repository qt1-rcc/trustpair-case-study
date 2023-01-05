# Trustpair - Case Study Terraform + AWS

## Flow DEMO

1. sourcer venv pour executer awslocal

```source venv/bin/activate**```

2. exporter la région (nécessaire pour tflocal)

```export AWS_DEFAULT_REGION="eu-west-1"```

3. Terraformer l'environnement

```
tflocal plan -out trustpair_casestudy
tflocal apply trustpair_casestudy
```

*Pour raser: **tflocal destroy***



4. Connexion à Cognito avec un utilisateur *(Modifier le ClientId en se basant sur celui donné par le output)*

```
curl --location --request POST 'http://localhost:4566/eu-west-1_e75d8d15edd14a95b15d29d03e936cfe' \
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
```

## Résumé des accès

Avec avec/sans access_token (GET) = OK

Avec avec access_token (POST) = OK

Avec sans access_token (POST) = NOK
