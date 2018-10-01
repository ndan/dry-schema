RSpec.shared_context :message_compiler do
  subject(:compiler) { Dry::Schema::MessageCompiler.new(messages) }

  let(:messages) do
    Dry::Schema::Messages::YAML.load
  end

  let(:result) do
    compiler.public_send(visitor, node)
  end
end
