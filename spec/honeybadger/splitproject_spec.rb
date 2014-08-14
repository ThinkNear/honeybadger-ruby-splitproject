require 'spec_helper'
require 'honeybadger/splitproject'

describe Honeybadger::Splitproject do
  def revert_definition
    Honeybadger.instance_eval do
      class << self
        remove_method :notify_team1
        remove_method :notify_detailed_team1
      end
    end
  end
  
  describe "#add_notifiers_for_team" do
    context "when valid parameters are given" do
      before do
        # pre-condition
        expect(Honeybadger).not_to respond_to(:notify_team1)
        expect(Honeybadger).not_to respond_to(:notify_detailed_team1)

        Honeybadger::Splitproject.add_notifiers_for_team("team1", "api_key")
        @options = { :key => "1" }
      end
      after do
        revert_definition
      end
      it "should add a notify method to honeybadger module named after team" do
        expect(Honeybadger).to respond_to(:notify_team1)
      end
      it "should add a notify method that delegates to the original notify method" do
        expect(Honeybadger).to receive(:notify).with("exception", @options.merge(api_key: "api_key")).once
        Honeybadger.notify_team1("exception", @options)
      end
      it "should add a notify detailed method to honeybadger module named after team" do
        expect(Honeybadger).to respond_to(:notify_detailed_team1)
      end
      it "should add a notify detailed method that delegates to the original notify detailed method" do
        params = { :param1 => "1" }
        expected_params = params.merge(error_message: "error_message", api_key: "api_key")

        expect(Honeybadger).to receive(:notify).with({ :error_class => "error_class" }, expected_params).once

        Honeybadger.notify_detailed_team1("error_class", "error_message", params)
      end
    end
    
    context "when a blank team postfix is given" do
      it "should raise an error" do
        expect { Honeybadger::Splitproject.add_notifiers_for_team(" ", "api_key") }.to raise_error
      end
    end
    
    context "when a nil team postfix is given" do
      it "should raise an error" do
        expect { Honeybadger::Splitproject.add_notifiers_for_team(nil, "api_key") }.to raise_error
      end
    end
    
    context "when a blank api key is given" do
      it "should raise an error" do
        expect { Honeybadger::Splitproject.add_notifiers_for_team("team", " ") }.to raise_error
      end
    end
    
    context "when a nil api key is given" do
      it "should raise an error" do
        expect { Honeybadger::Splitproject.add_notifiers_for_team("team", nil) }.to raise_error
      end
    end
    
    context "when a notifier is already setup for the team" do
      before do
        Honeybadger::Splitproject.add_notifiers_for_team("team", "key")
      end
      it "should raise an error" do
        expect { Honeybadger::Splitproject.add_notifiers_for_team("team", "key") }.to raise_error(/Team postfix team already setup/)
      end
    end
  end
end