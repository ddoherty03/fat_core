require 'spec_helper'
require 'fat_core/range'

describe Range do
  describe 'set operations' do
    it 'knows if it is a subset of another range' do
      expect((4..8)).to be_subset_of((2..9))
      expect((4..8)).to be_subset_of((4..8))
      expect((4..8)).not_to be_subset_of((2..7))
      expect((4..8)).not_to be_subset_of((5..8))
      expect((4..8)).not_to be_subset_of((11..20))
    end

    it 'knows if it is a proper subset of another range' do
      expect((4..8)).to be_proper_subset_of((2..9))
      expect((4..8)).to be_proper_subset_of((4..9))
      expect((4..8)).not_to be_proper_subset_of((4..8))
      expect((4..8)).not_to be_proper_subset_of((2..7))
      expect((4..8)).not_to be_proper_subset_of((5..8))
      expect((4..8)).not_to be_proper_subset_of((11..20))
    end

    it 'knows if it is a superset of another range' do
      expect((4..8)).to be_superset_of((5..7))
      expect((4..8)).to be_superset_of((6..8))
      expect((4..8)).to be_superset_of((4..7))
      expect((4..8)).to be_superset_of((4..8))
      expect((4..8)).not_to be_superset_of((2..9))
      expect((4..8)).not_to be_superset_of((2..8))
      expect((4..8)).not_to be_superset_of((4..9))
      expect((4..8)).not_to be_superset_of((8..20))
      expect((4..8)).not_to be_superset_of((0..4))
      expect((4..8)).not_to be_superset_of((0..3))
      expect((4..8)).not_to be_superset_of((9..20))
    end

    it 'knows if it is a proper superset of another range' do
      expect((4..8)).to be_proper_superset_of((5..7))
      expect((4..8)).to be_proper_superset_of((6..8))
      expect((4..8)).to be_proper_superset_of((4..7))
      expect((4..8)).not_to be_proper_superset_of((4..8))
      expect((4..8)).not_to be_proper_superset_of((2..9))
      expect((4..8)).not_to be_proper_superset_of((2..8))
      expect((4..8)).not_to be_proper_superset_of((4..9))
      expect((4..8)).not_to be_proper_superset_of((8..20))
      expect((4..8)).not_to be_proper_superset_of((0..4))
      expect((4..8)).not_to be_proper_superset_of((0..3))
      expect((4..8)).not_to be_proper_superset_of((9..20))
    end

    it 'knows its intersection with another range' do
      expect(((0..10) & (5..20))).to eq((5..10))
      expect(((0..10) & (5..20))).to eq((5..20) & (0..10))
      expect(((0..10) & (10..20))).to eq((10..10))
    end

    it 'intersection should return nil if there is no overlap' do
      expect(((0..10) & (15..20))).to be_nil
    end

    it 'knows its union with another range' do
      expect(((0..10) + (5..20))).to eq((0..20))
      expect(((0..10) + (5..20))).to eq((5..20) + (0..10))
      expect(((0..10) + (10..20))).to eq((0..20))

      # For discrete values, union should work on contiguous ranges
      expect(((0..5) + (6..20))).to eq((0..20))
    end

    it 'union should return nil if there is no overlap' do
      expect(((0..10) & (15..20))).to be_nil
      expect(((15..20) & (0..10))).to be_nil
    end

    it 'knows the difference with another range' do
      # Other is same as self
      # xrubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      expect(((4..10) - (4..10)).size).to eq(0)
      expect(((4..10) - (4..10))).to be_empty
      # xrubocop:enable Lint/BinaryOperatorWithIdenticalOperands

      # Other is proper subset of self
      expect(((4..10) - (6..7)).first).to eq((4..5))
      expect(((4..10) - (6..7)).last).to eq((8..10))
      expect(((4..10) - (6..10)).first).to eq((4..5))
      expect(((4..10) - (4..7)).last).to eq((8..10))

      # Other overlaps on the left
      expect(((4..10) - (0..6)).size).to eq(1)
      expect(((4..10) - (0..6)).first).to eq((7..10))

      expect(((4..10) - (4..6)).size).to eq(1)
      expect(((4..10) - (4..6)).first).to eq((7..10))

      # Other overlaps on the right
      expect(((4..10) - (7..11)).size).to eq(1)
      expect(((4..10) - (7..11)).first).to eq((4..6))

      expect(((4..10) - (7..10)).size).to eq(1)
      expect(((4..10) - (7..10)).last).to eq((4..6))

      # Other does not overlap
      expect((4..10) - (13..20)).to eq([(4..10)])
      expect((4..10) - (1..3)).to  eq([(4..10)])
    end
  end

  describe 'joining' do
    it 'can join contiguous ranges' do
      expect((0..3).join(4..8)).to eq((0..8))
      expect((4..8).join(0..3)).to eq((0..8))
    end

    it 'returns nil on join of non-contiguous ranges' do
      expect((0..3).join(5..8)).to be_nil
      expect((0...3).join(4..8)).to be_nil

      expect((5..8).join(0..3)).to be_nil
      expect((4..8).join(0...3)).to be_nil
    end

    it 'works with Floats, allowing single-point overlap' do
      expect((0.0..3.0).join(3.0..8.2)).to eq((0.0..8.2))
      expect((3.0..8.2).join(0.0..3.0)).to eq((0.0..8.2))
    end
  end

  describe 'spanning' do
    it 'can determine whether it is spanned by a set of ranges' do
      expect((0..10)).to be_spanned_by([(0..3), (4..6), (7..10)])
    end

    it 'can determine that overlapping ranges do not span' do
      expect((0..10)).not_to be_spanned_by([(0..3), (3..6), (7..10)])
    end

    it 'allows spanning ranges to be any Enumerable' do
      require 'set'
      set = [(0..3), (4..6), (7..10)].to_set
      expect((0..10)).to be_spanned_by(set)
      set = [(0...3), (4..6), (7..10)].to_set
      expect((0..10)).not_to be_spanned_by(set)
    end

    it 'allows the spanning set to be wider than itself' do
      set = [(0..3), (4..6), (7..10)].to_set
      expect((2..8)).to be_spanned_by(set)
      expect((5..6)).to be_spanned_by(set)
    end
  end

  describe 'overlapping a single range' do
    it 'knows if another range overlaps it' do
      expect((0..10)).to be_overlaps(-3..5)
      expect((0..10)).to be_overlaps(3..5)
      expect((0..10)).to be_overlaps(8..15)
      expect((0..10)).to be_overlaps(0..10)
      expect((0..10)).not_to be_overlaps(11..12)
      expect((0..10)).not_to be_overlaps(-11..-1)

      # Order of operands should not matter
      expect((-3..5)).to be_overlaps(0..10)
      expect((3..5)).to be_overlaps(0..10)
      expect((8..15)).to be_overlaps(0..10)
      expect((0..10)).to be_overlaps(0..10)
      expect((11..12)).not_to be_overlaps(0..10)
      expect((-11..-1)).not_to be_overlaps(0..10)
    end

    it 'can determine whether a set contains covered overlaps' do
      expect(Range.overlaps_among?([(0..3), (2..6), (7..10)])).to be true
      expect((0..10).overlaps_among?([(0..3), (2..6), (7..10)])).to be true
    end

    it 'does not care about overlaps outside self' do
      expect(Range.overlaps_among?([(0..3), (2..6), (7..10)])).to be true
      expect((11..15).overlaps_among?([(0..3), (2..6), (7..10)])).to be false
    end

    it 'does not consider contiguous ranges as overlapping' do
      expect(Range.overlaps_among?([(0..3), (4..6), (7..10)])).to be false
    end

    it 'does not consider non-contiguous ranges as overlapping' do
      expect(Range.overlaps_among?([(0..3), (4..6), (8..10)])).to be false
    end

    it 'does not consider an empty set as overlapping' do
      expect(Range.overlaps_among?([])).to be false
    end
  end

  describe '#gaps' do
    it 'returns an empty array if ranges completely cover' do
      expect((0..10).gaps([(-1..3), (4..8), (9..11)])).to be_empty
    end

    it 'returns array for itself if ranges are empty' do
      expect((0..10).gaps([])).to eq([(0..10)])
    end

    it 'returns an array of gaps' do
      gaps = (0..10).gaps([(0..3), (5..6), (9..10)])
      expect(gaps[0]).to eq((4..4))
      expect(gaps[1]).to eq((7..8))
    end

    it 'allows ranges to extend before and after self' do
      gaps = (0..10).gaps([(-3..3), (4..6), (7..13)])
      expect(gaps).to be_empty
    end

    it 'does not include parts before or after in gaps' do
      gaps = (0..10).gaps([(-10..-8), (-3..3), (7..13), (30..40)])
      expect(gaps.size).to eq(1)
      expect(gaps[0]).to eq((4..6))
    end

    it 'includes gaps at beginning and end' do
      gaps = (0..10).gaps([(2..3), (4..6), (7..8)])
      expect(gaps[0]).to eq((0..1))
      expect(gaps[1]).to eq((9..10))
    end

    it 'works even if ranges are out of order' do
      gaps = (0..10).gaps([(2..3), (30..40), (7..8), (-10..-8), (4..6)])
      expect(gaps[0]).to eq((0..1))
      expect(gaps[1]).to eq((9..10))
    end

    it 'notices single point coverage' do
      gaps = (0..10).gaps([(4..4), (5..5), (6..6)])
      expect(gaps[0]).to eq((0..3))
      expect(gaps[1]).to eq((7..10))
    end

    it 'works for a single-point range' do
      gaps = (3..3).gaps([(0..2), (4..4), (5..5), (6..6)])
      expect(gaps[0]).to eq((3..3))
    end

    it 'works even if ranges overlap' do
      gaps = (0..10).gaps([(-2..3), (2..8), (4..10)])
      expect(gaps).to be_empty
    end
  end

  describe '#overlaps' do
    it 'returns an empty array if ranges are empty' do
      expect((0..10).overlaps([])).to be_empty
    end

    it 'returns an empty array if ranges is same as self' do
      expect((0..10).overlaps([(0..10)])).to be_empty
    end

    it 'returns an empty array if ranges is wider than self' do
      expect((0..10).overlaps([(-5..15)])).to be_empty
    end

    it 'returns an empty array if ranges is narrower than self' do
      expect((0..10).overlaps([(5..8)])).to be_empty
    end

    it 'returns an array of overlaps' do
      overlaps = (0..10).overlaps([(0..3), (2..6), (4..10)])
      expect(overlaps.size).to eq(2)
      expect(overlaps[0]).to eq((2..3))
      expect(overlaps[1]).to eq((4..6))
    end

    it 'does not return any overlaps before self' do
      overlaps = (0..10).overlaps([(-5..-3), (-4..-1), (0..3), (2..6), (4..10)])
      expect(overlaps.size).to eq(2)
      expect(overlaps[0]).to eq((2..3))
      expect(overlaps[1]).to eq((4..6))
    end

    it 'does not return any overlaps after self' do
      overlaps = (0..10).overlaps([(0..3), (2..6), (4..15), (11..20)])
      expect(overlaps.size).to eq(2)
      expect(overlaps[0]).to eq((2..3))
      expect(overlaps[1]).to eq((4..6))
    end
  end
end
