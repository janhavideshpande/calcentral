describe 'MyAcademics::GpaUnits' do

  let(:uid) { '61889' }
  let(:eight_digit_cs_id) { '87654321' }
  let(:ten_digit_cs_id) { '1234567890' }

  let(:feed) do
    {}.tap { |feed| MyAcademics::GpaUnits.new(uid).merge feed }
  end

  context 'when sourced from Hub academic status' do
    let(:status_proxy) { HubEdos::AcademicStatus.new(user_id: uid, fake: true) }
    before do
      allow_any_instance_of(CalnetCrosswalk::ByUid).to receive(:lookup_campus_solutions_id).and_return ten_digit_cs_id
      allow(HubEdos::AcademicStatus).to receive(:new).and_return status_proxy
    end

    it 'translates GPA' do
      expect(feed[:gpaUnits][:cumulativeGpa]).to eq 3.8
    end

    it 'translates total units' do
      expect(feed[:gpaUnits][:totalUnits]).to eq 73
    end

    context 'empty status feed' do
      before { status_proxy.set_response(status: 200, body: '{}') }
      it 'reports empty' do
        expect(feed[:gpaUnits][:empty]).to eq true
      end
    end

    context 'errored status feed' do
      before { status_proxy.set_response(status: 502, body: '') }
      it 'reports error' do
        expect(feed[:gpaUnits][:errored]).to eq true
      end
    end

    context 'status feed lacking some data' do
      before do
        status_proxy.override_json do |json|
          json['apiResponse']['response']['any']['students'][0]['academicStatuses'][0].delete 'cumulativeUnits'
        end
      end
      it 'returns what data it can' do
        expect(feed[:gpaUnits][:cumulativeGpa]).to be_present
        expect(feed[:gpaUnits][:totalUnits]).to be nil
      end
    end
  end

  context 'when sourced from Oracle views' do
    before { allow_any_instance_of(CalnetCrosswalk::ByUid).to receive(:lookup_campus_solutions_id).and_return eight_digit_cs_id }

    context 'known test user', if: CampusOracle::Connection.test_data? do
      let(:uid) { '300939' }
      it 'should contain expected test data' do
        expect(feed[:gpaUnits]).to eq ({
          cumulativeGpa: '2.595',
          totalUnits: 18,
          totalUnitsAttempted: 20
        })
      end
    end
  end

end
