describe CampusSolutions::AdvisingResources do
  let(:user_id) { '12348' }
  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:ucAdvisingResources]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::AdvisingResources.new(fake: true, user_id: user_id) }
    let(:advisor_cs_id) { '19000000' }
    before do
      allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: user_id).and_return(
        double(lookup_campus_solutions_id: advisor_cs_id))
    end

    context 'no student uid requested' do
      it_should_behave_like 'a proxy that gets data'
      it 'includes specific mock data' do
        expect(proxy.get[:feed][:ucAdvisingResources][:ucAdvisingLinks][:ucAdviseeStudentCenter][:url]).to eq(
          'https://bcs-web-dev-03.is.berkeley.edu:8443/psc/bcsdev/EMPLOYEE/HRMS/c/SSR_ADVISEE_OVRD.SSS_STUDENT_CENTER.GBL?')
      end
      it 'should query for advisor EMPLID only' do
        proxy.get
        expect(a_request(:get, /UC_AA_ADVISING_RESOURCES.v1\/UC_ADVISING_RESOURCES/).with(query: {
          'EMPLID' => advisor_cs_id
        })).to have_been_made
      end
    end

    context 'student uid requested' do
      let(:student_uid) { '61889' }
      let(:student_cs_id) { '11667051' }
      let(:proxy) { CampusSolutions::AdvisingResources.new(fake: true, user_id: user_id, student_uid: student_uid) }
      before do
        allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: student_uid).and_return(
          double(lookup_campus_solutions_id: student_cs_id))
      end
      it 'should query for advisor and student EMPLID' do
        proxy.get
        expect(a_request(:get, /UC_AA_ADVISING_RESOURCES.v1\/UC_ADVISING_RESOURCES/).with(query: {
          'EMPLID' => advisor_cs_id,
          'STUDENT_EMPLID' => student_cs_id
        })).to have_been_made
      end
      context 'student EMPLID lookup failure' do
        let(:student_cs_id) { nil }
        it 'should report failure' do
          expect(proxy.get).to eq({noStudentId: true})
        end
      end
    end
  end
end
