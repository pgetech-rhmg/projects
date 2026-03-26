const aws = require('aws-sdk');

/**
* Sample Lambda function that will automatically approve any task submitted to sqs by state machine.
* For demonstration purposes this Lambda function simply returns a random integer between 0 and 100 as the stock price.
* 
* @param {Object} event - Input event to the Lambda function
* @param {Object} context - Lambda Context runtime methods and attributes
* 
*/
exports.lambdaHandler = (event, context, callback) => {
    const stepfunctions = new aws.StepFunctions();

    // For every record in sqs queue
    for (const record of event.Records) {
        const messageBody = JSON.parse(record.body);
        const taskToken = messageBody.TaskToken;

        const params = {
            output: "\"approved\"",
            taskToken: taskToken
        };

        console.log(`Calling Step Functions to complete callback task with params ${JSON.stringify(params)}`);

        // Approve
        stepfunctions.sendTaskSuccess(params, (err, data) => {
            if (err) {
                console.error(err.message);
                callback(err.message);
                return;
            }
            console.log(data);
            callback(null);
        });
    }
};