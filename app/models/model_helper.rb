module ModelHelper

    def code_with_description
      s = self.code.to_s + ' ' + self.description
      return s
    end

end
