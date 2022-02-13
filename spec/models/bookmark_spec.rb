# frozen_string_literal: true

RSpec.describe Bookmark do
  describe "bookmark associations" do
    it "has many tags" do
      assc = described_class.reflect_on_association(:tags)
      expect(assc.macro).to eq :has_many
    end
  end

  describe "#to_adddressable" do
    subject { instance.to_addressable }

    let(:instance) { described_class.create uri: }

    context "when setting an addressable uri" do
      let(:uri_string) { "http://test.me" }
      let(:uri) { Addressable::URI.parse(uri_string) }

      it { is_expected.to be_an(Addressable::URI) }
      it { is_expected.to eq(uri) }
    end

    context "when setting a string converts it" do
      let(:uri) { "http://test.me" }
      let(:uri_obj) { Addressable::URI.parse(uri) }

      it { is_expected.to be_an(Addressable::URI) }
      it { is_expected.to eq(uri_obj) }
    end

    context "when setting a string with a fragment removes fragment from save" do
      let(:uri) { "http://test.me#test" }
      let(:uri_obj) { Addressable::URI.parse(uri) }

      it { is_expected.to be_an(Addressable::URI) }
      it { is_expected.to eq(uri_obj.omit(:fragment)) }
    end
  end
end
