class BestellrundenController < InheritedResources::Base

  private

    def bestellrunde_params
      params.require(:bestellrunde).permit()
    end
end

