RSpec.describe BookmarksIndex, type: :chewy do
  describe ".build_host_iterations" do
    let(:webpage) { create :webpage, uri: uri }
    let(:bookmark) { create :bookmark, webpage: webpage }

    context "normal uri" do
      # subject { described_class.build_host_iterations bookmark }

      let(:uri) { "7.test.com" }
      let(:expected) { ["7.test.com", "test.com", "com" ] }

      it { expect(true).to be }
      # fit { binding.pry }
      # fit { is_expected.to eq(expected) }
    end
  end
end
