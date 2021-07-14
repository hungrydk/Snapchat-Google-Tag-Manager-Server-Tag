___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Snapchat Conversions API Tag",
  "categories": ["CONVERSIONS"],
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "A server-side tag template that prepares information from your tagging server to be sent through Snapchats Conversions API.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "pixel_id",
    "displayName": "Pixel ID",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "refresh_token",
    "displayName": "Snapchat Refresh token",
    "simpleValueType": true,
    "defaultValue": "hej"
  },
  {
    "type": "TEXT",
    "name": "client_id",
    "displayName": "Snapchat Client Id",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "client_secret",
    "displayName": "Snapchat Client Secret",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

const templateDataStorage = require('templateDataStorage');
const setResponseBody = require('setResponseBody');
const setResponseStatus = require('setResponseStatus');
const setResponseHeader = require('setResponseHeader');
const getTimestampMillis = require('getTimestampMillis');
const sendHttpRequest = require('sendHttpRequest');
const JSON = require('JSON');
const getAllEventData = require('getAllEventData');
const sha256Sync = require('sha256Sync');


const tokenTemplateStorageKey = "accessToken";
const saveAccessToken = (token) => templateDataStorage.setItemCopy(tokenTemplateStorageKey, token);
const getAccessToken = () => templateDataStorage.getItemCopy(tokenTemplateStorageKey);

function isAlreadyHashed(input){
  return input && (input.match('^[A-Fa-f0-9]{64}$') != null);
}


function hashFunction(input){
  if(input == null || isAlreadyHashed(input)){
    return input;
  }

  return sha256Sync(input.trim().toLowerCase(), {outputEncoding: 'hex'});
}


const eventModel = getAllEventData();

// Payload used for the Snapchat Conversion API
const snapchatPurchaseConversionPayload = JSON.stringify({
  "pixel_id": data.pixel_id,
  "timestamp": getTimestampMillis(),
  "event_type": "PURCHASE",
  "event_conversion_type": "WEB",
  "version": "2.0",
  "event_tag": "instore",
  "price": eventModel.value,
  "currency": eventModel.currency,
  "transaction_id": eventModel.transaction_id,
  "hashed_email": hashFunction(eventModel.user_data.email_address),
  "hashed_phone_number": hashFunction(eventModel.user_data.phone_number)
});


// HTTP Request sent to snapchat to refresh access_token
const refreshAccessToken = (callback) => {
  let postBody = "refresh_token=" + data.refresh_token;
  postBody += "&client_id=" + data.client_id;
  postBody += "&client_secret=" + data.client_secret;
  postBody += "&grant_type=refresh_token";


  sendHttpRequest('https://accounts.snapchat.com/login/oauth2/access_token', (statusCode, headers, body) => {
    const parsedBody = JSON.parse(body);
    if (statusCode >= 200 && statusCode <= 300 && parsedBody.access_token) {
      callback(parsedBody.access_token);
    }
  }, {headers: {'Content-Type': 'application/x-www-form-urlencoded'}, method: 'POST', timeout: 500}, postBody);
};


let attempts = 0;
// HTTP Request sent to snapchat to trigger a conversion
const purchaseConversion = (access_token, requestBody) => {
  sendHttpRequest('https://tr.snapchat.com/v2/conversion', (statusCode, headers, body) => {
    if (statusCode >= 200 && statusCode <= 300) {
      data.gtmOnSuccess();
    } else {
      data.gtmOnFailure();
    }
  }, {headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + access_token,
  }, method: 'POST', timeout: 2000}, requestBody);
};


// Use access token from storage.
const accessToken = getAccessToken();

if (accessToken) {
  // If access token is available, call the purchase conversion api.
  purchaseConversion(accessToken, snapchatPurchaseConversionPayload);
} else {
  // If no access token is available, aquire a new one.
  refreshAccessToken((new_access_token) => {
    saveAccessToken(new_access_token);
    purchaseConversion(new_access_token, snapchatPurchaseConversionPayload);
  });
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_template_storage",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "writeHeaderAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://tr.snapchat.com/v2/*"
              },
              {
                "type": 1,
                "string": "https://accounts.snapchat.com/login/oauth2/access_token"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Untitled test 1
  code: |-
    const mockData = {
      // Mocked field values
    };

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('logToConsole').wasCalled();


___NOTES___

Created on 14/07/2021, 12:26:21

