# frozen_string_literal: true

require "zeitwerk"

# IdempotentActor
module IdempotentActor; end

lib = File.expand_path("../..", __dir__)

loader = Zeitwerk::Loader.new
loader.tag = "idempotent_actor"
loader.inflector = Zeitwerk::GemInflector.new(
  File.expand_path("idempotent_actor.rb", lib)
)
loader.push_dir(lib)
loader.ignore(__dir__)
loader.setup
