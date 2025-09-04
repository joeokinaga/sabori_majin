require 'rails_helper'

RSpec.describe "Rankings", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/rankings/show"
      expect(response).to have_http_status(:success)
    end
  end

end
