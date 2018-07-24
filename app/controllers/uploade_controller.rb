class UploadeController < ApplicationController
    def uploader
        @image = Image.create(image_path: params[:upload][:image])
        render json: @image.as_json
    end
end
