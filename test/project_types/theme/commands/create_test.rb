# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::FakeUI

      CONFIG_FILE = Regexp.new <<~CONFIG
        development:
         password: boop
         themeid:  "[\d]+"
         store: shop.myshopify.com 
      CONFIG

      SHOPIFYCLI_FILE = <<~CLI
        ---
        project_type: theme
        organization_id: 0
      CLI

      def test_can_create_new_theme
        FakeFS do
          context = ShopifyCli::Context.new
          Themekit.expects(:ensure_themekit_installed).with(context)
          Theme::Forms::Create.expects(:ask)
            .with(context, [], {})
            .returns(Theme::Forms::Create.new(context, [], { password: 'boop',
                                                             store: 'shop.myshopify.com',
                                                             title: 'My Theme',
                                                             name: 'my_theme',
                                                             env: nil }))
          Themekit.expects(:create)
            .with(context, password: 'boop', store: 'shop.myshopify.com', name: 'my_theme', env: nil)
            .returns(true)
          context.expects(:done).with(context.message('theme.create.info.created',
                                                      'my_theme',
                                                      'shop.myshopify.com',
                                                      File.join(context.root, 'my_theme')))

          Theme::Commands::Create.new(context).call([], 'create')
          assert_equal SHOPIFYCLI_FILE, File.read(".shopify-cli.yml")
        end
      end

      def test_can_specify_env
        FakeFS do
          context = ShopifyCli::Context.new
          Themekit.expects(:ensure_themekit_installed).with(context)
          Theme::Forms::Create.expects(:ask)
            .with(context, [], { env: 'development' })
            .returns(Theme::Forms::Create.new(context, [], { password: 'boop',
                                                             store: 'shop.myshopify.com',
                                                             title: 'My Theme',
                                                             name: 'my_theme',
                                                             env: 'development' }))
          Themekit.expects(:create)
            .with(context, password: 'boop', store: 'shop.myshopify.com', name: 'my_theme', env: 'development')
            .returns(true)
          context.expects(:done).with(context.message('theme.create.info.created',
                                                      'my_theme',
                                                      'shop.myshopify.com',
                                                      File.join(context.root, 'my_theme')))

          command = Theme::Commands::Create.new(context)
          command.options.flags[:env] = 'development'
          command.call([], 'create')

          assert_equal CONFIG_FILE, File.read("config.yml") # TODO: CAN'T FIND FILE
          assert_equal SHOPIFYCLI_FILE, File.read(".shopify-cli.yml")
        end
      end
    end
  end
end
