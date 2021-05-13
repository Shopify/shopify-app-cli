# frozen_string_literal: true
require "base64"

module Extension
  module Models
    module SpecificationHandlers
      class CheckoutPostPurchase < Default
        PERMITTED_CONFIG_KEYS = [:metafields]
        CLI_PACKAGE_NAME = "@shopify/argo-run"

        def config(context)
          {
            **Features::ArgoConfig.parse_yaml(context, PERMITTED_CONFIG_KEYS),
            **argo.config(context),
          }
        end

        def serve(context:, port:, tunnel_url:)
          Features::ArgoServe.new(specification_handler: self, cli_compatibility: cli_compatibility(context),
          context: context, port: port, tunnel_url: tunnel_url).call
        end

        def cli_compatibility(context)
          @cli_compatibility ||= Features::ArgoCliCompatibility.new(renderer_package: renderer_package(context),
          installed_cli_package: installed_cli_package(context))
        end

        def installed_cli_package(context)
          js_system = ShopifyCli::JsSystem.new(ctx: context)
          Tasks::FindNpmPackages.exactly_one_of(CLI_PACKAGE_NAME, js_system: js_system)
            .unwrap { |_e| context.abort(context.message("errors.package_not_found", CLI_PACKAGE_NAME)) }
        end
      end
    end
  end
end
