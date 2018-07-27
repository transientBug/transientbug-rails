RSpec.describe QueryGrammar::Parser do
  describe "rule: clause" do
    subject { super().clause.parse input }

    context "when " do
    end
  end

  describe "rule: negator" do
    subject { super().negator.parse input }

    context "when no space" do
      let(:input) { "NOT" }

      it { expect { subject }.to raise_exception(Parslet::ParseFailed) }
    end

    context "when one space" do
      let(:input) { "NOT " }

      it { is_expected.to be_a(Hash) }
      it { is_expected.to include(negator: a_kind_of(Parslet::Slice)) }
    end

    context "when lots of space" do
      let(:input) { "NOT     " }

      it { is_expected.to be_a(Hash) }
      it { is_expected.to include(negator: a_kind_of(Parslet::Slice)) }
    end
  end

  describe "rule: term_list" do
    subject { super().term_list.parse input }

    context "when " do
    end
  end

  describe "rule: term" do
    subject { super().term.parse input }

    context "when " do
    end
  end

  describe "rule: phrase" do
    subject { super().phrase.parse input }

    context "when " do
    end
  end

  describe "rule: word" do
    subject { super().word.parse input }

    context "when character" do
      let(:input) { "a" }

      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "when CHARACTER" do
      let(:input) { "A" }

      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "when digit" do
      let(:input) { "1" }

      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "when word" do
      let(:input) { "asdf" }

      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "when word and digit" do
      let(:input) { "asdf1234" }

      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "when word with good symbols" do
      let(:input) { "asdf-asf_sdaf+ad=dfs" }

      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "when word with bad symbols" do
      let(:input) { "asdf)" }

      it { expect { subject }.to raise_exception(Parslet::ParseFailed) }
    end

    context "when word with spaces" do
      let(:input) { "asdf adfasdf" }

      it { expect { subject }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe "rule: space?" do
    subject { super().space?.parse input }

    context "when one space input" do
      let(:input) { " " }

      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "when multi space input" do
      let(:input) { "   " }

      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "when empty input" do
      let(:input) { "" }

      it { is_expected.to eq(input) }
    end
  end

  describe "rule: space" do
    subject { super().space.parse input }

    context "when one space input" do
      let(:input) { " " }

      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "when multi space input" do
      let(:input) { "   " }

      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "when empty input" do
      let(:input) { "" }

      it { expect { subject }.to raise_exception(Parslet::ParseFailed) }
    end
  end
end
