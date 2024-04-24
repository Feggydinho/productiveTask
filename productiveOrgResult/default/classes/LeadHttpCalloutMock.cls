public class LeadHttpCalloutMock implements HttpCalloutMock {
    Integer statusCode;
    String responseBody;

    public LeadHttpCalloutMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(this.responseBody);
        response.setStatusCode(this.statusCode);
        return response;
    }
}