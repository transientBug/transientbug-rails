require "parslet/rig/rspec"

RSpec.describe QueryGrammar::Parser do
  describe "rule: query" do
    subject { super().query }

    context "when nothing" do
      let(:input) { "" }

      it { is_expected.to parse(input) }
    end

    context "when anything" do
      let(:input) { "asdf" }

      it { is_expected.to parse(input) }
    end
  end

  describe "rule: expression" do
    subject { super().expression }

    context "when infix_group" do
      let(:input) { "asdf AND asf" }

      it { is_expected.to parse(input) }
    end

    context "when group" do
      let(:input) { "(asdf)" }

      it { is_expected.to parse(input) }
    end

    context "when clause" do
      let(:input) { "asdf" }

      it { is_expected.to parse(input) }
    end
  end

  describe "rule: group" do
    subject { super().group }

    context "when expression" do
      let(:input) { "a" }

      it { is_expected.not_to parse(input) }
    end

    context "when wrapped in parenthesis" do
      let(:input) { "(a)" }

      it { is_expected.to parse(input) }
    end

    context "when negated expression" do
      let(:input) { "NOT b" }

      it { is_expected.not_to parse(input) }
    end

    context "when negated group" do
      let(:input) { "NOT (b adsf)" }

      it { is_expected.to parse(input) }
    end
  end

  describe "rule: infix_group" do
    subject { super().infix_group }

    context "when OR" do
      let(:input) { "a OR b" }

      it { is_expected.to parse(input) }
    end

    context "when AND" do
      let(:input) { "a AND b" }

      it { is_expected.to parse(input) }
    end

    context "when spaced (implicit AND)" do
      let(:input) { "a b" }

      it { is_expected.to parse(input) }
    end
  end

  describe "rule: clause" do
    subject { super().clause }

    context "when term only" do
      let(:input) { "thing" }

      it { is_expected.to parse(input) }
    end

    context "when term list only" do
      let(:input) { "(one two)" }

      it { is_expected.not_to parse(input) }
    end

    context "when prefix only" do
      let(:input) { "test:" }

      it { is_expected.to parse(input) }
    end

    context "when unary prefix only" do
      let(:input) { "+test:" }

      it { is_expected.to parse(input) }
    end

    context "when negator prefix only" do
      let(:input) { "NOT test:" }

      it { is_expected.to parse(input) }
    end

    context "when negator unary prefix only" do
      let(:input) { "NOT +test:" }

      it { is_expected.to parse(input) }
    end

    context "when prefixed term" do
      let(:input) { "test:thing" }

      it { is_expected.to parse(input) }
    end

    context "when prefixed term list" do
      let(:input) { "test:(one two)" }

      it { is_expected.to parse(input) }
    end

    context "when unary prefixed field" do
      let(:input) { "+test:one" }

      it { is_expected.to parse(input) }
    end

    context "when negator unary prefixed field" do
      let(:input) { "NOT +test:one" }

      it { is_expected.to parse(input) }
    end
  end

  describe "rule: negator" do
    subject { super().negator }

    context "when no space" do
      let(:input) { "NOT" }

      it { is_expected.not_to parse(input) }
    end

    context "when one space" do
      let(:input) { "NOT " }

      it { is_expected.to parse(input) }
    end

    context "when lots of space" do
      let(:input) { "NOT     " }

      it { is_expected.to parse(input) }
    end
  end

  describe "rule: term_list" do
    subject { super().term_list }

    context "when balanced parenthesis" do
      context "when single item" do
        let(:input) { "(term)" }

        it { is_expected.to parse(input) }
      end

      context "when multiple items" do
        let(:input) { '(term "phrase")' }

        it { is_expected.to parse(input) }
      end
    end

    context "when one unbalanced ( parenthesis" do
      let(:input) { "(" }

      it { is_expected.not_to parse(input) }
    end

    context "when one unbalanced ) parenthesis" do
      let(:input) { ")" }

      it { is_expected.not_to parse(input) }
    end
  end

  describe "rule: term" do
    subject { super().term }

    context "when a single term" do
      let(:input) { "term" }

      it { is_expected.to parse(input) }
    end

    context "when a phrase" do
      let(:input) { '"this is a phrase"' }

      it { is_expected.to parse(input) }
    end
  end

  describe "rule: phrase" do
    subject { super().phrase }

    context "when perfect quotes" do
      let(:input) { '"this is a phrase"' }

      it { is_expected.to parse(input) }
    end

    context "when one quote too short" do
      let(:input) { '"this is a ' }

      it { is_expected.not_to parse(input) }
    end

    context "when three is outright" do
      let(:input) { '"this is" a"' }

      it { is_expected.not_to parse(input) }
    end
  end

  describe "rule: word" do
    subject { super().word }

    context "when character" do
      let(:input) { "a" }

      it { is_expected.to parse(input) }
    end

    context "when CHARACTER" do
      let(:input) { "A" }

      it { is_expected.to parse(input) }
    end

    context "when digit" do
      let(:input) { "1" }

      it { is_expected.to parse(input) }
    end

    context "when word" do
      let(:input) { "asdf" }

      it { is_expected.to parse(input) }
    end

    context "when word and digit" do
      let(:input) { "asdf1234" }

      it { is_expected.to parse(input) }
    end

    context "when word with good symbols" do
      let(:input) { "asdf-asf_sdaf+ad=dfs" }

      it { is_expected.to parse(input) }
    end

    context "when word with bad symbols" do
      let(:input) { "asdf)" }

      it { is_expected.not_to parse(input) }
    end

    context "when word with spaces" do
      let(:input) { "asdf adfasdf" }

      it { is_expected.not_to parse(input) }
    end
  end

  describe "rule: space?" do
    subject { super().space? }

    context "when one space input" do
      let(:input) { " " }

      it { is_expected.to parse(input) }
    end

    context "when multi space input" do
      let(:input) { "   " }

      it { is_expected.to parse(input) }
    end

    context "when empty input" do
      let(:input) { "" }

      it { is_expected.to parse(input) }
    end
  end

  describe "rule: space" do
    subject { super().space }

    context "when one space input" do
      let(:input) { " " }

      it { is_expected.to parse(input) }
    end

    context "when multi space input" do
      let(:input) { "   " }

      it { is_expected.to parse(input) }
    end

    context "when empty input" do
      let(:input) { "" }

      it { is_expected.not_to parse(input) }
    end
  end
end
