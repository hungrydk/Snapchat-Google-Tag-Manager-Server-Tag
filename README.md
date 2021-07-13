# Google Tag Manager Template for TikTok Conversions API (server-side)
This template can be used in a S2S integration with Google Tag Manager. It uses the Snapchat Marketing API to send events directly to Snapchat.

## Getting started
1. Download the template.tpl file
2. Navigate to your Google Tag Manager Server Container
3. In the left pane click `Templates`
4. Under Tag Templates click the `New` button
5. In the top right corner click the three dots and import the template.tpl file from the previous step
6. Complete the Tag configuration by filling in the required fields. Note that in order to send events toe Snapchats Marketing API the OAuth scope `snapchat-offline-conversions-api` is required. ([see Snapchat Authentication docs on how to obtain Refresh Token, Client ID and Client Secret](https://marketingapi.snapchat.com/docs/#authentication))
7. Save the template and go back
8. In the left pane click `Tags` and add a Trigger for the newly imported Tag

## Supported events
Currently this template only allows for tracking conversions.

--------
Example of an incoming event:
```
{
  "event_name": "purchase",
  "currency": "EUR",
  "value": 123,
  "transaction_id": "test_transaction_id",
  "user_data": {
    "email_address": "abc@example.com",
    "phone_number": "12345678"
  }
}
```
