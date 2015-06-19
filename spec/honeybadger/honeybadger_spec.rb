require 'spec_helper'
require 'honeybadger/honeybadger'
require 'honeybadger/splitproject'

class Dummy
end

describe Honeybadger do
  before do
    Honeybadger.clear_team
  end
  
  describe "#notify_detailed" do
    it "should delegate call to notify with proper params" do
      expect(Honeybadger).to receive(:notify)
        .with(error_class: "error_class", error_message: "error_message", parameters: { :key => "val" }).once
      Honeybadger.notify_detailed("error_class", "error_message", { :key => "val" })
    end
    
    it "should to string the error class to prevent stack overflow in HB" do
      expect(Honeybadger).to receive(:notify)
        .with(error_class: "Class", error_message: "error_message", parameters: { :key => "val" }).once
      Honeybadger.notify_detailed(Dummy.class, "error_message", { :key => "val" })
    end
  end

  describe "#set_team" do
    it "should set thread local variable" do
      Honeybadger.set_team('test_it')
      expect(Thread.current[:tn_honeybadger_team]).to equal(:test_it)
    end
  end

  describe "notify" do
    context "when team is not set" do
      it "should call notify base without api key" do
        expect(Honeybadger).to receive(:notify_super) do |args|
          expect(args).to_not have_key(:api_key)
        end

        Honeybadger.notify("test_it")
      end

    end

    context "when team is set by set_team" do
      it "should call notify base with api key for team" do
        ENV['HONEYBADGER_API_KEY_TESTIT'] = "test"
        Honeybadger.set_team("testit")
        expect(Honeybadger).to receive(:notify_super) do |args|
          expect(args).to have_key(:api_key)
        end

        Honeybadger.notify("testing")
      end
    end

    context "when team is passed in" do
      it "should call notify base with api key for team" do
        ENV['HONEYBADGER_API_KEY_TESTIT'] = "test"
        expect(Honeybadger).to receive(:notify_super) do |args|
          expect(args).to have_key(:api_key)
        end

        Honeybadger.notify({ :tn_team => "testit", :exception_name => "testing"})
      end
    end
  end
  
end