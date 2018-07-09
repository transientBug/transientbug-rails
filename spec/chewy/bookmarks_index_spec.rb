RSpec.describe BookmarksIndex, type: :chewy do
  describe ".build_host_iterations" do
    subject { described_class.build_host_iterations bookmark }

    let(:webpage) { create :webpage, uri: Addressable::URI.parse(uri) }
    let(:bookmark) { create :bookmark, webpage: webpage }

    context "with a normal uri" do
      let(:uri) { "http://7.test.com" }
      let(:expected) { ["7.test.com", "test.com", "com" ] }

      it { is_expected.to be_an(Array) }
      it { is_expected.to eq(expected) }
    end

    context "with no host" do
      let(:uri) do
        "about:reader?url=https%3A%2F%2Fnymag.com%2Fdaily%2Fintelligencer%2F2018%2F02%2Famericas-opioid-epidemic.html"
      end

      let(:expected) { [] }

      it { is_expected.to be_an(Array) }
      it { is_expected.to eq(expected) }
    end
  end

  describe ".build_bookmark_suggest" do
    subject { described_class.build_bookmark_suggest bookmark }

    let(:bookmark) { create :bookmark }

    context "with a normal" do
      it { is_expected.to be_a(Hash) }
      it { is_expected.to include(input: a_kind_of(Array), contexts: a_kind_of(Hash)) }
    end
  end

  describe ".build_tag_suggest" do
    subject { described_class.build_tag_suggest tag }

    let(:tag) { create :tag }

    context "with a normal" do
      it { is_expected.to be_a(Hash) }
      it { is_expected.to include(input: a_kind_of(String), contexts: a_kind_of(Hash)) }
    end
  end
end
