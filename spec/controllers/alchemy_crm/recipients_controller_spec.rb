require 'spec_helper'

module AlchemyCrm
  describe RecipientsController do

    let(:recipient) { FactoryGirl.create(:recipient) }

    describe '#reads' do

      context "receiving a recipient hash" do

        before do
          get :reads, {:h => recipient.sha1, :use_route => :alchemy_crm}
        end

        it "should record the read and read_at date." do
          recipient.reload
          recipient.read.should be_true
          recipient.read_at.should_not be_nil
        end

        it "should not render anything." do
          response.code.should == "200"
          response.body.should == " "
        end

      end

      context "reading multiple times" do

        it "should not record the reading any more." do
          recipient.update_attributes(:read => true)
          get :reads, {:h => recipient.sha1, :use_route => :alchemy_crm}
          recipient.read_at_changed?.should == false
        end

      end

      context "not receiving a recipient hash" do

        it "should not raise 404 / RecordNotFound error." do
          lambda {
            get :reads, {:use_route => :alchemy_crm}
          }.should_not raise_error(ActiveRecord::RecordNotFound)
        end

        it "should not record any reading." do
          get :reads, {:use_route => :alchemy_crm}
          recipient.reload
          recipient.read.should be_false
        end

      end

    end

    describe '#reacts' do

      let(:language_root) { FactoryGirl.create(:language_root_page) }
      let(:page)          { FactoryGirl.create(:public_page) }

      context "receiving a redirect url" do

        before do
          get :reacts, {:h => recipient.sha1, :r => "http://google.de", :use_route => 'alchemy_crm'}
        end

        it "should record the url as reaction for recipient." do
          recipient.reactions.collect(&:url).should include("http://google.de")
        end

        it "should redirect to url." do
          response.code.should == "302"
          response.should redirect_to('http://google.de')
        end

      end

      context "receiving a page id" do

        before do
          get :reacts, {:h => recipient.sha1, :page_id => page.id, :use_route => 'alchemy_crm'}
        end

        it "should record the page id as reaction for recipient." do
          recipient.reactions.collect(&:page_id).should include(page.id)
        end

        it "should redirect to page path." do
          response.code.should == "302"
          response.should redirect_to("/#{page.urlname}")
        end

      end

      context "not receiving a page id" do

        it "should raise 404 / RecordNotFound." do
          lambda {
            get :reacts, {:h => recipient.sha1, :use_route => 'alchemy_crm'}
          }.should raise_error(ActiveRecord::RecordNotFound)
        end

      end

      context "receiving page id and element id" do

        before do
          Alchemy::Element.stub!(:descriptions).and_return([{"name" => "headline"}])
          @element = Alchemy::Element.create!(:name => 'headline', :page_id => page.id)
          get :reacts, {:h => recipient.sha1, :page_id => page.id, :element_id => @element.id, :use_route => 'alchemy_crm'}
        end

        it "should record the page id and element id as reaction for recipient." do
          recipient.reactions.collect(&:page_id).should include(page.id)
          recipient.reactions.collect(&:element_id).should include(@element.id)
        end

        it "should redirect to page path with element dom id as anchor." do
          response.code.should == "302"
          response.should redirect_to("/#{page.urlname}##{@element.dom_id}")
        end

      end

      context "not receiving a recipient id" do

        it "should not raise 404 / RecordNotFound." do
          lambda {
            get :reacts, {:r => "http://google.de", :use_route => 'alchemy_crm'}
          }.should_not raise_error(ActiveRecord::RecordNotFound)
        end

        it "should not record any reactions." do
          get :reacts, {:r => "http://google.de", :use_route => 'alchemy_crm'}
          recipient.reactions.should be_empty
        end

        it "should redirect." do
          get :reacts, {:r => "http://google.de", :use_route => 'alchemy_crm'}
          response.code.should == "302"
          response.should redirect_to('http://google.de')
        end

      end

    end

  end
end
