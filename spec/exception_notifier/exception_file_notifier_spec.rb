require "spec_helper"

RSpec.describe ExceptionNotifier::ExceptionFileNotifier do
  it "has a version number" do
    expect(ExceptionNotifier::ExceptionFileNotifier::VERSION).not_to be nil
  end
end
