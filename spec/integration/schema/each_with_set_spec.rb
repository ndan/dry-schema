# frozen_string_literal: true

RSpec.describe 'Schema with each and set rules' do
  subject(:schema) do
    Dry::Schema.define do
      required(:payments).value(:array).each do
        schema do
          required(:method).filled(:str?)
          required(:amount).filled(:float?)
        end
      end
    end
  end

  describe '#messages' do
    it 'validates using all rules' do
      expect(schema.(payments: [{}]).messages).to eql(
        { payments: {
          0 => { method: ['is missing', 'must be a string'], amount: ['is missing', 'must be a float'] }
        }}
      )
    end

    it 'validates each payment against its set of rules' do
      input = {
        payments: [
          { method: 'cc', amount: 1.23 },
          { method: 'wire', amount: 4.56 }
        ]
      }

      expect(schema.(input).messages).to eql({})
    end

    it 'validates presence of the method key for each payment' do
      input = {
        payments: [
          { method: 'cc', amount: 1.23 },
          { amount: 4.56 }
        ]
      }

      expect(schema.(input).messages).to eql(
        payments: { 1 => { method: ['is missing', 'must be a string'] } }
      )
    end

    it 'validates type of the method value for each payment' do
      input = {
        payments: [
          { method: 'cc', amount: 1.23 },
          { method: 12, amount: 4.56 }
        ]
      }

      expect(schema.(input).messages).to eql(
        payments: { 1 => { method: ['must be a string'] } }
      )
    end

    it 'validates type of the amount value for each payment' do
      input = {
        payments: [
          { method: 'cc', amount: 1.23 },
          { method: 'wire', amount: '4.56' }
        ]
      }

      expect(schema.(input).messages).to eql(
        payments: { 1 => { amount: ['must be a float'] } }
      )
    end
  end
end
