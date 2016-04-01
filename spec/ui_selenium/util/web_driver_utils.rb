class WebDriverUtils

  include ClassLogger

  def self.launch_browser
    # Sometimes browser does not launch successfully, so try twice
    tries ||= 2
    logger.info('Launching browser')
    case Settings.ui_selenium.web_driver
      when 'firefox'
        driver = Selenium::WebDriver.for :firefox
        driver.manage.window.maximize
        driver
      when 'chrome'
        Selenium::WebDriver.for :chrome
      when 'safari'
        Selenium::WebDriver.for :safari
      else
        logger.error 'Unsupported webdriver'
    end
  rescue => e
    logger.error('Browser failed to launch')
    logger.error e.message + "\n" + e.backtrace.join("\n")
    retry unless (tries -= 1).zero?
  end

  def self.quit_browser(driver)
    logger.info 'Quitting the browser'
    # If the browser did not start successfully, the quit method will fail.
    driver.quit rescue NoMethodError
    # Pause after quitting the browser to make sure it shuts down completely before the next test relaunches it
    sleep 2
  end

  def self.base_url
    Settings.ui_selenium.base_url
  end

  def self.cal_net_url
    Settings.ui_selenium.cal_net_url
  end

  def self.canvas_base_url
    Settings.ui_selenium.canvas_base_url
  end

  def self.canvas_qa_sub_account
    Settings.ui_selenium.canvas_qa_sub_account
  end

  def self.google_auth_url
    Settings.ui_selenium.google_auth_url
  end

  def self.page_load_timeout
    Settings.ui_selenium.page_load_timeout
  end

  def self.campus_solutions_timeout
    Settings.ui_selenium.campus_solutions_timeout
  end

  def self.academics_timeout
    Settings.ui_selenium.academics_timeout
  end

  def self.google_task_timeout
    Settings.ui_selenium.google_task_timeout
  end

  def self.page_event_timeout
    Settings.ui_selenium.page_event_timeout
  end

  def self.canvas_update_timeout
    Settings.ui_selenium.canvas_update_timeout
  end

  def self.mail_live_update_timeout
    Settings.cache.expiration.marshal_dump["MyBadges::GoogleMail".to_sym] + Settings.ui_selenium.live_update_timeout_delta
  end

  def self.tasks_live_update_timeout
    Settings.cache.expiration.marshal_dump["MyTasks::GoogleTasks".to_sym] + Settings.ui_selenium.live_update_timeout_delta
  end

  def self.live_users
    File.join(CalcentralConfig.local_dir, "uids.json")
  end

  def self.ui_numeric_date_format(date)
    today = Date.today
    if date.strftime("%Y") == today.strftime("%Y")
      date_format = date.strftime("%m/%d")
    else
      date_format = date.strftime("%m/%d/%Y")
    end
    date_format
  end

  def self.ui_alphanumeric_date_format(date)
    date.strftime("%b %-d")
  end

  def self.ui_date_input_format(date)
    date.strftime("%m/%d/%Y")
  end

  def self.currency_to_f(dollar_amount)
    dollar_amount.delete('$, ').to_f
  end

  def self.wait_for_page_and_click(element)
    element.when_present page_load_timeout
    element.when_visible page_event_timeout
    element.click
  end

  def self.wait_for_element_and_click(element)
    element.when_present timeout=page_event_timeout
    element.when_visible timeout
    element.click
  end

  def self.wait_for_element_and_type(element, text)
    wait_for_element_and_click element
    element.clear
    element.send_keys text
  end

  def self.wait_for_element_and_select(element, option)
    element.when_visible(timeout=page_event_timeout)
    wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
    wait.until { element.include? option }
    element.select option
  end

  def self.verify_external_link(driver, link, expected_page_title)
    begin
      link.click
      if driver.window_handles.length > 1
        driver.switch_to.window driver.window_handles.last
        wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_load_timeout)
        wait.until { driver.title.include?("#{expected_page_title}") }
        true
      else
        logger.error('Link did not open in a new window')
        false
      end
    rescue
      logger.error "Expected page title '#{expected_page_title}', but got '#{driver.title}' instead"
      return false
    ensure
      if driver.window_handles.length > 1
        # Handle any alert that might appear when opening the new window
        driver.switch_to.alert.accept rescue Selenium::WebDriver::Error::NoAlertPresentError
        driver.close
        # Handle any alert that might appear when closing the new window
        driver.switch_to.alert.accept rescue Selenium::WebDriver::Error::NoAlertPresentError
      end
      driver.switch_to.window driver.window_handles.first
    end
  end

  def self.verify_block(&blk)
    begin
      return true if yield
    rescue
      false
    end
  end

  def self.save_screenshot(driver, uid, page_title)
    output_dir = Rails.root.join('tmp', 'ui_selenium_ouput', 'screenshots')
    unless File.exists?(output_dir)
      FileUtils.mkdir_p(output_dir)
    end
    driver.save_screenshot Rails.root.join(output_dir, "#{uid}-#{page_title}.png")
  end

end
