describe 'My Profile Basic Info', :testui => true, :order => :defined do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer == 'local'

    include ClassLogger

    before(:all) do
      @test_users = UserUtils.load_profile_test_data
      logger.info "There are #{@test_users.length.to_s} test users"
      @driver = WebDriverUtils.launch_browser
      @splash_page = CalCentralPages::SplashPage.new @driver
      @cal_net_page = CalNetAuthPage.new @driver
      @my_dashboard = CalCentralPages::MyDashboardPage.new @driver
      @basic_info_card = CalCentralPages::MyProfileBasicInfoCard.new @driver
    end

    before(:all) do
      @student = @test_users.first
      @student_info = @student['basicInfo']
      @splash_page.load_page
      @splash_page.basic_auth @student_info['uid']
      @my_dashboard.click_profile_link @driver
    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

    describe 'viewing official name' do

      it 'shows the first name, middle name, last name, and suffix' do
        @basic_info_card.name_element.when_visible WebDriverUtils.page_load_timeout
        expect(@basic_info_card.name).to eql("#{@student_info['officialName']['firstName']} #{@student_info['officialName']['lastName']}")
      end

    end

    describe 'viewing and editing preferred name' do

      before(:each) do
        @basic_info_card.preferred_name_element.when_visible WebDriverUtils.page_load_timeout
        # if preferred name is already set to one of the test names, then use the other one for this test
        (@basic_info_card.preferred_name == @student_info['preferredName']['option1']) ?
            @preferred_name = @student_info['preferredName']['option2'] :
            @preferred_name = @student_info['preferredName']['option1']
      end

      it 'allows the student to save an edited name' do
        @basic_info_card.edit_pref_name @preferred_name
        @basic_info_card.wait_until(WebDriverUtils.page_load_timeout) { @basic_info_card.preferred_name == @preferred_name }
      end

      it 'allows the student to cancel an edited name' do
        original_name = @basic_info_card.preferred_name
        @basic_info_card.click_edit_pref_name_button
        @basic_info_card.enter_preferred_name @preferred_name
        @basic_info_card.click_cancel_pref_name_button
        @basic_info_card.wait_until(WebDriverUtils.page_load_timeout) { @basic_info_card.preferred_name == original_name }
      end

      it 'allows a maximum of 30 characters for an edited name' do
        max_char_name = @student_info['preferredName']['maxChar']
        @basic_info_card.edit_pref_name max_char_name
        @basic_info_card.wait_until(WebDriverUtils.page_load_timeout) { @basic_info_card.preferred_name == max_char_name[0..29] }
      end

      it 'permits but trims leading or trailing spaces in an edited name' do
        whitespace_name = @student_info['preferredName']['leadingWhitespace']
        @basic_info_card.edit_pref_name whitespace_name
        @basic_info_card.wait_until(WebDriverUtils.page_load_timeout) { @basic_info_card.preferred_name == whitespace_name.strip }
      end

    end

    describe 'preferred name validation' do

      it 'does not permit the use of special characters for an edited name' do
        special_char_name = @student_info['preferredName']['specChar']
        @basic_info_card.click_edit_pref_name_button
        @basic_info_card.enter_preferred_name special_char_name
        @basic_info_card.preferred_name_error_element.when_visible WebDriverUtils.page_event_timeout
      end

      it 'does not permit the use of consecutive spaces in an edited name' do
        spaces_name = @student_info['preferredName']['consecutiveSpaces']
        @basic_info_card.enter_preferred_name spaces_name
        @basic_info_card.preferred_name_error_element.when_visible WebDriverUtils.page_event_timeout
      end

      it 'does not permit the use of consecutive hyphens in an edited name' do
        hyphens_name = @student_info['preferredName']['consecutiveHyphens']
        @basic_info_card.enter_preferred_name hyphens_name
        @basic_info_card.preferred_name_error_element.when_visible WebDriverUtils.page_event_timeout
      end

      it 'does not permit the use of leading or trailing hyphens in an edited name' do
        leading_hyphen_name = @student_info['preferredName']['leadingHyphens']
        @basic_info_card.enter_preferred_name leading_hyphen_name
        @basic_info_card.preferred_name_error_element.when_visible WebDriverUtils.page_event_timeout
      end

    end

    describe 'viewing SID' do

      it 'shows the SID and its label if the SID exists' do
        if @student_info['sid'].nil?
          expect(@basic_info_card.sid?).to be false
        else
          expect(@basic_info_card.sid).to eql(@student_info['sid'])
        end
      end

    end

    describe 'viewing UID' do

      it 'shows the UID and its label' do
        expect(@basic_info_card.uid).to eql(@student_info['uid'])
      end

    end
  end
end
