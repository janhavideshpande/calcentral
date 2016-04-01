module HubEdos
  class AcademicStatus < Student

    include CampusSolutions::AcademicProfileFeatureFlagged

    def initialize(options = {})
      super(options)
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/academic-status"
    end

    def json_filename
      'hub_academic_status.json'
    end

    def include_fields
      %w(academicStatuses awardHonors degrees holds)
    end

  end
end
