# Trustpair - Case Study Terraform + AWS

## Note

- Cet infrastructure a été déployé et testée via [LocalStack](https://localstack.cloud/) pour éviter tout facturation pendant les tests
- La commande [tflocal](https://docs.localstack.cloud/user-guide/integrations/terraform/#using-the-tflocal-script) est identique au CLI terraform mais permet de déployer automatique l'infrastructure vers les endpoints locaux (conteneur docker sur mon poste) de LocalStack

## Architecture

### Réseau
- 1 VPC
- 6 subnets (3 privés, 3 publiques)
- 1 internet gateway
- 3 public routes (1/chaque public subnet)
- 3 NAT gateway (1/chaque public subnet)
- 6 routes (3 privées/3 publiques)
- 6 routes association (3 privées/3 publiques)
- 3 EIP (1/chaque NAT gateway)

### Ressources AWS
- 1 Bucket (testé pour déployer zip lambda depuis bucket)
- 1 lambda (API python avec FastAPI)
- 1 API Gateway (branchée sur le lambda)
- 1 Cognito

### API
#### Exposée via API Gateway

- 1 endpoint HTTP GET (/)
- 1 endpoint HTTP POST (/api/v1/trustpair) qui requiert un token obtenu par authentification auprès de cognito **et** le body suivant:
```
{
    "name": "blabla",
    "description": "blabla)"
}
```
### Monitoring

- 1 Cloudwatch log group qui récupère les logs du Lambda
- 1 Cloudwatch alarm mais qui ne fonctionne pas :( (pas de data reçue)

## Flow DEMO

1. sourcer venv pour pouvoir executer tflocal/awslocal

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
