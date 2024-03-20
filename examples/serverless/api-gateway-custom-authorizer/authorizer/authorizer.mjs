import {CognitoJwtVerifier} from "aws-jwt-verify";
import {JwtExpiredError} from "aws-jwt-verify/error"

const userPoolId = process.env.USER_POOL_ID;
const clientId = process.env.USER_POOL_CLIENT_ID;

const verifier = CognitoJwtVerifier.create({
    userPoolId: userPoolId,
    tokenUse: "id",
    clientId: clientId,
});
export const handler = async (event) => {
    try {
        // Verify JWT Token
        const token = event.authorizationToken.split(" ")[1];
        const payload = await verifier.verify(token);
        const principal = payload["email"];
        console.log(payload);
        // do whatever you need with the verified token. For example return policies from DynamoDb by user groups

        const policy = generatePolicy(principal);
        console.log(policy);
        return policy;
    } catch (err) {
        if (err instanceof JwtExpiredError) {
            throw new Error('Unauthorized');
        } else {
            console.log(err);
            return generateDenyPolicy('user');
        }
    }
};

const generatePolicy = (principalId) => {
    return {
        principalId: principalId,
        policyDocument: {
            Version: '2012-10-17',
            Statement: [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": "Allow",
                    "Resource": "arn:aws:execute-api:*:*:*/*/*/*"
                }
            ]
        },
    };
};

const generateDenyPolicy = (principalId) => {
    return {
        principalId: principalId,
        policyDocument: {
            Version: '2012-10-17',
            Statement: [
                {
                    Action: "execute-api:Invoke",
                    Effect: "Deny",
                    Resource: "arn:aws:execute-api:*:*:*/ANY/*"
                }
            ]
        }
    };
};