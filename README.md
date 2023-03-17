# How to use the `ApiController` class

`ApiController` is a Controller for handling all integrations using the `HttpRequest` and `HttpResponse` classes in Apex. This simple guide explains how to use the class in your Apex code.

## Prerequisites

Before using the `ApiController`, you need to ensure that:

- You have created a named credential to authenticate the API callout.

## Deployment

You can use the quick installer here to deploy directly to your org.

[![Deploy to salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png)](https://githubsfdeploy.herokuapp.com/?owner=Stretch-Engage&repo=ApiController)

## Usage

To use the `ApiController` class, follow these steps:

1.  Create an instance of the class:

```Java
ApiController api = new ApiController();
```

2.  Initialize the controller with a named credential and a path:

```Java
api.init('named_credential', ApiController.HttpVerb.GET, '/path/to/resource');
```

Note that you need to specify the `HttpVerb` enum value to determine the HTTP method for the API callout.

3.  Set additional parameters and add headers if necessary:

```Java
api.setTimeout(5000);
api.addHeader('Content-Type', 'application/json');
```

4.  Add query parameters and a request body if necessary:

```Java
Map<String, String> queryParams = new Map<String, String>{
    'param1' => 'value1',
    'param2' => 'value2'
};
api.addQueryParameter(queryParams);

String requestBody = '{"key": "value"}';
api.addBody(requestBody);
```

5.  Perform the API callout:

```Java
api.doCallout();
```

6.  Retrieve the response from the controller:

```Java
HttpResponse response = api.getResponse();
```

### Chainable example

You can also chain the methods together to create a more concise code. The only requirement is that you call the `init` method first, and then the `doCallout` method last. The `getResponse` method can be called after the `doCallout` method you require the response.

```Java
ApiController api = new ApiController();
api.init('named_credential', ApiController.HttpVerb.GET, '/path/to/resource')
    .setTimeout(5000)
    .addHeader('Content-Type', 'application/json')
    .addQueryParameter(
        new Map<String, String>{
            'param1' => 'value1',
            'param2' => 'value2'
        })
    .addBody('{"key": "value"}')
    .doCallout();

HttpResponse res = api.getResponse();
```
