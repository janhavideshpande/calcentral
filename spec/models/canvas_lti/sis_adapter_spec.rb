describe CanvasLti::SisAdapter do
  let(:ccn) { '12345' }
  let(:ccns) { [ccn, '12346'] }
  let(:section_id) { rand(99999).to_s }
  let(:section_ids) { [section_id, rand(99999).to_s] }
  let(:term_year) { '2016' }

  context 'when legacy term in use' do
    before { allow(Berkeley::Terms).to receive(:legacy?).and_return(true) }
    let(:term_code) { 'C' }

    it 'provides enrolled students from legacy source' do
      expect(CampusOracle::Queries).to receive(:get_enrolled_students).with(ccn, term_year, term_code)
      expect(EdoOracle::Queries).to_not receive(:get_enrolled_students)
      CanvasLti::SisAdapter.get_enrolled_students(ccn, term_year, term_code)
    end

    it 'provides instructors for section from sisedo source' do
      expect(CampusOracle::Queries).to receive(:get_section_instructors).with(term_year, term_code, ccn)
      expect(EdoOracle::Queries).to_not receive(:get_section_instructors)
      CanvasLti::SisAdapter.get_section_instructors(ccn, term_year, term_code)
    end

    it 'provides sections for CCN list' do
      expect(CampusOracle::Queries).to receive(:get_sections_from_ccns).with(term_year, term_code, ccns)
      expect(EdoOracle::Queries).to_not receive(:get_sections_by_ids)
      CanvasLti::SisAdapter.get_sections_by_ids(ccns, term_year, term_code)
    end
  end

  context 'when sisedo term in use' do
    let(:expected_term_id) { '2168' }
    before { allow(Berkeley::Terms).to receive(:legacy?).and_return(false) }
    let(:term_code) { 'D' }
    it 'provides enrolled students from sisedo source' do
      expect(EdoOracle::Queries).to receive(:get_enrolled_students).with(section_id, expected_term_id)
      expect(CampusOracle::Queries).to_not receive(:get_enrolled_students)
      CanvasLti::SisAdapter.get_enrolled_students(section_id, term_year, term_code)
    end

    describe '#get_section_instructors' do
      let(:dummy_instructors) {
        [
          {'role_code' => 'PI'},    # Primary Instructor / Teaching and In Charge
          {'role_code' => 'TNIC'},  # Teaching but Not in Charge
          {'role_code' => 'ICNT'},  # In charge but not teaching
          {'role_code' => 'INVT'},  # Teaching with Invalid Title
        ]
      }
      before { allow(EdoOracle::Queries).to receive(:get_section_instructors).and_return(dummy_instructors) }
      it 'provides instructors for section from sisedo source' do
        expect(EdoOracle::Queries).to receive(:get_section_instructors).with(expected_term_id, section_id)
        expect(CampusOracle::Queries).to_not receive(:get_section_instructors)
        CanvasLti::SisAdapter.get_section_instructors(section_id, term_year, term_code)
      end

      it 'adds instructor_func to each instructor' do
        results = CanvasLti::SisAdapter.get_section_instructors(section_id, term_year, term_code)
        expect(results.count).to eq 4
        expect(results[0]['instructor_func']).to eq '1'
        expect(results[1]['instructor_func']).to eq '2'
        expect(results[2]['instructor_func']).to eq '3'
        expect(results[3]['instructor_func']).to eq '4'
      end
    end

    describe '#get_sections_by_ids' do
      let(:dummy_sections) {
        [
          {'section_id' => '12345', 'term_id' => '2168', 'primary' => 'true'},
          {'section_id' => '12346', 'term_id' => '2168', 'primary' => 'false'}
        ]
      }
      before { allow(EdoOracle::Queries).to receive(:get_sections_by_ids).and_return(dummy_sections) }

      it 'provides sections for section id list' do
        expect(EdoOracle::Queries).to receive(:get_sections_by_ids).with(expected_term_id, section_ids)
        expect(CampusOracle::Queries).to_not receive(:get_sections_from_ccns)
        CanvasLti::SisAdapter.get_sections_by_ids(section_ids, term_year, term_code)
      end

      it 'adds course_cntl_num to each section' do
        results = CanvasLti::SisAdapter.get_sections_by_ids(section_ids, term_year, term_code)
        expect(results.count).to eq 2
        expect(results[0]['section_id']).to eq '12345'
        expect(results[1]['section_id']).to eq '12346'
        expect(results[0]['course_cntl_num']).to eq '12345'
        expect(results[1]['course_cntl_num']).to eq '12346'
      end

      it 'adds term_yr and term_cd to each section' do
        results = CanvasLti::SisAdapter.get_sections_by_ids(section_ids, term_year, term_code)
        expect(results.count).to eq 2
        expect(results[0]['term_id']).to eq '2168'
        expect(results[1]['term_id']).to eq '2168'
        expect(results[0]['term_yr']).to eq '2016'
        expect(results[1]['term_yr']).to eq '2016'
        expect(results[0]['term_cd']).to eq 'D'
        expect(results[1]['term_cd']).to eq 'D'
      end

      it 'adds primary_secondary_cd to each section' do
        results = CanvasLti::SisAdapter.get_sections_by_ids(section_ids, term_year, term_code)
        expect(results.count).to eq 2
        expect(results[0]['primary']).to eq 'true'
        expect(results[1]['primary']).to eq 'false'
        expect(results[0]['primary_secondary_cd']).to eq 'P'
        expect(results[1]['primary_secondary_cd']).to eq 'S'
      end
    end
  end

end
