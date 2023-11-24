export const handler = async (event) => {
    for (const record of event.Records) {
        console.info(JSON.stringify(record));
    }
    return {};
};