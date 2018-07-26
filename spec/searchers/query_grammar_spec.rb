RSpec.describe QueryGrammar::Parser do
  describe "rule: clause" do
    subject { super().clause.parse input }

    context "" do
    end
  end

  describe "rule: negator" do
    subject { super().negator.parse input }

    context "no space" do
      let(:input) { "NOT" }
      it { expect{ subject }.to raise_exception(Parslet::ParseFailed) }
    end

    context "one space" do
      let(:input) { "NOT " }
      it { is_expected.to be_a(Hash) }
      it { is_expected.to include(negator: a_kind_of(Parslet::Slice)) }
    end

    context "lots of space" do
      let(:input) { "NOT     " }
      it { is_expected.to be_a(Hash) }
      it { is_expected.to include(negator: a_kind_of(Parslet::Slice)) }
    end
  end

  describe "rule: term_list" do
    subject { super().term_list.parse input }

    context "" do
    end
  end

  describe "rule: term" do
    subject { super().term.parse input }

    context "" do
    end
  end

  describe "rule: phrase" do
    subject { super().phrase.parse input }

    context "" do
    end
  end

  describe "rule: word" do
    subject { super().word.parse input }

    context "character" do
      let(:input) { "a" }
      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "CHARACTER" do
      let(:input) { "A" }
      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "digit" do
      let(:input) { "1" }
      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "word" do
      let(:input) { "asdf" }
      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "word and digit" do
      let(:input) { "asdf1234" }
      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "word with good symbols" do
      let(:input) { "asdf-asf_sdaf+ad=dfs" }
      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "word with bad symbols" do
      let(:input) { "asdf)" }
      it { expect{ subject }.to raise_exception(Parslet::ParseFailed) }
    end

    context "word with spaces" do
      let(:input) { "asdf adfasdf" }
      it { expect{ subject }.to raise_exception(Parslet::ParseFailed) }
    end
  end

  describe "rule: space?" do
    subject { super().space?.parse input }

    context "one space input" do
      let(:input) { " " }
      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "multi space input" do
      let(:input) { "   " }
      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "empty input" do
      let(:input) { "" }
      it { is_expected.to eq(input) }
    end
  end

  describe "rule: space" do
    subject { super().space.parse input }

    context "one space input" do
      let(:input) { " " }
      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "multi space input" do
      let(:input) { "   " }
      it { is_expected.to be_a(Parslet::Slice) }
      it { is_expected.to eq(input) }
    end

    context "empty input" do
      let(:input) { "" }
      it { expect{ subject }.to raise_exception(Parslet::ParseFailed) }
    end
  end
end
