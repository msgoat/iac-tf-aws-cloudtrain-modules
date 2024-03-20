# Testing

1. Create a user in cognito user pool
2. Execute following CURL to login

````
curl --location --request POST 'https://cognito-idp.${REGION}.amazonaws.com' \
--header 'X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth' \
--header 'Content-Type: application/x-amz-json-1.1' \
--data-raw '{
    "AuthParameters": {
        "USERNAME": "${USERNAME}",
        "PASSWORD": "${PASSWORD}"
    },
    "AuthFlow": "USER_PASSWORD_AUTH",
    "ClientId": "${AWS_COGNITO_CLIENT_ID}"
}'
````

3. When first login password must be changed

````
curl --location --request POST 'https://cognito-idp.${REGION}.amazonaws.com' \
--header 'X-Amz-Target: AWSCognitoIdentityProviderService.RespondToAuthChallenge' \
--header 'Content-Type: application/x-amz-json-1.1' \
--data-raw '{
    "ChallengeName": "NEW_PASSWORD_REQUIRED",
    "ClientId": "${AWS_COGNITO_CLIENT_ID}",
    "Session": "${SESSION_TOKEN}",
    "ChallengeResponses": {
        "NEW_PASSWORD": "${NEW_PASSWORD}",
        "USERNAME": "${USERNAME}"
    }
}'
````

4. Use Id-Token as Bearer Token in Authorization Header