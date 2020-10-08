module ShopifyCli
  ##
  # ShopifyCli::Shopifolk contains the logic to determine if the user appears to be a Shopify staff
  #
  # The Shopifolk Feature flag will persist between runs so if the flag is enabled or disabled,
  # it will still be in that same state until the next class invocation.
  class Shopifolk
    GCLOUD_CONFIG_PATH = '~/.config/gcloud/configurations/config_default'
    DEV_PATH = '/opt/dev'
    SECTION = 'core'
    FEATURE_NAME = 'shopifolk'
    def self.check
      ##
      # will return if the user appears to be a Shopify employee, based on several heuristics
      #
      # #### Returns
      #
      # * `is_shopifolk` - returns true if the user is a Shopify Employee
      #
      # #### Example
      #
      #     ShopifyCli::Shopifolk.check
      #
      ShopifyCli::Shopifolk.new.shopifolk?
    end

    def shopifolk?(gcloud_config_path = GCLOUD_CONFIG_PATH, dev_path = DEV_PATH, debug = false)
      ##
      # will return if the user is a Shopify employee
      #
      # #### Returns
      #
      # * `is_shopifolk` - returns true if the user has `dev` installed and
      # a valid google cloud config file with email ending in "@shopify.com"
      #
      unless debug
        return true if Feature.enabled?(FEATURE_NAME)
      end
      @gcloud_config_path = gcloud_config_path
      @dev_path = dev_path
      if shopifolk_by_dev? && shopifolk_by_gcloud?
        ShopifyCli::Feature.enable(FEATURE_NAME)
        true
      else
        ShopifyCli::Feature.disable(FEATURE_NAME)
        false
      end
    end

    private

    def shopifolk_by_gcloud?
      gcloud_config = File.expand_path(@gcloud_config_path)
      if File.exist?(gcloud_config)
        gcloud_account = ini(gcloud_config).dig("[#{SECTION}]", 'account')
      end
      gcloud_account&.match?(/@shopify.com\z/)
    end

    def shopifolk_by_dev?
      File.exist?("#{@dev_path}/bin/dev") && File.exist?("#{@dev_path}/.shopify-build")
    end

    def ini(gcloud_config)
      @ini ||= CLI::Kit::Ini
        .new(gcloud_config, default_section: "[#{SECTION}]", convert_types: false)
        .tap(&:parse).ini
    end
  end
end