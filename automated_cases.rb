require "json"
require "selenium-webdriver"
require "rspec"
include RSpec::Expectations
#include RSpec::Matchers

class ListingPage

  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @base_url = "http://immense-hollows-74271.herokuapp.com/"
    @driver.manage.timeouts.implicit_wait = 30
  end

  def wait_for(seconds = 2)
    Selenium::WebDriver::Wait.new(:timeout => seconds).until { yield }
  end

  def release_resources
    @driver.quit
  end

  #get resources from page
  def get_listing_by_order(order)
    wait_for { @driver.find_element(:xpath,"//*[@id='content']//li[#{order}]") }
  end

  def get_listing_text_by_order(order)
    wait_for { @driver.find_element(:xpath,"//*[@id='content']//li[#{order}]//p") }.text
  end

  def get_listing_text_by_order(order)
    wait_for { @driver.find_element(:xpath,"//*[@id='content']//li[#{order}]//p") }.text
  end

  def get_list_title()
    wait_for { @driver.find_element(:css, "h1.ng-binding") }.text
  end
        
  def get_edit_button()
    wait_for { @driver.find_element(:css, "button.btn.btn-default") }
  end
    
  def get_delete_button()
    wait_for { @driver.find_element(:xpath, "(//button[@type='button'])[3]") }
  end

  def get_text_edit_button()
    get_edit_button.text
  end
    
  def get_text_delete_button()
    get_delete_button.text
  end

  def click_item_edit_button
    wait_for { @driver.find_element(:xpath, '//*[@id="content"]//li[1]//button[1]') }.click
    #wait_for { @driver.find_element(:xpath, '//*[@id="content"]/div[1]/div/ul/li[1]/div/div/div[1]/button[1]') }.click
  end
  
  def clear_item_text
    wait_for {  @driver.find_element(:name, "text") }.clear
  end

  def change_item_text(text_to_update)
    wait_for { @driver.find_element(:name, "text") }.send_keys text_to_update
  end

  def click_update_item()
    wait_for { @driver.find_element(:css, 'button.btn.pull-right.btn-primary') }.click
  end

  def get_text_item(pos_item)
    wait_for { @driver.find_element(:xpath,"//*[@id='content']//li[#{pos_item}]//div[2]/p")  }
  end

  def get_form_item_details_text()
    wait_for { @driver.find_element(:css, "h3")  }.text
  end

  def get_for_image_title()
    wait_for { @driver.find_element(:xpath,'//*[@id="content"]//form/div[1]//label')  }.text
  end

  def get_form_cancel_button_text()
    wait_for { @driver.find_element(:xpath,'//*[@id="content"]//div[3]//button[1]')  }.text
  end

  def get_form_update_text()
    wait_for { @driver.find_element(:css,'button.btn.pull-right.btn-primary')  }.text
  end

  def click_delete_first_element()
    wait_for { @driver.find_element(:xpath, "(//button[@type='button'])[3]") }.click
  end

  def click_confirm_delete()
    wait_for { @driver.find_element(:css, "button.btn.btn-primary") }.click
  end

  def get_item_by_xpath(xpath_expression)
    wait_for { @driver.find_element(:xpath,xpath_expression) }.text()
  end

  #Functional cases
  def go_to_home
    @driver.get(@base_url + "/")
  end

  #Helpers for Test Cases
  def reload()
    go_to_home()
  end

  def swap_elements(first, second)
    first_element = get_listing_by_order(first)
    second_element = get_listing_by_order(second)

    #swap first and second elements
    @driver.action.drag_and_drop(second_element,first_element).perform
  end

  def update_first_item(text_to_update)
    click_item_edit_button()
    clear_item_text()
    change_item_text(text_to_update)
    click_update_item()
  end

end

describe "Sample Automated Cases" do
  #Before all the cases....
  before(:context) do
    @listingPage = ListingPage.new
    @listingPage.go_to_home
  end
  #After all the cases....
  after(:context) do
    @listingPage.release_resources
  end
  
  #Tests for Feature 1
  context "Feature 1 - Able to sort" do
    it "1.1 - Swap First and Second Items" do
        #Get current text in first place
        first_text =  @listingPage.get_listing_text_by_order(1)
        #swap first and second items
        @listingPage.swap_elements(1,2)
        #Get new text in first place
        new_second_text =  @listingPage.get_listing_text_by_order(2)

        #Validate swap
        expect(first_text).to eql(new_second_text)

    end
  end

  #Test for Feature 2
  context "Feature 2 - Counter" do
    it "2.1 - Counter is Present" do
        #get the counter
        counter_text = @listingPage.get_list_title() 

        #validate ounter is present
        expect(counter_text).to eql("List of items (13)")
    end
  end

  #Test for Feature 3
  context "Feature 3 - Add/Edit functionality" do
    it "3.1 - Edit and Delete Buttons are Present" do
        #Get the buttons
        edit_button = @listingPage.get_text_edit_button()
        delete_button = @listingPage.get_text_delete_button()

        #Validate Buttons are present
        expect(edit_button).to eql("Edit")
        expect(delete_button).to eql("Delete")
    end

    it "3.2 - Edit a Row" do
        #Update the fist item in the list
        @listingPage.update_first_item("Changed!")
        edited_item = @listingPage.get_text_item(1)

        #Validate if Text was edited
        expect(edited_item.text).to eql("Changed!")
    end

    it "3.3 - Delete Button is working" do
        @listingPage.go_to_home

        #Delete the first item
        @listingPage.click_delete_first_element()
        @listingPage.click_confirm_delete()

        #Reload the page
        @listingPage.reload
        counter_text = @listingPage.get_list_title() 

        #validate ounter is present
        expect(counter_text).to eql("List of items (12)")

    end
  end

  #Test for Feature 4
  context "Feature 4 - Add Form" do
    it "4.1 - Add Form is Present" do
        @listingPage.go_to_home
        #Click Edit from Listing items
        @listingPage.click_item_edit_button()

        #Now validate the Form is present and enabled
        form_item_details_text = @listingPage.get_form_item_details_text()
        for_image_title = @listingPage.get_for_image_title()
        form_cancel_button_text = @listingPage.get_form_cancel_button_text()
        form_update_text = @listingPage.get_form_update_text()

        #Validate Form exists
        expect(form_item_details_text).to eql("Item Details")
        expect(for_image_title).to eql("*Image 320px x 320px") 
        expect(form_cancel_button_text).to eql("Cancel") 
        expect(form_update_text).to eql("Update Item") 
    end
  end
  
  #Test for Feature 6
  context "Feature 6 - Refresh keep changes" do
    it "6.1 - Add Form is Present" do
        @listingPage.go_to_home

        first_text =  @listingPage.get_listing_text_by_order(1)
        #swap first and second items
        @listingPage.swap_elements(1,2)

        #Reload Page...
        @listingPage.reload

        #validate second elemant is in first place after refresh!
        #Get new text in first place
        new_second_text =  @listingPage.get_listing_text_by_order(2)
        #Validate swap
        expect(first_text).to eql(new_second_text)
    end
  end


end
