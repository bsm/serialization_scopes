module SerializationScopes # :nodoc:
  module Shoulda # :nodoc:
    module Matchers

      # Ensures that records are serialized correctly
      #
      # Example:
      #   describe Article do
      #     it { should serialize }
      #     it { should serialize.to(:article) }
      #     it { should serialize.to(:article).with_attributes(6) }
      #     it { should serialize.for(:reader).to(:article).with_attributes(4) }
      #   end
      def serialize
        SerializeMatcher.new
      end

      class SerializeMatcher

        def for(scope)
          @scope = scope
          self
        end

        def to(value)
          @to = value
          self
        end

        def with_attributes(count)
          @count = count
          self
        end

        def matches?(subject)
          @subject = subject
          @subject.id ||= rand(10000000)
          correct_root? && correct_column_count?
        end

        attr_reader :failure_message, :negative_failure_message

        def description
          result = "serialize"
          result << " with #{@scope.inspect} scope" unless @scope.nil?
          result << " to #{@to.inspect}" unless @to.nil?
          result << " with #{@count} attributes" unless @count.nil?
          result
        end

        def failure_message
          "Expected #{expectation}"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        private

          def root_name
            serialized.keys.first
          end

          def attributes
            serialized[root_name] ? serialized[root_name].keys : []
          end

          def serialized
            @serialized ||= ActiveSupport::JSON.decode(@subject.to_json(:scope => @scope))
          end

          def expectation
            result = "to #{description}"
            result << ", but #{failure_description}"
            result
          end

          def correct_root?
            @to.nil? || @to == root_name
          end

          def correct_column_count?
            @count.nil? || @count == attributes.size
          end

          def failure_description
            if !correct_root?
              "root was #{root_name.inspect}"
            elsif !correct_column_count?
              "#{attributes.size} attributes were created (#{attributes.map(&:to_s).sort.join(', ')})"
            end
          end

      end

    end
  end
end
