/**
 * @description       : Test class for ApiController
 * @author            : Erlend.Hansen@stretch.no | https://trailblazer.me/id/ehansen7
 * @group             : SharedCode, Test
 * @last modified on  : 03-17-2023
 * @last modified by  : Erlend.Hansen@stretch.no | https://trailblazer.me/id/ehansen7
 **/
@isTest
private class ApiControllerTest {
  @isTest
  static void testInit() {
    ApiController ctrl = new ApiController()
      .init('My_Named_Credential', ApiController.HttpVerb.DEL, '/some/path');
    System.assertEquals('callout:My_Named_Credential', ctrl.endpoint);
    System.assertEquals('/some/path', ctrl.path);
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
    System.assertEquals(
      'Bearer token',
      ctrl.request.getHeader('Authorization')
    );
    System.assertEquals(
      'application/json',
      ctrl.request.getHeader('Content-Type')
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
    System.assertEquals(
      '/some/path?param1=valueStored',
      ctrl.request.getEndpoint()
    );
  }

  @isTest
  static void testAddBody() {
    ApiController ctrl = new ApiController()
      .init('My_Named_Credential', ApiController.HttpVerb.POST, '/some/path');
    ctrl.addBody('{"foo":"bar"}');
    System.assertEquals('{"foo":"bar"}', ctrl.request.getBody());
  }

  @isTest
  static void testDoCallout() {
    ApiController ctrl = new ApiController()
      .init('My_Named_Credential', ApiController.HttpVerb.GET, '/some/path');
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();
    ctrl.doCallout();
    Test.stopTest();
    System.assertEquals(200, ctrl.response.getStatusCode());
    System.assertEquals('{"foo":"bar"}', ctrl.response.getBody());
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
      System.assertEquals(
        'Error occurred while calling external API: TEST EXCEPTION',
        e.getMessage()
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
      System.assert(
        ex.getMessage().contains('Invalid input parameters on method "init"')
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
      System.assert(
        ex.getMessage()
          .contains(
            'Path should not contain query parameters. Please use the "addQueryParameter" method instead.'
          )
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
