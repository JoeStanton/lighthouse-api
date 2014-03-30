require 'spec_helper'
describe ComponentsController do
  before(:all) do
    @service = Service.create(name: "A")
  end

  describe "GET index" do
    it "renders all components" do
      @component = Component.create(name: "Component A")
      get :index, service_id: @service
      assert_response :success
      assigns components: [@component]
    end
  end

  describe "GET show" do
    it "renders all components" do
      @component = Component.create(name: "component A")
      get :show, service_id: @service, id: @component.slug

      assert_response :success
      assigns component: @component
    end
  end

  describe "PUT components" do
    it "updates an existing component" do
      component = Component.create(name: "Existing component")
      put :update, service_id: @service, id: "existing-component", component: { description: "New description" }
      assert_response :success

      component.reload.description.should == "New description"
    end
  end

  describe "PUT component status" do
    it "updates component status and triggers an incident" do
      component = @service.components.create(name: "Problematic component")
      put :update, service_id: @service, id: "problematic-component", component: { status: "error" }
      assert_response :success

      component.service.open_incident.should be_present
    end

    it "updates component status and closes an incident" do
      component = @service.components.create(name: "Problematic component")
      put :update, service_id: @service, id: "problematic-component", component: { status: "ok" }
      assert_response :success

      component.service.open_incident.should_not be_present
    end
  end
end
