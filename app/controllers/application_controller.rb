class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  
  private
  
    def record_not_found
      render json: { errors: [{error_message: "Record not found"}]}.to_json, status: "404"
    end
    
end
