RSpec.describe Webpage do
  describe "bookmark associations" do
    it "has many bookmarks" do
      assc = described_class.reflect_on_association(:bookmarks)
      expect(assc.macro).to eq :has_many
    end
  end

  describe "validations" do
    describe "uri_string" do
      subject { described_class.new uri_string: uri_string }

      let(:uri_string) { "http://test.me" }

      context "valid" do
        it { is_expected.to be_valid }
      end

      context "invalid duplicate" do
        before do
          described_class.create uri_string: uri_string
        end

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe "#uri" do
    subject { instance.uri }

    let(:instance) { described_class.new }

    context "setting a uri" do
      let(:uri_string) { "http://test.me" }
      let(:uri) { Addressable::URI.parse(uri_string) }

      before do
        instance.uri = uri
      end

      it { is_expected.to be_an(Addressable::URI) }
      it { is_expected.to eq(uri) }
    end

    context "setting a string converts it" do
      let(:uri_string) { "http://test.me" }
      let(:uri) { Addressable::URI.parse(uri_string) }

      before do
        instance.uri = uri_string
      end

      it { is_expected.to be_an(Addressable::URI) }
      it { is_expected.to eq(uri) }
    end

    context "setting a string with a fragment removes fragment from save" do
      subject { instance.uri_string }

      let(:uri_string) { "http://test.me#test" }
      let(:uri) { Addressable::URI.parse(uri_string) }

      before do
        instance.uri = uri_string
        instance.valid?
      end

      it { is_expected.to be_a(String) }
      it { is_expected.to eq(uri.omit(:fragment).to_s) }
    end

    context "getting the uri" do
      let(:instance) { described_class.new uri_string: uri_string }
      let(:uri_string) { "http://test.me" }
      let(:uri) { Addressable::URI.parse(uri_string) }

      it { is_expected.to be_an(Addressable::URI) }
      it { is_expected.to eq(uri) }
    end
  end
end
