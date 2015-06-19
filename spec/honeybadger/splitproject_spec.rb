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
    context "when a non blank team name is given" do
      before do
        # pre-condition
        expect(Honeybadger).not_to respond_to(:notify_team1)
        expect(Honeybadger).not_to respond_to(:notify_detailed_team1)
      end
      after do
        revert_definition
      end
      
      context "when there exists an API key in the environment" do
        before do
          ENV['HONEYBADGER_API_KEY_TEAM1'] = 'api_key'
        end
        after do
          ENV.delete('HONEYBADGER_API_KEY_TEAM1')
        end
        
        describe "#notify" do
          it "should add a notify method to honeybadger module named after team" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")

            expect(Honeybadger).to respond_to(:notify_team1)
          end
          it "should add a notify method that delegates to the original notify method" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")
            @options = { :key => "1" }

            expect(Honeybadger).to receive(:notify).with("exception", @options.merge(tn_team: "team1")).once

            Honeybadger.notify_team1("exception", @options)
          end
          it "should default the options hash if none is passed in, for the notify method" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")

            expect(Honeybadger).to receive(:notify).with("exception", { tn_team: "team1" }).once

            Honeybadger.notify_team1("exception")
          end
        end
        
        describe "#notify_detailed" do
          it "should add a notify detailed method to honeybadger module named after team" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")

            expect(Honeybadger).to respond_to(:notify_detailed_team1)
          end
          it "should add a notify detailed method that delegates to the original notify detailed method" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")
            params = { param1: "1" }
            expected_params = { error_class: "error_class", error_message: "error_message", parameters: params }

            expect(Honeybadger).to receive(:notify).with(expected_params, { tn_team: "team1" }).once

            Honeybadger.notify_detailed_team1("error_class", "error_message", params)
          end
          it "should default the options hash if none is passed in for the notify detailed method" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")
            expected_params = { error_class: "error_class", error_message: "error_message", parameters: {} }

            expect(Honeybadger).to receive(:notify).with(expected_params, tn_team: "team1").once

            Honeybadger.notify_detailed_team1("error_class", "error_message")
          end
        end
      end
      
      context "when there doesn't exist an API key in the environment" do
        before do
          ENV.delete('HONEYBADGER_API_KEY_TEAM1')
        end
        
        describe "#notify" do
          it "should add a notify method to honeybadger module named after team" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")

            expect(Honeybadger).to respond_to(:notify_team1)
          end
          it "should add a notify method that delegates to the original notify method without adding a api key" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")
            @options = { :key => "1" }

            expect(Honeybadger).to receive(:notify).with("exception", @options).once

            Honeybadger.notify_team1("exception", @options)
          end
          it "should default the options hash if none is passed in, for the notify method" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")

            expect(Honeybadger).to receive(:notify).with("exception", {}).once

            Honeybadger.notify_team1("exception")
          end
        end
        
        describe "#notify_detailed" do
          it "should add a notify detailed method to honeybadger module named after team" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")

            expect(Honeybadger).to respond_to(:notify_detailed_team1)
          end
          it "should add a notify detailed method that delegates to the original notify detailed method" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")
            params = { param1: "1" }
            expected_params = { error_class: "error_class", error_message: "error_message", parameters: params }

            expect(Honeybadger).to receive(:notify).with(expected_params, {}).once

            Honeybadger.notify_detailed_team1("error_class", "error_message", params)
          end
          it "should default the options hash if none is passed in for the notify detailed method" do
            Honeybadger::Splitproject.add_notifiers_for_team("team1")
            expected_params = { error_class: "error_class", error_message: "error_message", parameters: {} }

            expect(Honeybadger).to receive(:notify).with(expected_params, {}).once

            Honeybadger.notify_detailed_team1("error_class", "error_message")
          end
        end
      end
    end
    
    context "when a blank team postfix is given" do
      it "should raise an error" do
        expect { Honeybadger::Splitproject.add_notifiers_for_team(" ") }.to raise_error(/Blank team/)
      end
    end
    
    context "when a nil team postfix is given" do
      it "should raise an error" do
        expect { Honeybadger::Splitproject.add_notifiers_for_team(nil) }.to raise_error(/Blank team/)
      end
    end

    context "when a notifier is already setup for the team" do
      before do
        ENV['HONEYBADGER_API_KEY_TEAM'] = 'api_key'
        Honeybadger::Splitproject.add_notifiers_for_team("team")
      end
      after do
        ENV.delete('HONEYBADGER_API_KEY_TEAM')
      end
      it "should raise an error" do
        expect { Honeybadger::Splitproject.add_notifiers_for_team("team") }.to raise_error(/Team team already setup/)
      end
    end
  end
end