# frozen_string_literal: true

require 'project_types/script/test_helper'

describe Script::Layers::Infrastructure::TaskRunner do
  describe "build" do
    subject { Script::Layers::Infrastructure::TaskRunner.for(@context, language) }

    describe "when the script language and compile type match an entry in the registry" do
      let(:language) { "ts" }

      it "should return the entry from the registry" do
        Script::Layers::Infrastructure::AssemblyScriptTaskRunner.expects(:new).with(@context)
        subject
      end
    end

    describe "when the script language and compile type doesn't match an entry in the registry" do
      let(:language) { "imaginary" }

      it "should raise a builder not found error" do
        assert_raises(Script::Layers::Infrastructure::Errors::TaskRunnerNotFoundError) { subject }
      end
    end
  end
end