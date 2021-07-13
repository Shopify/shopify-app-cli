# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module Converters
      module ProductConverter
        VARIANT_PATH = [:data, :products, :edges, 0, :node, :variants, :edges, 0, :node, :id]

        def self.from_hash(hash)
          return nil if hash.nil?

          hash.dig(*VARIANT_PATH).then do |variant|
            return nil if variant.nil?

            Models::Product.new(
              variant_id: variant.split("/").last
            )
          end
        end
      end
    end
  end
end
