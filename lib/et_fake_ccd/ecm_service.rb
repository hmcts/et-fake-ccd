module EtFakeCcd
  #noinspection RubyStringKeysInHashInspection
  class EcmService
    OFFICE_CODE_LOOKUP = {
      'Manchester' => '24',
      'Glasgow' => '41'
    }
    Response = Struct.new(:case_reference_count, :start_reference, :multiple_reference)
    # @param [EtFakeCcd::Command::StartMultipleCommand] command
    # @return [EtFakeCcd::EcmService::Response] The response
    def self.start_multiple(command)
      new(command).call
    end

    # @param [EtFakeCcd::Command::StartMultipleCommand] command
    def initialize(command)
      @command = command
    end

    def call
      start_reference = adapter.reserve_reference_numbers_for(command.case_type_id, quantity: command.case_ref_number_count)
      formatted_ref = "#{office_code_for(command.case_type_id)}#{start_reference.to_s.rjust(5, '0')}/#{Time.now.year}"
      formatted_multiple = "#{office_code_for(command.case_type_id)}#{adapter.build_multiple_reference(command.case_type_id).to_s.rjust(5, '0')}/#{Time.now.year}"
      Response.new(command.case_ref_number_count, formatted_ref, formatted_multiple).freeze
    end

    private

    def adapter
      Thread.current[:ecm_service_adapter] ||= InMemoryAdapter.new
    end

    def office_code_for(case_type_id)
      office_code = OFFICE_CODE_LOOKUP[case_type_id]
      raise "Case type id #{case_type_id} has no office lookup defined in the fake ccd server" if office_code.nil?

      office_code
    end

    # @return [EtFakeCcd::Command::StartMultipleCommand] command
    attr_reader :command

    class InMemoryAdapter
      def initialize
        self.data = {}
      end

      def reserve_reference_numbers_for(case_type_id, quantity:)
        data[case_type_id] ||= {}
        data[case_type_id][:next_case_reference] ||= 1
        start = data[case_type_id][:next_case_reference]
        data[case_type_id][:next_case_reference] += quantity
        start
      end

      def build_multiple_reference(case_type_id)
        data[case_type_id] ||= {}
        data[case_type_id][:multiple_reference] ||= 0
        data[case_type_id][:multiple_reference] += 1
      end

      private

      attr_accessor :data
    end

  end
end
