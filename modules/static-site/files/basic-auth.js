var authUser = '${auth_user}';
var authPass = '${auth_pass}';

function handler(event) {
    var request = event.request;
    var headers = request.headers;

    var authString = 'Basic ' + (authUser + ':' + authPass).toString('base64');

    if (
        typeof headers.authorization === 'undefined' ||
        headers.authorization.value !== authString
    ) {
        return {
            statusCode: 401,
            statusDescription: 'Unauthorized',
            headers: {
                'www-authenticate': {value: 'Basic'}
            }
        };
    }

    return request;
}
