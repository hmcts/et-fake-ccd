require "singleton"
module EtFakeCcd
  class AuthService
    include Singleton

    attr_reader :service_token, :user_token

    def self.generate_service_token
      instance.generate_service_token
    end

    def self.generate_user_token
      instance.generate_user_token
    end

    def self.validate_service_token(token)
      instance.validate_service_token(token)
    end

    def self.validate_user_token(token)
      instance.validate_user_token(token)
    end

    def generate_service_token
      self.service_token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJjY2RfZ3ciLCJleHAiOjE1NjE3NDIzMDN9.u9e1iGfAhXFsmGa4TbJBpnQ3Pps5Kdj64zPZELwEHqdSmMjWcDFaX1psf43QIKREB-7SU09oDBFTlcdJMxvOJw"
    end

    def generate_user_token
      self.user_token = "eyJ0eXAiOiJKV1QiLCJ6aXAiOiJOT05FIiwia2lkIjoiS0N4QmRlaHNIVUY2OTc4U2l6dklTRXhjWDBFPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJlcmljLmNjZGNvb3BlckBnbWFpbC5jb20iLCJhdXRoX2xldmVsIjowLCJhdWRpdFRyYWNraW5nSWQiOiI4NTg5NTc1OC1mMDg2LTRmMjgtYWIzOS1hNDBkNmE4YmRkYjciLCJpc3MiOiJodHRwczovL2Zvcmdlcm9jay1hbS5zZXJ2aWNlLmNvcmUtY29tcHV0ZS1pZGFtLWRlbW8uaW50ZXJuYWw6ODQ0My9vcGVuYW0vb2F1dGgyL2htY3RzIiwidG9rZW5OYW1lIjoiYWNjZXNzX3Rva2VuIiwidG9rZW5fdHlwZSI6IkJlYXJlciIsImF1dGhHcmFudElkIjoiN2ZiZTM3ZWEtZTc4Ni00ZTM1LWE3MzgtNThkMjRkOGZiNzlhIiwiYXVkIjoiaG1jdHMiLCJuYmYiOjE1NjE3MzQ0NjQsImdyYW50X3R5cGUiOiJwYXNzd29yZCIsInNjb3BlIjpbImFjciIsIm9wZW5pZCIsInByb2ZpbGUiLCJyb2xlcyIsImF1dGhvcml0aWVzIl0sImF1dGhfdGltZSI6MTU2MTczNDQ2NCwicmVhbG0iOiIvaG1jdHMiLCJleHAiOjE1NjE3NjMyNjQsImlhdCI6MTU2MTczNDQ2NCwiZXhwaXJlc19pbiI6Mjg4MDAsImp0aSI6ImRiNWI1ZTBlLWE1ODEtNGMwYi1iOGI1LTQxNGZmY2E3MWQzMyJ9.kZj0Y8h18MWde171myuGIPphijX9j2L2yhCUC75L3D-9fi11So-nlEOelh9-3jtolr9k--du9jzOREFy7KplsjLId6_yShd1CaafHz6DGvUBViO1vuoy6lp39R2iYfm5PEniLRDVVCySRkclLFtFaSQ3Ln28jo53BcLfTBXtH5gA_ydpgBaU6t66TZjWr_eu_mdSiFqdwWRFWsNJJiKQenZUXqcJiY9H1US6vx4RT3678HicZXNOCzg0_YIjtmZuMc3-akD6RLySch4qRy_ARWVjUzA_gAtz5R-R5MU6tGHJZpw_-leC4qwfVpTfEk2uTLOpLUSih6zYprzkkWyTJg"
    end

    def validate_service_token(token)
      service_token == token
    end

    def validate_user_token(token)
      user_token == token
    end

    private

    attr_writer :service_token, :user_token
  end
end
