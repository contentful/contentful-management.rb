require 'spec_helper'

class MockRequest
  def endpoint; end
end

describe Contentful::Management::Error do
  let(:r) { Contentful::Management::Response.new raw_fixture('not_found', 404), MockRequest.new }

  describe '#response' do
    it 'returns the response the error has been initialized with' do
      expect(Contentful::Management::Error.new(r).response).to be r
    end
  end

  describe '#message' do
    it 'returns the message found in the response json' do
      message = "HTTP status code: 404\n"\
                "Message: The resource could not be found.\n"\
                "Details: {\"type\"=>\"Entry\", \"space\"=>\"cfexampleapi\", \"id\"=>\"not found\"}\n"\
                "Request ID: 85f-351076632"
      expect(Contentful::Management::Error.new(r).message).not_to be_nil
      expect(Contentful::Management::Error.new(r).message).to eq message
    end

    describe 'message types' do
      describe 'default messages' do
        it '400' do
          response = Contentful::Management::Response.new raw_fixture('default_400', 400), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 400\n"\
                    "Message: The request was malformed or missing a required parameter.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '401' do
          response = Contentful::Management::Response.new raw_fixture('default_401', 401), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 401\n"\
                    "Message: The authorization token was invalid.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '403' do
          response = Contentful::Management::Response.new raw_fixture('default_403', 403), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 403\n"\
                    "Message: The specified token does not have access to the requested resource.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '404' do
          response = Contentful::Management::Response.new raw_fixture('default_404', 404), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 404\n"\
                    "Message: The requested resource or endpoint could not be found.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '409' do
          response = Contentful::Management::Response.new raw_fixture('default_409', 409), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 409\n"\
                    "Message: Version mismatch error. The version you specified was incorrect. This may be due to someone else editing the content.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '422' do
          response = Contentful::Management::Response.new raw_fixture('default_422', 422), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 422\n"\
                    "Message: The resource you sent in the body is invalid.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '429' do
          response = Contentful::Management::Response.new raw_fixture('default_429', 429), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 429\n"\
                    "Message: Rate limit exceeded. Too many requests.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '500' do
          response = Contentful::Management::Response.new raw_fixture('default_500', 500), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 500\n"\
                    "Message: Internal server error.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '502' do
          response = Contentful::Management::Response.new raw_fixture('default_502', 502), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 502\n"\
                    "Message: The requested space is hibernated.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '503' do
          response = Contentful::Management::Response.new raw_fixture('default_503', 503), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 503\n"\
                    "Message: Service unavailable.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end
      end

      describe 'special cases' do
        describe '400' do
          it 'details is a string' do
            response = Contentful::Management::Response.new raw_fixture('400_details_string', 400), MockRequest.new
            error = Contentful::Management::Error[response.raw.status].new(response)

            message = "HTTP status code: 400\n"\
                      "Message: The request was malformed or missing a required parameter.\n"\
                      "Details: some error\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end

          it 'details is an object, internal errors are strings' do
            response = Contentful::Management::Response.new raw_fixture('400_details_errors_string', 400), MockRequest.new
            error = Contentful::Management::Error[response.raw.status].new(response)

            message = "HTTP status code: 400\n"\
                      "Message: The request was malformed or missing a required parameter.\n"\
                      "Details: some error\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end

          it 'details is an object, internal errors are objects which have details' do
            response = Contentful::Management::Response.new raw_fixture('400_details_errors_object', 400), MockRequest.new
            error = Contentful::Management::Error[response.raw.status].new(response)

            message = "HTTP status code: 400\n"\
                      "Message: The request was malformed or missing a required parameter.\n"\
                      "Details: some error\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end
        end

        describe '403' do
          it 'has an array of reasons' do
            response = Contentful::Management::Response.new raw_fixture('403_reasons', 403), MockRequest.new
            error = Contentful::Management::Error[response.raw.status].new(response)

            message = "HTTP status code: 403\n"\
                      "Message: The specified token does not have access to the requested resource.\n"\
                      "Details: \n\tReasons:\n"\
                      "\t\tfoo\n"\
                      "\t\tbar\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end
        end

        describe '404' do
          it 'details is a string' do
            response = Contentful::Management::Response.new raw_fixture('404_details_string', 404), MockRequest.new
            error = Contentful::Management::Error[response.raw.status].new(response)

            message = "HTTP status code: 404\n"\
                      "Message: The requested resource or endpoint could not be found.\n"\
                      "Details: The resource could not be found\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end

          it 'has a type' do
            response = Contentful::Management::Response.new raw_fixture('404_type', 404), MockRequest.new
            error = Contentful::Management::Error[response.raw.status].new(response)

            message = "HTTP status code: 404\n"\
                      "Message: The requested resource or endpoint could not be found.\n"\
                      "Details: The requested Asset could not be found.\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end

          it 'can specify the resource id' do
            response = Contentful::Management::Response.new raw_fixture('404_id', 404), MockRequest.new
            error = Contentful::Management::Error[response.raw.status].new(response)

            message = "HTTP status code: 404\n"\
                      "Message: The requested resource or endpoint could not be found.\n"\
                      "Details: The requested Asset could not be found. ID: foobar.\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end
        end

        describe '422' do
          it 'can show formatted details' do
            response = Contentful::Management::Response.new raw_fixture('422_details', 422), MockRequest.new
            error = Contentful::Management::Error[response.raw.status].new(response)

            message = "HTTP status code: 422\n"\
                      "Message: The resource you sent in the body is invalid.\n"\
                      "Details: \n"\
                      "\t* Name: taken - Path: 'display_code' - Value: 'en-US'\n"\
                      "\t* Name: fallback locale creates a loop - Path: 'fallback_code' - Value: 'en-US'\n"\
                      "Request ID: 044bb23356babe4f11a3f7f1e77c762a"
            expect(error.message).to eq message
          end
        end

        describe '429' do
          it 'can show the time until reset' do
            response = Contentful::Management::Response.new raw_fixture('default_429', 429, false, {'x-contentful-ratelimit-reset' => 60}), MockRequest.new
            error = Contentful::Management::Error[response.raw.status].new(response)

            message = "HTTP status code: 429\n"\
                      "Message: Rate limit exceeded. Too many requests.\n"\
                      "Request ID: 85f-351076632\n"\
                      "Time until reset (seconds): 60"
            expect(error.message).to eq message
          end
        end
      end

      describe 'generic error' do
        it 'with everything' do
          response = Contentful::Management::Response.new raw_fixture('other_error', 512), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 512\n"\
                    "Message: Some error occurred.\n"\
                    "Details: some text\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it 'no details' do
          response = Contentful::Management::Response.new raw_fixture('other_error_no_details', 512), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 512\n"\
                    "Message: Some error occurred.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it 'no request id' do
          response = Contentful::Management::Response.new raw_fixture('other_error_no_request_id', 512), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 512\n"\
                    "Message: Some error occurred.\n"\
                    "Details: some text"
          expect(error.message).to eq message
        end

        it 'no message' do
          response = Contentful::Management::Response.new raw_fixture('other_error_no_message', 512), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 512\n"\
                    "Message: The following error was received: {\n"\
                    "  \"sys\": {\n"\
                    "    \"type\": \"Error\",\n"\
                    "    \"id\": \"SomeError\"\n"\
                    "  },\n"\
                    "  \"details\": \"some text\",\n"\
                    "  \"requestId\": \"85f-351076632\"\n"\
                    "}\n"\
                    "\n"\
                    "Details: some text\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it 'nothing' do
          response = Contentful::Management::Response.new raw_fixture('other_error_nothing', 512), MockRequest.new
          error = Contentful::Management::Error[response.raw.status].new(response)

          message = "HTTP status code: 512\n"\
                    "Message: The following error was received: {\n"\
                    "  \"sys\": {\n"\
                    "    \"type\": \"Error\",\n"\
                    "    \"id\": \"SomeError\"\n"\
                    "  }\n"\
                    "}\n"
          expect(error.message).to eq message
        end
      end
    end
  end

  describe Contentful::Management::UnparsableJson do
    describe '#message' do
      it 'returns the json parser\'s message' do
        uj = Contentful::Management::Response.new raw_fixture('unparsable'), MockRequest.new
        expect(Contentful::Management::UnparsableJson.new(uj).message).to \
            include 'unexpected token'
      end
    end
  end

  describe '.[]' do
    it 'returns BadRequest error class for 400' do
      expect(Contentful::Management::Error[400]).to eq Contentful::Management::BadRequest
    end

    it 'returns Unauthorized error class for 401' do
      expect(Contentful::Management::Error[401]).to eq Contentful::Management::Unauthorized
    end

    it 'returns AccessDenied error class for 403' do
      expect(Contentful::Management::Error[403]).to eq Contentful::Management::AccessDenied
    end

    it 'returns NotFound error class for 404' do
      expect(Contentful::Management::Error[404]).to eq Contentful::Management::NotFound
    end

    it 'returns Conflict error class for 409' do
      expect(Contentful::Management::Error[409]).to eq Contentful::Management::Conflict
    end

    it 'returns UnprocessableEntity error class for 422' do
      expect(Contentful::Management::Error[422]).to eq Contentful::Management::UnprocessableEntity
    end

    it 'returns RateLimitExceeded error class for 429' do
      expect(Contentful::Management::Error[429]).to eq Contentful::Management::RateLimitExceeded
    end

    it 'returns ServerError error class for 500' do
      expect(Contentful::Management::Error[500]).to eq Contentful::Management::ServerError
    end

    it 'returns BadGateway error class for 502' do
      expect(Contentful::Management::Error[502]).to eq Contentful::Management::BadGateway
    end

    it 'returns ServiceUnavailable error class for 503' do
      expect(Contentful::Management::Error[503]).to eq Contentful::Management::ServiceUnavailable
    end

    it 'returns generic error class for any other value' do
      expect(Contentful::Management::Error[nil]).to eq Contentful::Management::Error
      expect(Contentful::Management::Error[200]).to eq Contentful::Management::Error
    end
  end
end

