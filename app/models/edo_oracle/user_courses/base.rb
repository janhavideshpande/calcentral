module EdoOracle
  module UserCourses

    APP_ID = 'Campus'

    class Base < BaseProxy

      def initialize(options = {})
        super(Settings.campusdb, options)
        @uid = @settings.fake_user_id if @fake
        # Non-legacy terms are those after Settings.terms.legacy_cutoff.
        @non_legacy_academic_terms = Berkeley::Terms.fetch.campus.values.reject &:legacy?
      end

      def self.access_granted?(uid)
        !uid.blank?
      end

      def merge_enrollments(campus_classes)
        return if @non_legacy_academic_terms.empty?
        previous_item = {}
        EdoOracle::Queries.get_enrolled_sections(@uid, @non_legacy_academic_terms).each do |row|
          if (item = row_to_feed_item(row, previous_item))
            item[:role] = 'Student'
            merge_feed_item(item, campus_classes)
            previous_item = item
          end
        end
      end

      def merge_instructing(campus_classes)
        return if @non_legacy_academic_terms.empty?
        previous_item = {}
        cross_listing_tracker = {}
        EdoOracle::Queries.get_instructing_sections(@uid, @non_legacy_academic_terms).each do |row|
          if (item = row_to_feed_item(row, previous_item, cross_listing_tracker))
            item[:role] = 'Instructor'
            merge_feed_item(item, campus_classes)
            previous_item = item
          end
        end
        merge_implicit_instructing campus_classes
      end

      # This is done in a separate step so that all secondary sections
      # are ordered after explicitly assigned primary sections.
      def merge_implicit_instructing(campus_classes)
        campus_classes.each_value do |term|
          term.each do |course|
            if course[:role] == 'Instructor'
              section_ids = course[:sections].map { |section| section[:ccn] }.to_set
              course[:sections].select { |section| section[:is_primary_section] }.each do |primary|
                EdoOracle::Queries.get_associated_secondary_sections(course[:term_id], primary[:ccn]).each do |row|
                  # Skip duplicates.
                  if section_ids.add? row['section_id']
                    course[:sections] << row_to_section_data(row)
                  end
                end
              end
            end
          end
        end
      end

      def merge_feed_item(item, campus_classes)
        semester_key = item.values_at(:term_yr, :term_cd).join '-'
        campus_classes[semester_key] ||= []
        campus_classes[semester_key] << item
      end

      def row_to_feed_item(row, previous_item, cross_listing_tracker=nil)
        unless (course_item = new_course_item(row, previous_item))
          previous_item[:sections] << row_to_section_data(row, cross_listing_tracker)
          nil
        else
          term_data = Berkeley::TermCodes.from_edo_id(row['term_id']).merge({
            term_id: row['term_id']
          })
          course_name = row['course_title'].present? ? row['course_title'] : row['course_title_short']
          course_data = {
            catid: row['catalog_id'],
            course_catalog: row['catalog_id'],
            dept: row['dept_name'],
            emitter: 'Campus',
            name: course_name,
            sections: [
              row_to_section_data(row, cross_listing_tracker)
            ]
          }
          course_item.merge(term_data).merge(course_data)
        end
      end

      def new_course_item(row, previous_item)
        if row.values_at('dept_name', 'catalog_id', 'term_id') != previous_item.values_at(:dept, :catid, :term_id)
          course_ids_from_row row
        end
      end

      # Create IDs for a given course item:
      #   "id" : unique for the UserCourses feed across terms; used by Classes
      #   "slug" : URL-friendly ID without term information; used by Academics
      #   "course_code" : the short course name as displayed in the UX
      def course_ids_from_row(row)
        dept_name, catalog_id = row.values_at('dept_name', 'catalog_id')
        unless dept_name && catalog_id
          name_components = row['display_name'].split
          catalog_id = name_components.pop
          dept_name = name_components.join '_'
        end
        slug = [dept_name, catalog_id].map { |str| normalize_to_slug str }.join '-'
        term_code = Berkeley::TermCodes.edo_id_to_code row['term_id']
        {
          course_code: row['display_name'],
          id: "#{slug}-#{term_code}",
          slug: slug
        }
      end

      def normalize_to_slug(str)
        str.downcase.gsub(/[^a-z0-9-]+/, '_')
      end

      def row_to_section_data(row, cross_listing_tracker=nil)
        section_data = {
          ccn: row['section_id'].to_s,
          instruction_format: row['instruction_format'],
          is_primary_section: to_boolean(row['primary']),
          section_label: "#{row['instruction_format']} #{row['section_num']}",
          section_number: row['section_num']
        }
        if section_data[:is_primary_section]
          section_data[:units] = row['units']
        else
          section_data[:associated_primary_id] = row['primary_associated_section_id']
        end

        # Grading and waitlist data only apply to enrollment records and will be skipped for instructors.
        if row.include? 'enroll_status'
          section_data[:grade] = row['grade'].strip if row['grade'].present?
          section_data[:grading_basis] = row['grading_basis'] if section_data[:is_primary_section]
          if row['enroll_status'] == 'W'
            section_data[:waitlistPosition] = row['waitlist_position'].to_i
            section_data[:enroll_limit] = row['enroll_limit'].to_i
          end
        end

        # Cross-listed primaries are tracked only when merging instructed sections.
        if cross_listing_tracker && section_data[:is_primary_section]
          cross_listing_slug = row.values_at('term_id', 'cs_course_id', 'instruction_format', 'section_num').join '-'
          if (cross_listings = cross_listing_tracker[cross_listing_slug])
            # The front end expects cross-listed primaries to share a unique identifier, called 'hash'
            # because it was formerly implemented as an Oracle hash.
            section_data[:cross_listing_hash] = cross_listing_slug
            if cross_listings.length == 1
              cross_listings.first[:cross_listing_hash] = cross_listing_slug
            end
            cross_listings << section_data
          else
            cross_listing_tracker[cross_listing_slug] = ([] << section_data)
          end
        end

        section_data
      end

      def merge_detailed_section_data(campus_classes)
        campus_classes.each_value do |semester|
          semester.each do |course|
            course[:sections].uniq!
            course[:sections].each do |section|
              section.merge! EdoOracle::CourseSections.new(course[:term_id], section[:ccn]).get_section_data
            end
          end
        end
      end

      def to_boolean(string)
        string == 'true'
      end

    end
  end
end
