describe CampusSolutions::MyFinancialAidFilteredForDelegate do

  subject { CampusSolutions::MyFinancialAidFilteredForDelegate.from_session state }
  let(:state) { { 'fake' => true, 'user_id' => random_id } }

  context 'mock proxy' do
    context 'no aid year provided' do
      it 'should return empty' do
        expect(subject.get_feed).to be_empty
      end
    end
    context 'aid year provided' do
      before { subject.aid_year = '2016' }
      context 'no delegate session' do
        it 'should deny access' do
          expect{
            subject.get_feed
          }.to raise_exception /Only delegate users have access/
        end
      end
      context 'delegate session' do
        let(:state) { { 'fake' => true, 'user_id' => random_id, SessionKey.original_delegate_user_id => random_id } }
        let(:feed) { subject.get_feed }
        let(:json) { feed.to_json }

        it 'should indicate feed as filtered for delegate' do
          expect(feed[:filteredForDelegate]).to be true
        end
        it 'includes expected items' do
          expect(json).to include 'SHIP Health Insurance'
          expect(json).to include 'Student Standing'
          expect(json).to include 'Estimated Cost of Attendance'
          expect(json).to include 'Dependency Status'
          expect(json).to include 'Family Members in College'
        end
        it 'should filter out \'Expected Family Contribution\'' do
          expect(json).to_not include 'Expected Family Contribution'
        end
        it 'should filter out \'Berkeley Parent Contribution\'' do
          expect(json).to_not include 'Berkeley Parent Contribution'
        end
      end
    end
  end
end
