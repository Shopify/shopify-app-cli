require "shopify_cli"

module Script
  module Tasks
    class EnsureEnv < ShopifyCli::Task
      attr_accessor :ctx

      def call(ctx)
        self.ctx = ctx

        script_project_repo = Layers::Infrastructure::ScriptProjectRepository.new(ctx: ctx)
        script_project = script_project_repo.get

        return if script_project.api_key && script_project.api_secret && script_project.uuid_defined?

        org = ask_org
        app = ask_app(org["apps"])
        uuid = ask_script_uuid(app, script_project.extension_point_type)

        script_project_repo.create_env(
          api_key: app["apiKey"],
          secret: app["apiSecretKeys"].first["secret"],
          uuid: uuid
        )
      end

      private

      def ask_org
        if ShopifyCli::Shopifolk.check && wants_to_run_against_shopify_org?
          ShopifyCli::Shopifolk.act_as_shopify_organization
        end

        orgs = ShopifyCli::PartnersAPI::Organizations.fetch_with_app(ctx)
        if orgs.count == 1
          orgs.first
        elsif orgs.count > 0
          CLI::UI::Prompt.ask(ctx.message("script.application.ensure_env.organization_select")) do |handler|
            orgs.each do |org|
              handler.option("#{org["businessName"]} (#{org["id"]})") { org }
            end
          end
        else
          raise Errors::NoExistingOrganizationsError
        end
      end

      def ask_app(apps)
        apps = apps.select { |app| app["appType"] == "custom" } unless ShopifyCli::Shopifolk.acting_as_shopify_organization?

        if apps.count == 1
          apps.first
        elsif apps.count > 0
          CLI::UI::Prompt.ask(ctx.message("script.application.ensure_env.app_select")) do |handler|
            apps.each do |app|
              handler.option(app["title"]) { app }
            end
          end
        else
          raise Errors::NoExistingAppsError
        end
      end

      def ask_script_uuid(app, extension_point_type)
        script_service = Layers::Infrastructure::ScriptService.new(ctx: ctx)
        scripts = script_service.get_app_scripts(api_key: app["apiKey"], extension_point_type: extension_point_type)

        return nil unless scripts.count > 0 &&
          CLI::UI::Prompt.confirm(ctx.message("script.application.ensure_env.ask_connect_to_existing_script"))

        CLI::UI::Prompt.ask(ctx.message("script.application.ensure_env.ask_which_script_to_connect_to")) do |handler|
          scripts.each do |script|
            handler.option("#{script["title"]} (#{script["uuid"]})") { script["uuid"] }
          end
        end
      end
    end
  end
end
