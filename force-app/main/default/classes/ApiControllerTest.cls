/**
 * @description       : Test class for ApiController
 * @author            : Erlend.Hansen@stretch.no | https://trailblazer.me/id/ehansen7
 * @group             : SharedCode, Test
 * @last modified on  : 04-14-2023
 * @last modified by  : Erlend.Hansen@stretch.no | https://trailblazer.me/id/ehansen7
 **/
@isTest
private class ApiControllerTest {
  @isTest
  static void testInit() {
    ApiController ctrl = new ApiController()
      .init('My_Named_Credential', ApiController.HttpVerb.DEL, '/some/path');
    Assert.areEqual(
      'callout:My_Named_Credential',
      ctrl.endpoint,
      'The Named Credential did not match the provided endpoint'
    );
    Assert.areEqual(
      '/some/path',
      ctrl.path,
      'The path did not match the test path'
    );
  }

  @isTest
  static void testAddHeaders() {
    ApiController ctrl = new ApiController()
      .init('My_Named_Credential', ApiController.HttpVerb.GET, '/some/path');
    Map<String, String> headers = new Map<String, String>{
      'Authorization' => 'Bearer token',
      'Content-Type' => 'application/json'
    };
    ctrl.addHeaders(headers);
    Assert.areEqual(
      'Bearer token',
      ctrl.request.getHeader('Authorization'),
      'The Authorization header did not match the provided token value'
    );
    Assert.areEqual(
      'application/json',
      ctrl.request.getHeader('Content-Type'),
      'The Content-Type header did not match the provided data type'
    );
  }

  @isTest
  static void testAddQueryParameter() {
    ApiController ctrl = new ApiController()
      .init('My_Named_Credential', ApiController.HttpVerb.GET, '/some/path');
    Map<String, String> queryParameters = new Map<String, String>{
      'param1' => 'valueStored'
    };
    ctrl.addQueryParameter(queryParameters);
    ctrl.doCallout();
    Assert.areEqual(
      '/some/path?param1=valueStored',
      ctrl.request.getEndpoint(),
      'The query parameter did not match the provided values at the end of the path.'
    );
  }

  @isTest
  static void testAddBody() {
    ApiController ctrl = new ApiController()
      .init('My_Named_Credential', ApiController.HttpVerb.POST, '/some/path');
    ctrl.addBody('{"foo":"bar"}');
    Assert.areEqual('{"foo":"bar"}', ctrl.request.getBody());
  }

  @isTest
  static void testDoCallout() {
    ApiController ctrl = new ApiController()
      .init('My_Named_Credential', ApiController.HttpVerb.GET, '/some/path');
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();
    ctrl.doCallout();
    Test.stopTest();
    Assert.areEqual(
      200,
      ctrl.response.getStatusCode(),
      'Status code should be 200 for a successful GET request.'
    );
    Assert.areEqual(
      '{"foo":"bar"}',
      ctrl.response.getBody(),
      'The response body should be {"foo":"bar"}'
    );
  }

  private class MockHttpResponseGenerator implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody('{"foo":"bar"}');
      return response;
    }
  }

  /*********************************************
   * SECTION FOR CUSTOM EXCEPTIONS HANDLING
   *********************************************/
  @isTest
  static void testDoCalloutException() {
    ApiController ctrl = new ApiController()
      .init('My_Named_Credential', ApiController.HttpVerb.GET, '/some/path');
    Test.setMock(HttpCalloutMock.class, new ApiExceptionMock());
    Test.startTest();
    try {
      ctrl.doCallout();
      // The method should have thrown an exception, so we fail the test if it doesn't
      System.assert(false, 'Expected an exception to be thrown, but none was.');
    } catch (ApiController.ApiControllerException e) {
      // We expect an exception to be thrown, so we assert that it's the correct type
      Assert.areEqual(
        'Error occurred while calling external API: TEST EXCEPTION',
        e.getMessage(),
        'The exception message should be "Error occurred while calling external API: TEST EXCEPTION"'
      );
    }
    Test.stopTest();
  }

  // A private inner class that extends HttpCalloutMock to simulate an exception being thrown
  private class ApiExceptionMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      throw new TestException('TEST EXCEPTION');
    }
  }

  private class TestException extends Exception {
  }

  @IsTest
  static void testInitWithInvalidInput() {
    try {
      new ApiController().init(null, null, null);
      System.assert(false, 'Exception should have been thrown.');
    } catch (ApiController.ApiControllerException ex) {
      Assert.isTrue(
        ex.getMessage().contains('Invalid input parameters on method "init"'),
        'Exception message should contain "Invalid input parameters on method "init"'
      );
    }
  }

  @IsTest
  static void testInitWithQueryParamsInPath() {
    try {
      new ApiController()
        .init(
          'MyNamedCredential',
          ApiController.HttpVerb.GET,
          '/path?param1=value1'
        );
      System.assert(false, 'Exception should have been thrown.');
    } catch (ApiController.ApiControllerException ex) {
      Assert.isTrue(
        ex.getMessage()
          .contains(
            'Path should not contain query parameters. Please use the "addQueryParameter" method instead.'
          ),
        'Exception message should contain "Path should not contain query parameters. Please use the "addQueryParameter" method instead."'
      );
    }
  }

  @IsTest
  static void testSetTimeoutWithInvalidInput() {
    try {
      new ApiController().setTimeout(-1);
      System.assert(false, 'Exception should have been thrown.');
    } catch (ApiController.ApiControllerException ex) {
      System.assert(
        ex.getMessage()
          .contains('Timeout must be within 1-120,000 milliseconds')
      );
    }
  }

  @IsTest
  static void testGetResponseBeforeCallout() {
    try {
      new ApiController().getResponse();
      System.assert(false, 'Exception should have been thrown.');
    } catch (ApiController.ApiControllerException ex) {
      System.assert(
        ex.getMessage()
          .contains(
            'Response is null. Please call the "doCallout" method first.'
          )
      );
    }
  }
}
