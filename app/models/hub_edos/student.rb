module HubEdos
  class Student < Proxy

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/all"
    end

    def json_filename
      # student_edo.json contains the bmeta contract as defined at http://bmeta.berkeley.edu/common/personExampleV0.json
      # student_api_via_hub.json contains dummy of what we really get from ihub api
      'student_api_via_hub.json'
    end

    def build_feed(response)
      transformed_response = filter_fields(transform_address_keys(parse_response(response)))
      {
        'student' => transformed_response
      }
    end

    def empty_feed
      {
        'student' => {}
      }
    end

    def transform_address_keys(response)
      # TODO: this should really be done in the Integration Hub
      get_students(response).each do |student|
        if student['addresses'].present?
          student['addresses'].each do |address|
            address['state'] = address.delete('stateCode')
            address['postal'] = address.delete('postalCode')
            address['country'] = address.delete('countryCode')
          end
        end
      end
      response
    end

    def filter_fields(response)
      # only include the fields that this proxy is responsible for
      students = get_students(response)
      first_student = students.any? ? students[0] : {}
      if include_fields.nil?
        return first_student
      end
      result = {}
      first_student.keys.each do |field|
        result[field] = first_student[field] if include_fields.include? field
      end
      result
    end

    def include_fields
      nil
    end

  end
end
