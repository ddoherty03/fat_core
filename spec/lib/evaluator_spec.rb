require 'spec_helper'

module FatCore
  describe Evaluator do
    it 'should be able to evaluate a simple expression' do
      vars = { a: 23, b: 14, c: 'hello', d: Date.today }
      ev = Evaluator.new(vars: vars)
      lvars = { x: 77, y: 88, z: Rational(1, 3) }
      expect(ev.evaluate('@a + @b', vars: lvars)).to eq(37)
      expect(ev.evaluate('x + y', vars: lvars)).to eq(165)
      expect(ev.evaluate('@a + y', vars: lvars)).to eq(111)
    end

    it 'should be able to evaluate with a before hook' do
      vars = { a: 23, b: 14, c: 'hello', d: Date.today }
      ev = Evaluator.new(vars: vars, before: '@d += 1')
      lvars = { x: 77, y: 88, z: Rational(1, 3) }
      expect(ev.evaluate('@d', vars: lvars)).to eq(Date.today + 1)
      expect(ev.evaluate('@d', vars: lvars)).to eq(Date.today + 2)
      expect(ev.evaluate('@d', vars: lvars)).to eq(Date.today + 3)
    end

    it 'should be able to evaluate with an after hook' do
      vars = { a: 23, b: 114, c: 'hello', d: Date.today }
      ev = Evaluator.new(vars: vars, after: '@b = @b * z')
      lvars = { x: 77, y: 88, z: Rational(1, 3) }
      # Note: since @b is not evaluated until after the expression, the result
      # of multiplying by z (1/3) does not appear until the following eval.
      expect(ev.evaluate('@b', vars: lvars)).to eq(114)
      expect(ev.evaluate('@b', vars: lvars)).to eq(Rational(38, 1))
      expect(ev.evaluate('@b', vars: lvars)).to eq(Rational(38, 3))
    end
  end
end
