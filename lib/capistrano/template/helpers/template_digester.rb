module Capistrano
  module Template
    module Helpers
      class TemplateDigester < SimpleDelegator
        attr_accessor :digest_algo

        def initialize(renderer, digest_algo)
          super renderer

          self.digest_algo = digest_algo
        end

        def digest
          digest_algo.call(as_str)
        end
      end
    end
  end
end
