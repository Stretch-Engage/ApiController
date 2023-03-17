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
ApiController apiController = new ApiController();
```

2.  Initialize the controller with a named credential and a path:

```Java
apiController.init('named_credential', ApiController.HttpVerb.GET, '/path/to/resource');
```

Note that you need to specify the `HttpVerb` enum value to determine the HTTP method for the API callout.

3.  Set additional parameters and add headers if necessary:

```Java
apiController.setTimeout(5000);
apiController.addHeader('Content-Type', 'application/json');
```

4.  Add query parameters and a request body if necessary:

```Java
Map<String, String> queryParams = new Map<String, String>{
    'param1' => 'value1',
    'param2' => 'value2'
};
apiController.addQueryParameter(queryParams);

String requestBody = '{"key": "value"}';
apiController.addBody(requestBody);
```

5.  Perform the API callout:

```Java
apiController.doCallout();
```

6.  Retrieve the response from the controller:

```Java
HttpResponse response = apiController.getResponse();
```
