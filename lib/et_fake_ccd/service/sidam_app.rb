require 'roda'
require 'json'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/auth_service'
require 'et_fake_ccd/forced_error_handling'
module EtFakeCcd
  module Service
    class SidamApp < Roda
      include EtFakeCcd::ForcedErrorHandling
      plugin :request_headers
      plugin :halt
      route do |r|
        r.is "loginUser" do
          r.post do
            with_forced_error_handling(r, stage: :token) do
              command = ::EtFakeCcd::Command::LoginUserCommand.from_json(r.params)
              if command.valid?
                logged_in_result
              else
                r.halt 401, render_error_for(command)
              end
            end
          end
        end
        r.is "details" do
          r.get do
            with_forced_error_handling(r, stage: :token) do
              details_result
            end
          end
        end
      end

      private

      def logged_in_result
        j = {
            "access_token": ::EtFakeCcd::AuthService.generate_user_token,
            "scope": "acr openid profile roles authorities",
            "id_token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJLQ3hCZGVoc0hVRjY5NzhTaXp2SVNFeGNYMEU9IiwiYWxnIjoiUlMyNTYifQ.eyJhdF9oYXNoIjoiWkFUeXNZVzE3UHk3a2ZKenp3dEhkdyIsInN1YiI6ImVyaWMuY2NkY29vcGVyQGdtYWlsLmNvbSIsImF1ZGl0VHJhY2tpbmdJZCI6Ijg0YjM0YzI2LTk4ZDktNGIxMS04MGIyLWRhOTAwOWM0MDM0MC0yMjE3MzM4Iiwicm9sZXMiOlsiY2FzZXdvcmtlci1lbXBsb3ltZW50LXRyaWJ1bmFsLW1hbmNoZXN0ZXItY2FzZXN1cGVydmlzb3IiLCJjYXNld29ya2VyLWVtcGxveW1lbnQtdHJpYnVuYWwtZ2xhc2dvdy1jYXNlb2ZmaWNlciIsImNhc2V3b3JrZXItZW1wbG95bWVudC10cmlidW5hbC1nbGFzZ293IiwiY2FzZXdvcmtlci1lbXBsb3ltZW50IiwiY2FzZXdvcmtlciIsImNhc2V3b3JrZXItcHVibGljbGF3LWxvY2FsQXV0aG9yaXR5IiwiY2FzZXdvcmtlci1lbXBsb3ltZW50LXRyaWJ1bmFsLW1hbmNoZXN0ZXIiLCJjYXNld29ya2VyLXB1YmxpY2xhdyIsImNhc2V3b3JrZXItZW1wbG95bWVudC10cmlidW5hbC1nbGFzZ293LWNhc2VzdXBlcnZpc29yIiwiY2FzZXdvcmtlci1lbXBsb3ltZW50LXRyaWJ1bmFsLW1hbmNoZXN0ZXItY2FzZW9mZmljZXIiXSwiaXNzIjoiaHR0cHM6Ly9mb3JnZXJvY2stYW0uc2VydmljZS5jb3JlLWNvbXB1dGUtaWRhbS1kZW1vLmludGVybmFsOjg0NDMvb3BlbmFtL29hdXRoMi9obWN0cyIsInRva2VuTmFtZSI6ImlkX3Rva2VuIiwiZ2l2ZW5fbmFtZSI6IkVyaWMiLCJhdWQiOiJobWN0cyIsImF6cCI6ImhtY3RzIiwiYXV0aF90aW1lIjoxNTYxNzM0NDY0LCJuYW1lIjoiRXJpYyBDQ0RfQ29vcGVyIiwicmVhbG0iOiIvaG1jdHMiLCJleHAiOjE1NjE3MzgwNjQsInRva2VuVHlwZSI6IkpXVFRva2VuIiwiZmFtaWx5X25hbWUiOiJDQ0RfQ29vcGVyIiwiaWF0IjoxNTYxNzM0NDY0fQ.Fh7E9DZiwXIyCAbapRG-TMcfp2HkmcYaLDms9g5_VhJvTtA3VnAykPStNN4ctC64SG2Kv6xJ5o_ivJlVxR5UqEdap-cD77JiRi0wMAOLfmB16n65i0XJkyVO4J5tw0odSS7nKOpZJ0-fW6lQh4qLhYjShUNDxT5iobmRC7TA195wNmDCG0K4oMcqbtT6S-TUGBbsVxdfOsB9kXxMYhCAfOJfgzFsDv_cs7PLY1y89GEdIT3o5SWD_f14U7ksp8Xkmv_mkI_Cl4AlqdMcU4uxjIoF37q5vcJUki7I7okbZJ93ePe99_eW0nxoCGk2qLX_RKID1ock9lSmThHQSXgxnw",
            "token_type": "Bearer",
            "expires_in": "28799",
            "api_auth_token": "eyJtb25rZXkiOiJkWjFoVTFXb1RPVldZLTUydHRtN1A0OVB4ZTAuKkFBSlRTUUFDTURFQUFsTkxBQnh0THpRMVFsb3JRV1F3TVZZeVVqaE1iVTUxVTNaNFJYVlhaMnM5QUFKVE1RQUEqIiwicmFiYml0Ijoic2Vzc2lvbi1qd3Q9ZXlKMGVYQWlPaUpLVjFRaUxDSmpkSGtpT2lKS1YxUWlMQ0poYkdjaU9pSklVekkxTmlKOS5aWGxLTUdWWVFXbFBhVXBMVmpGUmFVeERTbXhpYlUxcFQybEtRazFVU1RSUk1FcEVURlZvVkUxcVZUSkphWGRwV1ZkNGJrbHFiMmxWYkU1Q1RWWTRNVWx1TUM1elF6VnFSakJFTFd3MVYySktUMGh4Y1ZNM2NVNVhXbXBtYkdrNWRERmlhMjFKYnpWYWVGaFlZa28wYXpkNE5FMTJVMW8zZUdkME9VUjFSR1UzVVVzM2JERnRaa1U1VWpNNUxXUXROMFJrWVdOaFdHVmpVa3Q1T0dOSGJ6UlBYMlpSZHpGc1draHROMjVRWlVwTFdHTkZSMlJJUkZSdE5sZG9iRVJwY3pCdk16SnZhR1ZpWVhOaWJFSk5aRkptWWxkbmMwbFliVUprVEMxQ2NsRnlPV1pJU1RGUFlVaHRlamxUU0c1VVZtdERVR2xvVjFVMGMzbHpSalI2WW5Fd1dUUldRV1U0TTJsak9WSktkMTlITFhKM05TMVdZME14UTB3d2FtdzNWbUZVT1ZOVGRtSm9iWGRsVVhBNGFUbFNTbkpqVm5CQlQzZFJZMHBpU0RobE4wNHdUbFpoY0dobFF6bFRVRTFEVWtNMlptZG5ZMlUzVHpabVZVSnhkemRDVEZSWFlURnhlV0Z5WmtwRGVIRjRaRlZZZUVRNFRXczVXWGhvZEVKRVZGUk1OMXBDUkV0RlN6Qm9TbTFGUlU5VldsSnhPVXh2TlhjdWF6WkRjblJsYmpJNFRtSkJRbUZQUm1keVVHUnNaeTVDVVZwSU1teEZYMFUwVWs5TlMwWnlUSFE1VURaUVpGaDZXRGRqVVhrMU5VaFROazV1Y2tOM1ZsbDNhak5RTUZweVpsVnhjRGhzTTA0dE1FdFZiVE5CZVV0TFQxZExkMGN0VFd4RE9XZGhabTVJVTJ4VE9VUnJkRmRDUkhNM2IyZE5SWG8zVjBKSGN6TlRTVkZuV0Y5c1IySjNSM001TmpObmFXWkVRazFZZHpaRGVWOXBXVmRNY25SYVFXZFlOSEJJTkhSd1dGbHFhbUZpTkhGcmNDMDFSREEzVms1ZmRVcFlNbkJrVDJNemFVWkRhRGxMVkZkUlZWbElXVlV4T1hjME5sSkdkWHBpUXpGWU1rTkZWVkJHUWxCSFRWSXlNRWRQY1U1eVZuVkJkbUpaUkVkWlJXWmlORzFQV0VwRE5ra3djM2xrVVZCNWFqSlBRemgwVUhRNGMxZFdPRWRKUVdWbFpEQndOVE5ETVU5UlFqRlBiSGhSUW5aeGRVVmZTVE5OUjNsdE1uSjBhalpTYWxCa1NHeGxkV2QyTmxSVloyRktjVmRNVUhveVdXNTZTSHBaWTNvdFJsZG9NVWszVW0weVVFUXphVmh3TUU5MGFtWmFjRTB6YTJOaFVFdDFWbkZUTm5sNVNtdHJialJ1TFc0eVZFbEJURTVEY21aNGJXUkVObDlFY2pWU2JUVTFWRlp6WW5OM2NGcFpkbmg0VEVZMlpYRlZTazR5ZUV4eGNURndRa1pvVjAxMWNVaDFVSFF6VEVOeVpESjNSVWxyWm5ocFQxTTBUREZKV1hwUmIyVktlbEJTTUZOUU1GQnpNM0JKU1dRMFdrbE5UbVZsUkdwbVl6Z3RXalZPVURsQlVVVnBUREJNVERsRU1tRm9iV2RIVHpCVlZEaEVlVlpVYURsYU1uWm9UMGhSYTJOcWFUWXdlblJUVEdJMmVHVmFlakp4ZVd4c1kzUm9Rbk5WWms0M09HTm5kamx2ZUdOUk1VSXlhSEV0TkZaUWJsTTNRVGN4ZEY5ZlNtSkVOakZvYzJSeVFWaGphMDkzUkhGYVQxaHNaRzB4U1RKRFVtaEtNVU5uYlhjMmJHdHhTM2hRWTNNNFdEVmtaMVZmWVcxNlpVaFFXWE5UUjI5a2VtbFlVamx1TjJGQ1oyWkhRMjVuZGxWeU1scFBUVGxFUm1WUFZGRmZTMk5KUWkxR1JqaE9YMkp5V0Y5UVFraEhSREJqT1VSS2Jub3lOM04xVWxWTGMzbzJlblJJWTJwUU5tdE5RM1V5TmpBeFlYWjZRbDh3WW5CeGRsZDZVM0oxY3pKTmRXdExaRGRPWmw5aVVsaFJaRkJuTFY5cWVXVndOWGhZTmpSblRqZDVjWEIyVG5KUE5sWXhjemR2VFcxQ1lXZ3phRlEzZFdkUFlsSjZhbXR0ZVZsWVgwVnBlVFJVT0VGMFRrTndZMU5FT0RBMmJIQXdaRVIyWjNVeVpGZFNNVTFuYUZsdk5TMXpYemxzWVdwNk5pMTFWVGQxU0dwWlJtZEllamhUT0VOd09VRTFiRTVhYzNGVFVXRm9kRzltY0VaMFJsWnRhR016U1RoME4ya3RkMWxZVEdoNVlVWk1ibkZ0UzFVMFl6Y3pWbUY1TWkxc1kxUkpTbU5tT1VGMVVHZDFiMFZFUWpKT2Ntc3hZa3RXTUdScFNVeFRPRFpPYVdKWE4ydE1ja2MxVURCb1JIcGllWEpxYW1RMGNUWlpaM2RuV25sdWIyWnRhazlSWm5GdVExbzVaV2xSWDJWR2J6Rm9YMmw1WDBaQmF6UXROVVZVYlVVMk5tOUNPVXMyUm5JelZtYzNSMDFHZUdKbWVYazRjVzVZU3pSdlIwUk9hVXRMTjNvMU1sTmlTbmRLTjJKSFExOHliRGRQUjJwUVNGaHNlbVJaV0VsSlowUldiMVZSZWs1WVZFdHFYMUV6WTBaaFIwUlhZM1Z5VEZFdVNUVlpVVTB6ZW5VeE5VZ3lVbkl3VmtjemNXbEpkdy5sOHBBbEd5WHhEUnQ3N0FZVy1YVHVlRUpMSVprUDV5OFo0MkI5RVotV240OyBQYXRoPS87IEh0dHBPbmx5In0="
        }
        JSON.generate(j)
      end

      def details_result
        j = {
            "id": "650692bb-cefe-466a-ba8d-687377173064",
            "forename": "Fred",
            "surname": "Bloggs",
            "email": "fred.bloggs@gmail.com",
            "active": true,
            "roles": [
                "caseworker-publiclaw-localAuthority",
                "caseworker-publiclaw",
                "caseworker",
                "caseworker-employment-tribunal-manchester",
                "caseworker-employment-tribunal-manchester-caseofficer",
                "caseworker-employment-tribunal-manchester-casesupervisor",
                "caseworker-employment-tribunal-glasgow",
                "caseworker-employment",
                "caseworker-employment-tribunal-glasgow-casesupervisor",
                "caseworker-employment-tribunal-glasgow-caseofficer"
            ]
        }
        JSON.generate j
      end

      def render_error_for(command)
        "Its broke"
      end

    end
  end
end
