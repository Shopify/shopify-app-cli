require 'shopify_cli'

module ShopifyCli
  module Tasks
    class TaskRegistry
      def initialize
        @tasks = {}
      end

      def add(const, name)
        @tasks[name] = const
      end

      def [](name)
        @tasks[name]
      end
    end

    Registry = TaskRegistry.new

    def self.register(task, name, path)
      autoload(task, path)
      Registry.add(const_get(task), name)
    end

    register :AuthenticateIdentity, :authenticate_identity, 'shopify-cli/tasks/authenticate_identity'
    register :AuthenticateShopify, :authenticate_shopify, 'shopify-cli/tasks/authenticate_shopify'
    register :Clone, :clone, 'shopify-cli/tasks/clone'
    register :EnsureEnv, :ensure_env, 'shopify-cli/tasks/ensure_env'
    register :GetOrgs, :get_orgs, 'shopify-cli/tasks/partner_queries/get_orgs'
    register :JsDeps, :js_deps, 'shopify-cli/tasks/js_deps'
    register :Schema, :schema, 'shopify-cli/tasks/schema'
    register :Tunnel, :tunnel, 'shopify-cli/tasks/tunnel'
  end
end
