# frozen_string_literal: true

require "base64"
require "shopify_cli"
require "net/http"
require "uri"
require "json"
require "fileutils"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptService
        include SmartProperties

        DEPLOY_FAILED_MSG = "Deploy failed with status %{status} and message %{msg}"
        SCHEMA_FETCH_FAILED = "Failed to fetch schemas with status %{status} and message %{msg}"
        private_constant :DEPLOY_FAILED_MSG, :SCHEMA_FETCH_FAILED

        property! :ctx, accepts: ShopifyCli::Context

        def fetch_extension_points
          query = Helpers::PartnersAPI.load_query(ctx, "get_extension_points")
          proxy_request(query: query, api_key: nil)
        end

        def deploy(
          extension_point_type:,
          schema:,
          script_name:,
          script_content:,
          compiled_type:,
          api_key: nil
        )
          query = Helpers::PartnersAPI.load_query(ctx, "app_script_update_or_create")
          variables = {
            extensionPointName: extension_point_type.upcase,
            title: script_name,
            sourceCode: Base64.encode64(script_content),
            language: compiled_type,
            schema: schema,
          }
          resp_hash = proxy_request(query: query, api_key: api_key, variables: variables.to_json)

          unless resp_hash["data"]["appScriptUpdateOrCreate"]["userErrors"].empty?
            raise(ShopifyCli::Abort, resp_hash["data"]["appScriptUpdateOrCreate"]["userErrors"].to_s)
          end
          resp_hash
        end

        private

        def proxy_request(variables)
          resp = Helpers::PartnersAPI.query(ctx, "script_service_proxy", **variables)
          resp_hash = JSON.parse(resp["data"]["scriptServiceProxy"])

          if resp_hash.key?("errors")
            raise(ShopifyCli::Abort, resp_hash["errors"].to_s)
          end
          resp_hash
        end
      end
    end
  end
end
