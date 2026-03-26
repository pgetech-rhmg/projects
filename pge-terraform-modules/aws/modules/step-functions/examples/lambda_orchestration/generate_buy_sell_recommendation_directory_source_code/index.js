/**
* Sample Lambda function which mocks the operation of recommending buying or selling of stocks.
* For demonstration purposes this Lambda function simply returns a "buy" or "sell" string depending on stock price.
* 
* @param {Object} event - Input event to the Lambda function
* @param {Object} context - Lambda Context runtime methods and attributes
*
* @returns {String} - Either "buy" or "sell" string of recommendation.
* 
*/
exports.lambdaHandler = async (event, context) => {
    const { stock_price } = event;
    // If the stock price is greater than 50 recommend selling. Otherwise, recommend buying.
    return stock_price > 50 ? 'sell' : 'buy';
};
