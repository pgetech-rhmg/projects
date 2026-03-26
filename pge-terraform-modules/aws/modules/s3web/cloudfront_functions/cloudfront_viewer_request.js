function handler(event) {
    var request = event.request;
    var uri = request.uri;
    
    // Log the original URI for debugging (comment out in production)
    // console.log('Original URI:', uri);
    
    // Check if the URI has a file extension (static assets like .js, .css, .png, etc.)
    if (uri.includes('.')) {
        // If it has an extension, assume it's a static asset and return as-is
        return request;
    }
    
    // Check if URI ends with a slash (directory)
    if (uri.endsWith('/')) {
        // If it ends with slash, append index.html
        request.uri += 'index.html';
    } else {
        // For all other paths (SPA routes), redirect to index.html
        // This handles routes like /about, /contact, etc.
        request.uri = '/index.html';
    }
    
    // Log the modified URI for debugging (comment out in production)
    // console.log('Modified URI:', request.uri);
    
    return request;
}