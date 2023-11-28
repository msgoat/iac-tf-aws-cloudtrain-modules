export const handler = async (event) => {
    console.info('received:', event);

    let responseBody = {
        message: "Hello from Lambda"
    }

    return {
        statusCode: 200,
        body: JSON.stringify(responseBody)
    };
};