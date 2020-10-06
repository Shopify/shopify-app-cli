require 'test_helper'

module ShopifyCli
  class ShopifolkTest < MiniTest::Test
    GCLOUD_FEATURE_NAME = 'gcloud_shopifolk'
    DEV_FEATURE_NAME = 'dev_shopifolk'

    def test_correct_features_is_shopifolk
      ShopifyCli::Feature.disable(GCLOUD_FEATURE_NAME.to_s)
      ShopifyCli::Feature.disable(DEV_FEATURE_NAME.to_s)
      ShopifyCli::Shopifolk.check
      assert ShopifyCli::Config.get_bool(Feature::SECTION, GCLOUD_FEATURE_NAME.to_s)
      assert ShopifyCli::Config.get_bool(Feature::SECTION, DEV_FEATURE_NAME.to_s)
    end

    def test_correct_gcloud_enables_gcloud_shopifolk_feature
      path = '../shopifolk_correct.conf'
      ShopifyCli::Feature.disable(GCLOUD_FEATURE_NAME.to_s)
      ShopifyCli::Shopifolk.new.shopifolk?(path)
      assert ShopifyCli::Config.get_bool(Feature::SECTION, GCLOUD_FEATURE_NAME.to_s)
    end

    def test_incorrect_gcloud_disables_shopifolk_feature
      ShopifyCli::Feature.enable(GCLOUD_FEATURE_NAME.to_s)
      path_no_core = '../shopifolk_incorrect_no_core.conf'
      ShopifyCli::Shopifolk.new.shopifolk?(path_no_core)
      refute ShopifyCli::Config.get_bool(Feature::SECTION, GCLOUD_FEATURE_NAME.to_s)

      ShopifyCli::Feature.enable(GCLOUD_FEATURE_NAME.to_s)
      path_no_account = '../shopifolk_incorrect_no_account.conf'
      ShopifyCli::Shopifolk.new.shopifolk?(path_no_account)
      refute ShopifyCli::Config.get_bool(Feature::SECTION, GCLOUD_FEATURE_NAME.to_s)

      ShopifyCli::Feature.enable(GCLOUD_FEATURE_NAME.to_s)
      path_no_email = '../shopifolk_incorrect_no_email.conf'
      ShopifyCli::Shopifolk.new.shopifolk?(path_no_email)
      refute ShopifyCli::Config.get_bool(Feature::SECTION, GCLOUD_FEATURE_NAME.to_s)
    end

    def test_correct_dev_path_enables_dev_shopifolk_feature
      ShopifyCli::Feature.disable(DEV_FEATURE_NAME.to_s)
      ShopifyCli::Shopifolk.new.shopifolk?
      assert ShopifyCli::Config.get_bool(Feature::SECTION, DEV_FEATURE_NAME.to_s)
    end

    def test_incorrect_dev_path_disables_dev_shopifolk_feature
      fake_path = "/fakepath"
      ShopifyCli::Feature.enable(DEV_FEATURE_NAME.to_s)
      ShopifyCli::Shopifolk.new.shopifolk?(fake_path, fake_path)
      refute ShopifyCli::Config.get_bool(Feature::SECTION, DEV_FEATURE_NAME.to_s)
    end
  end
end
