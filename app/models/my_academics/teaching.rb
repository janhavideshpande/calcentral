module MyAcademics
  class Teaching
    include AcademicsModule

    def merge(data)
      legacy_user_courses = CampusOracle::UserCourses::All.new(user_id: @uid)
      edo_user_courses = EdoOracle::UserCourses::All.new(user_id: @uid)
      feed = legacy_user_courses.get_all_campus_courses.merge edo_user_courses.get_all_campus_courses

      teaching_semesters = format_teaching_semesters feed
      if teaching_semesters.present?
        data[:teachingSemesters] = teaching_semesters
      end
    end

    # Our bCourses Canvas integration occasionally needs to create an Academics Teaching Semesters
    # list based on an explicit set of CCNs.
    def courses_list_from_ccns(term_yr, term_code, ccns)
      if Berkeley::Terms.legacy?(term_yr, term_code)
        proxy = CampusOracle::UserCourses::SelectedSections.new({user_id: @uid})
      else
        proxy = EdoOracle::UserCourses::SelectedSections.new({user_id: @uid})
      end
      feed = proxy.get_selected_sections(term_yr, term_code, ccns)
      format_teaching_semesters(feed, true)
    end

    def format_teaching_semesters(sections_data, ignore_roles = false)
      teaching_semesters = []
      # The campus courses data is organized by semesters, with course offerings under them.
      sections_data.keys.sort.reverse_each do |term_key|
        teaching_semester = semester_info term_key
        sections_data[term_key].each do |course|
          next unless ignore_roles || (course[:role] == 'Instructor')
          course_info = course_info_with_multiple_listings course
          if course_info[:sections].count { |section| section[:is_primary_section] } > 1
            merge_multiple_primaries(course_info, course[:course_option])
          end
          append_with_merged_crosslistings(teaching_semester[:classes], course_info)
        end
        teaching_semesters << teaching_semester unless teaching_semester[:classes].empty?
      end
      teaching_semesters
    end

  end
end
