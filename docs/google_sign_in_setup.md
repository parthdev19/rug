# Google Sign-In Android setup

`ApiException: 10` means Google Play services rejected the app's OAuth
configuration before the app can call the RUG backend. It cannot be fixed by
changing the Google ID token request alone.

In the Firebase project `rugcards-a8808`, add (or update) the Android app with:

| Setting | Value |
| --- | --- |
| Package name | `com.parth.rug` |
| Debug SHA-1 | `0A:EA:0A:28:BD:A7:E0:5B:0B:20:D1:8E:F5:11:C3:59:04:CC:99:FC` |
| Debug SHA-256 | `52:AE:BD:60:9A:91:35:DF:3A:72:8A:27:1D:5A:F7:F2:D9:C0:99:86:B2:BA:03:17:6C:4D:E5:D9:7C:CB:FF:80` |

Then download the newly generated `google-services.json` and replace
`android/app/google-services.json`. The downloaded file must contain an
`oauth_client` whose `client_type` is `1` and whose Android package is
`com.parth.rug`. Keep the existing Web client ID as the server client ID in
`auth_controller.dart`; it is the audience for the ID token sent to the API.

For release builds, register the SHA-1 and SHA-256 from the release signing
key as well. Rebuild and reinstall the app after replacing the configuration.
