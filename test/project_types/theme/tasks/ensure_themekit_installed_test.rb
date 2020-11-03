# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Tasks
    class EnsureThemekitInstalledTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
      end

      def test_does_nothing_if_themekit_installed
        stat = mock
        @context.expects(:capture2e).with(Themekit::THEMEKIT).returns(['out', stat])
        stat.stubs(:success?).returns(true)

        assert_nothing_raised do
          EnsureThemekitInstalled.call(@context)
        end
      end

      def test_installs_and_makes_executable_if_not_installed
        stub_check_executable
        stub_releases
        stub_themekit_file_write

        Digest::MD5.expects(:file).with(Themekit::THEMEKIT).returns('boop')
        FileUtils.expects(:chmod).with('+x', Themekit::THEMEKIT)

        EnsureThemekitInstalled.call(@context)
      end

      def test_fails_if_bad_digest
        stub_check_executable
        stub_releases
        stub_themekit_file_write

        Digest::MD5.expects(:file).with(Themekit::THEMEKIT).returns('mlem')
        FileUtils.expects(:chmod).with('+x', Themekit::THEMEKIT).never
        File.expects(:exist?).with(Themekit::THEMEKIT).returns(true)
        FileUtils.expects(:rm).with(Themekit::THEMEKIT)

        assert_raises(ShopifyCli::Abort,
                      @context.message('theme.tasks.ensure_themekit_installed.errors.digest_fail')) do
          EnsureThemekitInstalled.call(@context)
        end
      end

      def test_fails_gracefully_if_network_errors
        stat = mock
        @context.expects(:capture2e).with(Themekit::THEMEKIT).returns(['out', stat])
        stat.stubs(:success?).returns(false)
        stub_request(:get, EnsureThemekitInstalled::URL).to_return(status: 504)

        @context.expects(:capture2e)
          .with('curl', '-o', Themekit::THEMEKIT, 'http://www.website.ca')
          .never
        Digest::MD5.expects(:file).with(Themekit::THEMEKIT).never
        FileUtils.expects(:chmod).with('+x', Themekit::THEMEKIT).never

        assert_raises(ShopifyCli::Abort,
                      @context.message('theme.tasks.ensure_themekit_installed.errors.releases_fail')) do
          EnsureThemekitInstalled.call(@context)
        end
      end

      def test_fails_if_bad_write
        stub_check_executable
        stub_releases

        stat = mock
        @context.expects(:capture2e)
          .with('curl', '-o', Themekit::THEMEKIT, 'http://www.website.ca')
          .returns(['out', stat])
        stat.stubs(:success?).returns(false)

        Digest::MD5.expects(:file).with(Themekit::THEMEKIT).never
        FileUtils.expects(:chmod).with('+x', Themekit::THEMEKIT).never
        File.expects(:exist?).with(Themekit::THEMEKIT).returns(true)
        FileUtils.expects(:rm).with(Themekit::THEMEKIT)

        assert_raises(ShopifyCli::Abort, @context.message('theme.tasks.ensure_themekit_installed.errors.write_fail')) do
          EnsureThemekitInstalled.call(@context)
        end
      end

      private

      def stub_check_executable
        stat = mock
        @context.expects(:capture2e).with(Themekit::THEMEKIT).returns(['out', stat])
        stat.stubs(:success?).returns(false)
      end

      def stub_releases
        stub_request(:get, EnsureThemekitInstalled::URL)
          .to_return(body: { "platforms": [
            {
              "name": 'darwin-amd64',
              "version": '123',
              "url": 'http://www.website.ca',
              "digest": 'boop',
            },
            {
              "name": 'linux-amd64',
              "version": '123',
              "url": 'http://www.website.ca',
              "digest": 'boop',
            },
            {
              "name": 'windows-amd64',
              "version": '123',
              "url": 'http://www.website.ca',
              "digest": 'boop',
            },
          ] }.to_json)
      end

      def stub_themekit_file_write
        stat = mock
        @context.expects(:capture2e)
          .with('curl', '-o', Themekit::THEMEKIT, 'http://www.website.ca')
          .returns(['out', stat])
        stat.stubs(:success?).returns(true)
      end
    end
  end
end