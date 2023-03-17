/**
 * @description       : ApiController is a wrapper class for the HttpRequest and HttpResponse classes.
 *                    : Used for handling all integrations
 * @author            : Tor Håkon Sigurdsen
 * @group             : SharedCode, Controller
 * @last modified on  : 03-17-2023
 * @last modified by  : Erlend.Hansen@stretch.no | https://trailblazer.me/id/ehansen7
 **/
public without sharing class ApiController {
    @TestVisible
    protected HttpRequest request;
    @TestVisible
    protected HttpResponse response;
    @TestVisible
    private String endpoint;
    @TestVisible
    private String path;
  
    /**
     * @description Initialize the controller with a named credential and a path.
     * @param namedCredential
     * @param method
     * @param path
     * @return ApiController
     **/
    public ApiController init(
      String namedCredential,
      HttpVerb method,
      String path
    ) {
      if (String.isBlank(namedCredential) || String.isBlank(path)) {
        throw new ApiControllerException(
          'Invalid input parameters on method "init"'
        );
      }
      if (path.contains('?')) {
        throw new ApiControllerException(
          'Path should not contain query parameters. Please use the "addQueryParameter" method instead.'
        );
      }
      request = new HttpRequest();
  
      this.endpoint = 'callout:' + namedCredential;
      this.path = path;
      this.setMethod(method);
      return this;
    }
  
    /**
     * @description This ENUM lists possible HTTP Verbs. Note: 'Delete' is an Apex Keyword (DML)
     * and as a result, the ENUM value 'DEL' is used for delete.
     */
    public enum HttpVerb {
      GET,
      POST,
      PUT,
      PATCH,
      DEL
    }
  
    /**
    * @description Set the timeout for the request in milliseconds.
    * @param timeout 
    * @return ApiController 
    **/
    public ApiController setTimeout(Integer timeout) {
      if (timeout < 1 || timeout > 120000) {
        throw new ApiControllerException(
          'Timeout must be within 1-120,000 milliseconds'
        );
      }
      request.setTimeout(timeout);
      return this;
    }
  
    /**
     * @description Execute the request and store the response in the controller.
     * @return HttpResponse
     **/
    public void doCallout() {
      try {
        this.request.setEndpoint(this.endpoint + this.path);
        System.debug('### Endpoint: ' + this.endpoint + this.path);
        System.Debug('### Request: ' + this.request);
        this.response = new Http().send(this.request);
        System.debug(
          '### Response status code: ' + this.response.getStatusCode()
        );
        // System.debug('### Response body: ' + this.response.getBody());
      } catch (Exception ex) {
        throw new ApiControllerException(
          'Error occurred while calling external API: ' + ex.getMessage()
        );
      }
    }
  
    /**
     * @description Add a map of headers to the request
     * @param Map<String String> headers
     **/
    public ApiController addHeaders(Map<String, String> headers) {
      if (headers != null && !headers.isEmpty()) {
        for (String key : headers.keySet()) {
          addHeader(key, headers.get(key));
        }
      }
  
      return this;
    }
  
    /**
    * @description Add a content length header to the request
    * @param length 
    **/
    public ApiController addContentLength(Integer length) {
      this.addHeader('content-length', String.valueOf(length));
      return this;
    }
  
    /**
     * @description Add a single header value to the request
     * @param String key
     * @param String value
     **/
    public ApiController addHeader(String key, String value) {
      request.setHeader(key, value);
      return this;
    }
  
    /**
    * @description Set the HTTP method for the request using the HttpVerb ENUM
    * @param method - HttpVerb (GET, POST, PUT, PATCH, DEL)
    **/
    private ApiController setMethod(HttpVerb method) {
      if (method == HttpVerb.DEL) {
        this.request.setMethod('DELETE');
      } else {
        this.request.setMethod(String.valueOf(method));
      }
  
      return this;
    }
  
    /**
    * @description Add query parameters to the request
    * @param queryParameters 
    **/
    public ApiController addQueryParameter(Map<String, String> queryParameters) {
      for (String key : queryParameters.keySet()) {
        path.replace(key, queryParameters.get(key));
      }
      return this;
    }
  
    /**
    * @description Add a body to the request
    * @param body 
    **/
    public ApiController addBody(String body) {
      this.request.setBody(body);
      addContentLength(body.length());
      return this;
    }
  
    /**
     * @description Return the HttpResponse from the controller
     * @return HttpResponse
     **/
    public HttpResponse getResponse() {
      if (this.response == null) {
        throw new ApiControllerException(
          'Response is null. Please call the "doCallout" method first.'
        );
      }
      return response;
    }
  
    /** 
     * @description Custom exception class for the ApiController
     */
    public class ApiControllerException extends Exception {
    }
  }
  