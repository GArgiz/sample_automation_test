require "json"
require "selenium-webdriver"
require "rspec"
include RSpec::Expectations


describe "Sample Automated Cases" do
  #Before all the cases....
  before(:context) do
    @driver = Selenium::WebDriver.for :chrome
    @base_url = "http://immense-hollows-74271.herokuapp.com/"
    @driver.manage.timeouts.implicit_wait = 30
  end
  #After all the cases....
  after(:context) do
    @driver.quit
  end
  
  #Tests for Feature 1
  context "Feature 1 - Able to sort" do
    it "1.1 - Swap First and Second Items" do
        @driver.get(@base_url + "/")
        first_element = @driver.find_element(:xpath,'//*[@id="content"]/div[1]/div/ul/li[1]')
        second_element = @driver.find_element(:xpath, '//*[@id="content"]/div[1]/div/ul/li[2]')
        second_element_text = @driver.find_element(:xpath,'//*[@id="content"]/div[1]/div/ul/li[2]/div/div/div[2]/p').text
 

        #swap first and second elements
        @driver.action.drag_and_drop(second_element,first_element).perform

        #validate second elemant is now in first place!
        sleep 2
        new_first_element_text = @driver.find_element(:xpath,'//*[@id="content"]/div[1]/div/ul/li[1]/div/div/div[2]/p').text 
        expect(second_element_text).to eql(new_first_element_text)
    end
  end

  #Test for Feature 2
  context "Feature 2 - Counter" do
    it "2.1 - Counter is Present" do
        @driver.get(@base_url + "/")
        counter_text = @driver.find_element(:css, "h1.ng-binding").text

        #validate ounter is present
        expect(counter_text).to eql("List of items (13)")
    end
  end

  #Test for Feature 3
  context "Feature 3 - Add/Edit functionality" do
    it "3.1 - Edit and Delete Buttons are Present" do
        @driver.get(@base_url + "/")
        #Validate Buttons are present
        expect(@driver.find_element(:css, "button.btn.btn-default").text).to eql("Edit")
        expect(@driver.find_element(:xpath, "(//button[@type='button'])[3]").text).to eql("Delete")
    end

    it "3.2 - Edit a Row" do       
        @driver.get(@base_url + "/")
        #Edit the first item
        @driver.find_element(:css, "button.btn.btn-default").click
        @driver.find_element(:name, "text").clear
        @driver.find_element(:name, "text").send_keys "Changed!"
        @driver.find_element(:xpath, "//div[@id='content']/div[2]/div/div/form/div[3]/button[2]").click

        #just wait 2 seconds for UI update
        sleep 2

        #look the item in new list (Should NOT be in there)
        edited_item = @driver.find_element(:xpath,'//*[@id="content"]/div[1]/div/ul/li[1]/div/div/div[2]/p')

        #Validate if Text was edited
        expect(edited_item.text).to eql("Changed!")
    end

    it "3.3 - Delete Button is working" do
        @driver.get(@base_url + "/")
        #Get the first item
        first_element_text = @driver.find_element(:xpath,'//*[@id="content"]/div[1]/div/ul/li[1]/div/div/div[2]/p').text 
        xpath_expression = '//*[@id="content"]/div[1]//*[contains(text(), "'+ first_element_text + '")]'

        #Now, Delete the first item
        @driver.find_element(:xpath, "(//button[@type='button'])[3]").click
        @driver.find_element(:css, "button.btn.btn-primary").click

        #just wait 2 seconds for UI update
        sleep 2
        #look the item in new list (Should NOT be in there)
        deleted_item = @driver.find_elements(:xpath,xpath_expression)

        #not in list, so... result is empty
        expect(deleted_item.empty?).to eql(true)
    end
  end

  #Test for Feature 4
  context "Feature 4 - Add Form" do
    it "4.1 - Add Form is Present" do
        @driver.get(@base_url + "/")
        counter_text = @driver.find_element(:css, "h1.ng-binding").text

        #Validate Form exists
        expect(@driver.find_element(:css, "h3").text).to eql("Item Details")
        expect(@driver.find_element(:xpath, '//*[@id="content"]/div[2]/div/div/form/div[1]/div/label').text).to eql("*Image 320px x 320px") 
        @driver.find_element(:xpath, '//*[@id="content"]/div[2]/div/div/form/div[3]/button')
    end
  end
  
  #Test for Feature 6
  context "Feature 6 - Refresh keep changes" do
    it "6.1 - Add Form is Present" do
        @driver.get(@base_url + "/")
        #Swap First and Second items
        first_element = @driver.find_element(:xpath,'//*[@id="content"]/div[1]/div/ul/li[1]')
        second_element = @driver.find_element(:xpath, '//*[@id="content"]/div[1]/div/ul/li[2]')
        second_element_text = @driver.find_element(:xpath,'//*[@id="content"]/div[1]/div/ul/li[2]/div/div/div[2]/p').text
        @driver.action.drag_and_drop(second_element,first_element).perform

        #Reload Page...
        @driver.get(@base_url + "/")

        #validate second elemant is in first place after refresh!
        new_first_element_text = @driver.find_element(:xpath,'//*[@id="content"]/div[1]/div/ul/li[1]/div/div/div[2]/p').text 
        expect(second_element_text).to eql(new_first_element_text)
    end
  end


end
