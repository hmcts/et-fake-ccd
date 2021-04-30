require 'roda'
require 'json'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/auth_service'
require 'et_fake_ccd/document_store_service'
require 'active_support/core_ext/hash'
module EtFakeCcd
  module Service
    class DocumentStoreApp < Roda
      plugin :request_headers
      plugin :halt
      plugin :sinatra_helpers
      route do |r|
        r.is "documents" do
          r.post do
            with_forced_error_handling(r, stage: :documents) do
              unless EtFakeCcd::AuthService.validate_service_token(r.headers['ServiceAuthorization'].gsub(/\ABearer /, '')) && EtFakeCcd::AuthService.validate_user_token(r.headers['Authorization'].gsub(/\ABearer /, ''))
                r.halt 403, forbidden_error_for(r)
                break
              end
              command = ::EtFakeCcd::Command::UploadDocumentCommand.from_json(r.params.deep_stringify_keys)
              unless command.valid?
                r.halt 422, render_error_for(command, r)
                break
              end

              upload_document(r)
            end
          end
        end
        r.is "documents", String, "binary" do |uuid|
          with_forced_error_handling(r, stage: :documents) do
            r.get do
              file = ::EtFakeCcd::DocumentStoreService.find_file_by_id(uuid)
              unless file
                r.halt 404, not_found_error_for(r)
                break
              end
              send_file file.path
            end
          end
        end
      end

      private

      def upload_document(request)
        file = request.params['files']
        id = ::EtFakeCcd::DocumentStoreService.store_file filename: file[:filename], type: file[:type], file: file[:tempfile], classification: request.params['classification']
        document = ::EtFakeCcd::DocumentStoreService.find_by_id(id)
        render_document id: id, document: document, documents_root: request.url
      end

      def render_document(id:, document:, documents_root:)
        now = Time.now.strftime("%Y-%m-%dT%H:%M:%S%z")
        j = {
          "_embedded": {
            "documents": [
              {
                "size": document['size'],
                "mimeType": document['type'],
                "originalDocumentName": document['filename'],
                "createdBy": "42f46280-24b4-4f4d-b93c-8c92cbb2b93f",
                "lastModifiedBy": "42f46280-24b4-4f4d-b93c-8c92cbb2b93f",
                "modifiedOn": now,
                "createdOn": now,
                "classification": document['classification'],
                "_links": {
                  "self": {
                    "href": "#{documents_root}/#{id}"
                  },
                  "binary": {
                    "href": "#{documents_root}/#{id}/binary"
                  },
                  "thumbnail": {
                    "href": "#{documents_root}/#{id}/thumbnail"
                  }
                },
                "_embedded": {
                  "allDocumentVersions": {
                    "_embedded": {
                      "documentVersions": [
                        {
                          "size": document['size'],
                          "mimeType": document['type'],
                          "originalDocumentName": document['filename'],
                          "createdBy": "42f46280-24b4-4f4d-b93c-8c92cbb2b93f",
                          "createdOn": now,
                          "_links": {
                            "document": {
                              "href": "#{documents_root}/#{id}"
                            },
                            "self": {
                              "href": "#{documents_root}/#{id}/versions/ac711770-6681-4fd8-b662-f7f54ea7a27d"
                            },
                            "binary": {
                              "href": "#{documents_root}/#{id}/versions/ac711770-6681-4fd8-b662-f7f54ea7a27d/binary"
                            },
                            "thumbnail": {
                              "href": "#{documents_root}/#{id}/versions/ac711770-6681-4fd8-b662-f7f54ea7a27d/thumbnail"
                            },
                            "migrate": {
                              "href": "#{documents_root}/#{id}/versions/ac711770-6681-4fd8-b662-f7f54ea7a27d/migrate"
                            }
                          }
                        }
                      ]
                    }
                  }
                }
              }
            ]
          }
        }
        JSON.generate(j)
      end

      def render_error_for(command, request)
        j = {
          "exception": "uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException",
          "timestamp": "2019-07-01T16:02:28.045",
          "status": 422,
          "error": "Unprocessable Entity",
          "message": "Document validation failed",
          "path": request.path,
          "details": {
            "field_errors": command.errors.details[:data].map {|e| e[:field_error]}
          },
          "callbackErrors": nil,
          "callbackWarnings": nil
        }

        JSON.generate(j)
      end

      def forbidden_error_for(r)
        j = {"timestamp":"2019-07-01T07:46:35.405+0000","status":403,"error":"Forbidden","message":"Access Denied","path": r.path}
        JSON.generate(j)
      end

      def not_found_error_for(r)
        j = {"timestamp":"2019-07-01T07:46:35.405+0000","status":404,"error":"Not Found","message":"Not Found","path": r.path}
        JSON.generate(j)
      end
    end
  end
end
