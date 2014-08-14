require 'spec_helper'
require 'sidekiq'
require 'honeybadger/honeybadger'

describe Honeybadger do
  
  describe "#notify_detailed" do
    it "should delegate call to notify with proper params" do
      expect(Honeybadger).to receive(:notify)
        .with(error_class: "error_class", error_message: "error_message", parameters: { :key => "val" }).once
      Honeybadger.notify_detailed("error_class", "error_message", { :key => "val" })
    end
  end
  
  describe "#notify_or_ignore" do
    it "should delegate to overriden method" do
      expect(Honeybadger.method(:notify_or_ignore)).to eq(Honeybadger.method(:notify_or_ignore_with_devteam_detection))
    end
  end
  
  describe "#notify_or_ignore_without_devteam_detection" do
    it "should delegate to Honeybadger's send method (normal path)" do
      expect(Honeybadger).to receive(:send_notice).once
      Honeybadger.notify_or_ignore_without_devteam_detection("exception", {})
    end
  end
  
  describe "#notify_or_ignore_with_devteam_detection" do
    context "when there is a team override" do
      before do
        @options = { :parameters => { 'alert_team' => 'new team' } }
      end
      
      context "when no honeybadger key exists" do
        before do
          allow(ENV).to receive(:has_key?).and_return(false)
        end
        it "should still notify honeybadger with the other error" do
          expect(Honeybadger).to receive(:notify_or_ignore_without_devteam_detection).with("exception", @options).once
          Honeybadger.notify_or_ignore_with_devteam_detection("exception", @options)
        end
      end
      
      context "when a honeybadger key exists" do
        before do
          allow(ENV).to receive(:has_key?).and_return(true)
          allow(ENV).to receive(:[]).and_return('YES_KEY')
        end
        it "should notify honeybadger with the other error" do
          new_options = @options.merge(:api_key => 'YES_KEY')
          expect(Honeybadger).to receive(:notify_or_ignore_without_devteam_detection).with("exception", new_options).once
          Honeybadger.notify_or_ignore_with_devteam_detection("exception", @options)
        end

      end
    end
    
    context "when there is no team override" do
      before do
        @options = { params: 1 }
      end
      it "should call the regular notify or ignore method" do
        expect(Honeybadger).to receive(:notify_or_ignore_without_devteam_detection).with("exception", @options).once
        
        Honeybadger.notify_or_ignore_with_devteam_detection("exception", @options)
      end
    end
  end
  
end